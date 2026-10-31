# Story 006: Marcas permanentes

> **Epic**: porto-sereno
> **Status**: Ready
> **Layer**: N/A (minimal)
> **Type**: Visual/Feel
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: [set by /dev-story when implementation begins]

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 6 — marcas permanentes durante a sessão: crateras, escombros e fumaça

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH (docs/engine-reference/godot/VERSION.md: 4.7 é pós-cutoff)
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*Player goal do brief: uma sessão parece completa quando o jogador olha para trás e vê uma cidade visivelmente diferente por causa dele.*

- [ ] Cada impacto do canhão deixa uma cratera no chão onde atingiu
- [ ] Objetos que chegam ao estágio destruído deixam escombros no lugar
- [ ] Objetos danificados ou destruídos emitem fumaça contínua
- [ ] As marcas persistem até o jogo ser fechado; não somem sozinhas com o tempo
- [ ] Voltar a um lugar já visitado mostra as marcas feitas antes
- [ ] Não há sistema de save: as marcas se perdem ao fechar o jogo (fora de escopo: save entre sessões)
- [ ] Muitas marcas acumuladas não derrubam o jogo abaixo de 60 fps no alvo Web (definir um teto de marcas em dado externo)

---

## Implementation Notes

- Consumir os eventos da story 003 (impacto) e da story 004 (mudança de estágio).
- Prever um teto de marcas: sem ele, a persistência cresce sem limite na web.

---

## Out of Scope

- Save entre sessões
- Som e visual final: story 007

---

## Files

- `src/destruction/marks_manager.gd`
- `src/destruction/crater.tscn`
- `src/destruction/smoke_emitter.tscn`
- `src/destruction/marks_tuning.tres`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above.*

---

## Test Evidence

**Story Type**: Visual/Feel
**Required evidence**: um screenshot retido em `production/qa/evidence/` mostrando uma área já alterada + sign-off em `production/qa/evidence/story-006-marcas-permanentes-evidence.md`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/porto-sereno/story-004-destruicao-em-estagios.md`, `production/epics/porto-sereno/story-005-cidade-costeira-completa.md`
- Unlocks: `production/epics/porto-sereno/story-007-visual-ghibli-e-som.md`
