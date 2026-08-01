import { readFile, writeFile } from "node:fs/promises";
import path from "node:path";

const projectRoot = process.cwd();
const researchRoot = path.join(
  projectRoot,
  "openspec",
  "changes",
  "docs-wiki-content-and-expression-overhaul",
  "research",
  "code-explanation",
);
const captureRoot =
  process.env.CODE_EXPLANATION_CAPTURE_ROOT ??
  path.join(
    process.env.TEMP ?? projectRoot,
    "codex-code-explanation-references-20260730",
  );

const references = [
  {
    id: "unreal-directive",
    number: "01",
    title: "Unreal Directive · Enhanced Input",
    family: "端口与状态线",
    url: "https://unrealdirective.com/articles/enhanced-input-what-you-need-to-know/",
    image: "unreal-directive.webp",
    summary: "以 Blueprint 端口、执行线和数据线建立强方向感，是本轮“连接层级”的视觉上限。",
    strengths: [
      "端口足够小，却能立即说明信号从哪里进入或离开。",
      "线宽、颜色和汇合关系可在不增加文字的情况下表达状态。",
    ],
    limitations: [
      "大型节点和高对比连线会压过源码，不能直接移植为源码注解。",
    ],
    adoption:
      "采纳端口尺寸、线宽和颜色层级；注解端口会更小、连接线更淡，不使用 Blueprint 节点卡片。",
  },
  {
    id: "explainshell",
    number: "02",
    title: "ExplainShell",
    family: "细正交连接",
    url: "https://explainshell.com/explain?cmd=git%20log%20--graph%20--abbrev-commit%20--pretty%3Doneline%20origin..mybranch",
    image: "explainshell.webp",
    summary: "保持命令文本连续，再由细线把每个参数接到独立解释，是与本轮最接近的物理连接参考。",
    strengths: [
      "源命令没有被解释卡拆散，片段仍保持原始顺序。",
      "小圆端点和低对比正交线能表达跨距离、多对多关系。",
    ],
    limitations: [
      "解释一多就容易形成电路板式噪声，固定宽度布局也不适合直接缩到手机。",
    ],
    adoption:
      "09、11 使用更短的 CSS 折线；10、12 使用 SVG。静止状态降低对比度，只在关联项激活时增强。",
  },
  {
    id: "backbone",
    number: "03",
    title: "Backbone.js Annotated Source",
    family: "纵向对齐双栏",
    url: "https://backbonejs.org/docs/backbone.html",
    image: "backbone.webp",
    summary: "经典 annotated source 把解说和源码长期并排，优点和本轮要避免的问题都非常明确。",
    strengths: [
      "解释默认全部可见，适合连续阅读一个完整库。",
      "长段落和长代码块能通过纵向位置建立可靠对应。",
    ],
    limitations: [
      "50/50 双栏会压缩源码，解释与源码成为两个竞争主体。",
    ],
    adoption:
      "只保留“纵向接近”原则，不保留固定对半双栏；侧轨最多只是一条窄边注区。",
  },
  {
    id: "github",
    number: "04",
    title: "GitHub Pull Request Comments",
    family: "单行与多行范围",
    url: "https://docs.github.com/en/pull-requests/how-tos/review-pull-requests/commenting-on-a-pull-request",
    image: "github.webp",
    summary: "成熟的 gutter 入口和连续行范围选择，为源码注解提供了最清楚的定位语义。",
    strengths: [
      "单行与连续多行共用一套选择模型，范围边界容易理解。",
      "评论入口藏在行号附近，默认不会污染源码字符。",
    ],
    limitations: [
      "展开评论卡会插入 diff 流并推动后续源码，破坏稳定行几何。",
    ],
    adoption:
      "采纳行号外缘入口和范围语义；详情改成覆盖式浮层，绝不插入源码行之间。",
  },
  {
    id: "quarto",
    number: "05",
    title: "Quarto Code Annotations",
    family: "双端编号匹配",
    url: "https://quarto.org/docs/authoring/code-annotation.html",
    image: "quarto.webp",
    summary: "代码侧编号和解释编号互相匹配，点击后才突出对应行，静止状态十分克制。",
    strengths: [
      "源码保持连续，编号本身足以维持稳定映射。",
      "点击解释时才突出单行或多行范围，默认页面噪声低。",
    ],
    limitations: [
      "解释统一放在代码下方时，长代码会产生明显的视线往返。",
    ],
    adoption:
      "所有实验使用稳定短编号，并在 hover、focus 或 pinned 时同步增强源范围、端口、线和注解。",
  },
  {
    id: "tufte",
    number: "06",
    title: "Tufte CSS Sidenotes",
    family: "低对比边注",
    url: "https://edwardtufte.github.io/tufte-css/#sidenotes",
    image: "tufte.webp",
    summary: "最成熟的“主阅读流不动、辅助信息留在页边”方案，直接影响本轮注解的视觉主次。",
    strengths: [
      "边注靠近引用点，又通过字号、行宽和颜色主动退到第二层。",
      "主阅读流稳定，读者不必跳到页底再寻找脚注。",
    ],
    limitations: [
      "其窄屏策略会把边注折回正文或切换显示，与本轮锁定的横向画布不同。",
    ],
    adoption:
      "采纳 margin note 的密度和低对比层级；窄屏仍按本轮约束在组件内部横向滚动。",
  },
  {
    id: "material",
    number: "07",
    title: "Material for MkDocs Code Annotations",
    family: "轻标记与按需详情",
    url: "https://squidfunk.github.io/mkdocs-material/reference/code-blocks/#code-annotations",
    image: "material.webp",
    summary: "小型 marker 常驻，完整富文本解释通过点击或聚焦出现，信息密度控制得很好。",
    strengths: [
      "默认只留下很小的标记，细节不会持续抢占页面。",
      "点击、触摸和键盘都能进入完整解释，交互路径成熟。",
    ],
    limitations: [
      "作者语法常把编号写进源码注释，本轮不能让演示标记进入真实源码。",
    ],
    adoption:
      "采纳“短摘要常驻、详情按需出现”；marker 和 details 均放在源码容器外。",
  },
  {
    id: "code-hike",
    number: "08",
    title: "Code Hike Footnotes",
    family: "代码脚注",
    url: "https://codehike.org/docs/code/footnotes",
    image: "code-hike.webp",
    summary: "双端编号让源码和解释保持稳定映射，同时复制代码时不会混入脚注内容。",
    strengths: [
      "源码保持完整，编号不会改变源字符。",
      "解释默认可扫描，适合教程和逐段讲解。",
    ],
    limitations: [
      "所有解释都放在代码下方，局部注解失去“就在附近”的感觉。",
    ],
    adoption:
      "采纳稳定的双端标识；把短注解移动到源码外缘或窄侧轨，而不是统一下置。",
  },
  {
    id: "expressive-code",
    number: "09",
    title: "Expressive Code Text Markers",
    family: "行与词元范围",
    url: "https://expressive-code.com/key-features/text-markers/",
    image: "expressive-code.webp",
    summary: "清楚区分整行、连续范围和词元标记，适合作为激活时的局部源范围反馈。",
    strengths: [
      "行、范围和词元都有一致且克制的视觉语法。",
      "底色和边框不改动代码字符，可作为瞬时阅读辅助。",
    ],
    limitations: [
      "它擅长标记而非承载完整原理解释，标签过多时仍会重叠。",
    ],
    adoption:
      "只在关联项激活时显示淡范围底色；解释文本仍留在外部 note 中。",
  },
  {
    id: "twoslash",
    number: "10",
    title: "Shiki Twoslash",
    family: "语义悬停",
    url: "https://shiki.style/packages/twoslash",
    image: "twoslash.webp",
    summary: "把类型、错误和符号说明绑定到精确语义对象，并在静止时保持界面安静。",
    strengths: [
      "解释与具体符号精确绑定，读者可按需取用信息。",
      "默认页面几乎不增加噪声，适合高密度源码。",
    ],
    limitations: [
      "面向 TypeScript；只靠 hover 也不能覆盖触摸和键盘使用者。",
    ],
    adoption:
      "采纳悬停预览，同时补齐 focus、Enter 固定和 Escape 关闭，确保鼠标不是唯一入口。",
  },
];

function escapeHtml(value) {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

const hydrated = [];
for (const reference of references) {
  const screenshot = await readFile(path.join(captureRoot, reference.image));
  hydrated.push({
    ...reference,
    dataUri: `data:image/webp;base64,${screenshot.toString("base64")}`,
  });
}

const cards = hydrated
  .map(
    (reference) => `
      <article class="reference-card" data-reference-id="${reference.id}">
        <div class="capture-shell">
          <div class="capture-heading">
            <span class="capture-index">${reference.number}</span>
            <span>${escapeHtml(reference.family)}</span>
          </div>
          <button class="capture-button" type="button" data-action="enlarge" aria-label="放大 ${escapeHtml(reference.title)} 截图">
            <img src="${reference.dataUri}" alt="${escapeHtml(reference.title)} 页面研究截图" loading="lazy" decoding="async">
            <span class="zoom-hint" aria-hidden="true">放大查看 ↗</span>
          </button>
        </div>
        <div class="reference-copy">
          <p class="eyebrow">REFERENCE ${reference.number}</p>
          <h2>${escapeHtml(reference.title)}</h2>
          <p class="summary">${escapeHtml(reference.summary)}</p>
          <div class="evaluation-grid">
            <section data-strengths>
              <h3>值得保留</h3>
              <ul>${reference.strengths.map((item) => `<li>${escapeHtml(item)}</li>`).join("")}</ul>
            </section>
            <section data-limitations>
              <h3>不能照搬</h3>
              <ul>${reference.limitations.map((item) => `<li>${escapeHtml(item)}</li>`).join("")}</ul>
            </section>
          </div>
          <section class="adoption" data-adoption>
            <span>09–13 的采纳结论</span>
            <p>${escapeHtml(reference.adoption)}</p>
          </section>
          <a class="source-link" data-source-link href="${reference.url}" target="_blank" rel="noreferrer">
            查看原始参考 <span aria-hidden="true">↗</span>
          </a>
        </div>
      </article>`,
  )
  .join("");

const html = `<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="color-scheme" content="light">
  <title>源码解释展示参考画廊</title>
  <style>
    :root {
      --paper: #f1efe8;
      --paper-raised: #faf8f2;
      --ink: #172129;
      --muted: #667078;
      --line: #d7d4ca;
      --accent: #da5a3a;
      --accent-soft: #f4ded5;
      --moss: #3d6f66;
      --dark: #152028;
      --shadow: 0 18px 55px rgba(32, 39, 43, .09);
    }

    * { box-sizing: border-box; }
    html { background: var(--paper); }
    body {
      margin: 0;
      min-width: 0;
      overflow-x: hidden;
      color: var(--ink);
      background:
        radial-gradient(circle at 86% 2%, rgba(218, 90, 58, .12), transparent 24rem),
        var(--paper);
      font-family: "Segoe UI", "Microsoft YaHei UI", sans-serif;
    }

    button, a { font: inherit; }
    a { color: inherit; }

    .masthead {
      color: #f8f4ea;
      background:
        linear-gradient(110deg, rgba(255, 255, 255, .045) 1px, transparent 1px) 0 0 / 28px 28px,
        var(--dark);
      border-bottom: 4px solid var(--accent);
    }

    .masthead-inner,
    main,
    .footer-inner {
      width: min(1160px, calc(100% - 40px));
      margin-inline: auto;
    }

    .masthead-inner {
      display: grid;
      grid-template-columns: minmax(0, 1.5fr) minmax(260px, .65fr);
      gap: 54px;
      align-items: end;
      padding: 76px 0 62px;
    }

    .kicker,
    .eyebrow {
      margin: 0 0 12px;
      color: #e87558;
      font-size: 12px;
      font-weight: 800;
      letter-spacing: .15em;
      text-transform: uppercase;
    }

    h1 {
      max-width: 760px;
      margin: 0;
      font-family: Georgia, "Noto Serif SC", serif;
      font-size: clamp(42px, 7vw, 82px);
      font-weight: 500;
      letter-spacing: -.045em;
      line-height: .98;
    }

    .lede {
      max-width: 720px;
      margin: 28px 0 0;
      color: #bdc5c8;
      font-size: 18px;
      line-height: 1.75;
    }

    .thesis {
      padding: 24px;
      border: 1px solid rgba(255, 255, 255, .14);
      border-top-color: #e87558;
      background: rgba(255, 255, 255, .04);
    }

    .thesis span {
      display: block;
      color: #e87558;
      font-size: 11px;
      font-weight: 800;
      letter-spacing: .14em;
    }

    .thesis p {
      margin: 12px 0 0;
      color: #eef1ee;
      font-family: Georgia, "Noto Serif SC", serif;
      font-size: 18px;
      line-height: 1.65;
    }

    main { padding: 58px 0 90px; }

    .adoption-strip {
      display: grid;
      grid-template-columns: repeat(4, minmax(0, 1fr));
      border: 1px solid var(--line);
      background: rgba(250, 248, 242, .8);
      box-shadow: var(--shadow);
    }

    .adoption-strip section {
      min-width: 0;
      padding: 22px;
      border-right: 1px solid var(--line);
    }

    .adoption-strip section:last-child { border-right: 0; }
    .adoption-strip b {
      display: block;
      color: var(--accent);
      font-family: Georgia, serif;
      font-size: 26px;
      font-weight: 500;
    }
    .adoption-strip span {
      display: block;
      margin-top: 7px;
      color: var(--muted);
      font-size: 13px;
      line-height: 1.5;
    }

    .section-heading {
      display: flex;
      gap: 20px;
      align-items: baseline;
      justify-content: space-between;
      margin: 66px 0 24px;
      padding-bottom: 15px;
      border-bottom: 1px solid var(--line);
    }

    .section-heading h2 {
      margin: 0;
      font-family: Georgia, "Noto Serif SC", serif;
      font-size: 31px;
      font-weight: 500;
    }

    .section-heading p {
      margin: 0;
      color: var(--muted);
      font-size: 13px;
    }

    .gallery { display: grid; gap: 26px; }

    .reference-card {
      display: grid;
      grid-template-columns: minmax(0, .92fr) minmax(0, 1.08fr);
      min-width: 0;
      overflow: hidden;
      border: 1px solid var(--line);
      background: var(--paper-raised);
      box-shadow: 0 8px 30px rgba(32, 39, 43, .055);
    }

    .capture-shell {
      min-width: 0;
      padding: 15px;
      color: #dfe6e2;
      background: #202b31;
    }

    .capture-heading {
      display: flex;
      align-items: center;
      justify-content: space-between;
      min-height: 36px;
      margin-bottom: 12px;
      color: #aab5b8;
      font-size: 11px;
      font-weight: 700;
      letter-spacing: .1em;
      text-transform: uppercase;
    }

    .capture-index {
      color: #f2a18c;
      font-family: Georgia, serif;
      font-size: 20px;
      font-weight: 400;
    }

    .capture-button {
      position: relative;
      display: block;
      width: 100%;
      min-width: 0;
      padding: 0;
      overflow: hidden;
      cursor: zoom-in;
      border: 1px solid rgba(255, 255, 255, .12);
      background: #11181d;
    }

    .capture-button img {
      display: block;
      width: 100%;
      aspect-ratio: 3 / 2;
      object-fit: cover;
      object-position: center top;
      opacity: .92;
      transition: transform 180ms ease, opacity 180ms ease;
    }

    .capture-button:hover img,
    .capture-button:focus-visible img {
      opacity: 1;
      transform: scale(1.018);
    }

    .capture-button:focus-visible {
      outline: 3px solid #f2a18c;
      outline-offset: 3px;
    }

    .zoom-hint {
      position: absolute;
      right: 10px;
      bottom: 10px;
      padding: 6px 9px;
      color: #fff;
      border: 1px solid rgba(255, 255, 255, .24);
      background: rgba(10, 16, 20, .82);
      font-size: 11px;
    }

    .reference-copy {
      min-width: 0;
      padding: 31px 34px 29px;
    }

    .reference-copy h2 {
      margin: 0;
      font-family: Georgia, "Noto Serif SC", serif;
      font-size: 29px;
      font-weight: 500;
      letter-spacing: -.02em;
    }

    .summary {
      margin: 14px 0 23px;
      color: #505c62;
      font-size: 15px;
      line-height: 1.75;
    }

    .evaluation-grid {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 23px;
    }

    .evaluation-grid section { min-width: 0; }
    .evaluation-grid h3 {
      margin: 0 0 9px;
      color: var(--moss);
      font-size: 12px;
      letter-spacing: .08em;
    }

    .evaluation-grid section:nth-child(2) h3 { color: #9a5b4a; }
    .evaluation-grid ul {
      margin: 0;
      padding-left: 18px;
      color: #536067;
      font-size: 13px;
      line-height: 1.65;
    }

    .evaluation-grid li + li { margin-top: 5px; }

    .adoption {
      margin-top: 23px;
      padding: 15px 17px;
      border-left: 3px solid var(--accent);
      background: var(--accent-soft);
    }

    .adoption span {
      color: #8b422f;
      font-size: 10px;
      font-weight: 800;
      letter-spacing: .1em;
    }

    .adoption p {
      margin: 6px 0 0;
      color: #583c33;
      font-size: 13px;
      line-height: 1.6;
    }

    .source-link {
      display: inline-flex;
      gap: 8px;
      align-items: center;
      margin-top: 20px;
      color: #384b52;
      font-size: 12px;
      font-weight: 700;
      text-decoration-thickness: 1px;
      text-underline-offset: 4px;
    }

    .closing-note {
      display: grid;
      grid-template-columns: 190px minmax(0, 1fr);
      gap: 34px;
      margin-top: 58px;
      padding: 35px;
      color: #e9eeea;
      background: var(--dark);
    }

    .closing-note b {
      color: #ef8d73;
      font-family: Georgia, serif;
      font-size: 28px;
      font-weight: 500;
    }

    .closing-note p {
      margin: 0;
      color: #bdc5c8;
      line-height: 1.8;
    }

    footer {
      color: #8d989c;
      background: #0f171c;
    }

    .footer-inner {
      display: flex;
      gap: 20px;
      justify-content: space-between;
      padding: 25px 0;
      font-size: 11px;
    }

    dialog {
      width: min(1280px, calc(100vw - 36px));
      max-height: calc(100vh - 36px);
      padding: 14px;
      overflow: auto;
      border: 1px solid #4f5b60;
      background: #10181d;
      box-shadow: 0 30px 100px rgba(0, 0, 0, .42);
    }

    dialog::backdrop { background: rgba(7, 12, 15, .82); }
    dialog img {
      display: block;
      width: 100%;
      height: auto;
      max-height: calc(100vh - 96px);
      object-fit: contain;
    }

    .dialog-close {
      position: sticky;
      z-index: 2;
      top: 0;
      float: right;
      margin: 0 0 -44px;
      padding: 8px 11px;
      color: white;
      cursor: pointer;
      border: 1px solid rgba(255, 255, 255, .3);
      background: rgba(11, 17, 21, .88);
    }

    @media (max-width: 880px) {
      .masthead-inner { grid-template-columns: 1fr; gap: 34px; }
      .adoption-strip { grid-template-columns: repeat(2, minmax(0, 1fr)); }
      .adoption-strip section:nth-child(2) { border-right: 0; }
      .adoption-strip section:nth-child(-n+2) { border-bottom: 1px solid var(--line); }
      .reference-card { grid-template-columns: 1fr; }
      .capture-button img { aspect-ratio: 16 / 9; }
    }

    @media (max-width: 560px) {
      .masthead-inner,
      main,
      .footer-inner { width: min(100% - 24px, 1160px); }
      .masthead-inner { padding: 50px 0 42px; }
      h1 { font-size: 44px; }
      .lede { font-size: 16px; }
      main { padding-top: 34px; }
      .adoption-strip { grid-template-columns: 1fr; }
      .adoption-strip section {
        border-right: 0;
        border-bottom: 1px solid var(--line);
      }
      .adoption-strip section:last-child { border-bottom: 0; }
      .section-heading { display: block; }
      .section-heading p { margin-top: 8px; }
      .capture-shell { padding: 10px; }
      .reference-copy { padding: 25px 20px; }
      .evaluation-grid { grid-template-columns: 1fr; }
      .closing-note { grid-template-columns: 1fr; padding: 25px; }
      .footer-inner { display: block; }
      .footer-inner span { display: block; margin-top: 6px; }
    }

    @media (prefers-reduced-motion: reduce) {
      *, *::before, *::after {
        scroll-behavior: auto !important;
        transition-duration: .01ms !important;
      }
    }
  </style>
</head>
<body>
  <header class="masthead">
    <div class="masthead-inner">
      <div>
        <p class="kicker">CODE EXPLANATION / REFERENCE GALLERY</p>
        <h1>不拆开源码，解释还能放在哪里？</h1>
        <p class="lede">10 个真实参考的截图研究。目标不是找到一个可直接复制的模板，而是拆出适合 AngelScript 与 C++ 的定位、连接、主次和交互语法。</p>
      </div>
      <aside class="thesis">
        <span>本轮判断</span>
        <p>源码保持连续；短注解常驻；完整解释按需出现；连接线只负责定位，不成为画面主角。</p>
      </aside>
    </div>
  </header>

  <main>
    <div class="adoption-strip" aria-label="最终采纳的四个设计原则">
      <section><b>01</b><span>Tufte 的边注主次：解释靠近，但主动后退。</span></section>
      <section><b>02</b><span>GitHub 的范围语义：单行和连续多行共用模型。</span></section>
      <section><b>03</b><span>Quarto 的双端匹配：编号与激活范围彼此确认。</span></section>
      <section><b>04</b><span>ExplainShell 的细连接：小端口、短路径、低对比。</span></section>
    </div>

    <div class="section-heading">
      <h2>逐项拆解</h2>
      <p>截图采集于 2026-07-30 · 点击截图可离线放大</p>
    </div>

    <div class="gallery">
${cards}
    </div>

    <aside class="closing-note">
      <b>窄屏例外</b>
      <p>Tufte 等参考通常在手机上把边注折回正文。本轮实验遵循已经确认的约束：390px 下仍保留完整桌面式注解画布，横向滚动只发生在组件内部，页面本身不会横向溢出。这样能验证源码排版在任何视口都不被改写。</p>
    </aside>
  </main>

  <footer>
    <div class="footer-inner">
      <strong>OpenSpec · docs-wiki-content-and-expression-overhaul</strong>
      <span>Research artifact · screenshots are limited, compressed references with direct source links</span>
    </div>
  </footer>

  <dialog aria-label="参考截图放大预览">
    <button class="dialog-close" type="button">关闭 ×</button>
    <img alt="">
  </dialog>

  <script>
    (() => {
      const dialog = document.querySelector("dialog");
      const dialogImage = dialog.querySelector("img");

      document.addEventListener("click", (event) => {
        const enlarge = event.target.closest('[data-action="enlarge"]');
        if (enlarge) {
          const sourceImage = enlarge.querySelector("img");
          dialogImage.src = sourceImage.src;
          dialogImage.alt = sourceImage.alt + "（放大）";
          dialog.showModal();
          return;
        }

        if (event.target.closest(".dialog-close")) {
          dialog.close();
        }
      });

      dialog.addEventListener("click", (event) => {
        if (event.target === dialog) {
          dialog.close();
        }
      });

      function audit() {
        const cards = [...document.querySelectorAll("[data-reference-id]")];
        const errors = [];
        if (cards.length !== 10) errors.push("reference-count");

        for (const card of cards) {
          const image = card.querySelector('img[src^="data:image/webp;base64,"]');
          const source = card.querySelector('a[data-source-link][href^="https://"]');
          const strengths = card.querySelectorAll("[data-strengths] li");
          const limitations = card.querySelectorAll("[data-limitations] li");
          const adoption = card.querySelector("[data-adoption]");
          if (!image) errors.push(card.dataset.referenceId + ":webp");
          if (!source) errors.push(card.dataset.referenceId + ":source");
          if (strengths.length < 2) errors.push(card.dataset.referenceId + ":strengths");
          if (limitations.length < 1) errors.push(card.dataset.referenceId + ":limitations");
          if (!adoption?.textContent.trim()) errors.push(card.dataset.referenceId + ":adoption");
        }

        return { referenceCount: cards.length, errors };
      }

      window.__REFERENCE_GALLERY__ = { audit };
    })();
  </script>
</body>
</html>
`;

const outputPath = path.join(researchRoot, "reference-gallery.html");
await writeFile(outputPath, html, "utf8");
console.log(`wrote ${outputPath}`);
