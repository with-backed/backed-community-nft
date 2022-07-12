import { Status } from "@prisma/client";
import fs from "fs";
import path from "path";
import { findOrCreateCommunityMember } from "../src/communityMembers/crud";
import {
  activityCategoryId,
  communityCategoryId,
  contributorCategoryId,
} from "../src/constants";
import prisma from "../src/db";

const DESIGN_TOKEN_KEY = "Design Community";
const CODE_TOKEN_KEY = "Code Contributor";

const START = 110;
const LIMIT = 120;

async function run() {
  const json = JSON.parse(
    fs
      .readFileSync(path.join(__dirname, "initialTransitionData.json"))
      .toString()
  );
  const addresses = JSON.parse(
    fs.readFileSync(path.join(__dirname, "addresses.json")).toString()
  )["addresses"];

  for (let i = START; i < LIMIT && i < addresses.length; i++) {
    const address = addresses[i];
    const communityMember = await findOrCreateCommunityMember(address);

    const keys = Object.keys(json[address]);
    const codeContributorTokens = keys.includes(CODE_TOKEN_KEY) ? 1 : 0;
    const designContributorTokens = keys.includes(DESIGN_TOKEN_KEY) ? 1 : 0;

    // create alpha snake proposal
    const accessoryMetadata = await prisma.changeProposalMetadata.create({
      data: {
        ...baseMetadata(),
      },
    });
    await prisma.accessoryOnChainChangeProposal.create({
      data: {
        accessoryId: 9,
        unlock: true,
        communityMemberEthAddress: communityMember.ethAddress,
        changeProposalMetadataId: accessoryMetadata.id,
      },
    });

    // create category proposals
    const activityMetadata = await prisma.changeProposalMetadata.create({
      data: {
        ...baseMetadata(),
      },
    });
    const contributorMetadata = await prisma.changeProposalMetadata.create({
      data: {
        ...baseMetadata(),
      },
    });
    const communityMetadata = await prisma.changeProposalMetadata.create({
      data: {
        ...baseMetadata(),
      },
    });

    await Promise.all([
      await prisma.categoryOnChainChangeProposal.create({
        data: {
          category: activityCategoryId,
          value: keys.length,
          communityMemberEthAddress: communityMember.ethAddress,
          changeProposalMetadataId: activityMetadata.id,
        },
      }),
      await prisma.categoryOnChainChangeProposal.create({
        data: {
          category: contributorCategoryId,
          value: keys.length + designContributorTokens + codeContributorTokens,
          communityMemberEthAddress: communityMember.ethAddress,
          changeProposalMetadataId: contributorMetadata.id,
        },
      }),
      await prisma.categoryOnChainChangeProposal.create({
        data: {
          category: communityCategoryId,
          value: keys.length,
          communityMemberEthAddress: communityMember.ethAddress,
          changeProposalMetadataId: communityMetadata.id,
        },
      }),
    ]);
  }
}

const baseMetadata = () => ({
  isAutomaticallyCreated: true,
  status: Status.APPROVED,
  reason: "Initial transition script",
  txHash: "",
  gnosisSafeNonce: 0,
  ipfsURL: "",
});

run().then((res) => console.log(res));
