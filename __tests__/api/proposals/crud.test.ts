import supertest from "supertest";
import app from "../../../api/src/app";
import {
  CreateCategoryProposalBody,
  CreateAccessoryProposalBody,
} from "../../../api/src/proposals/crud";
import prisma from "../../../api/src/db";
import { Wallet } from "ethers";
import { Status } from "@prisma/client";

const address = Wallet.createRandom().address;
const reasonOne = "reason one";
const reasonTwo = "reason two";
const categoryIdOne = "ACTIVITY";
const categoryIdTwo = "CONTRIBUTOR";
const accessoryId = 1;

describe("CRUD methods for proposals", () => {
  afterEach(async () => {
    await prisma.accessoryOnChainChangeProposal.deleteMany({});
    await prisma.categoryOnChainChangeProposal.deleteMany({});
    await prisma.changeProposalMetadata.deleteMany({});
    await prisma.communityMember.deleteMany({});
  });
  describe("/create", () => {
    it("creates proposals", async () => {
      let reqBody: CreateCategoryProposalBody | CreateAccessoryProposalBody = {
        category: categoryIdOne,
        ethAddress: address,
        reason: reasonOne,
        value: 1,
      };
      let { body } = await supertest(app)
        .post("/proposals/create/category")
        .send(reqBody)
        .expect(200);

      const proposalIdOne = body.proposalId;
      expect(proposalIdOne).toBeDefined;

      const categoryProposal =
        await prisma.categoryOnChainChangeProposal.findUnique({
          where: { id: proposalIdOne },
        });

      let proposalMetadata = await prisma.changeProposalMetadata.findUnique({
        where: { id: categoryProposal?.changeProposalMetadataId },
      });

      expect(proposalMetadata!.status).toEqual(Status.PENDING);
      expect(proposalMetadata!.reason).toEqual(reasonOne);
      expect(categoryProposal!.category).toEqual(categoryIdOne);
      expect(categoryProposal!.communityMemberEthAddress).toEqual(address);

      reqBody = {
        ethAddress: address,
        reason: reasonTwo,
        accessoryId: 1,
        unlock: true,
      };

      ({ body } = await supertest(app)
        .post("/proposals/create/accessory")
        .send(reqBody)
        .expect(200));

      const proposalIdTwo = body.proposalId;
      expect(proposalIdTwo).toBeDefined;

      const accessoryProposal =
        await prisma.accessoryOnChainChangeProposal.findUnique({
          where: { id: proposalIdTwo },
        });

      proposalMetadata = await prisma.changeProposalMetadata.findUnique({
        where: { id: accessoryProposal?.changeProposalMetadataId },
      });
      expect(proposalMetadata!.status).toEqual(Status.PENDING);
      expect(proposalMetadata!.reason).toEqual(reasonTwo);
      expect(accessoryProposal!.accessoryId).toEqual(accessoryId);
      expect(accessoryProposal!.communityMemberEthAddress).toEqual(address);

      // ensure CommunityMember entry got created
      const communityMember = await prisma.communityMember.findUnique({
        where: { ethAddress: address },
      });
      expect(communityMember).toBeDefined;
    });
  });

  describe("/proposals/:id/approve", () => {
    let proposalId: string;
    beforeEach(async () => {
      const reqBody: CreateCategoryProposalBody = {
        category: categoryIdOne,
        ethAddress: address,
        reason: reasonOne,
        value: 1,
      };
      let { body } = await supertest(app)
        .post("/proposals/create/category")
        .send(reqBody)
        .expect(200);
      proposalId = body.proposalId;
    });
    it("successfully moves proposal into APPROVED state", async () => {
      const proposal = await prisma.categoryOnChainChangeProposal.findUnique({
        where: { id: proposalId },
      });

      let proposalMetadata = await prisma.changeProposalMetadata.findUnique({
        where: { id: proposal!.changeProposalMetadataId },
      });
      await supertest(app)
        .post(`/proposals/decision/${proposalMetadata!.id}/approve`)
        .set({ authorization: `username:password` })
        .expect(200);

      proposalMetadata = await prisma.changeProposalMetadata.findUnique({
        where: { id: proposal!.changeProposalMetadataId },
      });
      expect(proposalMetadata!.status).toEqual(Status.APPROVED);
    });

    it("returns a 401 if user is not authenticated", (done) => {
      supertest(app)
        .post(`/proposals/decision/${proposalId}/approve`)
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
      const reqBody: CreateCategoryProposalBody = {
        category: categoryIdOne,
        ethAddress: address,
        reason: reasonOne,
        value: 1,
      };
      let { body } = await supertest(app)
        .post("/proposals/create/category")
        .send(reqBody)
        .expect(200);
      proposalId = body.proposalId;
    });
    it("successfully moves proposal into REJECTED state", async () => {
      const proposal = await prisma.categoryOnChainChangeProposal.findUnique({
        where: { id: proposalId },
      });

      let proposalMetadata = await prisma.changeProposalMetadata.findUnique({
        where: { id: proposal!.changeProposalMetadataId },
      });
      await supertest(app)
        .post(`/proposals/decision/${proposalMetadata!.id}/reject`)
        .set({ authorization: `username:password` })
        .expect(200);

      proposalMetadata = await prisma.changeProposalMetadata.findUnique({
        where: { id: proposal!.changeProposalMetadataId },
      });
      expect(proposalMetadata!.status).toEqual(Status.REJECTED);
    });

    it("returns a 401 if user is not authenticated", (done) => {
      supertest(app)
        .post(`/proposals/decision/${proposalId}/reject`)
        .set({ authorization: `username:wrongPassword` })
        .end((err, res) => {
          if (res.status === 401) return done();
          return done(err);
        });
    });
  });
});
