# Claude Code + Warp, starter pack

Hi Dave. This is a ready-to-go version of my Claude Code setup, with all my
personal accounts and keys stripped out. Follow the steps below and you'll have
the same working environment I use every day. You don't need to be a developer.
Takes about half an hour.

The whole system lives in one folder on your Mac: `~/.claude/`. That folder *is*
the setup. This pack contains the files that go into it, plus the instructions.

---

## Quickest start — let Claude do it for you

Once you've installed Claude Code (Step 1 below), open a Claude session and paste:

> Look at this repo: https://github.com/PepoBCN/claude-code-warp-starter
> Read the README, then plan and execute the whole setup for me on this Mac.
> Walk me through anything you need me to do myself (logins, permissions), and
> explain each step plainly as you go. I'm a beginner, so don't assume I can code.

Claude reads these instructions, works out the steps and runs them, stopping to
ask whenever it needs you to log in or tick a permission box. If you'd rather do
it by hand, just follow the numbered steps below.

---

## What's in this pack

```
README.md              ← you are here
settings.json          ← the main config (goes to ~/.claude/settings.json)
statusline-command.sh  ← the status bar at the bottom of the screen
CLAUDE.md.template      ← your personal rules file (rename to CLAUDE.md)
bin/cc-warp            ← helper to open new Claude sessions in new Warp tabs
memory/MEMORY.md       ← starter memory file so Claude remembers across sessions
commands/              ← two handy slash commands (build-parallel, check)
agents/                ← a code-review helper
skills/                ← two reusable skills (deckadence, graphify) — see below
```

---

## Step 1 — Install the basics

Open Terminal and run these one at a time:

```bash
# If you don't have Homebrew yet, install it first from brew.sh

# Warp terminal
brew install --cask warp

# Claude Code itself
curl -fsSL https://claude.ai/install.sh | bash

# Three small helpers this setup uses
brew install jq terminal-notifier
```

Open Warp, type `claude`, and log in when it asks. You now have a plain version
working. The rest of this turns it into the good version.

---

## Step 2 — Drop in the config files

Copy the files from this pack into your `~/.claude/` folder. In Terminal, from
inside this pack's folder:

```bash
mkdir -p ~/.claude/bin ~/.claude/memory ~/.claude/commands ~/.claude/agents ~/.claude/skills

cp settings.json            ~/.claude/
cp statusline-command.sh    ~/.claude/
cp CLAUDE.md.template        ~/.claude/CLAUDE.md
cp bin/cc-warp              ~/.claude/bin/        && chmod +x ~/.claude/bin/cc-warp
cp memory/MEMORY.md         ~/.claude/memory/
cp -R commands/*            ~/.claude/commands/
cp -R agents/*              ~/.claude/agents/
cp -R skills/*              ~/.claude/skills/
```

Then open `~/.claude/settings.json` in any text editor and replace `YOURNAME`
with your Mac username (run `whoami` in Terminal if you're not sure).

---

## Step 3 — Make `claude` open in your projects folder

Decide where your projects will live, e.g. `~/Documents/projects`, and create it:

```bash
mkdir -p ~/Documents/projects
```

Open `~/.zshrc` in a text editor and add this line (point it at your folder):

```bash
alias claude='cd "/Users/YOURNAME/Documents/projects" && command claude'
```

Now typing `claude` anywhere jumps to your projects folder first. Run
`source ~/.zshrc` to apply it, or just close and reopen Warp.

---

## Step 4 — Turn on the Warp plugin

This makes Warp and Claude feel like one tool: notifications when Claude finishes
or needs you, and a live status dot in the tab list. Inside a Claude session, run:

```
/plugin marketplace add warpdotdev/claude-code-warp
/plugin install warp@claude-code-warp
```

Then restart Claude (or run `/reload-plugins`).

---

## Step 5 — Allow the new-tab helper (optional but nice)

The `cc-warp` script lets you open a fresh Claude session in a new Warp tab
without leaving the one you're in. Handy once you're juggling a couple of things.

For it to work, give Warp permission to be controlled:
System Settings → Privacy & Security → Accessibility → tick **Warp**.

Then:

```bash
~/.claude/bin/cc-warp                     # new tab, current folder
~/.claude/bin/cc-warp ~/Documents/foo     # new tab in that folder
```

---

## Step 6 — Make the rules file yours

Open `~/.claude/CLAUDE.md` (you copied the template in step 2) and edit it. This
is the single most important file. It's plain English instructions Claude reads
every session: how to talk to you, what your hard rules are, what you're working
on. Even a short version completely changes how it behaves. Add to it whenever
Claude does something you want done differently.

That's the whole setup. Everything below is extra.

---

## The two skills in this pack

Skills are bundles of know-how Claude can call on. These two are genuinely useful
and don't need any account or key:

**deckadence** — builds animated, single-file HTML presentations from a brief.
Think Prezi-style slides with no PowerPoint and no setup, just one file you open
in a browser. Great for pitch decks and one-pagers.

**graphify** — turns a pile of material (documents, notes, research) into an
interactive visual map of the key themes and how they connect. Good for making
sense of messy inputs fast.

To use either, just describe what you want in a session, e.g. "build me a deck
about X" or "graphify these notes", and Claude picks the skill up.

The two **commands** (`/build-parallel`, `/check`) and the **code-review** agent
are for when you start building things across several files. Ignore them until you
get there, they'll be waiting.

---

## Relevant to GTM engineering work

Go-to-market engineering is largely about wiring tools together: pulling lead and
company data, enriching it, pushing it into a CRM, and reporting on it. Claude
Code is a strong base for that because it can talk to those tools directly through
"MCP servers" (think of them as plug-in connectors to apps you already use).

You don't install these now. When you're ready, you add the ones you actually use,
each with your own login. The ones most relevant to GTM:

- **Clay** and **Apollo** — lead and company data, finding and enriching contacts.
- **HubSpot** — reading and updating your CRM (contacts, companies, deals).
- **Airtable** and **Google Sheets** — where a lot of GTM data actually lives.
- **Notion** — docs, wikis, project tracking.
- **Gmail**, **Google Calendar**, **Slack** — outreach, scheduling, comms.

The pattern that makes you a GTM engineer rather than just a tool user: chain
these together. "Find 50 companies matching this profile in Apollo, enrich the
contacts, dedupe against what's already in HubSpot, draft an outreach line for
each, and drop the lot in a Google Sheet for me to review." Claude can orchestrate
that once the connectors are in. Start with one (Google Sheets or Notion is the
gentlest), get comfortable, then add more.

When you want to add one, the command is roughly `/plugin` or you paste an MCP
config into `settings.json` like the structure already there. Ping me and I'll
walk you through your first one.

---

## Your first day actually using it

Setup done, now the point is to *live in it*. Open Warp, type `claude`, and start
giving it real work. A gentle path to get comfortable, in order:

1. **Just talk to it.** Ask it to explain something, summarise a document, or
   rewrite an email. Get a feel for the back-and-forth. This is the warm-up.

2. **Let it touch files.** Make a folder, drop a few notes or a spreadsheet export
   in it, and ask: *"Read everything in this folder and tell me what's here."*
   Watch it actually open and reason over your files. That's the lightbulb moment.

3. **Use a skill.** Try *"Use deckadence to build me a short deck about [anything]"*
   or *"Graphify these notes."* See it produce something real, not just chat.

4. **Open a second session.** Run `~/.claude/bin/cc-warp` to spin up another Claude
   in a new Warp tab. Now you can have two things going at once. This is where it
   starts to feel like a team rather than a chatbot.

5. **Connect a tool.** When you're ready, wire in your first MCP (Google Sheets or
   Notion is gentlest). See **SKILLS-AND-MCPS.md** in this pack for the how and the
   GTM-engineering thinking behind it.

The fastest way to learn all of this is to use it for actual work you'd be doing
anyway, and to break things without worrying. You can't damage anything that a
re-copy of these files won't fix.

For the deeper dive on skills and connectors, read **SKILLS-AND-MCPS.md**.

---

## A couple of things deliberately left out

- I dropped my own connectors (my messaging, my CRM tools, my domains). Those are
  tied to my accounts. You add your own as above.
- There's also an image-generator skill I use, but it needs a paid OpenAI API key
  to work, so I left it out. Easy to add later if you want it.
- Any API keys or logins are personal. Never copy someone else's, generate your
  own when a tool asks for one.

Anything unclear, just ask. The best way to learn this is to break it and fix it.
