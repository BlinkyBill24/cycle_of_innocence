# Arm C — Sorceress Tool API probe (2026-07-25)

## Mission

Prove key-on-disk + headless client; attempt **one** Briar `cower` gen vs Arm A (test only).  
**Do not** auto-adopt Sorceress into the production art stack ([[decisions/2026-07-25-briar-pose-bakeoff]] still stands).

## Key storage (human)

```text
~/.config/sorceress/api_key   # chmod 600, NEVER in repo
# optional: SORCERESS_API_KEY env
```

Same pattern as PixelLab / ElevenLabs.

## Client

```bash
python3 tools/sorceress_api.py ping
python3 tools/sorceress_api.py tools
python3 tools/sorceress_api.py image "…" --model grok-imagine --aspect 1:1 --out path.png
```

**Live base:** `https://sorceress.games/api/v1`  
- `GET /tools` — catalog  
- `POST /tools/<id>` — invoke  
- `GET /jobs/<id>` — async poll  

## Results (this probe)

| Check | Result |
|-------|--------|
| Key file present + mode 600 | OK |
| `ping` (auth) | **OK** — `pong: true`, creditsCharged 0 |
| `tools` list | **OK** — includes `image_generate`, AutoSprite suite, SFX, etc. |
| `image_generate` (grok-imagine, Briar cower prompt) | **BLOCKED** — HTTP **402** `Insufficient credits`, `balance: 0` |
| `cower_raw.png` written | **No** (no charge, no asset) |
| Score vs Arm A | **Deferred** until credits > 0 |

## Human next steps

1. Top up / grant credits on https://sorceress.games/ (account billing).  
2. Re-run:

```bash
python3 tools/sorceress_api.py image "$(cat <<'P'
retro pixel art top-down SNES Zelda style horror-tinged, small fawn-tan Malinois-style puppy
with black muzzle mask, upright ears, collar bell, COWER pose low tucked scared looking south,
solid magenta #FF00FF background, limited palette, crisp pixels no AA, game sprite
P
)" --model grok-imagine --aspect 1:1 \
  --out assets/reference/bakeoff_2026-07-25/arm_c_sorceress/cower_raw.png
```

3. Fill scorecard in `README.md` vs Arm A `../arm_a_imagine/cower_48.png`.  
4. Only then consider a **new decision** if C beats A on pose clarity *and* stays importable — stack stays Imagine+PixelLab until that decision.

## Stack status

**Unchanged:** Sorceress is **not** production stack. Client is an optional probe tool only.
