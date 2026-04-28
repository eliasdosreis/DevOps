# Prompt - Converter curso em Markdown para site HTML de estudo

Use este prompt quando quiser repetir o processo em outras pastas de curso.

```text
Quero transformar esta pasta de curso em uma pagina/site de estudo bonito, usando HTML, CSS e JavaScript.

Contexto:
- A pasta pode ter arquivos .md, scripts, templates e codigo organizados por modulos.
- Quero que cada arquivo didatico vire uma pagina HTML: `.md`, `.sh`, `.yaml`, `.yml`, `.py`, `.js`, `.json`, `.html`, `.css`, `Dockerfile` e outros arquivos relevantes do laboratorio.
- Quero tambem uma pagina principal com todos os modulos, busca, filtro, progresso e navegacao.
- O resultado precisa ser bonito, criativo, responsivo e agradavel para estudar.
- Pode usar imagem de referencia da internet quando fizer sentido.
- Preserve o conteudo original na conversao, incluindo codigo, scripts, templates de infraestrutura e arquivos sem extensao como Dockerfile.
- Se encontrar conteudo fraco, curto ou confuso, primeiro proponha/adicione uma camada de melhoria seguindo o contexto do curso.

Regras de conteudo:
- Explicar de forma simples, como para uma crianca de 8 anos.
- Tambem trazer visao senior/profissional quando fizer sentido.
- Criar comparativos, pegadinhas, checklists, simulados ou estudos de caso se o curso pedir.
- Para cursos de prova/certificacao, validar contra fonte oficial atual antes de afirmar pesos, dominios ou regras.
- Para cursos de projeto/portfolio, focar em evidencias, arquitetura, custo, seguranca, troubleshooting e entrevista.

Regras tecnicas:
- Criar uma pasta `site/` dentro do curso.
- Criar `site/index.html`.
- Criar ou atualizar tambem um `index.html` na raiz da pasta do curso apontando para `site/index.html`, para que o curso abra corretamente quando acessado pelo catalogo principal.
- Criar `site/assets/styles.css`.
- Criar `site/assets/app.js`.
- Criar `site/assets/quiz.js` quando o curso tiver perguntas, simulados ou gabarito.
- Criar `site/assets/data.js` ou equivalente com os dados convertidos.
- Criar `site/pages/*.html`, uma pagina por arquivo didatico.
- Para cursos praticos/projetos, criar tambem paginas HTML para scripts e codigo do modulo, como `.sh`, `.yaml`, `.py`, `.html`, `Dockerfile` e equivalentes.
- Criar uma pasta `tools/` com um script gerador, por exemplo `tools/build-study-site.js`.
- O script deve ler os arquivos didaticos e regenerar o site quando eu editar o conteudo.
- O site deve funcionar como arquivo estatico, sem servidor obrigatorio.
- Nenhum link de navegacao do site gerado deve apontar diretamente para `.md`, `.yaml`, `.yml`, `.sh` ou outros arquivos fonte. Links internos devem apontar para as paginas HTML geradas em `site/pages/*.html`.
- Se mostrar o caminho do arquivo original, mostrar apenas como texto informativo, nunca como link clicavel.
- Depois de gerar o site, atualizar o catalogo principal em `assets/catalog-data.js` para que o card do curso use `hasSite: true`, `href` apontando para `PASTA_DO_CURSO/index.html` ou `PASTA_DO_CURSO/site/index.html`, e `htmlCount` com a quantidade real de paginas geradas.

Funcionalidades desejadas:
- Menu lateral ou superior por modulos.
- Cards/lista de aulas.
- Busca por palavra-chave.
- Filtro por modulo.
- Botao de marcar aula como concluida usando localStorage.
- Barra de progresso.
- Botao de revisao aleatoria.
- Pagina HTML individual para cada aula.
- Perguntas interativas em formato quiz, com alternativas clicaveis.
- O aluno deve escolher a resposta antes de ver o gabarito.
- Ao clicar, mostrar se acertou ou errou, destacar a alternativa correta e revelar a explicacao.
- Nunca deixar `(correta)`, gabarito ou resposta visivel antes da tentativa.
- Se houver uma secao "Gabarito comentado", esconder essa secao e usar suas respostas como feedback do quiz.
- Layout responsivo para desktop e celular.
- Boa leitura: tabelas, codigos, listas e blocos destacados bem formatados.
- Arquivos de codigo devem virar paginas de estudo com resumo, tipo do arquivo, caminho original, custo/pre-requisito quando existir nos comentarios e bloco de codigo completo preservado.
- Transicoes suaves entre aulas com fade out/fade in.
- Animacoes discretas em cards, estatisticas, hero e elementos visuais.
- Respeitar `prefers-reduced-motion` para acessibilidade.
- Imagens de apoio por modulo para ajudar memorizacao e associacao visual.
- Quando usar imagens remotas, preferir fontes publicas/confiaveis e registrar isso no README.
- Se possivel, adicionar a mesma imagem/visual nas paginas HTML individuais.

Fluxo esperado:
1. Analise a pasta e liste rapidamente a estrutura.
2. Identifique lacunas importantes do curso.
3. Se necessario, adicione arquivos de revisao, checklist, guia ou case study.
4. Crie o gerador em `tools/`.
5. Inclua no gerador todos os arquivos didaticos do curso, nao apenas Markdown.
6. Gere o site em `site/`.
7. Valide sintaxe do JavaScript.
8. Confira a quantidade de paginas HTML geradas e compare com a quantidade de arquivos didaticos encontrados.
9. Crie um `site/README.md` explicando como abrir e regenerar.
10. Adicione transicoes, animacoes e imagens de apoio por modulo.
11. Transforme perguntas e simulados em quiz interativo, sem resposta visivel antes do clique.
12. Atualize o catalogo raiz `index.html` indiretamente via `assets/catalog-data.js`, garantindo que o curso nao abra mais arquivos fonte como `.md`.
13. Procure links perigosos antes de finalizar, por exemplo `href=.*.md`, `href=.*.yaml`, `href=.*.yml` e `href=.*.sh` dentro de `site/`.
14. Valide novamente o JavaScript e procure texto quebrado/mojibake antes de finalizar.
15. Faca commit e git push se eu autorizar.

Depois que o site estiver bom:
- Posso pedir para apagar os arquivos .md e as pastas antigas.
- Nesse caso, apague apenas os arquivos/pastas fonte do curso.
- Preserve `site/` e `tools/`.
- Confirme antes quais caminhos serao removidos.
- Nunca apague fora da pasta do curso.

Ao final, me diga:
- onde abrir o site;
- quantas paginas foram geradas;
- qual comando regenera;
- se fez commit/push;
- quais arquivos/pastas principais foram criados.
```

## Comando padrao para regenerar

Substitua `NOME DA PASTA` pelo curso desejado:

```bash
node "NOME DA PASTA/tools/build-study-site.js"
```

## Observacao

Se o curso tiver acentos ou caracteres quebrados, primeiro verificar encoding antes de reescrever arquivos grandes.

## Padrao visual oficial

Use como referencia o site ja criado em:

```text
AWS CLF02/site/index.html
```

Esse estilo passa a ser o padrao para os proximos cursos.

Caracteristicas obrigatorias do padrao:

- Visual moderno, escuro/profissional, com contraste alto e leitura confortavel.
- Hero forte no topo, com imagem de fundo relevante ao tema.
- Menu de modulos bem organizado.
- Cards de aulas com hover elegante.
- Imagem de apoio por modulo/aula para facilitar memorizacao.
- Transicao suave ao trocar de aula.
- Fade in/fade out entre conteudos.
- Microanimacoes em cards, estatisticas, progresso e elementos visuais.
- Barra de progresso salva no navegador com `localStorage`.
- Busca e filtro por modulo.
- Botao de revisao aleatoria.
- Paginas HTML individuais para cada aula.
- Responsivo para desktop e celular.
- Suporte a `prefers-reduced-motion`.
- README do site explicando como abrir e regenerar.

## Padrao de perguntas e simulados

Use como referencia o comportamento ja criado em:

```text
AWS CLF02/site/assets/quiz.js
```

Regras obrigatorias para proximos cursos:

- Converter perguntas de fixacao em cards de quiz.
- Cada alternativa deve ser um botao claro: A, B, C, D.
- A resposta correta deve ficar escondida antes do clique.
- Depois do clique, desabilitar as opcoes, marcar correto/errado e revelar feedback.
- Se o aluno errar, mostrar qual era a alternativa certa.
- Explicacoes, armadilhas, comentarios e gabarito comentado devem aparecer apenas apos a tentativa.
- O mesmo quiz precisa funcionar no painel principal e nas paginas HTML individuais.
- O visual deve seguir `.quiz-card`, `.quiz-option`, `.quiz-feedback` do CSS da AWS CLF02.
- Para simulados com perguntas em uma secao e gabarito em outra, usar o gabarito como fonte de resposta e remover/esconder a secao de gabarito da leitura inicial.
- Validar no navegador pelo menos uma pergunta comum e um simulado, quando existir.

Para catalogo principal de todos os cursos, usar como referencia:

```text
index.html
```
Não esquecer de ver arquivos .py .yaml .js e outros tambem são conteundos importantes.

Padrao do catalogo:

- Estilo catalogo/Netflix.
- Cards horizontais por categoria.
- Capa visual para cada curso.
- Busca e filtros.
- Destaque principal.
- Animações discretas e profissionais.
- Sempre que um curso ganhar `site/`, atualizar `assets/catalog-data.js`.
- O `href` do curso no catalogo deve abrir o site HTML, nunca o primeiro `.md` da pasta.
- Cursos convertidos devem ficar com `hasSite: true`, badge de site pronto quando fizer sentido, e contagem `htmlCount` atualizada.
- Validar no final clicando ou procurando no catalogo se o curso ainda aponta para `.md`, `.yaml`, `.yml` ou `.sh`.
