# Campo de batalha inicial (Roblox)

O campo é uma arena preta, vista de cima, com uma linha branca horizontal dividindo as metades. O personagem do jogador não aparece.

## Instalação no Roblox Studio

1. Abra `JOGO.rbxl` no Roblox Studio.
2. Em `ServerScriptService`, crie um **Script** chamado `BattleField` e cole o conteúdo de [Battlefield.server.lua](scripts/Battlefield.server.lua).
3. Em `StarterPlayer > StarterPlayerScripts`, crie um **LocalScript** chamado `BattleFieldCamera` e cole o conteúdo de [BattlefieldCamera.client.lua](scripts/BattlefieldCamera.client.lua).
4. Pressione **Jogar** para gerar e visualizar o tabuleiro.

O campo mede 700 por 520 studs. O script mantém o modelo do campo disponível para o cliente mesmo quando o carregamento por distância do Roblox estiver ativo, e desativa os efeitos de iluminação que clareavam o piso.
