const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const siteDir = path.join(root, "site");
const assetsDir = path.join(siteDir, "assets");
const pagesDir = path.join(siteDir, "pages");

const moduleOrder = [
  "modulo-00-guia-da-prova",
  "modulo-01-fundamentos-cloud",
  "modulo-02-infraestrutura-global",
  "modulo-03-seguranca-responsabilidade",
  "modulo-04-servicos-seguranca",
  "modulo-05-computacao",
  "modulo-06-armazenamento",
  "modulo-07-banco-de-dados",
  "modulo-08-rede-entrega-conteudo",
  "modulo-09-integracao-mensageria",
  "modulo-10-monitoramento-governanca",
  "modulo-11-machine-learning",
  "modulo-12-cobranca-e-suporte",
  "modulo-13-simulado-final",
  "modulo-14-revisao-senior-crianca",
];

const moduleMeta = {
  "modulo-00-guia-da-prova": { label: "Guia da prova", accent: "#6f42c1", icon: "MAP" },
  "modulo-01-fundamentos-cloud": { label: "Fundamentos", accent: "#ff9900", icon: "CLD" },
  "modulo-02-infraestrutura-global": { label: "Infra global", accent: "#2f80ed", icon: "REG" },
  "modulo-03-seguranca-responsabilidade": { label: "Responsabilidade", accent: "#d13212", icon: "IAM" },
  "modulo-04-servicos-seguranca": { label: "Seguranca", accent: "#dd344c", icon: "SEC" },
  "modulo-05-computacao": { label: "Computacao", accent: "#ed7100", icon: "CPU" },
  "modulo-06-armazenamento": { label: "Storage", accent: "#3f8624", icon: "S3" },
  "modulo-07-banco-de-dados": { label: "Banco de dados", accent: "#527fff", icon: "DB" },
  "modulo-08-rede-entrega-conteudo": { label: "Rede e CDN", accent: "#00a1c9", icon: "NET" },
  "modulo-09-integracao-mensageria": { label: "Integracao", accent: "#8c4fff", icon: "MSG" },
  "modulo-10-monitoramento-governanca": { label: "Governanca", accent: "#7aa116", icon: "OPS" },
  "modulo-11-machine-learning": { label: "Machine learning", accent: "#01a88d", icon: "ML" },
  "modulo-12-cobranca-e-suporte": { label: "Custos", accent: "#b7791f", icon: "FIN" },
  "modulo-13-simulado-final": { label: "Simulados", accent: "#495057", icon: "EXAM" },
  "modulo-14-revisao-senior-crianca": { label: "Revisao senior", accent: "#0f766e", icon: "PRO" },
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

function titleFromMarkdown(markdown, fallback) {
  const match = markdown.match(/^#\s+(.+)$/m);
  return match ? match[1].trim() : fallback;
}

function inlineMarkdown(text) {
  return escapeHtml(text)
    .replace(/`([^`]+)`/g, "<code>$1</code>")
    .replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>")
    .replace(/\*([^*]+)\*/g, "<em>$1</em>")
    .replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2" target="_blank" rel="noreferrer">$1</a>');
}

function convertTable(lines) {
  const rows = lines
    .filter((line) => line.trim().startsWith("|"))
    .map((line) => line.trim().replace(/^\||\|$/g, "").split("|").map((cell) => cell.trim()));

  if (rows.length < 2) return "";
  const header = rows[0];
  const body = rows.slice(2);

  return [
    '<div class="table-wrap"><table>',
    "<thead><tr>",
    ...header.map((cell) => `<th>${inlineMarkdown(cell)}</th>`),
    "</tr></thead><tbody>",
    ...body.map((row) => `<tr>${row.map((cell) => `<td>${inlineMarkdown(cell)}</td>`).join("")}</tr>`),
    "</tbody></table></div>",
  ].join("");
}

function markdownToHtml(markdown) {
  const lines = markdown.replace(/\r\n/g, "\n").split("\n");
  const html = [];
  let paragraph = [];
  let list = null;
  let code = null;
  let table = [];
  let blockquote = [];

  function closeParagraph() {
    if (!paragraph.length) return;
    html.push(`<p>${inlineMarkdown(paragraph.join(" "))}</p>`);
    paragraph = [];
  }

  function closeList() {
    if (!list) return;
    html.push(`</${list}>`);
    list = null;
  }

  function closeTable() {
    if (!table.length) return;
    closeParagraph();
    closeList();
    html.push(convertTable(table));
    table = [];
  }

  function closeBlockquote() {
    if (!blockquote.length) return;
    html.push(`<blockquote>${blockquote.map(inlineMarkdown).join("<br>")}</blockquote>`);
    blockquote = [];
  }

  for (const rawLine of lines) {
    const line = rawLine.replace(/\s+$/g, "");

    if (code !== null) {
      if (line.startsWith("```")) {
        html.push(`<pre><code>${escapeHtml(code.join("\n"))}</code></pre>`);
        code = null;
      } else {
        code.push(rawLine);
      }
      continue;
    }

    if (line.startsWith("```")) {
      closeTable();
      closeParagraph();
      closeList();
      closeBlockquote();
      code = [];
      continue;
    }

    if (line.trim().startsWith("|")) {
      table.push(line);
      continue;
    }
    closeTable();

    if (!line.trim()) {
      closeParagraph();
      closeList();
      closeBlockquote();
      continue;
    }

    if (line.startsWith(">")) {
      closeParagraph();
      closeList();
      blockquote.push(line.replace(/^>\s?/, ""));
      continue;
    }
    closeBlockquote();

    const heading = line.match(/^(#{1,6})\s+(.+)$/);
    if (heading) {
      closeParagraph();
      closeList();
      const level = heading[1].length;
      const text = heading[2].trim();
      const id = slugify(text);
      html.push(`<h${level} id="${id}">${inlineMarkdown(text)}</h${level}>`);
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

  closeTable();
  closeParagraph();
  closeList();
  closeBlockquote();
  if (code !== null) html.push(`<pre><code>${escapeHtml(code.join("\n"))}</code></pre>`);

  return html.join("\n");
}

function walkMarkdown(dir) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  const files = [];
  for (const entry of entries) {
    const full = path.join(dir, entry.name);
    if (entry.name === "site" || entry.name === "tools") continue;
    if (entry.isDirectory()) files.push(...walkMarkdown(full));
    if (entry.isFile() && entry.name.endsWith(".md")) files.push(full);
  }
  return files;
}

function moduleNameFromRelative(relative) {
  const first = relative.split(/[\\/]/)[0];
  return first.endsWith(".md") ? "inicio" : first;
}

function moduleLabel(moduleName) {
  if (moduleName === "inicio") return "Inicio";
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
      const moduleName = moduleNameFromRelative(relative);
      const title = titleFromMarkdown(markdown, path.basename(file, ".md"));
      const slug = slugify(relative.replace(/\.md$/i, ""));
      const html = markdownToHtml(markdown);
      const summary = markdown
        .replace(/^#.+$/m, "")
        .replace(/[#>*`|[\]()]/g, " ")
        .replace(/\s+/g, " ")
        .trim()
        .slice(0, 180);

      return {
        slug,
        title,
        module: moduleName,
        moduleLabel: moduleLabel(moduleName),
        relative,
        fileName: path.basename(relative),
        readingTime: readingTime(markdown),
        summary,
        html,
        text: markdown.replace(/\s+/g, " ").trim(),
      };
    })
    .sort((a, b) => {
      const ai = moduleOrder.indexOf(a.module);
      const bi = moduleOrder.indexOf(b.module);
      const ao = ai === -1 ? 999 : ai;
      const bo = bi === -1 ? 999 : bi;
      if (ao !== bo) return ao - bo;
      return a.relative.localeCompare(b.relative, "pt-BR", { numeric: true });
    });
}

function groupModules(lessons) {
  const groups = new Map();
  for (const lesson of lessons) {
    if (!groups.has(lesson.module)) {
      groups.set(lesson.module, {
        id: lesson.module,
        label: lesson.moduleLabel,
        accent: moduleMeta[lesson.module]?.accent || "#ff9900",
        icon: moduleMeta[lesson.module]?.icon || "AWS",
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
    sources: [
      {
        label: "AWS Architecture Icons",
        url: "https://aws.amazon.com/architecture/icons/",
      },
    ],
    modules,
    lessons,
  };
  fs.writeFileSync(path.join(assetsDir, "data.js"), `window.STUDY_DATA = ${JSON.stringify(data, null, 2)};\n`, "utf8");
}

function writePageHtml(lesson, previous, next) {
  const html = `<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${escapeHtml(lesson.title)} | AWS CLF-C02</title>
  <link rel="stylesheet" href="../assets/styles.css">
</head>
<body class="standalone-page">
  <main class="page-shell">
    <a class="back-link" href="../index.html#${lesson.slug}">Voltar para o painel</a>
    <article class="lesson-card full">
      <div class="lesson-kicker">${escapeHtml(lesson.moduleLabel)} · ${lesson.readingTime} min</div>
      ${lesson.html}
      <nav class="page-nav">
        ${previous ? `<a href="./${previous.slug}.html">Anterior: ${escapeHtml(previous.title)}</a>` : "<span></span>"}
        ${next ? `<a href="./${next.slug}.html">Proximo: ${escapeHtml(next.title)}</a>` : "<span></span>"}
      </nav>
    </article>
  </main>
</body>
</html>`;
  fs.writeFileSync(path.join(pagesDir, `${lesson.slug}.html`), html, "utf8");
}

function writeIndex() {
  fs.writeFileSync(path.join(siteDir, "index.html"), `<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>AWS CLF-C02 Study Lab</title>
  <link rel="stylesheet" href="./assets/styles.css">
</head>
<body>
  <div class="app-shell">
    <aside class="sidebar" aria-label="Navegacao dos modulos">
      <a class="brand" href="#inicio">
        <span class="brand-mark">AWS</span>
        <span>
          <strong>CLF-C02 Lab</strong>
          <small>Estudo visual e senior</small>
        </span>
      </a>
      <div class="progress-panel">
        <div>
          <span id="doneCount">0</span>/<span id="totalCount">0</span>
          <small>aulas concluidas</small>
        </div>
        <div class="progress-track"><span id="progressBar"></span></div>
      </div>
      <nav id="moduleNav" class="module-nav"></nav>
    </aside>

    <main class="main-area">
      <section class="hero-section" id="inicio">
        <div class="hero-copy">
          <span class="eyebrow">AWS Certified Cloud Practitioner</span>
          <h1>Estude CLF-C02 como quem entende arquitetura de verdade.</h1>
          <p>Todos os Markdown da pasta viraram uma experiencia HTML com busca, trilha, revisao senior, explicacao simples e progresso local no navegador.</p>
          <div class="hero-actions">
            <button id="startButton" class="primary-btn">Comecar estudo</button>
            <button id="randomButton" class="secondary-btn">Revisao aleatoria</button>
          </div>
        </div>
        <div class="architecture-visual" aria-label="Diagrama visual de estudos AWS">
          <div class="cloud-node core">AWS</div>
          <div class="cloud-node node-a">IAM</div>
          <div class="cloud-node node-b">S3</div>
          <div class="cloud-node node-c">EC2</div>
          <div class="cloud-node node-d">RDS</div>
          <div class="cloud-node node-e">CW</div>
          <svg viewBox="0 0 520 320" role="img" aria-label="Linhas conectando servicos AWS">
            <path d="M260 160 C160 80 130 90 95 90" />
            <path d="M260 160 C170 210 135 230 90 245" />
            <path d="M260 160 C260 65 260 60 260 45" />
            <path d="M260 160 C360 80 390 90 425 90" />
            <path d="M260 160 C360 225 395 235 430 245" />
          </svg>
        </div>
      </section>

      <section class="toolbar" aria-label="Ferramentas de estudo">
        <label class="search-box">
          <span>Buscar</span>
          <input id="searchInput" type="search" placeholder="Ex: CloudTrail, S3, responsabilidade, custo">
        </label>
        <select id="moduleFilter" aria-label="Filtrar modulo"></select>
        <button id="toggleCompleted" class="ghost-btn" aria-pressed="false">Ocultar concluidas</button>
      </section>

      <section class="stats-grid" id="statsGrid"></section>
      <section class="content-layout">
        <div class="lesson-list" id="lessonList"></div>
        <article class="lesson-card" id="lessonView"></article>
      </section>
    </main>
  </div>
  <script src="./assets/data.js"></script>
  <script src="./assets/app.js"></script>
</body>
</html>`, "utf8");
}

function writeStyles() {
  fs.writeFileSync(path.join(assetsDir, "styles.css"), String.raw`:root {
  --bg: #f5f7fb;
  --surface: #ffffff;
  --ink: #17202a;
  --muted: #657386;
  --line: #dfe6ef;
  --orange: #ff9900;
  --teal: #00a1c9;
  --green: #3f8624;
  --red: #d13212;
  --violet: #6f42c1;
  --shadow: 0 18px 45px rgba(23, 32, 42, 0.12);
  font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}

* { box-sizing: border-box; }
html { scroll-behavior: smooth; }
body {
  margin: 0;
  color: var(--ink);
  background:
    linear-gradient(135deg, rgba(255, 153, 0, 0.12), transparent 34%),
    linear-gradient(315deg, rgba(0, 161, 201, 0.12), transparent 32%),
    var(--bg);
}

a { color: #0073bb; }
button, input, select { font: inherit; }
button { cursor: pointer; }

.app-shell {
  min-height: 100vh;
  display: grid;
  grid-template-columns: 300px minmax(0, 1fr);
}

.sidebar {
  position: sticky;
  top: 0;
  height: 100vh;
  padding: 22px;
  overflow: auto;
  color: #f7fafc;
  background: linear-gradient(180deg, #161e2d 0%, #0f1724 100%);
  border-right: 1px solid rgba(255, 255, 255, 0.08);
}

.brand {
  display: flex;
  gap: 12px;
  align-items: center;
  color: inherit;
  text-decoration: none;
}

.brand-mark, .aws-token {
  display: grid;
  place-items: center;
  min-width: 48px;
  height: 48px;
  border-radius: 8px;
  color: #111827;
  background: linear-gradient(135deg, #ffb000, #ff7a00);
  font-weight: 900;
  letter-spacing: 0;
}

.brand small, .progress-panel small { display: block; color: #aab7c4; }

.progress-panel {
  margin: 24px 0;
  padding: 16px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.06);
}

.progress-panel span:first-child { font-size: 28px; font-weight: 800; }
.progress-track {
  height: 9px;
  margin-top: 14px;
  overflow: hidden;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.14);
}
.progress-track span {
  display: block;
  width: 0;
  height: 100%;
  background: linear-gradient(90deg, var(--orange), var(--teal));
  transition: width .25s ease;
}

.module-nav { display: grid; gap: 7px; }
.module-link {
  display: grid;
  grid-template-columns: 40px 1fr auto;
  gap: 10px;
  align-items: center;
  width: 100%;
  padding: 10px;
  color: #e7edf4;
  text-align: left;
  border: 1px solid transparent;
  border-radius: 8px;
  background: transparent;
}
.module-link:hover, .module-link.active {
  border-color: rgba(255, 255, 255, 0.14);
  background: rgba(255, 255, 255, 0.08);
}
.module-icon {
  display: grid;
  place-items: center;
  width: 40px;
  height: 40px;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 900;
  color: #fff;
}
.module-link small { color: #9fb0c2; }

.main-area { min-width: 0; padding: 28px; }
.hero-section {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 520px;
  gap: 28px;
  min-height: 440px;
  padding: 36px;
  border-radius: 8px;
  overflow: hidden;
  color: #fff;
  background:
    linear-gradient(135deg, rgba(16, 24, 39, .98), rgba(21, 33, 54, .94)),
    url("https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=1600&q=80") center/cover;
  box-shadow: var(--shadow);
}

.hero-copy { align-self: center; max-width: 760px; }
.eyebrow {
  display: inline-flex;
  padding: 7px 10px;
  border: 1px solid rgba(255, 255, 255, .2);
  border-radius: 999px;
  color: #ffd28a;
  background: rgba(0, 0, 0, .18);
}
h1 {
  margin: 18px 0 14px;
  font-size: clamp(38px, 6vw, 72px);
  line-height: .96;
  letter-spacing: 0;
}
.hero-copy p {
  max-width: 700px;
  color: #d8e2ef;
  font-size: 18px;
  line-height: 1.7;
}
.hero-actions { display: flex; flex-wrap: wrap; gap: 12px; margin-top: 24px; }
.primary-btn, .secondary-btn, .ghost-btn {
  min-height: 42px;
  padding: 0 16px;
  border-radius: 8px;
  border: 1px solid transparent;
}
.primary-btn { color: #111827; background: var(--orange); font-weight: 800; }
.secondary-btn { color: #fff; background: rgba(255,255,255,.12); border-color: rgba(255,255,255,.22); }
.ghost-btn { color: var(--ink); background: #fff; border-color: var(--line); }

.architecture-visual {
  position: relative;
  min-height: 320px;
  align-self: center;
}
.architecture-visual svg {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
}
.architecture-visual path {
  fill: none;
  stroke: rgba(255, 255, 255, .42);
  stroke-width: 3;
  stroke-linecap: round;
}
.cloud-node {
  position: absolute;
  z-index: 1;
  display: grid;
  place-items: center;
  width: 88px;
  height: 88px;
  border: 1px solid rgba(255, 255, 255, .32);
  border-radius: 18px;
  color: #fff;
  font-weight: 900;
  background: rgba(255, 255, 255, .12);
  box-shadow: 0 16px 42px rgba(0,0,0,.22);
  backdrop-filter: blur(8px);
}
.cloud-node.core { left: calc(50% - 54px); top: calc(50% - 54px); width: 108px; height: 108px; color: #111827; background: linear-gradient(135deg, #ffb000, #ff7a00); }
.node-a { left: 44px; top: 44px; }
.node-b { left: 48px; bottom: 42px; }
.node-c { left: calc(50% - 44px); top: 0; }
.node-d { right: 44px; top: 44px; }
.node-e { right: 40px; bottom: 42px; }

.toolbar {
  position: sticky;
  top: 0;
  z-index: 5;
  display: grid;
  grid-template-columns: minmax(260px, 1fr) 240px auto;
  gap: 12px;
  align-items: end;
  margin: 22px 0;
  padding: 14px;
  border: 1px solid var(--line);
  border-radius: 8px;
  background: rgba(255,255,255,.92);
  backdrop-filter: blur(12px);
}
.search-box span { display: block; margin-bottom: 6px; color: var(--muted); font-size: 13px; }
.search-box input, select {
  width: 100%;
  min-height: 42px;
  border: 1px solid var(--line);
  border-radius: 8px;
  padding: 0 12px;
  background: #fff;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 14px;
  margin-bottom: 22px;
}
.stat-card {
  padding: 18px;
  border-radius: 8px;
  border: 1px solid var(--line);
  background: var(--surface);
}
.stat-card strong { display: block; font-size: 28px; }
.stat-card span { color: var(--muted); }

.content-layout {
  display: grid;
  grid-template-columns: 380px minmax(0, 1fr);
  gap: 20px;
  align-items: start;
}
.lesson-list {
  display: grid;
  gap: 10px;
  max-height: calc(100vh - 130px);
  overflow: auto;
  padding-right: 4px;
}
.lesson-item {
  width: 100%;
  padding: 14px;
  text-align: left;
  border: 1px solid var(--line);
  border-left: 5px solid var(--accent, var(--orange));
  border-radius: 8px;
  background: #fff;
}
.lesson-item:hover, .lesson-item.active { box-shadow: 0 10px 24px rgba(23,32,42,.08); transform: translateY(-1px); }
.lesson-item strong { display: block; margin-bottom: 6px; line-height: 1.35; }
.lesson-item small { color: var(--muted); }
.lesson-item.done { background: #f5fbf4; }

.lesson-card {
  min-width: 0;
  padding: 32px;
  border: 1px solid var(--line);
  border-radius: 8px;
  background: var(--surface);
  box-shadow: var(--shadow);
}
.lesson-card.full { max-width: 980px; margin: 0 auto; }
.lesson-toolbar {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 22px;
  padding-bottom: 16px;
  border-bottom: 1px solid var(--line);
}
.lesson-kicker {
  color: var(--muted);
  font-size: 13px;
  font-weight: 800;
  text-transform: uppercase;
  letter-spacing: .08em;
}
.complete-btn {
  min-height: 38px;
  padding: 0 12px;
  border-radius: 8px;
  border: 1px solid #b6dfb0;
  color: #1f6b2a;
  background: #f2fbef;
}
.open-page {
  min-height: 38px;
  padding: 9px 12px;
  border-radius: 8px;
  color: #075985;
  background: #eef8ff;
  text-decoration: none;
}

.lesson-card h1 { color: var(--ink); font-size: clamp(34px, 4vw, 54px); line-height: 1.04; }
.lesson-card h2 { margin-top: 34px; padding-top: 10px; border-top: 1px solid var(--line); font-size: 27px; }
.lesson-card h3 { font-size: 21px; }
.lesson-card p, .lesson-card li { color: #2f3b4a; line-height: 1.78; }
.lesson-card li + li { margin-top: 8px; }
.lesson-card code {
  padding: 2px 6px;
  border-radius: 6px;
  color: #a92c00;
  background: #fff3e0;
}
.lesson-card pre {
  overflow: auto;
  padding: 18px;
  border-radius: 8px;
  color: #e8eef8;
  background: #101827;
}
.lesson-card pre code { padding: 0; color: inherit; background: transparent; }
.lesson-card blockquote {
  margin: 20px 0;
  padding: 18px;
  border-left: 5px solid var(--orange);
  border-radius: 8px;
  background: #fff8ed;
}
.table-wrap { overflow-x: auto; margin: 18px 0; border: 1px solid var(--line); border-radius: 8px; }
table { width: 100%; border-collapse: collapse; background: #fff; }
th, td { padding: 12px; border-bottom: 1px solid var(--line); text-align: left; vertical-align: top; }
th { color: #111827; background: #f3f6fb; }
tr:last-child td { border-bottom: 0; }

.page-shell { padding: 28px; }
.back-link {
  display: inline-flex;
  margin-bottom: 16px;
  padding: 10px 12px;
  border-radius: 8px;
  background: #fff;
  text-decoration: none;
}
.page-nav {
  display: flex;
  justify-content: space-between;
  gap: 16px;
  margin-top: 32px;
  padding-top: 20px;
  border-top: 1px solid var(--line);
}
.page-nav a { padding: 12px; border-radius: 8px; background: #f2f6fb; text-decoration: none; }

.empty-state {
  padding: 30px;
  border: 1px dashed var(--line);
  border-radius: 8px;
  color: var(--muted);
  background: #fff;
}

@media (max-width: 1160px) {
  .app-shell { grid-template-columns: 1fr; }
  .sidebar { position: relative; height: auto; }
  .hero-section, .content-layout { grid-template-columns: 1fr; }
  .architecture-visual { min-height: 300px; }
  .lesson-list { max-height: none; }
}

@media (max-width: 760px) {
  .main-area, .page-shell { padding: 14px; }
  .hero-section { padding: 24px; }
  .toolbar, .stats-grid { grid-template-columns: 1fr; }
  .lesson-card { padding: 20px; }
  .architecture-visual { display: none; }
}
`, "utf8");
}

function clientApp() {
const data = window.STUDY_DATA;
const state = {
  query: "",
  module: "all",
  hideCompleted: false,
  activeSlug: location.hash.replace("#", "") || data.lessons[0]?.slug,
  completed: new Set(JSON.parse(localStorage.getItem("clfCompleted") || "[]")),
};

const els = {
  moduleNav: document.getElementById("moduleNav"),
  moduleFilter: document.getElementById("moduleFilter"),
  lessonList: document.getElementById("lessonList"),
  lessonView: document.getElementById("lessonView"),
  searchInput: document.getElementById("searchInput"),
  toggleCompleted: document.getElementById("toggleCompleted"),
  doneCount: document.getElementById("doneCount"),
  totalCount: document.getElementById("totalCount"),
  progressBar: document.getElementById("progressBar"),
  statsGrid: document.getElementById("statsGrid"),
  startButton: document.getElementById("startButton"),
  randomButton: document.getElementById("randomButton"),
};

function saveCompleted() {
  localStorage.setItem("clfCompleted", JSON.stringify(Array.from(state.completed)));
}

function activeLesson() {
  return data.lessons.find((lesson) => lesson.slug === state.activeSlug) || data.lessons[0];
}

function filteredLessons() {
  const q = state.query.trim().toLowerCase();
  return data.lessons.filter((lesson) => {
    const matchesModule = state.module === "all" || lesson.module === state.module;
    const matchesDone = !state.hideCompleted || !state.completed.has(lesson.slug);
    const matchesQuery = !q || [lesson.title, lesson.moduleLabel, lesson.relative, lesson.text].join(" ").toLowerCase().includes(q);
    return matchesModule && matchesDone && matchesQuery;
  });
}

function renderModules() {
  els.moduleNav.innerHTML = data.modules.map((mod) => {
    const done = data.lessons.filter((lesson) => lesson.module === mod.id && state.completed.has(lesson.slug)).length;
    return `<button class="module-link ${state.module === mod.id ? "active" : ""}" data-module="${mod.id}">
      <span class="module-icon" style="background:${mod.accent}">${mod.icon}</span>
      <span><strong>${mod.label}</strong><small>${done}/${mod.count} concluidas</small></span>
      <small>${mod.count}</small>
    </button>`;
  }).join("");

  els.moduleNav.querySelectorAll("button").forEach((button) => {
    button.addEventListener("click", () => {
      state.module = button.dataset.module;
      render();
    });
  });

  els.moduleFilter.innerHTML = `<option value="all">Todos os modulos</option>` + data.modules
    .map((mod) => `<option value="${mod.id}" ${state.module === mod.id ? "selected" : ""}>${mod.label}</option>`)
    .join("");
}

function renderStats() {
  const minutes = data.lessons.reduce((sum, lesson) => sum + lesson.readingTime, 0);
  const done = state.completed.size;
  const percent = data.lessons.length ? Math.round((done / data.lessons.length) * 100) : 0;
  els.statsGrid.innerHTML = [
    ["Modulos", data.modules.length],
    ["Aulas", data.lessons.length],
    ["Leitura", `${minutes} min`],
    ["Progresso", `${percent}%`],
  ].map(([label, value]) => `<div class="stat-card"><strong>${value}</strong><span>${label}</span></div>`).join("");

  els.doneCount.textContent = done;
  els.totalCount.textContent = data.lessons.length;
  els.progressBar.style.width = `${percent}%`;
}

function renderLessonList() {
  const lessons = filteredLessons();
  if (!lessons.length) {
    els.lessonList.innerHTML = `<div class="empty-state">Nada encontrado. Tente buscar por outro servico ou modulo.</div>`;
    return;
  }
  els.lessonList.innerHTML = lessons.map((lesson) => {
    const mod = data.modules.find((item) => item.id === lesson.module);
    const done = state.completed.has(lesson.slug);
    return `<button class="lesson-item ${lesson.slug === state.activeSlug ? "active" : ""} ${done ? "done" : ""}" style="--accent:${mod?.accent || "#ff9900"}" data-slug="${lesson.slug}">
      <strong>${lesson.title}</strong>
      <small>${lesson.moduleLabel} · ${lesson.readingTime} min · ${done ? "concluida" : "pendente"}</small>
    </button>`;
  }).join("");

  els.lessonList.querySelectorAll("button").forEach((button) => {
    button.addEventListener("click", () => {
      state.activeSlug = button.dataset.slug;
      history.replaceState(null, "", `#${state.activeSlug}`);
      render();
      document.getElementById("lessonView").scrollIntoView({ behavior: "smooth", block: "start" });
    });
  });
}

function renderLesson() {
  const lesson = activeLesson();
  if (!lesson) return;
  const done = state.completed.has(lesson.slug);
  const mod = data.modules.find((item) => item.id === lesson.module);
  els.lessonView.style.borderTop = `6px solid ${mod?.accent || "#ff9900"}`;
  els.lessonView.innerHTML = `<div class="lesson-toolbar">
    <div>
      <div class="lesson-kicker">${lesson.moduleLabel} · ${lesson.readingTime} min · ${lesson.relative}</div>
    </div>
    <div>
      <button class="complete-btn" id="completeButton">${done ? "Marcar pendente" : "Marcar concluida"}</button>
      <a class="open-page" href="./pages/${lesson.slug}.html">Abrir pagina HTML</a>
    </div>
  </div>
  ${lesson.html}`;

  document.getElementById("completeButton").addEventListener("click", () => {
    if (state.completed.has(lesson.slug)) state.completed.delete(lesson.slug);
    else state.completed.add(lesson.slug);
    saveCompleted();
    render();
  });
}

function render() {
  renderModules();
  renderStats();
  renderLessonList();
  renderLesson();
}

els.searchInput.addEventListener("input", (event) => {
  state.query = event.target.value;
  renderLessonList();
});

els.moduleFilter.addEventListener("change", (event) => {
  state.module = event.target.value;
  render();
});

els.toggleCompleted.addEventListener("click", () => {
  state.hideCompleted = !state.hideCompleted;
  els.toggleCompleted.setAttribute("aria-pressed", String(state.hideCompleted));
  els.toggleCompleted.textContent = state.hideCompleted ? "Mostrar concluidas" : "Ocultar concluidas";
  renderLessonList();
});

els.startButton.addEventListener("click", () => {
  state.activeSlug = data.lessons[0]?.slug;
  state.module = "all";
  history.replaceState(null, "", `#${state.activeSlug}`);
  render();
  document.getElementById("lessonView").scrollIntoView({ behavior: "smooth", block: "start" });
});

els.randomButton.addEventListener("click", () => {
  const pool = filteredLessons();
  const lesson = pool[Math.floor(Math.random() * pool.length)] || data.lessons[0];
  state.activeSlug = lesson.slug;
  history.replaceState(null, "", `#${state.activeSlug}`);
  render();
  document.getElementById("lessonView").scrollIntoView({ behavior: "smooth", block: "start" });
});

window.addEventListener("hashchange", () => {
  const slug = location.hash.replace("#", "");
  if (data.lessons.some((lesson) => lesson.slug === slug)) {
    state.activeSlug = slug;
    render();
  }
});

render();
}

function writeApp() {
  fs.writeFileSync(path.join(assetsDir, "app.js"), `(${clientApp.toString()})();\n`, "utf8");
}

function build() {
  ensureDir(siteDir);
  ensureDir(assetsDir);
  ensureDir(pagesDir);

  const lessons = buildLessons();
  const modules = groupModules(lessons);

  writeIndex();
  writeStyles();
  writeApp();
  writeData(lessons, modules);

  lessons.forEach((lesson, index) => {
    writePageHtml(lesson, lessons[index - 1], lessons[index + 1]);
  });

  console.log(`Generated ${lessons.length} HTML lessons in ${path.relative(process.cwd(), siteDir)}`);
}

build();
