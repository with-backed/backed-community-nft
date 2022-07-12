import { Platform } from "@prisma/client";
import { Octokit } from "octokit";
import prisma from "../../src/db";

const octokit = new Octokit({});

const usernames = [
  "wilsoncusack",
  "cnasc",
  "adamgobes",
  "0xMetas",
  "jringenberg",
];

const REPO = "backed-community-nft";

async function generateOffChainAchievements() {
  let PAGE = 1;

  let response = await octokit.request(
    `GET /repos/{owner}/{repo}/pulls?state=closed&page=${PAGE}`,
    {
      owner: "with-backed",
      repo: REPO,
    }
  );

  while (response.data.length > 0) {
    for (let i = 0; i < response.data.length; i++) {
      const username = response.data[i].user.login;

      if (!usernames.includes(username)) continue;

      const handle = await prisma.handle.findUnique({
        where: {
          handleIdentifier: { platform: Platform.GITHUB, identifier: username },
        },
      });
      if (!handle) continue;

      await prisma.offChainAchievement.create({
        data: {
          achievement: "PULL_REQUEST",
          platform: "GITHUB",
          communityMemberEthAddress: handle.communityMemberEthAddress,
        },
      });

      console.log({ page: PAGE, username, count: i + 1 });
    }
    response = await octokit.request(
      `GET /repos/{owner}/{repo}/pulls?state=closed&page=${++PAGE}`,
      {
        owner: "with-backed",
        repo: REPO,
      }
    );
  }
}

async function createOnChainProposalsFromAchievements() {
  for (let i = 0; i < usernames.length; i++) {
    const username = usernames[i];
    const handle = await prisma.handle.findUnique({
      where: {
        handleIdentifier: { platform: "GITHUB", identifier: username },
      },
    });
    if (!handle) continue;

    const achievements = await prisma.offChainAchievement.findMany({
      where: {
        communityMemberEthAddress: handle?.communityMemberEthAddress,
        achievement: "PULL_REQUEST",
      },
    });
    console.log({
      username,
      prsMerged: achievements.length,
      xpEarned: Math.floor(Math.log2(achievements.length)) + 1,
    });
  }
}

generateOffChainAchievements();
