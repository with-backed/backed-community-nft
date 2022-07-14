import express from "express";
import {
  Achievement,
  ChangeProposalMetadata,
  OffChainAchievement,
  Platform,
  Status,
} from "@prisma/client";
import prisma from "../db";
import { authUser } from "../auth";
import { findOrCreateCommunityMember } from "../communityMembers/crud";
import { firstLendReason, firstRepaymentReason } from "../constants";
import { createInitialMetadata } from "../proposals/crud";

const AchievementsCrudRouter = express.Router();

export type CreateActivityAchievementBody = {
  ethAddress: string;
};

AchievementsCrudRouter.post(
  "/create/activity/:event",
  authUser,
  async (req, res) => {
    const { ethAddress } = req.body as CreateActivityAchievementBody;
    const { event } = req.params as { event: "lend_event" | "repayment_event" };

    if (!ethAddress || !event) {
      return res.status(400);
    }

    const communityMember = await findOrCreateCommunityMember(ethAddress);

    let previousOffchainAchievement: OffChainAchievement | undefined;
    let achievement: Achievement;
    let reason: string;

    if (event === "lend_event") {
      reason = firstLendReason;
      achievement = Achievement.FIRST_LEND;
    } else {
      reason = firstRepaymentReason;
      achievement = Achievement.FIRST_REPAYMENT;
    }

    previousOffchainAchievement = (
      await prisma.offChainAchievement.findMany({
        where: { achievement, communityMemberEthAddress: ethAddress },
      })
    )[0];

    if (!!previousOffchainAchievement) {
      return res.status(200).json({
        message: "User has already receieved XP",
      });
    }

    const newAchievement = await prisma.offChainAchievement.create({
      data: {
        achievement,
        platform: Platform.PROTOCOL,
        communityMemberEthAddress: communityMember.ethAddress,
      },
    });

    const metadata = await createInitialMetadata(reason, Status.APPROVED);
    const proposal = await prisma.categoryOnChainChangeProposal.create({
      data: {
        category: "ACTIVITY",
        value: 1,
        changeProposalMetadataId: metadata.id,
        communityMemberEthAddress: ethAddress,
      },
    });

    return res.status(200).json({
      achievementId: newAchievement.id,
      proposalId: proposal.id,
    });
  }
);

export default AchievementsCrudRouter;
