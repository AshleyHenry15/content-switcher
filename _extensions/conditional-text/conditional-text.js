// conditional-text.js
document.addEventListener("DOMContentLoaded", function() {
  const selector = document.getElementById("conditional-text-select");
  if (!selector) return;

  function switchVersion(version) {
    const blocks = document.querySelectorAll(".conditional-text");

    blocks.forEach(block => {
      if (block.dataset.version === version) {
        block.classList.remove("conditional-text-hidden");
      } else {
        block.classList.add("conditional-text-hidden");
      }
    });

    localStorage.setItem("conditional-text-selected-version", version);
  }

  selector.addEventListener("change", function(e) {
    switchVersion(e.target.value);
  });

  // Check for URL parameter first, then localStorage
  const urlParams = new URLSearchParams(window.location.search);
  const urlVersion = urlParams.get('version');
  const savedVersion = localStorage.getItem("conditional-text-selected-version");
  const validOptions = Array.from(selector.options).map(opt => opt.value);

  if (urlVersion && validOptions.includes(urlVersion)) {
    selector.value = urlVersion;
    switchVersion(urlVersion);
  } else if (savedVersion && validOptions.includes(savedVersion)) {
    selector.value = savedVersion;
    switchVersion(savedVersion);
  }
});