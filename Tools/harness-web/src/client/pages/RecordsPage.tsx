import { useMemo } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { ArrowLeft, ArrowUpRight, CheckCircle2, CircleDashed, Network, Search, X } from 'lucide-react';
import type { RecordKind } from '../../shared/types';
import { useRecord, useRecords } from '../lib/api';
import { EmptyState, ErrorState, Loading, PageHeading } from '../components/State';
import { RecordList, closureLabel } from '../components/RecordList';
import { DocumentPane } from '../components/DocumentPane';
import { RecordDocumentsNav } from '../components/RecordDocumentsNav';

export default function RecordsPage({ kind }: { kind: Extract<RecordKind, 'change' | 'archive'> }) {
  const records = useRecords();
  const [params, setParams] = useSearchParams();
  const selected = params.get('selected') ?? '';
  const detail = useRecord(selected);
  const navigate = useNavigate();
  const domain = params.get('domain') ?? '';
  const search = params.get('q') ?? '';
  const closure = params.get('closure') ?? '';
  const date = params.get('date') ?? '';
  const update = (key: string, value: string) =>
    setParams((current) => {
      value ? current.set(key, value) : current.delete(key);
      return current;
    });
  const includeArchive = params.get('includeArchive') === '1';
  const available = useMemo(
    () =>
      records.data?.filter(
        (r) => r.kind === kind || (kind === 'change' && includeArchive && r.kind === 'archive'),
      ) ?? [],
    [records.data, kind, includeArchive],
  );
  const domains = [...new Set(available.map((r) => r.domain))].sort();
  const closures = [...new Set(available.map((r) => r.closure).filter((c): c is string => Boolean(c)))];
  const filtered = available.filter(
    (r) =>
      (!domain || r.domain === domain || r.domain.startsWith(`${domain}/`)) &&
      (!search || `${r.title} ${r.id} ${r.description ?? ''}`.toLowerCase().includes(search.toLowerCase())) &&
      (!closure || r.closure === closure) &&
      (!date || (kind === 'archive' ? r.archivedAt : r.createdAt)?.startsWith(date)),
  );
  const selectedDoc =
    detail.data?.documents.find((doc) => doc.path === params.get('doc')) ??
    detail.data?.documents.find((doc) => doc.path.endsWith('/proposal.md')) ??
    detail.data?.documents[0];
  return (
    <div className={`page records-page ${selected ? 'has-selection' : ''}`}>
      <PageHeading
        eyebrow={`OPENSPEC / ${kind === 'archive' ? 'ARCHIVE' : 'CHANGES'}`}
        title={kind === 'archive' ? '演进档案' : '正在发生的改变'}
        description={
          kind === 'archive'
            ? '回看每一次交付、取舍与替代，保留完整的决策上下文。'
            : '从意图出发，沿着任务与证据，把每个 Change 推向完成。'
        }
      >
        <span className="page-count">
          {available.length}
          <small>{kind === 'archive' ? '归档记录' : '活跃 Changes'}</small>
        </span>
      </PageHeading>
      {!selected && (
        <div className="filter-bar">
          <label className="search-field">
            <Search size={16} />
            <input
              aria-label="筛选记录"
              placeholder="搜索名称、ID 或描述…"
              value={search}
              onChange={(e) => update('q', e.target.value)}
            />
          </label>
          <select aria-label="筛选领域" value={domain} onChange={(e) => update('domain', e.target.value)}>
            <option value="">所有领域</option>
            {domains.map((d) => (
              <option key={d}>{d}</option>
            ))}
          </select>
          {kind === 'archive' && (
            <select aria-label="闭合结果" value={closure} onChange={(e) => update('closure', e.target.value)}>
              <option value="">所有闭合结果</option>
              {closures.map((c) => (
                <option value={c} key={c}>
                  {closureLabel(c)}
                </option>
              ))}
            </select>
          )}
          {date && (
            <button className="tag filter-tag" onClick={() => update('date', '')}>
              {date}
              <X size={12} />
            </button>
          )}
          <span className="filter-count">
            {filtered.length} 条记录{includeArchive ? ' · 含归档' : ''}
          </span>
        </div>
      )}
      <div className="records-workspace">
        {!selected && (
          <section className="panel records-index">
            {records.isPending ? (
              <Loading />
            ) : records.error ? (
              <ErrorState error={records.error} retry={() => void records.refetch()} />
            ) : (
              <RecordList
                records={filtered}
                selected={selected}
                compact={Boolean(selected)}
                onSelect={(key) =>
                  setParams((current) => {
                    current.set('selected', key);
                    current.delete('doc');
                    current.delete('mode');
                    return current;
                  })
                }
              />
            )}
          </section>
        )}
        {selected && (
          <section className="panel record-detail">
            <div className="record-detail-header">
              <button
                className="button record-back-button"
                title="返回记录"
                onClick={() =>
                  setParams((current) => {
                    current.delete('selected');
                    current.delete('doc');
                    current.delete('mode');
                    return current;
                  })
                }
              >
                <ArrowLeft size={15} />
                返回记录
              </button>
              <select
                className="record-switcher"
                aria-label="切换记录"
                value={selected}
                onChange={(event) =>
                  setParams((current) => {
                    current.set('selected', event.target.value);
                    current.delete('doc');
                    current.delete('mode');
                    current.delete('line');
                    return current;
                  })
                }
              >
                {!filtered.some((record) => record.key === selected) && (
                  <option value={selected}>{detail.data?.record.id ?? selected}</option>
                )}
                {filtered.map((record) => (
                  <option value={record.key} key={record.key}>
                    {record.id}
                  </option>
                ))}
              </select>
              {detail.data?.record.kind === 'change' && (
                <button
                  className="text-link"
                  onClick={() => navigate(`/tasks?change=${encodeURIComponent(detail.data!.record.id)}`)}
                >
                  <Network size={14} />
                  任务图
                  <ArrowUpRight size={13} />
                </button>
              )}
            </div>
            {detail.isPending ? (
              <Loading />
            ) : detail.error ? (
              <ErrorState error={detail.error} retry={() => void detail.refetch()} />
            ) : (
              <>
                <div className="artifact-strip">
                  {detail.data.artifacts.map((artifact) => (
                    <div
                      className={`artifact-step ${artifact.state === 'done' || artifact.state === 'complete' ? 'complete' : ''}`}
                      key={artifact.id}
                    >
                      {artifact.state === 'done' || artifact.state === 'complete' ? (
                        <CheckCircle2 size={15} />
                      ) : (
                        <CircleDashed size={15} />
                      )}
                      <span>{artifact.id}</span>
                      <small>{artifact.state}</small>
                    </div>
                  ))}
                </div>
                <div className="record-document-workspace">
                  <RecordDocumentsNav
                    key={detail.data.record.key}
                    documents={detail.data.documents}
                    basePath={detail.data.record.path}
                    selected={selectedDoc?.path}
                    onSelect={(path) =>
                      setParams((current) => {
                        current.set('doc', path);
                        current.delete('mode');
                        current.delete('line');
                        return current;
                      })
                    }
                  />
                  <div className="record-document-content">
                    {selectedDoc ? (
                      <DocumentPane path={selectedDoc.path} embedded />
                    ) : (
                      <EmptyState title="还没有文档">此记录还没有可阅读的 Markdown 产物。</EmptyState>
                    )}
                  </div>
                </div>
              </>
            )}
          </section>
        )}
      </div>
    </div>
  );
}
