# Pre-recorded IVRS audio prompts

This directory is served as static files by Express at `/prompts/...`.
Exotel's **Play** applet fetches MP3s from here over HTTPS.

## Layout

```
prompts/
├── en/      English
├── kn/      Kannada
├── hi/      Hindi
└── ta/      Tamil
```

For each language directory, drop in these MP3s:

### Static prompts (one per language)

| File                  | Spoken content (see `02_languages_voice_prompts.ts` seed) |
| --------------------- | --------------------------------------------------------- |
| `welcome.mp3`         | "Welcome to PES Hospital navigation."                     |
| `language_menu.mp3`   | "For English press 1, Kannada 2, …"                       |
| `dept_menu.mp3`       | "Enter the two digit department code then press hash."    |
| `not_found.mp3`       | "Sorry, no department matches that code."                 |
| `error.mp3`           | "Sorry, something went wrong."                            |
| `farewell.mp3`        | "Thank you for calling."                                  |

### Per-department direction prompts

For every department row in the `DEPARTMENT` table, record one direction
clip per language and save as:

```
prompts/{lang}/dept_{department_id}.mp3
```

Example: directions for **Cardiology** (`D41`) in Hindi →
`prompts/hi/dept_D41.mp3`.

The `direction_text` column in `DEPT_DIRECTION` is the script to read out.

## How to generate the MP3s

For a hospital deployment we **strongly recommend pre-recording with a
human voice artist** for the welcome / menu / farewell prompts (they're
heard on every call). For department directions, batch TTS is acceptable.

Quick batch TTS via Google Cloud TTS (one-shot):

```bash
# psuedocode — pipe each row of DEPT_DIRECTION through gcloud tts
sqlite3 data/hospital-ivrs.db \
  "SELECT department_id, language_id, direction_text FROM DEPT_DIRECTION" \
  | while IFS='|' read dept lang text; do
      gcloud ml speech synthesize --language $lang --text "$text" \
        > "prompts/${lang}/dept_${dept}.mp3"
    done
```

Files must be **8 kHz mono MP3 or WAV** for Exotel compatibility — use
`ffmpeg -ar 8000 -ac 1` to downsample anything richer.
