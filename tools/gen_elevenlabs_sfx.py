#!/usr/bin/env python3
"""Generate game SFX via ElevenLabs sound-generation (text-to-sound-effects).

Key: ~/.config/elevenlabs/api_key (NEVER in repo). Requests PCM, downmixes
stereo->mono (lighter for the Web export constraint), wraps as 16-bit 44.1kHz
WAV with the stdlib `wave` module (no ffmpeg). Replaces the placeholder SFX
in-place (same filenames so Sfx.gd keeps working) and adds new ones.

Free-tier aware: generates sequentially and STOPS on the first quota/credit
error (402/429), reporting what was saved so we can resume next billing period.

Usage: python3 tools/gen_elevenlabs_sfx.py [--only name]
"""
import argparse
import array
import json
import sys
import urllib.request
import urllib.error
import wave
from pathlib import Path

KEY = (Path.home() / ".config/elevenlabs/api_key").read_text().strip()
URL = "https://api.elevenlabs.io/v1/sound-generation?output_format=pcm_44100"
SR = 44100
OUT = Path("assets/audio/sfx")

# name -> (duration_seconds, prompt_influence, text)
SFX = {
    # --- replace existing placeholders (keep filename -> Sfx.gd keys intact) ---
    "briar_bark":     (2.0, 0.5, "a dog barking twice, sharp and alert"),
    "briar_whimper":  (2.5, 0.5, "a small dog whimpering softly, scared and sad"),
    "briar_dig":      (2.5, 0.5, "a dog digging fast in dirt, paws scratching loose earth"),
    "footstep_grass": (2.0, 0.5, "soft footsteps walking on grass, a few slow steps"),
    "hit_thud":       (1.5, 0.6, "a heavy punch landing on a body, dull meaty thud"),
    "attack_swing":   (1.2, 0.6, "a quick whoosh of a wooden stick swung through the air"),
    # --- new ---
    "footstep_gravel":(2.0, 0.5, "footsteps walking on gravel, crunching small loose stones"),
    "found":          (2.0, 0.5, "a soft warm discovery chime, a gentle bell sparkle, something important found"),
    "owl_hoot":       (3.0, 0.5, "an owl hooting at night, two slow eerie hoots in a quiet forest"),
    "crickets":       (5.0, 0.4, "crickets chirping steadily at night, calm continuous nocturnal ambience"),
}


def downmix_mono(pcm: bytes) -> bytes:
    """Stereo interleaved s16le -> mono s16le (average of L/R)."""
    samples = array.array("h")
    samples.frombytes(pcm)
    mono = array.array("h", bytes(len(pcm) // 2))
    for i in range(len(mono)):
        lo = samples[2 * i]
        ro = samples[2 * i + 1]
        mono[i] = (lo + ro) // 2
    if sys.byteorder == "big":
        mono.byteswap()
    return mono.tobytes()


def generate(name: str, secs: float, influence: float, text: str) -> bool:
    body = json.dumps({
        "text": text,
        "duration_seconds": secs,
        "prompt_influence": influence,
    }).encode()
    req = urllib.request.Request(URL, data=body, method="POST", headers={
        "xi-api-key": KEY, "Content-Type": "application/json",
    })
    try:
        with urllib.request.urlopen(req, timeout=120) as r:
            pcm = r.read()
    except urllib.error.HTTPError as e:
        msg = e.read().decode()[:200]
        print(f"  ✗ {name}: HTTP {e.code} {msg}", flush=True)
        if e.code in (401, 402, 429):  # auth / quota / rate -> stop the batch
            return False
        return True  # other error: skip this one, keep going
    mono = downmix_mono(pcm)
    dest = OUT / f"{name}.wav"
    with wave.open(str(dest), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(mono)
    print(f"  ✓ {name}.wav ({len(mono) // 1024} KB, {secs}s)", flush=True)
    return True


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--only")
    args = ap.parse_args()
    OUT.mkdir(parents=True, exist_ok=True)
    for name, (secs, infl, text) in SFX.items():
        if args.only and name != args.only:
            continue
        if not generate(name, secs, infl, text):
            print(f"\nSTOPPED at {name} (auth/quota/rate). Saved files are good; "
                  "resume next period or with --only.", flush=True)
            sys.exit(2)
    print("\nall requested SFX generated")


if __name__ == "__main__":
    main()
