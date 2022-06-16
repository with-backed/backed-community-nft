import { Request, Response, NextFunction } from "express";

export function authUser(req: Request, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization!;

  const username = authHeader.substring(0, authHeader.indexOf(":"));
  const password = authHeader.substring(username.length + 1);

  if (
    username !== process.env.BASIC_AUTH_USERNAME ||
    password !== process.env.BASIC_AUTH_PASSWORD
  ) {
    return res.status(401).send({
      message: "Not authenticated",
    });
  }

  next();
}
