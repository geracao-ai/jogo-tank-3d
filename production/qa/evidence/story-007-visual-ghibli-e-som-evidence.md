# Test Evidence: Visual Ghibli e som

> **Story**: `production/epics/porto-sereno/story-007-visual-ghibli-e-som.md`
> **Story Type**: Visual/Feel
> **Date**: 2026-11-01
> **Tester**: Lucas Silva (hands-on run on Android); Claude Code (simulated input, captures and Web builds)
> **Build / Commit**: uncommitted working tree on `main`; see `production/qa/evidence/story-007-visual-ghibli-e-som/stamp.txt`

---

## What Was Tested

O visual toon, o céu de aquarela e o som, numa build Web de release. O desenvolvedor jogou no Android e aprovou: "Som e visual ficaram bons", e depois confirmou que o ronco do tanque toca e sobe de tom ao acelerar ("Sim, aprovo").

**Acceptance criteria covered**: AC-1 a AC-9. AC-8 falha por até 2,7 fps, aceito pelo desenvolvedor.

---

## Acceptance Criteria Results

| # | Criterion (from story) | Result | Notes |
|---|----------------------|--------|-------|
| AC-1 | A cidade, o tanque e o mar usam um toon shader com cores suaves | PASS | Imagens 1 a 3; aprovado no Android |
| AC-2 | O céu tem aparência de pintura (aquarela), não um céu realista | PASS | Imagens 1 e 3 |
| AC-3 | O visual funciona no renderizador Compatibility, no alvo Web | PASS | Chromium no Mac e Chrome no Android |
| AC-4 | Há um som ambiente contínuo de mar e cigarras | PASS | Aprovado no Android |
| AC-5 | O disparo do canhão toca um som seco e alto, que contrasta com o ambiente sereno | PASS | Aprovado no Android |
| AC-6 | A explosão ao atingir um alvo tem som e efeito visual próprios | PASS | Aprovado no Android |
| AC-7 | Os três estágios de destruição e as marcas mantêm o mesmo estilo | PASS | Imagem 2 |
| AC-8 | O jogo mantém 60 fps no alvo Web com o visual final | FAIL | Android: 57,3 a 60,1 fps, mediana de 60. Aceito pelo desenvolvedor |
| AC-9 | O volume do som pode ser ajustado ou silenciado | PASS | Tecla M, botão na tela e volume em dados; testado no desktop |

---

## Screenshots / Video

| # | Filename | What It Shows | Acceptance Criterion |
|---|----------|--------------|----------------------|
| 1 | `story-007-visual-ghibli-e-som/01-cidade-final.png` | Cidade em toon, céu de aquarela e botão de mudo | AC-1, AC-2 |
| 2 | `story-007-visual-ghibli-e-som/02-destruicao-final.png` | Estágios, crateras e fumaça na mesma paleta | AC-7 |
| 3 | `story-007-visual-ghibli-e-som/03-web-chromium.png` | Build Web de release em Chromium com WebGL 2 | AC-3 |

Relatórios de desempenho: `story-007-visual-ghibli-e-som/web-fps-android.json` e `web-fps-mac.json` (este, do Mac, é anterior ao ronco).

---

## Test Conditions

- **Game state at start**: cena `src/test_levels/porto_sereno.tscn`; o medidor também cobre a cidade inteira danificada e 60 crateras
- **Platform / hardware**: Android com Chrome 156, canvas 1339×568; macOS arm64 com M1 Pro e Chromium 151
- **Framerate during test**: Android 57,3 a 60,1 fps, pior frame 156,6 ms
- **Any special setup required**: o teste de desempenho usou uma cópia temporária com medidor de frames

---

## Observations

- O engasgo de meio segundo não apareceu nesta medição, mas apareceu em outras; a causa segue desconhecida.
- O ronco é grave, mas o alto-falante do celular corta a base, então parte do corpo vem dos harmônicos.
- Os sons são sintéticos e provisórios. O céu é estático.

---

## Sign-Off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Lead (art-director / designer) | Lucas Silva | 2026-11-01 | [x] Approved |

*Template: `.claude/docs/templates/test-evidence.md`*
*Location: `production/qa/evidence/[story-slug]-evidence.md`*
