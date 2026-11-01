# Story 006: Marcas permanentes

> **Epic**: porto-sereno
> **Status**: Complete
> **Layer**: N/A (minimal)
> **Type**: Visual/Feel
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-31

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
- `src/destruction/marks_tuning.gd`
- `src/destruction/marks_tuning.tres`
- `src/test_levels/porto_sereno.tscn`
- `src/test_levels/single_building.tscn`

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

## Completion Notes
**Completed**: 2026-10-31 — closed with AC-7 failing by 1.4 fps, accepted by the developer
**Criteria**: 6/7 passing. AC-7 (60 fps with many marks) measured on Android Chrome 156 with the whole city damaged and 60 craters: 58.6 fps (27 of 470 frames over 20 ms); destroyed stage 60.1 fps. The first smoke made of spheres gave 50.9 and 55.8 fps and 37,416 primitives; billboard quads cut it to 8,564 primitives. Two scenarios without marks lost about 3.6 fps each to a ~550 ms stall of unknown cause (it also showed in story 005b).
**Deviations**: ADVISORY — `crater.tscn` and `smoke_emitter.tscn` were not created, everything is built in code; smoke restarts when an object goes from damaged to destroyed; wall hits leave no crater; above 60 craters the oldest is reused. The developer approved the marks and the new smoke on Android.
**Test Evidence**: sign-off `production/qa/evidence/story-006-marcas-permanentes-evidence.md`; screenshot and `web-fps-android.json`, `web-fps-android-esferas.json` in `production/qa/evidence/story-006-marcas-permanentes/`; tests waived at qa.level minimal
**Reviewed by**: self, no independent review
