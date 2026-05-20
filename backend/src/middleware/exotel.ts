import { Request, Response, NextFunction } from "express";
import { env } from "../config/env";

/**
 * Normalized view of an Exotel webhook hit.
 *
 * Exotel sends a mix of query-string and form-body parameters depending on
 * the applet (Passthru, Get Input, Connect, etc.). The names also differ
 * slightly between Exotel and Twilio.  This middleware flattens both
 * sources into a single `req.exotel` object so handlers don't need to
 * know which transport the field arrived through.
 */
export interface ExotelPayload {
  callSid: string;
  from: string;
  to: string;
  callType?: string;
  direction?: string;
  digits?: string;
  dialCallStatus?: string;
  recordingUrl?: string;
  // Custom field we set on the Exotel applet, used to indicate which step
  // in the IVR flow this webhook represents (e.g. "start", "language",
  // "department", "end"). Driven by the ExoFlow configuration.
  step?: string;
}

declare global {
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace Express {
    interface Request {
      exotel?: ExotelPayload;
    }
  }
}

function pick(req: Request, key: string): string | undefined {
  const q = req.query[key];
  if (typeof q === "string" && q.length > 0) return q;
  const b = (req.body ?? {})[key];
  if (typeof b === "string" && b.length > 0) return b;
  return undefined;
}

export function parseExotel(req: Request, _res: Response, next: NextFunction): void {
  req.exotel = {
    callSid: pick(req, "CallSid") ?? "",
    from: pick(req, "From") ?? pick(req, "CallFrom") ?? "",
    to: pick(req, "To") ?? pick(req, "CallTo") ?? "",
    callType: pick(req, "CallType"),
    direction: pick(req, "Direction"),
    digits: pick(req, "digits") ?? pick(req, "Digits"),
    dialCallStatus: pick(req, "DialCallStatus"),
    recordingUrl: pick(req, "RecordingUrl"),
    step: pick(req, "step"),
  };
  next();
}

/**
 * Optional IP allow-list. Exotel publishes their egress IPs at
 * https://developer.exotel.com/api/  Populate EXOTEL_ALLOWED_IPS in prod.
 */
export function exotelIpAllowlist(req: Request, res: Response, next: NextFunction): void {
  if (env.EXOTEL_ALLOWED_IPS.length === 0) return next();

  // `req.ip` respects the `trust proxy` setting; when running behind nginx
  // make sure to set `app.set("trust proxy", true)` in index.ts.
  const ip = req.ip ?? "";
  if (!env.EXOTEL_ALLOWED_IPS.includes(ip)) {
    res.status(403).json({ error: "forbidden", ip });
    return;
  }
  next();
}
