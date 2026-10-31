# Story 003: Canhão com mira e disparo

> **Epic**: porto-sereno
> **Status**: Ready
> **Layer**: N/A (minimal)
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: [set by /dev-story when implementation begins]

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 4 — canhão com mira e disparo

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH (docs/engine-reference/godot/VERSION.md: 4.7 é pós-cutoff)
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

- [ ] O canhão gira (horizontal e vertical) seguindo a mira controlada pelo mouse, independente da direção do casco
- [ ] Há uma mira visível na tela indicando para onde o canhão aponta
- [ ] Um botão dispara um projétil na direção do canhão
- [ ] O projétil percorre uma trajetória e termina ao atingir qualquer coisa (chão, prédio, mar) ou ao sair do alcance
- [ ] Ao atingir algo, o projétil emite um evento de impacto com posição e alvo atingido, para a story 004 consumir
- [ ] Há um intervalo mínimo entre disparos (recarga), em dado externo
- [ ] Velocidade do projétil, alcance e recarga ficam em dados externos
- [ ] Atirar não é possível com o jogo pausado

---

## Implementation Notes

- O impacto deve ser um sinal (Signal) com posição, normal e o nó atingido, sem acoplar o canhão à destruição.
- Conferir a API de raycast/colisão no `docs/engine-reference/godot/modules/physics.md` antes de usar.

---

## Out of Scope

- Story 004: o que acontece com o alvo atingido (estágios de destruição)
- Story 006: crateras e fumaça
- Story 007: som e efeito visual do disparo

---

## Files

- `src/vehicle/cannon.gd`
- `src/vehicle/projectile.gd`
- `src/vehicle/cannon_tuning.tres`
- `tests/integration/cannon/cannon_fire_test.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above.*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/cannon/cannon_fire_test.gd` OU um playtest documentado (testes dispensados em `qa.level: minimal`)

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/porto-sereno/story-001-tanque-dirigivel.md`, `production/epics/porto-sereno/story-002-camera-terceira-pessoa.md`
- Unlocks: `production/epics/porto-sereno/story-004-destruicao-em-estagios.md`
