-- conditional-text.lua
-- A filter for conditional text in Quarto documents

-- Define defaults
local default_version = "default"
local versions = {}
local selector_position = "header" -- Where to place the selector (header, top, before-content)
local show_selector = true -- Whether to show the version selector

-- Parse configuration from document metadata
function get_config(meta)
  -- Get config from document metadata
  local config = meta["conditional-text"]

  if config ~= nil then
    -- Get default version if specified
    if config["default"] ~= nil then
      default_version = pandoc.utils.stringify(config["default"])
    end

    -- Get versions if specified
    if config["versions"] ~= nil then
      for i, version in ipairs(config["versions"]) do
        if type(version) == "table" then
          -- Handle detailed version specification with ID and label
          local id = pandoc.utils.stringify(version["id"])
          local label = pandoc.utils.stringify(version["label"] or id)
          table.insert(versions, { id = id, label = label })
        else
          -- Handle simple version string
          local id = pandoc.utils.stringify(version)
          table.insert(versions, { id = id, label = id })
        end
      end
    end

    -- Get selector position if specified
    if config["selector-position"] ~= nil then
      selector_position = pandoc.utils.stringify(config["selector-position"])
    end

    -- Get show_selector if specified
    if config["show-selector"] ~= nil then
      show_selector = config["show-selector"]
    end
  end

  -- If no versions defined but we have conditional blocks, add defaults based on what we find
  if #versions == 0 then
    quarto.log.output("No versions defined in metadata, will auto-detect")
  end
end

-- Add a version dynamically if discovered in content
function add_version_if_new(version)
  -- Don't add empty versions
  if version == nil or version == "" then
    return
  end

  -- Check if this version already exists
  for i, v in ipairs(versions) do
    if v.id == version then
      return -- Already exists
    end
  end

  -- Add the new version
  table.insert(versions, { id = version, label = version })
  quarto.log.output("Added version: " .. version)
end

-- Generate version selector HTML
function generate_version_selector()
  if #versions == 0 or not show_selector then
    return ""
  end

  local html = '<div class="conditional-text-selector">\n'
  html = html .. '  <label for="conditional-text-select">Version:</label>\n'
  html = html .. '  <select id="conditional-text-select" aria-label="Select content version">\n'

  for i, version in ipairs(versions) do
    local selected = ""
    if version.id == default_version then
      selected = ' selected="selected"'
    end
    html = html .. '    <option value="' .. version.id .. '"' .. selected .. '>' .. version.label .. '</option>\n'
  end

  html = html .. '  </select>\n'
  html = html .. '</div>\n'

  return html
end

-- Process conditional text divs
function Div(div)
  -- Process div with conditional-text class
  if div.classes:includes("conditional-text") then
    -- Get version from attributes
    local version = div.attributes["version"] or default_version

    -- Add this version to our list if it's new
    add_version_if_new(version)

    -- For HTML output, set up for dynamic switching
    if quarto.doc.isFormat("html") then
      -- Set data attribute for version
      div.attributes["data-version"] = version

      -- Determine initial visibility
      if version == default_version then
        div.attributes["data-visible"] = "true"
      else
        div.attributes["data-visible"] = "false"
        div.classes:insert("conditional-text-hidden")
      end

      return div
    end

    -- For non-HTML output, only show the default version
    if version == default_version then
      return div
    else
      -- Return empty to hide this div
      return {}
    end
  end

  -- Also check for fenced div syntax with attribute
  if div.attributes["version"] ~= nil then
    local version = div.attributes["version"]
    div.classes:insert("conditional-text")

    -- Add this version to our list if it's new
    add_version_if_new(version)

    -- For HTML output, set up for dynamic switching
    if quarto.doc.isFormat("html") then
      -- Set data attribute for version
      div.attributes["data-version"] = version

      -- Determine initial visibility
      if version == default_version then
        div.attributes["data-visible"] = "true"
      else
        div.attributes["data-visible"] = "false"
        div.classes:insert("conditional-text-hidden")
      end

      return div
    end

    -- For non-HTML output, only show the default version
    if version == default_version then
      return div
    else
      -- Return empty to hide this div
      return {}
    end
  end

  return div
end

-- Process inline conditional text (spans)
function Span(span)
  -- Process span with conditional-text class
  if span.classes:includes("conditional-text") then
    -- Get version from attributes
    local version = span.attributes["version"] or default_version

    -- Add this version to our list if it's new
    add_version_if_new(version)

    -- For HTML output, set up for dynamic switching
    if quarto.doc.isFormat("html") then
      -- Set data attribute for version
      span.attributes["data-version"] = version

      -- Determine initial visibility
      if version == default_version then
        span.attributes["data-visible"] = "true"
      else
        span.attributes["data-visible"] = "false"
        span.classes:insert("conditional-text-hidden")
      end

      return span
    end

    -- For non-HTML output, only show the default version
    if version == default_version then
      return span
    else
      -- Return empty to hide this span
      return {}
    end
  end

  -- Also check for attribute syntax
  if span.attributes["version"] ~= nil then
    local version = span.attributes["version"]
    span.classes:insert("conditional-text")

    -- Add this version to our list if it's new
    add_version_if_new(version)

    -- For HTML output, set up for dynamic switching
    if quarto.doc.isFormat("html") then
      -- Set data attribute for version
      span.attributes["data-version"] = version

      -- Determine initial visibility
      if version == default_version then
        span.attributes["data-visible"] = "true"
      else
        span.attributes["data-visible"] = "false"
        span.classes:insert("conditional-text-hidden")
      end

      return span
    end

    -- For non-HTML output, only show the default version
    if version == default_version then
      return span
    else
      -- Return empty to hide this span
      return {}
    end
  end

  return span
end

-- Main filter function
function Meta(meta)
  get_config(meta)
  return meta
end

function Pandoc(doc)
  -- Only for HTML, inject selector and JavaScript
  if quarto.doc.isFormat("html") then
    local selector_html = generate_version_selector()

    -- Inject version selector and JavaScript
    quarto.doc.addHtmlDependency({
      name = "conditional-text",
      version = "0.1.0",
      scripts = {"conditional-text.js"},
      stylesheets = {"conditional-text.css"}
    })

    -- If we have versions and show_selector is true, inject selector HTML
    if #versions > 0 and show_selector then
      -- Determine where to add the selector
      if selector_position == "header" then
        -- Add after first header (typical for Quarto docs)
        local first_header_idx = -1
        for i, block in ipairs(doc.blocks) do
          if block.t == "Header" then
            first_header_idx = i
            break
          end
        end

        if first_header_idx > 0 then
          table.insert(doc.blocks, first_header_idx + 1, pandoc.RawBlock("html", selector_html))
        else
          table.insert(doc.blocks, 1, pandoc.RawBlock("html", selector_html))
        end
      elseif selector_position == "top" then
        -- Add at the very top
        table.insert(doc.blocks, 1, pandoc.RawBlock("html", selector_html))
      elseif selector_position == "before-content" then
        -- Look for a div with class quarto-content
        local content_div_idx = -1
        for i, block in ipairs(doc.blocks) do
          if block.t == "Div" and block.classes:includes("quarto-content") then
            content_div_idx = i
            break
          end
        end

        if content_div_idx > 0 then
          table.insert(doc.blocks, content_div_idx, pandoc.RawBlock("html", selector_html))
        else
          -- Fallback to top
          table.insert(doc.blocks, 1, pandoc.RawBlock("html", selector_html))
        end
      end
    end
  end

  return doc
end

-- Register the filter functions
return {
  { Meta = Meta },
  { Span = Span },
  { Div = Div },
  { Pandoc = Pandoc }
}