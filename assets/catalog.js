const catalog = window.COURSE_CATALOG;
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
  els.featured.innerHTML = `
    <img src="${featured.image}" alt="${featured.title}">
    <div>
      <small>${featured.category} · ${featured.level}</small>
      <h2>${featured.title}</h2>
      <p>${featured.description}</p>
      <a href="${featured.href}">Abrir curso</a>
    </div>`;
}

function renderFilters() {
  els.category.innerHTML = '<option value="all">Todas</option>' + catalog.categories
    .map((category) => `<option value="${category}">${category}</option>`)
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
  ].map(([label, value]) => `<div class="stat"><strong>${value}</strong><span>${label}</span></div>`).join("");
}

function card(course, index) {
  return `<a class="course-card" href="${course.href}" style="animation-delay:${Math.min(index * 35, 280)}ms">
    <img src="${course.image}" alt="${course.title}" loading="lazy">
    <div class="course-body">
      <div class="course-meta">
        <span class="pill">${course.badge}</span>
        <span class="pill secondary">${course.level}</span>
      </div>
      <h3>${course.title}</h3>
      <p>${course.description}</p>
      <div class="course-stats">
        <span>${course.mdCount} md</span>
        <span>${course.htmlCount} html</span>
        <span>${course.fileCount} arquivos</span>
      </div>
    </div>
  </a>`;
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
    .map(([category, items]) => `<section class="row">
      <h2>${category}</h2>
      <div class="rail">${items.map(card).join("")}</div>
    </section>`)
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
