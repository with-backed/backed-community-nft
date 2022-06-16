import pinataSDK from "@pinata/sdk";
import { OnChainChangeProposal } from "@prisma/client";
import dayjs from "dayjs";

const pinata = pinataSDK(
  process.env.PINATA_API_KEY!,
  process.env.PINATA_SECRET_KEY!
);

export async function postJSONToIPFS(changeProposals: OnChainChangeProposal[]) {
  const res = await pinata.pinJSONToIPFS({
    changes: changeProposals.map((proposal) => ({
      ethAddress: proposal.communityMemberEthAddress,
      statistic: proposal.categoryOrAccessoryId,
      reason: proposal.reason,
      date: dayjs(new Date().getTime()).format("MMMM DD YYYY"),
    })),
  });

  return res;
}
