# Campo de batalha inicial (Roblox)

Arena preta vista de cima, com uma linha clara horizontal dividindo os territórios. O protótipo inclui árvores nos cantos e formações estáticas de círculos, quadrados e triângulos em azul e vermelho para servir de referência visual.

## Instalação no Roblox Studio

1. Em `ServerScriptService`, crie ou abra o **Script** `BattleField` e cole [Battlefield.server.lua](scripts/Battlefield.server.lua).
2. Em `StarterPlayer > StarterPlayerScripts`, crie ou abra o **LocalScript** `BattleFieldCamera` e cole [BattlefieldCamera.client.lua](scripts/BattlefieldCamera.client.lua).
3. Pressione **Jogar** para visualizar.

O campo mede 700 por 520 studs. O modelo do campo é mantido disponível para o cliente mesmo quando o carregamento por distância está ativo.
