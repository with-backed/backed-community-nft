import { Achievement, Platform, Status } from "@prisma/client";
import express from "express";
import { checkFromGithub } from "../auth";
import { contributorCategoryId, githubMergeReason } from "../constants";
import prisma from "../db";

const GithubWebhookRouter = express.Router();

GithubWebhookRouter.post("/pull_request", checkFromGithub, async (req, res) => {
  const { action, pull_request } = req.body;
  if (action !== "closed") {
    return res.status(200).json({});
  }

  const { user, merged } = pull_request;
  if (!merged) {
    return res.status(200).json({});
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

  const metadata = await prisma.changeProposalMetadata.create({
    data: {
      reason: githubMergeReason,
      status: Status.APPROVED,
      isAutomaticallyCreated: true,
      txHash: "",
      gnosisSafeNonce: 0,
      ipfsURL: "",
    },
  });

  const changeProposal = await prisma.categoryOnChainChangeProposal.create({
    data: {
      category: contributorCategoryId,
      communityMemberEthAddress: handle.communityMemberEthAddress,
      changeProposalMetadataId: metadata.id,
      value: 1,
    },
  });

  return res.status(200).json({
    message: "Webhook successfully received",
  });
});

export async function getTotalGithubPrsMerged(ethAddress: string) {
  return (
    await prisma.offChainAchievement.findMany({
      where: {
        communityMemberEthAddress: ethAddress,
        achievement: Achievement.PULL_REQUEST,
        platform: Platform.GITHUB,
      },
    })
  ).length;
}

export default GithubWebhookRouter;
