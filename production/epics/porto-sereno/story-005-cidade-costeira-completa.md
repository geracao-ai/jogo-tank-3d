# Story 005: Cidade costeira completa

> **Epic**: porto-sereno
> **Status**: Complete
> **Layer**: N/A (minimal)
> **Type**: Visual/Feel
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-31

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

- `src/world/city_builder.gd`
- `src/world/porto_sereno_city.json`
- `src/world/tuning/building_tuning.tres`
- `src/world/tuning/shop_tuning.tres`
- `src/world/tuning/bank_tuning.tres`
- `src/test_levels/porto_sereno.tscn`
- `src/camera/follow_camera.gd`
- `src/camera/follow_camera_tuning.gd`
- `src/camera/follow_camera_tuning.tres`

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

## Completion Notes
**Completed**: 2026-10-31
**Criteria**: 9/9 passing. AC-8 measured on release Web builds with the whole city (26 objects: 13 buildings, 12 shops, 1 bank): Android Chrome 156 at 60.1 fps in all four scenarios (worst frame 30.4 ms), Mac M1 Pro in Chromium at 75.0 fps (worst frame 21.4 ms); the flat values suggest a display cap. AC-9 (camera vs. walls, left open by story 002) was proven by script only: 0 of 8,580 frames had a wall between tank and camera.
**Deviations**: ADVISORY — scene lives in `src/test_levels/porto_sereno.tscn`, not `src/world/`; invisible walls on all four world edges (not only the shoreline) can pull the camera in when the tank touches them; hits per type (building 2/4, shop 1/2, bank 3/6) were chosen by the implementing agent and accepted by the developer; `export_presets.cfg` is gitignored, so a fresh clone must recreate it.
**Test Evidence**: sign-off `production/qa/evidence/story-005-cidade-costeira-completa-evidence.md`; screenshots and `web-fps-android.json`, `web-fps-mac.json` in `production/qa/evidence/story-005-cidade-costeira-completa/`; tests waived at qa.level minimal
**Reviewed by**: self, no independent review
