-- CreateEnum
CREATE TYPE "Status" AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'PROCESSING', 'FINALIZED', 'FAULTY');

-- CreateEnum
CREATE TYPE "ChangeType" AS ENUM ('CATEGORY_SCORE', 'ACCESSORY_UNLOCK');

-- CreateEnum
CREATE TYPE "Platform" AS ENUM ('DISCORD', 'GITHUB');

-- CreateEnum
CREATE TYPE "Achievement" AS ENUM ('PULL_REQUEST', 'COMMUNITY_CALL');

-- CreateTable
CREATE TABLE "OnChainChangeProposal" (
    "id" TEXT NOT NULL,
    "communityMemberEthAddress" TEXT NOT NULL,
    "changeType" "ChangeType" NOT NULL,
    "isAutomaticallyCreated" BOOLEAN NOT NULL DEFAULT false,
    "category" VARCHAR(32) NOT NULL DEFAULT E'',
    "accessoryId" INTEGER NOT NULL DEFAULT 0,
    "reason" TEXT NOT NULL,
    "status" "Status" NOT NULL,
    "gnosisSafeNonce" INTEGER NOT NULL,
    "txHash" VARCHAR(66) NOT NULL,
    "ipfsURL" VARCHAR(100) NOT NULL,

    CONSTRAINT "OnChainChangeProposal_pkey" PRIMARY KEY ("id")
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
CREATE UNIQUE INDEX "CommunityMember_ethAddress_key" ON "CommunityMember"("ethAddress");

-- CreateIndex
CREATE UNIQUE INDEX "Handle_platform_identifier_key" ON "Handle"("platform", "identifier");

-- AddForeignKey
ALTER TABLE "OnChainChangeProposal" ADD CONSTRAINT "OnChainChangeProposal_communityMemberEthAddress_fkey" FOREIGN KEY ("communityMemberEthAddress") REFERENCES "CommunityMember"("ethAddress") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Handle" ADD CONSTRAINT "Handle_communityMemberEthAddress_fkey" FOREIGN KEY ("communityMemberEthAddress") REFERENCES "CommunityMember"("ethAddress") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OffChainAchievement" ADD CONSTRAINT "OffChainAchievement_communityMemberEthAddress_fkey" FOREIGN KEY ("communityMemberEthAddress") REFERENCES "CommunityMember"("ethAddress") ON DELETE RESTRICT ON UPDATE CASCADE;
