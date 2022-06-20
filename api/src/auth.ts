import crypto from "crypto";
import { Request, Response, NextFunction } from "express";

export function authUser(req: Request, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({
      message: "Not authenticated",
    });
  }

  const username = authHeader.substring(0, authHeader.indexOf(":"));
  const password = authHeader.substring(username.length + 1);

  if (
    username !== process.env.BASIC_AUTH_USERNAME ||
    password !== process.env.BASIC_AUTH_PASSWORD
  ) {
    return res.status(401).json({
      message: "Not authenticated",
    });
  }

  next();
}

const secret = process.env.GITHUB_WEBHOOK_SECRET!;

const sigHeaderName = "X-Hub-Signature-256";
const sigHashAlg = "sha256";

export function checkFromGithub(
  req: Request,
  res: Response,
  next: NextFunction
) {
  if (process.env.JEST_WORKER_ID !== undefined) {
    return next();
  }

  const rawBody = JSON.stringify(req.body);

  const sig = Buffer.from(req.get(sigHeaderName) || "", "utf8");
  const hmac = crypto.createHmac(sigHashAlg, secret);
  const digest = Buffer.from(
    sigHashAlg + "=" + hmac.update(rawBody).digest("hex"),
    "utf8"
  );
  if (sig.length !== digest.length || !crypto.timingSafeEqual(digest, sig)) {
    return res.status(401).json({
      message: `Request body digest (${digest}) did not match ${sigHeaderName} (${sig})`,
    });
  }

  next();
}
