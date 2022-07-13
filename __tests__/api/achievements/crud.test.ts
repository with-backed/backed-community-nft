import { Achievement, Platform } from "@prisma/client";
import { Wallet } from "ethers";
import supertest from "supertest";
import app from "../../../api/src/app";
import prisma from "../../../api/src/db";
import { CreateActivityAchievementBody } from "../../../api/src/achievements/crud";
import {
  firstLendReason,
  firstRepaymentReason,
} from "../../../api/src/constants";

const address = Wallet.createRandom().address;

describe("CRUD methods for achievements", () => {
  afterEach(async () => {
    await prisma.accessoryOnChainChangeProposal.deleteMany({});
    await prisma.categoryOnChainChangeProposal.deleteMany({});
    await prisma.changeProposalMetadata.deleteMany({});
    await prisma.offChainAchievement.deleteMany({});
    await prisma.communityMember.deleteMany({});
  });

  describe("protocol activity achievements", () => {
    it("creates first lend event achievements", async () => {
      const reqBody: CreateActivityAchievementBody = {
        ethAddress: address,
      };
      const { body } = await supertest(app)
        .post("/achievements/create/activity/lend_event")
        .set({ authorization: `username:password` })
        .send(reqBody)
        .expect(200);

      const achievement = await prisma.offChainAchievement.findUnique({
        where: { id: body.achievementId },
      });

      expect(achievement).toBeDefined();
      expect(achievement?.communityMemberEthAddress).toEqual(address);
      expect(achievement?.platform).toEqual(Platform.PROTOCOL);
      expect(achievement?.achievement).toEqual(Achievement.FIRST_LEND);

      const proposal = await prisma.categoryOnChainChangeProposal.findUnique({
        where: { id: body.proposalId },
      });

      const metadata = await prisma.changeProposalMetadata.findUnique({
        where: { id: proposal?.changeProposalMetadataId },
      });

      expect(metadata?.reason).toEqual(firstLendReason);
      expect(proposal).toBeDefined();
      expect(proposal?.category).toEqual("ACTIVITY");
      expect(proposal?.communityMemberEthAddress).toEqual(address);
    });

    it("creates first repayment event achievements", async () => {
      const reqBody: CreateActivityAchievementBody = {
        ethAddress: address,
      };
      const { body } = await supertest(app)
        .post("/achievements/create/activity/repayment_event")
        .set({ authorization: `username:password` })
        .send(reqBody)
        .expect(200);

      const achievement = await prisma.offChainAchievement.findUnique({
        where: { id: body.achievementId },
      });

      expect(achievement).toBeDefined();
      expect(achievement?.communityMemberEthAddress).toEqual(address);
      expect(achievement?.platform).toEqual(Platform.PROTOCOL);
      expect(achievement?.achievement).toEqual(Achievement.FIRST_REPAYMENT);

      const proposal = await prisma.categoryOnChainChangeProposal.findUnique({
        where: { id: body.proposalId },
      });

      const metadata = await prisma.changeProposalMetadata.findUnique({
        where: { id: proposal?.changeProposalMetadataId },
      });

      expect(metadata?.reason).toEqual(firstRepaymentReason);
      expect(proposal).toBeDefined();
      expect(proposal?.category).toEqual("ACTIVITY");
      expect(proposal?.communityMemberEthAddress).toEqual(address);
    });
  });
});
