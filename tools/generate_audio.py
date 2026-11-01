#!/usr/bin/env python3
"""Synthesises the placeholder audio for Porto Sereno (story-007) with the Python standard
library only, and writes 16-bit mono 22050 Hz WAV files into assets/audio/.

Usage (from the project root):  python3 tools/generate_audio.py
Output: ambient_sea_cicadas.wav and tank_engine.wav (both loop seamlessly), cannon_shot.wav,
explosion.wav.
Deterministic (fixed seed). Replace any file with your own recording of the same name, or
change the paths in src/audio/audio_tuning.tres.
"""
import math
import os
import random
import struct
import wave

RATE = 22050
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "assets", "audio")


def write(name, samples):
    peak = max(1e-9, max(abs(s) for s in samples))
    scale = 0.95 * 32767 / peak
    path = os.path.join(OUT, name)
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b"".join(struct.pack("<h", int(s * scale)) for s in samples))
    print(name, os.path.getsize(path), "bytes")


def lowpass(samples, coeff, passes=1):
    for _ in range(passes):
        y = 0.0
        out = []
        for s in samples:
            y += coeff * (s - y)
            out.append(y)
        samples = out
    return samples


def ambient():
    rng = random.Random(1)
    seconds = 6
    n = RATE * seconds
    # Sea: low-passed noise with slow swells whose period divides the loop length.
    sea = lowpass([rng.uniform(-1, 1) for _ in range(n)], 0.06, 2)
    sea_peak = max(abs(s) for s in sea)
    swell = [0.55 + 0.45 * math.sin(2 * math.pi * 2 * i / n - 1.0) for i in range(n)]
    sea = [s / sea_peak * swell[i] for i, s in enumerate(sea)]
    fade = RATE // 2
    # Cicadas: two ~4 kHz buzzes, amplitude-pulsed at ~30 Hz with a slow on/off envelope.
    cic = []
    for i in range(n):
        t = i / RATE
        buzz = (math.sin(2 * math.pi * 4200 * t) + 0.6 * math.sin(2 * math.pi * 5100 * t)) * \
            (0.5 + 0.5 * math.sin(2 * math.pi * 30 * t))
        env = 0.5 + 0.5 * math.sin(2 * math.pi * (1.0 / 3.0) * t)
        cic.append(buzz * env * 0.25)
    mix = [sea[i] * 0.8 + cic[i] * 0.12 for i in range(n)]  # cicadas far away: phones stress this band
    # Wrap the last `fade` samples into the loop start for a click-free join.
    for i in range(fade):
        a = i / fade
        mix[i] = mix[i] * a + mix[n - fade + i] * (1 - a)
    return mix[:n - fade]


def shot():
    rng = random.Random(2)
    n = int(RATE * 0.5)
    out = []
    low = 0.0
    for i in range(n):
        t = i / RATE
        crack = rng.uniform(-1, 1) * math.exp(-t * 60)
        low += 0.15 * (rng.uniform(-1, 1) - low)
        boom = low * 3.0 * math.exp(-t * 14)
        thump = math.sin(2 * math.pi * (140 * math.exp(-t * 9) + 40) * t) * math.exp(-t * 11)
        out.append(crack * 1.0 + boom + thump * 1.3)
    return out


def explosion():
    rng = random.Random(3)
    n = int(RATE * 1.6)
    out = []
    a = b = 0.0
    for i in range(n):
        t = i / RATE
        w = rng.uniform(-1, 1)
        a += 0.25 * (w - a)
        b += 0.03 * (w - b)
        rumble = b * 4.0 * math.exp(-t * 2.2)
        debris = a * math.exp(-t * 6)
        thump = math.sin(2 * math.pi * (90 * math.exp(-t * 3) + 28) * t) * math.exp(-t * 4)
        out.append((debris * 0.8 + rumble + thump * 1.2) * min(1.0, t * 200))
    return out


def engine():
    """Low diesel rumble. Whole cycles in the loop, so it joins without a click. The fundamental
    is too low for a phone speaker, so the audible body comes from the harmonics above it."""
    rng = random.Random(4)
    seconds = 1
    n = RATE * seconds
    cycles = 55  # fundamental in Hz: an integer number of cycles per second loops cleanly
    tone = []
    for i in range(n):
        phase = 2 * math.pi * cycles * i / n
        s = 0.0
        for k in range(1, 13):
            s += math.sin(k * phase + k * k * 0.7) * (1.0 if k <= 4 else 4.0 / k) / k ** 0.5
        # Firing pulses: the level beats once per cycle, a whole number of times in the loop.
        s *= 0.75 + 0.25 * math.sin(phase * 0.5 * 2)
        tone.append(s)
    # Rumble noise, crossfaded over its own start so the loop point stays clean.
    fade = RATE // 10
    noise = lowpass([rng.uniform(-1, 1) for _ in range(n + fade)], 0.08, 2)
    for i in range(fade):
        t = i / fade
        noise[i] = noise[i] * t + noise[n + i] * (1 - t)
    noise_peak = max(abs(x) for x in noise[:n])
    tone_peak = max(abs(x) for x in tone)
    write("tank_engine.wav", [tone[i] / tone_peak + 0.08 * noise[i] / noise_peak for i in range(n)])


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    write("ambient_sea_cicadas.wav", ambient())
    write("cannon_shot.wav", shot())
    write("explosion.wav", explosion())
    engine()
