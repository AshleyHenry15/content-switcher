// content-switcher.js
document.addEventListener("DOMContentLoaded", function() {
  const selector = document.getElementById("content-switcher-select");
  if (!selector) return;

  const validOptions = Array.from(selector.options).map(opt => opt.value);

  function switchVersion(version) {
    if (!version || !validOptions.includes(version)) {
      console.warn(`Content switcher: Invalid version "${version}"`);
      return;
    }

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

    // Keep backward compatibility with scroll hack
    window.dispatchEvent(new Event('scroll'));
  }

  selector.addEventListener("change", function(e) {
    switchVersion(e.target.value);
  });

  // Check for URL parameter first, then localStorage, then default
  const urlParams = new URLSearchParams(window.location.search);
  const urlVersion = urlParams.get('version');
  const savedVersion = localStorage.getItem("content-switcher-selected-version");

  let initialVersion = selector.value; // Use selector's default value

  if (urlVersion && validOptions.includes(urlVersion)) {
    initialVersion = urlVersion;
    selector.value = urlVersion;
  } else if (savedVersion && validOptions.includes(savedVersion)) {
    initialVersion = savedVersion;
    selector.value = savedVersion;
  }

  // Initialize: hide all non-active versions on page load
  switchVersion(initialVersion);
});