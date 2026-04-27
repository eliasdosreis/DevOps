#!/bin/bash
# ==============================================================================
# Módulo 12 — Monitoramento e Observabilidade de VMs KVM
# Prometheus + Grafana + Alertmanager + libvirt-exporter
# ==============================================================================
#
# 1. ANALOGIA DO DIA A DIA
#
# Imagine um hospital de UTI com 50 pacientes (suas VMs).
# SEM monitoramento: Uma enfermeira passa de cama em cama a cada hora
# verificando temperatura. Se o paciente teve febre às 3:42am, ninguém saberá.
#
# COM monitoramento (Prometheus + Grafana):
# - Cada cama tem sensores automáticos (exporters) medindo temperatura/pulso a cada 5s
# - Uma tela central (Grafana) exibe gráficos históricos de TODOS os pacientes
# - Um sistema de alertas (Alertmanager) liga para a enfermeira se temperatura > 38°C
# - O histórico fica salvo para análise posterior (séries temporais — TSDB)
#
# 2. DEFINIÇÃO TÉCNICA SÊNIOR
#
# Prometheus é um banco de dados de séries temporais (TSDB) que PUXA (scrape)
# métricas de endpoints HTTP (/metrics) em intervalos configurados.
# O libvirt-exporter expõe métricas KVM via API virsh/libvirt em formato Prometheus.
# O Alertmanager roteia alertas (email, PagerDuty, Slack) quando regras de alerta disparam.
# ==============================================================================

set -euo pipefail

echo "============================================"
echo " Módulo 12 — Stack de Monitoramento KVM"
echo "============================================"

# ==============================================================================
# 3. INSTALANDO O LIBVIRT-EXPORTER
# ==============================================================================

echo ""
echo "=== PASSO 1: Instalar o Libvirt Prometheus Exporter ==="

# O prometheus-libvirt-exporter expõe métricas KVM via HTTP :9177/metrics
# GitHub: https://github.com/digitalocean/prometheus-libvirt-exporter

# Instalar via pacote (se disponível):
# apt install prometheus-libvirt-exporter  # Ubuntu 22.04+

# Ou via binário direto:
cat <<'INSTALL'
# Download e instalação manual:
EXPORTER_VERSION="1.0.0"
wget https://github.com/digitalocean/prometheus-libvirt-exporter/releases/download/v${EXPORTER_VERSION}/prometheus-libvirt-exporter_${EXPORTER_VERSION}_linux_amd64.tar.gz
tar xzf prometheus-libvirt-exporter_*.tar.gz
mv prometheus-libvirt-exporter /usr/local/bin/
chmod +x /usr/local/bin/prometheus-libvirt-exporter

# Criar service systemd:
cat > /etc/systemd/system/prometheus-libvirt-exporter.service << 'SYSTEMD'
[Unit]
Description=Prometheus Libvirt Exporter
After=libvirtd.service

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/prometheus-libvirt-exporter \
  --libvirt.uri=qemu:///system \
  --web.listen-address=:9177
Restart=always
RestartSec=5s

[Install]
WantedBy=multi-user.target
SYSTEMD

systemctl daemon-reload
systemctl enable --now prometheus-libvirt-exporter
INSTALL

echo ""
echo "=== PASSO 2: Verificar métricas expostas ==="
cat <<'METRICS_EXAMPLE'
# Após instalação, acessar: curl http://localhost:9177/metrics
# Exemplo de métricas expostas:

# Domínios em execução:
libvirt_domain_state{domain="vm-web-01",state="running"} 1

# CPU utilizada pela VM (nanosegundos acumulados):
libvirt_domain_cpu_time_seconds_total{domain="vm-web-01"} 1234567.89

# Memória RAM usada pela VM (bytes):
libvirt_domain_memory_used_bytes{domain="vm-web-01"} 2147483648

# I/O de disco (bytes lidos/escritos):
libvirt_domain_block_stats_read_bytes_total{domain="vm-web-01",disk="vda"} 98765432
libvirt_domain_block_stats_write_bytes_total{domain="vm-web-01",disk="vda"} 12345678

# Tráfego de rede:
libvirt_domain_interface_stats_receive_bytes_total{domain="vm-web-01",interface="vnet0"} 5678901
libvirt_domain_interface_stats_transmit_bytes_total{domain="vm-web-01",interface="vnet0"} 1234567
METRICS_EXAMPLE

# ==============================================================================
# 4. CONFIGURAÇÃO DO PROMETHEUS
# ==============================================================================

echo ""
echo "=== PASSO 3: Configurar Prometheus para raspar métricas KVM ==="

cat <<'PROMETHEUS_CONFIG'
# /etc/prometheus/prometheus.yml

global:
  scrape_interval: 15s       # Coletar métricas a cada 15 segundos
  evaluation_interval: 15s   # Avaliar regras de alerta a cada 15s
  external_labels:
    datacenter: 'dc-producao'
    environment: 'production'

# Configuração do Alertmanager
alerting:
  alertmanagers:
    - static_configs:
        - targets: ['alertmanager:9093']

# Importar regras de alerta
rule_files:
  - '/etc/prometheus/rules/kvm-alerts.yml'

scrape_configs:

  # Métricas do próprio Prometheus (automonitoramento)
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  # Métricas dos nós KVM (CPU, RAM, disco, rede do HOST)
  - job_name: 'node-exporter'
    static_configs:
      - targets:
          - 'kvm-node-a:9100'
          - 'kvm-node-b:9100'
    relabel_configs:
      - source_labels: [__address__]
        regex: '([^:]+):.*'
        target_label: instance

  # Métricas das VMs KVM (via libvirt-exporter)
  - job_name: 'libvirt'
    static_configs:
      - targets:
          - 'kvm-node-a:9177'
          - 'kvm-node-b:9177'
PROMETHEUS_CONFIG

# ==============================================================================
# 5. REGRAS DE ALERTA KVM
# ==============================================================================

echo ""
echo "=== PASSO 4: Criar regras de alerta para KVM ==="

cat <<'ALERT_RULES'
# /etc/prometheus/rules/kvm-alerts.yml

groups:
  - name: kvm.rules
    interval: 30s
    rules:

      # Alerta: VM consumindo > 90% da CPU por mais de 5 minutos
      - alert: VMCpuHighUsage
        expr: |
          (
            rate(libvirt_domain_cpu_time_seconds_total[5m])
            / on(domain) libvirt_domain_vcpu_maximum
          ) > 0.90
        for: 5m
        labels:
          severity: warning
          team: infra
        annotations:
          summary: "VM {{ $labels.domain }} com CPU alta"
          description: "VM {{ $labels.domain }} usando {{ $value | humanizePercentage }} de CPU por >5 min"
          runbook: "https://wiki.empresa.com/runbooks/vm-cpu-alta"

      # Alerta CRÍTICO: VM parou de responder (não aparece mais nas métricas)
      - alert: VMDown
        expr: absent(libvirt_domain_state{state="running"})
        for: 2m
        labels:
          severity: critical
          page: "true"   # Aciona PagerDuty
        annotations:
          summary: "VM desapareceu das métricas!"
          description: "Nenhuma VM em estado 'running' detectada no nó há 2 minutos"

      # Alerta: Disco da VM > 85% de uso de I/O wait
      - alert: VMDiskIOHigh
        expr: |
          rate(libvirt_domain_block_stats_write_bytes_total[5m]) > 500e6
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "VM {{ $labels.domain }} disco {{ $labels.disk }} saturado"
          description: "Write rate: {{ $value | humanize }}B/s por >10 min"

      # Alerta: Memória RAM da VM > 90% usada
      - alert: VMMemoryHigh
        expr: |
          (libvirt_domain_memory_used_bytes / libvirt_domain_memory_maximum_bytes) > 0.90
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "VM {{ $labels.domain }} com memória alta"
          description: "{{ $value | humanizePercentage }} da RAM usada"

      # Alerta: Host KVM com > 95% CPU (pode causar problemas nas VMs)
      - alert: KVMHostCpuCritical
        expr: |
          100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 95
        for: 3m
        labels:
          severity: critical
        annotations:
          summary: "Host KVM {{ $labels.instance }} CPU crítica"
          description: "Host com {{ $value }}% CPU — VMs em risco de degradação"
ALERT_RULES

# ==============================================================================
# 6. COMANDOS VIRSH PARA MÉTRICAS EM TEMPO REAL (SEM PROMETHEUS)
# ==============================================================================

echo ""
echo "=== COMANDOS VIRSH ESSENCIAIS DE MONITORAMENTO ==="

# Métricas de CPU de todas as VMs em execução
echo "# CPU stats de todas as VMs:"
echo "virsh list --name | xargs -I{} sh -c 'echo \"{}: \"; virsh cpu-stats {} --total'"

# Métricas de memória
echo ""
echo "# Memória de todas as VMs:"
echo "virsh list --name | while read vm; do"
echo "  echo \"=== \$vm ===\""
echo "  virsh dommemstat \$vm"
echo "done"

# Métricas de disco
echo ""
echo "# I/O de disco:"
echo "virsh domblkstat vm-producao-01 vda"

# Métricas de rede
echo ""
echo "# Tráfego de rede:"
echo "virsh domifstat vm-producao-01 vnet0"

# Stats completas (usado pelo Prometheus libvirt-exporter internamente)
echo ""
echo "# Stats completas (formato rico):"
echo "virsh domstats vm-producao-01 --state --vcpu --balloon --block --net --perf"

echo ""
echo "Configuração de monitoramento concluída!"

# ==============================================================================
# 7. PERGUNTA DE ENTREVISTA (Nível Sênior)
# ==============================================================================
cat <<'INTERVIEW'

PERGUNTA DE ENTREVISTA (Nível Sênior):

"Você recebe um alerta às 2am: 'vm-oracle-db está com CPU 98% por 10 minutos'.
Descreva sua análise sistemática para identificar se é:
(a) workload legítimo (batch noturno),
(b) problema de performance (CPU steal),
(c) incidente de segurança (cryptominer),
(d) bug de aplicação (loop infinito)."

RESPOSTA ESPERADA:
"Análise em camadas — começando pelo menos invasivo:

1. CONTEXTO TEMPORAL (30 segundos):
   Verificar no Grafana se há padrão recorrente neste horário.
   Oracle tem batches noturnos? Se sim → provavelmente legítimo.
   Primera vez? → investigar.

2. PERSPECTIVA DO HOST (2 minutos):
   `virsh domstats vm-oracle-db --vcpu` — quais vCPUs estão saturadas?
   `virsh cpu-stats vm-oracle-db` — é CPU time ou steal time?
   Se steal time alto → problema no HOST (overcrowding de VMs).

3. PERSPECTIVA DA VM — sem login ainda (1 minuto):
   `virsh qemu-monitor-command vm-oracle-db --hmp 'info cpus'`
   Ver o que o QEMU reporta internamente.

4. DENTRO DA VM (via SSH):
   `top` e `ps aux --sort=-%cpu | head -10` — qual processo consome?
   Se for 'ora_*' (Oracle process) → pode ser consulta pesada.
   Se for processo desconhecido ('kworker', 'python3 -c ...') → ALERTA SEGURANÇA!

5. REDE — INDÍCIO DE CRYPTOMINER:
   `virsh domifstat vm-oracle-db vnet0` — tráfego saindo alto sem entrada = suspeito.
   `ss -tlnp` dentro da VM — conexões para IPs externos desconhecidos?

6. AÇÃO BASEADA EM DIAGNÓSTICO:
   (a) Legítimo → sem ação, criar annotation no Grafana para histórico
   (b) Steal time → migrar VMs para outro nó: virsh migrate --live
   (c) Criptominer → ISOLAMENTO IMEDIATO da rede + snapshot forense + análise
   (d) Loop infinito → notificar DBA para análise de query + trace Oracle AWR"
INTERVIEW
