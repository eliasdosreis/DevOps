#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Módul avançado desvendendo o mistério profundo das permissões
# ocultas SUID (Set User ID), SGID, e o conceito imortal 
# do Umask de ambiente. A Magia obscura dos bits!
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# SUID Bit (`s` na permissão do arquivo). 
# - A sala de TI tem cofre. Só o Dono (Root) entra (`rm` e `su`).
# - Mas você é apenas Funcionario Normal (Elias) tentando trocar de senha no RH.
# Como você muda sua senha, se sua senha deve ser salva no cofre do Owner(Root)?
# O SUID Bit é o "Crachá do Chefe Emprestado Momentaneamente". Enquanto você roda
# o programa `passwd`, o gerente Linux diz "Por estar usando essa Ferramenta Mágica, nos proximos 2 segundos, Elias você age com o corpo do Deus Linux Root", e consegue gravar no cofre. Ao fechar a key some. E é por isso que virus odeiam SUID.
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# Especial Bits Modifier: SUID (Set User ID=4), SGID (Set Group ID=2), StickyBit (Restricted Deletion=1).
# Quando escalados nas máscaras clássicas octais `chmod 4755`: Elevam permissões operacionais do programa instanciado via Exec em kernel.
# Umask (User file creation mode mask): Macro baseada no bitwise Negativo de POSIX permission (022 revoga W pra Grupos).
# ============================================================

set -euo pipefail

# ============================================================
# 3. SCRIPT COMENTADO
# ============================================================

echo "=== O Lado Oculto do FHS e Suas Permissões ==="

echo "1. Olhando como o UMASK define quem 'Não entra' na sua festa"
# UMASK: "Quais cores de blusa eu OBRIGO a ficar de fora das novas pastas e arquivos?"
# A Bash pega a perfeição teórica (777 ou 666 na ram) e SUBTRAI o umask!
MASCARA_ATUAL=$(umask)
echo "   - O Umask protetor ATUAL do bash é: $MASCARA_ATUAL"

# Se o Umask é 0022 -> Pastas que seriam 777 nascem (777-022) = 755 ! (Donos full, resto Ler e Exe). 
# Arquivos nascem com zero 'x' por segurança kernel -> 666 - 022 = 644!
echo "2. O Sticky Bit 'T' ('t' no final do ls de Permissão). A pasta Sagrada: /tmp"
# O Sticky Bit diz: SOMENTE O DONO de sua caneta tem perm de Apagar Sua Caneta... NA MESMA MESA q 10 colegas tmb tem permissao maxima.
# Vemos na letra t: drwxrwxrwt
ls -ld /tmp

echo ""
echo "3. A mágica Sênior perigosa: O SUID (`s` de Set-user-ID) - O Root disfarçado"
echo "   - Olhe atenciosamente a permissão do executavel do SUDO:"
# A Permissão exibe um incrivel `-rwsr-xr-x`. Esse 's' pequeno substitui o 'x' do dono! (SUID=4000)
ls -l $(which sudo)
echo "...O 's' no root dono (rws) significa SUID activo. Um user q não é root vai poder abrir o arquivo, rodar e ganhar escopo."

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - Como dar chown sem recursivo estúpido e com moderação: `chown -R usuario:grupo pasta/`
# - Como arrancar um StickyBit maldoso ou setar Umask: `umask 077` (Se você for Hacker da NSA. Se o umask for 077, tudo q for gerado agora, os the-others e the-group nunca terão rwx da maquina de ngm).
# - Como dar SUID no seu script: `chmod 4755 proxy_network.sh` (Octal de 4 = SUID).
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - Meu `chmod 4755 meu_script.sh` NÃO DEU SUID. Continuo normal ao iniciar não vira root!
#   O que é: Kernel Posix/Linux moderno IGNORAM TOTALMENTE SUID PARA ARQUIVOS SHELL/INTERPRETADOS TEXTUAIS. (Se não, 1 milhão da falhas e malwares rodaria no planeta no Dia 1).
#   Solução Sênior: SUID em Linux só funciona se o Binário for compilado bruto e linkado nativo (C Lang ou Go /bin/ELF). Se quiser executar um shellscript como superadmin na marra dos permissions, force o sysadmin a liberar regra explíticamente no `/etc/sudoers`.
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe um motivo pro SUID do Ping? Sim!
# Por que o icônico comando de network `ping` antigamente precisava de SUID `-rwsr-xr-x root root... ` ? E por que em CentOs/Ubuntu20 ele perdeu hoje o SUID e funciona normal pra user não rootes?
# O `ping` trabalha abrindo RAW SOCKETS e manipulando ICMP no Kernel IP Layer. Apenas administradores (Roots) tem permissões puras TCP stack do C kernel para fazer isso. Por isso do SUID pra mortais pedirem ping!
# Atualmente os modern Linux adotaram o 'CAPABILITIES FRAMEWORK' (`setcap`), concedendo poderes atomicos fragmentados para binários em vez do martelão divino SUID. Hoje eles recebem apenas a flag sys network atômica sem necessitar ser Root!
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Se nós temos o ACL (Access Control Lists) pra granular `setfacl` dar read ao Joaoziho sem precisar estar no GRUPO... Num file file1 que exiba uma permissao 'ls' drwxrwx---+ ... oq significa e avisa esse MAIS (+) de sufixo pra vc DevOps?"
# Resposta Sênior: A Presença esdrúxula do sufixo POSITIVO/MAIS (`+`) ao final das colunas 10 de permissões UGO clássicas é a Flag Explicita de marcação do sistema Ext4/XFS que o arquivo POSSUIN ENTRADAS DE FACL (File ACL list). Apenas rodar `ls -l` alí vai mentir descaradamente pra vc sobre os direitos daquele file mascarados nos RWX. Vc precisa obrigatóriamente dar parse do true-access rodando debaixo dos panos o read program: `getfacl filename`.
# ============================================================
