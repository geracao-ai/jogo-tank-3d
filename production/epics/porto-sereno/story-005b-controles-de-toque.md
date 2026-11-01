# Story 005b: Controles de toque no Android

> **Epic**: porto-sereno
> **Status**: Ready
> **Layer**: N/A (minimal)
> **Type**: UI
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: [set by /dev-story when implementation begins]

## Context

**GDD**: `design/game-brief.md`
**Requirement**: Brief, pós-MVP — controles de toque para jogar no Chrome do Android sem teclado nem gamepad

**ADR Governing Implementation**: N/A (minimal — no ADRs)
**ADR Decision Summary**: N/A (minimal — no ADRs)
**ADR Version**: N/A (minimal — no ADRs)

**Engine**: Godot 4.7 | **Risk**: HIGH (docs/engine-reference/godot/VERSION.md: 4.7 é pós-cutoff)
**Engine Notes**: none (no ADR engine-compatibility analysis at minimal). `docs/engine-reference/godot/modules/input.md` cita o nó `VirtualJoystick` (modos Fixed, Dynamic e Following); conferir antes de usar. A referência não diz se o acelerômetro do celular funciona na exportação web.

**Control Manifest Rules (this layer)**: N/A (minimal — no control manifest)

---

## Acceptance Criteria

*Pedido do desenvolvedor após testar no Android com teclado Bluetooth. Depois da cidade (story 005), para ajustar nas ruas de verdade.*

- [ ] Um joystick virtual à esquerda dirige o tanque: acelera, vira e anda de ré, com a mesma física do teclado
- [ ] Arrastar o polegar na metade direita da tela mira o canhão, sem depender de cursor de mouse
- [ ] Um botão na tela dispara, respeitando a recarga existente
- [ ] Um botão na tela freia
- [ ] Dirigir, mirar e atirar funcionam ao mesmo tempo, com vários dedos
- [ ] Os controles de toque só aparecem em aparelhos com tela de toque; teclado, mouse e gamepad continuam funcionando como antes
- [ ] Os controles ficam ao alcance dos polegares e não cobrem o tanque, em celular na horizontal
- [ ] Tamanhos, posições e sensibilidade ficam em dados externos
- [ ] O jogo roda na exportação Web no Chrome do Android, mantendo 60 fps na cidade

---

## Implementation Notes

- Começar pelo `VirtualJoystick` do Godot 4.7, se ele atender; conferir `docs/engine-reference/godot/modules/input.md`.
- Reaproveitar as ações existentes (`tank_forward`, `tank_back`, `tank_left`, `tank_right`, `tank_brake`, `cannon_fire`) em vez de criar outro caminho de entrada.
- A mira hoje vem do cursor em `src/vehicle/cannon.gd`; por toque ela precisa de outra fonte.
- A mira na tela (`src/ui/crosshair.gd`) segue o cursor e precisa acompanhar a mira por toque.
- Testar em aparelho real, por exemplo com túnel HTTPS; o desktop não prova toque.

---

## Out of Scope

- Acelerômetro: possível opção futura, depende de verificar o suporte na exportação web
- Remapeamento de controles pelo jogador
- App nativo Android ou iOS; o alvo segue sendo o navegador

---

## Files

- `src/ui/touch_controls.gd`
- `src/ui/touch_controls.tscn`
- `src/ui/touch_controls_tuning.tres`
- `src/vehicle/cannon.gd`
- `src/ui/crosshair.gd`

---

## QA Test Cases

*N/A — no qa-lead specs at this tier; implement against the Acceptance Criteria above.*

---

## Test Evidence

**Story Type**: UI
**Required evidence**: um screenshot retido em `production/qa/evidence/story-005b-controles-de-toque/` mostrando os controles na tela

**Status**: [ ] Not yet created

---

## Dependencies

- Depends on: `production/epics/porto-sereno/story-005-cidade-costeira-completa.md`
- Unlocks: None
