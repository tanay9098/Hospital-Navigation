require('dotenv').config();
const app = require('./app');
const connectDB = require('./configs/database');

const PORT = process.env.PORT || 5000;

const startServer = async () => {
  await connectDB();

  app.listen(PORT, () => {
    console.log(`\n==============================================`);
    console.log(` PES Hospital Navigation System`);
    console.log(`==============================================`);
    console.log(` Server running on port ${PORT}`);
    console.log(` Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log(` API Base: http://localhost:${PORT}/api/v1`);
    console.log(`----------------------------------------------`);
    console.log(` REST API  → http://localhost:${PORT}/api/v1`);
    console.log(` IVR Hook  → http://localhost:${PORT}/api/v1/ivr/webhook`);
    console.log(` Health    → http://localhost:${PORT}/api/v1/health`);
    console.log(`==============================================\n`);
  });
};

startServer().catch((err) => {
  console.error('Failed to start server:', err);
  process.exit(1);
});
