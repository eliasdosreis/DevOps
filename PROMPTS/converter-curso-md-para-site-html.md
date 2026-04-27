# Prompt - Converter curso em Markdown para site HTML de estudo

Use este prompt quando quiser repetir o processo em outras pastas de curso.

```text
Quero transformar esta pasta de curso em uma pagina/site de estudo bonito, usando HTML, CSS e JavaScript.

Contexto:
- A pasta tem varios arquivos .md organizados por modulos.
- Quero que cada arquivo .md vire uma pagina HTML.
- Quero tambem uma pagina principal com todos os modulos, busca, filtro, progresso e navegacao.
- O resultado precisa ser bonito, criativo, responsivo e agradavel para estudar.
- Pode usar imagem de referencia da internet quando fizer sentido.
- Preserve o conteudo original na conversao.
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
- Criar `site/assets/styles.css`.
- Criar `site/assets/app.js`.
- Criar `site/assets/quiz.js` quando o curso tiver perguntas, simulados ou gabarito.
- Criar `site/assets/data.js` ou equivalente com os dados convertidos.
- Criar `site/pages/*.html`, uma pagina por arquivo .md.
- Criar uma pasta `tools/` com um script gerador, por exemplo `tools/build-study-site.js`.
- O script deve ler os .md e regenerar o site quando eu editar o conteudo.
- O site deve funcionar como arquivo estatico, sem servidor obrigatorio.

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
5. Gere o site em `site/`.
6. Valide sintaxe do JavaScript.
7. Confira a quantidade de paginas HTML geradas.
8. Crie um `site/README.md` explicando como abrir e regenerar.
9. Adicione transicoes, animacoes e imagens de apoio por modulo.
10. Transforme perguntas e simulados em quiz interativo, sem resposta visivel antes do clique.
11. Valide novamente o JavaScript e procure texto quebrado como `Â` ou `�`.
12. Faca commit e git push se eu autorizar.

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

Padrao do catalogo:

- Estilo catalogo/Netflix.
- Cards horizontais por categoria.
- Capa visual para cada curso.
- Busca e filtros.
- Destaque principal.
- Animações discretas e profissionais.
