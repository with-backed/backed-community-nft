import supertest from "supertest";
import app from "../../../api/src/app";
import prisma from "../../../api/src/db";
import { Wallet } from "ethers";
import { CreateHandleBody } from "../../../api/src/handles/crud";
import { Platform } from "@prisma/client";

const address = Wallet.createRandom().address;

describe("CRUD methods for handles", () => {
  afterEach(async () => {
    await prisma.handle.deleteMany({});
    await prisma.communityMember.deleteMany({});
  });

  describe("/create", () => {
    it("successfully creates a handle associated with a community member", async () => {
      await prisma.communityMember.create({
        data: {
          ethAddress: address,
        },
      });

      let reqBody: CreateHandleBody = {
        ethAddress: address,
        identifier: "adamgobes",
        platform: Platform.GITHUB,
      };

      await supertest(app).post("/handles/create").send(reqBody).expect(200);

      const communityMemberHandles = await prisma.handle.findMany({
        where: { communityMemberEthAddress: address },
      });
      expect(communityMemberHandles.length).toEqual(1);
      expect(communityMemberHandles[0].platform).toEqual("GITHUB");
      expect(communityMemberHandles[0].identifier).toEqual("adamgobes");
    });
  });
});
