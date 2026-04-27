# 🔴 Módulo 4 - Projeto Final (Nível Sênior)

## 🎯 O que vamos construir

Uma aplicação completa de **e-commerce** com:

```
[Internet]
    |
[Ingress / HTTPS]
    |
    ├── [Frontend - React]  --> Service ClusterIP
    ├── [API - Node.js]     --> Service ClusterIP
    └── [Admin - Django]    --> Service ClusterIP
         |
    [PostgreSQL StatefulSet] --> PVC (dados persistentes)
    [Redis Deployment]       --> Cache e sessões
         |
    [ConfigMap]  --> Configurações
    [Secrets]    --> Senhas e tokens
    [HPA]        --> Auto scaling
    [RBAC]       --> Permissões
    [NetworkPolicy] --> Segurança de rede
```

---

## 📁 Arquivos do Projeto Final

```
00-namespace.yaml              --> Namespace dedicado
01-secrets.yaml                --> Todas as senhas
02-configmap.yaml              --> Todas as configs
03-postgres-statefulset.yaml   --> Banco de dados
04-redis-deployment.yaml       --> Cache
05-api-deployment.yaml         --> Backend da API
06-frontend-deployment.yaml    --> Frontend
07-services.yaml               --> Todos os services
08-ingress.yaml                --> Roteamento externo
09-hpa.yaml                    --> Auto scaling
10-networkpolicy.yaml          --> Segurança de rede
11-rbac.yaml                   --> Controle de acesso
12-poddisruptionbudget.yaml    --> Alta disponibilidade
```

---

## 🚀 Como subir o projeto completo

```bash
# Habilitar addons no Minikube
minikube addons enable ingress
minikube addons enable metrics-server

# Aplicar TUDO em ordem
kubectl apply -f modulo-4-projeto-final/

# Verificar tudo no namespace
kubectl get all -n ecommerce

# Acessar via Minikube
minikube tunnel
```

---

## 🎯 Checklist Sênior - Projeto Final

- [ ] Todo recurso está no namespace correto
- [ ] Senhas usam Secrets (não hardcoded)
- [ ] Configs usam ConfigMap
- [ ] Todos os Deployments têm Probes
- [ ] Todos têm Resource requests/limits
- [ ] HPA configurado para API e Frontend
- [ ] NetworkPolicy restringindo acesso entre pods
- [ ] RBAC com mínimo privilégio
- [ ] PodDisruptionBudget para alta disponibilidade
- [ ] Ingress com TLS configurado
