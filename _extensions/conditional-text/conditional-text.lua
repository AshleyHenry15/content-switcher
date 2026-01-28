-- conditional-text.lua
-- A filter for conditional text in Quarto documents

-- Define defaults
local default_version = "default"
local versions = {}
local selector_position = "header" -- Where to place the selector (header, top, before-content)
local show_selector = true -- Whether to show the version selector
local selector_label = "Version:" -- Label text for the selector

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

    -- Get selector label if specified
    if config["selector-label"] ~= nil then
      selector_label = pandoc.utils.stringify(config["selector-label"])
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
  html = html .. '  <label for="conditional-text-select">' .. selector_label .. '</label>\n'
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

-- Helper function to process conditional elements (both Div and Span)
local function process_conditional_element(element)
  -- Only process elements with conditional-text class
  if not element.classes:includes("conditional-text") then
    return element
  end

  -- Get version (default if not specified)
  local version = element.attributes["version"] or default_version
  add_version_if_new(version)

  -- For HTML output, set up for dynamic switching
  if quarto.doc.isFormat("html") then
    element.attributes["data-version"] = version

    if version ~= default_version then
      element.classes:insert("conditional-text-hidden")
    end

    return element
  end

  -- For non-HTML output, only show the default version
  if version == default_version then
    return element
  else
    return {}
  end
end

-- Process conditional text divs
function Div(div)
  return process_conditional_element(div)
end

-- Process inline conditional text (spans)
function Span(span)
  return process_conditional_element(span)
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
      local insert_position = 1  -- Default to top

      -- Find position based on selector_position setting
      if selector_position == "header" then
        for i, block in ipairs(doc.blocks) do
          if block.t == "Header" then
            insert_position = i + 1
            break
          end
        end
      elseif selector_position == "before-content" then
        for i, block in ipairs(doc.blocks) do
          if block.t == "Div" and block.classes:includes("quarto-content") then
            insert_position = i
            break
          end
        end
      end

      table.insert(doc.blocks, insert_position, pandoc.RawBlock("html", selector_html))
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