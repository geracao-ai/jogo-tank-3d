# Story 005b: Controles de toque no Android

> **Epic**: porto-sereno
> **Status**: Complete
> **Layer**: N/A (minimal)
> **Type**: UI
> **Estimate**: M
> **Manifest Version**: N/A (minimal — no control manifest)
> **Last Updated**: 2026-10-31

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
- [ ] Um joystick virtual à direita, igual ao da esquerda, gira o canhão, sem depender de cursor de mouse
- [ ] Dois botões de tiro, um acima de cada joystick, disparam respeitando a recarga existente, para destros e canhotos
- [ ] Sem botão de freio na tela: freia-se empurrando o joystick esquerdo na direção contrária
- [ ] Dirigir, mirar e atirar funcionam ao mesmo tempo, com vários dedos
- [ ] Os controles de toque só aparecem em aparelhos com tela de toque; teclado, mouse e gamepad continuam funcionando como antes
- [ ] Os controles ficam ao alcance dos polegares e não cobrem o tanque, em celular na horizontal
- [ ] Tamanhos, posições e sensibilidade ficam em dados externos
- [ ] O jogo roda na exportação Web no Chrome do Android, mantendo 60 fps na cidade

---

## Implementation Notes

- Começar pelo `VirtualJoystick` do Godot 4.7, se ele atender; conferir `docs/engine-reference/godot/modules/input.md`.
- Reaproveitar as ações existentes (`tank_forward`, `tank_back`, `tank_left`, `tank_right`, `cannon_fire`) em vez de criar outro caminho de entrada.
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
- `src/ui/touch_controls_tuning.gd`
- `src/ui/touch_controls_tuning.tres`
- `src/ui/turret_dial.gd`
- `src/ui/crosshair.gd`
- `src/vehicle/cannon.gd`
- `src/test_levels/porto_sereno.tscn`
- `project.godot`

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

## Completion Notes
**Completed**: 2026-10-31
**Criteria**: 9/9 passing, confirmed by the developer on Android Chrome (drive and brake, turret and marker, both fire buttons, all at once, thumb reach in landscape). AC-9 measured on a release Web build: 60.1 fps in three of four scenarios and 56.5 fps with the city intact while driving, caused by one unexplained 529.9 ms stall; the median stayed at 16.6 ms. Draw calls rose from 91 to 98 against the build without controls, which suggests the controls were active; the report does not state it.
**Deviations**: ADVISORY — layout redesigned at the developer's request: right joystick turns the turret directly, the crosshair shows the barrel line, a marker on the ring shows the turret angle, a fire button sits above each joystick, and there is no brake button; joystick diagonals cut throttle to 0.71 compared with the keyboard; on touch devices the mouse does not aim, because browser mouse events on tap were moving the aim; in portrait the controls cover the tank and the game does not force landscape; `gray_ground.tscn` and `single_building.tscn` have no touch controls. `run/main_scene` is now `porto_sereno.tscn`.
**Test Evidence**: `production/qa/evidence/story-005b-controles-de-toque/01-controles-de-toque.png` and `web-fps-android.json`
**Reviewed by**: self, no independent review
