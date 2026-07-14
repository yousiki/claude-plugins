# ruby-lsp

[Shopify's `ruby-lsp`](https://github.com/Shopify/ruby-lsp) Ruby language server for Claude Code.

## What it is

`ruby-lsp` provides diagnostics, completion, hover, go-to-definition, and formatting integration for Ruby code, with optional add-ons for RSpec, Rails, and other frameworks.

## No runtime fallback chain

`ruby-lsp` is distributed as a RubyGem, not an npm or PyPI package — there's no `bunx`/`uvx` chain to fall back through. This plugin's `lspServers` entry invokes `ruby-lsp` directly, so **the gem's executable must already be on `$PATH`.**

Install it with Ruby/RubyGems on `PATH`:

```sh
gem install ruby-lsp
```

If the project uses Bundler, add `gem "ruby-lsp", group: :development` to the `Gemfile` instead so the server matches the project's Ruby/gem versions — in that case the `ruby-lsp` executable Bundler installs still needs to resolve on `PATH` (e.g. via `bundle binstubs ruby-lsp` or a Ruby version manager shim) for this plugin to find it.

## Extensions

This plugin registers:

- `.rb`, `.rake`, `.gemspec`, `.ru` → Ruby
- `.erb` → ERB

## Notes

- If `ruby-lsp` isn't found on `$PATH`, Claude Code will report "Executable not found in $PATH" in the `/plugin` Errors panel — install it with the command above and reload.
