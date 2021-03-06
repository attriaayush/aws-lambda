import { Router, Request, Response } from 'express';
import serverless from 'serverless-http';

import app from '../common/express-setup';

const router = Router();

router.get('/healthz', (_: Request, res: Response) => {
  console.log("the health endpoint")
  return res.status(200).send('Hey I am healthy!!!');
});

app.use('/health', router);
module.exports.handler = serverless(app);

