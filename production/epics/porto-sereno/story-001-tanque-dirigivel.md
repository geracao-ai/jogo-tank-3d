# Story 001: Tanque dirigível

> **Epic**: porto-sereno
> **Status**: Complete
> **Layer**: N/A (minimal)
> **Type**: Visual/Feel
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-31

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 1 — tanque que acelera, freia, vira e anda de ré

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH (docs/engine-reference/godot/VERSION.md: 4.7 é pós-cutoff)
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal). Consultar `docs/engine-reference/godot/modules/physics.md` (Jolt) antes de usar APIs de física.

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*From `design/game-brief.md` (Build order 1: provar que é gostoso de guiar), em um cenário cinza:*

- [ ] O tanque acelera para frente ao segurar a tecla de avanço e ganha velocidade de forma gradual, não instantânea
- [ ] O tanque freia ao soltar o acelerador e/ou usar o freio, até parar
- [ ] O tanque vira para a esquerda e para a direita, e a curva muda de acordo com a velocidade
- [ ] O tanque anda de ré
- [ ] O tanque tem peso perceptível: não para nem arranca de forma instantânea
- [ ] Valores de aceleração, velocidade máxima, freio e curva ficam em arquivo de dados externo, não no código
- [ ] A cena de teste é um terreno plano cinza com o tanque, sem pedestres nem outros veículos
- [ ] Controle por teclado funciona e há suporte parcial a gamepad (project.yaml: Gamepad Support Partial)

---

## Implementation Notes

- Nó de veículo 3D com física Jolt (padrão no 4.7). Conferir `docs/engine-reference/godot/modules/physics.md` antes de usar o nó de veículo ou corpo rígido.
- Cenário cinza simples: o objetivo é só provar a sensação de dirigir.
- Valores de tuning em um `Resource` ou arquivo de dados (coding-standards: gameplay data-driven).
- Os controles não podem depender de hover (alvo: web).

---

## Out of Scope

- Story 002: câmera em terceira pessoa
- Story 003: canhão e disparo
- Story 005: a cidade

---

## Files

- `src/vehicle/tank.gd`
- `src/vehicle/tank_tuning.gd`
- `src/vehicle/tank_tuning.tres`
- `src/vehicle/tank.tscn`
- `src/test_levels/gray_ground.tscn`
- `project.godot`

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above.*

---

## Test Evidence

**Story Type**: Visual/Feel
**Required evidence**: um screenshot retido em `production/qa/evidence/` + sign-off em `production/qa/evidence/story-001-tanque-dirigivel-evidence.md` (testes automáticos dispensados em `qa.level: minimal`; o screenshot não)

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: None
- Unlocks: `production/epics/porto-sereno/story-002-camera-terceira-pessoa.md`, `production/epics/porto-sereno/story-003-canhao-mira-disparo.md`

## Completion Notes
**Completed**: 2026-10-31 — closed over a BLOCKED verdict, by the user's explicit choice ("Fechar mesmo assim, aceitando as lacunas")
**Criteria**: 2/8 covered (AC-6 data-driven tuning; AC-7 gray scene, seen in `01-cena-tanque00000059.png`). Untested criteria: AC-1 to AC-5 and AC-8 (accelerate, brake, turn, reverse, weight, keyboard/gamepad). Their only basis is the /dev-story simulated-input measurement (12 m/s in 2 s, 10→0 m/s braking, 5 m/s reverse, 76° turn in 1.5 s); nobody has driven it with real keys or a gamepad.
**Deviations**: ADVISORY — `physics/3d/physics_engine` set to Jolt in `project.godot`; `src/vehicle/tank_tuning.gd` added beyond the planned Files list. Missing: Visual/Feel sign-off `production/qa/evidence/story-001-tanque-dirigivel-evidence.md` was never created.
**Test Evidence**: screenshots `production/qa/evidence/story-001-tanque-dirigivel/01-cena-tanque00000059.png` and `02-tanque-em-curva.png`; tests waived at qa.level minimal
**Reviewed by**: self, no independent review
**Feel**: DEFERRED — needs a hands-on drive (`godot --path .`); tuning values in `tank_tuning.tres` are a first guess.
