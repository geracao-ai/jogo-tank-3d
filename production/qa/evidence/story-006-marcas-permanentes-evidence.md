# Test Evidence: Marcas permanentes

> **Story**: `production/epics/porto-sereno/story-006-marcas-permanentes.md`
> **Story Type**: Visual/Feel
> **Date**: 2026-10-31
> **Tester**: Lucas Silva (hands-on run on Android); Claude Code (simulated shots and captures)
> **Build / Commit**: uncommitted working tree on `main`; see `production/qa/evidence/story-006-marcas-permanentes/stamp.txt`

---

## What Was Tested

Crateras no chão, escombros e fumaça nos objetos danificados e destruídos, na cidade. O desenvolvedor jogou no Android, confirmou que as marcas ficam e reaparecem ao voltar ao lugar, e depois aprovou a fumaça nova: "Sim, aprovo".

**Acceptance criteria covered**: AC-1 a AC-7. AC-7 falha por 1,4 fps, aceito pelo desenvolvedor.

---

## Acceptance Criteria Results

| # | Criterion (from story) | Result | Notes |
|---|----------------------|--------|-------|
| AC-1 | Cada impacto do canhão deixa uma cratera no chão onde atingiu | PASS | Tiros reais na cidade; impactos em paredes e objetos não deixam cratera |
| AC-2 | Objetos que chegam ao estágio destruído deixam escombros no lugar | PASS | Imagem 1 |
| AC-3 | Objetos danificados ou destruídos emitem fumaça contínua | PASS | Imagem 1; um emissor por objeto |
| AC-4 | As marcas persistem até o jogo ser fechado; não somem sozinhas com o tempo | PASS | Confirmado no Android; só o teto de 60 crateras reaproveita as mais antigas |
| AC-5 | Voltar a um lugar já visitado mostra as marcas feitas antes | PASS | Confirmado no Android |
| AC-6 | Não há sistema de save | PASS | Sem persistência entre sessões |
| AC-7 | Muitas marcas acumuladas não derrubam o jogo abaixo de 60 fps no alvo Web | FAIL | Pior caso: 58,6 fps, 27 de 470 frames acima de 20 ms. Aceito pelo desenvolvedor |

---

## Screenshots / Video

| # | Filename | What It Shows | Acceptance Criterion |
|---|----------|--------------|----------------------|
| 1 | `story-006-marcas-permanentes/01-marcas-na-cidade.png` | Crateras no chão, entulho e fumaça saindo de objetos danificados e destruídos | AC-1, AC-2, AC-3 |

Relatórios de desempenho no Android: `story-006-marcas-permanentes/web-fps-android.json` (fumaça de planos) e `web-fps-android-esferas.json` (fumaça de esferas, antes da correção).

---

## Test Conditions

- **Game state at start**: cena `src/test_levels/porto_sereno.tscn`; no teste de desempenho, cidade inteira danificada e 60 crateras
- **Platform / hardware**: Android com Chrome 156, canvas 1339×568; macOS arm64 para as capturas
- **Framerate during test**: 56,3 a 60,1 fps; pior caso 58,6 fps
- **Any special setup required**: o teste de desempenho usou uma cópia temporária com medidor de frames

---

## Observations

- Com esferas, o pior caso era 50,9 fps e 37.416 primitivas; com planos, 58,6 fps e 8.564.
- Dois cenários sem marcas tiveram um engasgo de cerca de 550 ms cada. Sem ele, ficariam em 60 fps. Causa desconhecida; apareceu também na medição da história 005b.
- Os prédios danificam um a um jogando, então o pior caso medido é improvável.
- A fumaça reinicia ao passar de danificado para destruído.

---

## Sign-Off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Lead (art-director / designer) | Lucas Silva | 2026-10-31 | [x] Approved |

*Template: `.claude/docs/templates/test-evidence.md`*
*Location: `production/qa/evidence/[story-slug]-evidence.md`*
