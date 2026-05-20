import { Router, Request, Response, RequestHandler } from "express";
import IvrsService from "../services/IvrsService";
import { parseExotel, exotelIpAllowlist } from "../middleware/exotel";

/**
 * IVRS webhook routes.  Every endpoint is hit by an Exotel applet
 * (Passthru / Get Input) configured in the ExoFlow visual builder.
 *
 * Exotel typically sends GET requests with the call context in the query
 * string, but some applets POST a form body — both are accepted here.
 * Each handler:
 *   1. logs the interaction
 *   2. updates the IVRS_CALL row
 *   3. responds with JSON describing the audio URLs Exotel should play
 *
 * In the ExoFlow dashboard, place a "Play" applet after each Passthru and
 * configure its URL from `play[0]` of the JSON response.  For multi-clip
 * playback, chain successive Play applets reading `play[1]`, `play[2]`, …
 */
const router = Router();

router.use(exotelIpAllowlist);
router.use(parseExotel);

const start: RequestHandler = (req: Request, res: Response) => {
  const { callSid, from, to } = req.exotel!;
  if (!callSid) {
    res.status(400).json({ error: "missing CallSid" });
    return;
  }
  res.json(IvrsService.startCall(callSid, from, to));
};

const language: RequestHandler = (req: Request, res: Response) => {
  const { callSid, digits } = req.exotel!;
  if (!callSid) {
    res.status(400).json({ error: "missing CallSid" });
    return;
  }
  res.json(IvrsService.selectLanguage(callSid, digits));
};

const department: RequestHandler = (req: Request, res: Response) => {
  const { callSid, digits } = req.exotel!;
  if (!callSid) {
    res.status(400).json({ error: "missing CallSid" });
    return;
  }
  res.json(IvrsService.selectDepartment(callSid, digits));
};

const end: RequestHandler = (req: Request, res: Response) => {
  const { callSid, dialCallStatus } = req.exotel!;
  if (!callSid) {
    res.status(400).json({ error: "missing CallSid" });
    return;
  }
  res.json(IvrsService.endCall(callSid, dialCallStatus));
};

router.route("/start").get(start).post(start);
router.route("/language").get(language).post(language);
router.route("/department").get(department).post(department);
router.route("/end").get(end).post(end);

export default router;
