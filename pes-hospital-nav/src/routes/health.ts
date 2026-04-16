import { Router, Request, Response } from 'express';

const router = Router();

router.get('/', (_req: Request, res: Response): void => {
  res.status(200).json({
    success: true,
    message: 'PES Hospital Nav API is running',
    timestamp: new Date().toISOString(),
  });
});

export default router;
