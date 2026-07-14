# jdtls-lsp

[Eclipse JDT.LS](https://github.com/eclipse-jdtls/eclipse.jdt.ls) Java language server for Claude Code.

## What it is

JDT.LS provides diagnostics, completion, refactoring, and navigation for Java projects (Maven, Gradle, or plain source trees), built on the Eclipse JDT compiler.

## No runtime fallback chain

JDT.LS ships as a tarball of jars plus a launcher script, not an npm or PyPI package — there's no `bunx`/`uvx` chain to fall back through. This plugin's `lspServers` entry invokes a `jdtls` launcher directly, so **a `jdtls` command must already be on `$PATH`, and a JDK (17+) must be installed.**

Install it with one of:

- macOS: `brew install jdtls` (installs both the launcher and a bundled JDK dependency check)
- Manual: download the latest tarball from the [Eclipse JDT.LS downloads page](https://download.eclipse.org/jdtls/snapshots/?d), extract it, and put a wrapper script on `PATH` that runs `java -jar <path>/plugins/org.eclipse.equinox.launcher_*.jar ...` (see the [running from the command line](https://github.com/eclipse-jdtls/eclipse.jdt.ls#running-from-the-command-line) instructions) — name that wrapper `jdtls`
- Many Neovim/Vim LSP installers (e.g. Mason) also provide a ready-made `jdtls` wrapper if you already have one of those installed

## Extensions

This plugin registers:

- `.java` → Java

## Notes

- If `jdtls` isn't found on `$PATH`, Claude Code will report "Executable not found in $PATH" in the `/plugin` Errors panel — install it with one of the methods above and reload.
- `startupTimeout` is set to 120s: JDT.LS does an initial workspace index on first launch, which is slower than most other language servers here.
