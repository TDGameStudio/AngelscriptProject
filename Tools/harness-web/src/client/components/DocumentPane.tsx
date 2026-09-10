import { lazy, Suspense, useEffect } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { useQueryClient } from '@tanstack/react-query';
import { ArrowUpRight, BookOpen, FilePenLine, LockKeyhole } from 'lucide-react';
import { api, useDocument, useWorkspace } from '../lib/api';
import { readPreference, writePreference } from '../lib/preferences';
import { documentUrl } from '../lib/paths';
import { EmptyState, ErrorState, Loading } from './State';
import { MarkdownDocument } from './MarkdownDocument';
const DocumentEditor = lazy(() => import('../editor/DocumentEditor'));

export function DocumentPane({ path, embedded = false }: { path: string; embedded?: boolean }) {
  const query = useDocument(path);
  const workspace = useWorkspace();
  const client = useQueryClient();
  const navigate = useNavigate();
  const [params, setParams] = useSearchParams();
  const editing = params.get('mode') === 'edit';
  useEffect(() => {
    if (!path || !workspace.data?.root) return;
    const previous = readPreference<string[]>(workspace.data.root, 'recent', []);
    writePreference(
      workspace.data.root,
      'recent',
      [path, ...(Array.isArray(previous) ? previous.filter((p) => p !== path) : [])].slice(0, 8),
    );
  }, [path, workspace.data?.root]);
  if (!path)
    return <EmptyState title="选择一份文档">从左侧目录中选择文档，或按 Ctrl K 搜索工作区。</EmptyState>;
  if (query.isPending) return <Loading label="正在读取文档…" />;
  if (query.error) return <ErrorState error={query.error} retry={() => void query.refetch()} />;
  const document = query.data;
  return (
    <section className={`document-pane ${embedded ? 'embedded' : ''}`}>
      <header className="document-toolbar">
        <span className="document-path" title={path}>
          {path}
        </span>
        <div className="document-actions">
          {document.readonly ? (
            <span className="tag" title={document.readonlyReason}>
              <LockKeyhole size={12} />
              只读
            </span>
          ) : (
            <div className="segmented small">
              <button
                className={!editing ? 'active' : ''}
                onClick={() =>
                  setParams((current) => {
                    current.delete('mode');
                    return current;
                  })
                }
              >
                <BookOpen size={14} />
                阅读
              </button>
              <button
                className={editing ? 'active' : ''}
                onClick={() =>
                  setParams((current) => {
                    current.set('mode', 'edit');
                    return current;
                  })
                }
              >
                <FilePenLine size={14} />
                编辑
              </button>
            </div>
          )}
          {embedded && (
            <button className="icon-button" title="在文档中打开" onClick={() => navigate(documentUrl(path))}>
              <ArrowUpRight size={16} />
            </button>
          )}
        </div>
      </header>
      {document.readonlyReason && (
        <p className="readonly-note">
          <LockKeyhole size={13} />
          {document.readonlyReason}
        </p>
      )}
      {editing && !document.readonly ? (
        <Suspense fallback={<Loading label="正在打开编辑器…" />}>
          <DocumentEditor
            key={path}
            document={document}
            workspaceId={workspace.data?.root ?? ''}
            onNavigate={(target) => navigate(documentUrl(target))}
            onSave={async (content, revision) => {
              const saved = await api.save(path, content, revision, workspace.data?.sessionToken ?? '');
              client.setQueryData(['document', path], saved);
              await client.invalidateQueries({ queryKey: ['documents'] });
              return saved;
            }}
          />
        </Suspense>
      ) : (
        <MarkdownDocument
          content={document.content}
          path={path}
          line={Number(params.get('line')) || undefined}
        />
      )}
    </section>
  );
}
