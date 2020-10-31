import { Router, Request, Response } from 'express';
import serverless from 'serverless-http';

import app from '../common/express-setup';

const router = Router();

router.get('/', (_: Request, res: Response) => {
  return res.status(200).send('OK');
});

app.use('/api/healthz', router);
module.exports.handler = serverless(app);

