import { useId, useMemo, useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import { BookOpen, ChevronDown, Maximize2, Minimize2, Search } from 'lucide-react';
import { WorkspacePanels } from '../components/WorkspacePanels';
import { useDocuments, useWorkspace } from '../lib/api';
import { DocumentPane } from '../components/DocumentPane';
import { FileTree } from '../components/FileTree';
import { EmptyState, ErrorState, Loading, PageHeading } from '../components/State';

export default function DocumentsPage({
  specs = false,
  skills = false,
}: {
  specs?: boolean;
  skills?: boolean;
}) {
  const documents = useDocuments();
  const workspace = useWorkspace();
  const [params, setParams] = useSearchParams();
  const query = params.get('q') ?? '';
  const selected = params.get('path') ?? '';
  const focus = params.get('focus') === '1';
  const [filesExpanded, setFilesExpanded] = useState(false);
  const treeId = useId();
  const prefix = skills ? '.agents/skills/' : specs ? 'openspec/specs/' : '';
  const available = useMemo(
    () => documents.data?.filter((doc) => !prefix || doc.path.startsWith(prefix)) ?? [],
    [documents.data, prefix],
  );
  const filtered = available.filter(
    (doc) => !query || `${doc.path} ${doc.title}`.toLowerCase().includes(query.toLowerCase()),
  );
  const path = selected || (prefix ? (filtered[0]?.path ?? '') : '');
  const panelName = skills ? 'skills' : specs ? 'specs' : 'documents';
  return (
    <div
      className={`page documents-page ${focus ? 'focus-mode' : ''} ${path ? 'has-document' : ''} ${filesExpanded ? 'files-open' : ''}`}
    >
      <PageHeading
        eyebrow={
          skills ? 'WORKSPACE / SKILLS' : specs ? 'OPENSPEC / SPECIFICATIONS' : 'WORKSPACE / DOCUMENTS'
        }
        title={skills ? '项目 Skills' : specs ? '规范，持续演进' : '让文档成为工作现场'}
        description={
          skills
            ? '浏览 .agents/skills 下的 Markdown，查看 Skill 提示和参考。'
            : specs
              ? '沿着领域阅读行为契约，在需求与场景之间建立连接。'
              : '阅读上下文，整理思考，让 Markdown 跟上每一次改变。'
        }
      >
        <button
          className="button"
          onClick={() =>
            setParams((current) => {
              focus ? current.delete('focus') : current.set('focus', '1');
              return current;
            })
          }
        >
          {focus ? <Minimize2 size={15} /> : <Maximize2 size={15} />}
          {focus ? '退出专注' : '专注阅读'}
        </button>
      </PageHeading>
      <div className="documents-workspace resizable-documents">
        <WorkspacePanels
          workspaceId={workspace.data?.root}
          name={panelName}
          focused={focus}
          first={
            <aside className="panel document-index">
              <div className="index-title">
                <BookOpen size={16} />
                <strong>{skills ? 'Skills' : specs ? '领域与规范' : '文档库'}</strong>
                <span className="count-label">{available.length}</span>
              </div>
              <button
                className="document-mobile-files"
                aria-expanded={!path || filesExpanded}
                aria-controls={treeId}
                onClick={() => setFilesExpanded(!filesExpanded)}
              >
                <BookOpen size={16} />
                <span>{skills ? '选择 Skill 文档' : '选择工作区文档'}</span>
                <strong>{path.split('/').at(-1) || '文件'}</strong>
                <ChevronDown size={15} />
              </button>
              <div className="document-tree-body" id={treeId}>
                <label className="search-field tree-search">
                  <Search size={15} />
                  <input
                    aria-label="筛选文档"
                    placeholder="筛选文件…"
                    value={query}
                    onChange={(e) =>
                      setParams((current) => {
                        e.target.value ? current.set('q', e.target.value) : current.delete('q');
                        return current;
                      })
                    }
                  />
                </label>
                {documents.isPending ? (
                  <Loading />
                ) : documents.error ? (
                  <ErrorState error={documents.error} retry={() => void documents.refetch()} />
                ) : filtered.length ? (
                  <FileTree
                    documents={filtered}
                    selected={path}
                    basePath={skills ? '.agents/skills' : ''}
                    onSelect={(next) => {
                      setFilesExpanded(false);
                      setParams((current) => {
                        current.set('path', next);
                        current.delete('mode');
                        current.delete('line');
                        return current;
                      });
                    }}
                  />
                ) : (
                  <EmptyState title="没有匹配的文档" />
                )}
              </div>
            </aside>
          }
          second={
            <div className="panel document-canvas">
              <DocumentPane path={path} />
            </div>
          }
        />
      </div>
    </div>
  );
}
