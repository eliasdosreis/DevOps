/* game.js - integração da UI, perguntas e engine */
(function(){
  const canvas = document.getElementById('game');
  const ctx = canvas.getContext('2d');
  // next-canvas removed in no-falling mode
  const qEl = document.getElementById('question');
  const scoreEl = document.getElementById('score');
  const levelEl = document.getElementById('level');
  const comboEl = document.getElementById('combo');
  const feedback = document.getElementById('feedback');
  const terminal = document.getElementById('terminal');
  const input = document.getElementById('cmd');
  const submit = document.getElementById('submit');

  const block = 24; // pixel size
  const cols = 10, rows = 20;

  const engine = new Engine();
  // engine.spawn() removed to avoid an initial piece at game start

  let score=0, level=1, combo=0;
  let dropInterval = 800; // ms
  let dropTimer = 0;
  let lastTime = 0;
  let currentQuestion = null;
  let history = [];
  let histPos = -1;

  function pickQuestion(){
    currentQuestion = getQuestion();
    qEl.textContent = currentQuestion.pergunta;
  }

  pickQuestion();

  function draw(){
    ctx.clearRect(0,0,canvas.width,canvas.height);
    const mat = engine.asMatrix();
    for(let y=0;y<rows;y++){
      for(let x=0;x<cols;x++){
        const v = mat[y][x];
        if(v){
          ctx.fillStyle = v===1 ? '#2a6d9f' : '#f2c94c';
          ctx.fillRect(x*block,y*block,block-1,block-1);
        } else {
          ctx.fillStyle = '#031322';
          ctx.fillRect(x*block,y*block,block-1,block-1);
        }
      }
    }
    // no 'next' preview in this mode
  }

  function update(time=0){
    const delta = time - lastTime; lastTime = time;
    dropTimer += delta;
    // no periodic spawns in no-falling mode
    if(dropTimer > dropInterval){ dropTimer = 0; }
    draw();
    if(engine.gameOver){
      showFeedback('Game Over','bad');
      return; // stop
    }
    requestAnimationFrame(update);
  }

  function showFeedback(msg,type){
    feedback.textContent = msg;
    feedback.className = type==='good' ? 'good' : 'bad';
    const el = document.getElementById('app');
    const gameEl = document.getElementById('game');
    if(type==='bad'){
      el.classList.add('shake');
      gameEl.classList.add('flash-bad');
      scoreEl.classList.remove('score-pop');
      setTimeout(()=>{el.classList.remove('shake'); gameEl.classList.remove('flash-bad');},400);
    } else {
      // good
      gameEl.classList.add('flash-good');
      scoreEl.classList.add('score-pop');
      setTimeout(()=>{gameEl.classList.remove('flash-good'); scoreEl.classList.remove('score-pop');},500);
    }
  }

  function appendTerminal(text, cls){
    const d = document.createElement('div');
    d.textContent = text;
    if(cls) d.className = cls;
    terminal.appendChild(d);
    terminal.scrollTop = terminal.scrollHeight;
  }

  function submitAnswer(){
    const val = input.value;
    if(!currentQuestion) return;
    // show in terminal
    appendTerminal(`user@linux:~$ ${val}`, 'cmd');
    history.push(val);
    histPos = history.length;

    const ok = validarResposta(val, currentQuestion.resposta);
    if(ok){
      combo++; score +=50; showFeedback('Correto +50','good');
      appendTerminal('[Sistema] Resposta aceita (+50)', 'out-good');
      dropInterval = Math.min(1200, dropInterval + 200);
      // reward: remove some blocks from the base (no spawning)
      engine.removeRandomBlocks(6);
      appendTerminal('[Sistema] Removidos blocos da base', 'out-good');
      if(combo>=3){
        engine.removeRandomBlocks(8);
        score += 20*combo;
        appendTerminal(`[Sistema] Combo x${combo} aplicado`, 'out-good');
      }
      // advance to next question immediately
      pickQuestion();
    } else {
      combo=0; score -=20; showFeedback('Errado -20','bad');
      appendTerminal('[Sistema] Comando incorreto (-20)', 'out-bad');
      engine.addGarbage(1);
      dropInterval = Math.max(150, dropInterval - 60);
      // provide a hint and allow retry (do not pick new question)
      try{
        const hint = getHint(currentQuestion) || 'Tente revisar o comando e tente novamente';
        appendTerminal(`[Dica] ${hint}`, 'out-bad');
      }catch(e){
        appendTerminal('[Dica] Tente revisar o comando e tente novamente', 'out-bad');
      }
    }

    // count full lines (without removing) and then remove/award
    let lines = 0;
    for(let y=0;y<rows;y++) if(engine.grid[y].every(c=>c)) lines++;
    if(lines>0){
      score += lines*100;
      appendTerminal(`[Sistema] Linhas limpas: ${lines} (+${lines*100})`, 'out-good');
      engine.sweepLines();
    }

    scoreEl.textContent = score;
    comboEl.textContent = combo;
    levelEl.textContent = level;
    // if answer was correct we already picked a new question; otherwise keep same question for retry
    input.value=''; input.focus();
  }

  submit.addEventListener('click', submitAnswer);
  input.addEventListener('keydown', e=>{
    if(e.key === 'Enter'){
      e.preventDefault(); submitAnswer();
      return;
    }
    if(e.key === 'ArrowUp'){
      if(history.length===0) return;
      histPos = Math.max(0, Math.min(history.length-1, histPos-1));
      input.value = history[histPos] || '';
      e.preventDefault();
    }
    if(e.key === 'ArrowDown'){
      if(history.length===0) return;
      histPos = Math.max(0, Math.min(history.length, histPos+1));
      if(histPos === history.length) input.value = '';
      else input.value = history[histPos] || '';
      e.preventDefault();
    }
  });

  // global key shortcuts (keep input behavior intact)
  document.addEventListener('keydown', e=>{
    // if typing in input, ignore global shortcuts
    if(document.activeElement === input) return;
    // no-op: no piece controls in this mode
  });

  // start game loop
  requestAnimationFrame(update);

  // expose for debug
  window._LT = {engine, submitAnswer};

})();