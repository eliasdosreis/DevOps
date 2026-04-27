#!/bin/bash
# ==============================================================================
# Aula 09.07: PROJETO FINAL - Kubernetes (O Maestro dos Containers)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA (Para Uma Criança de 10 Anos Entender!)
# ------------------------------------------------------------------------------
# Você Viu No Projeto Anterior Q O Docker É Uma Fábrica De Caixinhas LEGO, Né?
# Mas Imagina Agora Que Você Tem MILHARES De Caixinhas Em Centenas De Prateleiras!
#
# Quem Controla Isso? Pensa Assim:
# Você É O Dono De Um Zoológico Enorme!
# - Os Animais São Os Containers (Cada Um Com Sua Necessidade Diferente)
# - As Jaulas São Os Servidores (Nodes)
# - O Kubernetes É O ZELADOR CHEFE DO ZOOLÓGICO!
#
# O Zelador Garante:
# "Preciso De 3 Leões Sempre!" → Se Um Leão Morrer, Nasce Outro Automaticamente!
# "Esse Elefante Come Muito!" → Ele Coloca O Elefante Na Jaula Com Mais Espaço!
# "Tem Visita Chegando!" → Ele Abre Mais Jaulas E Move Animais Pra Dar Conta!
#
# Kubernetes Faz Isso Com Containers: Garante Que Sempre Tenha O Número Certo
# De Containers Rodando, Distribui A Carga, E Escala Automaticamente!

# ------------------------------------------------------------------------------
# 2. O QUE É (Definição Técnica Sênior)
# ------------------------------------------------------------------------------
# Kubernetes (k8s) É Um Orquestrador De Containers Open-Source Originado No Google (Borg).
# Ele Gerencia Clusters De Nodes Workers Via Control Plane (API Server, etcd, Scheduler,
# Controller Manager). Os Pods São A Menor Unidade (1+ Containers + Volumes + Network Namespace).
# O Reconciliation Loop É A Alma Do k8s: O etcd Armazena O "Estado Desejado" YAML E Os
# Controllers Ficam Em Loop Infinito Tentando Fazer O "Estado Real" Bater Com O "Desejado"!
# Essa Filosofia É Chamada De "Desired State" / Infraestrutura Declarativa!

# ------------------------------------------------------------------------------
# 3. INSTALAÇÃO DO AMBIENTE LOCAL (minikube) - MÃO NA MASSA!
# ------------------------------------------------------------------------------

# PASSO 1: INSTALAR O KUBECTL (O Controle Remoto Do Cluster)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
# [SAÍDA ESPERADA]: Client Version: v1.XX.X   ← Mostra A Versão Instalada!

# PASSO 2: INSTALAR O MINIKUBE (Um Kubernetes Pequenininho Pra Estudar No Seu PC)
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube

# PASSO 3: INICIAR O CLUSTER LOCAL
minikube start --driver=docker --cpus=2 --memory=4096
# --driver=docker = Usa Docker Como Base (Projeto 5!)
# --cpus=2        = Dá 2 CPUs Pro Cluster
# --memory=4096   = 4GB De RAM
# [SAÍDA ESPERADA]: Done! kubectl is now configured to use "minikube" cluster!

# PASSO 4: VER O ESTADO DO CLUSTER
kubectl get nodes
# NAME       STATUS   ROLES           AGE   VERSION
# minikube   Ready    control-plane   1m    v1.28.0
# "Ready" = O Zelador Chefe Acordou E Tá Pronto Pra Cuidar Dos Animais!

# ------------------------------------------------------------------------------
# 4. OS ARQUIVOS YAML SAGRADOS DO KUBERNETES - O CORAÇÃO DO NEGÓCIO!
# ------------------------------------------------------------------------------

# ============================================================
# ARQUIVO 1: DEPLOYMENT (Garante Que Sempre Tenha N Pods Rodando)
# ============================================================
# vim deployment.yaml
# ======= ARQUIVO DEPLOYMENT ABAIXO =======
# apiVersion: apps/v1
# kind: Deployment             # Tipo Do Objeto (Aqui É Um Deployment)
# metadata:
#   name: minha-app            # Nome Do Deployment
#   labels:
#     app: minha-app
#
# spec:
#   replicas: 3                # QUERO SEMPRE 3 CONTAINERS VIVOS! SE MORRER, NASCE!
#   selector:
#     matchLabels:
#       app: minha-app         # Controla Pods Com Este Label
#
#   # ROLLING UPDATE STRATEGY - SÊNIORIDADE MÁXIMA!
#   strategy:
#     type: RollingUpdate
#     rollingUpdate:
#       maxUnavailable: 1      # No Máximo 1 Pod Fora Do Ar Durante O Update!
#       maxSurge: 1            # Pode Criar 1 Pod Extra Durante A Atualização!
#   # Isso Garante ZERO DOWNTIME NOS DEPLOYS! O Site Nunca Cai!
#
#   template:
#     metadata:
#       labels:
#         app: minha-app
#     spec:
#       containers:
#       - name: minha-app
#         image: minha-app:v1.0
#         ports:
#         - containerPort: 8080
#
#         # RECURSOS: O Zelador Sabe Quanto Cada Animal Come!
#         resources:
#           requests:
#             memory: "128Mi"  # Minimo Q O Container Precisa Pra Subir
#             cpu: "100m"      # 100 Millicores = 10% De 1 CPU
#           limits:
#             memory: "256Mi"  # LIMITE MÁXIMO! Se Estourar: OOM Kill!
#             cpu: "250m"      # Nunca Vai Além De 25% De 1 CPU!
#
#         # LIVENESS PROBE: O Zelador Verifica Se O Animal Ainda Tá Vivo!
#         livenessProbe:
#           httpGet:
#             path: /health
#             port: 8080
#           initialDelaySeconds: 30   # Espera 30s Antes De Começar A Verificar
#           periodSeconds: 10         # Verifica A Cada 10 Segundos
#           failureThreshold: 3       # 3 Falhas Seguidas: Mata E Recria O Pod!
#
#         # READINESS PROBE: Antes De Mandar Tráfego, Verifica Se Tá Pronto!
#         readinessProbe:
#           httpGet:
#             path: /ready
#             port: 8080
#           initialDelaySeconds: 5
#           periodSeconds: 5
#         # O Load Balancer Só Manda Tráfego Pro Pod Que Passar No Readiness!
# ======= FIM DEPLOYMENT =======

# ============================================================
# ARQUIVO 2: SERVICE (A Portaria Do Zoológico - Como Entrar!)
# ============================================================
# vim service.yaml
# ======= ARQUIVO SERVICE ABAIXO =======
# apiVersion: v1
# kind: Service
# metadata:
#   name: minha-app-service
# spec:
#   selector:
#     app: minha-app             # Manda Tráfego Pra Todos Os Pods Com Esse Label!
#   ports:
#     - protocol: TCP
#       port: 80                 # Porta Externa (Quem Acessa De Fora)
#       targetPort: 8080         # Porta Do Container (Onde A App Roda)
#   type: LoadBalancer           # Na AWS/GCP Cria Um Load Balancer Real Automaticamente!
# ======= FIM SERVICE =======

# ============================================================
# ARQUIVO 3: HPA - AUTOSCALING (O Zelador Chama Reforço Automaticamente!)
# ============================================================
# vim hpa.yaml
# ======= ARQUIVO HPA ABAIXO =======
# apiVersion: autoscaling/v2
# kind: HorizontalPodAutoscaler
# metadata:
#   name: minha-app-hpa
# spec:
#   scaleTargetRef:
#     apiVersion: apps/v1
#     kind: Deployment
#     name: minha-app
#   minReplicas: 3             # MÍNIMO 3 Pods (Sempre!)
#   maxReplicas: 20            # MÁXIMO 20 Pods (Não Vai Além Disso! Controle De Custo!)
#   metrics:
#   - type: Resource
#     resource:
#       name: cpu
#       target:
#         type: Utilization
#         averageUtilization: 70    # SE CPU > 70%: Cria Mais Pods!
#                                   # SE CPU < 70%: Remove Pods (Poupa Dinheiro!)
# ======= FIM HPA =======

# APLICANDO OS ARQUIVOS NO CLUSTER:
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f hpa.yaml
# "apply" = "Ei Kubernetes! Esse É O Estado Que Eu Quero! Você Decide Como Fazer!"

# ------------------------------------------------------------------------------
# 5. COMANDOS DO DIA A DIA SÊNIOR (O Controle Remoto Do Zoológico)
# ------------------------------------------------------------------------------
kubectl get pods                        # Lista Todos Os Containers (Animais!) Vivos
kubectl get pods -o wide                # Mostra Em Qual Node (Jaula!) Cada Pod Tá!
kubectl describe pod meu-pod-abc123     # Relatório Completo De Um Pod (A Ficha Médica!)
kubectl logs meu-pod-abc123             # Ver Os Logs Do Container Vivo
kubectl logs meu-pod-abc123 -f          # Logs Ao Vivo (Tail -f Do Kubernetes!)
kubectl logs meu-pod-abc123 --previous  # Logs Do Container ANTES De Morrer! Sênior!
kubectl exec -it meu-pod-abc123 -- bash # Entrar Dentro Do Pod (O SSH Do k8s!)
kubectl top pods                        # CPU e RAM De Cada Pod Em Tempo Real!
kubectl get events --sort-by='.lastTimestamp'  # Histórico De Tudo Q Aconteceu!

# ESCALANDO MANUALMENTE (Emergência! Precisamos De Mais Pods AGORA!):
kubectl scale deployment/minha-app --replicas=10
# Em Segundos: 10 Pods Rodando! Sem Precisar Mexer No YAML!

# ROLLBACK DE DEPLOY QUE DEU ERRADO:
kubectl rollout history deployment/minha-app    # Histórico De Versões!
kubectl rollout undo deployment/minha-app       # Volta Pra Versão Anterior!
kubectl rollout undo deployment/minha-app --to-revision=3  # Volta Pra Versão 3!

# ------------------------------------------------------------------------------
# 6. VALIDAÇÃO E TROUBLESHOOTING SÊNIOR
# ------------------------------------------------------------------------------
# CENA: Pod Em Estado "CrashLoopBackOff" (O Animal Ficou Doente E Morre Toda Hora!)
#
# CrashLoopBackOff = O Container Inicia, Crasha, k8s Tenta Reiniciar, Crasha Dnv...
# O k8s Vai Aumentando O Tempo Entre Tentativas (Exponential Backoff): 10s, 20s, 40s...
#
# DIAGNÓSTICO DO SÊNIOR (Método Científico, Não Chute!):
kubectl describe pod meu-pod-doente     # 1. Olhar A Seção "Events" No Final!
kubectl logs meu-pod-doente --previous  # 2. Ver O Log DA MORTE ANTERIOR!
# Causas Comuns:
# - Variável De Ambiente Faltando (A App Não Encontrou DB_HOST e Morreu!)
# - OOMKilled (Memory Limit Muito Baixo! O Container Estourou A RAM!)
# - Imagem Com Bug (O Dockerfile Tem Erro! CMD Errado!)
# - Liveness Probe Muito Agressiva (Matou O Pod Antes Dele Conseguir Subir!)
#
# FIX DE EMERGÊNCIA (Entrar Em Debug Mode):
kubectl debug meu-pod-doente -it --image=busybox --copy-to=debug-pod
# Cria Uma Cópia Do Pod Com Uma Imagem Minimalista Pra Investigar O Problema!

# KUBERNETES É O QUE RODA POR BAIXO DO GOOGLE, AMAZON, SPOTIFY, BRADESCO...
# SE VOCÊ DOMINA KUBERNETES, VOCÊ É AUTOMATICAMENTE SÊNIOR NO MERCADO!
# PARABÉNS! VOCÊ CHEGOU NO TOPO DA MONTANHA LINUX SYSADMIN / DEVOPS / SRE!!!
