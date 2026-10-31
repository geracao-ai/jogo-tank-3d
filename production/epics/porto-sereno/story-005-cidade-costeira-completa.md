# Story 005: Cidade costeira completa

> **Epic**: porto-sereno
> **Status**: Ready
> **Layer**: N/A (minimal)
> **Type**: Visual/Feel
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: [set by /dev-story when implementation begins]

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 3 — uma cidade com ruas, lojas, prédios, banco e mar

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH (docs/engine-reference/godot/VERSION.md: 4.7 é pós-cutoff)
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*Build order 3: a cidade em blocos simples, com tudo destrutível. O visual final vem na story 007.*

- [ ] Existe uma cidade em uma cena única com ruas navegáveis pelo tanque
- [ ] A cidade tem lojas, prédios e um banco, reconhecíveis entre si (forma ou etiqueta de teste)
- [ ] A cidade é costeira: há mar junto à cidade, visível das ruas
- [ ] O mar é só paisagem: o tanque não entra nele (fora de escopo: entrar no mar)
- [ ] Prédios não podem ser acessados por dentro (fora de escopo: entrar em prédios)
- [ ] Não há pedestres nem outros carros
- [ ] Lojas, prédios, banco e demais objetos usam o componente destrutível da story 004
- [ ] A cidade roda a 60 fps no alvo Web com tudo intacto
- [ ] A câmera da story 002 não atravessa os prédios

---

## Implementation Notes

- Usar blocos simples; o visual Ghibli entra na story 007.
- Reaproveitar o componente destrutível; não reimplementar destruição aqui.
- Medir draw calls na primeira exportação web (limite ainda não definido em technical-preferences.md).

---

## Out of Scope

- Story 006: marcas permanentes
- Story 007: visual Ghibli e som

---

## Files

- `src/world/porto_sereno.tscn`
- `src/world/buildings/` (cenas das lojas, prédios e banco)
- `src/world/sea.tscn`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above.*

---

## Test Evidence

**Story Type**: Visual/Feel
**Required evidence**: um screenshot retido em `production/qa/evidence/` mostrando ruas, loja, banco e mar + sign-off em `production/qa/evidence/story-005-cidade-costeira-completa-evidence.md`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/porto-sereno/story-004-destruicao-em-estagios.md`
- Unlocks: `production/epics/porto-sereno/story-006-marcas-permanentes.md`, `production/epics/porto-sereno/story-007-visual-ghibli-e-som.md`
