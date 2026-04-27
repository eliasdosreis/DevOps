# O QUE ESTE ARQUIVO ENSINA:
Como verificar se o Vim está adequadamente instalado, preparado
para o curso e os primeiros contatos do terminal.

---

### 1. ANALOGIA DO DIA A DIA
Imagine que você é um piloto de avião entrando na cabine. Antes de
decolar e se jogar no espaço aéreo (escrever código), você precisa
fazer o "Checklist Pre-Flight": ver se os instrumentos (Vim) ligam
e se tudo está onde deveria.

---

### 2. O QUE É (Definição Senior)
O Vim é um editor de texto modal de alta performance residente no terminal 
ou ambiente de janelas. O teste de sanidade (sanity check) garante que 
sua variável `$PATH` aponta para o binário correto e que terminal/tty está 
lidando corretamente com a aplicação. Pode ser usado tanto o vim padrão quanto o Neovim (`nvim`).

---

### 3. DEMONSTRAÇÃO COMENTADA
Abra seu terminal favorito (Git Bash, WSL, ou PowerShell) e siga os comandos.

```bash
# Verifica se o vim existe e imprime o diretório do seu executável:
which vim     # ou `which nvim` se estiver usando Neovim

# Verifica a versão instalada e os recursos compilados (+ ou - ao lado deles):
vim --version

# Entra pela primeira vez no Vim em uma tela vazia (scratch buffer):
vim
```

---

### 4. COMANDOS PASSO A PASSO
1. **Comando:** `vim --version`
   - **O que faz:** Exibe a versão atual (ex: VIM - Vi IMproved 9.0)
   - **O que esperar:** Uma lista de características. Ideal ser versão > 8.0.
   - **Se der erro:** "command not found". Você precisará instalar o Vim dependendo do SO (pelo instalador Windows, ou no WSL com `sudo apt install vim`).

---

### 5. VERIFICAÇÃO E TROUBLESHOOTING
- Se bateu `vim` e a tela ficou "esquisita": parabéns, você abriu o Vim.
- E agora, a verificação fundamental de sobrevivência:

**COMO SAIR NESTA FASE:**
Se você caiu dentro da tela do Vim sem querer e travou, aperte a seguinte
sequência mecânica exata de teclas:
1. Pressione a tecla `ESC` 3 vezes.
2. Digite `:q!`  (dois pontos, letra q, exclamação).
3. Pressione a tecla `ENTER`.
Pronto, você está salvo de volta no terminal!

---

### 6. CONCEITO SENIOR (O "porquê" profundo)
Um Sênior nunca assume cegamente o ambiente de desenvolvimento, principalmente
acessando servidores remotos (via SSH). O comando `which vim` diz de *onde* o
Vim está sendo carregado.
Muitas vezes, a máquina linux "crua" tem apenas o vetusto `vi` (o pai do vim, sem os atalhos e melhorias atuais), ou o Vim instalado pelo root difere do seu Vim no `~/.local/bin`.
Ter certeza do binário sendo executado previne dores de cabeça com plugins falhando por incompatibilidade de versão.

---

### 7. PERGUNTA DE ENTREVISTA
**Pergunta:** "Por que às vezes rodar `vi arquivo.txt` em um servidor remoto
produz um comportamento bem diferente e frustrante comparado ao seu Vim local?"

**Resposta Esperada:** "Porque o `vi` original (disponível por padrão no POSIX) 
carece de muitos mapeamentos modernos, multithreading, suporte longo à linguagem 
de roteiro do Vim (Vimscript/Lua), que o projeto Vim (`vim` a partir dos 
anos 90) ou o Neovim (`nvim`) adicionaram. Executar `vi` geralmente inicia um
editor legado sem os recursos nativos do Vim."
