// conditional-text.js
document.addEventListener("DOMContentLoaded", function() {
  const selector = document.getElementById("conditional-text-select");
  if (!selector) return;

  function switchVersion(version) {
    const blocks = document.querySelectorAll(".conditional-text");

    blocks.forEach(block => {
      if (block.dataset.version === version) {
        block.classList.remove("conditional-text-hidden");
        block.dataset.visible = "true";
      } else {
        block.classList.add("conditional-text-hidden");
        block.dataset.visible = "false";
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

  // Helper to check if version exists
  const versionExists = (version) =>
    Array.from(selector.options).some(option => option.value === version);

  if (urlVersion && versionExists(urlVersion)) {
    selector.value = urlVersion;
    switchVersion(urlVersion);
  } else if (savedVersion && versionExists(savedVersion)) {
    selector.value = savedVersion;
    switchVersion(savedVersion);
  }
});