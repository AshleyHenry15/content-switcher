// conditional-text.js
document.addEventListener("DOMContentLoaded", function() {
  // Get the version selector
  const selector = document.getElementById("conditional-text-select");
  if (!selector) return;

  // Function to switch visible content
  function switchVersion(version) {
    // Get all conditional text blocks (both divs and spans)
    const blocks = document.querySelectorAll(".conditional-text");

    blocks.forEach(block => {
      if (block.dataset.version === version) {
        block.classList.remove("conditional-text-hidden");
        block.dataset.visible = "true";

        // If this is a code block, trigger a resize event for proper rendering
        if (block.querySelector('pre')) {
          window.dispatchEvent(new Event('resize'));
        }
      } else {
        block.classList.add("conditional-text-hidden");
        block.dataset.visible = "false";
      }
    });

    // Save selection to localStorage
    localStorage.setItem("conditional-text-selected-version", version);

    // Update all other selectors on the page to match
    const otherSelectors = document.querySelectorAll("#conditional-text-select");
    otherSelectors.forEach(otherSelector => {
      if (otherSelector !== selector) {
        otherSelector.value = version;
      }
    });
  }

  // Set up event listener for the selector
  selector.addEventListener("change", function(e) {
    switchVersion(e.target.value);
  });

  // Check for URL parameter first (highest priority)
  const urlParams = new URLSearchParams(window.location.search);
  const urlVersion = urlParams.get('version');

  // Check if there's a saved version in localStorage (second priority)
  const savedVersion = localStorage.getItem("conditional-text-selected-version");

  // Use URL param, then localStorage, then default
  if (urlVersion) {
    // Check if this version exists in the selector
    const versionExists = Array.from(selector.options).some(option => option.value === urlVersion);
    if (versionExists) {
      selector.value = urlVersion;
      switchVersion(urlVersion);
    }
  } else if (savedVersion) {
    // Check if this version exists in the selector
    const versionExists = Array.from(selector.options).some(option => option.value === savedVersion);
    if (versionExists) {
      selector.value = savedVersion;
      switchVersion(savedVersion);
    }
  }

  // Create a custom shortcut to toggle between versions
  document.addEventListener("keydown", function(e) {
    // Alt+V to focus the selector
    if (e.altKey && e.key === "v") {
      e.preventDefault();
      selector.focus();
      selector.click();
    }
  });
});