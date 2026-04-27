# 🚀 Kubernetes Senior - Do Zero ao Senior

## 👨‍💻 Alex DevOps Coach | Projeto Completo de Kubernetes

---

## 🎯 Objetivo
Ao final deste projeto, você saberá explicar e criar qualquer
aplicação Kubernetes. Estará pronto para entrevistas técnicas
de nível Sênior.

---

## 📦 Estrutura do Projeto

```
k8s-senior-project/
├── modulo-1-fundamentos/       # O básico que todo Senior sabe
├── modulo-2-intermediario/     # Subindo o nível
├── modulo-3-avancado/          # Recursos avançados
└── modulo-4-projeto-final/     # Projeto real de produção
```

---

## 🗺️ Mapa de Aprendizado

```
[Módulo 1]          [Módulo 2]          [Módulo 3]          [Módulo 4]
Fundamentos    -->  Intermediário  -->  Avançado       -->  Projeto Final
  Pod               Deployment          HPA                  App Completa
  Service           ConfigMap           NetworkPolicy        Monitoramento
  Namespace         Secret              RBAC                 CI/CD Ready
```

---

## 🛠️ Pré-requisitos

```bash
# Instale o kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s \
  https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Instale o Minikube (cluster local)
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Inicie o cluster
minikube start

# Verifique se está funcionando
kubectl get nodes
```

---

## 📚 Módulos

| Módulo | Tema | Arquivos | Nível |
|--------|------|----------|-------|
| 1 | Fundamentos | 5 arquivos | 🟢 Iniciante |
| 2 | Intermediário | 6 arquivos | 🟡 Júnior+ |
| 3 | Avançado | 6 arquivos | 🟠 Pleno |
| 4 | Projeto Final | App completa | 🔴 Sênior |

---

> 💡 **Dica do Coach**: Leia cada arquivo com calma.
> Cada linha tem um comentário. Não pule etapas!
