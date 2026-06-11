#!/usr/bin/env python3
"""Synthesize placeholder SFX (AU2) — replace at leisure with ChipTone.
Writes mono 22050 Hz WAVs to assets/audio/sfx/."""
import math
import random
import struct
import wave

SR = 22050
rng = random.Random(13)


def write_wav(name: str, samples: list[float]) -> None:
    path = f"assets/audio/sfx/{name}.wav"
    with wave.open(path, "w") as fh:
        fh.setnchannels(1)
        fh.setsampwidth(2)
        fh.setframerate(SR)
        fh.writeframes(b"".join(
            struct.pack("<h", int(max(-1.0, min(1.0, s)) * 32000)) for s in samples))
    print(f"wrote {path} ({len(samples)/SR:.2f}s)")


def env(i: int, n: int, attack: float = 0.01, decay: float = 1.0) -> float:
    t = i / n
    a = min(t / attack, 1.0) if attack > 0 else 1.0
    return a * math.exp(-t * 5.0 * decay)


def tone(freq_fn, dur: float, decay: float = 1.0, noise: float = 0.0) -> list[float]:
    n = int(SR * dur)
    out, phase = [], 0.0
    for i in range(n):
        phase += 2 * math.pi * freq_fn(i / n) / SR
        s = math.sin(phase) + noise * (rng.random() * 2 - 1)
        out.append(s * env(i, n, decay=decay) * 0.8)
    return out


def noise_burst(dur: float, lowpass: float = 0.3, decay: float = 1.0) -> list[float]:
    n = int(SR * dur)
    out, prev = [], 0.0
    for i in range(n):
        prev += lowpass * ((rng.random() * 2 - 1) - prev)
        out.append(prev * env(i, n, decay=decay) * 1.6)
    return out


# footstep: short soft thud
write_wav("footstep_grass", noise_burst(0.09, lowpass=0.12, decay=2.2))
# stick swing: filtered whoosh sweeping up
write_wav("attack_swing", [s * 0.7 for s in noise_burst(0.16, lowpass=0.5, decay=1.4)])
# hit: low thump + click
write_wav("hit_thud", [a + b for a, b in zip(
    tone(lambda t: 90 - 40 * t, 0.18, decay=1.8),
    noise_burst(0.18, lowpass=0.7, decay=3.0))])
# dig: repeated scrapes
dig = []
for k in range(3):
    dig += noise_burst(0.12, lowpass=0.25, decay=1.6) + [0.0] * int(SR * 0.06)
write_wav("briar_dig", dig)
# whimper: falling sine with vibrato
write_wav("briar_whimper", tone(
    lambda t: 620 - 260 * t + 28 * math.sin(t * 42), 0.5, decay=0.9))
# bark: two sharp bursts with pitch drop
bark = tone(lambda t: 340 - 140 * t, 0.10, decay=2.6, noise=0.5)
write_wav("briar_bark", bark + [0.0] * int(SR * 0.05) + bark)
# toy creak stinger: detuned descending squeak over a low swell — wrongness
creak = tone(lambda t: 1180 - 660 * t + 60 * math.sin(t * 90), 0.9, decay=0.5)
swell = tone(lambda t: 55 + 8 * t, 1.6, decay=0.35)
stinger = [(creak[i] * 0.55 if i < len(creak) else 0.0) + swell[i] * 0.7
           for i in range(len(swell))]
write_wav("toy_creak_stinger", stinger)


# hollowing bell: distant church bell, two slow tolls (inharmonic partials)
def bell(dur: float, f0: float) -> list[float]:
    n = int(SR * dur)
    partials = [(0.56, 0.5), (0.92, 1.0), (1.19, 0.55), (1.71, 0.3), (2.0, 0.45), (2.74, 0.2)]
    out = []
    for i in range(n):
        t = i / SR
        s = sum(a * math.sin(2 * math.pi * f0 * r * t) * math.exp(-t * (1.2 + r))
                for r, a in partials)
        out.append(s * 0.28)
    return out


toll = bell(2.2, 160.0)
write_wav("hollowing_bell", toll + [0.0] * int(SR * 0.7) + toll)


# briar growl: low chest rumble (quirk pings — true and false alike)
growl = []
n = int(SR * 0.55)
phase = 0.0
prev = 0.0
for i in range(n):
    phase += 2 * math.pi * (62 + 8 * math.sin(i / SR * 30)) / SR
    prev += 0.08 * ((rng.random() * 2 - 1) - prev)
    s = (math.sin(phase) * 0.6 + prev * 1.5) * env(i, n, attack=0.15, decay=0.9)
    growl.append(s * 0.7)
write_wav("briar_growl", growl)
