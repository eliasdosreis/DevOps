# Módulo 5 — Documentação Técnica
## Aula 02: Como escrever um README em inglês perfeito

**1. SITUAÇÃO DO DIA A DIA (contexto real)**
Você construiu um repositório sensacional que automatiza o deploy da AWS usando GitHub Actions. Excelente! Mas as instruções estão apenas na sua cabeça. Se um Dev Júnior de outra equipe pegar seu repositório, não existir um `README.md` legível em inglês fluente significa que o seu código é inútil para eles (e você será cutucado a semana inteira no Slack).

**2. O QUE VOCÊ PRECISA DIZER (objetivo da aula)**
Um README corporativo em inglês usa verbos técnicos no modo Imperativo direto ("Run this...", "Install that...") nas instruções de passo a passo, e inglês descritivo simples no cabeçalho ("This repository contains..."). O formato básico mundial tem quatro blocos: Title/Description, Prerequisites, Installation/Usage, e Contributing.

**3. OS BLOCOS ESSENCIAIS CONSTRUÍDOS EM INGLÊS**
🟢 **BLOCO 1: O PROPÓSITO (Description)**
* "This repository contains the Terraform templates for provisioning the development infrastructure in AWS."
  * **Tradução:** Este repositório contém os templates Terraform para provisionar a infraestrutura de desenvolvimento na AWS.
  * **Contexto:** Clareza e objetividade logo na primeira linha. 

🟡 **BLOCO 2: PRÉ-REQUISITOS (Prerequisites)**
* "Before you begin, ensure you have the following installed:"
  * **Tradução:** Antes de começar, garanta que você possui os seguintes instalados:
  * **Contexto:** Use "ensure you have" em vez de "make sure you have" para um tom superior.

🔵 **BLOCO 3: INSTALAÇÃO E USO (Usage / Getting Started)**
* "1. Clone the repository." (Clone o...)
* "2. Run `terraform init` to initialize the working directory." (Rode... para inicializar)
* "3. Apply the changes by running `terraform apply -auto-approve`." (Aplique as... por rodar...)
  * **Contexto:** Aqui, o inglês não pede favor, ele dita instrução como manual. Nada de "Please run the command..." É direto: "Run the command."

🔵 **BLOCO 4: VARIÁVEIS DE AMBIENTE (Environment Variables)**
* "To run this application, you will need to set the following environment variables in your `.env` file:"
  * **Tradução:** Para rodar esta aplicação, você irá precisar configurar (set) as seguintes vars de ambiente no seu .env.

**4. VOCABULÁRIO TÉCNICO DA AULA**
| Palavra/Expressão | Significado em Português | Exemplo de uso no README |
| :--- | :--- | :--- |
| **To ensure** | Garantir, ter certeza que | "**Ensure** Docker is running." |
| **By running** | Executando/Rodando (comando) | "Start the server **by running** npm start." |
| **To contain** | Conter / Abrigar | "This repository **contains** the scripts." |
| **To set (variables)** | Configurar / Setar (um valor) | "You must **set** the DB_PASS variable." |
| **Out-of-the-box** | Pronto pra rodar / Nativo | "It works **out-of-the-box**." |

**5. TEMPLATE COMPLETO E REAL (Para copiar para o Dev)**
```markdown
# AWS Infrastructure via Terraform

## Description
This repository contains all IaC (Infrastructure as Code) modules to deploy the payment gateway on AWS.

## Prerequisites
Before you begin, ensure you meet the following requirements:
- AWS CLI v2 installed
- Terraform v1.5 or higher
- Valid IAM AWS Credentials

## Usage
1. Clone the repository to your local machine.
2. Initialize the backend by running `terraform init`.
3. Set your required variables inside `terraform.tfvars`.
4. Deploy the infrastructure by running `terraform apply`.
```

**6. ERROS COMUNS DE BRASILEIRO EM INGLÊS**
❌ **"This project serves for automations."** (Pobre e misturado mentalmente com PT-BR).
✅ **"This project is used to automate deployments."** 

❌ **"Do the download of Terraform."** (Extremamente traduzido letreiramente).
✅ **"Download Terraform"** ou **"Install Terraform."**

❌ **"Inform the password."**
✅ **"Set the password variable"** ou **"Provide the password."**

**7. EXERCÍCIO PRÁTICO**
Crie mentalmente as primeiras DUAS regras em inglês do seu repo:
"1. Clone the repository."
"2. Start the Docker container **by running** (rodando/executando) `docker-compose up`."

**8. FRASE PARA MEMORIZAR HOJE**
🗣️ **"Before you begin, ensure you have the AWS CLI installed on your local machine."**
*(Antes de começar, garanta/assegure-se de que a AWS CLI está instalada em sua máquina local.)*

**9. PERGUNTA DE ENTREVISTA EM INGLÊS**
❓ **Pergunta:** *"How important is documentation for you, and how do you structure an internal project's README?"*
✅ **Resposta modelo:**
"Documentation is just as important as the code itself. If nobody can run my code, it's useless. In a README, I keep it very structured. First, a high-level description. Second, strict prerequisites so they don't face environment errors. Third, clear step-by-step 'Usage' instructions using bulleted lists and code blocks. The goal is to allow a junior to spin up the infrastructure entirely blindly, purely by following my steps."
