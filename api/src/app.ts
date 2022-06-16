import express from "express";
import bodyParser from "body-parser";
import ProposalsCrudRouter from "./proposals/crud";
import HandlesCrudRouter from "./handles/crud";
import CronRouter from "./proposals/cron";
import GithubWebhookRouter from "./webhooks/github";
import CommunityMemberRouter from "./communityMembers/crud";

const app = express();
app.use(bodyParser.json());

app.use("/proposals", ProposalsCrudRouter);
app.use("/handles", HandlesCrudRouter);
app.use("/communityMembers", CommunityMemberRouter);
app.use("/proposals/cron", CronRouter);
app.use("/webhooks/github", GithubWebhookRouter);

export default app;
