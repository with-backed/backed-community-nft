import pinataSDK from "@pinata/sdk";
import {
  AccessoryOnChainChangeProposal,
  CategoryOnChainChangeProposal,
} from "@prisma/client";
import { ethers } from "ethers";
import { getCurrentCategoryScoreForUser } from "./helpers";
import prisma from "./db";

const pinata = pinataSDK(
  process.env.PINATA_API_KEY!,
  process.env.PINATA_SECRET_KEY!
);

export async function postJSONToIPFS(
  categoryProposals: CategoryOnChainChangeProposal[],
  accessoryProposals: AccessoryOnChainChangeProposal[]
) {
  const ipfsObj: { [key: string]: object } = {};

  for (const categoryProposal of categoryProposals) {
    const metadata = await prisma.changeProposalMetadata.findUnique({
      where: { id: categoryProposal.changeProposalMetadataId },
    });

    const id = await hashIPFSIdForCategory(categoryProposal);
    ipfsObj[id] = {
      ethAddress: categoryProposal.communityMemberEthAddress,
      category: categoryProposal.category,
      reason: metadata!.reason,
      date: new Date().getTime(),
    };
  }

  for (const accessoryProposal of accessoryProposals) {
    const metadata = await prisma.changeProposalMetadata.findUnique({
      where: { id: accessoryProposal.changeProposalMetadataId },
    });
    const id = await hashIPFSIdForAccessory(accessoryProposal);
    ipfsObj[id] = {
      ethAddress: accessoryProposal.communityMemberEthAddress,
      accessoryId: accessoryProposal.accessoryId,
      reason: metadata!.reason,
      date: new Date().getTime(),
    };
  }

  const res = await pinata.pinJSONToIPFS(ipfsObj);

  return res;
}

export async function hashIPFSIdForCategory(
  proposal: CategoryOnChainChangeProposal
) {
  const currentScore = await getCurrentCategoryScoreForUser(
    proposal.category,
    proposal.communityMemberEthAddress
  );
  return ethers.utils.keccak256(
    ethers.utils.defaultAbiCoder.encode(
      ["address", "string", "uint256", "uint256"],
      [
        proposal.communityMemberEthAddress,
        proposal.category,
        currentScore.add(1),
        currentScore,
      ]
    )
  );
}

export async function hashIPFSIdForAccessory(
  proposal: AccessoryOnChainChangeProposal
) {
  return ethers.utils.keccak256(
    ethers.utils.defaultAbiCoder.encode(
      ["address", "uint256", "bool"],
      [
        proposal.communityMemberEthAddress,
        ethers.BigNumber.from(proposal.accessoryId),
        proposal.unlock,
      ]
    )
  );
}
