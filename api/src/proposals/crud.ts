import express from "express";
import { ChangeType, CommunityMember, Status } from "@prisma/client";
import prisma from "../db";
import { authUser } from "../auth";
import { createCommunityMember } from "../communityMembers/crud";

const ProposalsCrudRouter = express.Router();

export type CreateProposalBody = {
  ethAddress: string;
  changeType: ChangeType;
  categoryOrAccessoryId: number;
  reason: string;
};

type DecisionProposalBody = {
  id: string;
};

ProposalsCrudRouter.post("/create", async (req, res) => {
  const { ethAddress, changeType, categoryOrAccessoryId, reason } =
    req.body as CreateProposalBody;

  if (!ethAddress || !reason || !changeType) {
    return res.status(400);
  }

  let communityMember: CommunityMember | null;

  communityMember = await prisma.communityMember.findUnique({
    where: { ethAddress },
  });

  if (!communityMember)
    communityMember = await createCommunityMember(ethAddress);

  const proposal = await prisma.onChainChangeProposal.create({
    data: {
      status: Status.PENDING,
      communityMemberEthAddress: ethAddress,
      changeType,
      categoryOrAccessoryId,
      reason,
      txHash: "",
      gnosisSafeNonce: 0,
      ipfsURL: "",
    },
  });

  return res.json({
    proposalId: proposal.id,
  });
});

//TODO(adamgobes): add auth middleware for this endpoint
ProposalsCrudRouter.post("/:id/approve", authUser, async (req, res) => {
  const { id } = req.params as DecisionProposalBody;

  const proposal = await prisma.onChainChangeProposal.findUnique({
    where: { id },
  });

  if (proposal?.status !== Status.PENDING) {
    return res.status(400).json({
      message: "Proposal is not in PENDING state",
    });
  }

  await prisma.onChainChangeProposal.update({
    where: { id },
    data: {
      status: Status.APPROVED,
    },
  });

  return res.json({
    success: true,
  });
});

//TODO(adamgobes): add auth middleware for this endpoint
ProposalsCrudRouter.post("/:id/reject", authUser, async (req, res) => {
  const { id } = req.params as DecisionProposalBody;

  const proposal = await prisma.onChainChangeProposal.findUnique({
    where: { id },
  });

  if (proposal?.status !== Status.PENDING) {
    return res.status(400).json({
      message: "Proposal is not in PENDING state",
    });
  }

  await prisma.onChainChangeProposal.update({
    where: { id },
    data: {
      status: Status.REJECTED,
    },
  });

  return res.json({
    success: true,
  });
});

ProposalsCrudRouter.get("/:id", async (req, res) => {
  const { id } = req.params as DecisionProposalBody;

  return res.json({
    proposal: await prisma.onChainChangeProposal.findUnique({
      where: { id },
    }),
  });
});

ProposalsCrudRouter.get("/", async (_req, res) => {
  return res.json({
    proposals: await prisma.onChainChangeProposal.findMany(),
  });
});

export default ProposalsCrudRouter;
