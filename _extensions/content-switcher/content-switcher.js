// content-switcher.js
document.addEventListener("DOMContentLoaded", function() {
  const selector = document.getElementById("content-switcher-select");
  if (!selector) return;

  // Cache DOM queries for better performance
  const blocks = document.querySelectorAll(".content-switcher");
  const STORAGE_KEY = "content-switcher-selected-version";

  function switchVersion(version) {
    blocks.forEach(block => {
      if (block.dataset.version === version) {
        block.classList.remove("content-switcher-hidden");
      } else {
        block.classList.add("content-switcher-hidden");
      }
    });

    // Save to localStorage with error handling
    try {
      localStorage.setItem(STORAGE_KEY, version);
    } catch (error) {
      console.warn("Content switcher: Unable to save to localStorage", error);
    }

    // Trigger scroll event to update Quarto's TOC active state
    // This ensures the correct heading is highlighted after switching versions
    window.dispatchEvent(new Event('scroll'));
  }

  selector.addEventListener("change", function(e) {
    switchVersion(e.target.value);
  });

  // Check for URL parameter first, then localStorage
  const urlParams = new URLSearchParams(window.location.search);
  const urlVersion = urlParams.get('version');
  const validOptions = Array.from(selector.options).map(opt => opt.value);

  let savedVersion = null;
  try {
    savedVersion = localStorage.getItem(STORAGE_KEY);
  } catch (error) {
    console.warn("Content switcher: Unable to read from localStorage", error);
  }

  // Consolidate version switching logic
  const versionToLoad = (urlVersion && validOptions.includes(urlVersion))
    ? urlVersion
    : (savedVersion && validOptions.includes(savedVersion))
      ? savedVersion
      : null;

  if (versionToLoad) {
    selector.value = versionToLoad;
    switchVersion(versionToLoad);
  }
});