import db from "../db";

/* =============================
   LANGUAGES
   `ivrs_menu_option` is the DTMF digit the caller presses to pick this language.
============================= */

const languages: [string, string, string, string, string, string, number][] = [
  ["L_EN", "en", "English",  "English", "gcp", "en-IN-Standard-A", 1],
  ["L_KN", "kn", "Kannada",  "ಕನ್ನಡ",   "gcp", "kn-IN-Standard-A", 2],
  ["L_HI", "hi", "Hindi",    "हिन्दी",    "gcp", "hi-IN-Standard-A", 3],
  ["L_TA", "ta", "Tamil",    "தமிழ்",    "gcp", "ta-IN-Standard-A", 4],
];

const insertLang = db.prepare(`
INSERT OR IGNORE INTO LANGUAGE
(id, code, name, native_name, tts_engine, tts_voice_id, ivrs_menu_option)
VALUES (?, ?, ?, ?, ?, ?, ?)
`);
languages.forEach((l) => insertLang.run(...l));

/* =============================
   STATIC VOICE PROMPTS
   `audio_url` points to a file under `prompts/{lang}/{prompt_key}.mp3`,
   served by Express as static. Record these once and play them via
   Exotel's Play applet.
============================= */

type Prompt = [string, string, string, string, string, string];
//              id      lang_id key    text   audio   context

const audio = (lang: string, key: string) => `/prompts/${lang}/${key}.mp3`;

const prompts: Prompt[] = [
  // English
  ["VP_EN_WEL", "L_EN", "WELCOME",       "Welcome to PES Hospital navigation.",                                      audio("en", "welcome"),       "WELCOME"],
  ["VP_EN_LNG", "L_EN", "LANGUAGE_MENU", "For English press 1, Kannada 2, Hindi 3, Tamil 4.",                        audio("en", "language_menu"), "LANGUAGE_MENU"],
  ["VP_EN_DPT", "L_EN", "DEPT_MENU",     "Please enter the two digit department code from the signboard, then press hash.", audio("en", "dept_menu"), "DEPT_MENU"],
  ["VP_EN_NF",  "L_EN", "NOT_FOUND",     "Sorry, no department matches that code.",                                  audio("en", "not_found"),     "NOT_FOUND"],
  ["VP_EN_ERR", "L_EN", "ERROR",         "Sorry, something went wrong. Please try again later.",                     audio("en", "error"),         "ERROR"],
  ["VP_EN_BYE", "L_EN", "FAREWELL",      "Thank you for calling PES Hospital.",                                      audio("en", "farewell"),      "FAREWELL"],

  // Kannada
  ["VP_KN_WEL", "L_KN", "WELCOME",       "ಪಿಇಎಸ್ ಆಸ್ಪತ್ರೆ ನಾವಿಗೇಶನ್ ವ್ಯವಸ್ಥೆಗೆ ಸ್ವಾಗತ.",                                          audio("kn", "welcome"),       "WELCOME"],
  ["VP_KN_LNG", "L_KN", "LANGUAGE_MENU", "ಕನ್ನಡಕ್ಕೆ 2 ಒತ್ತಿ.",                                                          audio("kn", "language_menu"), "LANGUAGE_MENU"],
  ["VP_KN_DPT", "L_KN", "DEPT_MENU",     "ಸೂಚಕ ಫಲಕದ ಮೇಲಿನ ಎರಡು ಅಂಕಿಯ ಕೋಡ್ ಒತ್ತಿ ನಂತರ ಹ್ಯಾಶ್ ಒತ್ತಿ.",                          audio("kn", "dept_menu"),     "DEPT_MENU"],
  ["VP_KN_NF",  "L_KN", "NOT_FOUND",     "ಕ್ಷಮಿಸಿ, ಆ ಕೋಡ್‌ಗೆ ಯಾವುದೇ ವಿಭಾಗ ಸಿಗಲಿಲ್ಲ.",                                         audio("kn", "not_found"),     "NOT_FOUND"],
  ["VP_KN_ERR", "L_KN", "ERROR",         "ಕ್ಷಮಿಸಿ, ತೊಂದರೆ ಉಂಟಾಗಿದೆ. ನಂತರ ಪ್ರಯತ್ನಿಸಿ.",                                       audio("kn", "error"),         "ERROR"],
  ["VP_KN_BYE", "L_KN", "FAREWELL",      "ಪಿಇಎಸ್ ಆಸ್ಪತ್ರೆಗೆ ಕರೆ ಮಾಡಿದಕ್ಕೆ ಧನ್ಯವಾದ.",                                          audio("kn", "farewell"),      "FAREWELL"],

  // Hindi
  ["VP_HI_WEL", "L_HI", "WELCOME",       "पीईएस अस्पताल नेविगेशन में आपका स्वागत है.",                                  audio("hi", "welcome"),       "WELCOME"],
  ["VP_HI_LNG", "L_HI", "LANGUAGE_MENU", "हिन्दी के लिए 3 दबाएँ.",                                                     audio("hi", "language_menu"), "LANGUAGE_MENU"],
  ["VP_HI_DPT", "L_HI", "DEPT_MENU",     "साइनबोर्ड पर लिखा दो अंकों का कोड दबाएँ फिर हैश दबाएँ.",                        audio("hi", "dept_menu"),     "DEPT_MENU"],
  ["VP_HI_NF",  "L_HI", "NOT_FOUND",     "क्षमा करें, इस कोड से कोई विभाग नहीं मिला.",                                  audio("hi", "not_found"),     "NOT_FOUND"],
  ["VP_HI_ERR", "L_HI", "ERROR",         "क्षमा करें, कुछ गड़बड़ हुई. बाद में पुनः प्रयास करें.",                            audio("hi", "error"),         "ERROR"],
  ["VP_HI_BYE", "L_HI", "FAREWELL",      "पीईएस अस्पताल को कॉल करने के लिए धन्यवाद.",                                   audio("hi", "farewell"),      "FAREWELL"],

  // Tamil
  ["VP_TA_WEL", "L_TA", "WELCOME",       "பிஇஎஸ் மருத்துவமனை வழிசெலுத்தலுக்கு வரவேற்கிறோம்.",                            audio("ta", "welcome"),       "WELCOME"],
  ["VP_TA_LNG", "L_TA", "LANGUAGE_MENU", "தமிழுக்கு 4 அழுத்தவும்.",                                                    audio("ta", "language_menu"), "LANGUAGE_MENU"],
  ["VP_TA_DPT", "L_TA", "DEPT_MENU",     "சைன்போர்டில் உள்ள இரண்டு இலக்க குறியீட்டை அழுத்தி ஹாஷ் அழுத்தவும்.",              audio("ta", "dept_menu"),     "DEPT_MENU"],
  ["VP_TA_NF",  "L_TA", "NOT_FOUND",     "மன்னிக்கவும், அந்த குறியீட்டிற்கு துறை இல்லை.",                                  audio("ta", "not_found"),     "NOT_FOUND"],
  ["VP_TA_ERR", "L_TA", "ERROR",         "மன்னிக்கவும், சிக்கல் ஏற்பட்டது. பின்னர் முயற்சிக்கவும்.",                          audio("ta", "error"),         "ERROR"],
  ["VP_TA_BYE", "L_TA", "FAREWELL",      "பிஇஎஸ் மருத்துவமனைக்கு அழைத்ததற்கு நன்றி.",                                    audio("ta", "farewell"),      "FAREWELL"],
];

const insertPrompt = db.prepare(`
INSERT OR IGNORE INTO VOICE_PROMPT
(id, language_id, prompt_key, prompt_text, audio_url, context)
VALUES (?, ?, ?, ?, ?, ?)
`);
prompts.forEach((p) => insertPrompt.run(...p));

/* =============================
   DEPARTMENT DIRECTIONS  (landmark-based, per language)
   Only seeded for the high-traffic departments — extend in production.
   Audio URL convention: /prompts/{lang}/dept_{department_id}.mp3
============================= */

type Direction = [string, string, string, string, string];
//                 id     dept   lang  text  audio

const dir = (lang: string, deptId: string) => `/prompts/${lang}/dept_${deptId}.mp3`;

const directions: Direction[] = [
  // Reception (D1, ground floor)
  ["DD_D1_EN", "D1", "L_EN", "Reception is on the ground floor, directly opposite the main entrance.", dir("en", "D1")],
  ["DD_D1_KN", "D1", "L_KN", "ಸ್ವಾಗತ ಕೊಠಡಿ ನೆಲ ಮಹಡಿಯಲ್ಲಿ ಮುಖ್ಯ ಪ್ರವೇಶದ ಎದುರಿಗೆ ಇದೆ.", dir("kn", "D1")],
  ["DD_D1_HI", "D1", "L_HI", "रिसेप्शन ग्राउंड फ्लोर पर मुख्य प्रवेश के सामने है.", dir("hi", "D1")],
  ["DD_D1_TA", "D1", "L_TA", "வரவேற்பு தரை தளத்தில் முக்கிய நுழைவாயிலுக்கு எதிரே உள்ளது.", dir("ta", "D1")],

  // Emergency (D2)
  ["DD_D2_EN", "D2", "L_EN", "Emergency is on the ground floor, to the left of the main entrance. Follow the red signs.", dir("en", "D2")],
  ["DD_D2_KN", "D2", "L_KN", "ತುರ್ತು ವಿಭಾಗ ನೆಲ ಮಹಡಿಯಲ್ಲಿ ಮುಖ್ಯ ಪ್ರವೇಶದ ಎಡಭಾಗದಲ್ಲಿದೆ. ಕೆಂಪು ಸೂಚಕಗಳನ್ನು ಅನುಸರಿಸಿ.", dir("kn", "D2")],
  ["DD_D2_HI", "D2", "L_HI", "आपातकालीन विभाग ग्राउंड फ्लोर पर मुख्य प्रवेश के बाईं ओर है. लाल साइनबोर्ड का अनुसरण करें.", dir("hi", "D2")],
  ["DD_D2_TA", "D2", "L_TA", "அவசர பிரிவு தரை தளத்தில் முக்கிய நுழைவாயிலின் இடதுபுறம் உள்ளது. சிவப்பு பலகைகளை பின்தொடரவும்.", dir("ta", "D2")],

  // Pharmacy (D4)
  ["DD_D4_EN", "D4", "L_EN", "Pharmacy is on the ground floor, next to reception on the right.", dir("en", "D4")],
  ["DD_D4_KN", "D4", "L_KN", "ಔಷಧಾಲಯ ನೆಲ ಮಹಡಿಯಲ್ಲಿ ಸ್ವಾಗತ ಕೊಠಡಿಯ ಬಲಭಾಗದಲ್ಲಿದೆ.", dir("kn", "D4")],
  ["DD_D4_HI", "D4", "L_HI", "फार्मेसी ग्राउंड फ्लोर पर रिसेप्शन के दाईं ओर है.", dir("hi", "D4")],
  ["DD_D4_TA", "D4", "L_TA", "மருந்தகம் தரை தளத்தில் வரவேற்புக்கு வலதுபுறம் உள்ளது.", dir("ta", "D4")],

  // Cardiology OPD (D41, floor 4)
  ["DD_D41_EN", "D41", "L_EN", "Cardiology is on floor 4. Take the lift on your right, turn left after exiting. It is the third room on the left.", dir("en", "D41")],
  ["DD_D41_KN", "D41", "L_KN", "ಹೃದಯಶಾಸ್ತ್ರ ವಿಭಾಗ ನಾಲ್ಕನೇ ಮಹಡಿಯಲ್ಲಿದೆ. ಬಲಭಾಗದ ಲಿಫ್ಟ್ ತೆಗೆದುಕೊಂಡು ಹೊರಬಂದ ನಂತರ ಎಡಕ್ಕೆ ತಿರುಗಿ. ಎಡಭಾಗದ ಮೂರನೇ ಕೋಣೆ.", dir("kn", "D41")],
  ["DD_D41_HI", "D41", "L_HI", "कार्डियोलॉजी चौथे फ्लोर पर है. दाईं ओर की लिफ्ट लें, बाहर निकलकर बाएँ मुड़ें. बाएँ हाथ पर तीसरा कमरा.", dir("hi", "D41")],
  ["DD_D41_TA", "D41", "L_TA", "இதயவியல் நான்காவது தளத்தில் உள்ளது. வலதுபுற லிப்டை எடுத்துக் கொள்ளுங்கள், வெளியேறிய பிறகு இடப்புறம் திரும்பவும். இடதுபுற மூன்றாவது அறை.", dir("ta", "D41")],
];

const insertDir = db.prepare(`
INSERT OR IGNORE INTO DEPT_DIRECTION
(id, department_id, language_id, direction_text, audio_url)
VALUES (?, ?, ?, ?, ?)
`);
directions.forEach((d) => insertDir.run(...d));

console.log("Languages, voice prompts, and department directions seeded.");
