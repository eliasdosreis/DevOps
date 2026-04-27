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

  const moduleVisuals = {
    "modulo-00-guia-da-prova": {
      image: "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?auto=format&fit=crop&w=1200&q=80",
      caption: "Mapa de estudo: primeiro entenda a prova, depois ataque as lacunas.",
    },
    "modulo-01-fundamentos-cloud": {
      image: "https://images.unsplash.com/photo-1451187580459-43490279c0fa?auto=format&fit=crop&w=1200&q=80",
      caption: "Nuvem e como uma cidade digital: servicos prontos, elasticos e sob demanda.",
    },
    "modulo-02-infraestrutura-global": {
      image: "https://images.unsplash.com/photo-1520869562399-e772f042f422?auto=format&fit=crop&w=1200&q=80",
      caption: "Regioes, zonas e edge locations aproximam sistemas das pessoas.",
    },
    "modulo-03-seguranca-responsabilidade": {
      image: "https://images.unsplash.com/photo-1563986768494-4dee2763ff3f?auto=format&fit=crop&w=1200&q=80",
      caption: "Responsabilidade compartilhada: a AWS protege a nuvem; voce protege o que coloca nela.",
    },
    "modulo-04-servicos-seguranca": {
      image: "https://images.unsplash.com/photo-1550751827-4bd374c3f58b?auto=format&fit=crop&w=1200&q=80",
      caption: "Seguranca e defesa em camadas: detectar, bloquear, auditar e criptografar.",
    },
    "modulo-05-computacao": {
      image: "https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=1200&q=80",
      caption: "Computacao e escolher onde o trabalho acontece: servidor, container ou funcao.",
    },
    "modulo-06-armazenamento": {
      image: "https://images.unsplash.com/photo-1558494949-ef010cbdcc31?auto=format&fit=crop&w=1200&q=80",
      caption: "Storage e guardar cada dado no lugar certo: objeto, bloco ou arquivo.",
    },
    "modulo-07-banco-de-dados": {
      image: "https://images.unsplash.com/photo-1544383835-bda2bc66a55d?auto=format&fit=crop&w=1200&q=80",
      caption: "Banco de dados e organizacao: tabelas, chaves, consultas e escala.",
    },
    "modulo-08-rede-entrega-conteudo": {
      image: "https://images.unsplash.com/photo-1520869562399-e772f042f422?auto=format&fit=crop&w=1200&q=80",
      caption: "Rede e caminho: DNS, VPC, CDN, conexoes privadas e baixa latencia.",
    },
    "modulo-09-integracao-mensageria": {
      image: "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1200&q=80",
      caption: "Mensageria evita que sistemas dependam um do outro o tempo todo.",
    },
    "modulo-10-monitoramento-governanca": {
      image: "https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=1200&q=80",
      caption: "Operar bem e enxergar: logs, metricas, auditoria, conformidade e paineis.",
    },
    "modulo-11-machine-learning": {
      image: "https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&w=1200&q=80",
      caption: "Machine learning na prova e reconhecer qual API inteligente resolve cada problema.",
    },
    "modulo-12-cobranca-e-suporte": {
      image: "https://images.unsplash.com/photo-1554224155-6726b3ff858f?auto=format&fit=crop&w=1200&q=80",
      caption: "Custos: calcular antes, alertar durante e analisar depois.",
    },
    "modulo-13-simulado-final": {
      image: "https://images.unsplash.com/photo-1434030216411-0b793f4b4173?auto=format&fit=crop&w=1200&q=80",
      caption: "Simulado e treino de decisao: leia o cenario, elimine pegadinhas e escolha o servico.",
    },
    "modulo-14-revisao-senior-crianca": {
      image: "https://images.unsplash.com/photo-1519389950473-47ba0277781c?auto=format&fit=crop&w=1200&q=80",
      caption: "Revisao boa e simples o bastante para memorizar e profunda o bastante para entrevista.",
    },
  };

  function saveCompleted() {
    localStorage.setItem("clfCompleted", JSON.stringify(Array.from(state.completed)));
  }

  function activeLesson() {
    return data.lessons.find((lesson) => lesson.slug === state.activeSlug) || data.lessons[0];
  }

  function selectLesson(slug, shouldScroll = true) {
    if (!slug || slug === state.activeSlug) return;
    els.lessonView.classList.add("fade-out");
    window.setTimeout(() => {
      state.activeSlug = slug;
      history.replaceState(null, "", `#${state.activeSlug}`);
      render();
      if (shouldScroll) {
        document.getElementById("lessonView").scrollIntoView({ behavior: "smooth", block: "start" });
      }
    }, 140);
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
      button.addEventListener("click", () => selectLesson(button.dataset.slug));
    });
  }

  function renderLesson() {
    const lesson = activeLesson();
    if (!lesson) return;
    const done = state.completed.has(lesson.slug);
    const mod = data.modules.find((item) => item.id === lesson.module);
    const visual = moduleVisuals[lesson.module] || moduleVisuals["modulo-01-fundamentos-cloud"];
    els.lessonView.style.borderTop = `6px solid ${mod?.accent || "#ff9900"}`;
    els.lessonView.classList.remove("fade-out", "fade-in");
    els.lessonView.innerHTML = `<div class="lesson-toolbar">
      <div>
        <div class="lesson-kicker">${lesson.moduleLabel} · ${lesson.readingTime} min · ${lesson.relative}</div>
      </div>
      <div>
        <button class="complete-btn" id="completeButton">${done ? "Marcar pendente" : "Marcar concluida"}</button>
        <a class="open-page" href="./pages/${lesson.slug}.html">Abrir pagina HTML</a>
      </div>
    </div>
    <figure class="lesson-visual">
      <img src="${visual.image}" alt="Imagem de apoio para ${lesson.moduleLabel}" loading="lazy">
      <figcaption>${visual.caption}</figcaption>
    </figure>
    ${lesson.html}`;
    void els.lessonView.offsetWidth;
    els.lessonView.classList.add("fade-in");

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
    state.module = "all";
    selectLesson(data.lessons[0]?.slug);
  });

  els.randomButton.addEventListener("click", () => {
    const pool = filteredLessons();
    const lesson = pool[Math.floor(Math.random() * pool.length)] || data.lessons[0];
    selectLesson(lesson.slug);
  });

  window.addEventListener("hashchange", () => {
    const slug = location.hash.replace("#", "");
    if (data.lessons.some((lesson) => lesson.slug === slug)) {
      selectLesson(slug, false);
    }
  });

  render();
})();
