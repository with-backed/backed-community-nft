-- CreateEnum
CREATE TYPE "Status" AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'PROCESSING', 'FINALIZED', 'FAULTY');

-- CreateEnum
CREATE TYPE "Platform" AS ENUM ('DISCORD', 'GITHUB');

-- CreateEnum
CREATE TYPE "Achievement" AS ENUM ('PULL_REQUEST', 'COMMUNITY_CALL');

-- CreateTable
CREATE TABLE "ChangeProposalMetadata" (
    "id" TEXT NOT NULL,
    "reason" TEXT NOT NULL,
    "status" "Status" NOT NULL,
    "gnosisSafeNonce" INTEGER NOT NULL,
    "txHash" VARCHAR(66) NOT NULL,
    "ipfsURL" VARCHAR(100) NOT NULL,
    "isAutomaticallyCreated" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "ChangeProposalMetadata_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CategoryOnChainChangeProposal" (
    "id" TEXT NOT NULL,
    "communityMemberEthAddress" TEXT NOT NULL,
    "category" VARCHAR(32) NOT NULL,
    "value" INTEGER NOT NULL,
    "changeProposalMetadataId" TEXT NOT NULL,

    CONSTRAINT "CategoryOnChainChangeProposal_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AccessoryOnChainChangeProposal" (
    "id" TEXT NOT NULL,
    "communityMemberEthAddress" TEXT NOT NULL,
    "accessoryId" INTEGER NOT NULL,
    "unlock" BOOLEAN NOT NULL,
    "changeProposalMetadataId" TEXT NOT NULL,

    CONSTRAINT "AccessoryOnChainChangeProposal_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CommunityMember" (
    "id" TEXT NOT NULL,
    "ethAddress" TEXT NOT NULL,

    CONSTRAINT "CommunityMember_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Handle" (
    "id" TEXT NOT NULL,
    "communityMemberEthAddress" TEXT NOT NULL,
    "platform" "Platform" NOT NULL,
    "identifier" TEXT NOT NULL,

    CONSTRAINT "Handle_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "OffChainAchievement" (
    "id" TEXT NOT NULL,
    "communityMemberEthAddress" TEXT NOT NULL,
    "platform" "Platform" NOT NULL,
    "achievement" "Achievement" NOT NULL,
    "timestamp" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "OffChainAchievement_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "CategoryOnChainChangeProposal_changeProposalMetadataId_key" ON "CategoryOnChainChangeProposal"("changeProposalMetadataId");

-- CreateIndex
CREATE UNIQUE INDEX "AccessoryOnChainChangeProposal_changeProposalMetadataId_key" ON "AccessoryOnChainChangeProposal"("changeProposalMetadataId");

-- CreateIndex
CREATE UNIQUE INDEX "CommunityMember_ethAddress_key" ON "CommunityMember"("ethAddress");

-- CreateIndex
CREATE UNIQUE INDEX "Handle_platform_identifier_key" ON "Handle"("platform", "identifier");

-- AddForeignKey
ALTER TABLE "CategoryOnChainChangeProposal" ADD CONSTRAINT "CategoryOnChainChangeProposal_changeProposalMetadataId_fkey" FOREIGN KEY ("changeProposalMetadataId") REFERENCES "ChangeProposalMetadata"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CategoryOnChainChangeProposal" ADD CONSTRAINT "CategoryOnChainChangeProposal_communityMemberEthAddress_fkey" FOREIGN KEY ("communityMemberEthAddress") REFERENCES "CommunityMember"("ethAddress") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AccessoryOnChainChangeProposal" ADD CONSTRAINT "AccessoryOnChainChangeProposal_changeProposalMetadataId_fkey" FOREIGN KEY ("changeProposalMetadataId") REFERENCES "ChangeProposalMetadata"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AccessoryOnChainChangeProposal" ADD CONSTRAINT "AccessoryOnChainChangeProposal_communityMemberEthAddress_fkey" FOREIGN KEY ("communityMemberEthAddress") REFERENCES "CommunityMember"("ethAddress") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Handle" ADD CONSTRAINT "Handle_communityMemberEthAddress_fkey" FOREIGN KEY ("communityMemberEthAddress") REFERENCES "CommunityMember"("ethAddress") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OffChainAchievement" ADD CONSTRAINT "OffChainAchievement_communityMemberEthAddress_fkey" FOREIGN KEY ("communityMemberEthAddress") REFERENCES "CommunityMember"("ethAddress") ON DELETE RESTRICT ON UPDATE CASCADE;
