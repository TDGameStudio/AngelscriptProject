import { Children, isValidElement, useEffect, useMemo, useRef, useState, type ReactNode } from 'react';
import ReactMarkdown, { type Components } from 'react-markdown';
import remarkGfm from 'remark-gfm';
import { Link, useLocation } from 'react-router-dom';
import { List, WrapText } from 'lucide-react';
import { documentUrl, resolveDocumentLink, slug } from '../lib/paths';
import { readingModel } from '../lib/markdown';

function plainText(children: ReactNode): string {
  return Children.toArray(children)
    .map((child) =>
      typeof child === 'string' || typeof child === 'number'
        ? String(child)
        : isValidElement<{ children?: ReactNode }>(child)
          ? plainText(child.props.children)
          : '',
    )
    .join('');
}
function MermaidBlock({ source }: { source: string }) {
  const [svg, setSvg] = useState('');
  const [error, setError] = useState('');
  const id = useRef(`diagram-${Math.random().toString(36).slice(2)}`);
  useEffect(() => {
    let cancelled = false;
    setSvg('');
    setError('');
    void import('mermaid')
      .then(async ({ default: mermaid }) => {
        mermaid.initialize({
          startOnLoad: false,
          securityLevel: 'strict',
          theme: document.documentElement.dataset.theme === 'dark' ? 'dark' : 'neutral',
        });
        const result = await mermaid.render(id.current, source);
        if (!cancelled) setSvg(result.svg);
      })
      .catch(() => {
        if (!cancelled) setError('图表语法无法解析，请查看源码。');
      });
    return () => {
      cancelled = true;
    };
  }, [source]);
  return (
    <div className="mermaid-block">
      {svg ? (
        <div className="mermaid-preview" dangerouslySetInnerHTML={{ __html: svg }} />
      ) : error ? (
        <p className="inline-warning">{error}</p>
      ) : (
        <p className="muted-text">正在绘制图表…</p>
      )}
      <details>
        <summary>Mermaid 源码</summary>
        <pre>
          <code>{source}</code>
        </pre>
      </details>
    </div>
  );
}
export function MarkdownDocument({ content, path, line }: { content: string; path: string; line?: number }) {
  const [outlineOpen, setOutlineOpen] = useState(true);
  const [highlight, setHighlight] = useState<string>();
  const container = useRef<HTMLDivElement>(null);
  const location = useLocation();
  const { source, headings } = useMemo(() => readingModel(content), [content]);
  const sourceClass = (tag: string, sourceLine?: number, className?: string) =>
    [className, highlight === `${tag}:${sourceLine}` ? 'source-highlight' : undefined]
      .filter(Boolean)
      .join(' ') || undefined;
  const heading =
    (level: 1 | 2 | 3 | 4 | 5 | 6) =>
    ({ children, node }: { children?: ReactNode; node?: { position?: { start: { line: number } } } }) => {
      const entry = headings.find((item) => item.line === node?.position?.start.line);
      const Tag = `h${level}` as 'h1';
      return (
        <Tag
          id={entry?.id ?? slug(plainText(children))}
          data-line={entry?.line}
          className={sourceClass(`H${level}`, entry?.line)}
        >
          {children}
        </Tag>
      );
    };
  useEffect(() => {
    let element: Element | null | undefined;
    if (location.hash) {
      try {
        element = document.getElementById(decodeURIComponent(location.hash.slice(1)));
      } catch {
        /* Ignore malformed fragment. */
      }
    } else if (line) {
      const nodes = [...(container.current?.querySelectorAll<HTMLElement>('[data-line]') ?? [])];
      element = nodes
        .filter((node) => Number(node.dataset.line) <= line)
        .sort((a, b) => Number(b.dataset.line) - Number(a.dataset.line))[0];
    }
    setHighlight(element && line ? `${element.tagName}:${element.getAttribute('data-line')}` : undefined);
    if (element) {
      element.scrollIntoView?.({ block: 'center' });
    }
  }, [line, content, location.hash, path]);
  // Stable renderer identities keep source nodes and Mermaid previews mounted during workspace refreshes.
  const components = useMemo<Components>(
    () => ({
      h1: heading(1),
      h2: heading(2),
      h3: heading(3),
      h4: heading(4),
      h5: heading(5),
      h6: heading(6),
      p: ({ children, node, className }) => (
        <p
          data-line={node?.position?.start.line}
          className={sourceClass('P', node?.position?.start.line, className)}
        >
          {children}
        </p>
      ),
      li: ({ children, node, className }) => (
        <li
          data-line={node?.position?.start.line}
          className={sourceClass('LI', node?.position?.start.line, className)}
        >
          {children}
        </li>
      ),
      a: ({ href, children }) => {
        const local = href && resolveDocumentLink(path, href);
        return local ? (
          <Link to={`${documentUrl(local.path)}${local.hash}`}>{children}</Link>
        ) : (
          <a href={href} target={href?.startsWith('#') ? undefined : '_blank'} rel="noopener noreferrer">
            {children}
          </a>
        );
      },
      img: ({ src, alt }) => {
        if (!src) return null;
        if (/^https?:\/\//.test(src))
          return (
            <a href={src} target="_blank" rel="noopener noreferrer">
              图片：{alt || src}
            </a>
          );
        const parts = path.split('/').slice(0, -1);
        for (const part of src.split('/')) {
          if (part === '..') parts.pop();
          else if (part !== '.') parts.push(part);
        }
        return (
          <img
            src={`/api/image?path=${encodeURIComponent(parts.join('/'))}`}
            alt={alt ?? ''}
            loading="lazy"
          />
        );
      },
      pre: ({ children }) => {
        const child = Children.toArray(children)[0];
        if (
          isValidElement<{ className?: string; children?: ReactNode }>(child) &&
          child.props.className === 'language-mermaid'
        )
          return <MermaidBlock source={plainText(child.props.children)} />;
        return <pre>{children}</pre>;
      },
    }),
    [headings, path, highlight],
  );
  return (
    <div className={`markdown-layout ${outlineOpen ? '' : 'outline-closed'}`}>
      <article ref={container} className="markdown-body">
        <ReactMarkdown remarkPlugins={[remarkGfm]} skipHtml components={components}>
          {source}
        </ReactMarkdown>
      </article>
      <aside className="document-outline">
        <button
          className="outline-toggle"
          onClick={() => setOutlineOpen(!outlineOpen)}
          aria-label={outlineOpen ? '收起文档目录' : '展开文档目录'}
        >
          {outlineOpen ? <List size={15} /> : <WrapText size={15} />}
          <span>文档目录</span>
        </button>
        {outlineOpen && (
          <nav aria-label="文档目录">
            {headings.map((item) => (
              <a key={item.id} href={`#${item.id}`} style={{ paddingLeft: `${(item.depth - 1) * 10}px` }}>
                {item.text}
              </a>
            ))}
          </nav>
        )}
      </aside>
    </div>
  );
}
