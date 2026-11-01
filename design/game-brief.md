# Game Brief: Porto Sereno

**One-sentence pitch:** Dirija um tanque por uma cidade costeira serena no estilo Ghibli e veja cada tiro seu mudar para sempre aquela paisagem tão bonita.

## Core loop
- Dirigir pelas ruas e encontrar algo que chame a atenção
- Mirar e atirar em qualquer coisa
- Ver a cidade mudar, com escombros, fumaça e crateras que não somem
- Seguir em frente pela paisagem que você acabou de alterar

## Player goal & fail state — what "working" looks like
- Objetivo: explorar e decidir por conta própria o que preservar e o que destruir. Não há pontuação.
- Não há derrota. Uma sessão parece completa quando o jogador olha para trás e vê uma cidade visivelmente diferente por causa dele.

## MVP — what must exist to be the game
- Tanque que acelera, freia, vira e anda de ré
- Câmera em terceira pessoa que segue o tanque
- Uma cidade com ruas, lojas, prédios, banco e mar
- Canhão com mira e disparo
- Tudo na cidade é destrutível, em estágios: intacto → danificado → destruído
- Marcas permanentes durante a sessão: crateras, escombros e fumaça
- Visual Ghibli e som: toon shader, céu pintado, ambiente sereno, disparo e explosão

## Out of scope — not building this
- Pedestres e outros carros
- Pontuação, missões, inimigos e derrota
- Save entre sessões
- Fratura física em tempo real
- Multiplayer
- Mais de uma cidade ou mais de um veículo
- Entrar em prédios ou no mar

## Build order
1. Tanque dirigindo em um cenário cinza, para provar que é gostoso de guiar
2. Canhão e um prédio com os três estágios de destruição, para provar a parte mais arriscada
3. Cidade completa em blocos simples, com tudo destrutível
4. Controles de toque para Android (pós-MVP, pedido após testar no celular)
5. Marcas permanentes: crateras, escombros e fumaça
6. Visual Ghibli
7. Áudio

---
**Who it's for / what they feel:** Quem gosta de passear sem pressa em mundos bonitos; sente calma, depois o prazer da destruição, depois um pouco de culpa.

**Art & audio direction:** Cidade pintada à mão no estilo Ghibli, com cores suaves e céu de aquarela; ambiente de mar e cigarras, cortado pelo estrondo seco do canhão.

**Reference game:** Teardown: o prazer de destruir livremente um cenário que continua alterado; sem voxels, sem física de fratura e sem missões.
