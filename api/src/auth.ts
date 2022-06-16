import { Request, Response, NextFunction } from "express";

export function authUser(req: Request, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization!;

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

export function checkFromGithub(
  req: Request,
  res: Response,
  next: NextFunction
) {
  console.log({ headers: req.headers });
  console.log({ body: req.body });
  next();
}
