import { Status } from "@prisma/client";
import express from "express";
import prisma from "../db";
import { getTransactionStatusFromGnosisNonce, proposeTx } from "../gnosis";
import { postJSONToIPFS } from "../ipfs";

const CronRouter = express.Router();

CronRouter.post("/process", async (_req, res) => {
  let approvedProposals = await prisma.onChainChangeProposal.findMany({
    where: { status: "APPROVED" },
    take: 20,
  });

  if (approvedProposals.length === 0) return res.json({ success: true });

  const pinataResponse = await postJSONToIPFS(approvedProposals);

  await Promise.all(
    approvedProposals.map((proposal) => {
      return prisma.onChainChangeProposal.update({
        where: { id: proposal.id },
        data: {
          ipfsURL: `https://ipfs.io/ipfs/${pinataResponse.IpfsHash}`,
        },
      });
    })
  );

  // refresh proposals now that they have ipfsURL field populated
  approvedProposals = await prisma.onChainChangeProposal.findMany({
    where: { id: { in: approvedProposals.map((p) => p.id) } },
  });

  const nonce = await proposeTx(approvedProposals);

  await Promise.all(
    approvedProposals.map((proposal) => {
      return prisma.onChainChangeProposal.update({
        where: { id: proposal.id },
        data: {
          gnosisSafeNonce: nonce,
          status: Status.PROCESSING,
        },
      });
    })
  );

  return res.json({ success: true });
});

CronRouter.post("/finalize", async (_req, res) => {
  const processingProposals = await prisma.onChainChangeProposal.findMany({
    where: { status: "PROCESSING" },
  });

  if (processingProposals.length === 0) return res.json({ success: true });

  processingProposals.forEach(async (proposal) => {
    const [txHash, confirmed] = await getTransactionStatusFromGnosisNonce(
      proposal.gnosisSafeNonce
    );
    if (confirmed) {
      await prisma.onChainChangeProposal.update({
        where: { id: proposal.id },
        data: {
          status: Status.FINALIZED,
          txHash,
        },
      });
    } else {
      await prisma.onChainChangeProposal.update({
        where: { id: proposal.id },
        data: {
          status: Status.APPROVED,
        },
      });
    }
  });

  return res.json({
    success: true,
  });
});

export default CronRouter;
