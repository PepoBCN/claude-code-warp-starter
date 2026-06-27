# Skills and MCPs, a plain-English guide

Two things turn Claude Code from a clever chatbot into a proper work tool: **skills**
and **MCPs**. They sound technical. They're not. This explains both, what's in this
pack, and how to add more, including the connectors that matter for GTM work.

---

## The one-line version

- **A skill** = a bundle of know-how Claude already has on tap. No login, no key.
  It's just instructions and templates living in a folder. You trigger it by asking.
- **An MCP** = a connector that plugs Claude into an app you use (HubSpot, Google
  Sheets, Slack...). It needs your login. This is how Claude actually *does* things
  in your other tools instead of just talking about them.

Think of skills as Claude's built-in talents, and MCPs as the cables connecting it
to the rest of your stack.

---

## Skills included in this pack

You already have these once you've copied the `skills/` folder into `~/.claude/`.
Nothing to set up. Just ask for them in plain English.

### deckadence — animated presentations
Builds a slick, animated slideshow as a single HTML file you open in a browser.
Prezi-style movement, no PowerPoint, no setup. Good for pitch decks, one-pagers,
anything you'd normally fight Keynote over.

Try: *"Use deckadence to build me a 6-slide deck pitching [your idea]."*

### graphify — turn a mess into a map
Takes a pile of input (notes, documents, research, even a transcript) and produces
an interactive visual map of the main themes and how they connect. Great for making
sense of something sprawling before you write or present it.

Try: *"Graphify these meeting notes and show me the key themes."*

### The build helpers (for later)
There are also two commands, `/build-parallel` and `/check`, and a `code-review`
agent. These are for when you start building software across several files. Ignore
them until you get there, they'll be waiting.

---

## What skills are NOT in here (and why)

- **SEO suite** — useful, but a big bundle and not relevant to where you're starting.
- **Image generator** — needs a paid OpenAI API key to run, so it's left out. Easy
  to add later if you want it.

You can always add more skills later. A skill is just a folder with a `SKILL.md`
file inside it, dropped into `~/.claude/skills/`. People share them on GitHub.

---

## MCPs — connecting Claude to your other tools

This is the part that makes you a "GTM engineer" rather than just someone chatting
to an AI. With MCPs, Claude can read and write in the actual tools your work lives in.

**None are pre-installed in this pack** — they're tied to whoever's accounts you use,
so you add the ones you want with your own logins. Here's how to think about it.

### The GTM-relevant ones

- **Google Sheets** — where loads of GTM data actually lives. Gentlest place to start.
- **Notion** — docs, wikis, lightweight project and pipeline tracking.
- **Airtable** — structured data, a step up from Sheets.
- **HubSpot** — your CRM: contacts, companies, deals.
- **Apollo** and **Clay** — finding and enriching leads and company data.
- **Gmail, Google Calendar, Slack** — outreach, scheduling, comms.

### The move that matters

Anyone can use one tool. The GTM-engineer skill is **chaining them**. One instruction,
several tools, end to end. For example:

> "Find 50 companies matching this profile in Apollo, enrich the contacts, check
> them against what's already in HubSpot so we don't double up, draft a one-line
> opener for each, and drop the lot in a Google Sheet for me to review."

Once the connectors are in, Claude can orchestrate that whole run. That's the job.

Start with **one** connector (Google Sheets or Notion), get comfortable, then add
more as you need them. Don't bolt on ten at once.

---

## How to actually add an MCP

There are two ways. Both are simpler than they look.

### Easiest — ask Claude to do it
Just tell it: *"I want to connect my Google Sheets. Walk me through adding the MCP
and explain each step."* It'll handle the config and tell you exactly when to log in.

### By hand — paste a config block
MCPs are listed in `~/.claude/settings.json`. The structure looks like this (this
is just the shape, not a real working server):

```json
"mcpServers": {
  "notion": { "type": "http", "url": "https://mcp.notion.com/mcp" }
}
```

You add an entry per tool, then restart Claude and log in when it prompts. The
**login is where the security lives** — the config line itself holds no password.
Each provider publishes its own MCP URL and connect instructions.

A safety note: only add MCPs from tools you actually use and trust, and never paste
in someone else's account credentials. Your logins are yours.

---

## Where to find more

- Skills and MCPs get shared on GitHub all the time, search for "claude code skills"
  or "claude code mcp".
- Most big tools (Notion, HubSpot, Stripe, Linear, Slack...) now publish their own
  official MCP, that's always the one to prefer.

When you want to wire up your first connector, give me a shout and I'll do it with you.
