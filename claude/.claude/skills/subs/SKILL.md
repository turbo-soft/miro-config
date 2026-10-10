---
name: subs
description: Download subtitles for video files in the current directory using subliminal. Use when the user wants to fetch/download subtitles for movies or TV series.
disable-model-invocation: true
argument-hint: [language code, e.g. "en", "nl", "de"]
---

# Download Subtitles

Download subtitles for all video files in the current working directory using `subliminal`.

## Usage

The default language is English (`en`). If `$ARGUMENTS` is provided, use it as the language code (e.g. `nl`, `de`, `fr`, `pt-BR`).

## Command

```bash
subliminal download -l <language> -f *.mkv *.mp4 *.avi 2>&1
```

Key flags:
- `-l <language>` — IETF language code
- `-f` (force) — **required**, forces download even when embedded subtitles are already present in the video files, otherwise subliminal skips them

## Steps

1. Run `ls` to show the video files that will be processed
2. Run the subliminal command above with the appropriate language
3. Report how many subtitles were downloaded and list any failures
