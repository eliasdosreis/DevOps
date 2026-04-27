#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# A Evolução Sênior do Cron! Mostra a mecânica por trás de um
# .Timer unit e Service do SystemD (O Gerente Moderno Mestre
# do Linux Centos7+/Ubuntu16+) para agendamentos resilientes.
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# O cron era um relógio velho de cabeceira barato. Tocou a hora, apita. Acabou.
# O SystemD Timers é uma Secretaria Executiva com contrato.
# Ela sabe (Service Mapeado) o que vc vai rodar.
# Ela olha se vc não tá rodando pra não dar sobrecarga.
# Se o computador reinicou num pique de luz e perdeu a hora 15h00... quando 16h00 o pc ligar, 
# a secretária fala: "Opa, chefe se fudeu, Perdi a hora! Deixa eu rodar agora o que atrasei!" (Anacron persistente).
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# Systemd `*.timer` units coordenam trigaggins para units primárias de `*.service`.
# Permitem controle estrito de `cgroups` (Limite de RAM/CPU), logging acoplado unificado 
# ao `journalctl`, resolução de concorrência inerente (não encavalam) e Wakeup Catchups (Persistent=true).
# ============================================================

set -euo pipefail

# ============================================================
# 3. SCRIPT COMENTADO -- TEMPLATE SIMULADO DOS ARQUIVOS
# ============================================================

echo "=== Systemd Timers (A Evolução) ==="

# Para usar o timer, você não cria 1 arquivinho, vc declara DUAS peças no Linux:
# 1) O Service (O que será feito?). Fica em /etc/systemd/system/meu_bkp.service
# 2) O Timer (Quando será feito?). Fica em /etc/systemd/system/meu_bkp.timer

# Exemplo de conteúdo [meu_bkp.service]
# ---------------------------------------------
# [Unit]
# Description=Roda meu Script de Backup
#
# [Service]
# Type=oneshot
# ExecStart=/usr/local/bin/meu_backup.sh
# ---------------------------------------------

echo "1. Mostrando a inteligência brutal de um Arquivo TIMER!"
# Exemplo de conteúdo [meu_bkp.timer] 
# (Tudo legível a humanos em inglês, e não mais em zeros * * *)
# ---------------------------------------------
# [Unit]
# Description=Cronometro inteligente p/ Bkp
#
# [Timer]
# OnCalendar=*-*-* 02:00:00
# Persistent=true 
#
# [Install]
# WantedBy=timers.target
# ---------------------------------------------

echo "- Com [OnCalendar] você cria Agendas diárias human-readbale."
echo "- Com [Persistent=true], se o Server desligou as 01:50 e religou as 08:30 (Perdendo as 2 da manha)... ele Ativará o backup IMEDIATAMENTO compensatóriamente ao dar Boot!" 
echo "- O `Type=oneshot` do service IMPEDE que um novo timer dispare se o antigo Job de Oneshote não tiver dado Finished/Exit. Sem concorrência fatal em Discos (Overlaps)!"

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - Após criar esses 2 aquivos no `/etc/systemd/system/`:
#   1. Recarregue os dragoes: `sudo systemctl daemon-reload`
#   2. Ative o timer pra ligar com o PC: `sudo systemctl enable meu_bkp.timer`
#   3. Ligue o pulso/relogio agora: `sudo systemctl start meu_bkp.timer`
#   4. Olhe todos os cronometros girando ao vivo no dashboard: `systemctl list-timers --all`
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - Meu Timer dispara, mas depois de 30 minutos o Ubuntu MATA MEU SCRIPT na marra (Timeout). O Cron deixava eu rodar sem fim!
#   O que é: O SystemD amarra todo System Unit Type num Timeout global (Default de 90 segundos a infinitos). Se for Type=oneshot, pode ejetar dependencias e kill.
#   A solução: Para pipelines pesados, certifiquese de configurar o Unit dele com: `TimeoutStartSec=0` e `TimeoutStopSec=3500` p garantir que o systemManager Linux nao aborte sua job thread Cgroup prematuramente.
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# "Por que o SRE ama a Loggagem do Timers invés do Cron?"
# Porque o `cron` engole C-Error Stderros em mails root se vc nao canalizar (>> log 2>&1). 
# O SystemD é o mestre unificador! Se você criar um systemd Timer, todo EXATO `echo "A"` ou erro q seu script cuspir vai automático ser centralizado no Journal RingBuffer Nativo!
# Se seu script.sh rodado pelo timer quebrar mes passado, vc entra na maquina e roda `journalctl -u meu_bkp.service --since "1 month ago"` e os Logs do bash script estarao la em vermelho e amarelo com timestamps gloriosos, sem voce ter configurado NADA no bash!
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Se eu tiver OBRIGATORIAMENTE q rodar um container docker como serviço auto-inicializado e gerenciado num sistema On-premise sem Kubernetes... Systemd timers / services é o path correto?"
# Resposta Sênior: Absolutamente! O daemon do docker só cuida primariamente da runC. Para auto-healing OS-level native, amarra-se o runtime (e.g. `ExecStart=/usr/bin/docker run --name myapp alpine`) num systemd service com Policy Retry `Restart=always` . Porém, atenção crucial: No Service file do systemd Docker containers não podem ser disownhados pelo bash; exige-se sempre `Type=simple` acoplado ao parametro dockeresco foreground de `-a / Sem -d`. O Daemon systemd monitorará o entrypoint principal do docker anexando sua saude com o host.
# ============================================================
