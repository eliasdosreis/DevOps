/* engine.js - lógica básica do Tetris
   Exports a simple Engine constructor (global) que gerencia grid, peças e linhas.
*/
(function(window){
  const COLS = 10, ROWS = 20;
  const PIECES = {
    I: [[1,1,1,1]],
    J: [[1,0,0],[1,1,1]],
    L: [[0,0,1],[1,1,1]],
    O: [[1,1],[1,1]],
    S: [[0,1,1],[1,1,0]],
    T: [[0,1,0],[1,1,1]],
    Z: [[1,1,0],[0,1,1]]
  };

  function cloneGrid(){
    const g = [];
    for(let r=0;r<ROWS;r++) g.push(new Array(COLS).fill(0));
    return g;
  }

  function rotate(matrix){
    const m = matrix.map(r=>r.slice());
    const N = m.length, M = m[0].length;
    const res = Array.from({length:M},()=>Array(N).fill(0));
    for(let i=0;i<N;i++)for(let j=0;j<M;j++)res[j][N-1-i]=m[i][j];
    return res;
  }

  function randomPiece(){
    const keys = Object.keys(PIECES);
    const k = keys[Math.floor(Math.random()*keys.length)];
    return {type:k, matrix:PIECES[k].map(r=>r.slice())};
  }

  function Engine(){
    this.grid = cloneGrid();
    // no active falling piece anymore
    this.active = null;
    this.next = randomPiece();
    this.pos = {x:3,y:0};
    this.gameOver=false;
    this.linesCleared=0;
  }

  // New spawn: immediately merge next piece into the grid at top (no falling)
  Engine.prototype.spawn = function(){
    const piece = this.next;
    this.next = randomPiece();
    // attempt to place the piece centered at top rows
    const px = Math.floor((COLS - piece.matrix[0].length)/2);
    const py = 0;
    // if collision at placement, game over
    const willCollide = (function(){
      for(let y=0;y<piece.matrix.length;y++){
        for(let x=0;x<piece.matrix[y].length;x++){
          if(piece.matrix[y][x]){
            const gx = px + x, gy = py + y;
            if(gy<0 || gy>=ROWS || gx<0 || gx>=COLS) return true;
            if(this.grid[gy][gx]) return true;
          }
        }
      }
      return false;
    }).call(this);
    if(willCollide){ this.gameOver = true; return; }
    // merge directly
    for(let y=0;y<piece.matrix.length;y++){
      for(let x=0;x<piece.matrix[y].length;x++){
        if(piece.matrix[y][x]){
          const gx = px + x, gy = py + y;
          if(gy>=0 && gy<ROWS && gx>=0 && gx<COLS) this.grid[gy][gx] = 1;
        }
      }
    }
    // after merging, sweep lines
    this.sweepLines();
  };

  Engine.prototype.collide = function(px,py,matrix){
    // collision utility (keeps compatibility, but active not used)
    const mat = matrix || (this.active && this.active.matrix);
    if(!mat) return false;
    for(let y=0;y<mat.length;y++){
      for(let x=0;x<mat[y].length;x++){
        if(mat[y][x]){
          const gx = px + x, gy = py + y;
          if(gx<0 || gx>=COLS || gy>=ROWS) return true;
          if(gy>=0 && this.grid[gy][gx]) return true;
        }
      }
    }
    return false;
  };

  // No-op movement/rotation/drop since no active falling pieces
  Engine.prototype.move = function(dir){ /* no-op */ };
  Engine.prototype.rotateActive = function(){ /* no-op */ };
  Engine.prototype.drop = function(){ return false; };
  Engine.prototype.hardDrop = function(){ /* no-op */ };
  Engine.prototype.merge = function(){ /* no-op */ };

  Engine.prototype.sweepLines = function(){
    let lines = 0;
    for(let y=ROWS-1;y>=0;y--){
      if(this.grid[y].every(c=>c)){
        this.grid.splice(y,1);
        this.grid.unshift(new Array(COLS).fill(0));
        lines++; y++; // recheck this row index
      }
    }
    this.linesCleared += lines;
    return lines;
  };

  Engine.prototype.addGarbage = function(rows){
    rows = rows||1;
    for(let i=0;i<rows;i++){
      this.grid.shift();
      const row = new Array(COLS).fill(1);
      // leave one hole
      row[Math.floor(Math.random()*COLS)]=0;
      this.grid.push(row);
    }
  };

  Engine.prototype.removeRandomBlocks = function(n){
    n = n||5;
    for(let i=0;i<n;i++){
      const y = ROWS-1 - Math.floor(Math.random()*5);
      const x = Math.floor(Math.random()*COLS);
      this.grid[y][x]=0;
    }
  };

  Engine.prototype.clearAll = function(){
    this.grid = cloneGrid();
  };

  Engine.prototype.asMatrix = function(){
    // return a copy of the static grid (no active falling piece)
    return this.grid.map(r=>r.slice());
  };

  Engine.prototype.reset = function(){
    this.grid = cloneGrid(); this.next = randomPiece(); this.gameOver=false; this.linesCleared=0;
  };

  window.Engine = Engine;
})(window);