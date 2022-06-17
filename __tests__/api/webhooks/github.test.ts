import { Platform } from "@prisma/client";
import { Wallet } from "ethers";
import supertest from "supertest";
import app from "../../../api/src/app";
import prisma from "../../../api/src/db";
import { getTotalGithubPrsMerged } from "../../../api/src/webhooks/github";

const address = Wallet.createRandom().address;
const identifier = "some_username";

describe("Github webhooks", () => {
  afterEach(async () => {
    await prisma.offChainAchievement.deleteMany({});
    await prisma.handle.deleteMany({});
    await prisma.onChainChangeProposal.deleteMany({});
    await prisma.communityMember.deleteMany({});
  });
  describe("when user has associated their handle with their eth address", () => {
    beforeEach(async () => {
      await prisma.communityMember.create({
        data: { ethAddress: address },
      });

      await prisma.handle.create({
        data: {
          communityMemberEthAddress: address,
          platform: Platform.GITHUB,
          identifier,
        },
      });
    });

    it("succesfully creates an OffChainAchievement when a PR is merged", async () => {
      await supertest(app)
        .post("/webhooks/github/pull_request")
        .send({
          action: "closed",
          pull_request: {
            user: {
              login: identifier,
            },
            merged: true,
          },
        })
        .expect(200);

      expect(await getTotalGithubPrsMerged(address)).toEqual(1);

      const { body } = await supertest(app).get("/proposals").expect(200);
      expect(body.proposals.length).toEqual(1);
      expect(body.proposals[0].communityMemberEthAddress).toEqual(address);
      expect(body.proposals[0].reason).toEqual("Github PR merged");
      expect(body.proposals[0].status).toEqual("APPROVED");
      expect(body.proposals[0].isAutomaticallyCreated).toBeTruthy;
    });

    it("does nothing if webhook is received but PR is not closed (e.g. it was opened)", async () => {
      await supertest(app)
        .post("/webhooks/github/pull_request")
        .send({
          action: "closed",
          pull_request: {
            user: {
              login: identifier,
            },
            merged: false,
          },
        })
        .expect(200);

      expect(await getTotalGithubPrsMerged(address)).toEqual(0);
    });
  });

  describe("when user has not associated their handle with their eth address", () => {
    beforeEach(async () => {
      await prisma.communityMember.create({
        data: { ethAddress: address },
      });
    });

    it("returns 500 when user does not have their handle", (done) => {
      supertest(app)
        .post("/webhooks/github/pull_request")
        .send({
          action: "closed",
          pull_request: {
            user: {
              login: identifier,
            },
            merged: true,
          },
        })
        .end((err, res) => {
          if (
            res.status === 500 &&
            res.body.message ===
              "User has not associated their Github username with their ETH address"
          )
            return done();
          return done(err);
        });
    });
  });
});
