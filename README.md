# Loja dentro do jogo (FiveM)

O jogador digita `/loja` no servidor, escolhe os produtos, paga pelo celular
lendo um QR e recebe a entrega sem sair do jogo.

É a mesma loja do site: preço, estoque, cupom, limites do plano e entrega
saem da Nexify. O script não guarda catálogo nem preço.

## Instalação

1. Copie a pasta para `resources/nexify-loja`.
2. Adicione `ensure nexify-loja` no `server.cfg`.
3. Abra `config.lua` e cole o **token da loja** (Painel → Configurações →
   Integrações → Token). Ele fica só no servidor; o jogador nunca recebe esse
   valor.
4. Reinicie o servidor.

Só isso. A base do seu servidor é reconhecida sozinha.

## As duas metades

Este resource faz duas coisas, e cada uma liga ou desliga sozinha:

- **Entrega** (`entregarNesteServidor`) — executa as compras aprovadas,
  venham do site ou do jogo. É a mesma fila e os mesmos eventos
  `fivemarket:*` do resource oficial: os handlers do seu `server/config.lua`
  continuam valendo sem mudar nada.
- **Loja no jogo** (`lojaNoJogo`) — o `/loja`, a janela e o QR.

Quem quer só vender pelo site desliga a segunda. Quem já usa o resource
`nexify` não precisa desligar a primeira: ao ver o outro no ar, este se cala
sozinho para não entregar em dobro.

## Configuração

Tudo o que você normalmente mexe está no `config.lua`:

| Campo | Para que serve |
|---|---|
| `token` | Token da loja, no painel da Nexify |
| `entregarNesteServidor` | Executa as compras aprovadas neste servidor |
| `mostrarEntregaNoConsole` | Escreve cada entrega no console |
| `lojaNoJogo` | Liga a loja dentro do jogo |
| `comando` | Comando que abre a loja (padrão: `loja`) |
| `tecla` | Tecla de atalho (padrão: `F6`). Deixe `''` para não registrar |
| `mostrarIdentificadorNoConsole` | Escreve no console o ID usado em cada compra |

A cor da janela é a cor da sua loja, definida no painel. Ela chega junto com
o catálogo — trocou no painel, trocou no jogo, sem editar arquivo.

## Quem recebe a entrega

O identificador do comprador sai do servidor, nunca do jogador, e é o mesmo
que os seus comandos de entrega já recebem.

O `adaptadores.lua` descobre isso sozinho, nesta ordem:

1. **Bases conhecidas** — vRP (1 e 2), QBCore, Qbox, ESX e ND_Core.
2. **Bases próprias** — procura os nomes de export mais usados
   (`getUserId`, `getPlayerId`, `getPassaporte`, `getIdentifier`…) nos
   recursos que costumam guardar o core.
3. **Steam / license / discord**, para servidores sem framework.

Você não precisa mexer nisso: o `adaptadores.lua` vem protegido (ofuscado) e
funciona sozinho. Quando precisar ajustar algo, é sempre no `config.lua`.

### Se não achar sozinho

Com o jogador conectado, rode no **console do servidor**:

```
nexifyid 1
```

(o `1` é o id do jogador). Ele mostra qual identificador sairia numa compra,
**o que foi tentado e por que cada tentativa falhou**, e os identificadores
nativos do jogador. Quando uma compra falha, esse mesmo relato sai sozinho no
console.

Aí sim abra o `config.lua` e preencha o **AJUSTE MANUAL** (no fim do arquivo)
— uma das três formas, a que a sua base usar:

```lua
AjusteManual = {
    -- por export: exports['recurso']:metodo(source)
    exportRecurso = 'minhabase',
    exportMetodo = 'getUserId',

    -- ou por evento com função de retorno
    eventoNome = '',
    eventoEspera = 2000,

    -- ou na mão
    naMao = nil
}
```

O ajuste manual sempre vence o automático.

## Como funciona a entrega

A cada 10 segundos o script pergunta à Nexify se há compra aprovada
esperando. Quando há, dispara os eventos do produto e só então confirma.

Se o servidor cair no meio, **o pedido volta para a fila** — a confirmação é
o último passo justamente para isso. Melhor entregar de novo do que dar por
entregue algo que não saiu.

Os handlers ficam no seu `server/config.lua`, como sempre. Cada evento
recebe `(comprador, argumento, referência do pedido)`:

```lua
AddEventHandler('fivemarket:addMoney', function(comprador, valor)
    -- comprador aqui é o passaporte, o citizenid ou o identifier,
    -- conforme a base do seu servidor
end)
```

Se o evento não existir na sua base, a compra é aprovada e **nada acontece**,
sem erro — o FiveM ignora `TriggerEvent` de evento que ninguém escuta. Por
isso vale deixar `mostrarEntregaNoConsole` ligado até a primeira venda.

## Como funciona a compra

1. O jogador abre a loja e monta o carrinho.
2. O servidor do jogo pede o pagamento à Nexify, com o token e o
   identificador do comprador.
3. A janela mostra o QR. O jogador paga pelo celular.
4. A cada 5 segundos o jogo pergunta se o pagamento caiu. Quando cai, a
   entrega acontece pelo caminho normal da Nexify e o jogador vê o aviso na
   tela.

Produto gratuito não gera QR: sai entregue na hora.

## Segurança

- O token vive apenas no `server.lua`; a interface nunca o recebe.
- Preço, desconto, cupom e estoque são calculados pela Nexify. O que vem do
  jogo é só a escolha: quais produtos e quantas unidades.
- Loja suspensa, vencida ou em manutenção não vende, aqui como no site.
- Um pedido só pode ser consultado com o token da loja dele.
- Cada jogador pode fazer uma chamada por segundo.
- A busca por bases próprias só olha recursos com cara de core e chama tudo
  protegido: erro em script de terceiro não derruba a compra.
- `nexifyid` só responde no console do servidor ou para quem tem a permissão
  ACE `nexify.loja`.
- `server.lua`, `entrega.lua` e `adaptadores.lua` vêm **ofuscados** — não
  precisa (nem dá pra) editá-los. Tudo o que você ajusta fica no `config.lua`,
  que é aberto. Não altere os arquivos ofuscados: o resource para de funcionar.

## Problemas comuns

| O que aparece | O que é |
|---|---|
| "Falta colocar o token da loja no config.lua" no console | O token não foi preenchido |
| "Token da loja inválido" | Token errado ou trocado no painel |
| "Esta loja ainda não tem forma de pagamento configurada" | Configure Mercado Pago, PicPay, Stripe ou PayPal no painel |
| "Não conseguimos identificar você no servidor" | Rode `nexifyid` e preencha o AJUSTE MANUAL em `config.lua` |
| A loja abre vazia | Os produtos estão ocultos no painel; publique-os |

Os arquivos `.lua` são gravados sem acento de propósito: FiveM lê o console
em code page do Windows e acento vira caractere quebrado no editor e no log.
