import { Status } from "@prisma/client";
import express from "express";
import prisma from "../db";
import {
  getTransactionStatusFromGnosisNonce,
  proposeCategoryTx,
  proposeAccessoryTx,
} from "../gnosis";
import { postJSONToIPFS } from "../ipfs";

const CronRouter = express.Router();

CronRouter.post("/process", async (_req, res) => {
  let approvedProposalsMetadata = await prisma.changeProposalMetadata.findMany({
    where: { status: "APPROVED" },
    take: 20,
  });

  if (approvedProposalsMetadata.length === 0)
    return res.json({ success: true });

  const approvedCategoryProposals =
    await prisma.categoryOnChainChangeProposal.findMany({
      where: {
        changeProposalMetadataId: {
          in: approvedProposalsMetadata.map((m) => m.id),
        },
      },
    });

  const approvedAccessoryProposals =
    await prisma.accessoryOnChainChangeProposal.findMany({
      where: {
        changeProposalMetadataId: {
          in: approvedProposalsMetadata.map((m) => m.id),
        },
      },
    });

  const pinataResponse = await postJSONToIPFS(
    approvedCategoryProposals,
    approvedAccessoryProposals
  );

  const ipfsURL = `https://ipfs.io/ipfs/${pinataResponse.IpfsHash}`;
  await Promise.all(
    approvedProposalsMetadata.map((metadata) => {
      return prisma.changeProposalMetadata.update({
        where: { id: metadata.id },
        data: {
          ipfsURL,
        },
      });
    })
  );

  const categoryNonce = await proposeCategoryTx(
    approvedCategoryProposals,
    ipfsURL
  );
  const accessoryNonce = await proposeAccessoryTx(
    approvedAccessoryProposals,
    ipfsURL
  );

  await Promise.all([
    ...approvedCategoryProposals.map((proposal) => {
      return prisma.changeProposalMetadata.update({
        where: { id: proposal.changeProposalMetadataId },
        data: {
          gnosisSafeNonce: categoryNonce,
          status: Status.PROCESSING,
        },
      });
    }),
    ...approvedAccessoryProposals.map((proposal) => {
      return prisma.changeProposalMetadata.update({
        where: { id: proposal.changeProposalMetadataId },
        data: {
          gnosisSafeNonce: accessoryNonce,
          status: Status.PROCESSING,
        },
      });
    }),
  ]);

  return res.json({ success: true });
});

CronRouter.post("/finalize", async (_req, res) => {
  const processingProposalsMetadata =
    await prisma.changeProposalMetadata.findMany({
      where: { status: "PROCESSING" },
      distinct: "gnosisSafeNonce",
      take: 20,
    });

  if (processingProposalsMetadata.length === 0)
    return res.json({ success: true });

  processingProposalsMetadata.forEach(async (metadata) => {
    const [txHash, confirmed] = await getTransactionStatusFromGnosisNonce(
      metadata.gnosisSafeNonce
    );
    if (confirmed) {
      await prisma.changeProposalMetadata.updateMany({
        where: { gnosisSafeNonce: metadata.gnosisSafeNonce },
        data: {
          status: Status.FINALIZED,
          txHash,
        },
      });
    }
  });

  return res.json({
    success: true,
  });
});

export default CronRouter;
