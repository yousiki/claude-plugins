# Claude Code Plugin Marketplace Design

## Goal
Build a custom Claude Code plugin marketplace in this repo that stays close to the official marketplace layout while adapting selected plugins to run without assuming host-level global installs.

The initial marketplace scope is intentionally narrow:
- official plugins to migrate and adapt: `pyright-lsp`, `typescript-lsp`, `context7`
- custom plugins to add: `basedpyright-lsp`, `ty-lsp`, `ruff-formatter`

This is not a full mirror of the official marketplace. It is a curated, language-tool-focused set of plugin directories.

## Design Principles

### 1. Match official marketplace structure where practical
The repo should organize plugins in a way that feels familiar relative to the Claude Code official marketplace.

Rather than a centralized runtime dispatcher that all plugins register into, each plugin should live in its own folder and contain its own manifest, startup configuration, and plugin-specific runtime fallback behavior.

### 2. Use templates for consistency
Shared structure should come from templates, not from a global runtime abstraction.

Recommended top-level layout:
- `templates/js-ts-tool-plugin/`
- `templates/python-tool-plugin/`
- `plugins/context7/`
- `plugins/typescript-lsp/`
- `plugins/pyright-lsp/`
- `plugins/basedpyright-lsp/`
- `plugins/ty-lsp/`
- `plugins/ruff-formatter/`

Each template should provide:
- plugin directory skeleton
- manifest examples
- startup configuration examples
- fallback logic examples
- README guidance for how to fill in tool-specific details

### 3. Choose runtime by the launcher ecosystem the plugin adopts
Runtime selection should follow the ecosystem of the executable entrypoint the plugin will launch in this marketplace, not the language of the source files being analyzed.

In practice, this means:
- npm-distributed or JS/TS CLI entrypoints should use the JS/TS execution chain
- PyPI-distributed CLI entrypoints should use the Python execution chain, even if the underlying tool is implemented in Rust
- the analyzed language is not the deciding factor

Examples:
- `pyright-lsp` analyzes Python but the marketplace will launch it through its JS/TS distribution path, so it should follow the JS/TS execution chain
- `ruff-formatter` is implemented in Rust but distributed for marketplace use through a Python CLI path, so it should follow the Python execution chain
- `ty-lsp` is based on `ty`, which is implemented in Rust, but if this marketplace launches it through its PyPI-distributed entrypoint then it should also follow the Python execution chain

## Runtime Strategy

### JS/TS tool chain
For plugins backed by JS/TS CLI tools, try in this order:
1. `bunx`
2. `pnpm dlx`
3. `npx`

Behavioral expectations:
- prefer latest package resolution when practical
- embed the fallback sequence in the plugin implementation itself
- avoid requiring global installs like `npm install -g ...`

This chain applies to:
- `context7`
- `typescript-lsp`
- `pyright-lsp`

### Python tool chain
For plugins backed by Python CLI tools, try in this order:
1. `uvx`
2. `pipx`
3. `python -m`

Behavioral expectations:
- prefer fresh execution when practical
- avoid assuming the host already has the CLI installed globally
- make module-name-versus-command-name differences explicit in plugin definitions when needed

This chain applies to:
- `basedpyright-lsp` if the marketplace follows its PyPI-distributed entrypoint
- `ruff-formatter`
- `ty-lsp` if the marketplace follows its PyPI-distributed entrypoint

### System binary chain
Some tools may later need a separate system-binary-oriented template family, but that is not part of the initial marketplace scope.

The initial marketplace should prefer package-managed launcher paths where available rather than introducing a separate binary-discovery strategy up front.

## Plugin Adaptation List

### `context7`
Source: official plugin

Why it belongs here:
- official startup config hardcodes `npx`

Required changes:
- replace fixed `npx` execution with plugin-local JS/TS fallback logic
- preserve plugin identity and purpose
- document that this is a marketplace-adapted version of the upstream plugin

Recommended template:
- `templates/js-ts-tool-plugin/`

Migration difficulty:
- low

### `typescript-lsp`
Source: official plugin

Why it belongs here:
- upstream docs assume global npm installation of `typescript-language-server` and `typescript`

Required changes:
- replace global-install assumptions with plugin-local JS/TS fallback logic
- encode the language server startup shape in the plugin directory rather than in installation instructions
- make sure invocation parameters needed for LSP startup are preserved

Recommended template:
- `templates/js-ts-tool-plugin/`

Migration difficulty:
- low to medium

### `pyright-lsp`
Source: official plugin

Why it belongs here:
- upstream docs assume global installation and blur JS-versus-Python distribution paths

Required changes:
- treat it as a JS/TS-backed tool for execution purposes
- replace global-install assumptions with plugin-local JS/TS fallback logic
- explain clearly in docs that runtime choice follows the implementation language of the tool, not the analyzed source language

Recommended template:
- `templates/js-ts-tool-plugin/`

Migration difficulty:
- medium

### `basedpyright-lsp`
Source: custom plugin

Notes:
- Basedpyright is officially published on PyPI and also available on npm, with upstream docs recommending PyPI first

Required changes:
- follow the Python tool chain through its PyPI-distributed launcher path
- encode Python fallback logic directly in the plugin directory
- document how it differs from `pyright-lsp` and when users should choose it

Recommended starting point:
- `templates/python-tool-plugin/`

Migration difficulty:
- medium

### `ty-lsp`
Source: custom plugin based on Astral `ty`

Notes:
- `ty` is implemented in Rust, but the marketplace should prefer its PyPI-distributed launcher path when available

Required changes:
- implement Python-chain fallback behavior in the plugin directory
- define the LSP startup contract clearly
- document that launcher selection follows the chosen distribution path, not the implementation language of the tool internals

Recommended starting point:
- `templates/python-tool-plugin/`

Migration difficulty:
- medium

### `ruff-formatter`
Source: custom plugin

Notes:
- `ruff` is implemented in Rust, but this marketplace should launch it through the Python ecosystem path

Required changes:
- implement Python tool fallback logic locally in the plugin directory
- define the formatter invocation contract clearly
- document what capability is exposed first: pure formatting, or formatting plus optional fix/lint-related workflows later

Recommended template:
- `templates/python-tool-plugin/`

Migration difficulty:
- low to medium

## Rollout Plan

### Phase 1: establish templates and baseline plugins
Create the first two templates:
- `templates/js-ts-tool-plugin/`
- `templates/python-tool-plugin/`

Use them to build and validate four baseline plugins:
- `context7`
- `typescript-lsp`
- `pyright-lsp`
- `ruff-formatter`

This phase validates:
- repo structure
- per-plugin embedded fallback behavior
- template usefulness across both adapted and custom entries

### Phase 2: add the remaining current-scope plugins
Add:
- `basedpyright-lsp`
- `ty-lsp`

This phase extends the same template-driven structure to the remaining Python-ecosystem entries while preserving the same per-plugin marketplace shape.

## Failure Handling
Each plugin should own its fallback behavior, but error reporting should still feel consistent.

When all fallback attempts fail, plugin output should say:
- which tool it attempted to launch
- which commands were tried in order
- why each attempt failed, if that is known
- what the user can install or configure next

Errors should be actionable rather than just reporting that a command was not found.

## Verification Strategy

### Template verification
For each template, verify:
- directory structure is complete
- sample plugin shape matches intended marketplace conventions
- fallback order is encoded correctly

### Plugin smoke tests
For each plugin, verify:
- the expected startup command is constructed correctly
- startup works when the preferred runtime is present
- fallback works when higher-priority runtimes are absent
- failures are clear when no supported runtime is available

### Practical environment matrix
Design for these environments even if automation comes later:

JS/TS-backed tools:
- only `bun`
- only `pnpm`
- only `npm/npx`

Python-backed tools:
- only `uv`
- only `pipx`
- only `python`

## Open Decisions
The design is intentionally settled on repo shape, scope, and fallback direction. Remaining decisions are plugin-specific details such as exact package names, launch arguments, and how much plugin documentation should explain upstream differences.

These decisions should be resolved during implementation planning, not by changing the marketplace’s overall structure.