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
  const categoryChanges = await Promise.all(
    changeProposals
      .filter((c) => c.changeType === ChangeType.CATEGORY_SCORE)
      .map(async (change) => ({
        id: await hashIPFSId(change),
        ethAddress: change.communityMemberEthAddress,
        category: change.category,
        reason: change.reason,
        date: dayjs(new Date().getTime()).format("MMMM DD YYYY"),
      }))
  );

  const accessoryChanges = await Promise.all(
    changeProposals
      .filter((c) => c.changeType === ChangeType.ACCESSORY_UNLOCK)
      .map(async (change) => ({
        id: await hashIPFSId(change),
        ethAddress: change.communityMemberEthAddress,
        accessoryId: change.accessoryId,
        reason: change.reason,
        date: dayjs(new Date().getTime()).format("MMMM DD YYYY"),
      }))
  );

  const res = await pinata.pinJSONToIPFS({
    changes: [...categoryChanges, ...accessoryChanges],
  });

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
