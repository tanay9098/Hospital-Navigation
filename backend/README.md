# PES Hospital — IVRS Backend (Exotel)

A voice-based hospital direction system for **feature-phone callers**.
A patient dials the hospital's Exotel number, picks a language, enters
the two-digit department shortcode printed on the signboards, and hears
landmark-based walking directions in their preferred language.

This backend is **independent** of the Flutter smartphone app in `lib/`.
The two systems share no API; they only happen to describe the same
building.

---

## Tech Stack

| Layer       | Technology              |
| ----------- | ----------------------- |
| Runtime     | Node.js                 |
| Framework   | Express.js              |
| Language    | TypeScript              |
| Database    | SQLite (better-sqlite3) |
| Telephony   | Exotel (ExoFlow + Passthru applets) |

---

## Quick start

```bash
cp .env.example .env
npm install
npm run migrate
npm run seed
npm run dev      # starts on PORT (default 3000)
```

Once running, hit the health check:

```bash
curl http://localhost:3000/api/v1/health/
```

---

## Endpoint surface

All IVRS endpoints accept **both GET and POST** so they can be wired to
any Exotel applet that supports an HTTP callback.  Each returns JSON of
the form `{ play: ["<absolute-audio-url>", ...], ...meta }`.

| Method | Path                          | Called from Exotel applet         |
| ------ | ----------------------------- | --------------------------------- |
| GET    | `/api/v1/health/`             | (none — for ops monitoring)       |
| GET    | `/api/v1/ivrs/start`          | First **Passthru** in the flow    |
| GET    | `/api/v1/ivrs/language`       | **Get Input** → language digit    |
| GET    | `/api/v1/ivrs/department`     | **Get Input** → 2-digit dept code |
| GET    | `/api/v1/ivrs/end`            | "Call status callback" URL        |
| GET    | `/prompts/{lang}/{file}.mp3`  | **Play** applet (static MP3s)     |

---

## ExoFlow setup (one-time, in the Exotel dashboard)

1. **App Bazaar → Create App → ExoFlow.**
2. Drag in this sequence of applets and configure their URLs to point at
   `${PUBLIC_BASE_URL}/api/v1/ivrs/...`:

   ```
   ┌──────────────┐
   │   Passthru   │  GET  /api/v1/ivrs/start
   └──────┬───────┘
          ▼
   ┌──────────────┐
   │     Play     │  ${PUBLIC_BASE_URL}/prompts/en/welcome.mp3
   └──────┬───────┘       (and language_menu.mp3 chained after)
          ▼
   ┌──────────────┐
   │  Get Input   │  numDigits = 1 ; timeout = 5s
   │  (language)  │  on input → POST /api/v1/ivrs/language
   └──────┬───────┘
          ▼
   ┌──────────────┐
   │     Play     │  URL from response `play[0]`  (dept_menu.mp3
   └──────┬───────┘    in the chosen language)
          ▼
   ┌──────────────┐
   │  Get Input   │  numDigits = 2 ; finishOnKey = "#"
   │ (department) │  on input → POST /api/v1/ivrs/department
   └──────┬───────┘
          ▼
   ┌──────────────┐
   │     Play     │  URL from response `play[0]`  (directions),
   │              │  then `play[1]` (farewell)
   └──────┬───────┘
          ▼
   ┌──────────────┐
   │   Hang up    │
   └──────────────┘
   ```

3. In the App's settings, set **Call status callback URL** to
   `GET ${PUBLIC_BASE_URL}/api/v1/ivrs/end` so we record completed /
   dropped status.

4. Point your Exotel ExoPhone (virtual number) at this App.

### Exposing localhost during development

Exotel needs a public HTTPS endpoint.  In dev, use [ngrok](https://ngrok.com):

```bash
ngrok http 3000
# copy the https:// URL and put it in .env as PUBLIC_BASE_URL
```

Then plug the same URL into each applet's "URL" field in ExoFlow.

---

## Data model

```
LANGUAGE         — en / kn / hi / ta (each mapped to a DTMF digit)
DEPARTMENT       — every clinical/admin unit, with ivrs_shortcode (1–99)
VOICE_PROMPT     — static prompts (welcome, dept_menu, error, …) per language
DEPT_DIRECTION   — landmark-based walking directions per (department, language)
IVRS_CALL        — one row per Exotel call (logged on /start)
IVRS_INTERACTION — every Passthru hit (logged with step + DTMF + intent)
```

### Adding a new department

1. Insert into `DEPARTMENT` with a unique `ivrs_shortcode`.
2. Insert one row per language into `DEPT_DIRECTION` with the script.
3. Record (or TTS-generate) MP3s and drop them at
   `prompts/{lang}/dept_{department_id}.mp3`.
4. Restart not required — the next call picks them up.

---

## Audio prompts

See **`prompts/README.md`** for the file layout, recording requirements
(8 kHz mono MP3 for Exotel), and a batch TTS recipe.

---

## What is intentionally not here

- No `/departments` or `/navigation` REST API — the Flutter app reads
  the nav graph from its own bundled assets and never calls this server.
- No client/backend sync — the smartphone app is fully offline-first;
  this backend exists only to power phone-based IVRS.
- No live TTS at call time — all prompts are pre-recorded so we get
  consistent voice quality on Indic languages and zero per-call latency.
