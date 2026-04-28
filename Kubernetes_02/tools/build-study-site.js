const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const siteDir = path.join(root, "site");
const assetsDir = path.join(siteDir, "assets");
const pagesDir = path.join(siteDir, "pages");

const COURSE = {
  title: "Kubernetes 02",
  shortTitle: "K8S-02 Lab",
  subtitle: "Curso Kubernetes 02",
  description:
    "Curso convertido para um site estatico com trilha por modulos, busca, progresso local, paginas HTML individuais e revisao guiada por labs Kubernetes.",
  focus: [
    "Conteudo aguardando arquivos didaticos",
    "Estrutura pronta para Markdown, YAML, scripts e HTML",
    "Mesmo tema visual usado nos demais cursos",
    "Geracao estatica sem necessidade de servidor",
  ],
};

const allowedExtensions = new Set([
  ".md",
  ".sh",
  ".yaml",
  ".yml",
  ".py",
  ".js",
  ".json",
  ".html",
  ".css",
  ".dockerfile",
]);

const allowedNames = new Set(["dockerfile", "makefile", "license"]);
const ignoredDirs = new Set([".git", "site", "tools", "node_modules"]);
const moduleImages = [
  ["00", "https://images.unsplash.com/photo-1667372393119-3d4c48d07fc9?auto=format&fit=crop&w=1200&q=80", "Materiais gerais para alinhar conceitos e revisar antes dos labs."],
  ["01", "https://images.unsplash.com/photo-1515879218367-8466d910aaa4?auto=format&fit=crop&w=1200&q=80", "Fundamentos: pods, namespaces e services para formar a base operacional."],
  ["02", "https://images.unsplash.com/photo-1558494949-ef010cbdcc31?auto=format&fit=crop&w=1200&q=80", "Intermediario: replicas, deployments, rollout, probes, ConfigMap e Secret."],
  ["03", "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=1200&q=80", "Avancado: ingress, HPA, storage, RBAC, NetworkPolicy e stateful workloads."],
  ["04", "https://images.unsplash.com/photo-1497366811353-6870744d04b2?auto=format&fit=crop&w=1200&q=80", "Projeto final consolida manifestos de producao em uma arquitetura completa."],
];

function ensureDir(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

function removeDir(dir) {
  if (fs.existsSync(dir)) fs.rmSync(dir, { recursive: true, force: true });
}

function slash(filePath) {
  return filePath.split(path.sep).join("/");
}

function escapeHtml(value) {
  return String(value ?? "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

function fixMojibake(text) {
  if (!/[ÃƒÃ‚Ã¢â‚¬Ã°Å¸]/.test(text)) return text;
  try {
    const cp1252 = new Map([
      ["â‚¬", 0x80], ["â€š", 0x82], ["Æ’", 0x83], ["â€ž", 0x84], ["â€¦", 0x85],
      ["â€ ", 0x86], ["â€¡", 0x87], ["Ë†", 0x88], ["â€°", 0x89], ["Å ", 0x8a],
      ["â€¹", 0x8b], ["Å’", 0x8c], ["Å½", 0x8e], ["â€˜", 0x91], ["â€™", 0x92],
      ["â€œ", 0x93], ["â€", 0x94], ["â€¢", 0x95], ["â€“", 0x96], ["â€”", 0x97],
      ["Ëœ", 0x98], ["â„¢", 0x99], ["Å¡", 0x9a], ["â€º", 0x9b], ["Å“", 0x9c],
      ["Å¾", 0x9e], ["Å¸", 0x9f],
    ]);
    const bytes = [];
    for (const char of text) {
      const mapped = cp1252.get(char);
      if (mapped !== undefined) bytes.push(mapped);
      else {
        const code = char.charCodeAt(0);
        bytes.push(code <= 0xff ? code : 0x3f);
      }
    }
    const repaired = Buffer.from(bytes).toString("utf8");
    const oldScore = (text.match(/[ÃƒÃ‚Ã¢â‚¬Ã°Å¸]/g) || []).length;
    const newScore = (repaired.match(/[ÃƒÃ‚Ã¢â‚¬Ã°Å¸ï¿½]/g) || []).length;
    return newScore < oldScore ? repaired : text;
  } catch {
    return text;
  }
}

function slugify(text) {
  return fixMojibake(text)
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 90) || "aula";
}

function titleFromPath(relative, content) {
  const firstHeading = content.match(/^#\s+(.+)$/m);
  if (firstHeading) return cleanInline(firstHeading[1]);
  const base = path.basename(relative, path.extname(relative));
  if (/^readme$/i.test(base)) return path.basename(path.dirname(relative)).replace(/-/g, " ");
  return base.replace(/[-_]/g, " ");
}

function cleanInline(text) {
  return fixMojibake(text)
    .replace(/<[^>]+>/g, "")
    .replace(/!\[[^\]]*\]\([^)]+\)/g, "")
    .replace(/\[([^\]]+)\]\([^)]+\)/g, "$1")
    .replace(/[*_`>#]/g, "")
    .replace(/\s+/g, " ")
    .trim();
}

function walk(dir, files = []) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (entry.isDirectory()) {
      if (!ignoredDirs.has(entry.name)) walk(path.join(dir, entry.name), files);
      continue;
    }
    if (dir === root && entry.name.toLowerCase() === "index.html") continue;
    const full = path.join(dir, entry.name);
    const rel = slash(path.relative(root, full));
    const ext = path.extname(entry.name).toLowerCase();
    const name = entry.name.toLowerCase();
    if (allowedExtensions.has(ext) || allowedNames.has(name)) files.push(rel);
  }
  return files;
}

function moduleInfo(relative) {
  const first = relative.split("/")[0];
  const match = first.match(/^modulo[-_](\d+)[-_](.+)$/i) || first.match(/^(\d+)-(.+)$/);
  if (match) {
    const number = String(Number(match[1])).padStart(2, "0");
    const label = `Modulo ${number} - ${fixMojibake(match[2]).replace(/[-_]/g, " ")}`;
    return { id: slugify(first), label, raw: first, number };
  }
  return { id: "curso", label: "Curso e materiais gerais", raw: "Curso", number: "00" };
}

function fileKind(relative) {
  const base = path.basename(relative).toLowerCase();
  const ext = path.extname(base).replace(".", "");
  if (base === "dockerfile") return "Dockerfile";
  if (base === "makefile") return "Makefile";
  if (!ext) return "Arquivo";
  const map = {
    md: "Markdown",
    sh: "Shell script",
    yaml: "YAML",
    yml: "YAML",
    py: "Python",
    js: "JavaScript",
    json: "JSON",
    html: "HTML",
    css: "CSS",
  };
  return map[ext] || ext.toUpperCase();
}

function readingTime(text) {
  const words = cleanInline(text).split(/\s+/).filter(Boolean).length;
  return Math.max(1, Math.ceil(words / 180));
}

function markdownToHtml(markdown) {
  let text = fixMojibake(markdown).replace(/\r\n/g, "\n");
  const stash = [];
  text = text.replace(/```([^\n`]*)\n([\s\S]*?)```/g, (_, lang, code) => {
    const token = `@@CODE_${stash.length}@@`;
    stash.push(`<pre><code class="language-${escapeHtml(lang.trim())}">${escapeHtml(code.trimEnd())}</code></pre>`);
    return token;
  });
  text = text.replace(/<details>([\s\S]*?)<\/details>/gi, (_, body) => {
    const token = `@@DETAILS_${stash.length}@@`;
    const summary = body.match(/<summary>([\s\S]*?)<\/summary>/i);
    const summaryHtml = summary ? inlineMarkdown(summary[1]) : "Resposta";
    const rest = body.replace(/<summary>[\s\S]*?<\/summary>/i, "").trim();
    stash.push(`<details>${`<summary>${summaryHtml}</summary>`}${markdownToHtml(rest)}</details>`);
    return token;
  });
  text = text.replace(/<p align="center">([\s\S]*?)<\/p>/gi, (_, body) => {
    const token = `@@HTML_${stash.length}@@`;
    stash.push(`<div class="centered-html">${body}</div>`);
    return token;
  });

  const lines = text.split("\n");
  const html = [];
  let i = 0;

  while (i < lines.length) {
    const line = lines[i];
    if (!line.trim()) {
      i += 1;
      continue;
    }
    if (/^@@(CODE|DETAILS|HTML)_\d+@@$/.test(line.trim())) {
      html.push(resolveStash(line.trim(), stash));
      i += 1;
      continue;
    }
    const heading = line.match(/^(#{1,6})\s+(.+)$/);
    if (heading) {
      const level = heading[1].length;
      html.push(`<h${level}>${inlineMarkdown(heading[2])}</h${level}>`);
      i += 1;
      continue;
    }
    if (/^---+$/.test(line.trim())) {
      html.push("<hr>");
      i += 1;
      continue;
    }
    if (/^>\s?/.test(line)) {
      const block = [];
      while (i < lines.length && /^>\s?/.test(lines[i])) {
        block.push(lines[i].replace(/^>\s?/, ""));
        i += 1;
      }
      html.push(`<blockquote>${markdownToHtml(block.join("\n"))}</blockquote>`);
      continue;
    }
    if (isTableStart(lines, i)) {
      const table = [];
      while (i < lines.length && /^\s*\|/.test(lines[i])) {
        table.push(lines[i]);
        i += 1;
      }
      html.push(renderTable(table));
      continue;
    }
    if (/^\s*[-*]\s+/.test(line)) {
      const items = [];
      while (i < lines.length && /^\s*[-*]\s+/.test(lines[i])) {
        items.push(lines[i].replace(/^\s*[-*]\s+/, ""));
        i += 1;
      }
      html.push(`<ul>${items.map((item) => `<li>${inlineMarkdown(item)}</li>`).join("")}</ul>`);
      continue;
    }
    if (/^\s*\d+[.)]\s+/.test(line)) {
      const items = [];
      while (i < lines.length && /^\s*\d+[.)]\s+/.test(lines[i])) {
        items.push(lines[i].replace(/^\s*\d+[.)]\s+/, ""));
        i += 1;
      }
      html.push(`<ol>${items.map((item) => `<li>${inlineMarkdown(item)}</li>`).join("")}</ol>`);
      continue;
    }

    const para = [];
    while (
      i < lines.length &&
      lines[i].trim() &&
      !/^(#{1,6})\s+/.test(lines[i]) &&
      !/^\s*[-*]\s+/.test(lines[i]) &&
      !/^\s*\d+[.)]\s+/.test(lines[i]) &&
      !/^>\s?/.test(lines[i]) &&
      !isTableStart(lines, i) &&
      !/^@@(CODE|DETAILS|HTML)_\d+@@$/.test(lines[i].trim())
    ) {
      para.push(lines[i]);
      i += 1;
    }
    html.push(`<p>${inlineMarkdown(para.join(" "))}</p>`);
  }

  return html.join("\n").replace(/@@(?:CODE|DETAILS|HTML)_(\d+)@@/g, (_, index) => stash[Number(index)] || "");
}

function resolveStash(token, stash) {
  const match = token.match(/@@(?:CODE|DETAILS|HTML)_(\d+)@@/);
  return match ? stash[Number(match[1])] : token;
}

function inlineMarkdown(text) {
  let value = escapeHtml(fixMojibake(text));
  value = value.replace(/!\[([^\]]*)\]\(([^)]+)\)/g, '<img src="$2" alt="$1" loading="lazy">');
  value = value.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2">$1</a>');
  value = value.replace(/`([^`]+)`/g, "<code>$1</code>");
  value = value.replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>");
  value = value.replace(/\*([^*]+)\*/g, "<em>$1</em>");
  return value.replace(/\s{2,}/g, "<br>");
}

function isTableStart(lines, index) {
  return /^\s*\|/.test(lines[index] || "") && /^\s*\|?[\s:-]+\|/.test(lines[index + 1] || "");
}

function renderTable(lines) {
  const rows = lines
    .filter((line, index) => index !== 1)
    .map((line) => line.trim().replace(/^\||\|$/g, "").split("|").map((cell) => inlineMarkdown(cell.trim())));
  if (!rows.length) return "";
  const head = rows[0].map((cell) => `<th>${cell}</th>`).join("");
  const body = rows.slice(1).map((row) => `<tr>${row.map((cell) => `<td>${cell}</td>`).join("")}</tr>`).join("");
  return `<div class="table-wrap"><table><thead><tr>${head}</tr></thead><tbody>${body}</tbody></table></div>`;
}

function codeToHtml(relative, content) {
  const kind = fileKind(relative);
  const safe = escapeHtml(fixMojibake(content).trimEnd());
  return `<div class="code-study">
    <p><strong>Tipo:</strong> ${kind}</p>
    <p><strong>Arquivo convertido:</strong> este conteudo foi transformado em uma pagina HTML do curso.</p>
    <p>Leia este arquivo como evidencia pratica do laboratorio. Primeiro entenda o objetivo, depois revise namespace, selectors, portas, recursos, permissoes, persistencia e pontos de rollback.</p>
    <pre><code>${safe}</code></pre>
  </div>`;
}

function buildLesson(file, index) {
  const absolute = path.join(root, file);
  const raw = fs.readFileSync(absolute, "utf8");
  const fixed = fixMojibake(raw);
  const mod = moduleInfo(file);
  const ext = path.extname(file).toLowerCase();
  const title = titleFromPath(file, fixed);
  const slug = `${String(index + 1).padStart(3, "0")}-${slugify(file.replace(/\.[^.]+$/, ""))}`;
  const baseHtml = ext === ".md" ? markdownToHtml(fixed) : codeToHtml(file, fixed);
  const html = officialNoticeForOutdatedExamWeights(fixed) + baseHtml;
  return {
    title,
    slug,
    module: mod.id,
    moduleLabel: mod.label,
    moduleNumber: mod.number,
    relative: file,
    kind: fileKind(file),
    readingTime: readingTime(fixed),
    text: cleanInline(fixed).slice(0, 5000),
    html,
    sourceHtml: html,
  };
}

function normalizeRelativeLink(fromRelative, href) {
  if (!href || /^(?:https?:|mailto:|tel:|#)/i.test(href)) return null;
  const [target] = href.split("#");
  if (!target || target.startsWith("/")) return null;
  const decoded = target.replace(/\\/g, "/");
  const fromDir = path.posix.dirname(slash(fromRelative));
  return slash(path.posix.normalize(path.posix.join(fromDir, decoded)));
}

function rewriteInternalLinks(html, fromRelative, lessons, mode) {
  const byRelative = new Map(lessons.map((lesson) => [lesson.relative, lesson]));
  return html.replace(/href="([^"]+)"/g, (full, href) => {
    const target = normalizeRelativeLink(fromRelative, href);
    if (!target) return full;
    const lesson = byRelative.get(target);
    if (!lesson) return full;
    const hash = href.includes("#") ? `#${href.split("#").slice(1).join("#")}` : "";
    const pageHref = mode === "standalone" ? `./${lesson.slug}.html${hash}` : `./pages/${lesson.slug}.html${hash}`;
    return `href="${pageHref}"`;
  });
}

function officialNoticeForOutdatedExamWeights(content) {
  return "";
}

function moduleAccent(index) {
  const colors = ["#ff9900", "#00a1c9", "#3f8624", "#6f42c1", "#d13212", "#2563eb", "#0f766e", "#b45309"];
  return colors[index % colors.length];
}

function visualForModule(moduleNumber) {
  const item = moduleImages.find(([number]) => number === moduleNumber) || moduleImages[0];
  return { image: item[1], caption: item[2] };
}

function pageTemplate({ title, body, prefix = "." }) {
  return `<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${escapeHtml(title)}</title>
  <link rel="stylesheet" href="${prefix}/assets/styles.css">
</head>
<body class="standalone-page">
${body}
<script src="${prefix}/assets/data.js"></script>
<script src="${prefix}/assets/quiz.js"></script>
</body>
</html>
`;
}

function renderStandaloneLesson(lesson, prev, next, modules) {
  const mod = modules.find((item) => item.id === lesson.module);
  const visual = visualForModule(lesson.moduleNumber);
  const pageHtml = lesson.pageHtml || lesson.html;
  return pageTemplate({
    title: `${lesson.title} - ${COURSE.shortTitle}`,
    prefix: "..",
    body: `<main class="page-shell">
  <a class="back-link" href="../index.html#${lesson.slug}">Voltar ao painel</a>
  <article class="lesson-card full" style="border-top:6px solid ${mod?.accent || "#ff9900"}">
    <div class="lesson-toolbar">
      <div class="lesson-kicker">${escapeHtml(lesson.moduleLabel)} - ${lesson.readingTime} min - aula HTML</div>
    </div>
    <figure class="lesson-visual">
      <img src="${visual.image}" alt="Imagem de apoio para ${escapeHtml(lesson.moduleLabel)}" loading="lazy">
      <figcaption>${escapeHtml(visual.caption)}</figcaption>
    </figure>
    ${pageHtml}
    <nav class="page-nav">
      ${prev ? `<a href="./${prev.slug}.html">Aula anterior</a>` : "<span></span>"}
      ${next ? `<a href="./${next.slug}.html">Proxima aula</a>` : "<span></span>"}
    </nav>
  </article>
</main>`,
  });
}

function buildData(lessons) {
  const moduleMap = new Map();
  for (const lesson of lessons) {
    if (!moduleMap.has(lesson.module)) {
      moduleMap.set(lesson.module, {
        id: lesson.module,
        label: lesson.moduleLabel,
        number: lesson.moduleNumber,
        count: 0,
      });
    }
    moduleMap.get(lesson.module).count += 1;
  }
  const modules = Array.from(moduleMap.values())
    .sort((a, b) => a.number.localeCompare(b.number) || a.label.localeCompare(b.label))
    .map((mod, index) => ({
      ...mod,
      accent: moduleAccent(index),
      icon: mod.number === "00" ? "K8S" : mod.number,
      visual: visualForModule(mod.number),
    }));
  return { modules, lessons };
}

function indexHtml() {
  return `<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${COURSE.title}</title>
  <link rel="stylesheet" href="./assets/styles.css">
</head>
<body>
  <div class="app-shell">
    <aside class="sidebar" aria-label="Navegacao dos modulos">
      <a class="brand" href="#inicio">
        <span class="brand-mark">K8S</span>
        <span>
          <strong>${COURSE.shortTitle}</strong>
          <small>Kubernetes, YAML e labs</small>
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
          <span class="eyebrow">${COURSE.subtitle}</span>
          <h1>Estude Kubernetes com pratica, manifestos e revisao visual.</h1>
          <p>${COURSE.description}</p>
          <div class="hero-actions">
            <button id="startButton" class="primary-btn">Comecar estudo</button>
            <button id="randomButton" class="secondary-btn">Revisao aleatoria</button>
          </div>
        </div>
        <div class="architecture-visual" aria-label="Diagrama visual de componentes Kubernetes">
          <div class="cloud-node core">K8S</div>
          <div class="cloud-node node-a">POD</div>
          <div class="cloud-node node-b">SVC</div>
          <div class="cloud-node node-c">DEP</div>
          <div class="cloud-node node-d">PVC</div>
          <div class="cloud-node node-e">RBAC</div>
          <svg viewBox="0 0 520 320" role="img" aria-label="Linhas conectando componentes Kubernetes">
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
          <input id="searchInput" type="search" placeholder="Ex: pod, service, ingress, hpa, rbac">
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
  <script src="./assets/quiz.js"></script>
  <script src="./assets/app.js"></script>
</body>
</html>
`;
}

function appJs() {
  return `(function clientApp() {
  const data = window.STUDY_DATA;
  const storageKey = "${COURSE.shortTitle.replace(/[^a-z0-9]/gi, "")}Completed";
  const state = {
    query: "",
    module: "all",
    hideCompleted: false,
    activeSlug: location.hash.replace("#", "") || data.lessons[0]?.slug,
    completed: new Set(JSON.parse(localStorage.getItem(storageKey) || "[]")),
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
    localStorage.setItem(storageKey, JSON.stringify(Array.from(state.completed)));
  }
  function activeLesson() {
    return data.lessons.find((lesson) => lesson.slug === state.activeSlug) || data.lessons[0];
  }
  function selectLesson(slug, shouldScroll = true) {
    if (!slug || slug === state.activeSlug) return;
    els.lessonView.classList.add("fade-out");
    window.setTimeout(() => {
      state.activeSlug = slug;
      history.replaceState(null, "", "#" + state.activeSlug);
      render();
      if (shouldScroll) els.lessonView.scrollIntoView({ behavior: "smooth", block: "start" });
    }, 140);
  }
  function filteredLessons() {
    const q = state.query.trim().toLowerCase();
    return data.lessons.filter((lesson) => {
      const matchesModule = state.module === "all" || lesson.module === state.module;
      const matchesDone = !state.hideCompleted || !state.completed.has(lesson.slug);
      const haystack = [lesson.title, lesson.moduleLabel, lesson.relative, lesson.kind, lesson.text].join(" ").toLowerCase();
      return matchesModule && matchesDone && (!q || haystack.includes(q));
    });
  }
  function renderModules() {
    els.moduleNav.innerHTML = data.modules.map((mod) => {
      const done = data.lessons.filter((lesson) => lesson.module === mod.id && state.completed.has(lesson.slug)).length;
      return '<button class="module-link ' + (state.module === mod.id ? "active" : "") + '" data-module="' + mod.id + '">' +
        '<span class="module-icon" style="background:' + mod.accent + '">' + mod.icon + '</span>' +
        '<span><strong>' + mod.label + '</strong><small>' + done + '/' + mod.count + ' concluidas</small></span>' +
        '<small>' + mod.count + '</small></button>';
    }).join("");
    els.moduleNav.querySelectorAll("button").forEach((button) => {
      button.addEventListener("click", () => {
        state.module = button.dataset.module;
        render();
      });
    });
    els.moduleFilter.innerHTML = '<option value="all">Todos os modulos</option>' + data.modules
      .map((mod) => '<option value="' + mod.id + '" ' + (state.module === mod.id ? "selected" : "") + '>' + mod.label + '</option>')
      .join("");
  }
  function renderStats() {
    const minutes = data.lessons.reduce((sum, lesson) => sum + lesson.readingTime, 0);
    const done = state.completed.size;
    const percent = data.lessons.length ? Math.round((done / data.lessons.length) * 100) : 0;
    els.statsGrid.innerHTML = [
      ["Modulos", data.modules.length],
      ["Aulas", data.lessons.length],
      ["Leitura", minutes + " min"],
      ["Progresso", percent + "%"],
    ].map(([label, value]) => '<div class="stat-card"><strong>' + value + '</strong><span>' + label + '</span></div>').join("");
    els.doneCount.textContent = done;
    els.totalCount.textContent = data.lessons.length;
    els.progressBar.style.width = percent + "%";
  }
  function renderLessonList() {
    const lessons = filteredLessons();
    if (!lessons.length) {
      els.lessonList.innerHTML = '<div class="empty-state">Nada encontrado. Tente buscar por outro servico ou modulo.</div>';
      return;
    }
    els.lessonList.innerHTML = lessons.map((lesson) => {
      const mod = data.modules.find((item) => item.id === lesson.module);
      const done = state.completed.has(lesson.slug);
      return '<button class="lesson-item ' + (lesson.slug === state.activeSlug ? "active" : "") + ' ' + (done ? "done" : "") + '" style="--accent:' + (mod?.accent || "#ff9900") + '" data-slug="' + lesson.slug + '">' +
        '<strong>' + lesson.title + '</strong><small>' + lesson.moduleLabel + ' - ' + lesson.kind + ' - ' + lesson.readingTime + ' min - ' + (done ? "concluida" : "pendente") + '</small></button>';
    }).join("");
    els.lessonList.querySelectorAll("button").forEach((button) => button.addEventListener("click", () => selectLesson(button.dataset.slug)));
  }
  function renderLesson() {
    const lesson = activeLesson();
    if (!lesson) {
      els.lessonView.innerHTML = '<div class="empty-state">Nenhuma aula encontrada nesta pasta ainda.</div>';
      return;
    }
    const done = state.completed.has(lesson.slug);
    const mod = data.modules.find((item) => item.id === lesson.module);
    const visual = mod?.visual || data.modules[0]?.visual;
    els.lessonView.style.borderTop = "6px solid " + (mod?.accent || "#ff9900");
    els.lessonView.classList.remove("fade-out", "fade-in");
    els.lessonView.innerHTML = '<div class="lesson-toolbar"><div><div class="lesson-kicker">' + lesson.moduleLabel + ' - ' + lesson.kind + ' - ' + lesson.readingTime + ' min</div></div>' +
      '<div><button class="complete-btn" id="completeButton">' + (done ? "Marcar pendente" : "Marcar concluida") + '</button> <a class="open-page" href="./pages/' + lesson.slug + '.html">Abrir pagina HTML</a></div></div>' +
      '<figure class="lesson-visual"><img src="' + visual.image + '" alt="Imagem de apoio para ' + lesson.moduleLabel + '" loading="lazy"><figcaption>' + visual.caption + '</figcaption></figure>' +
      lesson.html;
    void els.lessonView.offsetWidth;
    els.lessonView.classList.add("fade-in");
    document.getElementById("completeButton").addEventListener("click", () => {
      if (state.completed.has(lesson.slug)) state.completed.delete(lesson.slug);
      else state.completed.add(lesson.slug);
      saveCompleted();
      render();
    });
    window.enhanceQuizzes?.(els.lessonView);
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
    state.module = "all";
    selectLesson(data.lessons[0]?.slug);
  });
  els.randomButton.addEventListener("click", () => {
    const pool = filteredLessons();
    const lesson = pool[Math.floor(Math.random() * pool.length)] || data.lessons[0];
    if (!lesson) return;
    selectLesson(lesson.slug);
  });
  window.addEventListener("hashchange", () => {
    const slug = location.hash.replace("#", "");
    if (data.lessons.some((lesson) => lesson.slug === slug)) selectLesson(slug, false);
  });
  render();
})();`;
}

function quizJs() {
  return `(function quizEnhancer() {
  function cleanText(text) {
    return (text || "").replace(/\\s+/g, " ").trim();
  }
  function escapeHtml(text) {
    const element = document.createElement("span");
    element.textContent = text || "";
    return element.innerHTML;
  }
  function optionLetter(text) {
    const match = cleanText(text).match(/^([A-E])\\)\\s*(.+)$/i);
    return match ? { letter: match[1].toUpperCase(), label: match[2] } : null;
  }
  function parseAnswer(details) {
    const text = cleanText(details.textContent);
    const match = text.match(/(?:Resposta correta|Resposta)\\s*:?\\s*([A-E])/i) || text.match(/^([A-E])\\s*[â€”-]/);
    return match ? match[1].toUpperCase() : "";
  }
  function buildQuiz(question, options, answer, feedbackHtml) {
    const card = document.createElement("section");
    card.className = "quiz-card";
    card.innerHTML = '<div class="quiz-header"><span>Treino da prova</span><strong>' + escapeHtml(question) + '</strong></div><div class="quiz-options"></div><div class="quiz-feedback" hidden></div>';
    const wrap = card.querySelector(".quiz-options");
    const feedback = card.querySelector(".quiz-feedback");
    options.forEach((option) => {
      const button = document.createElement("button");
      button.type = "button";
      button.className = "quiz-option";
      button.dataset.correct = String(option.letter === answer);
      button.innerHTML = '<span>' + escapeHtml(option.letter) + '</span><strong>' + escapeHtml(option.label) + '</strong>';
      button.addEventListener("click", () => {
        const buttons = Array.from(wrap.querySelectorAll(".quiz-option"));
        buttons.forEach((item) => {
          item.disabled = true;
          if (item.dataset.correct === "true") item.classList.add("is-correct");
        });
        button.classList.add(option.letter === answer ? "is-correct" : "is-wrong");
        feedback.hidden = false;
        feedback.innerHTML = '<strong>' + (option.letter === answer ? "Correto!" : "Ainda nao. A resposta certa e " + escapeHtml(answer) + ".") + '</strong>' + feedbackHtml;
      });
      wrap.appendChild(button);
    });
    return card;
  }
  function enhanceDetailsQuizzes(root) {
    Array.from(root.querySelectorAll("details")).forEach((details) => {
      if (details.dataset.quizUsed) return;
      const answer = parseAnswer(details);
      if (!answer) return;
      const options = [];
      let cursor = details.previousElementSibling;
      while (cursor && cursor.tagName === "UL") {
        const found = Array.from(cursor.querySelectorAll(":scope > li")).map((li) => optionLetter(li.textContent)).filter(Boolean);
        if (found.length >= 2) {
          options.unshift(...found);
          break;
        }
        cursor = cursor.previousElementSibling;
      }
      if (options.length < 2) return;
      let questionNode = cursor.previousElementSibling;
      while (questionNode && !["P", "H2", "H3", "H4", "LI"].includes(questionNode.tagName)) questionNode = questionNode.previousElementSibling;
      if (!questionNode) return;
      const question = cleanText(questionNode.textContent).replace(/^Quest[aÃ£]o\\s+\\d+\\s*/i, "");
      const feedback = Array.from(details.childNodes).filter((node) => node.tagName !== "SUMMARY").map((node) => node.outerHTML || "<p>" + escapeHtml(node.textContent) + "</p>").join("");
      const card = buildQuiz(question, options, answer, feedback || "<p>Revise o conceito e compare com a alternativa correta.</p>");
      details.dataset.quizUsed = "true";
      questionNode.replaceWith(card);
      cursor.remove();
      details.remove();
    });
  }
  function enhanceInlineCorrect(root) {
    Array.from(root.querySelectorAll("ul")).forEach((list) => {
      if (list.dataset.quizUsed || !/\\(correta\\)/i.test(list.textContent)) return;
      const options = Array.from(list.querySelectorAll(":scope > li")).map((li) => {
        const parsed = optionLetter(li.textContent.replace(/\\(correta\\)/ig, ""));
        return parsed ? { ...parsed, correct: /\\(correta\\)/i.test(li.textContent) } : null;
      }).filter(Boolean);
      if (options.length < 2 || !options.some((option) => option.correct)) return;
      let questionNode = list.previousElementSibling;
      while (questionNode && !["P", "H2", "H3", "H4", "LI"].includes(questionNode.tagName)) questionNode = questionNode.previousElementSibling;
      if (!questionNode) return;
      const answer = options.find((option) => option.correct).letter;
      const card = buildQuiz(cleanText(questionNode.textContent), options, answer, "<p>Compare sua escolha com a explicacao da aula.</p>");
      questionNode.replaceWith(card);
      list.remove();
    });
  }
  function enhanceQuizzes(root = document) {
    enhanceDetailsQuizzes(root);
    enhanceInlineCorrect(root);
  }
  window.enhanceQuizzes = enhanceQuizzes;
  document.addEventListener("DOMContentLoaded", () => enhanceQuizzes(document));
})();`;
}

function stylesCss() {
  const referenceCss = path.resolve(root, "..", "AWS CLF02", "site", "assets", "styles.css");
  const extras = `

/* Extensoes pequenas dos cursos Kubernetes sobre o tema oficial AWS CLF02. */
.lesson-card img { max-width: 100%; border-radius: 8px; }
.centered-html { text-align: center; }
.official-note {
  margin: 0 0 22px;
  padding: 18px;
  border: 1px solid #ffd28a;
  border-left: 6px solid var(--orange);
  border-radius: 8px;
  background: #fff8ed;
}
.official-note strong {
  display: block;
  color: #111827;
  margin-bottom: 8px;
}
.official-note p { margin: 8px 0 0; }
.lesson-kicker { overflow-wrap: anywhere; }
a { overflow-wrap: anywhere; }
`;
  if (fs.existsSync(referenceCss)) {
    return `${fs.readFileSync(referenceCss, "utf8").trimEnd()}${extras}`;
  }
  return `:root {
  --bg: #f5f7fb;
  --surface: #ffffff;
  --ink: #17202a;
  --muted: #657386;
  --line: #dfe6ef;
  --orange: #ff9900;
  --teal: #00a1c9;
  --green: #3f8624;
  --red: #d13212;
  --shadow: 0 18px 45px rgba(23, 32, 42, 0.12);
  font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}
* { box-sizing: border-box; }
html { scroll-behavior: smooth; }
body {
  margin: 0;
  color: var(--ink);
  background: linear-gradient(135deg, rgba(255, 153, 0, 0.12), transparent 34%), linear-gradient(315deg, rgba(0, 161, 201, 0.12), transparent 32%), var(--bg);
  animation: pageFadeIn .55s ease both;
}
a { color: #0073bb; overflow-wrap: anywhere; }
button, input, select { font: inherit; }
button { cursor: pointer; }
@keyframes pageFadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
@keyframes fadeInUp { from { opacity: 0; transform: translateY(18px); } to { opacity: 1; transform: translateY(0); } }
@keyframes fadeOutDown { from { opacity: 1; transform: translateY(0); } to { opacity: 0; transform: translateY(12px); } }
@keyframes softPulse { 0%,100% { transform: translateY(0) scale(1); } 50% { transform: translateY(-4px) scale(1.02); } }
@keyframes lineFlow { to { stroke-dashoffset: -220; } }
.app-shell { min-height: 100vh; display: grid; grid-template-columns: 300px minmax(0, 1fr); }
.sidebar { position: sticky; top: 0; height: 100vh; padding: 22px; overflow: auto; color: #f7fafc; background: linear-gradient(180deg, #161e2d 0%, #0f1724 100%); border-right: 1px solid rgba(255,255,255,.08); }
.brand { display: flex; gap: 12px; align-items: center; color: inherit; text-decoration: none; }
.brand-mark,.aws-token { display: grid; place-items: center; min-width: 48px; height: 48px; border-radius: 8px; color: #111827; background: linear-gradient(135deg,#ffb000,#ff7a00); font-weight: 900; letter-spacing: 0; }
.brand small,.progress-panel small { display: block; color: #aab7c4; }
.progress-panel { margin: 24px 0; padding: 16px; border: 1px solid rgba(255,255,255,.1); border-radius: 8px; background: rgba(255,255,255,.06); }
.progress-panel span:first-child { font-size: 28px; font-weight: 800; }
.progress-track { height: 9px; margin-top: 14px; overflow: hidden; border-radius: 999px; background: rgba(255,255,255,.14); }
.progress-track span { display: block; width: 0; height: 100%; background: linear-gradient(90deg,var(--orange),var(--teal)); transition: width .25s ease; }
.module-nav { display: grid; gap: 7px; }
.module-link { display: grid; grid-template-columns: 40px 1fr auto; gap: 10px; align-items: center; width: 100%; padding: 10px; color: #e7edf4; text-align: left; border: 1px solid transparent; border-radius: 8px; background: transparent; }
.module-link:hover,.module-link.active { border-color: rgba(255,255,255,.14); background: rgba(255,255,255,.08); }
.module-icon { display: grid; place-items: center; width: 40px; height: 40px; border-radius: 8px; font-size: 12px; font-weight: 900; color: #fff; }
.module-link small { color: #9fb0c2; }
.main-area { min-width: 0; padding: 28px; }
.hero-section { display: grid; grid-template-columns: minmax(0,1fr) 520px; gap: 28px; min-height: 440px; padding: 36px; border-radius: 8px; overflow: hidden; color: #fff; background: linear-gradient(135deg,rgba(16,24,39,.98),rgba(21,33,54,.94)), url("https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=1600&q=80") center/cover; box-shadow: var(--shadow); animation: fadeInUp .7s ease both; }
.hero-copy { align-self: center; max-width: 760px; }
.eyebrow { display: inline-flex; padding: 7px 10px; border: 1px solid rgba(255,255,255,.2); border-radius: 999px; color: #ffd28a; background: rgba(0,0,0,.18); }
h1 { margin: 18px 0 14px; font-size: clamp(38px,6vw,72px); line-height: .96; letter-spacing: 0; }
.hero-copy p { max-width: 700px; color: #d8e2ef; font-size: 18px; line-height: 1.7; }
.hero-actions { display: flex; flex-wrap: wrap; gap: 12px; margin-top: 24px; }
.primary-btn,.secondary-btn,.ghost-btn { min-height: 42px; padding: 0 16px; border-radius: 8px; border: 1px solid transparent; }
.primary-btn { color: #111827; background: var(--orange); font-weight: 800; }
.secondary-btn { color: #fff; background: rgba(255,255,255,.12); border-color: rgba(255,255,255,.22); }
.ghost-btn { color: var(--ink); background: #fff; border-color: var(--line); }
.architecture-visual { position: relative; min-height: 320px; align-self: center; }
.architecture-visual svg { position: absolute; inset: 0; width: 100%; height: 100%; }
.architecture-visual path { fill: none; stroke: rgba(255,255,255,.42); stroke-width: 3; stroke-linecap: round; stroke-dasharray: 12 18; animation: lineFlow 9s linear infinite; }
.cloud-node { position: absolute; z-index: 1; display: grid; place-items: center; width: 88px; height: 88px; border: 1px solid rgba(255,255,255,.32); border-radius: 18px; color: #fff; font-weight: 900; background: rgba(255,255,255,.12); box-shadow: 0 16px 42px rgba(0,0,0,.22); backdrop-filter: blur(8px); animation: softPulse 5s ease-in-out infinite; }
.cloud-node.core { left: calc(50% - 54px); top: calc(50% - 54px); width: 108px; height: 108px; color: #111827; background: linear-gradient(135deg,#ffb000,#ff7a00); }
.node-a { left: 44px; top: 44px; } .node-b { left: 48px; bottom: 42px; } .node-c { left: calc(50% - 44px); top: 0; } .node-d { right: 44px; top: 44px; } .node-e { right: 40px; bottom: 42px; }
.toolbar { position: sticky; top: 0; z-index: 5; display: grid; grid-template-columns: minmax(260px,1fr) 240px auto; gap: 12px; align-items: end; margin: 22px 0; padding: 14px; border: 1px solid var(--line); border-radius: 8px; background: rgba(255,255,255,.92); backdrop-filter: blur(12px); }
.search-box span { display: block; margin-bottom: 6px; color: var(--muted); font-size: 13px; }
.search-box input,select { width: 100%; min-height: 42px; border: 1px solid var(--line); border-radius: 8px; padding: 0 12px; background: #fff; }
.stats-grid { display: grid; grid-template-columns: repeat(4,minmax(0,1fr)); gap: 14px; margin-bottom: 22px; }
.stat-card { padding: 18px; border-radius: 8px; border: 1px solid var(--line); background: var(--surface); animation: fadeInUp .45s ease both; }
.stat-card strong { display: block; font-size: 28px; }
.stat-card span { color: var(--muted); }
.content-layout { display: grid; grid-template-columns: 380px minmax(0,1fr); gap: 20px; align-items: start; }
.lesson-list { display: grid; gap: 10px; max-height: calc(100vh - 130px); overflow: auto; padding-right: 4px; }
.lesson-item { width: 100%; padding: 14px; text-align: left; border: 1px solid var(--line); border-left: 5px solid var(--accent,var(--orange)); border-radius: 8px; background: #fff; transition: transform .18s ease,box-shadow .18s ease,background-color .18s ease,border-color .18s ease,opacity .18s ease; animation: fadeInUp .28s ease both; }
.lesson-item:hover,.lesson-item.active { box-shadow: 0 10px 24px rgba(23,32,42,.08); transform: translateY(-1px); }
.lesson-item strong { display: block; margin-bottom: 6px; line-height: 1.35; }
.lesson-item small { color: var(--muted); }
.lesson-item.done { background: #f5fbf4; }
.lesson-card { min-width: 0; padding: 32px; border: 1px solid var(--line); border-radius: 8px; background: var(--surface); box-shadow: var(--shadow); transition: opacity .16s ease,transform .16s ease; }
.lesson-card.fade-in { animation: fadeInUp .34s ease both; } .lesson-card.fade-out { animation: fadeOutDown .14s ease both; }
.lesson-card.full { max-width: 980px; margin: 0 auto; }
.lesson-toolbar { display: flex; flex-wrap: wrap; gap: 10px; align-items: center; justify-content: space-between; margin-bottom: 22px; padding-bottom: 16px; border-bottom: 1px solid var(--line); }
.lesson-visual { position: relative; margin: 0 0 28px; overflow: hidden; border-radius: 8px; border: 1px solid var(--line); background: #101827; animation: fadeInUp .42s ease both; }
.lesson-visual img { display: block; width: 100%; height: clamp(180px,28vw,320px); object-fit: cover; opacity: .9; transform: scale(1.01); transition: transform .7s ease,opacity .35s ease; }
.lesson-visual:hover img { opacity: 1; transform: scale(1.05); }
.lesson-visual::after { content: ""; position: absolute; inset: 0; background: linear-gradient(180deg,transparent 40%,rgba(16,24,39,.9)); pointer-events: none; }
.lesson-visual figcaption { position: absolute; left: 18px; right: 18px; bottom: 16px; z-index: 1; color: #fff; font-weight: 750; line-height: 1.45; text-shadow: 0 2px 18px rgba(0,0,0,.45); }
.lesson-kicker { color: var(--muted); font-size: 13px; font-weight: 800; text-transform: uppercase; letter-spacing: .08em; overflow-wrap: anywhere; }
.complete-btn { min-height: 38px; padding: 0 12px; border-radius: 8px; border: 1px solid #b6dfb0; color: #1f6b2a; background: #f2fbef; }
.open-page,.back-link,.page-nav a { min-height: 38px; padding: 9px 12px; border-radius: 8px; color: #075985; background: #eef8ff; text-decoration: none; display: inline-flex; align-items: center; }
.lesson-card h1 { color: var(--ink); font-size: clamp(34px,4vw,54px); line-height: 1.04; }
.lesson-card h2 { margin-top: 34px; padding-top: 10px; border-top: 1px solid var(--line); font-size: 27px; }
.lesson-card h3 { font-size: 21px; }
.lesson-card p,.lesson-card li { color: #2f3b4a; line-height: 1.78; }
.lesson-card li + li { margin-top: 8px; }
.lesson-card code { padding: 2px 6px; border-radius: 6px; color: #a92c00; background: #fff3e0; }
.lesson-card pre { overflow: auto; padding: 18px; border-radius: 8px; color: #e8eef8; background: #101827; }
.lesson-card pre code { padding: 0; color: inherit; background: transparent; }
.lesson-card blockquote { margin: 20px 0; padding: 18px; border-left: 5px solid var(--orange); border-radius: 8px; background: #fff8ed; }
.lesson-card img { max-width: 100%; border-radius: 8px; }
.official-note { margin: 0 0 22px; padding: 18px; border: 1px solid #ffd28a; border-left: 6px solid var(--orange); border-radius: 8px; background: #fff8ed; }
.official-note strong { display: block; color: #111827; margin-bottom: 8px; }
.official-note p { margin: 8px 0 0; }
.centered-html { text-align: center; }
.quiz-card { margin: 22px 0; padding: 20px; border: 1px solid #cfe4f2; border-radius: 8px; background: linear-gradient(180deg,#f7fbff,#ffffff); box-shadow: 0 14px 30px rgba(23,32,42,.08); animation: fadeInUp .32s ease both; }
.quiz-header { display: grid; gap: 8px; margin-bottom: 14px; }
.quiz-header span { width: fit-content; padding: 5px 8px; border-radius: 999px; color: #075985; background: #e7f5ff; font-size: 12px; font-weight: 900; text-transform: uppercase; letter-spacing: .06em; }
.quiz-header strong { color: #111827; font-size: 20px; line-height: 1.35; }
.quiz-options { display: grid; gap: 10px; }
.quiz-option { display: grid; grid-template-columns: 40px minmax(0,1fr); gap: 12px; align-items: center; width: 100%; min-height: 54px; padding: 10px; border: 1px solid var(--line); border-radius: 8px; color: #1f2937; text-align: left; background: #fff; transition: transform .16s ease,border-color .16s ease,background-color .16s ease,box-shadow .16s ease; }
.quiz-option:hover:not(:disabled) { transform: translateY(-1px); border-color: #7cc5e5; box-shadow: 0 10px 20px rgba(0,115,187,.1); }
.quiz-option span { display: grid; place-items: center; width: 36px; height: 36px; border-radius: 8px; color: #075985; background: #e7f5ff; font-weight: 900; }
.quiz-option strong { color: inherit; font-size: 15px; line-height: 1.4; }
.quiz-option.is-correct { border-color: #83c879; background: #f1fbef; }
.quiz-option.is-correct span { color: #fff; background: var(--green); }
.quiz-option.is-wrong { border-color: #efa48e; background: #fff3ef; }
.quiz-option.is-wrong span { color: #fff; background: var(--red); }
.quiz-option:disabled { cursor: default; }
.quiz-feedback { margin-top: 14px; padding: 14px; border-left: 5px solid var(--orange); border-radius: 8px; background: #fff8ed; animation: fadeInUp .22s ease both; }
.quiz-feedback > strong { display: block; margin-bottom: 8px; color: #111827; }
.table-wrap { overflow-x: auto; margin: 18px 0; border: 1px solid var(--line); border-radius: 8px; }
table { width: 100%; border-collapse: collapse; background: #fff; }
th,td { padding: 12px; border-bottom: 1px solid var(--line); text-align: left; vertical-align: top; }
th { color: #111827; background: #f3f6fb; }
tr:last-child td { border-bottom: 0; }
.page-shell { padding: 28px; }
.back-link { margin-bottom: 16px; background: #fff; }
.page-nav { display: flex; justify-content: space-between; gap: 16px; margin-top: 32px; padding-top: 20px; border-top: 1px solid var(--line); }
.standalone-page .lesson-card.full { animation: fadeInUp .5s ease both; }
.empty-state { padding: 30px; border: 1px dashed var(--line); border-radius: 8px; color: var(--muted); background: #fff; }
@media (max-width: 1160px) { .app-shell { grid-template-columns: 1fr; } .sidebar { position: relative; height: auto; } .hero-section,.content-layout { grid-template-columns: 1fr; } .architecture-visual { min-height: 300px; } .lesson-list { max-height: none; } }
@media (max-width: 760px) { .main-area,.page-shell { padding: 14px; } .hero-section { padding: 24px; } .toolbar,.stats-grid { grid-template-columns: 1fr; } .lesson-card { padding: 20px; } .architecture-visual { display: none; } .lesson-visual img { height: 190px; } }
@media (prefers-reduced-motion: reduce) { *,*::before,*::after { animation-duration: .001ms !important; animation-iteration-count: 1 !important; scroll-behavior: auto !important; transition-duration: .001ms !important; } }`;
}

function readme(lessonCount, moduleCount) {
  return `# Site de estudo - ${COURSE.title}

Abra \`site/index.html\` diretamente no navegador. O site e estatico e nao precisa de servidor.

## Regenerar

\`\`\`bash
node "${path.basename(root)}/tools/build-study-site.js"
\`\`\`

## Conteudo gerado

- ${moduleCount} modulos no menu.
- ${lessonCount} paginas HTML individuais em \`site/pages/\`.
- Busca, filtro por modulo, revisao aleatoria e progresso salvo em \`localStorage\`.
- Quizzes interativos: respostas e explicacoes ficam escondidas ate o aluno escolher uma alternativa.

## Focos do curso

${COURSE.focus.map((item) => `- ${item}`).join("\n")}

## Imagens

As imagens remotas usadas no hero e nas paginas sao do Unsplash via URLs publicas com parametros de renderizacao. Elas sao apenas apoio visual de memorizacao; o conteudo didatico continua nos arquivos do curso.
`;
}

function main() {
  const files = walk(root).sort((a, b) => a.localeCompare(b, "pt-BR", { numeric: true }));
  const lessons = files.map(buildLesson);
  lessons.forEach((lesson) => {
    lesson.html = rewriteInternalLinks(lesson.sourceHtml, lesson.relative, lessons, "index");
    lesson.pageHtml = rewriteInternalLinks(lesson.sourceHtml, lesson.relative, lessons, "standalone");
  });
  const data = buildData(lessons);

  removeDir(siteDir);
  ensureDir(assetsDir);
  ensureDir(pagesDir);

  fs.writeFileSync(path.join(siteDir, "index.html"), indexHtml(), "utf8");
  fs.writeFileSync(path.join(assetsDir, "styles.css"), stylesCss(), "utf8");
  fs.writeFileSync(path.join(assetsDir, "app.js"), appJs(), "utf8");
  fs.writeFileSync(path.join(assetsDir, "quiz.js"), quizJs(), "utf8");
  const clientData = {
    modules: data.modules,
    lessons: lessons.map(({ pageHtml, sourceHtml, ...lesson }) => lesson),
  };
  fs.writeFileSync(path.join(assetsDir, "data.js"), `window.STUDY_DATA = ${JSON.stringify(clientData, null, 2)};\n`, "utf8");
  fs.writeFileSync(path.join(siteDir, "README.md"), readme(lessons.length, data.modules.length), "utf8");

  lessons.forEach((lesson, index) => {
    fs.writeFileSync(
      path.join(pagesDir, `${lesson.slug}.html`),
      renderStandaloneLesson(lesson, lessons[index - 1], lessons[index + 1], data.modules),
      "utf8",
    );
  });

  console.log(`Arquivos didaticos encontrados: ${files.length}`);
  console.log(`Paginas HTML geradas: ${lessons.length}`);
  console.log(`Modulos: ${data.modules.length}`);
  console.log(`Site: ${path.join(siteDir, "index.html")}`);
}

main();

