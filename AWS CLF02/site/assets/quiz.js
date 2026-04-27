(function quizEnhancer() {
  function hasOptions(text) {
    return /A\)\s+/.test(text) && /B\)\s+/.test(text) && /\(correta\)/i.test(text);
  }

  function isHeading(node) {
    return /^H[1-3]$/.test(node?.tagName || "");
  }

  function cleanText(text) {
    return (text || "").replace(/\s+/g, " ").trim();
  }

  function escapeHtml(text) {
    const element = document.createElement("span");
    element.textContent = text;
    return element.innerHTML;
  }

  function parseOptions(text) {
    const options = [];
    const optionRegex = /([A-D])\)\s*([\s\S]*?)(?=\s+[A-D]\)\s*|$)/g;
    let match;

    while ((match = optionRegex.exec(text)) !== null) {
      const rawLabel = cleanText(match[2]);
      const correct = /\(correta\)/i.test(rawLabel);
      const label = cleanText(rawLabel.replace(/\(correta\)/ig, ""));

      if (label) {
        options.push({ letter: match[1], label, correct });
      }
    }

    return options;
  }

  function createFeedbackHtml(nodes) {
    if (!nodes.length) {
      return "<p>Revise a alternativa correta e compare com o conceito da aula.</p>";
    }

    return nodes.map((node) => node.outerHTML || `<p>${cleanText(node.textContent)}</p>`).join("");
  }

  function buildQuizCard(question, options, feedbackHtml) {
    const card = document.createElement("section");
    card.className = "quiz-card";
    card.innerHTML = `
      <div class="quiz-header">
        <span>Treino da prova</span>
        <strong>${escapeHtml(question)}</strong>
      </div>
      <div class="quiz-options"></div>
      <div class="quiz-feedback" hidden></div>
    `;

    const optionsWrap = card.querySelector(".quiz-options");
    const feedback = card.querySelector(".quiz-feedback");
    const correctOption = options.find((option) => option.correct);

    options.forEach((option) => {
      const button = document.createElement("button");
      button.type = "button";
      button.className = "quiz-option";
      button.dataset.correct = String(option.correct);
      button.innerHTML = `<span>${option.letter}</span><strong>${escapeHtml(option.label)}</strong>`;
      button.addEventListener("click", () => {
        const feedbackTitle = option.correct
          ? "Correto!"
          : `Ainda nao. A resposta certa e ${correctOption?.letter || ""}.`;
        const buttons = Array.from(optionsWrap.querySelectorAll(".quiz-option"));
        buttons.forEach((item) => {
          item.disabled = true;
          if (item.dataset.correct === "true") item.classList.add("is-correct");
        });

        button.classList.add(option.correct ? "is-correct" : "is-wrong");
        feedback.hidden = false;
        feedback.innerHTML = `
          <strong>${escapeHtml(feedbackTitle)}</strong>
          ${feedbackHtml}
        `;
      });
      optionsWrap.appendChild(button);
    });

    return card;
  }

  function answerMapFromGabarito(root) {
    const headings = Array.from(root.querySelectorAll("h2"));
    const answerHeading = headings.find((heading) => /gabarito/i.test(heading.textContent));
    const answers = new Map();
    const nodesToRemove = [];

    if (!answerHeading) return { answers, nodesToRemove };

    nodesToRemove.push(answerHeading);
    let cursor = answerHeading.nextElementSibling;

    while (cursor && !isHeading(cursor) && cursor.tagName !== "NAV" && cursor.tagName !== "SCRIPT") {
      nodesToRemove.push(cursor);

      if (cursor.tagName === "OL") {
        Array.from(cursor.querySelectorAll("li")).forEach((item, index) => {
          const text = cleanText(item.textContent);
          const match = text.match(/^([A-D])\s*[-:]\s*(.+)$/i);

          if (match) {
            answers.set(index + 1, {
              letter: match[1].toUpperCase(),
              explanation: match[2],
            });
          }
        });
      }

      cursor = cursor.nextElementSibling;
    }

    return { answers, nodesToRemove };
  }

  function enhanceGabaritoQuizzes(root = document) {
    const { answers, nodesToRemove } = answerMapFromGabarito(root);
    if (!answers.size) return;

    Array.from(root.querySelectorAll("h3")).forEach((heading) => {
      if (heading.dataset.quizEnhanced) return;

      const numberMatch = cleanText(heading.textContent).match(/^(\d+)\.\s*(.+)$/);
      const optionNode = heading.nextElementSibling;
      if (!numberMatch || !optionNode || optionNode.tagName !== "P") return;

      const answer = answers.get(Number(numberMatch[1]));
      if (!answer || !hasOptions(`${optionNode.textContent} (correta)`)) return;

      const options = parseOptions(optionNode.textContent).map((option) => ({
        ...option,
        correct: option.letter.toUpperCase() === answer.letter,
      }));
      if (options.length < 2 || !options.some((option) => option.correct)) return;

      const feedbackHtml = `<p>${escapeHtml(answer.explanation)}</p>`;
      const card = buildQuizCard(cleanText(numberMatch[2]), options, feedbackHtml);
      heading.dataset.quizEnhanced = "true";
      heading.replaceWith(card);
      optionNode.remove();
    });

    nodesToRemove.forEach((node) => node.remove());
  }

  function enhanceQuizzes(root = document) {
    const orderedLists = Array.from(root.querySelectorAll("ol")).filter((list) => {
      return !list.dataset.quizEnhanced && hasOptions(list.textContent + " " + (list.nextElementSibling?.textContent || ""));
    });

    orderedLists.forEach((list) => {
      const firstItem = list.querySelector("li");
      if (!firstItem) return;

      let question = cleanText(firstItem.textContent);
      let optionText = cleanText(list.textContent.replace(firstItem.textContent, ""));
      const inlineOptionStart = question.search(/\sA\)\s+/);

      if (inlineOptionStart >= 0) {
        optionText = `${question.slice(inlineOptionStart)} ${optionText}`;
        question = cleanText(question.slice(0, inlineOptionStart));
      }
      const nodesToRemove = [];
      let cursor = list.nextElementSibling;

      if (cursor && hasOptions(cursor.textContent)) {
        optionText += ` ${cleanText(cursor.textContent)}`;
        nodesToRemove.push(cursor);
        cursor = cursor.nextElementSibling;
      }

      const options = parseOptions(optionText);
      if (options.length < 2 || !options.some((option) => option.correct)) return;

      const feedbackNodes = [];
      while (cursor && !isHeading(cursor) && cursor.tagName !== "OL") {
        feedbackNodes.push(cursor.cloneNode(true));
        nodesToRemove.push(cursor);
        cursor = cursor.nextElementSibling;
      }

      const card = buildQuizCard(question, options, createFeedbackHtml(feedbackNodes));
      list.dataset.quizEnhanced = "true";
      list.replaceWith(card);
      nodesToRemove.forEach((node) => node.remove());
    });

    enhanceGabaritoQuizzes(root);
  }

  window.enhanceQuizzes = enhanceQuizzes;

  document.addEventListener("DOMContentLoaded", () => {
    enhanceQuizzes(document);
  });
})();
