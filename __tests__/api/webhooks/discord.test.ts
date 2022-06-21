import { Achievement, Platform } from "@prisma/client";
import dayjs from "dayjs";
import { Wallet } from "ethers";
import prisma from "../../../api/src/db";
import {
  getTotalCallStreak,
  getTotalNumberOfCallsJoined,
  handleDiscordVoiceUpdate,
} from "../../../api/src/webhooks/discord";

const address = Wallet.createRandom().address;
const identifier = "some_username";

describe("Discord voice API listener", () => {
  beforeAll(async () => {
    await prisma.communityMember.create({
      data: { ethAddress: address },
    });

    await prisma.handle.create({
      data: {
        communityMemberEthAddress: address,
        platform: Platform.DISCORD,
        identifier,
      },
    });
  });
  afterEach(async () => {
    await prisma.offChainAchievement.deleteMany({});
    await prisma.onChainChangeProposal.deleteMany({});
  });
  afterAll(async () => {
    await prisma.offChainAchievement.deleteMany({});
    await prisma.handle.deleteMany({});
    await prisma.onChainChangeProposal.deleteMany({});
    await prisma.communityMember.deleteMany({});
  });

  describe("When user joins a call", () => {
    it("creates an offchain achievement and on chain proposal if user joins call for first time", async () => {
      await handleDiscordVoiceUpdate(identifier);
      expect(await getTotalNumberOfCallsJoined(address)).toEqual(1);
    });
    it("properly computes the community call streak for a user", async () => {
      for (let i = 0; i < 6; i++) {
        await prisma.offChainAchievement.create({
          data: {
            achievement: Achievement.COMMUNITY_CALL,
            platform: Platform.DISCORD,
            communityMemberEthAddress: address,
            timestamp: dayjs("2022-01-01").add(i, "week").toISOString(),
          },
        });
      }

      expect(await getTotalCallStreak(address)).toEqual(6);
    });
  });
});
