import db from "../db";

/* =========================
   LANGUAGES
========================= */

const languages = [
["L_EN","en","English","English","gcp","en-IN-Standard-A",1],
["L_KN","kn","Kannada","ಕನ್ನಡ","gcp","kn-IN-Standard-A",2],
["L_HI","hi","Hindi","हिन्दी","gcp","hi-IN-Standard-A",3],
["L_TA","ta","Tamil","தமிழ்","gcp","ta-IN-Standard-A",4]
];

const insertLang = db.prepare(`
INSERT OR IGNORE INTO LANGUAGE
(id, code, name, native_name, tts_engine, tts_voice_id, ivrs_menu_option)
VALUES (?, ?, ?, ?, ?, ?, ?)
`);

languages.forEach(l => insertLang.run(...l));

/* =========================
   VOICE PROMPTS
========================= */

const prompts = [

/* English */
["VP1","L_EN","WELCOME_MSG","Welcome to PES Hospital navigation system.","","WELCOME"],
["VP2","L_EN","MAIN_MENU","Press 1 for departments, 2 for directions.","","MENU"],
["VP3","L_EN","ERROR_MSG","Sorry, I did not understand.","","ERROR"],
["VP4","L_EN","CONFIRM_DEST","You selected the department.","","CONFIRMATION"],
["VP5","L_EN","GOODBYE","Thank you for calling PES Hospital.","","FAREWELL"],

/* Kannada */
["VP6","L_KN","WELCOME_MSG","ಪಿಇಎಸ್ ಆಸ್ಪತ್ರೆ ನಾವಿಗೇಶನ್ ವ್ಯವಸ್ಥೆಗೆ ಸ್ವಾಗತ.","","WELCOME"],
["VP7","L_KN","MAIN_MENU","ವಿಭಾಗಗಳಿಗೆ 1 ಒತ್ತಿರಿ.","","MENU"],
["VP8","L_KN","ERROR_MSG","ಕ್ಷಮಿಸಿ, ನಿಮ್ಮ ಮಾತು ಅರ್ಥವಾಗಲಿಲ್ಲ.","","ERROR"],
["VP9","L_KN","CONFIRM_DEST","ನೀವು ಆಯ್ದ ವಿಭಾಗ.","","CONFIRMATION"],
["VP10","L_KN","GOODBYE","ಪಿಇಎಸ್ ಆಸ್ಪತ್ರೆಗೆ ಕರೆ ಮಾಡಿದಕ್ಕೆ ಧನ್ಯವಾದ.","","FAREWELL"],

/* Hindi */
["VP11","L_HI","WELCOME_MSG","पीईएस अस्पताल नेविगेशन प्रणाली में आपका स्वागत है.","","WELCOME"],
["VP12","L_HI","MAIN_MENU","विभागों के लिए 1 दबाएँ.","","MENU"],
["VP13","L_HI","ERROR_MSG","क्षमा करें, समझ नहीं आया.","","ERROR"],
["VP14","L_HI","CONFIRM_DEST","आपने विभाग चुना है.","","CONFIRMATION"],
["VP15","L_HI","GOODBYE","पीईएस अस्पताल को कॉल करने के लिए धन्यवाद.","","FAREWELL"],

/* Tamil */
["VP16","L_TA","WELCOME_MSG","பிஇஎஸ் மருத்துவமனை வழிசெலுத்தல் அமைப்பிற்கு வரவேற்கிறோம்.","","WELCOME"],
["VP17","L_TA","MAIN_MENU","துறைகளுக்கு 1 அழுத்தவும்.","","MENU"],
["VP18","L_TA","ERROR_MSG","மன்னிக்கவும் புரியவில்லை.","","ERROR"],
["VP19","L_TA","CONFIRM_DEST","நீங்கள் தேர்ந்தெடுத்த துறை.","","CONFIRMATION"],
["VP20","L_TA","GOODBYE","பிஇஎஸ் மருத்துவமனைக்கு அழைத்ததற்கு நன்றி.","","FAREWELL"]

];

const insertPrompt = db.prepare(`
INSERT OR IGNORE INTO VOICE_PROMPT
(id, language_id, prompt_key, prompt_text, audio_url, context)
VALUES (?, ?, ?, ?, ?, ?)
`);

prompts.forEach(p => insertPrompt.run(...p));

console.log("Languages and voice prompts seeded.");