# Campo de batalha inicial (Roblox)

Estes scripts geram o primeiro campo de batalha do projeto. Eles são mantidos como arquivos Lua no GitHub e precisam ser colocados manualmente no Roblox Studio; este repositório ainda não tem configuração do Rojo.

## Instalação no Roblox Studio

1. Abra `JOGO.rbxl` no Roblox Studio.
2. Em `ServerScriptService`, crie um **Script** chamado `Battlefield` e cole o conteúdo de [Battlefield.server.lua](scripts/Battlefield.server.lua).
3. Em `StarterPlayer > StarterPlayerScripts`, crie um **LocalScript** chamado `BattlefieldCamera` e cole o conteúdo de [BattlefieldCamera.client.lua](scripts/BattlefieldCamera.client.lua).
4. Pressione **Play** para gerar e visualizar o tabuleiro.

O script do servidor cria um tabuleiro de 24 por 14 casas, com os territórios divididos ao meio, árvores, rochas e um trecho de rio. A câmera é configurada pelo LocalScript do jogador.

Para atualizar o arquivo do jogo no GitHub depois de editar no Studio, salve uma nova cópia do `.rbxl` e envie-a pelo fluxo de GitHub usado pela equipe.
