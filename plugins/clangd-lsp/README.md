# clangd-lsp

[`clangd`](https://clangd.llvm.org/) C/C++ language server for Claude Code.

## What it is

`clangd` provides diagnostics, completion, go-to-definition, and cross-references for C and C++ code. It works best with a `compile_commands.json` in the project root (generate one with CMake's `CMAKE_EXPORT_COMPILE_COMMANDS=ON`, or via `bear`/`compiledb` for other build systems), but still offers basic support without one.

## No runtime fallback chain

Unlike this marketplace's JS/TS- and Python-distributed language servers, `clangd` ships as a native binary from the LLVM project — there's no npm or PyPI package to run on demand through `bunx`/`uvx`. This plugin's `lspServers` entry invokes `clangd` directly, so **the binary must already be on `$PATH`.**

Install it with one of:

- macOS: `brew install llvm` (adds `clangd` under the Homebrew LLVM prefix; symlink or add it to `PATH`) or `xcode-select --install` or a package that bundles `clangd` on your platform
- Debian/Ubuntu: `apt install clangd`
- Fedora: `dnf install clang-tools-extra`
- Arch: `pacman -S clang`
- Manual: download a prebuilt release from [clangd/clangd releases](https://github.com/clangd/clangd/releases)

## Extensions

This plugin registers:

- `.c`, `.h` → C
- `.cpp`, `.cc`, `.cxx`, `.hpp`, `.hxx`, `.C`, `.H` → C++

## Notes

- If `clangd` isn't found on `$PATH`, Claude Code will report "Executable not found in $PATH" in the `/plugin` Errors panel — install it with one of the methods above and reload.
- Started with `--background-index` so cross-file navigation works without waiting on first use.
