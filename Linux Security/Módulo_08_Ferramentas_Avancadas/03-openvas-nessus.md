# Módulo 8: Ferramentas Avançadas
## Aula 03 - OpenVAS / Nessus (Scan Automatizado de Redes e CVE NVD Integration)

### 1. ANALOGIA DO DIA A DIA
Se O NMAP é o Detetive de Polícia olhando janelas abertas do prédio...
O OpenVAS/Nessus é o Fiscal da Prefeitura com Drones Aéreos varrendo um Quarteirão Inteiro de forma orquestrada, abrindo um Checklist enorme de 123 mil folhas, ligando nos rádios de cada serviço, cruzando nomes de portas e testando centenas de trancas numa noite só. E no final da noite, eole te joga um Relatório Bonito PDF do Bairro em um Dashboard pra vender Compliance pra acionistas baseados em Códigos da CVSS vermelho pra assustar gerente financeiro.

### 2. O QUE É (definição técnica Senior)
Os Vulnerability Scanners corporativos operam centralizados no Database de Assinaturas (Feeds NVTs - Network Vulnerability Tests).
O OpenVAS (hoje Greenbone Vulnerability Manager) é a engine de core Open Source. O Nessus é o pago da Tenable (Líder Comercial).
As Ferramentas Integram o NMAP Scanner pra Port-Discover Base MAS... Elas escalonan injetando os feeds diários do próprio banco de dados MITRE CVE NVD pra "Testar Exploits sem causar Dano", e verificar com Certeza se O Apache XPTO rodante possui a flag de vulnerável (Authentication Bypass de API). Um Scanner tira o trabalho pesado do Analyst e te chuta direto pro Exploit da Vulnerabilidade que tu vai checar se falso positivo ou não e botar no excel de Risk.

### 3. SCRIPT / COMANDO COMENTADO
Ao invés de Linha de Comando de Script Bash, o OpenVAS/Nessus é Deploy de Arquitetura. Sêniors não o rodam da pasta com bash; Sêniors o invocam rodando Stack de Docker em KALI ou instâncias dedicadas.

```bash
# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Método mais Sênior/Limpo de Subir OpenVAS na Raiz pra não 
# foder o Redis/Postgre do Kali atual poluindo de packages C.!
# Instancia via Pod/Docker Compose Oficial (Greenbone Community).
# ============================================================

#!/bin/bash
# Não executar cegamente. Siga em maquinas preparadas com +4 gb ram.

echo "[+] Inicializando Stack Central de Gestão Greenbone Vulnerability (GVM) via container..."
# apt install docker-compose -y
# export DOWNLOAD_DIR=$HOME/greenbone-community-container && mkdir -p $DOWNLOAD_DIR
# cd $DOWNLOAD_DIR
# curl -f -L https://greenbone.github.io/docs/latest/_downloads/docker-compose-22.4.yml -o docker-compose.yml

# Isso puxa O Banco PostgreSQL gigante, o Redis db pro feed de cache, a camada Frontend SecurtiyAssistant
# E O SCANNER de CORE OSPD-OpenVas numa malha lúdica sem conflitos locais de SO. 
echo -e "\n[+] Baixando Feeds CVE Gb de dados e Ligando a Plataforma WEB de Scanner..."
# docker-compose -f $DOWNLOAD_DIR/docker-compose.yml -p greenbone-community-edition up -d
```

### 4. PASSO A PASSO
**Passo 1:** Dê start no container como manda acima. A porta 9392 Mapeia a Web.
**Passo 2:** Abre o FIrefox no kali web browser `http://127.0.0.1:9392`. Admin/admin padrão provido do docker file init configs.
**Passo 3:** Clique em "Task Wizard". Insira o IP alvo seu `192.168...200` da maquina vitima. (O NMAP no fundo ligará o motor, o DB de assinatura cruzará os VTS do nmap).
**Passo 4:** Vai almoçar (1hr as vzs demore). 
**Passo 5:** Baixe o PDF de Scans de Report. Tá lá um "CVSS 9.8 RED: Apache Log4j Unauthenticated RCE". A sua aula de scan terminou em 1 print pdf comercial!

### 5. VERIFICAÇÃO E TROUBLESHOOTING
Por que muitas vezes o teu Nessus ou OpenVas não Acha o LFI RCE ou coisas do Kernel qe nós vimos nos ultimos dias e os logs de nmap sim?
As ferramentas automáticas sofrem de limitacoes de **Scans Sem Credenciais**. Scans Unauthenticated batem na Rede Externa(Black Box). Ele nao tem COMO descobrir um `find SUID` ou `privesc root sudo l` dentro da máquina pq ele AINDA é black box. Para scanners como esses brilharem, eles possuem A aba "Athenticated / Credentialed Scan". O Scanner loga SSH de Verdade com as chaves dadas de Sysadmin q vc da a ele, e roda o LINPEAS doidão lá dentro como se fosse vc nativo (White box). Assim as CVES listam tudo de dentro e fora!

### 6. CONCEITO SENIOR (o "porquê" profundo)
"Falso Positivo" é a desgraça de Consultoria de Segurança Júnior. Quando um júnior passa o Nessus PDF report cru q mandou e anexa e diz pra empresa "Tem CVSS Critical 9 aq no Apache", O dev vai no apache, le a doc e vê q o cara fez um BlackPort patch nativo Debian sem mudar a versão numérica exibida na flag da web `-V`. O Scanner Nessus achou o "Header 2.3", comparou do banco banco, achou q é vuln. Mas o DEV backporteou a C code de segurança no Header velho faz 2 dias. Entao NÃO TÁ. O Sênior Ofensivo sempre usa O scan cm guia bússula p ele testar Com a Mão dele (PoC Manual com nc nmap curl) se o código Exploit bate ou foi bloqueada de ips, validando fisicamnte que FALSOS POSITIVOS Não enchem a mesa da gerencia do dev lixo.

### 7. PERGUNTA DE ENTREVISTA / CTF
**Pergunta:** "Explicar para o C-Level Business Master de Empresa (Diretoria): O Nessus encontrou a Falha X na Máquina de Contas Bancarias (Sem Net isolaca) pontuando a nota de risco CVSS Escopo `CVSS Base 8.5 Criticality`. E o Qualis/Openvas encontrou a Falha Y 'Mesmo código mas no FrontEnd Web Publico de Compras do Site dmz'. Mas essa a falha Y foi pontuada com um fraco `CVSS 4.5 Medium`. Qual vc conserta hoje na hora como gestor da crise de time de Blue e por que e se os numeros confudiram ele?"
**Resposta Esperada:** Consertamos primeiro a Falhas FrontEnd de Compras. Essa é a distinção teórica entre "Perigo Intrínseco vs SCOPO DE EXPLOITABILIDADE (Vector Risk)". A métrica de Calculo da NVD CVSS V3 calcula `(Network/AdjacentLocal) + (Auth Required) + (Complexidade)`. Como as Máquinas Web DMZ possum vetores Atacker Local: Network Public (AV:N e AC:L - complexidade Ligeira), A sua explorabilidade pra internet global RCE as torna os ativos Top #1 do incidente mesmo do score CVSS sendo mediano de base para danos. A máquina de contas do banco c/ bug critico cvss 8 de system destuction local so pode ser estourada SE E SOMENTE SE o atacante JÁ INVADIU LA DENTRO DA LAN REDE FECHADA DA EMPRESA e ta num teclado de intranet (Vector. AV:Local). Nós remediamos as portas expostas q derrubam o muro do perimetro primeiro! Risk Real = (CVSS Score * Atack Surface Reality). 
