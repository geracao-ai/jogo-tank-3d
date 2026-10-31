# Test Evidence: Tanque dirigível

> **Story**: `production/epics/porto-sereno/story-001-tanque-dirigivel.md`
> **Story Type**: Visual/Feel
> **Date**: 2026-10-31
> **Tester**: Lucas Silva (hands-on run); Claude Code (simulated-input measurements and captures)
> **Build / Commit**: uncommitted working tree on `main`; see `production/qa/evidence/story-001-tanque-dirigivel/stamp.txt`

---

## What Was Tested

A direção do tanque no cenário cinza. O desenvolvedor rodou o jogo e relatou: "Eu rodei e gostei", e confirmou: "001 tb testado". A execução manual aconteceu depois da história 002, já com a câmera de seguimento. As medições e as imagens são anteriores, com a câmera fixa.

**Acceptance criteria covered**: AC-1 a AC-7. AC-8 coberto só na parte do teclado.

---

## Acceptance Criteria Results

| # | Criterion (from story) | Result | Notes |
|---|----------------------|--------|-------|
| AC-1 | O tanque acelera para frente ao segurar a tecla de avanço e ganha velocidade de forma gradual, não instantânea | PASS | Aprovado pelo desenvolvedor; 12 m/s em 2 s na medição |
| AC-2 | O tanque freia ao soltar o acelerador e/ou usar o freio, até parar | PASS | Aprovado pelo desenvolvedor; de 10 para 0 m/s na medição |
| AC-3 | O tanque vira para a esquerda e para a direita, e a curva muda de acordo com a velocidade | PASS | Aprovado pelo desenvolvedor; 76° e 36° em 1,5 s, medida indicativa |
| AC-4 | O tanque anda de ré | PASS | Aprovado pelo desenvolvedor; 5 m/s na medição |
| AC-5 | O tanque tem peso perceptível: não para nem arranca de forma instantânea | PASS | Sensação aprovada pelo desenvolvedor |
| AC-6 | Valores de aceleração, velocidade máxima, freio e curva ficam em arquivo de dados externo, não no código | PASS | `src/vehicle/tank_tuning.tres` |
| AC-7 | A cena de teste é um terreno plano cinza com o tanque, sem pedestres nem outros veículos | PASS | Na imagem 1 |
| AC-8 | Controle por teclado funciona e há suporte parcial a gamepad | PARTIAL | Teclado: execução manual. Gamepad: uso não registrado |

---

## Screenshots / Video

| # | Filename | What It Shows | Acceptance Criterion |
|---|----------|--------------|----------------------|
| 1 | `story-001-tanque-dirigivel/01-cena-tanque00000059.png` | Tanque parado no cenário cinza, câmera fixa | AC-7 |
| 2 | `story-001-tanque-dirigivel/02-tanque-em-curva.png` | Tanque deslocado e girado depois de dirigido por entrada simulada | AC-1, AC-3 |

---

## Test Conditions

- **Game state at start**: cena `src/test_levels/gray_ground.tscn`
- **Platform / hardware**: macOS (Darwin 25.6.0), arm64, Godot 4.7.2; não testado na exportação Web
- **Framerate during test**: not measured
- **Any special setup required**: none

---

## Observations

- `stamp.txt` deve mostrar `gray_ground.tscn` como alterado: a história 002 trocou a câmera da cena depois das capturas.
- Não foi registrado se o desenvolvedor usou gamepad.

---

## Sign-Off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Lead (art-director / designer) | Lucas Silva | 2026-10-31 | [x] Approved |

*Template: `.claude/docs/templates/test-evidence.md`*
*Location: `production/qa/evidence/[story-slug]-evidence.md`*
