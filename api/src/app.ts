import express from "express";
import bodyParser from "body-parser";
import ProposalsCrudRouter from "./proposals/crud";
import HandlesCrudRouter from "./handles/crud";
import CronRouter from "./proposals/cron";

const app = express();
app.use(bodyParser.json());

app.use("/proposals", ProposalsCrudRouter);
app.use("/handles", HandlesCrudRouter);
app.use("/proposals/cron", CronRouter);

export default app;
