import { unified } from 'unified';
import remarkParse from 'remark-parse';
import remarkGfm from 'remark-gfm';

export interface DocumentSegment {
  id: string;
  kind: 'editable' | 'protected';
  source: string;
  markdown: string;
  reason?: string;
  indent: string;
  leading: string;
  trailing: string;
}
export interface DocumentEnvelope {
  original: string;
  bom: string;
  newline: string;
  segments: DocumentSegment[];
}
interface Range {
  start: number;
  end: number;
  reason: string;
}
interface SyntaxNode {
  type: string;
  children?: SyntaxNode[];
  position?: { start: { offset?: number }; end: { offset?: number } };
}
const markdownParser = unified().use(remarkParse).use(remarkGfm);

function linesWithOffsets(source: string) {
  let offset = 0;
  return (source.match(/[^\r\n]*(?:\r\n|\r|\n|$)/g) ?? []).filter(Boolean).map((raw) => {
    const line = { raw, text: raw.replace(/[\r\n]+$/, ''), start: offset, end: offset + raw.length };
    offset += raw.length;
    return line;
  });
}

function protectedRanges(source: string): Range[] {
  const lines = linesWithOffsets(source);
  const ranges: Range[] = [];
  const code: Range[] = [];
  const tree = markdownParser.parse(source) as SyntaxNode;
  const visit = (node: SyntaxNode, paragraph?: SyntaxNode) => {
    const start = node.position?.start.offset;
    const end = node.position?.end.offset;
    if (start !== undefined && end !== undefined) {
      if (node.type === 'code') code.push({ start, end, reason: 'code' });
      if (node.type === 'html' || node.type === 'definition') {
        const a = paragraph?.position?.start.offset ?? start;
        const b = paragraph?.position?.end.offset ?? end;
        // Preserve the containing Markdown block, so inline HTML cannot split a paragraph.
        const first = lines.find((line) => line.start <= a && line.end > a);
        const last = lines.find((line) => line.start < b && line.end >= b);
        ranges.push({ start: first?.start ?? a, end: last?.end ?? b, reason: '原始语法' });
      }
    }
    node.children?.forEach((child) => visit(child, node.type === 'paragraph' ? node : paragraph));
  };
  tree.children?.forEach((node) => visit(node));
  const first = lines[0]?.text;
  if (first === '---' || first === '+++') {
    const close = lines.findIndex(
      (line, i) => i > 0 && (line.text === first || (first === '---' && line.text === '...')),
    );
    ranges.push({ start: 0, end: close >= 0 ? lines[close]!.end : source.length, reason: '文档元数据' });
  }
  for (let index = 0; index < lines.length; index++) {
    const line = lines[index]!;
    if (code.some((block) => line.start >= block.start && line.start < block.end)) continue;
    if (/^\s*[-*+] \[[ xX]\] \d+(?:\.\d+)+\b/.test(line.text)) {
      ranges.push({ start: line.start, end: line.end, reason: '任务定义 · 只读' });
    } else if (/^\s*>\s*Files\s*:/i.test(line.text)) {
      ranges.push({ start: line.start, end: line.end, reason: '文件范围 · 只读' });
    } else if (/^\s*:::[^:]/.test(line.text)) {
      let end = index + 1;
      let depth = 1;
      for (; end < lines.length; end++) {
        if (/^\s*:::[^:]/.test(lines[end]!.text)) depth++;
        if (/^\s*:::\s*$/.test(lines[end]!.text) && --depth === 0) break;
      }
      ranges.push({
        start: line.start,
        end: lines[end]?.end ?? source.length,
        reason: '扩展语法 · 原样保留',
      });
      index = end;
    }
  }
  const sorted = ranges.sort((a, b) => a.start - b.start || b.end - a.end);
  const merged: Range[] = [];
  for (const range of sorted) {
    const previous = merged.at(-1);
    if (previous && range.start < previous.end) previous.end = Math.max(previous.end, range.end);
    else merged.push({ ...range });
  }
  return merged;
}

/** A source envelope deliberately keeps protected blocks outside contenteditable. */
export function splitDocument(content: string, _path?: string): DocumentEnvelope {
  const bom = content.startsWith('\uFEFF') ? '\uFEFF' : '';
  const source = content.slice(bom.length);
  const newline = source.match(/\r\n|\r|\n/)?.[0] ?? '\n';
  const segments: DocumentSegment[] = [];
  const add = (raw: string, kind: DocumentSegment['kind'], reason?: string, indent = '') => {
    if (!raw) return;
    const normalized = raw.replace(/\r\n|\r/g, '\n');
    const leading = normalized.match(/^(?:[ \t]*\n)*/)?.[0] ?? '';
    const rest = normalized.slice(leading.length);
    const trailing = rest.match(/(?:\n[ \t]*)+$/)?.[0] ?? '';
    const core = trailing ? rest.slice(0, -trailing.length) : rest;
    const markdown = indent
      ? core
          .split('\n')
          .map((line) => (line.startsWith(indent) ? line.slice(indent.length) : line))
          .join('\n')
      : core;
    segments.push({
      id: `segment-${segments.length}`,
      kind,
      source: raw,
      markdown,
      reason,
      indent,
      leading,
      trailing,
    });
  };
  let taskContinuation = false;
  const addEditable = (raw: string) => {
    let pending = '';
    let currentIndent: string | undefined;
    for (const line of linesWithOffsets(raw)) {
      if (!line.text.trim()) {
        pending += line.raw;
        continue;
      }
      const indent = taskContinuation && /^ {2}/.test(line.text) ? '  ' : '';
      if (currentIndent !== undefined && indent !== currentIndent) {
        add(pending, 'editable', undefined, currentIndent);
        pending = '';
      }
      currentIndent = indent;
      if (taskContinuation && !indent) taskContinuation = false;
      pending += line.raw;
    }
    add(pending, 'editable', undefined, currentIndent ?? '');
  };
  let offset = 0;
  for (const range of protectedRanges(source)) {
    addEditable(source.slice(offset, range.start));
    const raw = source.slice(range.start, range.end);
    add(raw, 'protected', range.reason);
    if (/^\s*[-*+] \[[ xX]\] \d+(?:\.\d+)+\b/.test(raw)) taskContinuation = true;
    offset = range.end;
  }
  addEditable(source.slice(offset));
  if (!segments.length)
    segments.push({
      id: 'segment-0',
      kind: 'editable',
      source: '',
      markdown: '',
      indent: '',
      leading: '',
      trailing: '',
    });
  return { original: content, bom, newline, segments };
}

/** Rich text serializers may normalize body syntax; protected source slices never pass through them. */
export function serializeDocument(envelope: DocumentEnvelope, edits: Record<string, string>): string {
  let changed = false;
  const chunks = envelope.segments.map((segment) => {
    const edit = edits[segment.id];
    if (segment.kind === 'protected' || edit === undefined) return segment.source;
    const normalized = edit.replace(/\r\n|\r/g, '\n').replace(/^\n+|\n+$/g, '');
    if (normalized === segment.markdown) return segment.source;
    changed = true;
    const indented = normalized
      .split('\n')
      .map((line) => (line ? segment.indent + line : ''))
      .join('\n');
    return (segment.leading + indented + segment.trailing).replace(/\n/g, envelope.newline);
  });
  if (!changed) return envelope.original;
  const next = envelope.bom + chunks.join('');
  assertProtectedContentUnchanged(envelope.original, next);
  return next;
}

export function assertProtectedContentUnchanged(original: string, next: string): void {
  if (original.startsWith('\uFEFF') !== next.startsWith('\uFEFF')) throw new Error('文档编码标记不能修改。');
  const before = splitDocument(original).segments.filter((segment) => segment.kind === 'protected');
  const after = splitDocument(next).segments.filter((segment) => segment.kind === 'protected');
  if (before.length !== after.length || before.some((segment, i) => segment.source !== after[i]?.source)) {
    throw new Error('文档元数据、任务定义、文件范围或原始语法块发生改变；请只编辑正文。');
  }
}
export const assertProtectedContent = (original: string, next: string, _path?: string): void =>
  assertProtectedContentUnchanged(original, next);
