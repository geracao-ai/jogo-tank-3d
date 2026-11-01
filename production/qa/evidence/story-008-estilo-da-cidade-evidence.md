# Test Evidence: Estilo da cidade

> **Story**: `production/epics/porto-sereno/story-008-estilo-da-cidade.md`
> **Story Type**: Visual/Feel
> **Date**: 2026-11-01
> **Tester**: Lucas Silva (jogou a build final no Android); Claude Code (capturas, testes de colisão, builds Web e medições)
> **Build / Commit**: árvore de trabalho sem commit em `main`; ver `production/qa/evidence/story-008-estilo-da-cidade/stamp.txt`

---

## What Was Tested

A cidade com modelos do kit CC0 da Kenney (City Kit Suburban e Nature Kit), o tanque novo, as ruínas recortadas dos próprios modelos, as árvores, postes e barcos derrubáveis, os morros, as nuvens e o desempenho no Android. O desenvolvedor aprovou o estilo ("o estilo agradou, bem sereno") e, ao fechar a história, aprovou o visual completo, incluindo o tanque novo.

**Acceptance criteria covered**: AC-1 a AC-10 (AC-9 é o desempenho, aceito pelo desenvolvedor com a ressalva abaixo).

---

## Acceptance Criteria Results

| # | Criterion (from story) | Result | Notes |
|---|----------------------|--------|-------|
| AC-1 | Prédios, lojas e banco usam modelos com forma real | PASS | Imagens 1, 3 e 6 |
| AC-2 | Licença CC0 registrada no repositório | PASS | `assets/models/suburban/License.txt` e `assets/models/nature/License.txt` |
| AC-3 | Vegetação: árvores e arbustos | PASS | Imagens 1, 2 e 4 |
| AC-4 | Postes com fios, cercas, barcos e cais | PASS | Imagens 1 e 2 |
| AC-5 | Morros no fundo e nuvens grandes | PASS | Imagens 4 e 5 |
| AC-6 | Cor variada, aparência pintada e contraste com o céu | PASS | Imagens 1 e 5 |
| AC-7 | Estágios danificado e destruído funcionam, com colisão correta | PASS | Imagem 4; teste de colisão nos 26 lotes: sem falhas nos 3 estágios |
| AC-8 | Cidade gerada a partir do arquivo de dados | PASS | `src/world/porto_sereno_city.json` |
| AC-9 | Desempenho no Android no nível aceito na história 007 | PASS (aceito) | Jogando: 56,2 a 60,1 fps, 60,1 em 17 de 20 janelas. Veja Observations |
| AC-10 | Tanque com estilo próprio, sem mudar colisão nem direção | PASS | Imagens 1, 3 e 4; `tank.gd` só ganhou a queda de adereços |

---

## Screenshots / Video

| # | Filename | What It Shows | Acceptance Criterion |
|---|----------|--------------|----------------------|
| 1 | `story-008-estilo-da-cidade/01-rua.png` | Rua com casas, cercas, postes com fios, árvores e o tanque novo | AC-1, AC-3, AC-4, AC-6, AC-10 |
| 2 | `story-008-estilo-da-cidade/02-orla.png` | Orla com palmeiras, barcos, cais e mar | AC-3, AC-4 |
| 3 | `story-008-estilo-da-cidade/03-tanque.png` | Tanque de perto, com esteiras, rodas e torre | AC-1, AC-10 |
| 4 | `story-008-estilo-da-cidade/04-ruinas-e-arvores-caidas.png` | Prédios danificados e destruídos, árvores e postes caídos, fumaça | AC-5, AC-7 |
| 5 | `story-008-estilo-da-cidade/05-web-chromium.png` | Build Web de release em Chromium com WebGL 2 | AC-5, AC-6 |
| 6 | `story-008-estilo-da-cidade/06-banco.png` | Banco com colunas e placa | AC-1 |

Relatórios de desempenho no Android, em `story-008-estilo-da-cidade/`: `web-fps-android-jogando.json` (build final), `web-fps-android-parado.json` e `web-fps-android-isolamento.json` (anteriores aos cortes de chamadas de desenho).

---

## Test Conditions

- **Game state at start**: cena `src/test_levels/porto_sereno.tscn`
- **Platform / hardware**: Android com Chrome 156, canvas 1339×568; macOS arm64 com M1 Pro e Chromium
- **Framerate during test**: Android, jogando com toque: 56,2 a 60,1 fps
- **Any special setup required**: o medidor de fps usou uma cópia temporária do projeto

---

## Observations

- Parado e sem tocar na tela, antes dos cortes de chamadas de desenho, a cena fazia cerca de 48 fps; a cidade inteira em ruínas fazia cerca de 40. Esses dois casos não foram medidos de novo depois dos cortes.
- A primeira janela jogando fez 56,2 fps, com um engasgo de 267 ms.
- Cercas e cais não têm colisão: o tanque e os tiros passam por eles.
- O toldo das lojas só foi visto de longe.

---

## Sign-Off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Lead (art-director / designer) | Lucas Silva | 2026-11-01 | [x] Approved |

*Template: `.claude/docs/templates/test-evidence.md`*
*Location: `production/qa/evidence/[story-slug]-evidence.md`*
