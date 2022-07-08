import { ChangeType, OnChainChangeProposal, Status } from "@prisma/client";
import fs from "fs";
import path from "path";
import { findOrCreateCommunityMember } from "../src/communityMembers/crud";
import prisma from "../src/db";

const DESIGN_TOKEN_KEY = "Design Community";
const CODE_TOKEN_KEY = "Code Contributor";

async function run() {
  const json = JSON.parse(
    fs
      .readFileSync(path.join(__dirname, "initialTransitionData.json"))
      .toString()
  );

  for (const address in json) {
    const communityMember = await findOrCreateCommunityMember(address);

    const keys = Object.keys(json[address]);
    const partialProposalsForAddress = xpChangeProposalSubsetsFromTokens(
      keys.length,
      keys.includes(CODE_TOKEN_KEY),
      keys.includes(DESIGN_TOKEN_KEY)
    );
    await Promise.all(
      partialProposalsForAddress.map((partialProposal) =>
        prisma.onChainChangeProposal.create({
          data: {
            ...partialProposal,
            communityMemberEthAddress: communityMember.ethAddress,
            isAutomaticallyCreated: true,
            status: Status.APPROVED,
            reason: "Initial transition script",
            txHash: "",
            gnosisSafeNonce: 0,
            ipfsURL: "",
          },
        })
      )
    );
  }
}

type PartialOnChainChangeProposal = {
  changeType: ChangeType;
  accessoryId?: number;
  category?: string;
};

function xpChangeProposalSubsetsFromTokens(
  numberOfTokens: number,
  hasCodeContributor: boolean,
  hasDesign: boolean
): PartialOnChainChangeProposal[] {
  let proposals: PartialOnChainChangeProposal[] = [
    {
      changeType: ChangeType.ACCESSORY_UNLOCK,
      accessoryId: 9, // alpha snake accessory id
    },
    ...Array.apply(null, Array(numberOfTokens)) // one set of XP per category per token that they have
      .map(() => {})
      .map((_i) => [
        {
          changeType: ChangeType.CATEGORY_SCORE,
          category: "ACTIVITY",
        },
        {
          changeType: ChangeType.CATEGORY_SCORE,
          category: "CONTRIBUTOR",
        },
        {
          changeType: ChangeType.CATEGORY_SCORE,
          category: "COMMUNITY",
        },
      ])
      .flat(),
  ];

  if (hasCodeContributor) {
    proposals = [
      ...proposals,
      {
        changeType: ChangeType.CATEGORY_SCORE,
        category: "CONTRIBUTOR",
      },
    ];
  }
  if (hasDesign) {
    proposals = [
      ...proposals,
      {
        changeType: ChangeType.CATEGORY_SCORE,
        category: "CONTRIBUTOR",
      },
    ];
  }

  return proposals;
}

run().then((res) => console.log(res));
