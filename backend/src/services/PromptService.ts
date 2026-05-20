import db from "../db/db";
import { env } from "../config/env";

type VoicePromptRow = {
  audio_url: string;
  prompt_text: string;
};

type DirectionRow = {
  audio_url: string;
  direction_text: string;
};

function absolute(url: string | undefined): string | null {
  if (!url) return null;
  if (url.startsWith("http://") || url.startsWith("https://")) return url;
  return `${env.PUBLIC_BASE_URL}${url}`;
}

/**
 * Look up a static prompt (welcome, error, farewell, etc.) for a language.
 * Returns the absolute audio URL Exotel's Play applet should fetch.
 */
function getPrompt(langCode: string, context: string): { url: string | null; text: string } {
  const row = db
    .prepare(
      `SELECT vp.audio_url, vp.prompt_text
         FROM VOICE_PROMPT vp
         JOIN LANGUAGE l ON l.id = vp.language_id
        WHERE l.code = ? AND vp.context = ?
        LIMIT 1`,
    )
    .get(langCode, context) as VoicePromptRow | undefined;

  return { url: absolute(row?.audio_url), text: row?.prompt_text ?? "" };
}

/**
 * Look up the landmark-direction prompt for a specific department, in a
 * specific language.  Falls back to English if the requested language has
 * no recording yet.
 */
function getDirection(
  langCode: string,
  departmentId: string,
): { url: string | null; text: string } {
  const row = db
    .prepare(
      `SELECT dd.audio_url, dd.direction_text
         FROM DEPT_DIRECTION dd
         JOIN LANGUAGE l ON l.id = dd.language_id
        WHERE l.code = ? AND dd.department_id = ?
        LIMIT 1`,
    )
    .get(langCode, departmentId) as DirectionRow | undefined;

  if (row) return { url: absolute(row.audio_url), text: row.direction_text };

  // Fallback to English
  const fallback = db
    .prepare(
      `SELECT dd.audio_url, dd.direction_text
         FROM DEPT_DIRECTION dd
         JOIN LANGUAGE l ON l.id = dd.language_id
        WHERE l.code = 'en' AND dd.department_id = ?
        LIMIT 1`,
    )
    .get(departmentId) as DirectionRow | undefined;

  return { url: absolute(fallback?.audio_url), text: fallback?.direction_text ?? "" };
}

export default { getPrompt, getDirection };
