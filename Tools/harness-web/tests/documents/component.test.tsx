// @vitest-environment jsdom
import 'fake-indexeddb/auto';
import { beforeAll, afterEach, describe, expect, it } from 'vitest';
import { cleanup, render, screen, waitFor, fireEvent } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import DocumentEditor from '../../src/client/editor/DocumentEditor';
import { loadDraft, saveDraft } from '../../src/client/editor/drafts';
import type { DocumentContent } from '../../src/shared/types';

beforeAll(() => {
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
afterEach(cleanup);
const doc: DocumentContent = {
  path: 'notes.md',
  title: 'Notes',
  readonly: false,
  content: '# Heading\n\nOriginal body.\n',
  revision: 'revision-1',
};

describe('document editing session', () => {
  it('continues a manual merge with the latest disk revision and saves only on explicit request', async () => {
    const workspace = 'manual-merge';
    const disk = { ...doc, content: '# Heading\n\nRemote note.\n', revision: 'revision-2' };
    await saveDraft(workspace, doc.path, { base: doc, content: '# Heading\n\nMy draft.\n', updatedAt: 10 });
    const saves: { content: string; revision: string }[] = [];
    render(
      <DocumentEditor
        document={disk}
        workspaceId={workspace}
        onSave={async (content, revision) => {
          saves.push({ content, revision });
          return { ...disk, content, revision: 'revision-3' };
        }}
      />,
    );
    await screen.findByText(/磁盘上的文件已经更新/);
    const textbox = await screen.findByRole('textbox', { name: '文档正文' });
    textbox.querySelector('p')!.textContent = 'My draft with final input.';
    fireEvent.input(textbox, { inputType: 'insertText', data: 'My draft with final input.' });
    await new Promise((resolve) => setTimeout(resolve, 0));
    fireEvent.click(screen.getByRole('button', { name: '以磁盘版本为基准继续合并' }));
    await screen.findByText(/请对照差异编辑后手动保存/);
    expect(screen.getByRole('textbox', { name: '文档正文' }).textContent).toContain(
      'My draft with final input.',
    );
    expect(screen.queryByText(/磁盘上的文件已经更新/)).toBeNull();
    expect(saves).toHaveLength(0);
    await waitFor(async () =>
      expect((await loadDraft(workspace, doc.path))?.base.revision).toBe('revision-2'),
    );
    textbox.querySelector('p')!.textContent = 'My draft with final input. Remote note.';
    fireEvent.input(textbox, { inputType: 'insertText', data: 'My draft with final input. Remote note.' });
    await new Promise((resolve) => setTimeout(resolve, 0));
    fireEvent.click(screen.getByRole('button', { name: '保存文档' }));
    await screen.findByText('已保存');
    expect(saves).toEqual([
      { content: '# Heading\n\nMy draft with final input. Remote note.\n', revision: 'revision-2' },
    ]);
  });

  it('refuses manual rebasing when protected disk metadata changed and preserves the draft', async () => {
    const workspace = 'manual-merge-protected';
    const original = { ...doc, content: '---\nmode: original\n---\n\nOriginal body.\n' };
    const disk = {
      ...original,
      content: '---\nmode: external\n---\n\nExternal body.\n',
      revision: 'revision-2',
    };
    const localContent = '---\nmode: original\n---\n\nMy preserved draft.\n';
    await saveDraft(workspace, doc.path, { base: original, content: localContent, updatedAt: 11 });
    render(
      <DocumentEditor
        document={disk}
        workspaceId={workspace}
        onSave={async () => {
          throw new Error('must not save protected changes');
        }}
      />,
    );
    await screen.findByText(/磁盘上的文件已经更新/);
    await screen.findByRole('textbox', { name: '文档正文' });
    await userEvent.click(screen.getByRole('button', { name: '以磁盘版本为基准继续合并' }));
    await screen.findByText(/磁盘版本的受保护内容已经变化/);
    expect(screen.getByRole('button', { name: '保存文档' }).hasAttribute('disabled')).toBe(true);
    expect(screen.getByRole('textbox', { name: '文档正文' }).textContent).toContain('My preserved draft.');
    expect((await loadDraft(workspace, doc.path))?.content).toBe(localContent);
    expect((await loadDraft(workspace, doc.path))?.base.revision).toBe('revision-1');
  });

  it('saves the latest live input immediately while the debounced dirty status is still clean', async () => {
    const saves: string[] = [];
    render(
      <DocumentEditor
        document={doc}
        workspaceId="immediate-save-click"
        onSave={async (content) => {
          saves.push(content);
          return { ...doc, content, revision: 'revision-2' };
        }}
      />,
    );
    const textbox = await screen.findByRole('textbox', { name: '文档正文' });
    await waitFor(() =>
      expect(screen.getByRole('button', { name: '保存文档' }).hasAttribute('disabled')).toBe(false),
    );
    textbox.querySelector('p')!.textContent = 'Immediate final input.';
    fireEvent.input(textbox, { inputType: 'insertText', data: 'Immediate final input.' });
    await new Promise((resolve) => setTimeout(resolve, 0));
    expect(screen.queryByText('未保存')).toBeNull();
    fireEvent.click(screen.getByRole('button', { name: '保存文档' }));
    await screen.findByText('已保存');
    expect(saves).toEqual(['# Heading\n\nImmediate final input.\n']);
  });

  it('preserves live keystrokes when a disk revision arrives before the editor debounce', async () => {
    const workspace = 'revision-before-debounce';
    const { rerender } = render(
      <DocumentEditor document={doc} workspaceId={workspace} onSave={async () => doc} />,
    );
    const textbox = await screen.findByRole('textbox', { name: '文档正文' });
    textbox.querySelector('p')!.textContent = 'Local final keystrokes.';
    fireEvent.input(textbox, { inputType: 'insertText', data: 'Local final keystrokes.' });
    await new Promise((resolve) => setTimeout(resolve, 0));
    expect(screen.queryByText('未保存')).toBeNull();
    rerender(
      <DocumentEditor
        document={{ ...doc, content: '# Heading\n\nExternal writer.\n', revision: 'revision-2' }}
        workspaceId={workspace}
        onSave={async () => doc}
      />,
    );
    await screen.findByText(/磁盘上的文件已经更新/);
    expect(screen.getByRole('textbox', { name: '文档正文' }).textContent).toContain(
      'Local final keystrokes.',
    );
    await waitFor(async () => {
      const draft = await loadDraft(workspace, doc.path);
      expect(draft?.content).toContain('Local final keystrokes.');
      expect(draft?.base.revision).toBe('revision-1');
    });
    expect(screen.getByRole('button', { name: '保存文档' }).hasAttribute('disabled')).toBe(true);
  });
  it('flushes the live editor into its draft before immediate navigation unmount', async () => {
    const workspace = 'immediate-unmount';
    const { unmount } = render(
      <DocumentEditor document={doc} workspaceId={workspace} onSave={async () => doc} />,
    );
    const textbox = await screen.findByRole('textbox', { name: '文档正文' });
    // A real browser input event changes DOM before Milkdown's debounced markdownUpdated callback.
    const paragraph = textbox.querySelector('p')!;
    paragraph.textContent = 'The last keystrokes.';
    fireEvent.input(textbox, { inputType: 'insertText', data: 'The last keystrokes.' });
    await new Promise((resolve) => setTimeout(resolve, 0));
    unmount();
    await waitFor(async () =>
      expect((await loadDraft(workspace, doc.path))?.content).toContain('The last keystrokes.'),
    );
  });
  it('restores a draft and saves explicitly with its original revision', async () => {
    const workspace = 'restore-and-save';
    await saveDraft(workspace, doc.path, {
      base: doc,
      content: '# Heading\n\nRecovered draft.\n',
      updatedAt: 1,
    });
    let persisted: DocumentContent = doc;
    render(
      <DocumentEditor
        document={doc}
        workspaceId={workspace}
        onSave={async (content, revision) => {
          if (revision !== 'revision-1') throw new Error('wrong revision');
          persisted = { ...doc, content, revision: 'revision-2' };
          return persisted;
        }}
      />,
    );
    await screen.findByText('已恢复本机草稿');
    await waitFor(() =>
      expect(screen.getByRole('button', { name: '保存文档' }).hasAttribute('disabled')).toBe(false),
    );
    expect(persisted.content).toBe(doc.content);
    await userEvent.click(screen.getByRole('button', { name: '保存文档' }));
    await screen.findByText('已保存');
    expect(persisted.content).toContain('Recovered draft.');
    expect(await loadDraft(workspace, doc.path)).toBeUndefined();
  });

  it('keeps a dirty draft when a newer disk revision arrives', async () => {
    const workspace = 'incoming-revision';
    await saveDraft(workspace, doc.path, { base: doc, content: 'My draft.\n', updatedAt: 2 });
    const { rerender } = render(
      <DocumentEditor document={doc} workspaceId={workspace} onSave={async () => doc} />,
    );
    await screen.findByText('已恢复本机草稿');
    rerender(
      <DocumentEditor
        document={{ ...doc, content: 'External edit.\n', revision: 'revision-2' }}
        workspaceId={workspace}
        onSave={async () => doc}
      />,
    );
    await screen.findByText(/磁盘上的文件已经更新/);
    expect((await loadDraft(workspace, doc.path))?.content).toBe('My draft.\n');
    expect(screen.getByRole('button', { name: '保存文档' }).hasAttribute('disabled')).toBe(true);
  });

  it('never exposes an editable surface for read-only documents', async () => {
    render(
      <DocumentEditor
        document={{ ...doc, readonly: true, readonlyReason: '归档文档' }}
        workspaceId="readonly-doc"
        onSave={async () => {
          throw new Error('must not save');
        }}
      />,
    );
    await screen.findByText('归档文档');
    expect(screen.getByRole('button', { name: '保存文档' }).hasAttribute('disabled')).toBe(true);
    expect(document.querySelector('[contenteditable="true"]')).toBeNull();
  });
});
