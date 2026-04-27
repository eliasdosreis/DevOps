# 📗 Módulo 1 - Fundamentos

## 🧠 O que você vai aprender

Pense no Kubernetes como uma **cidade inteligente**.

- **Pod** = Uma casinha onde mora seu app
- **Service** = O endereço da casinha (para as pessoas acharem)
- **Namespace** = O bairro onde ficam as casinhas
- **ReplicaSet** = Um construtor que faz N casinhas iguais
- **Labels** = Etiquetas nas casinhas para organizar

---

## 📁 Arquivos deste módulo

```
01-pod-simples.yaml          --> Cria 1 pod básico
02-pod-com-limites.yaml      --> Pod com controle de memória/CPU
03-namespace.yaml            --> Cria um bairro (namespace)
04-service-clusterip.yaml    --> Endereço interno do pod
05-service-nodeport.yaml     --> Expõe o pod para fora
```

---

## 🚀 Como usar cada arquivo

```bash
# Aplicar um arquivo
kubectl apply -f 01-pod-simples.yaml

# Ver o que foi criado
kubectl get pods

# Ver detalhes completos
kubectl describe pod meu-primeiro-pod

# Deletar
kubectl delete -f 01-pod-simples.yaml
```

---

## 🎯 Checklist do Módulo 1

- [ ] Criar e deletar um Pod
- [ ] Entender o que é um Namespace
- [ ] Explicar a diferença entre ClusterIP e NodePort
- [ ] Saber o que são Labels e para que servem
- [ ] Conseguir fazer `kubectl describe` e entender a saída
