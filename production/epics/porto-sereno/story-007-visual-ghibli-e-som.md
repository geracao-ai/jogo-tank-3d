# Story 007: Visual Ghibli e som

> **Epic**: porto-sereno
> **Status**: Ready
> **Layer**: N/A (minimal)
> **Type**: Visual/Feel
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: [set by /dev-story when implementation begins]

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 7 — visual Ghibli e som: toon shader, céu pintado, ambiente sereno, disparo e explosão

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH (docs/engine-reference/godot/VERSION.md: 4.7 é pós-cutoff)
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal). O projeto usa o renderizador Compatibility (alvo Web); `docs/engine-reference/godot/` não diz o que ele suporta em shaders. Validar o toon shader nele cedo.

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*Direção de arte e áudio do brief: cidade pintada à mão no estilo Ghibli, cores suaves, céu de aquarela; ambiente de mar e cigarras, cortado pelo estrondo seco do canhão.*

- [ ] A cidade, o tanque e o mar usam um toon shader com cores suaves
- [ ] O céu tem aparência de pintura (aquarela), não um céu realista
- [ ] O visual funciona no renderizador Compatibility, no alvo Web
- [ ] Há um som ambiente contínuo de mar e cigarras
- [ ] O disparo do canhão toca um som seco e alto, que contrasta com o ambiente sereno
- [ ] A explosão ao atingir um alvo tem som e efeito visual próprios
- [ ] Os três estágios de destruição (story 004) e as marcas (story 006) mantêm o mesmo estilo
- [ ] O jogo mantém 60 fps no alvo Web com o visual final
- [ ] O volume do som pode ser ajustado ou silenciado (necessário em navegador)

---

## Implementation Notes

- Verificar a API de shader no `docs/engine-reference/godot/` e, na dúvida, pesquisar na documentação oficial antes de escrever; os shaders ficam com o godot-shader-specialist.
- Exportar para web cedo para validar o shader e medir desempenho.
- Os assets de áudio e arte final podem ser provisórios no início; o critério é o estilo e o contraste sonoro.

---

## Out of Scope

- Mais de uma cidade ou mais de um veículo
- Música com composição elaborada além do ambiente descrito

---

## Files

- `src/rendering/toon.gdshader`
- `src/rendering/watercolor_sky.gdshader`
- `src/audio/audio_manager.gd`
- `assets/audio/` (ambiente, disparo, explosão)

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above.*

---

## Test Evidence

**Story Type**: Visual/Feel
**Required evidence**: um screenshot retido em `production/qa/evidence/` de uma exportação Web + sign-off em `production/qa/evidence/story-007-visual-ghibli-e-som-evidence.md`

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/porto-sereno/story-005-cidade-costeira-completa.md`, `production/epics/porto-sereno/story-006-marcas-permanentes.md`
- Unlocks: None
