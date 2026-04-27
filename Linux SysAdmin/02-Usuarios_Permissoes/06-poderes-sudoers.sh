#!/bin/bash
# ==============================================================================
# Aula 02.06: Usuários, Grupos e Permissões - Delegação do Olympo (Sudoers)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. ANALOGIA DO DIA A DIA
# ------------------------------------------------------------------------------
# Você tem um funcionário de limpeza novo no prédio (Um Usuário Comum). 
# Ele precisa de poder pra abrir a Sala dos Geradores (Tarefa Root) 
# PRA LIMPAR, mas SÓ ISSO!
# 
# Pior Cenário: O Síndico maluco dá a "Chave Mestra Universal" (Senha do Root) 
# pra limpar a sala. O cara pode acidentalmente desligar a luz do prédio todo.
#
# Cenário Sênior: O Síndico escreve NO CADERNO (O `/etc/sudoers`) uma regra assim:
# "O limpador Joãozinho pode virar Deus SOMENTE SE for pra usar a vassoura na 
# Sala X, e ele vai digitar A SENHA DELE COMO ASSINATURA". O nome desse caderno é Sudo.

# ------------------------------------------------------------------------------
# 2. O QUE É (definição técnica Senior)
# ------------------------------------------------------------------------------
# 'su' (Substitute User): Troca o seu Shell E UID local por outro (Root ou Pessoal). 
# Requer a senha DO ALVO (Uma vulnerabilidade colossal de senhas compartilhadas).
#
# 'sudo' (SuperUser DO): Um framework avançado de segurança governado por `/etc/sudoers`.
# Ele confere se VOCÊ (usuario que digitou o sudo) está mapeado para ter poder 
# de escalar privilégios (Escalation) baseado no seu ID e num Comando Específico.
# A melhor parte? Ele audita rigorosamente (logs) TUDO que você faz como Deus,
# e exige a SUA PRÓPRIA SENHA para autenticar o ato.

# ------------------------------------------------------------------------------
# 3. SCRIPT / ARQUIVO COMENTADO
# ------------------------------------------------------------------------------

# O 'Su' Velho (Método antigo - evite compartilhar senhas principais!).
su -                        # Tenta virar Root pra sempre. Pede a senha Mestra. (Não Use!)
su - alice                  # O Administrador vira a Alice (Root não precisa da senha dela).

# O 'Sudo' Sênior: Executando apenas 1 comando como Deus usando a sua senha.
# O log do servidor vai dedurar: "Elias mandou Reiniciar o NGINX as 10:00 da manhã".
sudo systemctl restart nginx # OBRIGATÓRIO (Compliance de Logs - Você só ganha poder nos SEGUNDOS de rodar o restart).

# Editando o Caderno Mágico das Leis Mundiais (Visudo)
sudo visudo                 # OBRIGATÓRIO: Abre seguro o /etc/sudoers.

# O que tem dentro do arquivo visudo (Exemplos Plenos):
# root    ALL=(ALL:ALL) ALL
# %sudo   ALL=(ALL:ALL) ALL      <-- Membros do Grupo sudo fazem qualquer coisa
# joao    ALL=(root) /bin/kill   <-- Regra Micro: O João pode SÓ matar processos como root. NADA MAIS.
# maria   ALL=(ALL) NOPASSWD: ALL <- A Maria é um bot Jenkins? Ela roda scripts GITHUB SEM DIGITAR SENHA.

# ------------------------------------------------------------------------------
# 4. COMANDOS PASSO A PASSO
# ------------------------------------------------------------------------------
# [COMANDO] sudo -i
# [SAÍDA ESPERADA] root@meuservidor:~#
# [O QUE FAZ] Inicia uma SESSÃO INTERATIVA COMPLETA (Root bash) invocando o
#             seu poder do /etc/sudoers. Use APENAS se tiver dezenas de manutenções 
#             complexas e não quiser ficar digitando 'sudo isso, sudo aquilo' toda hora.

# [COMANDO] visudo -c
# [SAÍDA ESPERADA] /etc/sudoers: parsed OK
# [O QUE FAZ] Validador lógico do caderno de Leis (-c = check syntax).

# ------------------------------------------------------------------------------
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# ------------------------------------------------------------------------------
# - ERRO: "Elias is not in the sudoers file. This incident will be reported."
#   A famosíssima tela do medo!
#   Você é um usuário novo, seu chefe júnior não te colocou no Grupo de Pulseira
#   `sudo` (Ubuntu) ou `wheel` (CentOS/RHEL). Toda tentativa que você fez hoje foi 
#   salva num LOG DO MEDO `/var/log/auth.log` que o SysAdmin SecOps avalia pra 
#   detectar ameaças internas de vazamento de credencial.
#   Solução (Via Root verdadeiro): `usermod -aG sudo Elias`.

# - EU USEI VIM /ETC/SUDOERS, FIZ UM ERRO DE DIGITAÇÃO E TRAVEI TODO O SERVIDOR!!!!
#   Meus Parabéns. O servidor inteiro "Brikou" (Virou tijolo). NINGUÉM NO MUNDO CONSEGUE
#   DAR O COMANDO "SUDO" PRA CONSERTAR O ARQUIVO DE SUDO QUE VOCÊ DANIFICOU.
#   REGRA VITAL: NUNCAA, NUUUNCAAA USE "NANO /ETC/SUDOERS" ou "VIM /ETC/SUDOERS" PRA CONFIGURAR!
#   USE EXCLUSIVAMENTE O COMANDO `visudo`. 
#   Por quê? Porque ele edita na Memória RAM. Quando você Manda Salvar, ele verifica
#   todos os Erros de Sintaxe. Se existir um Erro que Destrua o SO, ELE ABORTA O SALVAMENTO 
#   e preserva o Caderno Antigo intacto!

# ------------------------------------------------------------------------------
# 6. CONCEITO SENIOR (o "porquê" profundo)
# ------------------------------------------------------------------------------
# Como um DevOps Provisiona Nuvem (AWS/Terraform) usando NOPASSWD.
# Quando a Amazon sobe uma nova máquina Linux 100% pronta, como o software do "Ansible"
# consegue instalar pacotes Apache na máquina sem ter um "Humano pra teclar senha na tela"?
# 
# Pelo conceito de Passwordless Delegation. A nuvem injeta no Linux SecOps a Regra Mestra:
# `ubuntu ALL=(ALL) NOPASSWD: ALL`. (Nenhum prompt será emitido).
# ISSO É PERFEITO para um Robô. Mas é perigoso em servidores DMZ Públicos.
# A diferença entre Júnior Scripts vs Sênior Infraestrutura de Código é dominar
# o visudo pra dar a permissão EXCLUSIVA `NOPASSWD: /usr/bin/apt` para o Ansible!

# ------------------------------------------------------------------------------
# 7. PERGUNTA DE ENTREVISTA
# ------------------------------------------------------------------------------
# Entrevistador: "Você abriu um chamado pedindo permissão pra resetar o servidor Apache
# após o deploy das nossas Tags. A InfoSec (CyberSegurança) me diz que você configurou 
# o DROP-IN do sudoers dentro de `/etc/sudoers.d/joazinho` com as seguintes linhas:"
# joazinho ALL=(root) /usr/bin/systemctl restart httpd
# joazinho ALL=(root) /usr/bin/systemctl stop httpd
# 
# Entrevistador: "Nossa auditoria aprovou as duas políticas. Contudo, quando o joazinho tenta reiniciar
# digitando 'sudo systemctl restart httpd', ele é BARRADO de rodar, mesmo o nome 
# e caminhos estando corretos. Qual o erro?"
#
# Resposta Esperada: "O erro conceitual está no Shell Globbing/Redirecionamento
# de argumentos atrelados ao Binário Systemctl! O sudoers, por regra Paranoica
# Nativa (Defaults env_reset / secure_path), exige caminhos absolutos sim,
# porém, a validação de parâmetros do comando systemctl é estrita e exata na 
# string registrada. Se o usuário tentar passar flag diferente que não coincida
# letra-a-letra com o array do Visudo ele engasga! E se houver scripts concorrentes
# rodando aliases em runtime ele negará (Defaults requiretty). Pra contornar,
# precisamos autorizar o Curinga ou reativar o parser restrito se for apenas
# comandos diretos de restart unitário."
