# 🎯 Guia de Entrevista Técnica Sênior - Kubernetes

## Perguntas GARANTIDAS e como responder

---

## 🔵 Nível 1 - Conceitos Fundamentais

**"O que é Kubernetes e por que usamos?"**
> K8s é um orquestrador de containers. Resolve:
> automatizar deploy, escalar, self-healing e service discovery.
> Sem K8s: você gerencia cada servidor manualmente.
> Com K8s: você descreve o estado desejado, ele garante.

**"Qual a diferença entre Pod e Container?"**
> Container = processo isolado (Docker).
> Pod = envelope K8s com 1+ containers compartilhando
> rede (mesmo IP) e volumes. Menor unidade deployável do K8s.

**"Qual a hierarquia: Deployment, ReplicaSet, Pod?"**
> Deployment gerencia ReplicaSets.
> ReplicaSet gerencia Pods.
> Deployment --> ReplicaSet --> Pod(s)
> Você cria Deployment. K8s cria os outros automaticamente.

---

## 🟡 Nível 2 - Serviços e Rede

**"Tipos de Service e quando usar cada um?"**
> ClusterIP: interno ao cluster. Padrão. Comunicação entre pods.
> NodePort: expõe via porta no nó. Dev/teste. Range 30000-32767.
> LoadBalancer: IP externo na nuvem. Produção. Caro se muito uso.
> ExternalName: aponta para DNS externo. Para serviços fora do cluster.

**"O que é Ingress e por que usar?"**
> Ingress = roteamento L7 (HTTP/HTTPS) para múltiplos Services.
> Sem Ingress: 1 LoadBalancer por Service = caro!
> Com Ingress: 1 LoadBalancer + regras por host/path = econômico.

**"Como pods se descobrem no cluster (Service Discovery)?"**
> DNS interno (CoreDNS). Todo Service vira um registro DNS.
> http://nome-service.namespace.svc.cluster.local
> Dentro do mesmo namespace: basta usar o nome: http://api

---

## 🟠 Nível 3 - Configuração e Storage

**"Diferença entre ConfigMap e Secret?"**
> ConfigMap: configurações não-sensíveis em texto puro.
> Secret: dados sensíveis em base64 (NÃO é criptografia!).
> Para segurança real: Secret + etcd encryption + Vault.

**"O que é PV, PVC e StorageClass?"**
> StorageClass: como o storage é provisionado (tipo/fabricante).
> PersistentVolume: disco físico ou lógico disponível.
> PersistentVolumeClaim: pedido de um pod por storage.
> PVC se "casa" com PV compatível automaticamente.

**"O que é Dynamic Provisioning?"**
> StorageClass cria o PV automaticamente quando um PVC é criado.
> Não precisa criar PV manualmente. Modo preferido em produção.

---

## 🔴 Nível 4 - Avançado (Sênior Real)

**"Como garantir zero downtime no deploy?"**
> 1. Deployment com RollingUpdate
> 2. maxUnavailable: 0 (nunca reduz pods durante update)
> 3. Readiness Probe correta (novo pod só entra se pronto)
> 4. preStop hook (drena conexões antes de morrer)
> 5. terminationGracePeriodSeconds adequado
> 6. Mínimo 2 réplicas SEMPRE

**"Liveness vs Readiness vs Startup Probe?"**
> Liveness: "Está vivo?" -> falhou = reinicia container
> Readiness: "Está pronto?" -> falhou = remove do Service (não reinicia)
> Startup: "Terminou de iniciar?" -> protege apps lentos no início
> Regra de ouro: Liveness NUNCA checa o banco! (causaria reinício em cascata)

**"O que é RBAC e princípio do menor privilégio?"**
> RBAC controla quem pode fazer o quê no cluster.
> ServiceAccount = identidade do pod
> Role = lista de permissões (verbs + resources)
> RoleBinding = associa SA com Role
> Menor privilégio: dar apenas o mínimo necessário para funcionar.

**"HPA vs VPA vs KEDA?"**
> HPA: escala horizontal (mais pods). Stateless apps.
> VPA: escala vertical (mais CPU/RAM). Apps com estado.
> KEDA: escala por métricas customizadas (filas, eventos Kafka/SQS).

**"O que acontece quando um nó falha?"**
> 1. Node Controller detecta nó não responsivo (~40s)
> 2. Nó marcado como NotReady
> 3. Após ~5min: pods marcados para evicção
> 4. Scheduler reagenda pods em outros nós
> 5. PDB garante mínimo de pods disponíveis durante o processo

**"O que é etcd e por que é crítico?"**
> etcd é o banco de dados do cluster (chave-valor distribuído).
> Guarda TUDO: estado dos pods, configs, secrets, etc.
> Se etcd morrer: cluster para de funcionar (não destrói pods)
> Boas práticas: backup regular, mínimo 3 instâncias, etcd separado.

**"Explique o fluxo de criação de um pod (kubectl apply até rodar)"**
> 1. kubectl envia YAML para kube-apiserver
> 2. apiserver valida e salva no etcd
> 3. Scheduler encontra nó adequado (resources, affinity, taints)
> 4. kubelet do nó recebe a instrução
> 5. kubelet chama o container runtime (containerd/docker)
> 6. Runtime puxa imagem e inicia container
> 7. kubelet reporta status de volta ao apiserver
> 8. Probes verificam saúde do pod

---

## 💡 Dicas de Ouro para a Entrevista

1. **Sempre dê exemplos reais**: "Em produção eu usaria..."
2. **Mencione trade-offs**: "A vantagem é X, mas o custo é Y"
3. **Cite ferramentas do ecossistema**: Helm, ArgoCD, Prometheus
4. **Fale de troubleshooting**: kubectl describe, logs, events
5. **Mostre que pensa em segurança**: RBAC, NetworkPolicy, Secrets

---

## 🛠️ Comandos Que Todo Sênior Sabe de Cor

```bash
# Debug de pod com problema
kubectl describe pod <nome>       # Ver eventos e status
kubectl logs <pod> -c <container> # Logs do container
kubectl logs <pod> --previous     # Logs antes do crash

# Entrar no container
kubectl exec -it <pod> -- /bin/sh

# Ver recursos consumidos
kubectl top pods
kubectl top nodes

# Rollback rápido
kubectl rollout undo deployment/<nome>

# Forçar restart sem downtime
kubectl rollout restart deployment/<nome>

# Ver todos os eventos (ótimo para debug)
kubectl get events --sort-by='.lastTimestamp' -n <namespace>

# Port forward para acesso local
kubectl port-forward pod/<nome> 8080:80

# Ver YAML do recurso atual
kubectl get deployment <nome> -o yaml
```
