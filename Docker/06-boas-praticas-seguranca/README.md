# Módulo 6 — Boas Práticas e Segurança

Quem quer apenas rodar código no PC local pode ignorar isso. Quem quer vagas de DevOps/Cloud Sênior e manter empregos precisa saber que o Container é maravilhoso, até injetarem um shell reverso que destrói as raízes da empresa inteira.

---

### 1. ANALOGIA DO DIA A DIA

**A Fechadura Mestra e o Faxineiro**
Mandar um recém chegado (Container) entrar na sua base e deixá-lo rodando com poderes de Diretor é pedir pra dar dor de cabeça:
- **Root-based (Inseguro)**: Você contrata um estagiário e no primeiro dia entrega as Chaves Mestras de acesso de _TODAS_ as portas do prédio, até da sala dos cofres, pro cara fazer o almoço na copa.
- **Non-Root Base (Oft/Distroless)**: Você revogou as chaves, entrega só a chave restrita da _porta da copa_ pra ele. "Você não é o dono, você tem direito apenas à pasta `/app`". Tudo sob controle rigoroso.

---

### 2. O QUE É (Definição Técnica Senior)

Boas práticas envolvem minificar a  Attack Surface (*Superfície de Ataque*) do software:
- **Alpine / Distroless Images**: Remover Ubuntu Gigantes com 300 pacotes pré-instaladdos (ssh, ping, wget). Se seu app só precisa de Node, ele usa a *Distro+Less* (Imagens curtas que tem literalmente a engine do Node e absolutamente zero pacotes de sistema, evitando brechas de Zero Day Cves do Linux).
- **Non-root enforcement**: Por default o `Docker run` liga o PID 1 com o UID 0 (root). Significa que se acharem uma falha que fuja do container e faça bypass no Host, o atacante já cai no Host Host Linux AWS sendo Deus (Root). Quando mudamos user pra 1000/node na imagem, ele capota no meio do ataque por falta de autoridade nativa em escalation.
- **Cache Layers optimization**: Já coberto de leve antes. Mas aqui formalizamos a prática de minificar steps usando `&&`.

---

### 3. ARQUIVOS COMENTADOS

Inspecione:
- `01-Dockerfile-inseguro-vs-seguro.md`: Um quadro analítico das diferenças mais mortais do mercado.
- `02-Dockerfile-alpine-nonroot`: A compilação definitiva perfeita de exemplo pra se bater o olho.

---

### 4. COMANDOS PASSO A PASSO

**Comando 1: Validar Escaners de Segurança na imagem local**
`docker scout cves nginx:latest` (Opcionalmente precisa de plugin atrelado a conta do hub).
* **O que faz**: Vasculha cada byte cada biblioteca dpkg que compõe o Nginx pra falar "Opa, esta versão xpto tem a vulnerabilidade X, troque pra base Y".

**Comando 2: Forçando na unha a segurança no boot**
`docker run -u 1000:1000 my_app`
* **O que faz**: Se um júnior te manda uma imagem que roda em mode God Root, você pode dar um override forçando aquela imagem a encarnar no Host usando UID 1000 arbitrário! Salva de incidentes no calor da noite.

---

### 5. VERIFICAÇÃO E TROUBLESHOOTING

- Coloquei o `USER node` na imagem que rodava perfeita root, o build deu sucesso mas o app tá dando "EACCES Permission Denied" e crachando assim que liga.
  **Troubleshooting**: O clássico! Voce definiu que o processo de vida na pasta `/app` seria o "USER node". Mas um pouco MAIS ACIMA no Dockerfile, você rodou o `$ COPY . .` (e copiou logando como Root, que é o base builder natural!). Você tem que mudar a sintaxe de chown no copy pra pertencer ao estagiário se não ele nem le o arquivo dele! `COPY --chown=node:node . .`.

---

### 6. CONCEITO SENIOR (O "Porquê" Profundo)

Por que o Dockerfile clássico com 40 comandos de `RUN` seguido era mal visto e exigiam aglutinar tudo em `RUN apt update && apt install xyz && rm -rf ...`?
**R: Limpeza tardia nas fatias da Camada**.
Lembra que falamos que cada "RUN" cria 1 pasta cache separada?
Se a linha A (RUN) baixa 2 GB e instala. A Linha A pesa 2 GB.
Se a linha B (RUN) for apenas "deleta os caches temporarios" , o Docker não volta na linha A para esvaziar lá (A linha A é imutavel forever). A linha B apenas coloca uma "Máscara em branco overlay"  nas pastas deletadas na foto nova dela. Mas para quem baixa os gigabytes pela ISO pela rede, a linha A ainda conta!! Fazer o clean na mesma execução do `RUN` *IMPEDE* que aquela Layer grave tudo no disco morto do Commit. Reduzindo imagens de 2 GB pra 80 MB.

---

### 7. PERGUNTA DE ENTREVISTA

**Pergunta:** A Empresa tá desesperada pois a AWS tá cobrando absurdos mensais em tráfego de Rede na pipeline CI/CD diária que empurra nossos containeres para o ECR e pros Kubernetes, e descobrimos que nossas imagens tão 1.5GB!! E só rodamos Java dentro delas! O que a gente faz que tá inflando tudo?
**Resposta Senior:** Eles provavelmente erraram as fundações do Dockerfile de duas formas letais: Escolheram imagens monstruosas do Tomcat puro ou Ubuntu Full como "FROM" ao invés de versões de base "jre-alpine" ou imagem Scratch com executável nativo. Falta uso de Multi-Stage builds (estão jogando o compilador Maven e arquivos fonte src/ pra AWS). E finalmente possivelmente estã faltando `.dockerignore` que por preguiça faz eles empurrarem pastas `.git/` de desenvolvimento que não operam em runtime logico.
