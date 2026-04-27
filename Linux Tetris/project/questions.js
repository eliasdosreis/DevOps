/* Banco de perguntas e função de validação
   Regras:
   - aceita múltiplas respostas
   - ignora espaços extras
   - case insensitive
   - aceita regex quando resposta for escrita como "/regex/"
*/
const QUESTIONS = [
  { pergunta: "Listar arquivos no diretório atual", resposta: ["ls"], dica: "Use o comando 'ls'" },
  { pergunta: "Entrar na pasta /var/log", resposta: ["cd /var/log", "cd /var/log/"], dica: "Use 'cd' para mudar de diretório (ex: cd /var/log)" },
  { pergunta: "Ver conteúdo de um arquivo (nomes de exemplo)", resposta: ["cat arquivo.txt", "less arquivo.txt", "more arquivo.txt"], dica: "Use 'cat' ou 'less' para visualizar arquivos" },
  { pergunta: "Ver uso de disco", resposta: ["df -h"], dica: "Tente 'df -h' para ver uso de disco legível" },
  { pergunta: "Ver processos rodando", resposta: ["ps aux", "top"], dica: "'ps aux' ou 'top' mostram processos em execução" },
  { pergunta: "Procurar a palavra 'erro' em arquivo.log", resposta: ["/grep\\s+erro\\s+arquivo.log/", "grep erro arquivo.log"], dica: "Use 'grep' (ex: grep erro arquivo.log)" },
  { pergunta: "Redirecionar saída para arquivo.out", resposta: ["echo 'texto' > arquivo.out", "/>\\s*arquivo.out$/"], dica: "Use '>' para redirecionar saída: echo 'texto' > arquivo.out" },
  { pergunta: "Mostrar as últimas 10 linhas de um arquivo", resposta: ["tail -n 10 arquivo.log", "tail arquivo.log"], dica: "Use 'tail' para ver o fim do arquivo (ex: tail -n 10 arquivo.log)" }
];

function normalizeInput(s){
  return s.trim().replace(/\s+/g,' ').toLowerCase();
}

function isRegexString(r){
  return typeof r === 'string' && r.startsWith('/') && r.endsWith('/');
}

function validarResposta(input, respostas){
  const normalized = normalizeInput(input);
  return respostas.some(r => {
    // regex answers
    if(isRegexString(r)){
      try{
        const inner = r.slice(1,-1);
        const rx = new RegExp(inner,'i');
        return rx.test(input.trim());
      }catch(e){
        return false;
      }
    }

    // normal string answers: try strict match first
    const normR = normalizeInput(r);
    if(normalized === normR) return true;

    // token-based tolerant matching: require same command and required flags, allow filenames/paths to vary
    const inTokens = normalized.split(' ');
    const rTokens = normR.split(' ');
    if(inTokens.length && rTokens.length && inTokens[0] === rTokens[0]){
      let match = true;
      for(let i=0;i<rTokens.length;i++){
        const rt = rTokens[i];
        const it = inTokens[i] || '';
        if(!rt) continue;
        // if token looks like a filename or path, accept any token in that position
        if(rt.includes('.') || rt.startsWith('/') || rt.startsWith('~')) continue;
        // flags (start with -) must match
        if(rt.startsWith('-')){
          if(it !== rt){ match = false; break; }
          continue;
        }
        // otherwise tokens must match
        if(it !== rt){ match = false; break; }
      }
      if(match) return true;
    }

    // last resort: contains
    if(normalized.includes(normR)) return true;
    return false;
  });
}

function getQuestion(difficulty){
  // difficulty can be 'easy'|'medium'|'hard' — for now random pick
  return QUESTIONS[Math.floor(Math.random()*QUESTIONS.length)];
}

function getHint(question){
  if(!question) return '';
  if(question.dica) return question.dica;
  // fallback: derive from first resposta
  const r = question.resposta && question.resposta[0];
  if(!r) return '';
  if(isRegexString(r)){
    try{ const inner = r.slice(1,-1); return `Pense em usar algo semelhante a: /${inner}/`; }catch(e){}
  }
  const cmd = r.split(/\s+/)[0];
  return `Tente usar: ${cmd}`;
}