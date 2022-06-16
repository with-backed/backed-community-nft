-- CreateEnum
CREATE TYPE "Status" AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'PROCESSING', 'FINALIZED', 'FAULTY');

-- CreateEnum
CREATE TYPE "ChangeType" AS ENUM ('CATEGORY_SCORE', 'ACCESSORY_UNLOCK');

-- CreateTable
CREATE TABLE "OnChainChangeProposal" (
    "id" TEXT NOT NULL,
    "communityMemberEthAddress" TEXT NOT NULL,
    "changeType" "ChangeType" NOT NULL,
    "isAutomaticallyCreated" BOOLEAN NOT NULL DEFAULT false,
    "categoryOrAccessoryId" INTEGER NOT NULL,
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
    "prsMerged" INTEGER NOT NULL DEFAULT 0,
    "communityCallsAttended" INTEGER NOT NULL DEFAULT 0,
    "lastCommunityCallAttended" INTEGER NOT NULL DEFAULT 0,
    "communityCallStreak" INTEGER NOT NULL DEFAULT 0,
    "githubUsername" TEXT,
    "discordUsername" TEXT,

    CONSTRAINT "CommunityMember_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "CommunityMember_ethAddress_key" ON "CommunityMember"("ethAddress");

-- CreateIndex
CREATE UNIQUE INDEX "CommunityMember_githubUsername_key" ON "CommunityMember"("githubUsername");

-- CreateIndex
CREATE UNIQUE INDEX "CommunityMember_discordUsername_key" ON "CommunityMember"("discordUsername");

-- AddForeignKey
ALTER TABLE "OnChainChangeProposal" ADD CONSTRAINT "OnChainChangeProposal_communityMemberEthAddress_fkey" FOREIGN KEY ("communityMemberEthAddress") REFERENCES "CommunityMember"("ethAddress") ON DELETE RESTRICT ON UPDATE CASCADE;
