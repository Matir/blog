"use strict";

(function() {
  const addCopyButtons = function() {
    if (!navigator.clipboard) {
      return;
    }
    const copyIcon = '<i class="fa-regular fa-copy"></i>';
    const copiedIcon = '<i class="fa-solid fa-square-check"></i>';
    const codeBlocks = document.querySelectorAll("td.rouge-code");
    codeBlocks.forEach((block) => {
      const newButton = document.createElement("button");
      newButton.innerHTML = copyIcon;
      newButton.classList.add("copy-button");
      newButton.addEventListener("click", async function(e) {
        const target = e.currentTarget;
        const container = target.parentElement;
        const codePre = container.querySelector("pre");
        console.log(codePre.innerText);
        await navigator.clipboard.writeText(codePre.innerText);
        target.innerHTML = copiedIcon;
        setTimeout(() => {
          target.innerHTML = copyIcon;
        }, 2000);
      });
      block.appendChild(newButton);
    });
  };
  if (document.readyState !== "loading") {
    addCopyButtons();
  } else {
    document.addEventListener("DOMContentLoaded", addCopyButtons);
  }
}());
