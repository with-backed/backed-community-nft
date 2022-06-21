import pinataSDK from "@pinata/sdk";
import { ChangeType, OnChainChangeProposal } from "@prisma/client";
import dayjs from "dayjs";

const pinata = pinataSDK(
  process.env.PINATA_API_KEY!,
  process.env.PINATA_SECRET_KEY!
);

export async function postJSONToIPFS(changeProposals: OnChainChangeProposal[]) {
  const categoryChanges = changeProposals
    .filter((c) => c.changeType === ChangeType.CATEGORY_SCORE)
    .map((change) => ({
      ethAddress: change.communityMemberEthAddress,
      categoryId: change.categoryOrAccessoryId,
      reason: change.reason,
      date: dayjs(new Date().getTime()).format("MMMM DD YYYY"),
    }));

  const accessoryChanges = changeProposals
    .filter((c) => c.changeType === ChangeType.ACCESSORY_UNLOCK)
    .map((change) => ({
      ethAddress: change.communityMemberEthAddress,
      accessoryId: change.categoryOrAccessoryId,
      reason: change.reason,
      date: dayjs(new Date().getTime()).format("MMMM DD YYYY"),
    }));

  const res = await pinata.pinJSONToIPFS({
    changes: [...categoryChanges, accessoryChanges],
  });

  return res;
}
