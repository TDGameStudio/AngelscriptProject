import { useCallback, useEffect, useLayoutEffect, useMemo, useRef, useState } from 'react';
import { diffLines } from 'diff';
import { Check, Download, FileDiff, LockKeyhole, Save, Undo2 } from 'lucide-react';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import type { DocumentContent } from '../../shared/types';
import {
  assertProtectedContentUnchanged,
  serializeDocument,
  splitDocument,
  type DocumentSegment,
} from '../../shared/documents';
import { createBodyEditor, resolveDocumentLink } from './body-editor';
import { clearDraft, loadDraft, saveDraft } from './drafts';
import '@milkdown/crepe/theme/common/style.css';
import '@milkdown/crepe/theme/classic.css';
import './editor.css';

export interface DocumentEditorProps {
  document: DocumentContent;
  workspaceId: string;
  onSave: (content: string, baseRevision: string) => Promise<DocumentContent>;
  onNavigate?: (path: string) => void;
}

function BodySegment({
  segment,
  readonly,
  onChange,
  register,
  documentPath,
}: {
  segment: DocumentSegment;
  readonly: boolean;
  documentPath: string;
  onChange: (id: string, markdown: string) => void;
  register: (id: string, getter: (() => string) | undefined) => void;
}) {
  const root = useRef<HTMLDivElement>(null);
  const callbacks = useRef({ onChange, register });
  callbacks.current = { onChange, register };
  const [error, setError] = useState('');
  useEffect(() => {
    let disposed = false;
    let dispose: (() => Promise<void>) | undefined;
    if (!root.current) return;
    void createBodyEditor(
      root.current,
      segment.markdown,
      (markdown) => callbacks.current.onChange(segment.id, markdown),
      readonly,
      documentPath,
    )
      .then((editor) => {
        if (disposed) {
          void editor.destroy();
          return;
        }
        dispose = async () => {
          await editor.destroy();
        };
        const initial = editor.getMarkdown();
        callbacks.current.register(segment.id, () => {
          const current = editor.getMarkdown();
          return current === initial ? segment.markdown : current;
        });
      })
      .catch((reason: unknown) => {
        if (!disposed) setError(reason instanceof Error ? reason.message : '编辑器暂时不可用');
      });
    return () => {
      disposed = true;
      callbacks.current.register(segment.id, undefined);
      void dispose?.();
    };
  }, [segment.id, segment.markdown, readonly, documentPath]);
  return (
    <section className="editor-body-segment">
      {error && (
        <div className="editor-message editor-error" role="alert">
          此段暂时无法编辑，原文已保留。{error}
          <pre>{segment.source}</pre>
        </div>
      )}
      <div ref={root} className="editor-crepe-host" />
    </section>
  );
}

function ProtectedSegment({ segment }: { segment: DocumentSegment }) {
  if (segment.reason?.startsWith('任务定义') || segment.reason?.startsWith('文件范围')) {
    return (
      <div
        className={`editor-protected ${segment.reason.startsWith('任务') ? 'editor-task-heading' : 'editor-task-files'}`}
      >
        <span className="editor-protected-label">
          <LockKeyhole size={12} />
          {segment.reason}
        </span>
        <ReactMarkdown remarkPlugins={[remarkGfm]}>{segment.source.trim()}</ReactMarkdown>
      </div>
    );
  }
  return (
    <details className="editor-protected editor-opaque">
      <summary>
        <LockKeyhole size={13} />
        {segment.reason} <span>原样保留</span>
      </summary>
      <pre>{segment.source}</pre>
    </details>
  );
}

export default function DocumentEditor(props: DocumentEditorProps) {
  return <EditorSession key={`${props.workspaceId}:${props.document.path}`} {...props} />;
}

function EditorSession({ document: incoming, workspaceId, onSave, onNavigate }: DocumentEditorProps) {
  const [base, setBase] = useState(incoming);
  const [envelope, setEnvelope] = useState(() => splitDocument(incoming.content));
  const [edits, setEdits] = useState<Record<string, string>>({});
  const [version, setVersion] = useState(0);
  const [notice, setNotice] = useState('');
  const [error, setError] = useState('');
  const [draftLoaded, setDraftLoaded] = useState(false);
  const [saving, setSaving] = useState(false);
  const [conflict, setConflict] = useState<DocumentContent>();
  const [showDiff, setShowDiff] = useState(false);
  const getters = useRef(new Map<string, () => string>());
  const pendingDraft = useRef(Promise.resolve());
  const latestBase = useRef(base);
  latestBase.current = base;
  const output = useMemo(() => {
    try {
      const content = serializeDocument(envelope, edits);
      assertProtectedContentUnchanged(base.content, content);
      return { content, error: '' };
    } catch (reason) {
      return {
        content: envelope.original,
        error: reason instanceof Error ? reason.message : '无法保存当前内容',
      };
    }
  }, [envelope, edits, base.content]);
  const dirty = output.content !== base.content || !!output.error;
  const dirtyRef = useRef(dirty);
  dirtyRef.current = dirty;
  const latestSession = useRef({ base, envelope, edits });
  latestSession.current = { base, envelope, edits };
  useLayoutEffect(
    () => () => {
      // Read live ProseMirror state before child cleanup; markdownUpdated is debounced.
      const latest = latestSession.current;
      if (latest.base.readonly) return;
      try {
        const flushed = {
          ...latest.edits,
          ...Object.fromEntries([...getters.current].map(([id, getter]) => [id, getter()])),
        };
        const content = serializeDocument(latest.envelope, flushed);
        if (content !== latest.base.content) {
          pendingDraft.current = saveDraft(workspaceId, latest.base.path, {
            base: latest.base,
            content,
            updatedAt: Date.now(),
          }).catch(() => {});
        }
      } catch {
        /* Keep the last valid draft if a protected-content edit cannot serialize. */
      }
    },
    [workspaceId],
  );
  const replaceSession = useCallback((document: DocumentContent, content = document.content) => {
    getters.current.clear();
    setBase(document);
    setEnvelope(splitDocument(content));
    setEdits({});
    setVersion((value) => value + 1);
    setError('');
  }, []);
  useEffect(() => {
    let cancelled = false;
    void loadDraft(workspaceId, incoming.path)
      .then((draft) => {
        if (
          cancelled ||
          dirtyRef.current ||
          incoming.readonly ||
          !draft ||
          draft.content === incoming.content
        )
          return;
        replaceSession(draft.base, draft.content);
        setNotice('已恢复本机草稿');
        if (draft.base.revision !== incoming.revision) setConflict(incoming);
      })
      .catch(() => {
        if (!cancelled) setNotice('本机草稿存储不可用，请及时保存文档。');
      })
      .finally(() => {
        if (!cancelled) setDraftLoaded(true);
      });
    return () => {
      cancelled = true;
    };
    // A session is keyed by workspace and path; restoration happens exactly once.
  }, []);
  const incomingRevision = useRef(incoming.revision);
  useEffect(() => {
    if (incomingRevision.current === incoming.revision) return;
    incomingRevision.current = incoming.revision;
    if (incoming.revision === latestBase.current.revision) return;
    // Watcher updates may arrive before Milkdown publishes its debounced change event.
    // Inspect the live editors before deciding that it is safe to replace their content.
    const latest = latestSession.current;
    const flushed = {
      ...latest.edits,
      ...Object.fromEntries([...getters.current].map(([id, getter]) => [id, getter()])),
    };
    let hasUnsavedContent = dirtyRef.current;
    try {
      hasUnsavedContent ||= serializeDocument(latest.envelope, flushed) !== latest.base.content;
    } catch {
      hasUnsavedContent = true;
    }
    if (hasUnsavedContent) {
      setEdits(flushed);
      setConflict(incoming);
    } else {
      replaceSession(incoming);
      setNotice('已同步磁盘版本');
    }
  }, [incoming.revision, incoming, replaceSession]);
  useEffect(() => {
    if (!draftLoaded || !dirty || base.readonly || output.error) return;
    pendingDraft.current = saveDraft(workspaceId, base.path, {
      base,
      content: output.content,
      updatedAt: Date.now(),
    }).catch(() => {
      setNotice('本机草稿存储不可用，请及时保存文档。');
    });
  }, [draftLoaded, dirty, base, output.content, output.error, workspaceId]);
  useEffect(() => {
    const beforeUnload = (event: BeforeUnloadEvent) => {
      if (dirtyRef.current) {
        event.preventDefault();
        event.returnValue = '';
      }
    };
    window.addEventListener('beforeunload', beforeUnload);
    return () => window.removeEventListener('beforeunload', beforeUnload);
  }, []);
  const register = useCallback((id: string, getter: (() => string) | undefined) => {
    if (getter) getters.current.set(id, getter);
    else getters.current.delete(id);
  }, []);
  const onChange = useCallback((id: string, markdown: string) => {
    setEdits((previous) => ({ ...previous, [id]: markdown }));
    setNotice('');
  }, []);
  const save = useCallback(async () => {
    if (base.readonly || conflict || saving || !draftLoaded) return;
    setError('');
    try {
      const flushed = {
        ...edits,
        ...Object.fromEntries([...getters.current].map(([id, getter]) => [id, getter()])),
      };
      const content = serializeDocument(envelope, flushed);
      assertProtectedContentUnchanged(base.content, content);
      if (content === base.content) {
        setNotice('没有待保存的修改');
        return;
      }
      setSaving(true);
      await pendingDraft.current;
      await saveDraft(workspaceId, base.path, { base, content, updatedAt: Date.now() }).catch(() => {});
      const saved = await onSave(content, base.revision);
      await clearDraft(workspaceId, base.path).catch(() => {});
      replaceSession(saved);
      setNotice('已保存');
      setShowDiff(false);
    } catch (reason) {
      const failure = reason as { message?: string; current?: DocumentContent };
      if (failure.current) {
        setConflict(failure.current);
        setShowDiff(true);
      } else setError(failure.message ?? '保存失败，草稿仍保留在本机。');
    } finally {
      setSaving(false);
    }
  }, [base, conflict, saving, draftLoaded, edits, envelope, workspaceId, onSave, replaceSession]);
  useEffect(() => {
    const shortcut = (event: KeyboardEvent) => {
      if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === 's') {
        event.preventDefault();
        void save();
      }
    };
    window.addEventListener('keydown', shortcut);
    return () => window.removeEventListener('keydown', shortcut);
  }, [save]);
  const downloadDraft = () => {
    const blob = new Blob([output.content], { type: 'text/markdown;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `${base.path.split('/').at(-1) ?? 'document'}.draft.md`;
    link.click();
    URL.revokeObjectURL(url);
  };
  const discard = async () => {
    await pendingDraft.current;
    await clearDraft(workspaceId, base.path).catch(() => {});
    replaceSession(conflict ?? base);
    setConflict(undefined);
    setNotice('已载入磁盘版本');
    setShowDiff(false);
  };
  const continueMerge = () => {
    if (!conflict || saving) return;
    setError('');
    if (conflict.readonly) {
      setError('当前磁盘文档只读，不能继续合并保存。');
      return;
    }
    try {
      const flushed = {
        ...edits,
        ...Object.fromEntries([...getters.current].map(([id, getter]) => [id, getter()])),
      };
      const content = serializeDocument(envelope, flushed);
      // Explicitly adopt the disk revision, never its protected fields or body content.
      assertProtectedContentUnchanged(conflict.content, content);
      setEdits(flushed);
      setBase(conflict);
      setConflict(undefined);
      setShowDiff(true);
      setNotice('已以磁盘版本为基准继续合并；你的正文已保留，请对照差异编辑后手动保存。');
    } catch {
      setShowDiff(true);
      setError(
        '磁盘版本的受保护内容已经变化，无法直接继续合并。草稿仍保留；请下载草稿并载入磁盘版本后迁移正文。',
      );
    }
  };
  const changes = showDiff ? diffLines(conflict?.content ?? base.content, output.content) : [];
  return (
    <div className="document-editor">
      <div className="editor-toolbar">
        <div className="editor-save-state" role="status">
          {saving ? (
            '正在保存…'
          ) : dirty ? (
            <>
              <span className="editor-unsaved-dot" />
              未保存
            </>
          ) : (
            <>
              <Check size={14} />
              与磁盘一致
            </>
          )}
        </div>
        <span className="editor-toolbar-spacer" />
        <button
          type="button"
          className="editor-button"
          disabled={!dirty && !conflict}
          onClick={() => setShowDiff(!showDiff)}
          aria-pressed={showDiff}
        >
          <FileDiff size={15} />
          查看差异
        </button>
        <button
          type="button"
          className="editor-button editor-save"
          aria-label="保存文档"
          disabled={base.readonly || !!output.error || !!conflict || saving || !draftLoaded}
          onClick={() => void save()}
        >
          <Save size={15} />
          保存 <kbd>Ctrl S</kbd>
        </button>
      </div>
      {notice && (
        <p className="editor-message" role="status">
          {notice}
        </p>
      )}
      {base.readonly && (
        <p className="editor-message">
          <LockKeyhole size={14} />
          {base.readonlyReason ?? '此文档只读'}
        </p>
      )}
      {(error || output.error) && (
        <p className="editor-message editor-error" role="alert">
          {error || output.error}
        </p>
      )}
      {conflict && (
        <div className="editor-conflict" role="alert">
          <strong>磁盘上的文件已经更新，你的草稿已保留。</strong>
          <p>对照差异，将正文手动合并到最新磁盘版本后保存；也可以下载草稿或放弃本次修改。</p>
          <div>
            <button className="editor-button" onClick={() => setShowDiff(true)}>
              <FileDiff size={14} />
              比较版本
            </button>
            <button className="editor-button" onClick={continueMerge} disabled={saving || conflict.readonly}>
              <FileDiff size={14} />
              以磁盘版本为基准继续合并
            </button>
            <button className="editor-button" onClick={downloadDraft}>
              <Download size={14} />
              下载我的草稿
            </button>
            <button className="editor-button" onClick={() => void discard()}>
              <Undo2 size={14} />
              放弃草稿并载入磁盘版
            </button>
          </div>
        </div>
      )}
      {showDiff && (
        <section className="editor-diff" aria-label="文档差异">
          <div className="editor-diff-heading">
            {conflict ? '磁盘版本 → 我的草稿' : '已保存版本 → 我的修改'}
            <button className="editor-button" onClick={() => setShowDiff(false)}>
              关闭
            </button>
          </div>
          <pre>
            {changes.map((change, index) => (
              <span
                key={index}
                className={change.added ? 'editor-diff-added' : change.removed ? 'editor-diff-removed' : ''}
              >
                {change.value}
              </span>
            ))}
          </pre>
        </section>
      )}
      <div
        className="editor-document-body"
        inert={saving || !draftLoaded}
        onClick={(event) => {
          const anchor = (event.target as HTMLElement).closest('a');
          const href = anchor?.getAttribute('href');
          if (!href) return;
          if (/^(https?:|mailto:)/i.test(href)) {
            event.preventDefault();
            window.open(href, '_blank', 'noopener,noreferrer');
          } else if (onNavigate && !href.startsWith('#')) {
            event.preventDefault();
            const path = resolveDocumentLink(base.path, href);
            if (path) onNavigate(path);
          }
        }}
      >
        {envelope.segments.map((segment) =>
          segment.kind === 'protected' ? (
            <ProtectedSegment key={`${version}-${segment.id}`} segment={segment} />
          ) : segment.markdown.trim() || envelope.segments.length === 1 ? (
            <BodySegment
              key={`${version}-${segment.id}`}
              segment={segment}
              readonly={base.readonly}
              onChange={onChange}
              register={register}
              documentPath={base.path}
            />
          ) : null,
        )}
      </div>
      <div className="editor-footer">
        <span>Markdown · 所见即所得</span>
        <span>{new Intl.NumberFormat('zh-CN').format(output.content.length)} 字符</span>
        <span>{envelope.newline === '\r\n' ? 'CRLF' : envelope.newline === '\r' ? 'CR' : 'LF'}</span>
      </div>
    </div>
  );
}
