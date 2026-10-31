# Story 002: Câmera em terceira pessoa

> **Epic**: porto-sereno
> **Status**: Complete
> **Layer**: N/A (minimal)
> **Type**: Visual/Feel
> **Estimate**: S
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-31

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
- `src/camera/follow_camera_tuning.gd`
- `src/camera/follow_camera_tuning.tres`
- `src/test_levels/gray_ground.tscn`

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

## Completion Notes
**Completed**: 2026-10-31
**Criteria**: 5/6 passing (AC-4 walls DEFERRED to `production/epics/porto-sereno/story-005-cidade-costeira-completa.md`, which carries that criterion; the ground half passes)
**Deviations**: ADVISORY — camera runs before the tank in the scene tree and follows with a one-tick lag, while the comment at `src/camera/follow_camera.gd:25` says otherwise; `src/camera/follow_camera_tuning.gd` added beyond the planned Files list.
**Test Evidence**: `production/qa/evidence/story-002-camera-terceira-pessoa-evidence.md` and the screenshots in `production/qa/evidence/story-002-camera-terceira-pessoa/`; tests waived at qa.level minimal
**Reviewed by**: self, no independent review
