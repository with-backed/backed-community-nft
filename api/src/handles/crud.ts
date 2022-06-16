import express from "express";
import { Platform } from "@prisma/client";
import prisma from "../db";

const HandlesCrudRouter = express.Router();

export type CreateHandleBody = {
  ethAddress: string;
  identifier: string;
  platform: Platform;
};

HandlesCrudRouter.post("/create", async (req, res) => {
  const { ethAddress, identifier, platform } = req.body as CreateHandleBody;

  const handle = await prisma.handle.create({
    data: {
      communityMemberEthAddress: ethAddress,
      identifier,
      platform,
    },
  });

  return res.status(200).send({
    handleId: handle.id,
  });
});

export default HandlesCrudRouter;
