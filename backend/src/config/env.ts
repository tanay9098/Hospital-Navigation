import dotenv from "dotenv";

dotenv.config();

export const env = {
  NODE_ENV: process.env.NODE_ENV ?? "development",
  PORT: parseInt(process.env.PORT ?? "3000", 10),
  DB_PATH: process.env.DB_PATH ?? "./data/hospital-ivrs.db",

  // Public origin under which this backend is reachable from Exotel
  // (e.g. https://ivrs.yourhospital.in). Used to build absolute audio URLs
  // returned to the Exotel Play applet.
  PUBLIC_BASE_URL: process.env.PUBLIC_BASE_URL ?? "http://localhost:3000",

  // Exotel credentials. Only required if the backend ever calls Exotel's
  // outbound REST API; webhook handlers themselves do not need them.
  EXOTEL_SID: process.env.EXOTEL_SID ?? "",
  EXOTEL_API_KEY: process.env.EXOTEL_API_KEY ?? "",
  EXOTEL_API_TOKEN: process.env.EXOTEL_API_TOKEN ?? "",
  EXOTEL_VIRTUAL_NUMBER: process.env.EXOTEL_VIRTUAL_NUMBER ?? "",

  // If set, the IVRS webhook middleware rejects requests whose source IP
  // is not in this comma-separated allow-list. Exotel publishes their
  // egress IP ranges; populate this in production.
  EXOTEL_ALLOWED_IPS: (process.env.EXOTEL_ALLOWED_IPS ?? "")
    .split(",")
    .map((s) => s.trim())
    .filter(Boolean),
};
