// ============================================================
// MÓDULO 8 — AGENTS E NODES
// Arquivo: 08-Jenkinsfile-agent-kubernetes.groovy
//
// O QUE ESTE ARQUIVO FAZ:
// Demonstra o uso de Pods Kubernetes como agentes Jenkins.
// Cada build cria um Pod efêmero, executa o trabalho e o Pod é destruído.
//
// ANALOGIA DO DIA A DIA:
// Como trabalho freelancer numa plataforma:
// Quando um projeto chega, você contrata um freelancer (Pod).
// Ele faz o trabalho, recebe e vai embora.
// Sem vínculo permanente, sem custos fixos quando não há trabalho.
// ============================================================

pipeline {
  // ===========================================================
  // AGENT KUBERNETES: define a especificação do Pod
  // O Jenkins Kubernetes Plugin cria o Pod, executa e destrói.
  // ===========================================================
  agent {
    kubernetes {
      // Definição do Pod em YAML — mesma sintaxe dos Kubernetes YAMLs
      yaml '''
        apiVersion: v1
        kind: Pod
        metadata:
          labels:
            app: jenkins-agent
        spec:
          serviceAccountName: jenkins-agent
          containers:
            # Container principal: jnlp
            # OBRIGATÓRIO: é o agent Jenkins que se comunica com o Controller
            - name: jnlp
              image: jenkins/inbound-agent:latest-jdk21
              resources:
                requests:
                  memory: "256Mi"
                  cpu: "250m"
                limits:
                  memory: "512Mi"
                  cpu: "500m"

            # Container adicional: Maven para compilação
            - name: maven
              image: maven:3.9-eclipse-temurin-21
              command: ["sleep"]
              args: ["infinity"]    # Mantém o container ativo para o Jenkins usar
              resources:
                requests:
                  memory: "512Mi"
                  cpu: "500m"
                limits:
                  memory: "2Gi"
                  cpu: "1"
              volumeMounts:
                - mountPath: /root/.m2
                  name: maven-cache

            # Container adicional: Docker para build de imagens
            - name: docker
              image: docker:24-dind
              securityContext:
                privileged: true
              env:
                - name: DOCKER_TLS_CERTDIR
                  value: ""
              volumeMounts:
                - name: docker-sock
                  mountPath: /var/run/docker.sock

            # Container adicional: kubectl para deploy Kubernetes
            - name: kubectl
              image: bitnami/kubectl:latest
              command: ["sleep"]
              args: ["infinity"]

          volumes:
            - name: maven-cache
              persistentVolumeClaim:
                claimName: maven-cache-pvc   # PVC para cache do Maven entre builds
            - name: docker-sock
              hostPath:
                path: /var/run/docker.sock
      '''

      // Configurações adicionais do plugin Kubernetes Jenkins
      defaultContainer 'maven'       // Container padrão para steps (sem especificar container)
      retries 2                       // Tenta criar o Pod até 2 vezes em caso de falha
    }
  }

  stages {

    stage('Verificar Ambiente') {
      steps {
        // Executa no container 'maven' (defaultContainer)
        sh '''
          echo "=== CONTAINER: maven ==="
          java --version
          mvn --version
          echo "Pod: $POD_NAME"
          echo "Node K8s: $POD_NODE_NAME"
        '''
      }
    }

    stage('Build com Maven') {
      steps {
        // Ainda no container 'maven' (defaultContainer)
        container('maven') {
          sh 'mvn clean package -B -DskipTests'
        }
      }
    }

    stage('Docker Build e Push') {
      steps {
        // Muda para o container 'docker'
        container('docker') {
          sh '''
            docker --version
            docker build -t minha-app:${BUILD_NUMBER} .
            echo "Build Docker concluído no container docker"
          '''
        }
      }
    }

    stage('Deploy no Kubernetes') {
      steps {
        // Usa o container 'kubectl' para operações K8s
        container('kubectl') {
          sh '''
            kubectl version --client
            # kubectl set image deployment/minha-app app=minha-app:${BUILD_NUMBER}
            # kubectl rollout status deployment/minha-app
            echo "Deploy K8s simulado"
          '''
        }
      }
    }

    stage('Verificar Informações do Pod') {
      steps {
        script {
          echo "=== INFORMAÇÕES DO POD KUBERNETES ==="
          echo "Pod Name:     ${env.POD_NAME ?: 'N/A'}"
          echo "Pod Node:     ${env.POD_NODE_NAME ?: 'N/A'}"
          echo "Pod Namespace: ${env.POD_NAMESPACE ?: 'N/A'}"
          echo "Build URL:    ${env.BUILD_URL}"

          sh '''
            echo "Hostname do Pod: $(hostname)"
            echo "IP do Pod: $(hostname -i)"
          '''
        }
      }
    }

  } // Fecha stages

} // Fecha pipeline

// ============================================================
// CONFIGURAÇÃO DO PLUGIN KUBERNETES NO JENKINS:
//
// Manage Jenkins → Clouds → Add Cloud → Kubernetes
//   Kubernetes URL: https://kubernetes.default  (dentro do cluster)
//   Jenkins URL: http://jenkins.jenkins.svc.cluster.local:8080
//   Pod template: (configurado no Jenkinsfile acima)
//
// SERVICE ACCOUNT:
//   O Pod precisa de permissões para se comunicar com o Jenkins.
//   kubectl create serviceaccount jenkins-agent -n jenkins
//   kubectl create clusterrolebinding jenkins-agent \
//     --clusterrole=cluster-admin \
//     --serviceaccount=jenkins:jenkins-agent
//   (ajuste as permissões conforme o princípio do menor privilégio)
//
// VANTAGENS DOS AGENTES KUBERNETES:
//   ✅ Scale automático: 0 Pods quando não há builds, N Pods quando há carga
//   ✅ Isolamento: cada build tem seu próprio Pod (sem estado sujo)
//   ✅ Eficiência: sem custo de VM permanente para agentes ociosos
//   ✅ Multi-container: cada step pode usar uma ferramenta diferente
//   ✅ Integração nativa: o Jenkins gerencia o lifecycle do Pod
// ============================================================
