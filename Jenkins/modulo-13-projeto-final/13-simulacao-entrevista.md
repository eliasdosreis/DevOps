# ============================================================
# MÓDULO 13 — PROJETO FINAL SENIOR
# Arquivo: 13-simulacao-entrevista.md
#
# Perguntas reais de entrevistas Senior de Jenkins/CI/CD
# com respostas completas esperadas.
# ============================================================

# Simulação de Entrevista Técnica Senior — Jenkins CI/CD

---

## INSTRUÇÕES

1. Leia cada pergunta e tente responder SEM olhar a resposta
2. Escreva sua resposta em voz alta (ou no papel)
3. Compare com a resposta esperada
4. Repita as que errou no dia seguinte
5. Você está pronto quando conseguir responder TODAS fluentemente

---

## BLOCO 1: FUNDAMENTOS

**Q1: O que é Pipeline as Code e por que é superior ao Job Freestyle?**

> Pipeline as Code significa definir a lógica de CI/CD em arquivos de código
> (Jenkinsfile) versionados no Git, em vez de configurar via interface gráfica.
>
> Vantagens sobre Freestyle:
> - **Versionamento**: histórico completo via git log
> - **Code Review**: mudanças no pipeline passam por PR
> - **Recuperação**: Jenkins reinstalado? Basta apontar para o Git
> - **Rastreabilidade**: sabe exatamente quando e por que o pipeline mudou
> - **Multibranch**: cada branch tem seu pipeline automaticamente
> - **Reutilização**: Shared Libraries para código compartilhado

---

**Q2: Explique a diferença entre Pipeline Declarativo e Scripted. Quando usar cada um?**

> **Declarativo**: estrutura rígida (`pipeline → agent → stages → stage → steps`),
> validação antes da execução, suporte nativo a `post`, `when`, `parallel`,
> `environment`, `parameters`. Melhor legibilidade e manutenibilidade.
>
> **Scripted**: código Groovy puro dentro de `node { }`. Liberdade total,
> sem validação prévia, sem blocos semânticos nativos. Mais poder, mais
> responsabilidade.
>
> **Use Declarativo**: sempre (padrão moderno, 95% dos casos).
> **Use Scripted**: quando precisa de lógica dinâmica impossível no Declarativo.
> **Melhor dos dois mundos**: use Declarativo com blocos `script { }` internos.

---

**Q3: O que acontece quando um stage faz parte de um bloco `parallel` e um deles falha?**

> Por padrão, os outros stages paralelos **continuam executando** até terminar,
> mesmo após um falhar. O pipeline só marca como FAILED ao final.
>
> Com `failFast: true`, os stages paralelos restantes são **cancelados imediatamente**
> quando um falha — útil para feedback mais rápido e economia de recursos.
>
> O bloco `post { failure }` executa após todo o parallel terminar.

---

## BLOCO 2: VARIÁVEIS E CREDENTIALS

**Q4: Qual a diferença entre `env.VARIAVEL`, `params.VARIAVEL` e `def` no script?**

> - `env.VARIAVEL`: variável de ambiente — string, visível para todos os stages após definida, acessível no shell como `$VARIAVEL`
> - `params.VARIAVEL`: parâmetro fornecido pelo usuário — somente leitura, pode ser Boolean ou String dependendo do tipo
> - `def variavel` no script: variável Groovy local — escopo apenas ao bloco `script { }` onde foi declarada, NÃO acessível no shell via `sh '...'`
>
> Armadilha: `env.BOOL == true` é sempre false porque env são strings. Use `env.BOOL == 'true'` ou `env.BOOL.toBoolean()`.

---

**Q5: Como garantir que um token de API nunca aparece nos logs do Jenkins?**

> 1. Usar o **Credentials Store** (nunca hardcode), acessar via `credentials()` ou `withCredentials`
> 2. Jenkins mascara automaticamente os valores de credentials nos logs
> 3. Usar `--password-stdin` no Docker login em vez de `-p $TOKEN`
> 4. Não concatenar em strings de `echo` ou `sh "echo ...$TOKEN"`
> 5. Usar arquivo temporário com chmod 600 + remover após uso
> 6. Evitar `sh "curl -H 'Auth: $TOKEN' ..."` — prefer `--header @arquivo`
>
> O Jenkins não mascara se você dividir o token em partes — prevenção adicional.

---

## BLOCO 3: AGENTS E ARQUITETURA

**Q6: Por que nunca se deve executar builds no Controller Jenkins?**

> O Controller é o cérebro do Jenkins: gerencia configurações, credentials, plugins,
> interface web e orquestração de todos os builds.
>
> Executar builds nele:
> - **Segurança**: código arbitrário com acesso a credentials, configs, sistema de arquivos
> - **Disponibilidade**: build pesado pode consumir memória/CPU e derrubar o Controller inteiro
> - **Escalabilidade**: o Controller tem um número fixo de executors, não escala
>
> **Solução**: `agent none` no nível do pipeline, agents dedicados por stage.
> Configurar `Number of executors: 0` no Built-in Node.

---

**Q7: Qual a diferença entre agentes efêmeros (Kubernetes) e persistentes (SSH)?**

> **Persistentes (SSH/JNLP)**: VMs sempre ativas, rápidas (sem cold start), boas para
> cache de dependências Maven/npm. Custo fixo mesmo sem builds.
>
> **Efêmeros (Kubernetes)**: Pods criados por demanda, destruídos após o build.
> Estado sempre limpo, scale de 0 a N automático, custo proporcional ao uso.
> Cold start de ~30s. Cache em PVCs compartilhados.
>
> **Produção moderna**: Kubernetes para a maioria dos builds + persistentes para
> casos especiais (GPU, cache de tb de dados, hardware específico).

---

## BLOCO 4: DOCKER E DEPLOY

**Q8: Por que nunca usar `:latest` em imagens Docker de produção?**

> `:latest` é **mutável** — aponta para imagens diferentes ao longo do tempo.
> Se você deploiar `app:latest` e depois alguém fizer push de uma nova imagem
> com essa tag, um rollback buscaria a nova imagem, não a original.
>
> **Produção exige imutabilidade**: use `app:v1.2.3-a3f9c12b` (semver + commit hash).
> Assim: (1) rollback busca EXATAMENTE a imagem que estava rodando, (2) auditoria
> sabe qual commit gerou aquela imagem, (3) fingerprinting funciona corretamente.

---

**Q9: Descreva uma estratégia Blue-Green Deploy com rollback. De onde a Jenkins Pipeline facilita?**

> **Blue-Green**: dois ambientes idênticos (Blue=atual, Green=novo).
> Deploy acontece no Green sem afetar o Blue. Smoke tests no Green.
> Switch no load balancer (instantâneo). Rollback = reverter o switch (segundos).
>
> **No Jenkins**:
> 1. Stage "Determinar Slot": descobre qual está ativo (Blue ou Green)
> 2. Stage "Deploy Standby": deploia no slot inativo
> 3. Stage "Smoke Tests": valida o novo slot
> 4. Stage "Aprovação": input manual para o switch
> 5. Stage "Switch": atualiza o Service Kubernetes
> 6. Stage "Verificação": monitoramento pós-switch
> 7. Em caso de falha: `kubectl patch service app -p '{"spec":{"selector":{"slot":"blue"}}}'`

---

## BLOCO 5: SHARED LIBRARIES E GOVERNANÇA

**Q10: O que são Shared Libraries e qual o benefício para uma organização com 50+ microserviços?**

> Shared Libraries são repositórios Git com código Groovy reutilizável
> importado por múltiplos Jenkinsfiles com `@Library('nome-da-library') _`.
>
> Com 50+ microserviços sem library:
> - Cada serviço tem seu próprio script de build/deploy = 50 versões diferentes
> - Bug em security scan = 50 PRs para corrigir
> - Novos requisitos de compliance = 50 atualizações manuais
>
> Com Shared Library:
> - `buildApp(tipo: 'maven')` em todos os serviços
> - Corrige a library = todos os 50 serviços são atualizados automaticamente
> - Padrão corporativo garantido: SonarQube, Trivy, notificação, aprovação = sempre presentes

---

**Q11: Como você abordaria a migração de 30 Jobs Freestyle para Pipelines?**

> **Estratégia incremental** (não big bang):
>
> 1. **Inventário**: mapear todos os jobs Freestyle com dependências, schedules, credentials
> 2. **Priorização**: começar pelos mais simples (hello world) para ganhar confiência
> 3. **Shared Library**: criar as funções/padrões reutilizáveis primeiro
> 4. **Multibranch**: criar job Multibranch paralelo ao Freestyle existente
> 5. **Teste paralelo**: manter os dois rodando por 1 sprint para comparar resultados
> 6. **Switch gradual**: mover equipe por equipe
> 7. **Desativar Freestyle**: após validação, desativar (não deletar — manter backup)
>
> **Risco a evitar**: migrar tudo de uma vez — um problema bloqueia todos os times.

---

## BLOCO 6: TROUBLESHOOTING

**Q12: Um build ficou preso em "WAITING" por 30 minutos. Quais são as causas e como investigar?**

> **Causas mais comuns**:
> 1. **Input não respondido**: stage com `input {}` aguardando aprovação humana
> 2. **Sem executor disponível**: todos os executors do agente estão ocupados
> 3. **Agente offline**: o label especificado não tem agente disponível
> 4. **Lock de recurso**: plugin lockable-resources aguardando liberação
>
> **Como investigar**:
> 1. Jenkins Dashboard → Build → "Build Executor Status" → ver se está na fila
> 2. Jenkins → Build → clique no build → "Pipeline Steps" → ver qual step está preso
> 3. `Manage Jenkins → Nodes` → verificar agentes online/offline
> 4. Verificar se há `input {}` sem resposta na interface do job
> 5. Console Output → última linha antes do travamento

---

## AUTOAVALIAÇÃO

Responda: em uma escala de 1-5, quão confortável você está com cada tema?

| Tema | 1 (baixo) | ... | 5 (alto) |
|------|-----------|-----|----------|
| Declarativo vs Scripted | | | |
| Credentials e Secrets | | | |
| Agents e Labels | | | |
| Docker no Pipeline | | | |
| Deploy Strategies | | | |
| Shared Libraries | | | |
| Segurança e RBAC | | | |
| Monitoramento e DORA | | | |

**Meta**: todos os temas com nota 4+ antes de ir para entrevistas Senior.
