import db from "../db/db";
import { randomUUID } from "crypto";
import PromptService from "./PromptService";

const DEFAULT_LANG = "en";

type CallRow = {
  id: string;
  language_code: string | null;
};

type LangRow = { code: string };

type DeptRow = {
  id: string;
  name: string;
  short_name: string;
  floor_number: number;
};

/* ---------- internal helpers ---------- */

function getOrCreateCall(exotelCallSid: string, from: string, to: string): CallRow {
  const existing = db
    .prepare(`SELECT id, language_code FROM IVRS_CALL WHERE exotel_call_sid = ?`)
    .get(exotelCallSid) as CallRow | undefined;

  if (existing) return existing;

  const id = randomUUID();
  db.prepare(
    `INSERT INTO IVRS_CALL
       (id, exotel_call_sid, caller_number, called_number, call_status)
     VALUES (?, ?, ?, ?, 'ACTIVE')`,
  ).run(id, exotelCallSid, from, to);

  return { id, language_code: null };
}

function logInteraction(
  callId: string,
  step: string,
  dtmf: string | undefined,
  intent: string,
  promptKey?: string,
): void {
  const seq =
    (db.prepare(`SELECT COUNT(*) AS c FROM IVRS_INTERACTION WHERE call_id = ?`).get(callId) as {
      c: number;
    }).c + 1;

  db.prepare(
    `INSERT INTO IVRS_INTERACTION
       (id, call_id, sequence, step, dtmf_input, intent_matched, prompt_played)
     VALUES (?, ?, ?, ?, ?, ?, ?)`,
  ).run(randomUUID(), callId, seq, step, dtmf ?? null, intent, promptKey ?? null);
}

function resolveLanguageFromDigit(digit: string | undefined): string {
  if (!digit) return DEFAULT_LANG;
  const row = db
    .prepare(`SELECT code FROM LANGUAGE WHERE ivrs_menu_option = ? AND is_active = 1`)
    .get(parseInt(digit, 10)) as LangRow | undefined;
  return row?.code ?? DEFAULT_LANG;
}

/* ---------- public API ---------- */

/**
 * Step 1 — call comes in. Exotel's first Passthru applet hits this.
 * Creates an IVRS_CALL row and returns the welcome + language-menu URLs.
 */
function startCall(exotelCallSid: string, from: string, to: string) {
  const call = getOrCreateCall(exotelCallSid, from, to);
  logInteraction(call.id, "START", undefined, "UNKNOWN", "WELCOME");

  const welcome = PromptService.getPrompt(DEFAULT_LANG, "WELCOME");
  const langMenu = PromptService.getPrompt(DEFAULT_LANG, "LANGUAGE_MENU");

  return {
    call_id: call.id,
    play: [welcome.url, langMenu.url].filter(Boolean) as string[],
  };
}

/**
 * Step 2 — caller pressed a digit to choose a language.
 * Stores it on the call and returns the dept-menu prompt in that language.
 */
function selectLanguage(exotelCallSid: string, digit: string | undefined) {
  const call = getOrCreateCall(exotelCallSid, "", "");
  const langCode = resolveLanguageFromDigit(digit);

  db.prepare(`UPDATE IVRS_CALL SET language_code = ? WHERE id = ?`).run(langCode, call.id);
  logInteraction(call.id, "LANGUAGE", digit, "LANGUAGE_SELECT", "DEPT_MENU");

  const deptMenu = PromptService.getPrompt(langCode, "DEPT_MENU");
  return { call_id: call.id, language: langCode, play: deptMenu.url ? [deptMenu.url] : [] };
}

/**
 * Step 3 — caller entered a department shortcode (e.g. "41" for Cardiology).
 * Looks up the department and returns the direction-audio URL.
 */
function selectDepartment(exotelCallSid: string, digits: string | undefined) {
  const call = getOrCreateCall(exotelCallSid, "", "");
  const langCode = call.language_code ?? DEFAULT_LANG;

  const shortcode = digits ? parseInt(digits, 10) : NaN;
  const dept = Number.isFinite(shortcode)
    ? (db
        .prepare(
          `SELECT id, name, short_name, floor_number
             FROM DEPARTMENT
            WHERE ivrs_shortcode = ? AND is_active = 1
            LIMIT 1`,
        )
        .get(shortcode) as DeptRow | undefined)
    : undefined;

  if (!dept) {
    logInteraction(call.id, "DEPARTMENT", digits, "UNKNOWN", "NOT_FOUND");
    const nf = PromptService.getPrompt(langCode, "NOT_FOUND");
    const menu = PromptService.getPrompt(langCode, "DEPT_MENU");
    return {
      call_id: call.id,
      found: false,
      play: [nf.url, menu.url].filter(Boolean) as string[],
    };
  }

  db.prepare(`UPDATE IVRS_CALL SET selected_dept_id = ? WHERE id = ?`).run(dept.id, call.id);
  logInteraction(call.id, "DIRECTIONS", digits, "DEPARTMENT_SELECT", `dept_${dept.id}`);

  const direction = PromptService.getDirection(langCode, dept.id);
  const farewell = PromptService.getPrompt(langCode, "FAREWELL");

  return {
    call_id: call.id,
    found: true,
    department: { id: dept.id, name: dept.name, floor: dept.floor_number },
    play: [direction.url, farewell.url].filter(Boolean) as string[],
  };
}

/**
 * Final webhook from Exotel when the call hangs up.
 */
function endCall(exotelCallSid: string, dialCallStatus: string | undefined) {
  const status =
    dialCallStatus === "completed"
      ? "COMPLETED"
      : dialCallStatus === "no-answer" || dialCallStatus === "failed"
        ? "DROPPED"
        : "COMPLETED";

  const row = db
    .prepare(`SELECT id FROM IVRS_CALL WHERE exotel_call_sid = ?`)
    .get(exotelCallSid) as { id: string } | undefined;

  if (!row) return { ok: false };

  db.prepare(
    `UPDATE IVRS_CALL
        SET call_end = CURRENT_TIMESTAMP, call_status = ?
      WHERE id = ?`,
  ).run(status, row.id);

  logInteraction(row.id, "END", undefined, "HANGUP");
  return { ok: true, call_id: row.id, call_status: status };
}

export default { startCall, selectLanguage, selectDepartment, endCall };
