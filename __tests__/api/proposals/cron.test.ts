import { Status } from "@prisma/client";
import { Wallet } from "ethers";
import supertest from "supertest";
import app from "../../../api/src/app";
import prisma from "../../../api/src/db";
import {
  getTransactionStatusFromGnosisNonce,
  proposeAccessoryTx,
  proposeCategoryTx,
} from "../../../api/src/gnosis";
import { postJSONToIPFS } from "../../../api/src/ipfs";
import {
  CreateAccessoryProposalBody,
  CreateCategoryProposalBody,
} from "../../../api/src/proposals/crud";

jest.mock("../../../api/src/gnosis", () => ({
  proposeCategoryTx: jest.fn(),
  proposeAccessoryTx: jest.fn(),
  getTransactionStatusFromGnosisNonce: jest.fn(),
}));

jest.mock("../../../api/src/ipfs", () => ({
  postJSONToIPFS: jest.fn(),
}));

const mockedProposeCategoryTxCall = proposeCategoryTx as jest.MockedFunction<
  typeof proposeCategoryTx
>;

const mockedProposeAccessoryTxCall = proposeAccessoryTx as jest.MockedFunction<
  typeof proposeAccessoryTx
>;

const mockedIPFSCall = postJSONToIPFS as jest.MockedFunction<
  typeof postJSONToIPFS
>;
const mockedGetTransactionStatusCall =
  getTransactionStatusFromGnosisNonce as jest.MockedFunction<
    typeof getTransactionStatusFromGnosisNonce
  >;

const nonce = 33;
const ipfsHash = "some-ipfs-hash";

const address = Wallet.createRandom().address;

const proposalOneReqBody: CreateCategoryProposalBody = {
  ethAddress: address,
  category: "ACTIVITY",
  reason: "important reason",
  value: 1,
};

const proposalTwoReqBody: CreateAccessoryProposalBody = {
  ethAddress: address,
  accessoryId: 1,
  reason: "important reason accessory",
  unlock: true,
};

describe("proposals cron", () => {
  let proposalOneId;
  let proposalTwoId;

  beforeAll(async () => {
    await prisma.communityMember.create({
      data: { ethAddress: address },
    });

    let { body } = await supertest(app)
      .post("/proposals/create/category")
      .send(proposalOneReqBody)
      .expect(200);
    proposalOneId = body.proposalId;

    ({ body } = await supertest(app)
      .post("/proposals/create/accessory")
      .send(proposalTwoReqBody)
      .expect(200));
    proposalTwoId = body.proposalId;

    const proposalOne = await prisma.categoryOnChainChangeProposal.findUnique({
      where: { id: proposalOneId },
    });
    const proposalTwo = await prisma.accessoryOnChainChangeProposal.findUnique({
      where: { id: proposalTwoId },
    });
    const metadataOne = await prisma.changeProposalMetadata.findUnique({
      where: { id: proposalOne?.changeProposalMetadataId },
    });
    const metadataTwo = await prisma.changeProposalMetadata.findUnique({
      where: { id: proposalTwo?.changeProposalMetadataId },
    });

    await supertest(app)
      .post(`/proposals/decision/${metadataOne!.id}/approve`)
      .set({ authorization: `username:password` })
      .expect(200);

    await supertest(app)
      .post(`/proposals/decision/${metadataTwo!.id}/approve`)
      .set({ authorization: `username:password` })
      .expect(200);
  });

  afterAll(async () => {
    await prisma.categoryOnChainChangeProposal.deleteMany({});
    await prisma.accessoryOnChainChangeProposal.deleteMany({});
    await prisma.changeProposalMetadata.deleteMany({});
    await prisma.communityMember.deleteMany({});
  });

  describe("/cron/process", () => {
    beforeEach(() => {
      jest.clearAllMocks();
      mockedProposeCategoryTxCall.mockResolvedValue(nonce);
      mockedProposeAccessoryTxCall.mockResolvedValue(nonce + 1);
      mockedIPFSCall.mockResolvedValue({
        IpfsHash: ipfsHash,
        PinSize: 0,
        Timestamp: "0",
      });
    });

    it("successfully processes all proposals and puts them in processing", async () => {
      await supertest(app).post("/proposals/cron/process").expect(200);

      const processingProposals = await prisma.changeProposalMetadata.findMany({
        where: {
          status: Status.PROCESSING,
        },
        orderBy: {
          gnosisSafeNonce: "asc",
        },
      });
      expect(processingProposals.length).toEqual(2);
      expect(processingProposals[0].gnosisSafeNonce).toEqual(nonce);
      expect(processingProposals[0].ipfsURL).toEqual(
        "https://ipfs.io/ipfs/some-ipfs-hash"
      );
      expect(processingProposals[1].gnosisSafeNonce).toEqual(nonce + 1);
      expect(processingProposals[1].ipfsURL).toEqual(
        "https://ipfs.io/ipfs/some-ipfs-hash"
      );
    });
  });

  describe("/cron/finalize", () => {
    beforeEach(() => {
      jest.clearAllMocks();
    });

    it("successfully finalizes proposals", async () => {
      mockedGetTransactionStatusCall.mockResolvedValue([
        "0xf11d2bf8eefdd6f9faad28d1fdf251dc05827aff28f716405b24be5cffb14990",
        true,
      ]);

      await supertest(app).post("/proposals/cron/finalize").expect(200);

      const finalizedProposals = await prisma.changeProposalMetadata.findMany({
        where: {
          status: Status.FINALIZED,
        },
      });
      expect(finalizedProposals.length).toEqual(2);
      expect(finalizedProposals[0].txHash).toEqual(
        "0xf11d2bf8eefdd6f9faad28d1fdf251dc05827aff28f716405b24be5cffb14990"
      );
      expect(finalizedProposals[1].txHash).toEqual(
        "0xf11d2bf8eefdd6f9faad28d1fdf251dc05827aff28f716405b24be5cffb14990"
      );
    });
  });
});
