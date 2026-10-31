# Story 004: Destruição em estágios

> **Epic**: porto-sereno
> **Status**: Ready
> **Layer**: N/A (minimal)
> **Type**: Integration
> **Estimate**: L
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: [set by /dev-story when implementation begins]

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief MVP feature 5 — tudo na cidade é destrutível, em estágios: intacto → danificado → destruído

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH (docs/engine-reference/godot/VERSION.md: 4.7 é pós-cutoff)
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal)

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*Este é o maior risco técnico do projeto (Build order 2). Provar em UM prédio antes de espalhar pela cidade.*

- [ ] Existe um componente reutilizável de "destrutível" que pode ser colocado em qualquer objeto da cidade (prédio, loja, banco, poste etc.)
- [ ] Cada destrutível tem três estágios: intacto, danificado e destruído, cada um com sua própria versão modelada
- [ ] O destrutível reage ao evento de impacto do canhão (story 003)
- [ ] Quantos tiros mudam de estágio é um valor em dados externos, configurável por tipo de objeto
- [ ] Ao mudar de estágio o modelo é trocado na hora; não há fratura física em tempo real (fora de escopo no brief)
- [ ] No estágio destruído o objeto não bloqueia o tanque mais do que os escombros dele
- [ ] Um tiro em um objeto já destruído não quebra nada nem gera erro
- [ ] Prova em um cenário com um único prédio, rodando a 60 fps no alvo Web

---

## Implementation Notes

- Estágios por troca de modelo/cena, não física de fratura. Mantém o escopo viável.
- Reagir ao sinal de impacto da story 003; não acoplar o canhão ao destrutível.
- Escombros e crateras ficam na story 006.

---

## Out of Scope

- Story 005: aplicar o componente a toda a cidade
- Story 006: marcas permanentes (crateras, fumaça, escombros espalhados)

---

## Files

- `src/destruction/destructible.gd`
- `src/destruction/destructible_tuning.tres`
- `src/test_levels/single_building.tscn`
- `tests/integration/destruction/destruction_stages_test.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above.*

---

## Test Evidence

**Story Type**: Integration
**Required evidence**: `tests/integration/destruction/destruction_stages_test.gd` OU um playtest documentado (testes dispensados em `qa.level: minimal`)

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/porto-sereno/story-003-canhao-mira-disparo.md`
- Unlocks: `production/epics/porto-sereno/story-005-cidade-costeira-completa.md`, `production/epics/porto-sereno/story-006-marcas-permanentes.md`
