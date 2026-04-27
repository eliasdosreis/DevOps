# Site de estudo AWS CLF-C02

Este site foi gerado automaticamente a partir dos arquivos `.md` da pasta `AWS CLF02`.

## Como abrir

Abra este arquivo no navegador:

```text
AWS CLF02/site/index.html
```

O site funciona como pagina estatica: nao precisa servidor.

## O que existe no site

- Painel principal com todos os modulos.
- Busca por assunto ou servico AWS.
- Filtro por modulo.
- Progresso salvo no navegador.
- Botao de revisao aleatoria.
- Uma pagina HTML individual para cada arquivo Markdown em `site/pages/`.

## Como regenerar

Se editar qualquer `.md`, rode:

```bash
node "AWS CLF02/tools/build-study-site.js"
```

Isso atualiza:

- `site/index.html`
- `site/assets/data.js`
- `site/assets/app.js`
- `site/assets/styles.css`
- `site/pages/*.html`

