import { Router, Request, Response } from 'express';
import serverless from 'serverless-http';

import app from '../common/express-setup';

const router = Router();

router.get('/hello-world', (_: Request, res: Response) => {
  console.log("is this being hit")
  return res.status(200).send('Hello World!');
});

app.use('/api', router);
module.exports.handler = serverless(app);
