# Test Evidence: Câmera em terceira pessoa

> **Story**: `production/epics/porto-sereno/story-002-camera-terceira-pessoa.md`
> **Story Type**: Visual/Feel
> **Date**: 2026-10-31
> **Tester**: Lucas Silva (hands-on run); Claude Code (simulated-input measurements and captures)
> **Build / Commit**: uncommitted working tree on `main`; see `production/qa/evidence/story-002-camera-terceira-pessoa/stamp.txt`

---

## What Was Tested

A câmera de seguimento no cenário cinza, atrás e acima do tanque, parado, em curva e de ré. O desenvolvedor rodou o jogo e relatou: "Eu rodei e gostei". As medições são de uma execução com entrada simulada: 9 trechos, 1.680 frames.

**Acceptance criteria covered**: AC-1, AC-2, AC-3, AC-5, AC-6. AC-4 coberto só na parte do chão.

---

## Acceptance Criteria Results

| # | Criterion (from story) | Result | Notes |
|---|----------------------|--------|-------|
| AC-1 | A câmera fica atrás e acima do tanque e o mantém sempre em quadro | PASS | 0 frames fora de quadro em 1.680 |
| AC-2 | A câmera segue o tanque ao acelerar, frear, virar e dar ré, com suavização (sem tranco) | PASS | Aprovado pelo desenvolvedor; maior passo 0,23 m e maior giro 1,1° por frame |
| AC-3 | O jogador consegue ver a rua à frente e o próprio tanque ao mesmo tempo | PASS | Nas três imagens; ainda não há rua, só o terreno à frente |
| AC-4 | A câmera não atravessa o chão nem as paredes dos prédios | PARTIAL | Chão: altura mínima medida de 5 m. Paredes: NOT TESTED, não há prédios até a story 005 |
| AC-5 | Distância, altura e suavização ficam em dados externos | PASS | `src/camera/follow_camera_tuning.tres` |
| AC-6 | Funciona com mouse e teclado (mira do canhão fica para a story 003) | PASS | A câmera não lê entrada; mira fica para a story 003 |

---

## Screenshots / Video

| # | Filename | What It Shows | Acceptance Criterion |
|---|----------|--------------|----------------------|
| 1 | `story-002-camera-terceira-pessoa/01-parado.png` | Tanque parado, câmera atrás e acima, terreno à frente | AC-1, AC-3 |
| 2 | `story-002-camera-terceira-pessoa/02-em-curva.png` | Tanque em curva, ainda em quadro | AC-1, AC-2 |
| 3 | `story-002-camera-terceira-pessoa/03-de-re.png` | Tanque de ré, sem a câmera girar | AC-1, AC-2 |

---

## Test Conditions

- **Game state at start**: cena `src/test_levels/gray_ground.tscn`
- **Platform / hardware**: macOS (Darwin 25.6.0), arm64, Godot 4.7.2; não testado na exportação Web
- **Framerate during test**: not measured
- **Any special setup required**: none

---

## Observations

- Colisão da câmera com prédios continua aberta até a story 005.
- A câmera segue o tanque com um tick de atraso, por causa da ordem dos nós; o comentário em `src/camera/follow_camera.gd:25` afirma o contrário.
- Não foi registrado se o desenvolvedor usou gamepad.

---

## Sign-Off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Lead (art-director / designer) | Lucas Silva | 2026-10-31 | [x] Approved |

*Template: `.claude/docs/templates/test-evidence.md`*
*Location: `production/qa/evidence/[story-slug]-evidence.md`*
