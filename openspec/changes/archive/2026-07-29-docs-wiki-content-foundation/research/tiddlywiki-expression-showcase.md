# TiddlyWiki Expression Showcase Scope

Captured: 2026-07-25

This note extends the Showcase catalog with explicit TiddlyWiki-native authoring, HTML, and embedded-web cases. It is a plan and acceptance record only; no new showcase tiddlers or runtime code are created in this OpenSpec session.

## Why these need explicit entries

The current WikiText showcase already demonstrates one `\procedure`, transclusion, filtering, buttons, and temporary state. It does not yet teach or regression-test:

- the boundary between variables, procedures, functions, legacy macros, transclusion, and widgets;
- parameter/default/quoting behavior or nested procedure composition;
- how ordinary HTML participates in the WikiText parse tree;
- which HTML is safe for trusted documentation and which constructs must be shown only as escaped source;
- how to embed a local or external web page;
- iframe title, sandbox, referrer, loading, responsive, failure, and offline behavior;
- what happens when a remote site refuses framing through CSP or `X-Frame-Options`.

These are authoring capabilities, not theme decoration. They therefore belong in Base and Pattern, with security/policy experiments isolated in Lab.

## Catalog expansion

The catalog expands from 36 to 42 entries:

- Base: B01–B15 (15)
- Pattern: P01–P16 (16)
- Lab: L01–L11 (11)

### New Base entries

| ID | Surface group | Required examples | Stable acceptance boundary |
|---|---|---|---|
| B13 | TiddlyWiki variables, procedures, functions, and legacy macros | `\procedure` with positional/default parameters; nested invocation; `\function` producing a filter result; scoped variables through `<$let>`/`<$set>`; one clearly labelled `\define` compatibility example; invocation through `<<name ...>>` and `<$transclude $variable="...">`. | Output and scoping are deterministic; quoting/empty/default parameters are visible; examples do not persist state; preferred modern form and legacy compatibility are distinguished. |
| B14 | Trusted WikiText HTML and widget composition | Semantic HTML headings/section/details/table, attributes, classes, ARIA, TiddlyWiki widgets inside HTML, HTML inside procedure output, escaped source display, and an explicitly blocked live-script/event-handler example. | DOM is semantic and keyboard-readable; no inline script or `on*` handler executes; HTML does not break transclusion, links, narrow layout, copy, or print; the page states that authored HTML is trusted product content, not an untrusted-content sandbox. |
| B15 | Embedded local and external web content | Responsive iframe wrapper; product-owned/local static page; external URL example; `title`, `loading`, `sandbox`, `referrerpolicy`, fallback link/text, denied-frame state, unavailable/offline state, and narrow-screen behavior. | Local case works offline; external case degrades to a link/message; sandbox permissions are minimal and documented; no arbitrary external page is required for normal verification; iframe cannot overflow the article. |

### New Pattern entries

| ID | Composition group | Intended authoring use | Required contract |
|---|---|---|---|
| P15 | Parameterized WikiText documentation component | Reuse a procedure/function/transclusion composition for evidence panels, API notes, source links, or comparison rows without introducing a JS widget. | Named purpose, parameter table, defaults, escaping rules, nested-content strategy, call examples, empty/error behavior, accessible markup, and source-level tests. |
| P16 | Embedded interactive companion with static fallback | Pair a diagram, local mini-page, or allowed external tool with authoritative prose and a static/offline alternative. | The prose remains authoritative; embed origin and network behavior are visible; iframe sandbox/referrer policy is reviewed; a static image/table/link fallback exists; print and no-script states remain useful. |

### New Lab entry

| ID | Experimental group | Question | Boundary |
|---|---|---|---|
| L11 | Web-embed security and packaging policy | Which local `srcdoc`, packaged static page, sandboxed external iframe, or new-window link patterns are compatible with the single-file/offline Wiki and its publishing CSP? | Use synthetic/product-owned targets only; no credentials, cross-origin messaging, arbitrary remote script, or production dependency; graduate only after CSP, offline artifact, accessibility, and threat review. |

## Planned example shapes

These examples describe the surfaces to test. Final code must be checked in the actual Wiki runtime before it is presented as canonical.

### Procedure and function

```tiddlywiki
\procedure showcase-greeting(name:"读者")
欢迎，<<name>>。
\end

\function ordered-showcase-pages() [tag[ASWiki/Docs/showcase-lab]sort[as-order]]

<<showcase-greeting "文档作者">>

<$list filter=<<ordered-showcase-pages>> emptyMessage="暂无页面">
  <$link to=<<currentTiddler>>/>
</$list>
```

The canonical example must also show an empty parameter, a value containing spaces/quotes, nested calls, and scope through `<$let>`. A `\define` example is retained only to explain compatibility with existing tiddlers; new reusable components should use the current procedure/function forms selected by the Wiki's TiddlyWiki version.

### HTML inside WikiText

```tiddlywiki
<section class="as-doc-example" aria-labelledby="example-heading">
  <h3 id="example-heading">HTML 与 WikiText 混写</h3>
  <p>普通 HTML 可以包含 <$link to="AS/Docs">Wiki 链接</$link> 和 TW widgets。</p>
  <details>
    <summary>查看说明</summary>
    <p>这里仍然处于同一个 WikiText 解析上下文。</p>
  </details>
</section>
```

The live example must not include `<script>`, inline event handlers, unsanitized user input, or a claim that TiddlyWiki sanitizes trusted author HTML into an untrusted-content boundary. Dangerous forms are displayed only as escaped code with an explanation.

### Embedded page

```tiddlywiki
<div class="as-embed-frame">
  <iframe
    src="https://example.invalid/companion"
    title="示例伴随页面"
    loading="lazy"
    sandbox=""
    referrerpolicy="no-referrer"
  ></iframe>
</div>

无法加载时，请使用 [[独立页面|https://example.invalid/companion]]。
```

The final Base page must use a deterministic product-owned/local target instead of `example.invalid`; the invalid address above merely makes the fallback requirement explicit. If scripts, forms, downloads, popups, same-origin access, or cross-window messaging are needed, each sandbox token requires a stated reason and a separate security review.

## Security and offline rules

- Raw HTML is permitted only in repository-reviewed, trusted tiddlers.
- Never interpolate untrusted text into element names, raw attributes, `style`, URL schemes, `srcdoc`, or executable HTML.
- No live `<script>` or inline event handler appears in a Showcase page.
- External embeds are optional enhancements; article meaning, navigation, and verification cannot depend on them.
- Normal `dev`, `test`, `verify`, and `build:wiki` commands remain network-free.
- Browser tests use a local fixture or request interception, not a third-party website.
- Every iframe has a unique accessible title and visible fallback.
- Start with an empty sandbox; add only the tokens demanded by the reviewed use case.
- Do not combine `allow-scripts` and `allow-same-origin` for untrusted same-origin content.
- Record CSP, `X-Frame-Options`, mixed-content, cookie, authentication, and privacy limitations.
- The embed wrapper must handle narrow viewports, 200% zoom, print, reduced motion, and unavailable content.
- A packaged local mini-page must be covered by source-boundary and artifact-size checks and must not silently add a heavy runtime.

## Verification additions

The later implementation must add:

1. source-contract checks for B13–B15, P15–P16, and L11 IDs;
2. a deterministic procedure/function output test including parameter and scope edge cases;
3. browser checks for semantic HTML, nested widgets, keyboard operation, and escaped dangerous examples;
4. local iframe load plus denied/unavailable fallback tests;
5. assertions for `title`, `sandbox`, `loading`, `referrerpolicy`, responsive containment, and no unexpected network request;
6. offline build inspection confirming the local case remains useful and the external case is nonessential;
7. artifact-size and source-boundary checks for any packaged companion page;
8. author guidance that separates WikiText, procedures/functions, raw HTML, JS widgets, and external embeds.

## Source candidates

- current `Wiki/wiki/tiddlers/examples/WikiTextSyntaxShowcase.tid`;
- current `Wiki/wiki/tiddlers/as/navigation.tid`;
- TDGameStudio-owned procedures/functions in `Wiki/src/angelscript-tools/`;
- the pinned local TiddlyWiki/Kookma reference sources described in `AGENTS.md`;
- official TiddlyWiki 5 documentation for the exact version used by the Wiki.

Reference projects are examples, not runtime dependencies. Any copied expression must pass license, global-template, security, and product-namespace review.
