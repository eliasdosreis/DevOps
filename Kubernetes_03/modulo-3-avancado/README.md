# 📙 Módulo 3 - Avançado

## 🧠 Neste módulo você vai dominar

- **Ingress** = Porteiro inteligente que distribui visitantes
- **HPA** = Sistema automático que contrata/demite funcionários
- **PV/PVC** = Almoxarifado permanente que não some quando o pod morre
- **RBAC** = Sistema de permissões (quem pode fazer o quê)
- **NetworkPolicy** = Firewall entre pods
- **StatefulSet** = Para apps que têm "identidade" (bancos de dados)

---

## 📁 Arquivos deste módulo

```
01-ingress.yaml              --> Roteamento HTTP/HTTPS
02-hpa.yaml                  --> Auto scaling horizontal
03-pv-pvc.yaml               --> Storage persistente
04-rbac.yaml                 --> Controle de acesso
05-networkpolicy.yaml        --> Firewall entre pods
06-statefulset.yaml          --> Apps com estado (ex: banco)
```

---

## 🎯 Checklist do Módulo 3

- [ ] Configurar Ingress com múltiplos paths
- [ ] Entender como o HPA usa métricas para escalar
- [ ] Diferença entre PV, PVC e StorageClass
- [ ] Criar Role e RoleBinding para um ServiceAccount
- [ ] Saber quando usar StatefulSet vs Deployment
