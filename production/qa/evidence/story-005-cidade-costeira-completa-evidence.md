# Test Evidence: Cidade costeira completa

> **Story**: `production/epics/porto-sereno/story-005-cidade-costeira-completa.md`
> **Story Type**: Visual/Feel
> **Date**: 2026-10-31
> **Tester**: Lucas Silva (hands-on run); Claude Code (simulated-input measurements and captures)
> **Build / Commit**: uncommitted working tree on `main`; see `production/qa/evidence/story-005-cidade-costeira-completa/stamp.txt`

---

## What Was Tested

A cidade gerada a partir de `src/world/porto_sereno_city.json`. O desenvolvedor jogou e relatou: "joguei ficou bom". As medições vêm de uma execução com entrada simulada e de builds Web de release, no Android e no Mac.

**Acceptance criteria covered**: AC-1 a AC-9.

---

## Acceptance Criteria Results

| # | Criterion (from story) | Result | Notes |
|---|----------------------|--------|-------|
| AC-1 | Existe uma cidade em uma cena única com ruas navegáveis pelo tanque | PASS | As 8 ruas percorridas, 151,8 m cada, 0 travadas |
| AC-2 | A cidade tem lojas, prédios e um banco, reconhecíveis entre si | PASS | 12 lojas, 13 prédios e 1 banco, com etiquetas |
| AC-3 | A cidade é costeira: há mar junto à cidade, visível das ruas | PASS | Imagens 2 e 4 |
| AC-4 | O mar é só paisagem: o tanque não entra nele | PASS | Parou em x=90, antes da margem em x=92 |
| AC-5 | Prédios não podem ser acessados por dentro | PASS | Blocos sólidos; o tanque para na parede |
| AC-6 | Não há pedestres nem outros carros | PASS | Imagens 1 a 5 |
| AC-7 | Lojas, prédios, banco e demais objetos usam o componente destrutível da story 004 | PASS | 26 objetos; um de cada tipo destruído por tiros simulados |
| AC-8 | A cidade roda a 60 fps no alvo Web com tudo intacto | PASS | Android Chrome 156: 60,1 fps; Mac: 75,0 fps. Ver relatórios |
| AC-9 | A câmera da story 002 não atravessa os prédios | PASS | 0 frames com parede entre tanque e câmera em 8.580 |

---

## Screenshots / Video

| # | Filename | What It Shows | Acceptance Criterion |
|---|----------|--------------|----------------------|
| 1 | `story-005-cidade-costeira-completa/01-rua.png` | Tanque na rua, prédios e lojas com etiquetas | AC-1, AC-2 |
| 2 | `story-005-cidade-costeira-completa/02-mar.png` | Mar visível da rua leste | AC-3 |
| 3 | `story-005-cidade-costeira-completa/03-banco.png` | Banco com placa e etiqueta | AC-2 |
| 4 | `story-005-cidade-costeira-completa/04-visao-geral.png` | Visão geral da cidade e do mar | AC-1, AC-3 |
| 5 | `story-005-cidade-costeira-completa/05-destruicao-na-cidade.png` | Objetos intactos, danificados e em entulho | AC-7 |

Relatórios de desempenho: `story-005-cidade-costeira-completa/web-fps-android.json` e `web-fps-mac.json`.

---

## Test Conditions

- **Game state at start**: cena `src/test_levels/porto_sereno.tscn`
- **Platform / hardware**: Android com Chrome 156 (modelo do aparelho não informado pelo navegador); macOS arm64 com M1 Pro e Chromium 151
- **Framerate during test**: Android 60,1 fps em todos os cenários, pior frame 30,4 ms; Mac 75,0 fps, pior frame 21,4 ms
- **Any special setup required**: as medições usaram uma cópia temporária com medidor de frames, fora do repositório

---

## Observations

- Os valores presos em 60 e 75 fps sugerem o limite da tela, então mostram que o alvo foi atingido, não a folga real.
- No Android, com a cidade intacta e parada, 9 de 480 frames passaram de 20 ms.
- A quantidade de tiros por tipo foi definida pelo agente e aceita no teste: prédio 4, loja 2, banco 6.
- Paredes invisíveis nas quatro bordas podem aproximar a câmera quando o tanque encosta nelas.
- Não foi registrado em qual aparelho o desenvolvedor jogou.

---

## Sign-Off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Lead (art-director / designer) | Lucas Silva | 2026-10-31 | [x] Approved |

*Template: `.claude/docs/templates/test-evidence.md`*
*Location: `production/qa/evidence/[story-slug]-evidence.md`*
