import { CommunityMember } from "@prisma/client";
import express from "express";
import prisma from "../db";

const CommunityMemberRouter = express.Router();

CommunityMemberRouter.post("/create", async (req, res) => {
  const { ethAddress } = req.body as { ethAddress: string };

  try {
    await createCommunityMember(ethAddress);
    res.status(200).send({
      message: `Community member with eth address ${ethAddress} successfully created`,
    });
  } catch (e) {
    res.status(500).send({
      message: "Unable to create community member",
    });
  }
});

export async function createCommunityMember(
  ethAddress: string
): Promise<CommunityMember> {
  return await prisma.communityMember.create({
    data: {
      ethAddress,
    },
  });
}

export default CommunityMemberRouter;
