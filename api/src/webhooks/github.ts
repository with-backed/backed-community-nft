import { Achievement, ChangeType, Platform, Status } from "@prisma/client";
import express from "express";
import { checkFromGithub } from "../auth";
import { contributorCategoryId, githubMergeReason } from "../constants";
import prisma from "../db";

const GithubWebhookRouter = express.Router();

GithubWebhookRouter.post("/pull_request", checkFromGithub, async (req, res) => {
  const { action, pull_request } = req.body;
  if (action !== "closed") {
    return res.status(200).send({});
  }

  const { user, merged } = pull_request;
  if (!merged) {
    return res.status(200).send({});
  }

  const handle = await prisma.handle.findUnique({
    where: {
      handleIdentifier: { identifier: user.login, platform: Platform.GITHUB },
    },
  });
  if (!handle) {
    return res.status(500).json({
      message:
        "User has not associated their Github username with their ETH address",
    });
  }

  await prisma.offChainAchievement.create({
    data: {
      platform: Platform.GITHUB,
      achievement: Achievement.PULL_REQUEST,
      communityMemberEthAddress: handle.communityMemberEthAddress,
    },
  });

  const totalGithubPrsMerged = await getTotalGithubPrsMerged(
    handle.communityMemberEthAddress
  );

  if (totalGithubPrsMerged === 1 || totalGithubPrsMerged % 5 === 0) {
    await prisma.onChainChangeProposal.create({
      data: {
        categoryOrAccessoryId: contributorCategoryId,
        changeType: ChangeType.CATEGORY_SCORE,
        reason: githubMergeReason,
        status: Status.APPROVED,
        communityMemberEthAddress: handle.communityMemberEthAddress,
        txHash: "",
        gnosisSafeNonce: 0,
        ipfsURL: "",
      },
    });
  }

  return res.status(200).json({
    message: "Webhook successfully received",
  });
});

export async function getTotalGithubPrsMerged(ethAddress: string) {
  return (
    await prisma.offChainAchievement.findMany({
      where: { communityMemberEthAddress: ethAddress },
    })
  ).length;
}

export default GithubWebhookRouter;
