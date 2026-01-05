# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a Claude Code customization repository containing agents, commands (slash commands), and skills that extend Claude's capabilities for Java development with TDD discipline.

## Structure

- `agents/` - Specialized AI agents
- `commands/` - Slash commands for TDD workflow and git operations
- `skills/` - Reusable skill definitions

### Claude Commands Location

Claude commands for this project are stored in `commands/` at the project root (not `.claude/commands/`). This folder is symlinked to the global Claude config (`~/.claude/commands/`).
When creating new commands:
- Good: Create in `/commands/` at project root
- Bad: Create in `~/.claude/commands/` or `.claude/commands/`