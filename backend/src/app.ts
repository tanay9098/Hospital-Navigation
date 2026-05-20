import express, { Application } from "express";
import path from "path";
import { errorHandler } from "./middleware/errorHandler";
import { notFound } from "./middleware/notFound";
import apiRouter from "./routes/index";

const app: Application = express();

// Exotel webhook bodies arrive as application/x-www-form-urlencoded
// (and many fields actually come in the query string), so both parsers
// are required.
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Pre-recorded multilingual audio. Exotel's Play applet fetches files
// from here over HTTPS.  Audio file layout:
//   prompts/{lang}/welcome.mp3
//   prompts/{lang}/dept_menu.mp3
//   prompts/{lang}/dept_{department_id}.mp3
app.use(
  "/prompts",
  express.static(path.join(process.cwd(), "prompts"), {
    fallthrough: false,
    maxAge: "1h",
  }),
);

// IVRS webhooks + health
app.use("/api/v1", apiRouter);

app.use(notFound);
app.use(errorHandler);

export default app;
