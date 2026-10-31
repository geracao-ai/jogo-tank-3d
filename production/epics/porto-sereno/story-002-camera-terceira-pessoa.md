# Story 002: Câmera em terceira pessoa

> **Epic**: porto-sereno
> **Status**: Ready
> **Layer**: N/A (minimal)
> **Type**: Visual/Feel
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: [set by /dev-story when implementation begins]

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 2 — câmera em terceira pessoa que segue o tanque

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH (docs/engine-reference/godot/VERSION.md: 4.7 é pós-cutoff)
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

- [ ] A câmera fica atrás e acima do tanque e o mantém sempre em quadro
- [ ] A câmera segue o tanque ao acelerar, frear, virar e dar ré, com suavização (sem tranco)
- [ ] O jogador consegue ver a rua à frente e o próprio tanque ao mesmo tempo
- [ ] A câmera não atravessa o chão nem as paredes dos prédios
- [ ] Distância, altura e suavização ficam em dados externos
- [ ] Funciona com mouse e teclado (mira do canhão fica para a story 003)

---

## Implementation Notes

- Câmera de seguimento sobre o tanque da story 001; o comportamento de colisão da câmera deve ser tratado quando a cidade (story 005) existir.
- Valores em dados externos.

---

## Out of Scope

- Story 003: mira do canhão controlando a câmera
- Story 005: colisão da câmera com os prédios da cidade

---

## Files

- `src/camera/follow_camera.gd`
- `src/camera/follow_camera_tuning.tres`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above.*

---

## Test Evidence

**Story Type**: Visual/Feel
**Required evidence**: um screenshot retido em `production/qa/evidence/` + sign-off em `production/qa/evidence/story-002-camera-terceira-pessoa-evidence.md`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/porto-sereno/story-001-tanque-dirigivel.md`
- Unlocks: `production/epics/porto-sereno/story-003-canhao-mira-disparo.md`
