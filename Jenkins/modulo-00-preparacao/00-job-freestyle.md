# ============================================================
# MÓDULO 0 — PRIMEIRO JOB FREESTYLE
# Arquivo: 00-job-freestyle.md
#
# O QUE ESTE GUIA FAZ:
# Ensina a criar o primeiro job no Jenkins usando a interface gráfica.
# O Job Freestyle é o tipo mais simples — serve para entender
# a interface antes de partir para os Pipelines.
# ============================================================

# Criando o Primeiro Job Freestyle no Jenkins

---

## 1. ANALOGIA DO DIA A DIA

Um Job Freestyle é como um **formulário de pedido** numa padaria.
Você preenche campos: "quero pão de queijo", "quantidade: 10",
"horário: 8h". O atendente (Jenkins) recebe o formulário e executa.

O problema? Esse formulário é difícil de versionar, compartilhar
e automatizar. Por isso o mundo evoluiu para os **Pipelines**
(próximo módulo), onde a "receita" fica num arquivo de texto no Git.

---

## 2. PRÉ-REQUISITOS

- Jenkins rodando em http://localhost:8080
- Ter feito o acesso inicial com a senha do `initialAdminPassword`
- Ter instalado os plugins sugeridos no wizard

---

## 3. PASSO A PASSO: CRIANDO O JOB

### Passo 1: Acessar a página principal
1. Abra http://localhost:8080
2. Faça login com usuário `admin` e a senha inicial
3. Você verá o Dashboard principal (lista de jobs — inicialmente vazia)

**O que esperar**: Painel limpo com menu lateral esquerdo

---

### Passo 2: Criar novo Job
1. Clique em **"New Item"** (ou "Novo Item") no menu lateral esquerdo
2. No campo **"Enter an item name"**, digite: `meu-primeiro-job`
3. Selecione **"Freestyle project"** (primeiro ícone da lista)
4. Clique em **"OK"**

**O que esperar**: Tela de configuração do job

---

### Passo 3: Configurar descrição
1. Na aba **"General"**, no campo **"Description"**, escreva:
   ```
   Meu primeiro job Jenkins — aprendendo a interface
   ```

---

### Passo 4: Configurar a ação de build
1. Desça até a seção **"Build Steps"**
2. Clique em **"Add build step"**
3. Selecione **"Execute shell"** (Linux/Mac) ou
   **"Execute Windows batch command"** (Windows)
4. No campo de comando, cole:

**Linux/Mac:**
```bash
echo "==================================="
echo "  MEU PRIMEIRO BUILD NO JENKINS!   "
echo "==================================="
echo ""
echo "Data e hora atual: $(date)"
echo "Usuário: $(whoami)"
echo "Diretório de trabalho: $(pwd)"
echo "Build number: $BUILD_NUMBER"
echo ""
echo "BUILD CONCLUÍDO COM SUCESSO!"
```

**Windows:**
```batch
echo ===================================
echo   MEU PRIMEIRO BUILD NO JENKINS!
echo ===================================
echo.
echo Build number: %BUILD_NUMBER%
echo.
echo BUILD CONCLUIDO COM SUCESSO!
```

---

### Passo 5: Salvar o job
1. Clique em **"Save"** (botão azul no final da página)

**O que esperar**: Redirecionamento para a página do job

---

### Passo 6: Executar o job
1. Clique em **"Build Now"** no menu lateral esquerdo
2. Na seção **"Build History"** (canto inferior esquerdo), aparecerá
   um ícone animado indicando que o build está executando
3. Clique no número do build (ex: `#1`) e depois em **"Console Output"**

**O que esperar**: Log do console exibindo as mensagens que você escreveu

---

## 4. ENTENDENDO O CONSOLE OUTPUT

Um build log típico tem esta estrutura:

```
Started by user admin                       ← Quem iniciou o build
Running as SYSTEM                           ← Contexto de segurança
Building in workspace /var/jenkins_home/workspace/meu-primeiro-job  ← Onde os arquivos ficam
[meu-primeiro-job] $ /bin/sh -xe /tmp/jenkins12345.sh  ← Jenkins cria um script temp

+ echo =================================== ← O + indica comandos executados (modo -x do shell)
===================================
+ echo   MEU PRIMEIRO BUILD NO JENKINS!
  MEU PRIMEIRO BUILD NO JENKINS!
...

Finished: SUCCESS                           ← Status final do build
```

---

## 5. EXPLORAR A INTERFACE (exercício guiado)

Depois de rodar o build, explore:

| Onde Clicar | O que Você Verá |
|-------------|-----------------|
| Console Output | Log completo linha a linha |
| Changes | Mudanças de código que triggaram este build |
| Configure | Volta para a configuração do job |
| Build History | Histórico de todos os builds |
| Workspace | Arquivos gerados pelo build |

---

## 6. TROUBLESHOOTING: Problemas Comuns

### Problema: "Permission denied" ao executar shell
**Causa**: O Jenkins não tem permissão para executar o script  
**Solução**: O container está rodando como root? Verifique o `docker-compose.yml`

### Problema: Build fica em fila (Pending)
**Causa**: Todos os executors estão ocupados, ou nenhum agent disponível  
**Solução**: Manage Jenkins → Nodes → Verifique se o Built-in Node está online

### Problema: Jenkins não abre no browser
**Causa**: Container não subiu corretamente  
**Solução**: `docker-compose logs jenkins` para ver o erro

---

## 7. CONCEITO SENIOR: Job Freestyle vs Pipeline

| Aspecto | Freestyle | Pipeline |
|---------|-----------|----------|
| **Versionamento** | ❌ Não (config no banco do Jenkins) | ✅ Sim (Jenkinsfile no Git) |
| **Code Review** | ❌ Não é possível | ✅ Via Pull Request |
| **Reutilização** | ❌ Difícil | ✅ Shared Libraries |
| **Visualização** | Básica | Stage View, Blue Ocean |
| **Paralelismo** | ❌ Limitado | ✅ Nativo com `parallel` |
| **Quando usar** | Nunca em produção | Sempre |

> **Regra Senior**: Se você está usando Freestyle em produção em 2024,
> é uma dívida técnica. Todo time maduro usa Pipelines com Jenkinsfile
> versionado no Git junto com o código da aplicação.

---

## 8. PERGUNTAS DE ENTREVISTA

**Q1: Qual a principal desvantagem dos Jobs Freestyle em relação aos Pipelines?**

> **Resposta**: Os Jobs Freestyle guardam sua configuração no banco interno
> do Jenkins (arquivos XML em `JENKINS_HOME`), não no repositório Git.
> Isso significa que não há histórico de mudanças, code review, ou
> rastreabilidade. Se o Jenkins for reinstalado ou corrompido, as
> configurações se perdem. Com Pipelines, o Jenkinsfile fica no Git
> junto com o código — qualquer mudança no pipeline passa por revisão,
> tem histórico completo e é recuperável.
