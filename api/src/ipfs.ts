import pinataSDK from "@pinata/sdk";
import { ChangeType, OnChainChangeProposal } from "@prisma/client";
import dayjs from "dayjs";
import { ethers } from "ethers";
import { getCurrentCategoryScoreForUser } from "./helpers";
import prisma from "./db";

const pinata = pinataSDK(
  process.env.PINATA_API_KEY!,
  process.env.PINATA_SECRET_KEY!
);

export async function postJSONToIPFS(changeProposals: OnChainChangeProposal[]) {
  const ipfsObj: { [key: string]: object } = {};

  for (const proposal of changeProposals) {
    const id = await hashIPFSId(proposal);
    ipfsObj[id] =
      proposal.changeType === ChangeType.CATEGORY_SCORE
        ? {
            ethAddress: proposal.communityMemberEthAddress,
            category: proposal.category,
            reason: proposal.reason,
            date: new Date().getTime(),
          }
        : {
            ethAddress: proposal.communityMemberEthAddress,
            accessoryId: proposal.accessoryId,
            reason: proposal.reason,
            date: new Date().getTime(),
          };
  }

  const res = await pinata.pinJSONToIPFS(ipfsObj);

  return res;
}

export async function hashIPFSId(
  changeProposal: OnChainChangeProposal
): Promise<string> {
  if (changeProposal.changeType === ChangeType.CATEGORY_SCORE) {
    const currentScore = await getCurrentCategoryScoreForUser(
      changeProposal.category,
      changeProposal.communityMemberEthAddress
    );
    return ethers.utils.keccak256(
      ethers.utils.defaultAbiCoder.encode(
        ["address", "string", "uint256", "uint256"],
        [
          changeProposal.communityMemberEthAddress,
          changeProposal.category,
          currentScore.add(1),
          currentScore,
        ]
      )
    );
  } else {
    return ethers.utils.keccak256(
      ethers.utils.defaultAbiCoder.encode(
        ["address", "uint256", "bool"],
        [
          changeProposal.communityMemberEthAddress,
          ethers.BigNumber.from(changeProposal.accessoryId),
          true,
        ]
      )
    );
  }
}

prisma.onChainChangeProposal
  .findFirst({})
  .then((proposal) => postJSONToIPFS([proposal!]));
