# Content Switcher Extension for Quarto

A Quarto extension that enables dynamic content switching in HTML documents. Perfect for documentation that needs to show different content for multiple versions, languages, or platforms.

## Features

- Display different content blocks based on user selection
- Support for both block-level and inline content switching
- Dropdown selector with customizable position and label
- Persistent selection using localStorage
- URL parameter support for direct linking to specific versions
- Auto-detection of versions from content
- Dark mode support
- Works seamlessly with Quarto themes

## Installation

Install the extension in your Quarto project:

```bash
quarto add AshleyHenry15/content-switcher
```

Or install a specific version:

```bash
quarto add AshleyHenry15/content-switcher@v0.1.0
```

This will install the extension under the `_extensions` subdirectory of your project. If you're using version control, you'll want to check in this directory.

## Usage

### Basic Setup

Add the extension to your document's YAML frontmatter:

```yaml
---
title: "My Document"
format: html
filters:
  - content-switcher
content-switcher:
  default: "v2026.01"
  versions:
    - id: "v2026.01"
      label: "2026.01.0"
    - id: "v2.0"
      label: "2.0"
    - id: "v3.0"
      label: "3.0"
  selector-position: "header"
  selector-label: "Version:"
---
```

### Block-Level Content Switching

Use divs with the `content-switcher` class to create version-specific content blocks:

````markdown
::: {.content-switcher version="v2026.01"}
### Version 2026.01.0 Example

Use pandas to read CSV data:

```python
import pandas as pd
data = pd.read_csv('data.csv')
```
:::

::: {.content-switcher version="v2.0"}
### Version 2.0 Example

Use readr to read CSV data:

```r
library(readr)
data <- read_csv('data.csv')
```
:::
````

### Inline Content Switching

Switch content inline within paragraphs using spans:

```markdown
You can use [pandas]{.content-switcher version="v2026.01"}[readr]{.content-switcher version="v2.0"}[CSV.jl]{.content-switcher version="v3.0"} to read your data files.
```

### Combining with Other Classes

Content switcher blocks can be combined with other Quarto classes:

```markdown
::: {.content-switcher version="v2026.01" .callout-note}
This is a version-specific note with callout styling.
:::
```

## Configuration Options

Configure the extension in your document's YAML frontmatter:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `default` | string | `"default"` | The version to display by default |
| `versions` | array | `[]` | List of version configurations |
| `selector-position` | string | `"header"` | Where to place the selector: `"header"`, `"top"`, or `"before-content"` |
| `show-selector` | boolean | `true` | Whether to show the version selector dropdown |
| `selector-label` | string | `"Version:"` | Label text for the selector |

### Version Configuration

Each version in the `versions` array can be configured as:

```yaml
versions:
  - id: "unique-id"        # Required: unique identifier used in version attributes
    label: "Display Name"  # Optional: user-friendly name shown in dropdown (defaults to id)
```

Or as a simple string:

```yaml
versions:
  - "v1.0"
  - "v2.0"
```

## Advanced Features

### URL Parameters

Link directly to a specific version by adding a URL parameter:

```
https://example.com/docs.html?version=v2026.01
```

The URL parameter takes precedence over localStorage.

### Persistent Selection

User selections are automatically saved in localStorage and persist across page visits within the same browser.

### Auto-Detection

If no versions are specified in the configuration, the extension will automatically detect versions from content blocks.

## Example

See the [example.qmd](example.qmd) file for a complete working example, or view the [live demo site](https://yoursite.com).

## Output Formats

This extension is designed for HTML output only. When rendering to PDF, Word, or other formats, only the default version content will be included.

## Development

The extension consists of three main files:

- `content-switcher.lua` - Pandoc Lua filter for processing content
- `content-switcher.js` - Client-side JavaScript for version switching
- `content-switcher.css` - Styling for the selector and content blocks

## Requirements

- Quarto >= 1.3.0

## License

[Add your license here]

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.
