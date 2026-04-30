---
name: cmux
description: Use to drive the user's cmux terminal multiplexer — read output from other panes, send input/keys into other terminals, spawn new workspaces/splits/panes, control browser surfaces (Playwright-like), and post desktop notifications. Trigger eagerly whenever the user references work happening in another terminal, pane, workspace, or browser surface ("the other terminal", "my running server", "the pane next to this one", "in my browser", "tell me when X finishes"), or asks Claude to open/split/spawn a terminal or browser. Also trigger when the user says "cmux", "send this to…", "look at what's running in…", "notify me when…", or wants Claude to drive a webpage they have open.
---

# cmux

cmux is a terminal multiplexer + workspace manager + browser controller, all driven over a Unix socket via the `cmux` CLI. If the user is running cmux, you can see what's in their other terminals, type into them, spawn new ones, drive their browser, and notify them — all without leaving your current pane.

## When to use this skill (eager triggers)

Fire this skill whenever the user's request touches anything outside your current pane. Examples:

- "Look at what's running in the pane next to this one"
- "Send `npm test` to my server terminal"
- "What does the build log say in workspace 3?"
- "Open a new terminal and run X"
- "Split this pane and run the dev server on the right"
- "Click the login button on the page I have open"
- "Fill in the email field with…"
- "Notify me when the tests finish"
- "What's in my browser right now?"
- Any phrase like *the other pane / the other terminal / my running X / the workspace where Y / the browser tab I just opened*.

Don't wait for the user to say "cmux" — they may not know that's the name of what they're using. The signal is **cross-context work**: anything that requires reading or writing somewhere other than where you're typing.

## Prerequisites

Run `cmux ping` first if uncertain. Expected reply: `PONG`. If it fails, cmux isn't running or the socket isn't reachable — tell the user, don't keep guessing.

```bash
cmux ping        # PONG if alive
cmux version     # build info
```

## Mental model

cmux has a 4-level hierarchy. Internalise this — most commands take refs at one of these levels.

```
window      one OS window of the cmux app
└── workspace    a tab inside the window (the user's "project context")
    └── pane         a split region inside a workspace
        └── surface     the actual terminal / browser inside a pane
```

A workspace can also have **panels** (sidebars, e.g. AI chat panel). Surfaces come in two types: `terminal` and `browser`.

### Identifying things

Every entity has a UUID, a short ref, and an index. Commands accept any of:

- **ref**: `workspace:1`, `pane:3`, `surface:2`, `window:1` — short and stable per-session
- **index**: just `1`, `2` — position in the parent's list
- **uuid**: full UUID — what you get from `--id-format uuids`

Default to refs in your output. Add `--id-format both` if the user asks for stable identifiers.

### Auto-context env vars

When `cmux` runs *inside a cmux terminal* (which is your situation right now), these are pre-set and used as defaults:

- `CMUX_WORKSPACE_ID` — default `--workspace`
- `CMUX_SURFACE_ID` — default `--surface`
- `CMUX_TAB_ID` — default `--tab` for `tab-action` / `rename-tab`

So `cmux read-screen` with no flags reads *your own pane*. To read elsewhere, pass `--workspace` and/or `--surface` explicitly.

## Inspecting state

Always orient yourself before acting. Don't send input to a guessed surface — list first.

```bash
cmux current-workspace             # ref of the workspace you're in
cmux list-workspaces               # all workspaces, marks the selected one
cmux list-windows                  # all OS windows
cmux tree                          # workspace tree: panes + surfaces
cmux tree --all                    # tree across all workspaces
cmux list-panes --workspace workspace:3
cmux list-pane-surfaces --workspace workspace:3 --pane pane:1
cmux list-panels --workspace workspace:3
```

`tree` is the single most useful inspection command — it shows the full pane/surface layout for the workspace and is how you find the right `surface:N` to target.

## Reading output from other panes

This is the highest-leverage cmux capability for Claude. You can see what's on someone else's terminal screen without disturbing it.

```bash
# Read what's currently visible on a surface
cmux read-screen --workspace workspace:3 --surface surface:2

# Include scrollback, last 200 lines
cmux read-screen --workspace workspace:3 --surface surface:2 --scrollback --lines 200
```

Use this to:

- Diagnose errors the user is seeing in another terminal
- Check whether a long-running process is done / what it printed
- Read REPL state, server logs, test output, etc.

Prefer `read-screen` over asking the user to copy-paste output.

## Sending input to other panes

Two flavours: **text** and **keys**.

```bash
# Type text (does NOT press Enter — terminal sees it as if typed)
cmux send --workspace workspace:3 --surface surface:2 "ls -la"

# Press a named key (Enter, Up, Down, Tab, C-c, etc.)
cmux send-key --workspace workspace:3 --surface surface:2 Enter

# To "run a command", send text + Enter as two calls
cmux send --workspace workspace:3 --surface surface:2 "npm test"
cmux send-key --workspace workspace:3 --surface surface:2 Enter
```

**Be careful — this is real input on a real terminal.** Treat sending input like running a destructive command:

- For anything that mutates state (deploys, deletes, force-pushes, drops, restarts), confirm with the user first and tell them the exact target surface.
- For read-only commands (`ls`, `git status`, `cat`), just do it.
- After sending, optionally `read-screen` to verify the result before reporting back.

`send-panel` / `send-key-panel` exist for sending input into a workspace **panel** (e.g. an AI chat panel) — same shape, but `--panel` instead of `--surface`.

## Spawning workspaces, splits, panes, surfaces

Pick the right granularity:

| Want | Use |
|------|-----|
| New project context (its own tab) | `cmux new-workspace` |
| New OS window | `cmux new-window` |
| Split the current pane | `cmux new-split <left\|right\|up\|down>` |
| Add another pane to a workspace | `cmux new-pane --type terminal\|browser` |
| Add a surface (tab) inside an existing pane | `cmux new-surface --type terminal\|browser --pane <ref>` |

Common recipes:

```bash
# New workspace running a command in a directory
cmux new-workspace --name "dev server" --cwd ~/dev/myapp --command "npm run dev"

# Split current pane to the right and put a browser there pointing at localhost
cmux new-split right
cmux new-surface --type browser --url http://localhost:3000

# Open an SSH session as a new workspace
cmux ssh user@host --name "prod box"
```

When you spawn something for the user, **return the ref** they should use to refer to it later (e.g. "I opened it as `workspace:8`"). They can also see it in the UI, but the ref makes follow-up requests precise.

## Notifications

Push a desktop notification — useful for "ping me when X finishes" workflows.

```bash
cmux notify --title "Tests passed" --body "All 142 green in 38s"
cmux notify --title "Deploy ready" --subtitle "staging" --body "Click to review"

cmux list-notifications      # see history
cmux clear-notifications
```

If the user says "let me know when…" or "tell me once X is done", set up a watch loop and emit a `cmux notify` at the end.

## Inter-pane coordination

When two panes need to coordinate — wait for each other, react to output, or talk back and forth (e.g. two Claude instances) — cmux gives you several primitives. Pick the lightest one that fits.

### `wait-for` — named signals between panes

The cleanest "wake me when you're done" primitive. One pane blocks on a named token; another pane signals it. Tokens are global across the cmux instance — pick distinct names per workflow.

```bash
# Pane A: block until "build-done" is signalled (default 30s timeout)
cmux wait-for build-done --timeout 600

# Pane B: signal it
cmux wait-for -S build-done
```

### `pipe-pane` — react continuously to another pane's output

Watch a pane and react to lines as they appear, instead of polling.

```bash
cmux pipe-pane --workspace workspace:3 --surface surface:2 \
  --command 'grep -q "Listening on" && cmux wait-for -S server-up'
```

The shell command receives the pane's text on stdin as it streams. Combine with `wait-for` to convert "output appeared" into a signal.

### `set-hook` + `claude-hook` — react to events

`set-hook` is a generic event-hook system; `claude-hook` exposes Claude Code lifecycle events specifically. Combined, they're how you build "fire X when the other Claude finishes thinking".

```bash
cmux set-hook --list                       # see configured hooks
cmux set-hook <event> '<shell command>'    # wire one
cmux set-hook --unset <event>              # remove
```

Claude lifecycle events (`cmux claude-hook <subcommand>`):

- `session-start` (alias `active`) — Claude session began
- `stop` (alias `idle`) — Claude session went idle / finished its turn
- `notification` (alias `notify`) — Claude emitted a notification
- `prompt-submit` — user submitted a prompt

Confirm exact hook event names available in your build with `cmux set-hook --list` after wiring — names can vary by cmux version.

### Pattern: two Claude instances talking to each other

A asks B a question, waits for B to finish, reads the answer.

```bash
# One-time setup on B's side: when B goes idle, signal a named token.
cmux set-hook claude-stop 'cmux wait-for -S claude-b-done'

# A's side: send a prompt into B's terminal, submit, wait, read back.
cmux send        --workspace ws-b --surface s-b "Please summarise foo.md"
cmux send-key    --workspace ws-b --surface s-b Enter
cmux wait-for    claude-b-done --timeout 300
cmux read-screen --workspace ws-b --surface s-b --scrollback --lines 400
```

If B lives in a workspace **panel** (AI sidebar) rather than a terminal surface, swap `send` / `send-key` for `send-panel` / `send-key-panel` with `--panel <ref>`.

### Picking the right primitive

| Need | Use |
|------|-----|
| Pane B explicitly tells A "I'm done" | `wait-for` token |
| Poll B until visible output looks done | `read-screen` in a loop |
| React to every line B prints | `pipe-pane` |
| React to a cmux event | `set-hook` |
| React to a Claude session lifecycle event | `claude-hook` + `set-hook` |
| Tell the human something happened | `cmux notify` |

## Browser automation

cmux includes a full Playwright-like API on browser surfaces — navigation, clicking, typing, snapshots, screenshots, cookies, storage, tabs, frames, downloads, etc. The full reference is large; load it on demand.

**See `references/browser.md` when the user wants to drive a webpage.**

Quick pointers without reading the reference:

```bash
cmux browser open https://example.com           # opens in caller's workspace
cmux browser goto https://example.com           # navigate current browser surface
cmux browser snapshot                            # accessibility tree (best for LLMs)
cmux browser screenshot --out /tmp/page.png
cmux browser click "button:has-text('Submit')"
cmux browser fill "input[name=email]" "me@x.com"
cmux browser get url                             # current URL
```

Default to `browser snapshot` (accessibility tree) for understanding page structure — it's far more LLM-friendly than HTML.

## Other useful commands

```bash
cmux focus-pane --pane pane:2                    # bring a pane to front
cmux focus-panel --panel <ref>                   # focus a sidebar panel
cmux select-workspace --workspace workspace:3    # switch workspace
cmux rename-workspace --workspace workspace:3 "deploy logs"
cmux rename-tab --surface surface:2 "API server"

cmux close-surface --surface surface:5
cmux close-workspace --workspace workspace:8

cmux refresh-surfaces                            # force redraw if something looks stuck
cmux surface-health                              # check terminal/browser health

cmux themes list / set / clear                   # theming
cmux feedback --body "..."                       # send feedback to cmux team
```

## RPC escape hatch

For anything not covered by a named subcommand, cmux exposes raw RPC:

```bash
cmux capabilities                                # list all RPC methods
cmux rpc <method> '<json-params>'                # call any method directly
```

Reach for `rpc` only when the named CLI doesn't expose what you need.

## Working style

1. **Inspect before acting.** `tree` or `list-workspaces` first when targeting something other than your own pane.
2. **Read after writing.** After `send`, follow up with `read-screen` to confirm the command landed and to capture output.
3. **Quote refs when reporting back.** Say `surface:2 in workspace:3` — never "the other one".
4. **Treat `send` as command execution.** Same care you'd take with `Bash`: confirm destructive actions, don't fire blind.
5. **Don't paste long output the user can already see.** If they're watching the pane, summarise; if they can't see it, paste the relevant part.

## Common mistakes

### Sending input without confirming target

```bash
# DON'T fire send into a guessed surface
cmux send --surface surface:2 "rm -rf node_modules"

# DO list first, confirm with user, then send
cmux tree
# "I'll run this in surface:2 of workspace:3 (your 'api server' tab) — ok?"
```

### Using read-screen on yourself when you wanted another pane

`read-screen` defaults to `CMUX_SURFACE_ID` — your own pane. Always pass `--workspace` and `--surface` when targeting elsewhere.

### Forgetting `Enter` after `send`

`send "npm test"` types `npm test` into the prompt but doesn't run it. Follow with `cmux send-key … Enter`.

### Reaching for HTML when `browser snapshot` exists

`browser get html` returns full HTML — long, noisy. `browser snapshot` returns the accessibility tree, which is the right input for LLM reasoning about a page.
