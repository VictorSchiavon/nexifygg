/*
  A loja desenhada dentro do jogo.

  Este arquivo só mostra o que o servidor mandou e devolve a escolha do
  jogador. Preço, estoque e cupom quem confere é a Nexify — aqui os valores
  servem para o jogador enxergar o que está comprando.
*/

const janela = document.getElementById('janela');
const telaPagamento = document.getElementById('pagamento');
const vitrine = document.getElementById('vitrine');
const listaCategorias = document.getElementById('categorias');
const listaCarrinho = document.getElementById('itens-do-carrinho');
const carrinhoVazio = document.getElementById('carrinho-vazio');
const painelCarrinho = document.getElementById('carrinho');

let catalogo = { produtos: [], categorias: [] };
let categoriaAtual = null;
let carrinho = [];
let pedidoEmAberto = null;
let relogioDoPedido = null;

const dinheiro = (valor) =>
  new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(Number(valor) || 0);

const precoFinal = (produto) =>
  produto.precoComDesconto > 0 ? produto.precoComDesconto : produto.preco;

function avisar(texto) {
  document.getElementById('aviso').textContent = texto || '';
}

function nui(nome, dados) {
  return fetch(`https://${GetParentResourceName()}/${nome}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(dados || {})
  }).catch(() => {});
}

/* --------------------------------------------------------------- catálogo */


function desenharCategorias() {
  const usadas = new Set(catalogo.produtos.map((p) => p.categoria));
  const categorias = catalogo.categorias.filter((c) => usadas.has(c.referencia));

  listaCategorias.innerHTML = '';
  const todas = document.createElement('button');
  todas.type = 'button';
  todas.textContent = 'Tudo';
  todas.setAttribute('aria-current', categoriaAtual === null ? 'true' : 'false');
  todas.onclick = () => { categoriaAtual = null; desenharCategorias(); desenharProdutos(); };
  listaCategorias.appendChild(todas);

  categorias.forEach((categoria) => {
    const botao = document.createElement('button');
    botao.type = 'button';
    botao.textContent = `${categoria.icone || ''} ${categoria.nome}`.trim();
    botao.setAttribute('aria-current', categoriaAtual === categoria.referencia ? 'true' : 'false');
    botao.onclick = () => { categoriaAtual = categoria.referencia; desenharCategorias(); desenharProdutos(); };
    listaCategorias.appendChild(botao);
  });
}

function desenharProdutos() {
  const produtos = categoriaAtual
    ? catalogo.produtos.filter((p) => p.categoria === categoriaAtual)
    : catalogo.produtos;

  vitrine.innerHTML = '';

  if (!produtos.length) {
    const vazio = document.createElement('p');
    vazio.className = 'vazio';
    vazio.textContent = 'Nenhum produto por aqui ainda.';
    vitrine.appendChild(vazio);
    return;
  }

  produtos.forEach((produto) => {
    const cartao = document.createElement('article');
    cartao.className = 'produto';

    const foto = document.createElement('div');
    foto.className = 'foto';
    if (produto.imagem) {
      const img = document.createElement('img');
      // A imagem vem do painel da loja, já preparada pela Nexify.
      img.src = produto.imagem.startsWith('data:') ? produto.imagem : `data:image/png;base64,${produto.imagem}`;
      img.alt = '';
      foto.appendChild(img);
    }
    cartao.appendChild(foto);

    const conteudo = document.createElement('div');
    conteudo.className = 'conteudo';

    const titulo = document.createElement('h3');
    titulo.textContent = produto.nome;
    conteudo.appendChild(titulo);

    if (produto.descricao) {
      const descricao = document.createElement('p');
      descricao.textContent = produto.descricao.slice(0, 120);
      conteudo.appendChild(descricao);
    }

    let opcaoEscolhida = produto.opcoes && produto.opcoes.length ? produto.opcoes[0].referencia : '';
    if (produto.opcoes && produto.opcoes.length > 1) {
      const escolha = document.createElement('select');
      produto.opcoes.forEach((opcao) => {
        const item = document.createElement('option');
        item.value = opcao.referencia;
        item.textContent = opcao.nome;
        escolha.appendChild(item);
      });
      escolha.onchange = () => { opcaoEscolhida = escolha.value; };
      conteudo.appendChild(escolha);
    }

    const precos = document.createElement('div');
    precos.className = 'precos';
    if (produto.precoComDesconto > 0 && produto.precoComDesconto < produto.preco) {
      const de = document.createElement('span');
      de.className = 'de';
      de.textContent = dinheiro(produto.preco);
      precos.appendChild(de);
    }
    const por = document.createElement('span');
    por.className = 'por';
    por.textContent = dinheiro(precoFinal(produto));
    precos.appendChild(por);
    conteudo.appendChild(precos);

    const comprar = document.createElement('button');
    comprar.type = 'button';
    const semEstoque = produto.estoque <= 0;
    comprar.textContent = semEstoque ? 'Esgotado' : 'Adicionar';
    comprar.disabled = semEstoque;
    comprar.onclick = () => adicionar(produto, opcaoEscolhida);
    conteudo.appendChild(comprar);

    cartao.appendChild(conteudo);
    vitrine.appendChild(cartao);
  });
}

/* --------------------------------------------------------------- carrinho */

function adicionar(produto, opcao) {
  const existente = carrinho.find((item) => item.produto === produto.referencia && item.opcao === opcao);
  if (existente) {
    if (existente.quantidade >= produto.estoque) {
      avisar(`Só há ${produto.estoque} unidade(s) de ${produto.nome}.`);
      return;
    }
    existente.quantidade += 1;
  } else {
    carrinho.push({ produto: produto.referencia, nome: produto.nome, preco: precoFinal(produto), opcao: opcao || '', quantidade: 1 });
  }
  avisar('');
  desenharCarrinho();
}

function desenharCarrinho() {
  listaCarrinho.innerHTML = '';
  carrinhoVazio.style.display = carrinho.length ? 'none' : 'block';

  carrinho.forEach((item, indice) => {
    const linha = document.createElement('li');

    const copia = document.createElement('div');
    const nome = document.createElement('strong');
    nome.textContent = item.nome;
    const detalhe = document.createElement('small');
    detalhe.textContent = `${item.quantidade} × ${dinheiro(item.preco)}`;
    copia.appendChild(nome);
    copia.appendChild(detalhe);

    const valor = document.createElement('span');
    valor.textContent = dinheiro(item.preco * item.quantidade);

    const remover = document.createElement('button');
    remover.type = 'button';
    remover.className = 'remover';
    remover.setAttribute('aria-label', `Tirar ${item.nome} do carrinho`);
    remover.textContent = '×';
    remover.onclick = () => {
      carrinho.splice(indice, 1);
      desenharCarrinho();
    };

    linha.appendChild(copia);
    linha.appendChild(valor);
    linha.appendChild(remover);
    listaCarrinho.appendChild(linha);
  });

  const total = carrinho.reduce((soma, item) => soma + item.preco * item.quantidade, 0);
  document.getElementById('total').textContent = dinheiro(total);
  document.getElementById('contador').textContent = String(carrinho.reduce((soma, i) => soma + i.quantidade, 0));
  document.getElementById('comprar').disabled = carrinho.length === 0;
}

/* -------------------------------------------------------------- pagamento */

function mostrarPagamento(dados) {
  pedidoEmAberto = dados.referencia || null;
  telaPagamento.classList.remove('escondido');

  const situacao = document.getElementById('situacao');
  const textoSituacao = document.getElementById('texto-situacao');
  const qr = document.getElementById('qr');

  if (dados.gratuito) {
    document.getElementById('titulo-pagamento').textContent = 'Pedido concluído';
    document.getElementById('texto-pagamento').textContent = 'Este produto é gratuito e já foi liberado para você.';
    qr.style.display = 'none';
    situacao.dataset.estado = 'aprovado';
    textoSituacao.textContent = 'Entrega feita.';
    return;
  }

  document.getElementById('titulo-pagamento').textContent = 'Pague pelo celular';
  document.getElementById('texto-pagamento').textContent = 'Aponte a câmera do seu celular para o código abaixo. Você não precisa sair do jogo.';
  qr.style.display = dados.qr ? 'block' : 'none';
  if (dados.qr) qr.src = dados.qr;
  document.getElementById('link-pagamento').textContent = dados.url || '';
  situacao.dataset.estado = 'aguardando';
  textoSituacao.textContent = 'Aguardando o pagamento…';

  // Enquanto a tela estiver aberta, pergunta ao servidor se já caiu.
  clearInterval(relogioDoPedido);
  relogioDoPedido = setInterval(() => {
    if (pedidoEmAberto) nui('consultar', { referencia: pedidoEmAberto });
  }, 5000);
}

function atualizarPedido(dados) {
  if (!pedidoEmAberto || dados.referencia !== pedidoEmAberto) return;

  const situacao = document.getElementById('situacao');
  const texto = document.getElementById('texto-situacao');
  situacao.dataset.estado = dados.situacao;

  if (dados.situacao === 'aprovado') {
    texto.textContent = dados.entregue ? 'Pagamento aprovado e entrega feita!' : 'Pagamento aprovado! Preparando a entrega…';
    if (dados.entregue) {
      clearInterval(relogioDoPedido);
      carrinho = [];
      desenharCarrinho();
    }
  } else if (dados.situacao === 'recusado') {
    texto.textContent = 'O pagamento não foi concluído.';
    clearInterval(relogioDoPedido);
  }
}

/* ----------------------------------------------------------------- eventos */

window.addEventListener('message', (evento) => {
  const { acao, dados, mensagem } = evento.data || {};

  if (acao === 'abrir') {
    catalogo = { produtos: dados.produtos || [], categorias: dados.categorias || [] };
    document.getElementById('nome-da-loja').textContent = dados.loja?.nome || 'Loja';
    document.getElementById('endereco-da-loja').textContent = dados.loja?.endereco || '';
    document.getElementById('inicial').textContent = (dados.loja?.nome || 'N').charAt(0).toUpperCase();
    if (dados.loja?.cor) document.documentElement.style.setProperty('--destaque', dados.loja.cor);
    categoriaAtual = null;
    desenharCategorias();
    desenharProdutos();
    desenharCarrinho();
    avisar('');
    janela.classList.remove('escondido');
  }

  if (acao === 'fechar') {
    janela.classList.add('escondido');
    telaPagamento.classList.add('escondido');
    clearInterval(relogioDoPedido);
  }

  if (acao === 'pagamento') mostrarPagamento(dados || {});
  if (acao === 'pedido') atualizarPedido(dados || {});
  if (acao === 'erro') avisar(mensagem || 'Não foi possível concluir.');
});

document.getElementById('fechar').onclick = () => nui('fechar');
document.getElementById('voltar').onclick = () => {
  telaPagamento.classList.add('escondido');
  clearInterval(relogioDoPedido);
};
document.getElementById('ver-carrinho').onclick = () => painelCarrinho.classList.toggle('aberto');
document.getElementById('comprar').onclick = () => {
  if (!carrinho.length) return;
  avisar('Gerando seu pagamento…');
  nui('comprar', {
    carrinho: carrinho.map((item) => ({ produto: item.produto, quantidade: item.quantidade, opcao: item.opcao })),
    cupom: document.getElementById('cupom').value.trim()
  });
};

document.addEventListener('keyup', (evento) => {
  if (evento.key === 'Escape') nui('fechar');
});
