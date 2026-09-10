// @vitest-environment jsdom
import 'fake-indexeddb/auto';
import { afterEach, beforeAll, describe, expect, it } from 'vitest';
import { replaceAll } from '@milkdown/kit/utils';
import { unified } from 'unified';
import remarkParse from 'remark-parse';
import remarkGfm from 'remark-gfm';
import { waitFor } from '@testing-library/react';
import {
  createBodyEditor,
  renderMermaidPreview,
  resolveDocumentLink,
  imageDisplayUrl,
} from '../../src/client/editor/body-editor';
import { clearDraft, loadDraft, saveDraft } from '../../src/client/editor/drafts';
import { serializeDocument, splitDocument } from '../../src/shared/documents';

beforeAll(() => {
  // JSDOM has no layout; these browser primitives do not change document transformations.
  window.matchMedia ??= (() => ({
    matches: false,
    addListener() {},
    removeListener() {},
    addEventListener() {},
    removeEventListener() {},
    dispatchEvent() {
      return false;
    },
    media: '',
    onchange: null,
  })) as typeof window.matchMedia;
  globalThis.ResizeObserver ??= class {
    observe() {}
    unobserve() {}
    disconnect() {}
  };
  Range.prototype.getClientRects ??= (() => []) as unknown as typeof Range.prototype.getClientRects;
  Range.prototype.getBoundingClientRect ??= () => ({
    left: 0,
    right: 0,
    top: 0,
    bottom: 0,
    width: 0,
    height: 0,
    x: 0,
    y: 0,
    toJSON() {},
  });
});
afterEach(() => {
  document.body.replaceChildren();
});

describe('actual WYSIWYG document conversion', () => {
  it('resolves local images against the document without rewriting their Markdown links', async () => {
    expect(resolveDocumentLink('docs/guides/edit.md', '../images/picture.png')).toBe(
      'docs/images/picture.png',
    );
    expect(imageDisplayUrl('docs/guides/edit.md', '../images/picture.png')).toBe(
      '/api/image?path=docs%2Fimages%2Fpicture.png',
    );
    expect(resolveDocumentLink('docs/edit.md', 'javascript:alert(1)')).toBeNull();
    const root = document.createElement('div');
    document.body.append(root);
    const editor = await createBodyEditor(
      root,
      '![Picture](../images/picture.png)',
      () => {},
      false,
      'docs/guides/edit.md',
    );
    try {
      await waitFor(() =>
        expect(root.querySelector('img')?.getAttribute('src')).toBe(
          '/api/image?path=docs%2Fimages%2Fpicture.png',
        ),
      );
      expect(editor.getMarkdown()).toContain('![Picture](../images/picture.png)');
    } finally {
      await editor.destroy();
    }
  });
  it('keeps Scenario nesting, table cells and blockquotes after a real Crepe edit', async () => {
    const source =
      '- [ ] 1.1 Proof — verify: `npm test`\n  > Files: `src/**`\n\n  #### Scenario: nested content\n  - WHEN **a request** arrives\n    - GIVEN a child\n\n      | Field | Value |\n      | --- | --- |\n      | mode | local |\n\n      > Keep the quoted note.\n  - THEN preserve structure\n';
    const envelope = splitDocument(source);
    const segment = envelope.segments.find(
      (part) => part.kind === 'editable' && part.markdown.includes('Scenario'),
    )!;
    const root = document.createElement('div');
    document.body.append(root);
    const editor = await createBodyEditor(root, segment.markdown, () => {}, false);
    try {
      editor.editor.action(replaceAll(segment.markdown.replace('a request', 'another request')));
      const actual = serializeDocument(envelope, { [segment.id]: editor.getMarkdown() });
      const expected = source.replace('a request', 'another request');
      const tree = (value: string) =>
        JSON.parse(
          JSON.stringify(unified().use(remarkParse).use(remarkGfm).parse(value), (key, entry) =>
            key === 'position' ? undefined : entry,
          ),
        );
      expect(tree(actual)).toEqual(tree(expected));
      expect(root.querySelector('[contenteditable="true"]')).not.toBeNull();
      await waitFor(() =>
        expect(
          [...root.querySelectorAll('table')].some((table) => table.textContent?.includes('local')),
        ).toBe(true),
      );
    } finally {
      await editor.destroy();
    }
  });

  it('reports malformed Mermaid locally without destroying its editable source', async () => {
    const preview = await renderMermaidPreview('this is not valid Mermaid');
    expect(preview.getAttribute('role')).toBe('status');
    expect(preview.textContent).toContain('图表');
    expect(preview.querySelector('script')).toBeNull();
  });
});

describe('persistent local drafts', () => {
  it('persists original revision and content and isolates workspace plus path', async () => {
    const draft = {
      content: 'Unsaved **body**',
      base: { path: 'notes.md', title: 'Notes', readonly: false, content: 'Original', revision: 'r1' },
      updatedAt: 123,
    };
    await saveDraft('workspace-a', 'notes.md', draft);
    expect(await loadDraft('workspace-a', 'notes.md')).toEqual(draft);
    expect(await loadDraft('workspace-b', 'notes.md')).toBeUndefined();
    expect(await loadDraft('workspace-a', 'other.md')).toBeUndefined();
    await clearDraft('workspace-a', 'notes.md');
    expect(await loadDraft('workspace-a', 'notes.md')).toBeUndefined();
  });
});
