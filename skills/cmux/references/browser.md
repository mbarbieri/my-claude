# cmux browser API

Playwright-like browser automation, exposed as `cmux browser <subcommand>`. Every command operates on a **browser surface** — either the caller's current browser surface (auto-detected from `CMUX_SURFACE_ID` if it's a browser), an explicit `--surface <ref|index>`, or a positional `<surface>` arg.

## Mental model

A browser surface is a Chromium page (Playwright under the hood). You can:

- **Navigate** — open URLs, go back/forward, reload
- **Inspect** — accessibility snapshot, screenshot, get URL/title/text/attributes
- **Interact** — click, type, fill, hover, check, scroll, press keys
- **Locate** — by selector or by Playwright-style role/text/label/placeholder/testid
- **Manage state** — cookies, local/session storage, tabs, frames, downloads, dialogs

## Choosing how to "see" the page

| Goal | Use |
|------|-----|
| Understand structure for LLM reasoning | `browser snapshot` (accessibility tree) |
| Visual confirmation for the user | `browser screenshot --out /tmp/x.png` |
| Specific text on the page | `browser get text <selector>` |
| One field's value | `browser get value <selector>` |
| Current URL/title | `browser get url` / `browser get title` |
| Raw HTML (last resort, noisy) | `browser get html` |

**Always prefer `snapshot` over `get html`.** The accessibility tree is shorter, role-tagged, and far easier to reason about.

`snapshot` flags:

```bash
cmux browser snapshot                       # full tree
cmux browser snapshot --interactive         # only focusable / clickable nodes
cmux browser snapshot --cursor              # include cursor position
cmux browser snapshot --compact             # smaller output
cmux browser snapshot --max-depth 5         # limit nesting
cmux browser snapshot --selector "main"     # subtree only
```

## Opening / navigating

```bash
cmux browser open                            # opens a new browser split in caller's workspace
cmux browser open https://example.com        # same, navigated to URL
cmux browser open-split https://example.com  # explicit split form

cmux browser goto https://example.com        # navigate current surface
cmux browser navigate https://example.com    # alias for goto
cmux browser back
cmux browser forward
cmux browser reload
```

Append `--snapshot-after` to any navigation/interaction command to get an accessibility snapshot back in the same call — saves a round trip.

## Locating elements

Two styles. Use whichever yields the most stable selector.

### CSS selector (most commands)

Most interaction commands (`click`, `type`, `fill`, etc.) take a CSS selector directly:

```bash
cmux browser click "button.primary"
cmux browser fill "input[name=email]" "me@example.com"
cmux browser type "textarea#bio" "Hello"
```

### Playwright-style finders (`browser find …`)

When CSS is brittle, use semantic finders:

```bash
cmux browser find role button "Submit"          # role + accessible name
cmux browser find text "Forgot password?"
cmux browser find label "Email"                 # input by its <label> text
cmux browser find placeholder "Search…"
cmux browser find alt "Company logo"
cmux browser find title "Settings"
cmux browser find testid "login-form"           # data-testid="login-form"
cmux browser find first <selector>
cmux browser find last <selector>
cmux browser find nth <n> <selector>
```

`find` returns a description / handle — combine with subsequent commands the same way you'd combine Playwright locators.

## Interacting

```bash
cmux browser click <selector>           [--snapshot-after]
cmux browser dblclick <selector>        [--snapshot-after]
cmux browser hover <selector>           [--snapshot-after]
cmux browser focus <selector>           [--snapshot-after]
cmux browser check <selector>           [--snapshot-after]
cmux browser uncheck <selector>         [--snapshot-after]
cmux browser scroll-into-view <selector>

cmux browser type <selector> <text>     [--snapshot-after]   # types char-by-char (fires keypress)
cmux browser fill <selector> <text>     [--snapshot-after]   # sets value directly (faster, no keystrokes)
cmux browser fill <selector>                                   # empty text → clears the field

cmux browser press <key>                [--snapshot-after]   # one keystroke (Enter, Tab, Escape, …)
cmux browser keydown <key>
cmux browser keyup <key>

cmux browser select <selector> <value>  [--snapshot-after]   # <select> dropdowns
cmux browser scroll [--selector <css>] [--dx <n>] [--dy <n>]
```

`type` vs `fill`: use `fill` for plain inputs (one shot, atomic), `type` when the page reacts to keystrokes (autocomplete, hotkey-based UIs).

## Waiting

Don't `sleep` — cmux has explicit waits.

```bash
cmux browser wait --selector "#results"
cmux browser wait --text "Saved"
cmux browser wait --url-contains "/dashboard"
cmux browser wait --load-state interactive       # or `complete`
cmux browser wait --function "() => window.dataReady === true"
cmux browser wait --selector "#x" --timeout-ms 10000
```

Combine flags freely (e.g. `--selector` *and* `--text` to wait for selector to contain text).

## Reading state

```bash
cmux browser get url
cmux browser get title
cmux browser get text <selector>
cmux browser get html [<selector>]                # noisy — prefer snapshot
cmux browser get value <selector>                 # input value
cmux browser get attr <selector> <attr-name>
cmux browser get count <selector>                 # number of matches
cmux browser get box <selector>                   # bounding rect
cmux browser get styles <selector>

cmux browser is visible <selector>
cmux browser is enabled <selector>
cmux browser is checked <selector>
```

## Screenshots

```bash
cmux browser screenshot                          # returns base64 / handle
cmux browser screenshot --out /tmp/page.png      # write to file
cmux browser screenshot --json                   # metadata + path
```

Read screenshots back via the `Read` tool to view them yourself.

## Frames

```bash
cmux browser frame main                          # back to top frame
cmux browser frame "iframe[name=checkout]"       # scope subsequent ops to a frame
```

After selecting a frame, subsequent `browser` calls operate inside it until you switch back with `frame main`.

## Dialogs

```bash
cmux browser dialog accept
cmux browser dialog accept "my prompt answer"
cmux browser dialog dismiss
```

Auto-fires on the next dialog the page raises (`alert`, `confirm`, `prompt`, `beforeunload`).

## Downloads

```bash
cmux browser download wait                       # waits for next download to start
cmux browser download wait --path /tmp/out.zip   # save to specific path
cmux browser download wait --timeout-ms 30000
```

## Cookies & storage

```bash
cmux browser cookies get
cmux browser cookies get --name session
cmux browser cookies set <json>                  # array of cookie objects
cmux browser cookies clear

cmux browser storage local get
cmux browser storage local get <key>
cmux browser storage local set <key> <value>
cmux browser storage local clear

cmux browser storage session get/set/clear …
```

## Tabs (within a browser surface, NOT cmux tabs)

```bash
cmux browser tab new                             # opens a new tab in same surface
cmux browser tab new https://example.com
cmux browser tab list
cmux browser tab switch <index>
cmux browser tab <index>                         # shorthand for switch
cmux browser tab close
cmux browser tab close <index>
```

## Console & errors

```bash
cmux browser console list                        # buffered console messages
cmux browser console clear

cmux browser errors list                         # uncaught page errors
cmux browser errors clear
```

Useful for catching JS errors that don't crash the page but break behaviour.

## Eval & injection

When CLI commands aren't enough, evaluate JS directly:

```bash
cmux browser eval "document.querySelectorAll('a').length"
cmux browser eval "document.title = 'Renamed'"
```

Persistent injection (re-applied across navigations):

```bash
cmux browser addinitscript "window.__test = true"   # runs before page scripts on every nav
cmux browser addscript     "console.log('one shot')" # runs once in current page
cmux browser addstyle      "body { background: red }"
```

## Highlighting

Useful for debugging selectors visually:

```bash
cmux browser highlight "button.primary"          # outlines matches in the page
```

## State save/load

```bash
cmux browser state save /tmp/state.json          # cookies + storage snapshot
cmux browser state load /tmp/state.json
```

## Identify / surface targeting

```bash
cmux browser identify                            # which surface "browser" calls hit by default
cmux browser identify --surface surface:2
```

All `browser` subcommands accept `--surface <ref|index>` (or positional `<surface>` before the subcommand) when you need to target a specific browser surface other than the default.

## Patterns

### Submit a form and confirm it landed

```bash
cmux browser fill "input[name=email]" "me@example.com"
cmux browser fill "input[name=password]" "$PW"
cmux browser click "button[type=submit]" --snapshot-after
cmux browser wait --url-contains "/dashboard" --timeout-ms 10000
```

### Scrape a list

```bash
cmux browser snapshot --selector "ul.results" --compact
# parse the snapshot — don't try to scrape from raw HTML
```

### Drive a step-by-step wizard

```bash
for step in step1 step2 step3; do
  cmux browser wait --selector "[data-step=$step]"
  cmux browser click "button.next"
done
```

### Handle a confirm dialog before deleting

```bash
cmux browser dialog accept &           # arms the next dialog
cmux browser click "button.delete"     # triggers confirm()
wait
```
