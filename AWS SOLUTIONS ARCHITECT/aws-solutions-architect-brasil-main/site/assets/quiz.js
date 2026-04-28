(function quizEnhancer() {
  function cleanText(text) {
    return (text || "").replace(/\s+/g, " ").trim();
  }
  function escapeHtml(text) {
    const element = document.createElement("span");
    element.textContent = text || "";
    return element.innerHTML;
  }
  function optionLetter(text) {
    const match = cleanText(text).match(/^([A-E])\)\s*(.+)$/i);
    return match ? { letter: match[1].toUpperCase(), label: match[2] } : null;
  }
  function parseAnswer(details) {
    const text = cleanText(details.textContent);
    const match = text.match(/(?:Resposta correta|Resposta)\s*:?\s*([A-E])/i) || text.match(/^([A-E])\s*[—-]/);
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
      const question = cleanText(questionNode.textContent).replace(/^Quest[aã]o\s+\d+\s*/i, "");
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
      if (list.dataset.quizUsed || !/\(correta\)/i.test(list.textContent)) return;
      const options = Array.from(list.querySelectorAll(":scope > li")).map((li) => {
        const parsed = optionLetter(li.textContent.replace(/\(correta\)/ig, ""));
        return parsed ? { ...parsed, correct: /\(correta\)/i.test(li.textContent) } : null;
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
})();