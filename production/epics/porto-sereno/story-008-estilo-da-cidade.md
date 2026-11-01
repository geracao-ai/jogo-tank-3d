# Story 008: Estilo da cidade

> **Epic**: porto-sereno
> **Status**: Complete
> **Layer**: N/A (minimal)
> **Type**: Visual/Feel
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-11-01

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Art direction do brief — cidade pintada à mão no estilo Ghibli. Após jogar, o desenvolvedor avaliou: "nao tem estilo muito menos ghibli".

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH (docs/engine-reference/godot/VERSION.md: 4.7 é pós-cutoff)
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal). Importar modelos em glTF; conferir no renderizador Compatibility.

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*O desenvolvedor escolheu kit gratuito CC0 mais detalhes próprios. A referência visual é uma vila costeira de filme Ghibli.*

- [ ] Prédios, lojas e banco usam modelos com forma real (telhado, janelas, portas), não blocos lisos
- [ ] Modelos e texturas de terceiros têm licença CC0 registrada no repositório
- [ ] Há vegetação nas ruas e nos lotes: árvores e arbustos
- [ ] Há detalhes de rua: postes com fios, muros ou cercas, e barcos ou um cais junto ao mar
- [ ] Há morros no fundo e nuvens grandes, de modo que o horizonte não fique vazio
- [ ] Paredes e telhados têm cor variada e aparência pintada, com contraste contra o céu
- [ ] Os estágios danificado e destruído continuam funcionando em todos os objetos, com colisão correta
- [ ] A cidade continua gerada a partir do arquivo de dados
- [ ] O jogo mantém no Android o desempenho aceito na story 007 (57 a 60 fps), medido no `/fps/`
- [ ] O tanque tem estilo próprio, coerente com a cidade: esteiras, rodas, torre e detalhes pintados, sem mudar colisão nem direção (pedido do desenvolvedor em 2026-11-01)

---

## Implementation Notes

- Kits candidatos, com licença CC0 confirmada nas páginas: Kenney City Kit Suburban (`https://kenney.nl/assets/city-kit-suburban`) e Kenney Nature Kit (`https://kenney.nl/assets/nature-kit`). O site recusa `curl`; o download pode precisar do desenvolvedor.
- Importar só as peças usadas, para não inflar a build web. Reaproveitar malhas compartilhadas.
- Aplicar o `toon.gdshader` aos modelos para manter o estilo.
- Provar um quarteirão antes de converter a cidade inteira, medindo no celular.

---

## Out of Scope

- Interiores de prédios
- Pedestres e outros carros
- Colisão de cercas e do cais: o tanque e os tiros passam por eles
- Personagens
- Arte feita à mão ou por encomenda

---

## Files

- `src/world/city_builder.gd`
- `src/world/city_prop.gd`
- `src/world/porto_sereno_city.json`
- `src/rendering/toon.gdshader`
- `src/rendering/ground_shadow.gdshader`
- `src/rendering/ruined_building.gdshader`
- `src/vehicle/tank.gd`
- `src/vehicle/tank.tscn`
- `src/vehicle/tank_model.gd`
- `src/destruction/destruction_router.gd`
- `src/destruction/marks_manager.gd`
- `src/test_levels/porto_sereno.tscn`
- `tools/generate_city_art.py`
- `assets/models/` (peças CC0 usadas e `License.txt` de cada kit)
- `assets/textures/`

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above.*

---

## Test Evidence

**Story Type**: Visual/Feel
**Required evidence**: screenshots retidos em `production/qa/evidence/story-008-estilo-da-cidade/` + sign-off em `production/qa/evidence/story-008-estilo-da-cidade-evidence.md`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/porto-sereno/story-007-visual-ghibli-e-som.md`
- Unlocks: None

## Completion Notes
**Completed**: 2026-11-01
**Criteria**: 10/10 passing. AC-9 accepted by the developer on Android Chrome 156 from the play-session result: 56.2 to 60.1 fps, 60.1 in 17 of 20 windows, 13 objects hit, worst frame 266.7 ms in the first window.
**Deviations**: ADVISORY — before the draw-call cuts, the untouched still view ran at about 48 fps and the whole city in ruins at about 40; neither was measured again after them. The cause of the gap between playing and an untouched screen is unproven. Literals that could be data remain in `src/vehicle/tank_model.gd` (colours, sizes), `src/world/city_builder.gd` (pole and wire radii, prewarm wait). Fences and the pier have no collision. The tank criterion AC-10 was added at the developer's request during implementation. Implementation ran inline, without the programmer agent or the engine specialist's API check.
**Test Evidence**: sign-off `production/qa/evidence/story-008-estilo-da-cidade-evidence.md`; screenshots, `web-fps-android-jogando.json`, `web-fps-android-parado.json` and `web-fps-android-isolamento.json` in `production/qa/evidence/story-008-estilo-da-cidade/`; tests waived at qa.level minimal
**Reviewed by**: self, no independent review
