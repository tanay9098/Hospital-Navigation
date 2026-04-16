import { Router } from "express";
import IvrsService from "../services/IvrsService";
import db from "../db/db";

const router = Router();

router.post("/ivrs/call/start",(req,res)=>{

  const { caller_number, language_code } = req.body;

  const result = IvrsService.startCall(caller_number,language_code);

  res.json(result);

});

router.post("/ivrs/call/:call_id/interact",(req,res)=>{

  const { dtmf_input, speech_input } = req.body;
  const { call_id } = req.params;

  const seq = db.prepare(`
    SELECT COUNT(*) as c FROM IVRS_INTERACTION WHERE call_id=?
  `).get(call_id).c + 1;

  db.prepare(`
    INSERT INTO IVRS_INTERACTION
    (id,call_id,sequence,dtmf_input,speech_input,intent_matched)
    VALUES (?,?,?,?,?,?)
  `).run(
    crypto.randomUUID(),
    call_id,
    seq,
    dtmf_input,
    speech_input,
    "UNKNOWN"
  );

  res.json({ status:"logged" });

});

router.post("/ivrs/call/:call_id/end",(req,res)=>{

  const { call_status } = req.body;

  db.prepare(`
    UPDATE IVRS_CALL
    SET call_end=CURRENT_TIMESTAMP, call_status=?
    WHERE id=?
  `).run(call_status,req.params.call_id);

  res.json({ status:"ended" });

});

router.get("/ivrs/menu",(req,res)=>{

  res.json(IvrsService.menu());

});

export default router;