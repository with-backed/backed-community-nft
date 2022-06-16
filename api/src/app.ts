import express from "express";
import bodyParser from "body-parser";
import ProposalsCrudRouter from "./proposals/crud";
import HandlesCrudRouter from "./handles/crud";
import CronRouter from "./proposals/cron";
import GithubWebhookRouter from "./webhooks/github";

const app = express();
app.use(bodyParser.json());

app.use("/proposals", ProposalsCrudRouter);
app.use("/handles", HandlesCrudRouter);
app.use("/proposals/cron", CronRouter);
app.use("/webhooks/github", GithubWebhookRouter);

export default app;
