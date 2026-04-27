# 📘 Módulo 2 - Intermediário

## 🧠 Analogias para este módulo

- **Deployment** = Gerente de RH que garante N funcionários sempre ativos
- **ReplicaSet** = Time de funcionários com papéis idênticos
- **ConfigMap** = Placa de avisos com configurações
- **Secret** = Cofre com senhas e chaves importantes
- **Liveness Probe** = Médico verificando se o paciente está vivo
- **Readiness Probe** = RH verificando se o funcionário está pronto

---

## 📁 Arquivos deste módulo

```
01-replicaset.yaml           --> Múltiplas cópias de um pod
02-deployment.yaml           --> Gerencia ReplicaSets com rollout
03-deployment-rollout.yaml   --> Atualização sem downtime
04-configmap.yaml            --> Configurações externas
05-secret.yaml               --> Senhas e dados sensíveis
06-probes.yaml               --> Health checks (liveness/readiness)
```

---

## 🎯 Checklist do Módulo 2

- [ ] Entender a hierarquia: Deployment > ReplicaSet > Pod
- [ ] Fazer um rollout e rollback de Deployment
- [ ] Diferença entre ConfigMap e Secret
- [ ] Explicar Liveness vs Readiness Probe
- [ ] Quando usar cada tipo de probe
