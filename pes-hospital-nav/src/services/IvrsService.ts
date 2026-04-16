import db from "../db/db";
import { randomUUID } from "crypto";

export default class IvrsService {

  static startCall(caller: string, lang: string) {

    const activeSession = db.prepare(`
      SELECT * FROM NAV_SESSION
      WHERE user_id = ?
      AND status='ACTIVE'
      AND started_at > datetime('now','-30 minutes')
    `).get(caller);

    const callId = randomUUID();

    db.prepare(`
      INSERT INTO IVRS_CALL(id,caller_number,language_code,call_status,menu_version)
      VALUES(?,?,?,?,1)
    `).run(callId,caller,lang,"ACTIVE");

    const prompt = db.prepare(`
      SELECT prompt_text FROM VOICE_PROMPT
      WHERE language_id=? AND context='WELCOME'
      LIMIT 1
    `).get(lang);

    return { call_id: callId, prompt };
  }

  static menu() {

    return db.prepare(`
      SELECT floor_number,name,ivrs_shortcode
      FROM DEPARTMENT
      ORDER BY floor_number
    `).all();

  }

}