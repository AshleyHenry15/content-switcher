// content-switcher.js
document.addEventListener("DOMContentLoaded", function() {
  const selector = document.getElementById("content-switcher-select");
  if (!selector) return;

  function switchVersion(version) {
    const blocks = document.querySelectorAll(".content-switcher");

    blocks.forEach(block => {
      if (block.dataset.version === version) {
        block.classList.remove("content-switcher-hidden");
      } else {
        block.classList.add("content-switcher-hidden");
      }
    });

    localStorage.setItem("content-switcher-selected-version", version);

    // Dispatch custom event for extensibility
    window.dispatchEvent(new CustomEvent('content-switcher:changed', {
      detail: { version }
    }));
  }

  selector.addEventListener("change", function(e) {
    switchVersion(e.target.value);
  });

  // Check for URL parameter first, then localStorage
  const urlParams = new URLSearchParams(window.location.search);
  const urlVersion = urlParams.get('version');
  const savedVersion = localStorage.getItem("content-switcher-selected-version");
  const validOptions = Array.from(selector.options).map(opt => opt.value);

  if (urlVersion && validOptions.includes(urlVersion)) {
    selector.value = urlVersion;
    switchVersion(urlVersion);
  } else if (savedVersion && validOptions.includes(savedVersion)) {
    selector.value = savedVersion;
    switchVersion(savedVersion);
  }
});