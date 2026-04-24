import app from './app';
import { env } from './config/env';

const { PORT, NODE_ENV } = env;

app.listen(PORT, () => {
  console.info(`Server running on port ${PORT} in ${NODE_ENV} mode`);
  console.info(`Health check: http://localhost:${PORT}/api/v1/health`);
});
