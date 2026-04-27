# Módulo 5 — Documentação Técnica
## Aula 01: Como ler documentação oficial (Skimming and Scanning)

**1. SITUAÇÃO DO DIA A DIA (contexto real)**
Você tomou a tarefa de implementar um cluster EKS na AWS com Terraform, mas uma *feature* fundamental mudou na versão 4.0 do módulo. A documentação oficial (Docs da HashiCorp ou da AWS) tem cerca de 50.000 palavras numa página. Se você for ler do "The" até o "End" usando seu inglês passo-a-passo e procurando dicionário, a sprint acaba e você não configurou nada.

**2. O QUE VOCÊ PRECISA SABER (objetivo da aula)**
Como engenheiro, você não lê documentação técnica como lê Harry Potter (do início ao fim). Você usa duas habilidades de interpretação do inglês: **Skimming** (Passar o olho rápido só para saber onde fica cada título/seção) e **Scanning** (Procurar como um radar por palavras-chave exatas: ex *Requirements, Deprecation, Errors, Usage*). Você precisa dominar as cabeçalhos (headers) da indústria de Docs.

**3. TÍTULOS E PALAVRAS-CHAVE OBRIGATÓRIAS (Scanning)**
Ao entrar em uma página de Documentação Oficial (Kubernetes, Terraform, AWS), seus olhos devem pular direto para estes subtítulos:

* 🟢 **"Prerequisites / Requirements"** (Pré-requisitos / Requerimentos)
  * Nunca copie os comandos do tutorial se você não leu isso primeiro. Saber se você precisa da `aws-cli v2` ou Node `18` fica aqui.
  
* 🟡 **"Usage" ou "Getting Started"** (Uso / Começando)
  * É a parte do "Copy and Paste" (Copia e Cola). Onde os exemplos de código simples, diretos (Hello World) moram.

* 🟡 **"Configuration / Arguments Reference"** (Configuração / Ref. de Argumentos)
  * É a tabela pesada. Onde mostra se a variável é obrigatoria (*Required*) ou Opcional (*Optional*), e qual *Default Type* (Booleano, String, etc).

* 🔵 **"Troubleshooting"** (Resolução de problemas)
  * A primeira palavra procurada pelo plantonista de On-Call. Onde mostram os erros comuns da ferramenta.

* 🔴 **"Deprecation Notice / Warning"** (Aviso de Descontinuação)
  * A palavra "Deprecated" significa que a função vai morrer/será removida nas próximas versões. Jamais implemente um código "Deprecated" em produção nova.

**4. VOCABULÁRIO TÉCNICO DA AULA**
| Palavra/Expressão | Significado em Português | Exemplo de uso em Documentação |
| :--- | :--- | :--- |
| **Deprecated** | Descontinuado / Obsolescente | "This attribute is **deprecated**." |
| **Prerequisites** | Pré-requisitos (obrigatórios) | "Ensure all **prerequisites** are met." |
| **Troubleshooting** | Ato de solucionar BOs / Erros | "Check the **troubleshooting** section." |
| **Workload** | Carga de trabalho (A aplicação em si)| "Deploy your **workload** to the cluster." |
| **Out-of-the-box** | Pronto pra usar / Nativo naturação | "It supports logging **out-of-the-box**." |

**5. CENA DE ESTUDO DE CASO (Leitura dinâmica)**
*[Você lê a doc do AWS EKS Terraform Module]*

1. O olho bate no título: **Warning - Deprecation Notice.** (Atenção, o bloco `workers` foi removido na versão 18.0).
2. O olho cai para: **Usage** (Você copia o exemplo do módulo).
3. Você procura por: `cluster_version`. O olho vai em **Arguments Reference**. Vê que "string, optional".
4. Você está pronto. Gasto de inglês total: 20 segundos para achar. Custo mental quase nulo.

**6. ERROS COMUNS DE BRASILEIRO EM INGLÊS (Interpretação)**
❌ **Achar que "Eventually" significa "Eventualmente" (Quando der na telha).**
✅ Na área de tech, "Eventually Consistent" significa **"No fim das contas / Fatalmente"**. Uma hora o dado vai aparecer correto.

❌ **Traduzir "Deprecate" como "Depreciado" num código (Diminuição de valor financeiro).**
✅ **"Isso está descontinuado."**

❌ **Traduzir "Actually" como "Atualmente".**
✅ **"Actually"** significa "Na verdade/O fato real". (Para atualmente, leia **"Currently"** na doc).

**7. EXERCÍCIO PRÁTICO**
Pressione CTRL+F no seu cérebro. Se um colega gringo no seu Slack disse que o Ingress Router caiu, e você pega a doc do NGINX, em qual "Título" (Usage? Prerequisites? Troubleshooting?) você "scanearia" seus olhos primeiro em busca de logs de erro?

**8. FRASE PARA MEMORIZAR HOJE**
🗣️ **"I always check the prerequisites and deprecation warnings before deploying a new module."**
*(Eu sempre verifico os pré-reqs e os alertas de descontinuação antes de deployar (implantar) um módulo novo.)*

**9. PERGUNTA DE ENTREVISTA EM INGLÊS**
❓ **Pergunta:** *"Technologies change fast. How do you keep up with new tools when you are forced to use something you have never seen before?"*
✅ **Resposta modelo:**
"I immediately dive right into the official documentation. First, I use 'Scanning' techniques to read the official 'Getting Started' and 'Requirements'. I deploy a fast proof-of-concept (PoC) in an isolated sandbox. Only when the architecture gets complex do I dig deeper into the 'Configuration References' and 'Troubleshooting', looking out for any 'Deprecation' notices that could impact our long-term plan."
