const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const assetsDir = path.join(root, "assets");

const ignoredDirs = new Set([".git", "assets", "tools", "PROMPTS", "node_modules"]);

const meta = {
  "AWS CLF02": {
    title: "AWS CLF-C02 Study Lab",
    category: "AWS",
    level: "Certificacao",
    badge: "Site pronto",
    image: "https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=1400&q=80",
    description: "Curso visual para AWS Cloud Practitioner CLF-C02 com aulas HTML, revisao e progresso.",
  },
  "AWS Projetos": {
    title: "AWS Projetos - Portfolio Pratico",
    category: "AWS",
    level: "Portfolio",
    badge: "Projetos",
    image: "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?auto=format&fit=crop&w=1400&q=80",
    description: "Projetos praticos AWS com foco em portfolio, custo, seguranca e entrevistas.",
  },
  "AWS SOLUTIONS ARCHITECT": {
    title: "AWS Solutions Architect",
    category: "AWS",
    level: "Arquitetura",
    badge: "SAA",
    image: "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1400&q=80",
    description: "Conteudos para arquitetura AWS e preparacao Solutions Architect.",
  },
  Ansible: {
    title: "Ansible Senior",
    category: "DevOps",
    level: "Senior",
    badge: "Automacao",
    image: "https://images.unsplash.com/photo-1515879218367-8466d910aaa4?auto=format&fit=crop&w=1400&q=80",
    description: "Automacao, playbooks, roles, inventarios e entrevista senior em Ansible.",
  },
  Docker: {
    title: "Docker",
    category: "Containers",
    level: "Fundamentos",
    badge: "Containers",
    image: "https://images.unsplash.com/photo-1605745341112-85968b19335b?auto=format&fit=crop&w=1400&q=80",
    description: "Docker do ambiente inicial a imagens, containers, redes e boas praticas.",
  },
  "Git + Vim": {
    title: "Git + Vim",
    category: "Ferramentas",
    level: "Base",
    badge: "Workflow",
    image: "https://images.unsplash.com/photo-1461749280684-dccba630e2f6?auto=format&fit=crop&w=1400&q=80",
    description: "Fluxo de trabalho com Git, versionamento, Vim e produtividade no terminal.",
  },
  "Ingles DevOps": {
    title: "Ingles DevOps",
    category: "Carreira",
    level: "Comunicacao",
    badge: "English",
    image: "https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=1400&q=80",
    description: "Ingles tecnico para DevOps, entrevistas, apresentacao pessoal e rotina profissional.",
  },
  Jenkins: {
    title: "Jenkins CI/CD Senior",
    category: "CI/CD",
    level: "Senior",
    badge: "Pipeline",
    image: "https://images.unsplash.com/photo-1552664730-d307ca884978?auto=format&fit=crop&w=1400&q=80",
    description: "Jenkins CI/CD com pipelines, automacao, boas praticas e entrevistas.",
  },
  Kubernetes_01: {
    title: "Kubernetes 01",
    category: "Kubernetes",
    level: "Inicio",
    badge: "K8s",
    image: "https://images.unsplash.com/photo-1667372393119-3d4c48d07fc9?auto=format&fit=crop&w=1400&q=80",
    description: "Primeiros passos em Kubernetes, conceitos, clusters e objetos principais.",
  },
  Kubernetes_02: {
    title: "Kubernetes 02",
    category: "Kubernetes",
    level: "Laboratorio",
    badge: "Vazio",
    image: "https://images.unsplash.com/photo-1667372393119-3d4c48d07fc9?auto=format&fit=crop&w=1400&q=80",
    description: "Espaco reservado para evoluir laboratorios Kubernetes.",
  },
  Kubernetes_03: {
    title: "Kubernetes Senior",
    category: "Kubernetes",
    level: "Senior",
    badge: "K8s Senior",
    image: "https://images.unsplash.com/photo-1667372393119-3d4c48d07fc9?auto=format&fit=crop&w=1400&q=80",
    description: "Kubernetes em nivel senior com guia de entrevista e fundamentos praticos.",
  },
  "Linux Bash": {
    title: "Linux Bash",
    category: "Linux",
    level: "Shell",
    badge: "Bash",
    image: "https://images.unsplash.com/photo-1629654297299-c8506221ca97?auto=format&fit=crop&w=1400&q=80",
    description: "Automacao e linha de comando com Bash para administracao Linux.",
  },
  "Linux Rsync SSH": {
    title: "Linux Rsync SSH",
    category: "Linux",
    level: "Rede",
    badge: "SSH",
    image: "https://images.unsplash.com/photo-1558494949-ef010cbdcc31?auto=format&fit=crop&w=1400&q=80",
    description: "Rsync, SSH, sincronizacao, transferencia segura e operacao remota.",
  },
  "Linux Security": {
    title: "Linux Security",
    category: "Linux",
    level: "Seguranca",
    badge: "Hardening",
    image: "https://images.unsplash.com/photo-1550751827-4bd374c3f58b?auto=format&fit=crop&w=1400&q=80",
    description: "Seguranca Linux, hardening, auditoria, servicos vulneraveis e defesa.",
  },
  "Linux SysAdmin": {
    title: "Linux SysAdmin",
    category: "Linux",
    level: "SysAdmin",
    badge: "Admin",
    image: "https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=1400&q=80",
    description: "Administracao Linux, sistema, servicos, usuarios, rede e operacao.",
  },
  "Linux Tetris": {
    title: "Linux Tetris",
    category: "Projetos",
    level: "Game",
    badge: "HTML",
    image: "https://images.unsplash.com/photo-1550745165-9bc0b252726f?auto=format&fit=crop&w=1400&q=80",
    description: "Projeto interativo em HTML com tema Linux e Tetris.",
  },
  "Linux Virtualização": {
    title: "Linux Virtualizacao",
    category: "Linux",
    level: "Senior",
    badge: "Virtualizacao",
    image: "https://images.unsplash.com/photo-1516321165247-4aa89a48be28?auto=format&fit=crop&w=1400&q=80",
    description: "Virtualizacao Linux, KVM, libvirt, imagens, redes e operacao senior.",
  },
  "Maven, Gradle": {
    title: "Maven & Gradle",
    category: "Build",
    level: "Java",
    badge: "Build tools",
    image: "https://images.unsplash.com/photo-1515879218367-8466d910aaa4?auto=format&fit=crop&w=1400&q=80",
    description: "Maven e Gradle do zero ao senior para projetos Java e automacao de build.",
  },
  Vagrant: {
    title: "Vagrant",
    category: "DevOps",
    level: "Laboratorio",
    badge: "VMs",
    image: "https://images.unsplash.com/photo-1516321165247-4aa89a48be28?auto=format&fit=crop&w=1400&q=80",
    description: "Vagrant para ambientes reproduziveis, provisionamento e laboratorios locais.",
  },
};

function ensureDir(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

function slash(value) {
  return value.replace(/\\/g, "/");
}

function encodeHref(relativePath) {
  return slash(relativePath).split("/").map(encodeURIComponent).join("/");
}

function countFiles(dir, ext) {
  let count = 0;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) count += countFiles(full, ext);
    if (entry.isFile() && entry.name.toLowerCase().endsWith(ext)) count += 1;
  }
  return count;
}

function firstFile(dir, ext) {
  const found = [];
  function walk(current) {
    for (const entry of fs.readdirSync(current, { withFileTypes: true })) {
      const full = path.join(current, entry.name);
      if (entry.isDirectory()) walk(full);
      if (entry.isFile() && entry.name.toLowerCase().endsWith(ext)) found.push(full);
    }
  }
  walk(dir);
  return found.sort((a, b) => a.localeCompare(b, "pt-BR", { numeric: true }))[0] || "";
}

function readTitle(readmePath, fallback) {
  if (!readmePath || !fs.existsSync(readmePath)) return fallback;
  const content = fs.readFileSync(readmePath, "utf8");
  const match = content.match(/^#\s+(.+)$/m);
  return match ? match[1].replace(/[🚀🎯💰📁⚠️🔧📊🏁🖥️]/g, "").trim() : fallback;
}

function courseTarget(dir) {
  const site = path.join(dir, "site", "index.html");
  if (fs.existsSync(site)) return site;
  const readme = path.join(dir, "README.md");
  if (fs.existsSync(readme)) return readme;
  const html = firstFile(dir, ".html");
  if (html) return html;
  const md = firstFile(dir, ".md");
  if (md) return md;
  return dir;
}

function buildCourses() {
  return fs.readdirSync(root, { withFileTypes: true })
    .filter((entry) => entry.isDirectory() && !ignoredDirs.has(entry.name))
    .map((entry) => {
      const dir = path.join(root, entry.name);
      const readme = path.join(dir, "README.md");
      const mdCount = countFiles(dir, ".md");
      const htmlCount = countFiles(dir, ".html");
      const fileCount = countFiles(dir, "");
      const target = courseTarget(dir);
      const info = meta[entry.name] || {};
      const hasSite = fs.existsSync(path.join(dir, "site", "index.html"));
      const title = info.title || readTitle(readme, entry.name);
      return {
        folder: entry.name,
        title,
        category: info.category || "Cursos",
        level: info.level || "Estudo",
        badge: info.badge || (hasSite ? "Site" : "Curso"),
        image: info.image || "https://images.unsplash.com/photo-1519389950473-47ba0277781c?auto=format&fit=crop&w=1400&q=80",
        description: info.description || `Curso com ${mdCount} arquivos Markdown e ${fileCount} arquivos de estudo.`,
        mdCount,
        htmlCount,
        fileCount,
        hasSite,
        href: encodeHref(path.relative(root, target)),
        updatedAt: fs.statSync(dir).mtime.toISOString(),
      };
    })
    .sort((a, b) => {
      if (a.hasSite !== b.hasSite) return a.hasSite ? -1 : 1;
      return a.title.localeCompare(b.title, "pt-BR");
    });
}

function writeData(courses) {
  const data = {
    generatedAt: new Date().toISOString(),
    totalCourses: courses.length,
    categories: Array.from(new Set(courses.map((course) => course.category))).sort(),
    courses,
  };
  fs.writeFileSync(path.join(assetsDir, "catalog-data.js"), `window.COURSE_CATALOG = ${JSON.stringify(data, null, 2)};\n`, "utf8");
}

function writeIndex() {
  fs.writeFileSync(path.join(root, "index.html"), `<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>EstudoFlix - Catalogo de Cursos</title>
  <link rel="stylesheet" href="./assets/catalog.css">
</head>
<body>
  <header class="hero">
    <nav class="topbar">
      <a class="logo" href="./index.html">Estudo<span>Flix</span></a>
      <div class="top-actions">
        <a href="./AWS%20CLF02/site/index.html">Continuar AWS CLF02</a>
        <a href="./PROMPTS/converter-curso-md-para-site-html.md">Prompt mestre</a>
      </div>
    </nav>
    <section class="hero-content">
      <div>
        <p class="eyebrow">Seu hub de aprendizado DevOps, AWS e Linux</p>
        <h1>Escolha o proximo curso como quem escolhe uma serie boa.</h1>
        <p>Todos os cursos da pasta Estudo em um catalogo visual, com busca, filtros e atalhos para abrir cada trilha.</p>
        <div class="hero-buttons">
          <button id="playFeatured">Assistir destaque</button>
          <button id="shuffleCourse">Surpreenda-me</button>
        </div>
      </div>
      <article class="featured-card" id="featuredCard"></article>
    </section>
  </header>

  <main class="catalog-shell">
    <section class="controls">
      <label>
        <span>Buscar curso</span>
        <input id="searchInput" type="search" placeholder="AWS, Linux, Docker, Kubernetes...">
      </label>
      <label>
        <span>Categoria</span>
        <select id="categoryFilter"></select>
      </label>
      <label>
        <span>Status</span>
        <select id="statusFilter">
          <option value="all">Todos</option>
          <option value="site">Com site pronto</option>
          <option value="content">Com conteudo</option>
          <option value="empty">Vazios/reservados</option>
        </select>
      </label>
    </section>

    <section class="stats" id="stats"></section>
    <section id="rows" class="rows"></section>
  </main>

  <script src="./assets/catalog-data.js"></script>
  <script src="./assets/catalog.js"></script>
</body>
</html>`, "utf8");
}

function writeCss() {
  fs.writeFileSync(path.join(assetsDir, "catalog.css"), `:root {
  --bg: #070707;
  --panel: #141414;
  --panel-2: #1f1f1f;
  --text: #f5f5f5;
  --muted: #b3b3b3;
  --red: #e50914;
  --line: rgba(255,255,255,.12);
  --shadow: 0 24px 70px rgba(0,0,0,.55);
  font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}
* { box-sizing: border-box; }
html { scroll-behavior: smooth; }
body {
  margin: 0;
  color: var(--text);
  background:
    radial-gradient(circle at 20% 0%, rgba(229,9,20,.24), transparent 32%),
    linear-gradient(180deg, rgba(0,0,0,.24), #070707 520px),
    var(--bg);
  animation: pageIn .5s ease both;
}
a { color: inherit; }
button, input, select { font: inherit; }
button { cursor: pointer; }
@keyframes pageIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
@keyframes cardIn { from { opacity: 0; transform: translateY(18px) scale(.98); } to { opacity: 1; transform: translateY(0) scale(1); } }

.hero {
  min-height: 620px;
  padding: 26px clamp(18px, 4vw, 56px) 64px;
  background:
    linear-gradient(90deg, rgba(0,0,0,.92), rgba(0,0,0,.54), rgba(0,0,0,.84)),
    url("https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1800&q=80") center/cover;
}
.topbar {
  display: flex;
  justify-content: space-between;
  gap: 20px;
  align-items: center;
}
.logo {
  color: var(--red);
  text-decoration: none;
  font-size: clamp(28px, 4vw, 46px);
  font-weight: 950;
  letter-spacing: 0;
}
.logo span { color: #fff; }
.top-actions { display: flex; gap: 12px; flex-wrap: wrap; }
.top-actions a {
  padding: 10px 14px;
  border: 1px solid var(--line);
  border-radius: 8px;
  text-decoration: none;
  background: rgba(255,255,255,.08);
}
.hero-content {
  display: grid;
  grid-template-columns: minmax(0, 1fr) minmax(320px, 440px);
  gap: 36px;
  align-items: end;
  min-height: 500px;
}
.eyebrow {
  display: inline-flex;
  padding: 8px 12px;
  border-radius: 999px;
  color: #ffd0d3;
  background: rgba(229,9,20,.22);
}
h1 {
  max-width: 900px;
  margin: 20px 0 16px;
  font-size: clamp(44px, 7vw, 86px);
  line-height: .92;
  letter-spacing: 0;
}
.hero-content p:not(.eyebrow) {
  max-width: 760px;
  color: #e4e4e4;
  font-size: 19px;
  line-height: 1.7;
}
.hero-buttons { display: flex; gap: 12px; flex-wrap: wrap; margin-top: 26px; }
.hero-buttons button {
  min-height: 46px;
  padding: 0 18px;
  border-radius: 8px;
  border: 1px solid transparent;
  font-weight: 800;
}
#playFeatured { color: #fff; background: var(--red); }
#shuffleCourse { color: #fff; background: rgba(255,255,255,.16); border-color: var(--line); }
.featured-card {
  overflow: hidden;
  border-radius: 8px;
  border: 1px solid var(--line);
  background: rgba(20,20,20,.76);
  box-shadow: var(--shadow);
  backdrop-filter: blur(12px);
  animation: cardIn .65s ease both;
}
.featured-card img { width: 100%; height: 240px; object-fit: cover; display: block; }
.featured-card div { padding: 18px; }
.featured-card small { color: #ffb4b8; font-weight: 800; text-transform: uppercase; }
.featured-card h2 { margin: 8px 0; }
.featured-card p { color: var(--muted); line-height: 1.55; }
.featured-card a {
  display: inline-flex;
  margin-top: 10px;
  padding: 10px 14px;
  border-radius: 8px;
  color: #fff;
  background: var(--red);
  text-decoration: none;
  font-weight: 800;
}

.catalog-shell { padding: 0 clamp(18px, 4vw, 56px) 60px; }
.controls {
  position: sticky;
  top: 0;
  z-index: 5;
  display: grid;
  grid-template-columns: minmax(260px, 1fr) 220px 220px;
  gap: 12px;
  margin-top: -28px;
  padding: 14px;
  border: 1px solid var(--line);
  border-radius: 8px;
  background: rgba(20,20,20,.92);
  backdrop-filter: blur(14px);
}
.controls span { display: block; margin-bottom: 7px; color: var(--muted); font-size: 13px; }
.controls input, .controls select {
  width: 100%;
  min-height: 44px;
  border: 1px solid var(--line);
  border-radius: 8px;
  color: #fff;
  background: #0f0f0f;
  padding: 0 12px;
}
.stats {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 12px;
  margin: 26px 0;
}
.stat {
  padding: 18px;
  border: 1px solid var(--line);
  border-radius: 8px;
  background: var(--panel);
}
.stat strong { display: block; font-size: 30px; }
.stat span { color: var(--muted); }
.rows { display: grid; gap: 34px; }
.row h2 { margin: 0 0 14px; }
.rail {
  display: grid;
  grid-auto-flow: column;
  grid-auto-columns: minmax(250px, 320px);
  gap: 14px;
  overflow-x: auto;
  padding: 4px 4px 20px;
  scroll-snap-type: x proximity;
}
.course-card {
  position: relative;
  min-height: 360px;
  overflow: hidden;
  border: 1px solid var(--line);
  border-radius: 8px;
  background: var(--panel);
  text-decoration: none;
  scroll-snap-align: start;
  transition: transform .22s ease, box-shadow .22s ease, border-color .22s ease;
  animation: cardIn .38s ease both;
}
.course-card:hover {
  transform: translateY(-8px) scale(1.02);
  border-color: rgba(255,255,255,.34);
  box-shadow: var(--shadow);
}
.course-card img { width: 100%; height: 170px; object-fit: cover; display: block; transition: transform .45s ease; }
.course-card:hover img { transform: scale(1.08); }
.course-body { padding: 14px; }
.course-meta { display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 10px; }
.pill {
  padding: 5px 8px;
  border-radius: 999px;
  color: #fff;
  background: rgba(229,9,20,.82);
  font-size: 12px;
  font-weight: 800;
}
.pill.secondary { background: rgba(255,255,255,.14); }
.course-card h3 { margin: 0 0 8px; font-size: 21px; line-height: 1.15; }
.course-card p { color: var(--muted); line-height: 1.48; margin: 0 0 12px; }
.course-stats { display: flex; gap: 10px; color: #d7d7d7; font-size: 13px; flex-wrap: wrap; }
.empty {
  padding: 36px;
  border: 1px dashed var(--line);
  border-radius: 8px;
  color: var(--muted);
}
@media (max-width: 900px) {
  .hero-content, .controls, .stats { grid-template-columns: 1fr; }
  .hero { min-height: auto; }
}
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: .001ms !important;
    animation-iteration-count: 1 !important;
    scroll-behavior: auto !important;
    transition-duration: .001ms !important;
  }
}
`, "utf8");
}

function writeJs() {
  fs.writeFileSync(path.join(assetsDir, "catalog.js"), `const catalog = window.COURSE_CATALOG;
const state = { query: "", category: "all", status: "all" };
const els = {
  featured: document.getElementById("featuredCard"),
  rows: document.getElementById("rows"),
  stats: document.getElementById("stats"),
  search: document.getElementById("searchInput"),
  category: document.getElementById("categoryFilter"),
  status: document.getElementById("statusFilter"),
  play: document.getElementById("playFeatured"),
  shuffle: document.getElementById("shuffleCourse"),
};

const featured = catalog.courses.find((course) => course.folder === "AWS CLF02") || catalog.courses[0];

function filteredCourses() {
  const q = state.query.trim().toLowerCase();
  return catalog.courses.filter((course) => {
    const matchesQuery = !q || [course.title, course.folder, course.category, course.description, course.level].join(" ").toLowerCase().includes(q);
    const matchesCategory = state.category === "all" || course.category === state.category;
    const matchesStatus =
      state.status === "all" ||
      (state.status === "site" && course.hasSite) ||
      (state.status === "content" && course.fileCount > 0) ||
      (state.status === "empty" && course.fileCount === 0);
    return matchesQuery && matchesCategory && matchesStatus;
  });
}

function renderFeatured() {
  els.featured.innerHTML = \`
    <img src="\${featured.image}" alt="\${featured.title}">
    <div>
      <small>\${featured.category} · \${featured.level}</small>
      <h2>\${featured.title}</h2>
      <p>\${featured.description}</p>
      <a href="\${featured.href}">Abrir curso</a>
    </div>\`;
}

function renderFilters() {
  els.category.innerHTML = '<option value="all">Todas</option>' + catalog.categories
    .map((category) => \`<option value="\${category}">\${category}</option>\`)
    .join("");
}

function renderStats(courses) {
  const siteCount = catalog.courses.filter((course) => course.hasSite).length;
  const mdCount = catalog.courses.reduce((sum, course) => sum + course.mdCount, 0);
  const htmlCount = catalog.courses.reduce((sum, course) => sum + course.htmlCount, 0);
  els.stats.innerHTML = [
    ["Cursos", catalog.totalCourses],
    ["Sites prontos", siteCount],
    ["Markdown", mdCount],
    ["Paginas HTML", htmlCount],
  ].map(([label, value]) => \`<div class="stat"><strong>\${value}</strong><span>\${label}</span></div>\`).join("");
}

function card(course, index) {
  return \`<a class="course-card" href="\${course.href}" style="animation-delay:\${Math.min(index * 35, 280)}ms">
    <img src="\${course.image}" alt="\${course.title}" loading="lazy">
    <div class="course-body">
      <div class="course-meta">
        <span class="pill">\${course.badge}</span>
        <span class="pill secondary">\${course.level}</span>
      </div>
      <h3>\${course.title}</h3>
      <p>\${course.description}</p>
      <div class="course-stats">
        <span>\${course.mdCount} md</span>
        <span>\${course.htmlCount} html</span>
        <span>\${course.fileCount} arquivos</span>
      </div>
    </div>
  </a>\`;
}

function renderRows() {
  const courses = filteredCourses();
  renderStats(courses);
  if (!courses.length) {
    els.rows.innerHTML = '<div class="empty">Nenhum curso encontrado com esses filtros.</div>';
    return;
  }
  const groups = new Map();
  for (const course of courses) {
    if (!groups.has(course.category)) groups.set(course.category, []);
    groups.get(course.category).push(course);
  }
  els.rows.innerHTML = Array.from(groups.entries())
    .map(([category, items]) => \`<section class="row">
      <h2>\${category}</h2>
      <div class="rail">\${items.map(card).join("")}</div>
    </section>\`)
    .join("");
}

els.search.addEventListener("input", (event) => {
  state.query = event.target.value;
  renderRows();
});
els.category.addEventListener("change", (event) => {
  state.category = event.target.value;
  renderRows();
});
els.status.addEventListener("change", (event) => {
  state.status = event.target.value;
  renderRows();
});
els.play.addEventListener("click", () => {
  window.location.href = featured.href;
});
els.shuffle.addEventListener("click", () => {
  const pool = filteredCourses();
  const course = pool[Math.floor(Math.random() * pool.length)] || featured;
  window.location.href = course.href;
});

renderFeatured();
renderFilters();
renderRows();
`, "utf8");
}

function build() {
  ensureDir(assetsDir);
  const courses = buildCourses();
  writeData(courses);
  writeIndex();
  writeCss();
  writeJs();
  console.log(`Generated catalog with ${courses.length} courses.`);
}

build();
