# Brave container links (`ext+container://`)

A Brave version of the Firefox add-on *Open external links in a container*.
Links like this open in Brave's built-in **GOOGLE** container:

```
ext+container://GOOGLE/https://claude.ai/new
```

## Why this isn't a browser extension

Brave's Containers (added in 1.92) aren't exposed to extensions, so no extension can
put a tab into a container. Brave 1.95 added a command-line switch for it instead
(`--container=NAME`). This package registers `ext+container:` with your operating
system and turns each link into `brave --container=NAME URL`. When Brave is already
running, the URL opens as a new tab in the existing window.

## Before you start

1. Brave **1.95 or newer** (`brave://settings/help`).
2. Containers turned on: `brave://settings/braveContent` → **Enable Containers**.
3. A container with the exact name used in your links (e.g. `GOOGLE`) — create it in
   that same settings page. Brave won't create named containers on the fly the way
   the Firefox add-on did.

## Install

**Windows** (no admin needed) — in PowerShell, from the `windows` folder:
```
powershell -ExecutionPolicy Bypass -File .\install.ps1
```
Uninstall with `uninstall.ps1`.

**Linux** — `bash unix/install-linux.sh`
(installs to `~/.local/bin` and registers with `xdg-mime`; Flatpak Brave is detected too).

**macOS** — `bash unix/install-macos.sh`
(builds a small background app, `~/Applications/Brave Container Links.app`).

The first time you click a link, Brave asks whether to open it with the handler.
Tick **Always allow** so it stops asking.

## Link formats

| Link | Result |
|---|---|
| `ext+container://GOOGLE/https://claude.ai/new` | Opens in container **GOOGLE** |
| `ext+container://My%20Work/https://example.com` | Names with spaces: use `%20` |
| `ext+container://@temp/https://example.com` | New temporary container |
| `ext+container://@temp:Shop/https://example.com` | Temporary container named **Shop**, reused |
| `ext+container:name=GOOGLE&url=https%3A%2F%2Fclaude.ai` | Firefox add-on format also works |

From a terminal or shortcut, call the handler directly:
```
brave-container-open GOOGLE https://gemini.google.com/app            # Linux/macOS
brave-container-open.ps1 GOOGLE https://gemini.google.com/app        # Windows
```

Only `http(s)` URLs are accepted, so a link on a web page can't use the handler to
pass extra switches or local files to Brave.

Not carried over from the Firefox add-on: creating containers with a colour/icon,
`pinned`, and reader mode — Brave's switch doesn't support them.

## Using Brave Beta or Nightly

Set `BRAVE_BIN` (Linux/macOS) or `$BraveExe` (Windows) at the top of the handler
script to the browser's path, then reinstall.

## Your start page

`index.html` is your DOX BOX page with one fix: the fallback that opens the plain URL
when no handler responds waited only 800 ms, which is shorter than the handler takes
to start Brave, so you'd have got the link twice (once outside the container). It now
waits 3 s.
