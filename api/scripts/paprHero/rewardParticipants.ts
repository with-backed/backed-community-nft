import path from "path";
import fs from "fs";
import { ChangeProposalMetadata, Status } from "@prisma/client";
import { activityCategoryId, communityCategoryId } from "../../src/constants";
import prisma from "../../src/db";

async function run(perform: boolean = true) {
  const addresses: string[] = JSON.parse(
    fs.readFileSync(path.join(__dirname, "results.json")).toString()
  ).map((entry: any) => entry.address);
  let metadata: ChangeProposalMetadata;
  if (perform) {
    metadata = await prisma.changeProposalMetadata.create({
      data: {
        isAutomaticallyCreated: true,
        status: Status.APPROVED,
        reason: "Participation in Papr Hero",
        txHash: "",
        gnosisSafeNonce: 0,
        ipfsURL: "",
      },
    });
  }
  for (let i = 0; i < addresses.length; i++) {
    const address = addresses[i];
    if (perform) {
      await prisma.categoryOnChainChangeProposal.create({
        data: {
          category: activityCategoryId,
          value: 1,
          communityMemberEthAddress: address,
          changeProposalMetadataId: metadata!.id,
        },
      });
    } else {
      console.log(`assigning ${address} 1 activity XP`);
    }
    if (perform) {
      await prisma.categoryOnChainChangeProposal.create({
        data: {
          category: communityCategoryId,
          value: 1,
          communityMemberEthAddress: address,
          changeProposalMetadataId: metadata!.id,
        },
      });
    } else {
      console.log(`assigning ${address} 1 community XP`);
    }
  }
}

run(false);
