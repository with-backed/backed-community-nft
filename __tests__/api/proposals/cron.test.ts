import { ChangeType, Status } from "@prisma/client";
import { Wallet } from "ethers";
import supertest from "supertest";
import app from "../../../api/src/app";
import prisma from "../../../api/src/db";
import {
  getTransactionStatusFromGnosisNonce,
  proposeTx,
} from "../../../api/src/gnosis";
import { postJSONToIPFS } from "../../../api/src/ipfs";

jest.mock("../../../api/src/gnosis", () => ({
  proposeTx: jest.fn(),
  getTransactionStatusFromGnosisNonce: jest.fn(),
}));

jest.mock("../../../api/src/ipfs", () => ({
  postJSONToIPFS: jest.fn(),
}));

const mockedProposeTxCall = proposeTx as jest.MockedFunction<typeof proposeTx>;
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

const proposalOneTraits = {
  communityMemberEthAddress: address,
  categoryOrAccessoryId: 0,
  changeType: ChangeType.CATEGORY_SCORE,
  reason: "important reason",
  status: Status.APPROVED,
  gnosisSafeNonce: 0,
  ipfsURL: "",
  txHash: "",
};

const proposalTwoTraits = {
  communityMemberEthAddress: address,
  categoryOrAccessoryId: 1,
  changeType: ChangeType.ACCESSORY_UNLOCK,
  reason: "important reason accessory",
  status: Status.APPROVED,
  gnosisSafeNonce: 0,
  ipfsURL: "",
  txHash: "",
};

describe("proposals cron", () => {
  beforeAll(async () => {
    await prisma.communityMember.create({
      data: { ethAddress: address },
    });

    await prisma.onChainChangeProposal.create({
      data: {
        ...proposalOneTraits,
      },
    });
    await prisma.onChainChangeProposal.create({
      data: {
        ...proposalTwoTraits,
      },
    });
  });

  afterAll(async () => {
    await prisma.onChainChangeProposal.deleteMany({});
    await prisma.communityMember.deleteMany({});
  });

  describe("/cron/process", () => {
    beforeEach(() => {
      jest.clearAllMocks();
      mockedProposeTxCall.mockResolvedValue(nonce);
      mockedIPFSCall.mockResolvedValue({
        IpfsHash: ipfsHash,
        PinSize: 0,
        Timestamp: "0",
      });
    });

    it("successfully processes all proposals and puts them in processing", async () => {
      await supertest(app).post("/proposals/cron/process").expect(200);

      const processingProposals = await prisma.onChainChangeProposal.findMany({
        where: {
          communityMemberEthAddress: address,
          status: Status.PROCESSING,
        },
      });
      expect(processingProposals.length).toEqual(2);
      expect(processingProposals[0].gnosisSafeNonce).toEqual(nonce);
      expect(processingProposals[0].ipfsURL).toEqual(
        "https://ipfs.io/ipfs/some-ipfs-hash"
      );
      expect(processingProposals[1].gnosisSafeNonce).toEqual(nonce);
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

      const finalizedProposals = await prisma.onChainChangeProposal.findMany({
        where: {
          communityMemberEthAddress: address,
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
