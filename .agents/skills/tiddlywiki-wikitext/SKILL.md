---
name: tiddlywiki-wikitext
description: Use when creating, editing, converting, or reviewing TiddlyWiki 5/TW5 tiddlers, TiddlyWiki WikiText, filters, widgets, transclusion, macros, procedures, tables, links, code blocks, or TiddlyWiki notes. Use official TiddlyWiki 5 syntax, not MediaWiki wikitext.
metadata:
  short-description: Write accurate TiddlyWiki 5 WikiText
---

# TiddlyWiki WikiText

## Scope

Use this skill for TiddlyWiki 5 WikiText only. Do not assume MediaWiki, GitHub Markdown, or other wiki syntaxes are valid in TiddlyWiki.

When exact syntax matters, consult official TiddlyWiki documentation before answering. Start with `references/official-links.md`, and prefer `https://tiddlywiki.com/static/...` pages as the source of truth.

Default to producing copy-pasteable tiddler body text unless the user asks for JSON, `.tid` fields, import/export format, or plugin/system tiddlers.

## Common Patterns

- Internal link: `[[Tiddler Title]]`
- Aliased internal link: `[[Displayed Link Title|Tiddler Title]]`
- External URL: `https://tiddlywiki.com/`
- Aliased external URL: `[[TW5|https://tiddlywiki.com/]]`
- Forced/relative external link: `[ext[Label|./relative/path]]`
- Transclude tiddler: `{{Tiddler Title}}`
- Transclude field: `{{Tiddler Title!!field}}`
- Transclude current tiddler field: `{{!!field}}`
- Filtered transclusion: `{{{ [tag[Some Tag]] }}}`
- Heading levels: `!`, `!!`, `!!!`
- Bold: `''bold text''`
- Italic: `//italic text//`
- Underline: `__underlined text__`
- Inline code: `` `code` ``
- Code block: triple backticks at the start of a line, immediately followed by a line break.
- Table header cells: prefix cell text with `!`, for example `|!Name |!Value |`

## Output Rules

- Avoid Markdown-only conveniences unless TiddlyWiki supports them.
- Keep local file links explicit. Use a URL form such as `file:///Users/name/path/file.jsonl` or `[ext[Label|file:///Users/name/path/file.jsonl]]` when the user wants a filesystem link.
- If using widgets, prefer clear widget syntax over clever shortcuts for dynamic behavior.
- For dynamic links, avoid trying to expand variables inside shortcut link syntax; use `<$link>` with dynamic attributes instead.
- For notes intended for a personal wiki, include a compact title suggestion and tags only if useful.

## Verification

Before presenting non-trivial WikiText, sanity-check:

- Is this TW5 syntax, not MediaWiki syntax?
- Are code blocks separated from preceding paragraphs by a blank line?
- Are local file paths represented as valid URLs when used as links?
- Do links with dynamic targets need widget syntax?
- Does the answer need an official-doc check before claiming a syntax detail?
