#!/bin/bash
# ==============================================================================
# Aula 09.06: PROJETO FINAL - Pipeline CI/CD (A Esteira Automática da Fábrica)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA (Para Uma Criança de 10 Anos Entender!)
# ------------------------------------------------------------------------------
# Imagina Uma Fábrica De Chocolate Que Faz Barras MANUALMENTE:
# 1. O Cozinheiro Derrete O Chocolate (No Fogão Com A Mão)
# 2. O Ajudante Testa Se Ficou Doce (Provando Com A Colher)
# 3. Outro Cara Coloca Na Caixinha (Embrulhando Um a Um)
# 4. O Caminhoneiro Leva Pra Loja (Viagem De 2 Horas)
#
# Isso É O Que O Desenvolvedor Júnior Faz: TUDO NA MÃO! Lento, Cheio de Erro!
#
# A CI/CD É A ESTEIRA AUTOMÁTICA DA FÁBRICA!
# 1. Você Joga O Código No Git (Empurra O Cacau Na Esteira!)
# 2. A Máquina Compila E Testa Sozinha (Derrete, Molda, Testa AUTOMÁTICO!)
# 3. Se Passou Em Tudo, Ela Empacota E Manda Pro Servidor (Caixinha Na Loja!)
# 4. Sem Nenhum Humano Tocando! Em 3 Minutos!
#
# CI = Continuous Integration = Testar E Juntar O Código Toda Vez Que Alguém Commita.
# CD = Continuous Delivery   = Entregar O Código Testado Pro Servidor Automaticamente!

# ------------------------------------------------------------------------------
# 2. O QUE É (Definição Técnica Sênior)
# ------------------------------------------------------------------------------
# CI/CD É Uma Prática DevOps Que Automatiza O Ciclo Build-Test-Deploy Via Pipelines
# Declarativos (YAML). O GitLab CI e GitHub Actions São Runners Que Escutam Eventos
# Git (push, merge_request, tag) E Disparam Jobs Isolados Em Containers Efêmeros.
# Cada Job Tem Um Stage (build, test, deploy), E O Pipeline Quebra Fail-Fast Se
# Qualquer Assertion Do Suite De Testes Retornar Exit Code != 0. Zero-Touch Delivery!

# ------------------------------------------------------------------------------
# 3. ARQUITETURA DO PIPELINE - MÃO NA MASSA!
# ------------------------------------------------------------------------------

# ============================================================
# EXEMPLO 1: GITHUB ACTIONS (.github/workflows/deploy.yml)
# ============================================================
# Crie A Pasta E O Arquivo No Seu Repositório Git:
mkdir -p .github/workflows
# vim .github/workflows/deploy.yml
# ======= ARQUIVO GITHUB ACTIONS ABAIXO =======
# name: Pipeline CI/CD de Producao Sênior
#
# on:
#   push:
#     branches: [ "main" ]       # GATILHO: Só Roda Quando Alguém Manda Pro Main!
#   pull_request:
#     branches: [ "main" ]       # E Quando Abrir Um PR (Para Validar Antes Do Merge!)
#
# jobs:
#   # -----------------------------------------------
#   # STAGE 1: BUILD (Compilar A App Dentro De Container)
#   # -----------------------------------------------
#   build:
#     name: Compilar e Empacotar
#     runs-on: ubuntu-latest     # O GitHub Sobe Uma VM Ubuntu Nova Zerada Pra Nós!
#     steps:
#       - name: Baixar O Codigo (Git Checkout)
#         uses: actions/checkout@v4
#
#       - name: Configurar Node.js
#         uses: actions/setup-node@v4
#         with:
#           node-version: '20'
#           cache: 'npm'         # Cache Das Dependencias Pra Pipeline Ficar Rapida!
#
#       - name: Instalar Dependencias
#         run: npm ci            # 'ci' É Mais Seguro Que 'install' Em Pipeline! (Usa Lock File)
#
#       - name: Compilar O Projeto
#         run: npm run build
#
#       - name: Guardar O Build Como Artefato
#         uses: actions/upload-artifact@v4
#         with:
#           name: build-dist
#           path: dist/          # Guarda A Pasta 'dist' Pra O Próximo Job Usar!
#
#   # -----------------------------------------------
#   # STAGE 2: TEST (Rodar Os Testes Automatizados)
#   # -----------------------------------------------
#   test:
#     name: Testar A Aplicacao
#     runs-on: ubuntu-latest
#     needs: build              # SÓ RODA SE O BUILD PASSOU! (Dependência Entre Jobs!)
#     steps:
#       - uses: actions/checkout@v4
#
#       - name: Configurar Node.js
#         uses: actions/setup-node@v4
#         with:
#           node-version: '20'
#
#       - name: Instalar E Rodar Testes
#         run: |
#           npm ci
#           npm test -- --coverage   # Roda Os Testes E Gera Relatório De Cobertura!
#
#       - name: Verificar Cobertura Minima (80%)
#         run: npx jest --coverageThreshold='{"global":{"lines":80}}'
#         # SE A COBERTURA CAIR ABAIXO DE 80%, O PIPELINE QUEBRA E O DEPLOY NÃO ACONTECE!
#
#   # -----------------------------------------------
#   # STAGE 3: DEPLOY (Mandar Pra Producao De Verdade!)
#   # -----------------------------------------------
#   deploy:
#     name: Deploy Para Producao
#     runs-on: ubuntu-latest
#     needs: [build, test]      # SÓ RODA SE BUILD E TEST PASSARAM!
#     if: github.ref == 'refs/heads/main'  # SÓ NA BRANCH MAIN! Não Em PRs!
#     environment: production   # Ambiente Protegido (Precisa Aprovação Manual!)
#
#     steps:
#       - uses: actions/checkout@v4
#
#       - name: Baixar O Build Do Stage Anterior
#         uses: actions/download-artifact@v4
#         with:
#           name: build-dist
#           path: dist/
#
#       - name: Configurar Credenciais AWS
#         uses: aws-actions/configure-aws-credentials@v4
#         with:
#           aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
#           aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
#           aws-region: us-east-1
#         # NUNCA COLOQUE SENHAS NO CÓDIGO!! USA 'secrets' Do GitHub (Cofre Criptografado!)
#
#       - name: Deploy No S3 (Site Estático)
#         run: aws s3 sync dist/ s3://meu-site-producao --delete
#
#       - name: Invalidar Cache CloudFront (Pra Usuarios Verem As Mudancas!)
#         run: |
#           aws cloudfront create-invalidation \
#             --distribution-id ${{ secrets.CLOUDFRONT_ID }} \
#             --paths "/*"
#
#       - name: Notificar Time No Slack
#         if: always()          # Roda Mesmo Se O Deploy Falhou! (Para Avisar O Time!)
#         run: |
#           curl -X POST ${{ secrets.SLACK_WEBHOOK }} \
#             -H 'Content-type: application/json' \
#             --data '{"text":"Deploy ${{ job.status }} na branch ${{ github.ref }}!"}'
# ======= FIM ARQUIVO GITHUB ACTIONS =======

# ============================================================
# EXEMPLO 2: GITLAB CI (.gitlab-ci.yml) - Estagio de Segurança
# ============================================================
# O GitLab CI É Usado Em Empresas Com Servidor Git Próprio (On-Premise)
# vim .gitlab-ci.yml
# ======= ARQUIVO GITLAB CI ABAIXO =======
# stages:
#   - build
#   - test
#   - security          # STAGE EXTRA SÊNIOR: Análise De Segurança!
#   - deploy
#
# variables:
#   DOCKER_IMAGE: "registry.empresa.com/minha-app:${CI_COMMIT_SHORT_SHA}"
#   # CI_COMMIT_SHORT_SHA = Variável Mágica Do GitLab! O Hash Do Commit Atual!
#   # Assim Cada Deploy Tem Uma Tag Única! Nunca Mais "latest" Em Produção!
#
# build-docker:
#   stage: build
#   image: docker:24.0
#   services:
#     - docker:24.0-dind         # Docker-In-Docker: Container Que Roda Docker!
#   script:
#     - docker build -t $DOCKER_IMAGE .
#     - docker push $DOCKER_IMAGE    # Manda Imagem Pro Registry Privado Da Empresa!
#
# test-unitario:
#   stage: test
#   image: $DOCKER_IMAGE
#   script:
#     - python -m pytest tests/ -v --junitxml=report.xml
#   artifacts:
#     reports:
#       junit: report.xml        # GitLab Lê Esse XML E Mostra Os Testes Na Interface!
#
# scan-seguranca:
#   stage: security
#   image: aquasec/trivy:latest  # Scanner De Vulnerabilidades CVE Na Imagem Docker!
#   script:
#     - trivy image --exit-code 1 --severity HIGH,CRITICAL $DOCKER_IMAGE
#     # SE ACHAR VULNERABILIDADE CRÍTICA NA IMAGEM, O PIPELINE QUEBRA E NÃO FAZ DEPLOY!
#     # ISSO É DEVSECOPS! SEGURANÇA DENTRO DO PIPELINE AUTOMATICAMENTE!
#
# deploy-producao:
#   stage: deploy
#   only:
#     - main
#   script:
#     - ssh deploy@servidor-producao "docker pull $DOCKER_IMAGE && docker compose up -d"
# ======= FIM ARQUIVO GITLAB CI =======

# ------------------------------------------------------------------------------
# 4. SCRIPT DE ROLLBACK DE EMERGÊNCIA (O Botão Vermelho Sênior!)
# ------------------------------------------------------------------------------
# CENA DE TERROR: O Deploy Das 14h Chegou Na Produção E Quebrou TUDO!
# O Site Tá Retornando 500 Pra TODOS Os Clientes! O CTO Tá Ligando!
# O Sênior Não Entra Em Pânico. Ele Tem O ROLLBACK PRONTO!

set -e
set -o pipefail

IMAGEM_ATUAL="registry.empresa.com/minha-app:abc1234"
IMAGEM_ANTERIOR="registry.empresa.com/minha-app:def5678"  # A Versão Boa Anterior!
SERVIDOR="deploy@servidor-producao"
LOG_ROLLBACK="/var/log/rollbacks.log"
DATA=$(date +%F_%T)

echo "[${DATA}] INICIANDO ROLLBACK DE EMERGENCIA! De ${IMAGEM_ATUAL} Para ${IMAGEM_ANTERIOR}" >> $LOG_ROLLBACK

# Mandando Comando SSH Pro Servidor Trocar A Imagem E Reiniciar:
ssh $SERVIDOR "
  export DOCKER_IMAGE=${IMAGEM_ANTERIOR}
  docker compose pull
  docker compose up -d --no-deps app
"

# Esperando 10 segundos e testando se o site voltou:
sleep 10
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://meu-site.com/health)

if [ "$HTTP_CODE" = "200" ]; then
    echo "[${DATA}] ROLLBACK SUCESSO! Site Respondendo 200 OK! Os Clientes Voltaram!" >> $LOG_ROLLBACK
    curl -X POST $SLACK_WEBHOOK --data '{"text":"Rollback concluido com SUCESSO. Site no ar!"}'
else
    echo "[${DATA}] ROLLBACK FALHOU TAMBEM! Site Retornou ${HTTP_CODE}! ESCALAR PARA CTO!" >> $LOG_ROLLBACK
    curl -X POST $SLACK_WEBHOOK --data '{"text":"CRITICO: Rollback também falhou! Escalar para CTO AGORA!"}'
    exit 1
fi

# VALIDAÇÃO DO PIPELINE SÊNIOR:
# - Verifica Se O Arquivo .github/workflows/ Existe:
ls -la .github/workflows/
# - Simula Um Push Localmente Pra Ver O YAML Sem Erros:
# (Usa o 'act' - Ferramenta Que Roda GitHub Actions Localmente!)
# act push --job build
# - Ver Status Dos Últimos Pipelines Via CLI Do GitHub:
# gh run list --limit 5

# A CI/CD É A DIFERENÇA ENTRE UMA EMPRESA QUE FAZ 1 DEPLOY POR MÊS (COM MEDO)
# E UMA QUE FAZ 50 DEPLOYS POR DIA (COM CONFIANÇA)! NETFLIX FAZ 4000 POR DIA!!
# VOCÊ ACABOU DE APRENDER O SEU SUPERPODER SÊNIOR!!! PARABÉNS!!
