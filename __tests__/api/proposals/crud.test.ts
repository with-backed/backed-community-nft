import supertest from "supertest";
import app from "../../../api/src/app";
import { CreateProposalBody } from "../../../api/src/proposals/crud";
import prisma from "../../../api/src/db";
import { Wallet } from "ethers";
import { ChangeType, Status } from "@prisma/client";

const address = Wallet.createRandom().address;
const reasonOne = "reason one";
const reasonTwo = "reason two";
const categoryIdOne = 0;
const categoryIdTwo = 1;

describe("CRUD methods for proposals", () => {
  afterAll(async () => {
    await prisma.onChainChangeProposal.deleteMany({});
    await prisma.communityMember.deleteMany({});
  });
  describe("/create, /proposals/proposal/:id, /proposals/all", () => {
    it("creates proposals and can fetch successfully", async () => {
      let reqBody: CreateProposalBody = {
        categoryOrAccessoryId: categoryIdOne,
        changeType: ChangeType.CATEGORY_SCORE,
        ethAddress: address,
        reason: reasonOne,
      };
      let { body } = await supertest(app)
        .post("/proposals/create")
        .send(reqBody)
        .expect(200);

      let proposalIdOne = body.proposalId;
      expect(proposalIdOne).toBeDefined;

      ({ body } = await supertest(app)
        .get(`/proposals/${proposalIdOne}`)
        .expect(200));

      expect(body.proposal.status).toEqual(Status.PENDING);
      expect(body.proposal.reason).toEqual(reasonOne);
      expect(body.proposal.categoryOrAccessoryId).toEqual(categoryIdOne);
      expect(body.proposal.communityMemberEthAddress).toEqual(address);

      reqBody = {
        categoryOrAccessoryId: categoryIdTwo,
        changeType: ChangeType.CATEGORY_SCORE,
        ethAddress: address,
        reason: reasonTwo,
      };

      await supertest(app).post("/proposals/create").send(reqBody).expect(200);

      ({ body } = await supertest(app).get(`/proposals`).expect(200));

      expect(body.proposals.length).toEqual(2);
    });
  });

  describe("/proposals/:id/approve", () => {
    let proposalId: string;
    beforeEach(async () => {
      const reqBody: CreateProposalBody = {
        categoryOrAccessoryId: categoryIdOne,
        changeType: ChangeType.CATEGORY_SCORE,
        ethAddress: address,
        reason: reasonOne,
      };
      let { body } = await supertest(app)
        .post("/proposals/create")
        .send(reqBody)
        .expect(200);
      proposalId = body.proposalId;
    });
    it("successfully moves proposal into APPROVED state", async () => {
      await supertest(app)
        .post(`/proposals/${proposalId}/approve`)
        .set({ authorization: `username:password` })
        .expect(200);

      const { body } = await supertest(app)
        .get(`/proposals/${proposalId}`)
        .expect(200);
      expect(body.proposal.status).toEqual(Status.APPROVED);
    });

    it("returns a 401 if user is not authenticated", (done) => {
      supertest(app)
        .post(`/proposals/${proposalId}/approve`)
        .set({ authorization: `username:wrongPassword` })
        .end((err, res) => {
          if (res.status === 401) return done();
          return done(err);
        });
    });
  });

  describe("/proposals/:id/reject", () => {
    let proposalId: string;
    beforeEach(async () => {
      const reqBody: CreateProposalBody = {
        categoryOrAccessoryId: categoryIdOne,
        changeType: ChangeType.CATEGORY_SCORE,
        ethAddress: address,
        reason: reasonOne,
      };
      let { body } = await supertest(app)
        .post("/proposals/create")
        .send(reqBody)
        .expect(200);
      proposalId = body.proposalId;
    });
    it("successfully moves proposal into REJECTED state", async () => {
      await supertest(app)
        .post(`/proposals/${proposalId}/reject`)
        .set({ authorization: `username:password` })
        .expect(200);

      const { body } = await supertest(app)
        .get(`/proposals/${proposalId}`)
        .expect(200);
      expect(body.proposal.status).toEqual(Status.REJECTED);
    });

    it("returns a 401 if user is not authenticated", (done) => {
      supertest(app)
        .post(`/proposals/${proposalId}/reject`)
        .set({ authorization: `username:wrongPassword` })
        .end((err, res) => {
          if (res.status === 401) return done();
          return done(err);
        });
    });
  });
});
