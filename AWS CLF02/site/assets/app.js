(function clientApp() {
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
})();
