# ============================================================
# O QUE ESTE ARQUIVO FAZ:
# Desenha e explica a Topologia de Rede da nossa Aplicação 
# Senior do Mundo Real. Ele é o "Mapa da Mina".
# ============================================================

# 1. A VISÃO GERAL
Chegou a hora de provar valor. Ninguém ganha vaga de Sênior escrevendo 
apenas 1 Pod avulso. Aplicações de mercado possuem "Tiers" (Camadas).
Vamos subir juntos uma aplicação de "Vendas de Livros".

Ela é composta por 3 blocos gigantescos que se conversam magicamente 
usando 100% dos blocos que aprendemos em todos os módulos até aqui:

### Camada 1: Database (Arquivo `02-database.yaml`)
- **Quem É:** Um pod de MySQL.
- **O Isolamento:** Ele NÃO POSSUI `NodePort` nem `Ingress`. Ninguém da RUA no mundo físico pode escanear portas ou tentar "Hackear" direto o seu banco de dados, pois ele só possui um `Service (ClusterIP)` 100% trancado e isolado na rede virtual de Overlay.
- **A Sobrevivência:** Tem um `PVC` próprio amarado para reter os livros e Senhas vindas de um `Secret` encriptado.

### Camada 2: Backend API (Arquivo `03-backend.yaml`)
- **Quem É:** Uma API REST simulada que o FrontEnd consome.
- **A Resiliência:** Tem `2 Réplicas`. Tem `LivenessProbe` protegendo contra deadlocks, tem `Requests/Limits` limitando pra 512mb de ram pra não sugar o cluster. E ele tem uma ponte que injeta nele um `ConfigMap` com os dados literais do Ramal-PABX do MySQL para a query funcionar.
- **O Isolamento:** Ele APENAS POSSUI UM `Service (ClusterIP)`. Também é intocável pra hacker externo cru! A única forma de bater na API é vindo do Nginx/Ingress.

### Camada 3: Frontend e Ingress (Arquivo `04-frontend.yaml`)
- **Quem É:** O Site SPA/Nginx na ponta do Funil Web.
- **Exposição Segura:** Nós criamos um `Ingress` (A Recepcionista da Empresa) focada exclusivamente em rotear quem bater pelo DNS de URL "www.livrariak8s.com.br". Todo request da URL cai magicamente no Serviço Front, que bate no Nginx e retorna o html seguro.

---

### O Efeito Dominó do Deploy Completo Sênior
Quando você aplicar o Módulo 8, os robôs de controle `Kube-Controller-Manager` farão o seguinte milagre em frações de segundo:
1. Buscar disco na AWS pra faturar HDD (PVC do MYSQL).
2. Plugar PVC e ligar banco com token criptografado (Secret).
3. Levantar a API segurando o tráfego nela na marra (`ReadinessProbe`) até o Java confirmar que pingou o MySQL no IP fixo CoreDNS do ClusterIP.
4. Escalar dois Backend clones.
5. Ingress Nginx atualizando seu conf raiz de Proxy-Pass recebendo permissão pra jogar pacote do Crome do hospede pro Node isolado... Tudo sem você relar num terminal SSH.

*Bem Vindo ao mundo Cloud Native! Vá para o arquivo 02.*
