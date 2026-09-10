import { unified } from 'unified';
import remarkParse from 'remark-parse';
import remarkGfm from 'remark-gfm';
import type { RootContent } from 'mdast';
import { slug } from './paths';

export function readingModel(content: string) {
  // Blank source lines retain original CLI/search line coordinates.
  const source = content
    .replace(/^\uFEFF/, '')
    .replace(/^---\r?\n[\s\S]*?\r?\n---(?:\r?\n|$)/, (block) =>
      '\n'.repeat((block.match(/\n/g) ?? []).length),
    );
  const tree = unified().use(remarkParse).use(remarkGfm).parse(source);
  const headings: { id: string; text: string; depth: number; line: number }[] = [];
  const counts = new Map<string, number>();
  const plain = (node: RootContent | { type: string; value?: string; children?: unknown[] }): string =>
    'value' in node && typeof node.value === 'string'
      ? node.value
      : 'children' in node && node.children
        ? node.children.map((child) => plain(child as RootContent)).join('')
        : '';
  const walk = (node: RootContent) => {
    if (node.type === 'heading') {
      const text = plain(node);
      const base = slug(text);
      const occurrence = counts.get(base) ?? 0;
      counts.set(base, occurrence + 1);
      headings.push({
        id: occurrence ? `${base}-${occurrence}` : base,
        text,
        depth: node.depth,
        line: node.position!.start.line,
      });
    }
    if ('children' in node) node.children.forEach((child) => walk(child as RootContent));
  };
  tree.children.forEach(walk);
  return { source, headings };
}
