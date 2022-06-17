import { Achievement, ChangeType, Platform, Status } from "@prisma/client";
import dayjs from "dayjs";
import duration from "dayjs/plugin/duration";
import Discord from "discord.js";
import {
  communityCallReason,
  communityCallStreakReason,
  communityCategoryId,
} from "../constants";
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

    const username = newState.member?.user.username;
    if (!username) return;

    await handleDiscordVoiceUpdate(username);
  });
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
  if (totalCalls === 1 || totalCalls % 5 === 0) {
    await prisma.onChainChangeProposal.create({
      data: {
        categoryOrAccessoryId: communityCategoryId,
        changeType: ChangeType.CATEGORY_SCORE,
        reason: communityCallReason,
        status: Status.APPROVED,
        isAutomaticallyCreated: true,
        communityMemberEthAddress: handle.communityMemberEthAddress,
        txHash: "",
        gnosisSafeNonce: 0,
        ipfsURL: "",
      },
    });
  }

  if (
    (await getTotalCallStreak(handle.communityMemberEthAddress)) === 4 &&
    !(await hasReceivedStreakAward(handle.communityMemberEthAddress))
  ) {
    await prisma.onChainChangeProposal.create({
      data: {
        categoryOrAccessoryId: communityCategoryId,
        changeType: ChangeType.CATEGORY_SCORE,
        reason: communityCallStreakReason,
        status: Status.APPROVED,
        isAutomaticallyCreated: true,
        communityMemberEthAddress: handle.communityMemberEthAddress,
        txHash: "",
        gnosisSafeNonce: 0,
        ipfsURL: "",
      },
    });
  }
}

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

export async function getTotalCallStreak(ethAddress: string) {
  const allCallsAttended = await prisma.offChainAchievement.findMany({
    where: {
      communityMemberEthAddress: ethAddress,
      platform: Platform.DISCORD,
      achievement: Achievement.COMMUNITY_CALL,
    },
  });

  const sortedCallTimestamps = allCallsAttended
    .sort((a, b) => b.timestamp.getDate() - a.timestamp.getDate())
    .map((call) => call.timestamp.getDate());

  let currentStreak = 1;
  for (let i = 1; i < sortedCallTimestamps.length; i++) {
    if (areWithinAWeek(sortedCallTimestamps[i - 1], sortedCallTimestamps[i])) {
      currentStreak++;
    } else {
      break;
    }
  }
  return currentStreak;
}

async function hasReceivedStreakAward(ethAddress: string) {
  const proposals = await prisma.onChainChangeProposal.findMany({
    where: {
      communityMemberEthAddress: ethAddress,
      reason: communityCallStreakReason,
      isAutomaticallyCreated: true,
    },
  });
  // should probably have some alerting here if above length is greater than 1

  return proposals.length > 0;
}

function areWithinAWeek(dateTimeOne: number, dateTimeTwo: number) {
  const milliSecondsBetween = dayjs(dateTimeOne).diff(dateTimeTwo);
  return dayjs.duration(milliSecondsBetween).asDays() < 8;
}
