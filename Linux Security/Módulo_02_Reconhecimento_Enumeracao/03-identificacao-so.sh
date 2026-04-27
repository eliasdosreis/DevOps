#!/bin/bash
# ==============================================================================
# Módulo 2: Reconhecimento e Enumeração
# Aula 03 - Identificação de OS (OS Fingerprinting e TTL)
# ==============================================================================
#
# 1. ANALOGIA DO DIA A DIA
# Num país onde muitas pessoas usam roupas iguais e óculos de sol, como você pode 
# saber de qual Região do país uma pessoa vem se ela se nega a te contar a cidade dela? 
# Facilmente. Analisando o *SOTAQUE* (Fingerprinting). No ciberespaço, toda máquina na Internet
# ao mandar um simples "Sinal da Cruz" ping ou "Sim estou Vivo" de HTTP, joga minúsculos 
# sotaques na maneira como constrói os Pacinhos Elétricos e IP Packets. O Windows, o 
# Linux ou FreeBDS de Cisco, agem e reagem de maneira diferente a certos comprimentos das respostas.
# Pelo "sotaque" do TCP/IP da resposta, cravamos e identificamos que o cara no telefone, é, na real,
# um Roteador Core ou um Linux Debian 10.
#
# 2. O QUE É (definição técnica Senior)
# O OS Fingerprinting mede certas reações na montagem da Pilha (Stack) de Protocolos IP, 
# especificamente testadas em heurística comparativa das RFC (Request For Comments) vs a realidade. 
# TTL (Time To Live): Tempo de pulos entre routers antes que o pacote evapore. E por padronização 
# da indústria histórica: 
#      - Linux TTL Default = 64
#      - Windows TTL Default = 128
#      - Dispositivos IoT / Cisco TTL = 255.
# Associado o TTL do Ping bruto ao tipo de preenchimento dos Bytes do Window Size e o Fragment Bit, 
# a base do p0f (Scanner Passivo), ou o `nmap -O` cravam com % de certeza a Kernel Version subjacente do Alvo.
#
# ==============================================================================
# 3. SCRIPT / COMANDO COMENTADO
# ==============================================================================

# Defensivo Passivo / Ninja do Red Team: OS Identify usando Ping
# Nós damos 1 disparo ICMP limpo no alvo de forma orgânica, sem scanner na rede pra não queimar.
# Lemos do pacote o TTL. Como a Internet / Lan pode ter alguns Hubs e Roteadores que "Diminuirão" 
# esse valor em -1,-2... Nós arredondamos em memória pra ver de qual classe (64, 128, 255) o pacote derivou!

TARGET_IP="127.0.0.1"

echo "[+] Executando método Fingerprint Artesanal em $TARGET_IP:"
ttl=$(ping -c 1 $TARGET_IP | grep -o "ttl=[0-9]*" | cut -d '=' -f 2)

if [ ! -z "$ttl" ]; then
    echo "[!] TTL Recebido = $ttl"
    if [ "$ttl" -gt 0 ] && [ "$ttl" -le 64 ]; then
        echo "[!!!] Diagnóstico Passivo: Alta Chance de ser um Sistema LINUX / UNIX / BSD."
    elif [ "$ttl" -gt 64 ] && [ "$ttl" -le 128 ]; then
         echo "[!!!] Diagnóstico Passivo: Alta Chance de ser ambiente WINDOWS da MS."
    elif [ "$ttl" -gt 128 ] && [ "$ttl" -le 255 ]; then
         echo "[!!!] Diagnóstico Passivo: Possível roteador CORE CISCO / Solaris Clássico."
    fi
else
    echo "[-!] Alvo Inacessível para o teste PING (Dropped)."
fi

# Utilizando Scanner Específico para Fingerprint Mágico e Completo (Precisamos de UID-0 do linux pra o Kernel raw mode).
# -O -> Ativa a engine de adivinhação do OS do Nmap. O Nmap mandar pacotes bugados propostos e analisa deflexões da pilha stack 7x vezes pra preencher o confidence % rating. (ex 98% de chance Ser Ubuntu Linux kernel 5.x)
# --osscan-guess força agressivamente a dizer q sistema que não tá no DB pode parecer com o que.
echo -e "\n[+] Executando Advanced OS Fingerprinting (Precisa Root):"
# sudo nmap -O --osscan-guess $TARGET_IP
#
# ==============================================================================
# 4. PASSO A PASSO
# ==============================================================================
# Passo 1: Dispare ping numa máquina windows e veja na sua mente a regra TTL=128 da formula, mas lembre-se, de São Paulo pra Alemanha o tráfego passa em 5 routers e decai em 5 pontos o TTL. Ele pode dar na sua tela TTL=121. Se é 121, e está abaixo e próximo de 128, Windows.
# Passo 2: Mas isso apenas diz Família (NT ou GNU/Linux). O verdadeiro Hacker quer a versão Kernel Kernel 3.12 ou 5.4! Rodemos sudo nmap -O -p22,80 <IP Alvo>. A saída gerada dirá: `Aggressive OS guesses: Linux 4.15 - 5.6 (95%), Linux 5.3 - 5.4 (95%)`.
#
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# Por que o NMAP só cospe "Too many fingerprints for this host. OS scan failed"? Porque para a mágica da heurística adivinhação TCP do nmap funcionar, você PRECISA, obrigatoriamente, fornecer uma porta sabida FECHADA do Alvo (pro SO enviar pacotes de rejects Reset flag, que tem seu próprio sotaque) e uma porta sabida ABERTA pra completar o puzzle RST+SYN/ACK. Se uma VM na AWS tiver Security Group block total drop, ou você deu `-O` mas sem achar portas, o scanner não adivinha.
# 
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe um motivo pro Sênior não acreditar 100% no `-O` NMAP da DMZ. Se as requisições estão passando num firewall de NGFW como A10, F5 BIG-IP / WAF, essas mega-máquinas corporativas funcionam em arquitetura de "Web Reverse Proxy / TCP Splice". ELES finalizam a sua conexão TCP fora da empresa (O seu hand-shake nunca nem sequer tocou no servidor real Apache linux de dentro!). Todo o Fingerprint das flags TCP, SACK e TLL, será O FINGERPRINT DA MÁQUINA DE SEGURANÇA FW. Vc vai achar é FreeBSD ao inés da real, e seus exploits de Windows vão dar timeout frustrando. O pentester Sênior deduz a camada de proxy observando diferenças minúsculas de timestamps no `TCP Options` passivo do wireshark pra quebrar essas premissas mentrosas.
#
# 7. PERGUNTA DE ENTREVISTA / CTF
# Pergunta: "Seu CTO da Equipe Azul está puto porque nas auditorias mensais seus roteadores Linux Ubuntu DMZ aparecem fácil pra script kiddies como Linux via scan NMAP revelador de OS e eles tentam RCEs neles achando ser alvos viáveis, causando poluição por ruídos IPS. O CTO manda vc Ofuscar o Sistema contra Nmap básico com os recursos nativos, sem instalar software extra ou quebrar rede, mascarando ou camuflando pro ping que o TTL é de um servidor antigo 'Windows' pra trolar os Bots e parar o ruído. Como tu faria?"
# Resposta Esperada: Sabendo que o Stack IPv4 é controlável via variáveis de Kernel pelo sysctl no run-time, eu edito o arquivo paramétrico live: `/proc/sys/net/ipv4/ip_default_ttl` . Se eu dropar um `echo 128 > /proc/sys/net/ipv4/ip_default_ttl`, as próximas respostas ICMP Ping e os pacotes originários SYN/ACK do Apache já carregarão TTL 128. Hackers preguiçosos automatizadores verão e suas scripts irão dropar e focar em windows pra tentar smb-exploits que retornarão zero (pois eu nem fechei nada nem abri portas). Torna minha assinatura de pilha falsificada!
