#!/usr/bin/env bash

# ============================================================
# O QUE ESTE SCRIPT FAZ:
# Apresenta a ferramenta fundamental do Here-Document (Here-Doc)
# e as facilidades das Here-Strings, além de uma palinha rápida 
# de expressões regulares (Regex).
# ============================================================

# ============================================================
# 1. ANALOGIA DO DIA A DIA
# Você quer mandar uma carta gigantesca para alguém "Embutida na caixa".
# Você não tem tempo pra criar um arquivo, escrever bloco por bloco.
# O "Here-Doc" é como você pegar um post-it gigante, prender e dizer pro
# terminal Bash: "Anota esse textasso multilinhas agorinha mesmo na sua cabeça aí, até a hora que eu disser FIM!".
# ============================================================

# ============================================================
# 2. O QUE É (definição técnica Senior)
# O Here-Document `<<` é um recurso sintático de desvio input/output (redirecionamento) no File Descriptor
# nativo, onde o interpretador da shell repassa strings blocadas formatadas de múltiplas linhas diretamente na porta EOF interativa, provendo stdin pra programas sem ter q instanciar temporários read/write discos.
# O Here-String `<<<` provê o mesmo inline para strings avulsas rápidas.
# ============================================================

set -euo pipefail

# ============================================================
# 3. SCRIPT COMENTADO
# ============================================================

echo "=== Magias de Redirecionamento Texto ==="

NOME_CONFIGURADA="Elias_Production"

echo "1. Criando um mega-arquivo de configuração Multi-lines Usando Here-Doc (<<)"
# O "EOF" (End of File) é nosso "Feitiço de Cúpula".
# Tudo que for digitado daqui p baixo está preso, e cai dentro do comando "cat" que salva.
# Você encerra fechando com a MESMA TAG MÁGICA ('EOF') sem espaços pra fechar o feitiço.
cat <<EOF > "/tmp/app_config.cfg"
[DATABASE]
conexao=$NOME_CONFIGURADA
porta=3306
host=127.0.0.1
; Essa variavel vai expandir acima pq não coloquei 'EOF' emulando aspas simles (Ex: 'EOF')
EOF

echo "- O Mega arquivo com a variável substituída dinâmicamente ($NOME_CONFIGURADA) foi gerado puro!"

echo ""
echo "2. O uso do Here-String (<<<)"
# Ao invez de usarmos o (Useless use of cat ou Echos): `echo "teste" | grep "t"` para jogar p/ um comando...
# Usa-se a "seta apontando" do HERESTRING <<< para injeção limpa de Váriavel -> Stdin.
VAR_SECRETA="TOKEN123!"

# Grep mastigando stdin da propria string sem subshells
grep -q "TOKEN" <<< "$VAR_SECRETA" && echo "- A string secreta contém (match) o texto."

echo ""
echo "3. Um Pouco de Regex com utilitarios"
# Regex = Padrões Universais.
# ^    = Inicio da string
# [0-9]= Qualquer núm
# $    = Fim da string
# grep -E (Ou egrep - Extended Regex POSIX)
if echo "Erro 1999 Fatal App..." | grep -qE "^Erro [0-9]{4}"; then
    echo "- Detectamos na expressão estendida [-E] de regex que começou (^) com Erro e teve 4 num!"
fi

# ============================================================
# 4. COMANDOS PASSO A PASSO
# - O Here-Doc usa uma `CHAVE_GRAFIA`. Pode ser 'EOF'/ FIM / CABOU. (O dev escolhe). Ex: `cat <<CABOU` e depois fecha escrevendo `CABOU` na borda esquerda limpa.
# - Para mandar instruções gigantes pra um SQL psql remotamente com sub-shell limpo sem aspas chatas: `psql ... <<EOF SELECT * FROM ... EOF`.
# ============================================================

# ============================================================
# 5. VERIFICAÇÃO E TROUBLESHOOTING
# - Ao usar Here-Doc (<<) dentro de um Sub-Loop com tabs:
#    Eu botei um 'TAB' de identação pra o "EOF" ficar bonitinho com meus IFs do código... e agora o script quebrou "Unexpected EOF".
#   Solução Sênior: Se o limite "EOF" de fechamento (Limit String) tiver 1 ESPAÇO em branco, não conta! Se vc usar o dash prefix `<<-EOF`, o interpretador ignora OBRIGATORIAMENTE os *LEADING TABS* (tabulaçao padrão, mas de espaço não!) deixando fechar elegantemente na endentação do dev!!
# ============================================================

# ============================================================
# 6. CONCEITO SENIOR (o "porquê" profundo)
# Existe risco real no Here Doc?
# Extremos! Por padrao um "EOF" Nuo vai avaliar e expandir toda a string e variáveis bash e escapes nela processando e jogando tudo no texto como se fosse Aspsas Duplas `""`.
# Porém, se você escrever um Here-Doc que vai gerar na pasta do outro um *.sh script. Vc terá scripts criando scripts. E os '$' vão se amassar com o parent!
# Como eu dou "Quotes limpas" protegidas e puras pra eu criar meu .sh script via Here-Doc que vai cair 100% literal no /tmp, incluindo vars internas literais de lá?
# Mágicamete Quote a Cúpula/Palavra do EOF inicial pra desativar as Expansão Atômicas de Shell: `cat << 'EOF'`. E pronto! Nascerá 100% puro!
# ============================================================

# ============================================================
# 7. PERGUNTA DE ENTREVISTA
# Pergunta: "Dado um pipeline extenso de extrair dados e mandar a um container pod root via bash heredoc `ssh root@host bash <<EOF ...` Qual a diferença de usar o Redirecionador Here-String (`grep xyz <<< "$VAR"`) contra um Echo Pipe (`echo "$VAR" | grep xyz`)?"
# Resposta Sênior: Herestrings `<` ou `<<<` operam de forma 100% mono-processada na current execution thread provendo redirecionamento de Memory File Descriptors (na forma de tempfiles no UNIX background fd/pipes via proc filesystem). Por eles correrem em mono-thread com o comando adjunto à frente, evitam o overhead formidável de "Command Forking/Fork() e execve() Process Creation" requerido nas avaliações do bash pro "Pipelining via |" geradores de instâncias mortais clonais. Para fluxos brutos os Hercode/strs são milésimos de mcs mais limpos.
# ============================================================
