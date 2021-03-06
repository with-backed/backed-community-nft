import { Achievement, Platform, Status } from "@prisma/client";
import dayjs from "dayjs";
import duration from "dayjs/plugin/duration";
import Discord from "discord.js";
import { findOrCreateCommunityMember } from "../communityMembers/crud";
import { communityCallReason, communityCategoryId } from "../constants";
import prisma from "../db";

dayjs.extend(duration);

export function setupDiscordVoiceChannelListener() {
  const client = new Discord.Client();
  client.login(process.env.DISCORD_BOT_TOKEN!);
  client.on("voiceStateUpdate", async (oldState, newState) => {
    // null or undefined oldState.channelID means user is joining a voice channel
    if (oldState.channelID !== null && typeof oldState.channelID != "undefined")
      return;
    // make sure we are on the community call channel id
    if (newState.channelID !== process.env.COMMUNITY_CALL_CHANNEL_ID!) return;

    if (!newState.member?.user) return;

    const identifier = generateIdentifierFromUserObject(newState.member.user);

    await handleDiscordVoiceUpdate(identifier);
  });

  client.on("message", async (message) => {
    if (!message.member?.user) return;
    if (message.channel.id !== process.env.DISCORD_USERNAME_LINK_CHANNEL_ID!)
      return;

    if (!message.content.startsWith("0x")) return;

    const communityMember = await findOrCreateCommunityMember(message.content);

    const constructedUsername = generateIdentifierFromUserObject(
      message.member.user
    );

    try {
      await prisma.handle.upsert({
        create: {
          communityMemberEthAddress: communityMember.ethAddress,
          identifier: constructedUsername,
          platform: Platform.DISCORD,
        },
        update: {
          communityMemberEthAddress: communityMember.ethAddress,
        },
        where: {
          handleIdentifier: {
            identifier: constructedUsername,
            platform: Platform.DISCORD,
          },
        },
      });
    } catch (e) {
      console.error(e);
    } finally {
      return;
    }
  });
}

function generateIdentifierFromUserObject(user: Discord.User): string {
  return `${user.username}#${user.discriminator}`;
}

export async function handleDiscordVoiceUpdate(username: string) {
  const handle = await prisma.handle.findUnique({
    where: {
      handleIdentifier: {
        identifier: username,
        platform: Platform.DISCORD,
      },
    },
  });

  if (!handle) return;

  const mostRecentCallJoined = await prisma.offChainAchievement.findFirst({
    where: { communityMemberEthAddress: handle.communityMemberEthAddress },
    orderBy: { timestamp: "desc" },
  });

  if (
    !!mostRecentCallJoined &&
    areWithinAWeek(new Date(), mostRecentCallJoined.timestamp)
  ) {
    return;
  }

  await prisma.offChainAchievement.create({
    data: {
      achievement: Achievement.COMMUNITY_CALL,
      platform: Platform.DISCORD,
      communityMemberEthAddress: handle.communityMemberEthAddress,
    },
  });

  const totalCalls = await getTotalNumberOfCallsJoined(
    handle.communityMemberEthAddress
  );
  if (isPowerOfTwo(totalCalls)) {
    const metadata = await prisma.changeProposalMetadata.create({
      data: {
        reason: communityCallReason,
        status: Status.APPROVED,
        isAutomaticallyCreated: true,
        txHash: "",
        gnosisSafeNonce: 0,
        ipfsURL: "",
      },
    });

    await prisma.categoryOnChainChangeProposal.create({
      data: {
        category: communityCategoryId,
        communityMemberEthAddress: handle.communityMemberEthAddress,
        changeProposalMetadataId: metadata.id,
        value: 1,
      },
    });
  }
}

export const isPowerOfTwo = (n: number) =>
  Math.ceil(Math.log2(n)) === Math.floor(Math.log2(n));

export async function getTotalNumberOfCallsJoined(ethAddress: string) {
  return (
    await prisma.offChainAchievement.findMany({
      where: {
        communityMemberEthAddress: ethAddress,
        platform: Platform.DISCORD,
        achievement: Achievement.COMMUNITY_CALL,
      },
    })
  ).length;
}

function areWithinAWeek(dateTimeOne: Date, dateTimeTwo: Date) {
  const milliSecondsBetween = dayjs(dateTimeOne.getMilliseconds()).diff(
    dateTimeTwo.getMilliseconds()
  );
  return dayjs.duration(milliSecondsBetween).asDays() < 7;
}
