## Why

The Wiki currently keeps a Vanilla-specific sidebar layout override in `wiki/tiddlers/system/`, which makes a reusable Angelscript theme harder to publish and install independently. The theme needs a package boundary now so Wiki styling and theme-owned configuration travel together with the plugin release.

## What Changes

- Add an independently buildable `$:/themes/angelscript` theme plugin under `Wiki/src/angelscript-theme/`.
- Derive from `$:/themes/tiddlywiki/vanilla` so the existing page template and sidebar segments remain stable.
- Move the Vanilla-compatible sidebar layout value into the theme package and remove the duplicate Wiki system tiddler.
- Add Angelscript visual styling and theme-owned palette/configuration tiddlers inside the theme package.
- Add a regular `$:/plugins/TDGameStudio/angelscript-wiki-config` plugin that packages stable Wiki defaults and startup behavior as shadow tiddlers so the Wiki system folder does not accumulate `$__` configuration files.
- Select the Angelscript theme as the default for the development Wiki while keeping the plugin independently installable.
- Verify the theme is included in plugin builds and online/offline Wiki publishing outputs.

## Capabilities

### New Capabilities

- `angelscript-wiki-theme`: A standalone TiddlyWiki theme plugin with packaged styles, compatibility settings, default Wiki activation, and publishable artifacts.

### Modified Capabilities

None.

## Impact

- `Wiki/` submodule source, Wiki tiddlers, and generated `dist/` artifacts.
- Parent repository OpenSpec records and the `Wiki` gitlink after the submodule change is committed separately.
- No Unreal Engine modules, AngelScript runtime APIs, or existing Wiki tools are changed.
