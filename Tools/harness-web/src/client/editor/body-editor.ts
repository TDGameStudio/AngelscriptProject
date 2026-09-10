import { Crepe } from '@milkdown/crepe';
import { remarkStringifyOptionsCtx, editorViewOptionsCtx } from '@milkdown/kit/core';
import { imageBlockSchema } from '@milkdown/kit/component/image-block';

let diagramId = 0;
export function resolveDocumentLink(documentPath: string, href: string): string | null {
  if (/^(?:[a-z][\w+.-]*:|\/\/)/i.test(href)) return null;
  try {
    const resolved = new URL(
      href.replace(/\\/g, '/'),
      `http://workspace.local/${documentPath.replace(/\\/g, '/')}`,
    );
    return decodeURIComponent(resolved.pathname).replace(/^\//, '');
  } catch {
    return null;
  }
}
export function imageDisplayUrl(documentPath: string, href: string): string {
  const path = resolveDocumentLink(documentPath, href);
  return path
    ? `/api/image?path=${encodeURIComponent(path)}`
    : 'data:image/gif;base64,R0lGODlhAQABAAD/ACwAAAAAAQABAAACADs=';
}
export async function renderMermaidPreview(source: string): Promise<HTMLElement> {
  const element = document.createElement('div');
  element.className = 'editor-mermaid';
  try {
    const { default: mermaid } = await import('mermaid');
    mermaid.initialize({
      startOnLoad: false,
      securityLevel: 'strict',
      theme: 'neutral',
      suppressErrorRendering: true,
    });
    const result = await mermaid.render(`harness-diagram-${++diagramId}`, source);
    // Mermaid's strict renderer sanitizes SVG and disables click callbacks / executable HTML.
    element.innerHTML = result.svg;
    element.setAttribute('aria-label', 'Mermaid 图表');
  } catch {
    element.setAttribute('role', 'status');
    element.classList.add('editor-mermaid-error');
    element.textContent = '图表语法尚未完成；编辑此代码块后会自动更新预览。';
  }
  return element;
}

/** One ordinary body segment; source-envelope boundaries are never inside this editor. */
export async function createBodyEditor(
  root: HTMLElement,
  markdown: string,
  onChange: (markdown: string) => void,
  readonly: boolean,
  documentPath = '',
): Promise<Crepe> {
  const rejectUpload = async () => {
    let message = root.querySelector('.editor-upload-message');
    if (!message) {
      message = document.createElement('p');
      message.className = 'editor-upload-message editor-message';
      message.setAttribute('role', 'status');
      root.prepend(message);
    }
    message.textContent = '这里只引用仓库中已有的图片，请输入相对路径；文件上传不会写入文档。';
    return '';
  };
  const crepe = new Crepe({
    root,
    defaultValue: markdown,
    features: { [Crepe.Feature.Latex]: false, [Crepe.Feature.AI]: false },
    featureConfigs: {
      [Crepe.Feature.ImageBlock]: {
        proxyDomURL: (url) => imageDisplayUrl(documentPath, url),
        onUpload: rejectUpload,
        inlineUploadButton: '仅支持图片路径',
        blockUploadButton: '仅支持图片路径',
        inlineUploadPlaceholderText: '输入仓库内相对图片路径',
        blockUploadPlaceholderText: '输入仓库内相对图片路径',
        blockConfirmButton: '引用图片',
      },
      [Crepe.Feature.Placeholder]: { text: '开始书写，输入 / 插入内容…' },
      [Crepe.Feature.CodeMirror]: {
        searchPlaceholder: '选择代码语言',
        noResultText: '未找到语言',
        copyText: '复制',
        previewLabel: '图表预览',
        previewOnlyByDefault: true,
        renderPreview: (language, content, applyPreview) => {
          if (language.toLowerCase() !== 'mermaid') return null;
          void renderMermaidPreview(content).then(applyPreview);
        },
      },
      [Crepe.Feature.BlockEdit]: {
        textGroup: {
          label: '文字',
          text: { label: '正文' },
          h1: { label: '一级标题' },
          h2: { label: '二级标题' },
          h3: { label: '三级标题' },
        },
        listGroup: {
          label: '列表',
          bulletList: { label: '项目列表' },
          orderedList: { label: '有序列表' },
          taskList: { label: '待办列表' },
        },
        advancedGroup: {
          label: '插入',
          codeBlock: { label: '代码 / Mermaid' },
          table: { label: '表格' },
          image: { label: '图片链接' },
          math: null,
        },
      },
    },
  });
  crepe.editor.config((ctx) => {
    // Crepe uses Markdown alt text for a resize ratio. Repository Markdown must retain its actual alt text.
    ctx.update(imageBlockSchema.key, (previous) => (context) => {
      const schema = previous(context);
      return {
        ...schema,
        attrs: { ...schema.attrs, alt: { default: '' } },
        parseMarkdown: {
          ...schema.parseMarkdown,
          runner: (state, node, type) =>
            state.addNode(type, { src: node.url, caption: node.title ?? '', ratio: 1, alt: node.alt ?? '' }),
        },
        toMarkdown: {
          ...schema.toMarkdown,
          runner: (state, node) => {
            state.openNode('paragraph');
            state.addNode('image', undefined, undefined, {
              title: node.attrs.caption || null,
              url: node.attrs.src,
              alt: node.attrs.alt,
            });
            state.closeNode();
          },
        },
      };
    });
    ctx.update(remarkStringifyOptionsCtx, (options) => ({
      ...options,
      bullet: '-' as const,
      listItemIndent: 'one' as const,
      fences: true,
    }));
    ctx.update(editorViewOptionsCtx, (options) => ({
      ...options,
      attributes: { ...options.attributes, 'aria-label': '文档正文', spellcheck: 'false' },
    }));
  });
  let ready = false;
  let initial = '';
  crepe.on((listener) =>
    listener.markdownUpdated((_ctx, next) => {
      if (ready) onChange(next === initial ? markdown : next);
    }),
  );
  crepe.setReadonly(readonly);
  await crepe.create();
  initial = crepe.getMarkdown();
  ready = true;
  return crepe;
}
