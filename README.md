# SEEDS — Jogo 2D

Projeto de desenvolvimento de jogo 2D utilizando Godot Engine e GDScript, com foco em combate, movimentação de personagens, inimigos e confrontos contra chefes.

## Sobre o projeto

O jogo apresenta um personagem explorando cenários em estilo pixel art, enfrentando inimigos e utilizando diferentes ações durante o combate. A jogabilidade inclui gerenciamento de vida e stamina, ataques, esquiva e uma arena dedicada ao confronto com um chefe.

O projeto também explora animações, detecção de colisões, inteligência de inimigos e transição entre cenas.

## Funcionalidades

- Movimentação horizontal e pulo.
- Ataques que consomem stamina.
- Esquiva com consumo de stamina.
- Barras de vida e stamina.
- Inimigos com movimentação, perseguição e ataques.
- Sistema de dano, empurrão e animações de combate.
- Chefe com diferentes comportamentos de combate.
- Arena com sequência de introdução ao confronto.
- Portais para transição entre cenas.
- Cenários com camadas de fundo e recursos visuais em pixel art.

## Tecnologias utilizadas

- **Godot Engine 4.x** — criação e execução do jogo.
- **GDScript** — programação da lógica de jogo.
- **Pixel art** — estilo visual dos personagens e cenários.

A configuração atual do projeto declara compatibilidade com Godot 4.7.

## Como executar

1. Baixe ou clone este repositório:

   ```bash
   git clone https://github.com/Luan-Silva-Ramos/SEEDS-godot.git
   ```

2. Abra o Godot Engine.
3. Na tela de projetos, escolha a opção para importar ou abrir um projeto existente.
4. Selecione o arquivo `project.godot` dentro da pasta do projeto.
5. Aguarde a importação dos recursos e pressione **F6** para executar a cena atual ou **F5** para iniciar pela cena principal configurada.

## Controles

| Tecla ou botão | Ação |
|---|---|
| `A` / `D` | Mover para a esquerda / direita |
| `W` ou `ESPAÇO` | Pular |
| `E` ou botão esquerdo do mouse | Atacar |
| `SHIFT` | Esquivar |

## Estrutura do projeto

```text
SEEDS-godot/
├── Art Assets/       # Personagens, cenários e recursos visuais
├── scenes/           # Cenas do jogo
│   ├── world.tscn
│   ├── player.tscn
│   ├── enemies.tscn
│   ├── boss.tscn
│   ├── arenaboss.tscn
│   └── portal.tscn
├── scripts/          # Lógica e comportamentos
│   ├── player.gd
│   ├── enemies.gd
│   ├── boss.gd
│   ├── arena_trigger.gd
│   └── portal.gd
├── icon.svg
└── project.godot
```

## Conceitos praticados

- Organização de projetos por cenas e scripts.
- Programação orientada a objetos com GDScript.
- Máquinas de estados para controlar ações e comportamentos.
- Física 2D, colisões e áreas de detecção.
- Animação de personagens.
- Gerenciamento de vida, dano e stamina.
- Comunicação entre cenas e transição de fases.

## Créditos e licenças

O projeto reúne recursos visuais de diferentes pacotes. Os créditos e as condições de uso devem ser respeitados conforme as licenças incluídas nos respectivos diretórios.

O pacote de cenário *Parallax Demon Woods* identifica **David Marah** como autor e informa que a atribuição é apreciada, embora não obrigatória.

O diretório de efeitos visuais *Dark Fantasy Ambient VFX* também inclui arquivos próprios de licença e divulgação. Consulte esses documentos antes de redistribuir os recursos ou utilizar o projeto em outros contextos.

## Estado do projeto

Projeto em desenvolvimento, voltado à prática de desenvolvimento de jogos 2D com Godot Engine, GDScript, combate e organização de cenas.
