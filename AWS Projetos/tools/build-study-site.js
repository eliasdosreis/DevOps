const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const siteDir = path.join(root, "site");
const assetsDir = path.join(siteDir, "assets");
const pagesDir = path.join(siteDir, "pages");

const moduleOrder = [
  "docs",
  "modulo-00-preparacao",
  "modulo-01-s3",
  "modulo-02-lambda",
  "modulo-03-api-gateway",
  "modulo-04-dynamodb",
  "modulo-05-sns-sqs",
  "modulo-06-cloudformation",
  "modulo-07-iam-secrets",
  "modulo-08-containers",
  "modulo-09-cloudwatch",
  "modulo-10-projeto-final",
];

const moduleMeta = {
  inicio: { label: "Inicio", accent: "#e50914", icon: "AWS", image: "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?auto=format&fit=crop&w=1400&q=80", caption: "Portfolio AWS: cada projeto precisa provar arquitetura, custo, seguranca e operacao." },
  docs: { label: "Portfolio", accent: "#e50914", icon: "PRO", image: "https://images.unsplash.com/photo-1552664730-d307ca884978?auto=format&fit=crop&w=1400&q=80", caption: "Documentacao de portfolio transforma laboratorio em historia profissional." },
  "modulo-00-preparacao": { label: "Preparacao", accent: "#ff9900", icon: "IAM", image: "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?auto=format&fit=crop&w=1400&q=80", caption: "Antes de criar recursos, prepare seguranca, CLI, budget e controle de custo." },
  "modulo-01-s3": { label: "S3", accent: "#3f8624", icon: "S3", image: "https://images.unsplash.com/photo-1558494949-ef010cbdcc31?auto=format&fit=crop&w=1400&q=80", caption: "S3 e a base para arquivos, sites estaticos, backups e data lakes." },
  "modulo-02-lambda": { label: "Lambda", accent: "#ff9900", icon: "LMD", image: "https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=1400&q=80", caption: "Lambda executa codigo sob demanda: sem servidor ligado esperando trabalho." },
  "modulo-03-api-gateway": { label: "API Gateway", accent: "#00a1c9", icon: "API", image: "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1400&q=80", caption: "API Gateway e a porta de entrada segura para funcoes e servicos." },
  "modulo-04-dynamodb": { label: "DynamoDB", accent: "#527fff", icon: "DB", image: "https://images.unsplash.com/photo-1544383835-bda2bc66a55d?auto=format&fit=crop&w=1400&q=80", caption: "DynamoDB exige pensar nos padroes de acesso antes de criar a tabela." },
  "modulo-05-sns-sqs": { label: "SNS + SQS", accent: "#8c4fff", icon: "MSG", image: "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1400&q=80", caption: "Filas e notificacoes desacoplam sistemas e deixam a arquitetura mais resiliente." },
  "modulo-06-cloudformation": { label: "CloudFormation", accent: "#dd344c", icon: "IAC", image: "https://images.unsplash.com/photo-1461749280684-dccba630e2f6?auto=format&fit=crop&w=1400&q=80", caption: "Infraestrutura como codigo cria ambientes repetiveis, auditaveis e destrutiveis." },
  "modulo-07-iam-secrets": { label: "IAM + Secrets", accent: "#d13212", icon: "SEC", image: "https://images.unsplash.com/photo-1550751827-4bd374c3f58b?auto=format&fit=crop&w=1400&q=80", caption: "Seguranca de portfolio: menor privilegio, segredos fora do codigo e auditoria." },
  "modulo-08-containers": { label: "Containers", accent: "#2496ed", icon: "ECS", image: "https://images.unsplash.com/photo-1605745341112-85968b19335b?auto=format&fit=crop&w=1400&q=80", caption: "Containers empacotam aplicacoes; ECS/Fargate executa sem cuidar de servidor." },
  "modulo-09-cloudwatch": { label: "CloudWatch", accent: "#7aa116", icon: "OBS", image: "https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=1400&q=80", caption: "Observabilidade mostra se a aplicacao esta saudavel antes do usuario reclamar." },
  "modulo-10-projeto-final": { label: "Projeto Final", accent: "#e50914", icon: "APP", image: "https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?auto=format&fit=crop&w=1400&q=80", caption: "O projeto final junta frontend, API, banco, fila, notificacao, logs e IaC." },
};

function ensureDir(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

function escapeHtml(value) {
  return String(value)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

function slugify(value) {
  return String(value)
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

function inlineMarkdown(text) {
  return escapeHtml(text)
    .replace(/`([^`]+)`/g, "<code>$1</code>")
    .replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>")
    .replace(/\*([^*]+)\*/g, "<em>$1</em>")
    .replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2">$1</a>');
}

function convertTable(lines) {
  const rows = lines
    .filter((line) => line.trim().startsWith("|"))
    .map((line) => line.trim().replace(/^\||\|$/g, "").split("|").map((cell) => cell.trim()));
  if (rows.length < 2) return "";
  const header = rows[0];
  const body = rows.slice(2);
  return `<div class="table-wrap"><table><thead><tr>${header.map((cell) => `<th>${inlineMarkdown(cell)}</th>`).join("")}</tr></thead><tbody>${body.map((row) => `<tr>${row.map((cell) => `<td>${inlineMarkdown(cell)}</td>`).join("")}</tr>`).join("")}</tbody></table></div>`;
}

function markdownToHtml(markdown) {
  const lines = markdown.replace(/\r\n/g, "\n").split("\n");
  const html = [];
  let paragraph = [];
  let list = null;
  let code = null;
  let table = [];
  let quote = [];

  function closeParagraph() {
    if (paragraph.length) {
      html.push(`<p>${inlineMarkdown(paragraph.join(" "))}</p>`);
      paragraph = [];
    }
  }
  function closeList() {
    if (list) {
      html.push(`</${list}>`);
      list = null;
    }
  }
  function closeTable() {
    if (table.length) {
      closeParagraph();
      closeList();
      html.push(convertTable(table));
      table = [];
    }
  }
  function closeQuote() {
    if (quote.length) {
      html.push(`<blockquote>${quote.map(inlineMarkdown).join("<br>")}</blockquote>`);
      quote = [];
    }
  }

  for (const rawLine of lines) {
    const line = rawLine.replace(/\s+$/g, "");
    if (code) {
      if (line.startsWith("```")) {
        html.push(`<pre><code>${escapeHtml(code.join("\n"))}</code></pre>`);
        code = null;
      } else {
        code.push(rawLine);
      }
      continue;
    }
    if (line.startsWith("```")) {
      closeTable(); closeParagraph(); closeList(); closeQuote();
      code = [];
      continue;
    }
    if (line.trim().startsWith("|")) {
      table.push(line);
      continue;
    }
    closeTable();
    if (!line.trim()) {
      closeParagraph(); closeList(); closeQuote();
      continue;
    }
    if (line.startsWith(">")) {
      closeParagraph(); closeList();
      quote.push(line.replace(/^>\s?/, ""));
      continue;
    }
    closeQuote();
    const heading = line.match(/^(#{1,6})\s+(.+)$/);
    if (heading) {
      closeParagraph(); closeList();
      const level = heading[1].length;
      const text = heading[2].trim();
      html.push(`<h${level} id="${slugify(text)}">${inlineMarkdown(text)}</h${level}>`);
      continue;
    }
    const ordered = line.match(/^\d+\.\s+(.+)$/);
    if (ordered) {
      closeParagraph();
      if (list !== "ol") {
        closeList();
        html.push("<ol>");
        list = "ol";
      }
      html.push(`<li>${inlineMarkdown(ordered[1])}</li>`);
      continue;
    }
    const unordered = line.match(/^[-*]\s+(.+)$/);
    if (unordered) {
      closeParagraph();
      if (list !== "ul") {
        closeList();
        html.push("<ul>");
        list = "ul";
      }
      html.push(`<li>${inlineMarkdown(unordered[1])}</li>`);
      continue;
    }
    paragraph.push(line.trim());
  }
  closeTable(); closeParagraph(); closeList(); closeQuote();
  if (code) html.push(`<pre><code>${escapeHtml(code.join("\n"))}</code></pre>`);
  return html.join("\n");
}

function walkMarkdown(dir) {
  const files = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (entry.name === "site" || entry.name === "tools") continue;
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) files.push(...walkMarkdown(full));
    if (entry.isFile() && entry.name.endsWith(".md")) files.push(full);
  }
  return files;
}

function titleFromMarkdown(markdown, fallback) {
  const match = markdown.match(/^#\s+(.+)$/m);
  return match ? match[1].replace(/[🚀🎯💰📁⚠️🔧📊🏁🖥️✅]/g, "").trim() : fallback;
}

function moduleFromRelative(relative) {
  const first = relative.split("/")[0];
  return first.endsWith(".md") ? "inicio" : first;
}

function moduleLabel(moduleName) {
  return moduleMeta[moduleName]?.label || moduleName.replace(/-/g, " ");
}

function readingTime(markdown) {
  const words = markdown.trim().split(/\s+/).filter(Boolean).length;
  return Math.max(1, Math.ceil(words / 180));
}

function buildLessons() {
  return walkMarkdown(root)
    .map((file) => {
      const relative = path.relative(root, file).replace(/\\/g, "/");
      const markdown = fs.readFileSync(file, "utf8");
      const moduleName = moduleFromRelative(relative);
      const title = titleFromMarkdown(markdown, path.basename(file, ".md"));
      const slug = slugify(relative.replace(/\.md$/i, ""));
      return {
        slug,
        title,
        module: moduleName,
        moduleLabel: moduleLabel(moduleName),
        relative,
        readingTime: readingTime(markdown),
        html: markdownToHtml(markdown),
        text: markdown.replace(/\s+/g, " ").trim(),
      };
    })
    .sort((a, b) => {
      const ai = moduleOrder.indexOf(a.module);
      const bi = moduleOrder.indexOf(b.module);
      const ao = ai === -1 ? 998 : ai;
      const bo = bi === -1 ? 998 : bi;
      if (a.module === "inicio") return -1;
      if (b.module === "inicio") return 1;
      if (ao !== bo) return ao - bo;
      return a.relative.localeCompare(b.relative, "pt-BR", { numeric: true });
    });
}

function groupModules(lessons) {
  const groups = new Map();
  for (const lesson of lessons) {
    if (!groups.has(lesson.module)) {
      const meta = moduleMeta[lesson.module] || {};
      groups.set(lesson.module, {
        id: lesson.module,
        label: moduleLabel(lesson.module),
        accent: meta.accent || "#ff9900",
        icon: meta.icon || "AWS",
        image: meta.image || moduleMeta.inicio.image,
        caption: meta.caption || "Projeto pratico AWS para fortalecer portfolio.",
        count: 0,
      });
    }
    groups.get(lesson.module).count += 1;
  }
  return Array.from(groups.values());
}

function writeData(lessons, modules) {
  const data = {
    generatedAt: new Date().toISOString(),
    title: "AWS Projetos Lab",
    subtitle: "Portfolio pratico AWS com projetos, arquitetura, seguranca, custo e operacao.",
    modules,
    lessons,
  };
  fs.writeFileSync(path.join(assetsDir, "data.js"), `window.STUDY_DATA = ${JSON.stringify(data, null, 2)};\n`, "utf8");
}

function writeIndex() {
  fs.writeFileSync(path.join(siteDir, "index.html"), `<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>AWS Projetos Lab</title>
  <link rel="stylesheet" href="./assets/styles.css">
</head>
<body>
  <div class="app-shell">
    <aside class="sidebar">
      <a class="brand" href="#inicio"><span class="brand-mark">AWS</span><span><strong>Projetos Lab</strong><small>Portfolio pratico</small></span></a>
      <div class="progress-panel"><div><span id="doneCount">0</span>/<span id="totalCount">0</span><small>aulas concluidas</small></div><div class="progress-track"><span id="progressBar"></span></div></div>
      <nav id="moduleNav" class="module-nav"></nav>
    </aside>
    <main class="main-area">
      <section class="hero-section" id="inicio">
        <div class="hero-copy">
          <span class="eyebrow">AWS do Zero ao Portfolio Senior</span>
          <h1>Construa projetos que contam uma historia de engenharia.</h1>
          <p>Uma experiencia visual para estudar cada modulo, revisar decisoes tecnicas e transformar laboratorio AWS em portfolio profissional.</p>
          <div class="hero-actions"><button id="startButton" class="primary-btn">Comecar trilha</button><button id="randomButton" class="secondary-btn">Revisao aleatoria</button></div>
        </div>
        <div class="architecture-visual">
          <div class="cloud-node core">AWS</div><div class="cloud-node node-a">S3</div><div class="cloud-node node-b">API</div><div class="cloud-node node-c">LMD</div><div class="cloud-node node-d">DB</div><div class="cloud-node node-e">OBS</div>
          <svg viewBox="0 0 520 320"><path d="M260 160 C160 80 130 90 95 90" /><path d="M260 160 C170 210 135 230 90 245" /><path d="M260 160 C260 65 260 60 260 45" /><path d="M260 160 C360 80 390 90 425 90" /><path d="M260 160 C360 225 395 235 430 245" /></svg>
        </div>
      </section>
      <section class="toolbar"><label class="search-box"><span>Buscar</span><input id="searchInput" type="search" placeholder="S3, Lambda, DynamoDB, portfolio, custo..."></label><select id="moduleFilter"></select><button id="toggleCompleted" class="ghost-btn" aria-pressed="false">Ocultar concluidas</button></section>
      <section class="stats-grid" id="statsGrid"></section>
      <section class="content-layout"><div class="lesson-list" id="lessonList"></div><article class="lesson-card" id="lessonView"></article></section>
    </main>
  </div>
  <script src="./assets/data.js"></script>
  <script src="./assets/app.js"></script>
</body>
</html>`, "utf8");
}

function writeStyles() {
  fs.writeFileSync(path.join(assetsDir, "styles.css"), `:root {
  --bg:#070707;--surface:#141414;--surface-2:#1f1f1f;--ink:#f5f5f5;--muted:#b8b8b8;--line:rgba(255,255,255,.12);--red:#e50914;--orange:#ff9900;--teal:#00a1c9;--shadow:0 24px 70px rgba(0,0,0,.55);
  font-family:Inter,ui-sans-serif,system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;
}
*{box-sizing:border-box}html{scroll-behavior:smooth}body{margin:0;color:var(--ink);background:radial-gradient(circle at 18% 0%,rgba(229,9,20,.22),transparent 32%),linear-gradient(180deg,#080808,#111 520px,#070707);animation:pageIn .55s ease both}a{color:#6ecbff}button,input,select{font:inherit}button{cursor:pointer}
@keyframes pageIn{from{opacity:0;transform:translateY(10px)}to{opacity:1;transform:translateY(0)}}@keyframes fadeInUp{from{opacity:0;transform:translateY(18px)}to{opacity:1;transform:translateY(0)}}@keyframes fadeOutDown{from{opacity:1;transform:translateY(0)}to{opacity:0;transform:translateY(12px)}}@keyframes softPulse{0%,100%{transform:translateY(0) scale(1)}50%{transform:translateY(-4px) scale(1.02)}}@keyframes lineFlow{to{stroke-dashoffset:-220}}
.app-shell{min-height:100vh;display:grid;grid-template-columns:310px minmax(0,1fr)}.sidebar{position:sticky;top:0;height:100vh;padding:22px;overflow:auto;background:linear-gradient(180deg,#151515,#080808);border-right:1px solid var(--line)}.brand{display:flex;gap:12px;align-items:center;color:inherit;text-decoration:none}.brand-mark{display:grid;place-items:center;min-width:50px;height:50px;border-radius:8px;color:#111;background:linear-gradient(135deg,#ffb000,#ff6a00);font-weight:950}.brand small,.progress-panel small{display:block;color:var(--muted)}.progress-panel{margin:24px 0;padding:16px;border:1px solid var(--line);border-radius:8px;background:rgba(255,255,255,.06)}.progress-panel span:first-child{font-size:28px;font-weight:900}.progress-track{height:9px;margin-top:14px;overflow:hidden;border-radius:999px;background:rgba(255,255,255,.14)}.progress-track span{display:block;width:0;height:100%;background:linear-gradient(90deg,var(--red),var(--orange));transition:width .25s ease}
.module-nav{display:grid;gap:7px}.module-link{display:grid;grid-template-columns:42px 1fr auto;gap:10px;align-items:center;width:100%;padding:10px;color:#f2f2f2;text-align:left;border:1px solid transparent;border-radius:8px;background:transparent;transition:.18s ease}.module-link:hover,.module-link.active{border-color:rgba(255,255,255,.16);background:rgba(255,255,255,.08)}.module-icon{display:grid;place-items:center;width:42px;height:42px;border-radius:8px;color:#fff;font-size:12px;font-weight:900}.module-link small{color:var(--muted)}
.main-area{min-width:0;padding:28px}.hero-section{display:grid;grid-template-columns:minmax(0,1fr)520px;gap:28px;min-height:440px;padding:36px;border-radius:8px;overflow:hidden;color:#fff;background:linear-gradient(135deg,rgba(0,0,0,.94),rgba(20,20,20,.68)),url("https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?auto=format&fit=crop&w=1800&q=80") center/cover;box-shadow:var(--shadow);animation:fadeInUp .7s ease both}.hero-copy{align-self:center}.eyebrow{display:inline-flex;padding:8px 12px;border-radius:999px;color:#ffd1d4;background:rgba(229,9,20,.25)}h1{margin:18px 0 14px;font-size:clamp(38px,6vw,76px);line-height:.95;letter-spacing:0}.hero-copy p{max-width:760px;color:#e1e1e1;font-size:18px;line-height:1.7}.hero-actions{display:flex;gap:12px;flex-wrap:wrap;margin-top:24px}.primary-btn,.secondary-btn,.ghost-btn{min-height:42px;padding:0 16px;border-radius:8px;border:1px solid transparent}.primary-btn{color:#fff;background:var(--red);font-weight:850}.secondary-btn{color:#fff;background:rgba(255,255,255,.14);border-color:var(--line)}.ghost-btn{color:#fff;background:#181818;border-color:var(--line)}
.architecture-visual{position:relative;min-height:320px;align-self:center}.architecture-visual svg{position:absolute;inset:0;width:100%;height:100%}.architecture-visual path{fill:none;stroke:rgba(255,255,255,.42);stroke-width:3;stroke-linecap:round;stroke-dasharray:12 18;animation:lineFlow 9s linear infinite}.cloud-node{position:absolute;z-index:1;display:grid;place-items:center;width:88px;height:88px;border:1px solid rgba(255,255,255,.32);border-radius:18px;color:#fff;font-weight:950;background:rgba(255,255,255,.12);box-shadow:0 16px 42px rgba(0,0,0,.25);backdrop-filter:blur(8px);animation:softPulse 5s ease-in-out infinite}.cloud-node.core{left:calc(50% - 54px);top:calc(50% - 54px);width:108px;height:108px;color:#111;background:linear-gradient(135deg,#ffb000,#ff6a00)}.node-a{left:44px;top:44px}.node-b{left:48px;bottom:42px}.node-c{left:calc(50% - 44px);top:0}.node-d{right:44px;top:44px}.node-e{right:40px;bottom:42px}
.toolbar{position:sticky;top:0;z-index:5;display:grid;grid-template-columns:minmax(260px,1fr)240px auto;gap:12px;align-items:end;margin:22px 0;padding:14px;border:1px solid var(--line);border-radius:8px;background:rgba(20,20,20,.92);backdrop-filter:blur(14px)}.search-box span{display:block;margin-bottom:6px;color:var(--muted);font-size:13px}.search-box input,select{width:100%;min-height:42px;border:1px solid var(--line);border-radius:8px;padding:0 12px;color:#fff;background:#0f0f0f}.stats-grid{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:14px;margin-bottom:22px}.stat-card{padding:18px;border-radius:8px;border:1px solid var(--line);background:var(--surface);animation:fadeInUp .45s ease both}.stat-card strong{display:block;font-size:28px}.stat-card span{color:var(--muted)}
.content-layout{display:grid;grid-template-columns:390px minmax(0,1fr);gap:20px;align-items:start}.lesson-list{display:grid;gap:10px;max-height:calc(100vh - 130px);overflow:auto;padding-right:4px}.lesson-item{width:100%;padding:14px;text-align:left;border:1px solid var(--line);border-left:5px solid var(--accent,var(--red));border-radius:8px;color:#fff;background:#171717;transition:.18s ease;animation:fadeInUp .28s ease both}.lesson-item:hover,.lesson-item.active{transform:translateY(-2px);box-shadow:0 16px 32px rgba(0,0,0,.35);background:#222}.lesson-item strong{display:block;margin-bottom:6px;line-height:1.35}.lesson-item small{color:var(--muted)}.lesson-item.done{background:#132016}
.lesson-card{min-width:0;padding:32px;border:1px solid var(--line);border-radius:8px;background:#f7f7f7;color:#151515;box-shadow:var(--shadow);transition:opacity .16s ease,transform .16s ease}.lesson-card.fade-in{animation:fadeInUp .34s ease both}.lesson-card.fade-out{animation:fadeOutDown .14s ease both}.lesson-card.full{max-width:980px;margin:0 auto}.lesson-toolbar{display:flex;gap:10px;flex-wrap:wrap;align-items:center;justify-content:space-between;margin-bottom:22px;padding-bottom:16px;border-bottom:1px solid #ddd}.lesson-kicker{color:#636363;font-size:13px;font-weight:850;text-transform:uppercase;letter-spacing:.08em}.complete-btn,.open-page{min-height:38px;padding:9px 12px;border-radius:8px;border:1px solid #d6d6d6;text-decoration:none;background:#fff;color:#111}.lesson-visual{position:relative;margin:0 0 28px;overflow:hidden;border-radius:8px;border:1px solid #ddd;background:#101827;animation:fadeInUp .42s ease both}.lesson-visual img{display:block;width:100%;height:clamp(180px,28vw,320px);object-fit:cover;opacity:.92;transform:scale(1.01);transition:.7s ease}.lesson-visual:hover img{opacity:1;transform:scale(1.05)}.lesson-visual:after{content:"";position:absolute;inset:0;background:linear-gradient(180deg,transparent 40%,rgba(0,0,0,.86));pointer-events:none}.lesson-visual figcaption{position:absolute;left:18px;right:18px;bottom:16px;z-index:1;color:#fff;font-weight:800;line-height:1.45;text-shadow:0 2px 18px rgba(0,0,0,.45)}
.lesson-card h1{color:#151515;font-size:clamp(34px,4vw,54px);line-height:1.04}.lesson-card h2{margin-top:34px;padding-top:10px;border-top:1px solid #ddd;font-size:27px}.lesson-card h3{font-size:21px}.lesson-card p,.lesson-card li{color:#2f3b4a;line-height:1.78}.lesson-card li+li{margin-top:8px}.lesson-card code{padding:2px 6px;border-radius:6px;color:#a92c00;background:#fff3e0}.lesson-card pre{overflow:auto;padding:18px;border-radius:8px;color:#e8eef8;background:#101827}.lesson-card pre code{padding:0;color:inherit;background:transparent}.lesson-card blockquote{margin:20px 0;padding:18px;border-left:5px solid var(--red);border-radius:8px;background:#fff0f1}.table-wrap{overflow-x:auto;margin:18px 0;border:1px solid #ddd;border-radius:8px}table{width:100%;border-collapse:collapse;background:#fff}th,td{padding:12px;border-bottom:1px solid #ddd;text-align:left;vertical-align:top}th{background:#f0f0f0}tr:last-child td{border-bottom:0}.page-shell{padding:28px}.back-link{display:inline-flex;margin-bottom:16px;padding:10px 12px;border-radius:8px;background:#fff;text-decoration:none}.page-nav{display:flex;justify-content:space-between;gap:16px;margin-top:32px;padding-top:20px;border-top:1px solid #ddd}.page-nav a{padding:12px;border-radius:8px;background:#f2f2f2;text-decoration:none}.empty-state{padding:30px;border:1px dashed var(--line);border-radius:8px;color:var(--muted);background:#171717}
@media(max-width:1160px){.app-shell{grid-template-columns:1fr}.sidebar{position:relative;height:auto}.hero-section,.content-layout{grid-template-columns:1fr}.lesson-list{max-height:none}}@media(max-width:760px){.main-area,.page-shell{padding:14px}.hero-section{padding:24px}.toolbar,.stats-grid{grid-template-columns:1fr}.lesson-card{padding:20px}.architecture-visual{display:none}.lesson-visual img{height:190px}}@media(prefers-reduced-motion:reduce){*,*:before,*:after{animation-duration:.001ms!important;animation-iteration-count:1!important;scroll-behavior:auto!important;transition-duration:.001ms!important}}
`, "utf8");
}

function writeApp() {
  fs.writeFileSync(path.join(assetsDir, "app.js"), `const data = window.STUDY_DATA;
const state = { query: "", module: "all", hideCompleted: false, activeSlug: location.hash.replace("#", "") || data.lessons[0]?.slug, completed: new Set(JSON.parse(localStorage.getItem("awsProjetosCompleted") || "[]")) };
const els = { moduleNav: document.getElementById("moduleNav"), moduleFilter: document.getElementById("moduleFilter"), lessonList: document.getElementById("lessonList"), lessonView: document.getElementById("lessonView"), searchInput: document.getElementById("searchInput"), toggleCompleted: document.getElementById("toggleCompleted"), doneCount: document.getElementById("doneCount"), totalCount: document.getElementById("totalCount"), progressBar: document.getElementById("progressBar"), statsGrid: document.getElementById("statsGrid"), startButton: document.getElementById("startButton"), randomButton: document.getElementById("randomButton") };
function saveCompleted(){localStorage.setItem("awsProjetosCompleted",JSON.stringify(Array.from(state.completed)))}
function activeLesson(){return data.lessons.find(l=>l.slug===state.activeSlug)||data.lessons[0]}
function activeModule(id){return data.modules.find(m=>m.id===id)||data.modules[0]}
function selectLesson(slug,scroll=true){if(!slug||slug===state.activeSlug)return;els.lessonView.classList.add("fade-out");setTimeout(()=>{state.activeSlug=slug;history.replaceState(null,"","#"+state.activeSlug);render();if(scroll)document.getElementById("lessonView").scrollIntoView({behavior:"smooth",block:"start"})},140)}
function filteredLessons(){const q=state.query.trim().toLowerCase();return data.lessons.filter(l=>(state.module==="all"||l.module===state.module)&&(!state.hideCompleted||!state.completed.has(l.slug))&&(!q||[l.title,l.moduleLabel,l.relative,l.text].join(" ").toLowerCase().includes(q)))}
function renderModules(){els.moduleNav.innerHTML=data.modules.map(m=>{const done=data.lessons.filter(l=>l.module===m.id&&state.completed.has(l.slug)).length;return '<button class="module-link '+(state.module===m.id?'active':'')+'" data-module="'+m.id+'"><span class="module-icon" style="background:'+m.accent+'">'+m.icon+'</span><span><strong>'+m.label+'</strong><small>'+done+'/'+m.count+' concluidas</small></span><small>'+m.count+'</small></button>'}).join("");els.moduleNav.querySelectorAll("button").forEach(b=>b.addEventListener("click",()=>{state.module=b.dataset.module;render()}));els.moduleFilter.innerHTML='<option value="all">Todos os modulos</option>'+data.modules.map(m=>'<option value="'+m.id+'" '+(state.module===m.id?'selected':'')+'>'+m.label+'</option>').join("")}
function renderStats(){const minutes=data.lessons.reduce((s,l)=>s+l.readingTime,0);const done=state.completed.size;const percent=data.lessons.length?Math.round(done/data.lessons.length*100):0;els.statsGrid.innerHTML=[["Modulos",data.modules.length],["Aulas",data.lessons.length],["Leitura",minutes+" min"],["Progresso",percent+"%"]].map(([label,value])=>'<div class="stat-card"><strong>'+value+'</strong><span>'+label+'</span></div>').join("");els.doneCount.textContent=done;els.totalCount.textContent=data.lessons.length;els.progressBar.style.width=percent+"%"}
function renderLessonList(){const lessons=filteredLessons();if(!lessons.length){els.lessonList.innerHTML='<div class="empty-state">Nada encontrado. Tente outro termo ou modulo.</div>';return}els.lessonList.innerHTML=lessons.map(l=>{const m=activeModule(l.module);const done=state.completed.has(l.slug);return '<button class="lesson-item '+(l.slug===state.activeSlug?'active ':'')+(done?'done':'')+'" style="--accent:'+m.accent+'" data-slug="'+l.slug+'"><strong>'+l.title+'</strong><small>'+l.moduleLabel+' · '+l.readingTime+' min · '+(done?'concluida':'pendente')+'</small></button>'}).join("");els.lessonList.querySelectorAll("button").forEach(b=>b.addEventListener("click",()=>selectLesson(b.dataset.slug)))}
function renderLesson(){const lesson=activeLesson();if(!lesson)return;const done=state.completed.has(lesson.slug);const mod=activeModule(lesson.module);els.lessonView.style.borderTop='6px solid '+mod.accent;els.lessonView.classList.remove("fade-out","fade-in");els.lessonView.innerHTML='<div class="lesson-toolbar"><div><div class="lesson-kicker">'+lesson.moduleLabel+' · '+lesson.readingTime+' min · '+lesson.relative+'</div></div><div><button class="complete-btn" id="completeButton">'+(done?'Marcar pendente':'Marcar concluida')+'</button> <a class="open-page" href="./pages/'+lesson.slug+'.html">Abrir pagina HTML</a></div></div><figure class="lesson-visual"><img src="'+mod.image+'" alt="Imagem de apoio para '+lesson.moduleLabel+'" loading="lazy"><figcaption>'+mod.caption+'</figcaption></figure>'+lesson.html;void els.lessonView.offsetWidth;els.lessonView.classList.add("fade-in");document.getElementById("completeButton").addEventListener("click",()=>{if(state.completed.has(lesson.slug))state.completed.delete(lesson.slug);else state.completed.add(lesson.slug);saveCompleted();render()})}
function render(){renderModules();renderStats();renderLessonList();renderLesson()}
els.searchInput.addEventListener("input",e=>{state.query=e.target.value;renderLessonList()});els.moduleFilter.addEventListener("change",e=>{state.module=e.target.value;render()});els.toggleCompleted.addEventListener("click",()=>{state.hideCompleted=!state.hideCompleted;els.toggleCompleted.setAttribute("aria-pressed",String(state.hideCompleted));els.toggleCompleted.textContent=state.hideCompleted?"Mostrar concluidas":"Ocultar concluidas";renderLessonList()});els.startButton.addEventListener("click",()=>{state.module="all";selectLesson(data.lessons[0]?.slug)});els.randomButton.addEventListener("click",()=>{const pool=filteredLessons();const lesson=pool[Math.floor(Math.random()*pool.length)]||data.lessons[0];selectLesson(lesson.slug)});window.addEventListener("hashchange",()=>{const slug=location.hash.replace("#","");if(data.lessons.some(l=>l.slug===slug))selectLesson(slug,false)});render();
`, "utf8");
}

function writePageHtml(lesson, previous, next, modulesById) {
  const mod = modulesById.get(lesson.module) || moduleMeta.inicio;
  const html = `<!doctype html>
<html lang="pt-BR">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>${escapeHtml(lesson.title)} | AWS Projetos Lab</title><link rel="stylesheet" href="../assets/styles.css"></head>
<body class="standalone-page"><main class="page-shell"><a class="back-link" href="../index.html#${lesson.slug}">Voltar para o painel</a><article class="lesson-card full"><div class="lesson-kicker">${escapeHtml(lesson.moduleLabel)} · ${lesson.readingTime} min</div><figure class="lesson-visual"><img src="${mod.image}" alt="Imagem de apoio para ${escapeHtml(lesson.moduleLabel)}" loading="lazy"><figcaption>${escapeHtml(mod.caption)}</figcaption></figure>${lesson.html}<nav class="page-nav">${previous ? `<a href="./${previous.slug}.html">Anterior: ${escapeHtml(previous.title)}</a>` : "<span></span>"}${next ? `<a href="./${next.slug}.html">Proximo: ${escapeHtml(next.title)}</a>` : "<span></span>"}</nav></article></main></body></html>`;
  fs.writeFileSync(path.join(pagesDir, `${lesson.slug}.html`), html, "utf8");
}

function writeReadme(lessons) {
  fs.writeFileSync(path.join(siteDir, "README.md"), `# Site de estudo AWS Projetos

Site gerado automaticamente a partir dos arquivos Markdown da pasta \`AWS Projetos\`.

## Como abrir

\`\`\`text
AWS Projetos/site/index.html
\`\`\`

## O que existe no site

- Painel principal com todos os modulos.
- Busca por projeto, servico ou conceito.
- Filtro por modulo.
- Progresso salvo no navegador.
- Revisao aleatoria.
- Transicoes com fade in/fade out.
- Imagens de apoio por modulo.
- ${lessons.length} paginas HTML individuais em \`site/pages/\`.

## Como regenerar

\`\`\`bash
node "AWS Projetos/tools/build-study-site.js"
\`\`\`
`, "utf8");
}

function build() {
  ensureDir(siteDir);
  ensureDir(assetsDir);
  ensureDir(pagesDir);
  const lessons = buildLessons();
  const modules = groupModules(lessons);
  const modulesById = new Map(modules.map((mod) => [mod.id, mod]));
  writeData(lessons, modules);
  writeIndex();
  writeStyles();
  writeApp();
  lessons.forEach((lesson, index) => writePageHtml(lesson, lessons[index - 1], lessons[index + 1], modulesById));
  writeReadme(lessons);
  console.log(`Generated AWS Projetos site with ${lessons.length} lessons.`);
}

build();
