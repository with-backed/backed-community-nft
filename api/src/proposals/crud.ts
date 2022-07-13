import express from "express";
import {
  AccessoryOnChainChangeProposal,
  CategoryOnChainChangeProposal,
  ChangeProposalMetadata,
  CommunityMember,
  Status,
} from "@prisma/client";
import prisma from "../db";
import { authUser } from "../auth";
import { createCommunityMember } from "../communityMembers/crud";

const ProposalsCrudRouter = express.Router();

export type CreateCategoryProposalBody = {
  ethAddress: string;
  category: string;
  reason: string;
  value: number;
};

ProposalsCrudRouter.post("/create/category", async (req, res) => {
  const { ethAddress, category, reason, value } =
    req.body as CreateCategoryProposalBody;

  if (!ethAddress || !reason || !category) {
    return res.status(400);
  }

  let communityMember: CommunityMember | null;

  communityMember = await prisma.communityMember.findUnique({
    where: { ethAddress },
  });

  if (!communityMember)
    communityMember = await createCommunityMember(ethAddress);

  const proposalMetadata = await createInitialMetadata(reason);

  const proposal = await prisma.categoryOnChainChangeProposal.create({
    data: {
      category,
      value,
      communityMemberEthAddress: ethAddress,
      changeProposalMetadataId: proposalMetadata.id,
    },
  });

  return res.status(200).json({
    proposalId: proposal.id,
  });
});

export type CreateAccessoryProposalBody = {
  ethAddress: string;
  accessoryId: number;
  reason: string;
  unlock: boolean;
};

ProposalsCrudRouter.post("/create/accessory", async (req, res) => {
  const { ethAddress, accessoryId, reason, unlock } =
    req.body as CreateAccessoryProposalBody;

  if (!ethAddress || !reason || !accessoryId) {
    return res.status(400);
  }

  let communityMember: CommunityMember | null;

  communityMember = await prisma.communityMember.findUnique({
    where: { ethAddress },
  });

  if (!communityMember)
    communityMember = await createCommunityMember(ethAddress);

  const proposalMetadata = await createInitialMetadata(reason);

  const proposal = await prisma.accessoryOnChainChangeProposal.create({
    data: {
      accessoryId,
      unlock,
      communityMemberEthAddress: ethAddress,
      changeProposalMetadataId: proposalMetadata.id,
    },
  });

  return res.status(200).json({
    proposalId: proposal.id,
  });
});

ProposalsCrudRouter.post(
  "/decision/:metadata_id/:status",
  authUser,
  async (req, res) => {
    const { metadata_id, status } = req.params as {
      metadata_id: string;
      status: "approve" | "reject";
    };

    const proposalMetadata = await prisma.changeProposalMetadata.findUnique({
      where: { id: metadata_id },
    });

    if (!proposalMetadata) {
      return res.status(400);
    }

    if (proposalMetadata.status !== Status.PENDING) {
      return res.status(400).json({
        message: "Proposal is not in PENDING state",
      });
    }

    await prisma.changeProposalMetadata.update({
      where: { id: metadata_id },
      data: {
        status: status === "approve" ? Status.APPROVED : Status.REJECTED,
      },
    });

    return res.json({
      success: true,
    });
  }
);

async function findProposalFromMetadata(
  metadata: ChangeProposalMetadata
): Promise<
  | CategoryOnChainChangeProposal
  | AccessoryOnChainChangeProposal
  | null
  | undefined
> {
  const maybeProposals = [
    await prisma.categoryOnChainChangeProposal.findUnique({
      where: { changeProposalMetadataId: metadata.id },
    }),
    await prisma.accessoryOnChainChangeProposal.findUnique({
      where: { changeProposalMetadataId: metadata.id },
    }),
  ];

  return maybeProposals.find((p) => p !== null);
}

export async function createInitialMetadata(
  reason: string,
  status: Status = Status.PENDING
): Promise<ChangeProposalMetadata> {
  const proposalMetadata = await prisma.changeProposalMetadata.create({
    data: {
      reason,
      status,
      gnosisSafeNonce: 0,
      txHash: "",
      ipfsURL: "",
    },
  });
  return proposalMetadata;
}

export default ProposalsCrudRouter;
