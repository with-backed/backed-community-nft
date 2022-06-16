import express from "express";
import bodyParser from "body-parser";
import CrudRouter from "./proposals/crud";
import CronRouter from "./proposals/cron";

const app = express();
app.use(bodyParser.json());

app.use("/proposals", CrudRouter);
app.use("/proposals/cron", CronRouter);

export default app;
