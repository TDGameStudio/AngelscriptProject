import { ArrowUpRight, Check, CircleDashed, FolderOpen, TriangleAlert } from 'lucide-react';
import type { RecordSummary } from '../../shared/types';
import { formatDate } from '../lib/paths';
import { EmptyState } from './State';

export function Progress({ record }: { record: RecordSummary }) {
  if (record.kind !== 'change')
    return record.kind === 'archive' ? (
      <span className="tag">{closureLabel(record.closure)}</span>
    ) : (
      <span className="tag">当前规范</span>
    );
  if (record.invalid)
    return (
      <span className="tag warning">
        <TriangleAlert size={12} />
        计划需修复
      </span>
    );
  if (!record.progress?.total)
    return (
      <span className="tag muted">
        <CircleDashed size={12} />
        待编制任务
      </span>
    );
  const { complete, total } = record.progress;
  return (
    <div className="mini-progress">
      <span>
        {complete}
        <span className="muted-text"> / {total}</span>
      </span>
      <span className="progress-track">
        <span style={{ width: `${(complete / total) * 100}%` }} />
      </span>
      <span className="muted-text">{Math.round((complete / total) * 100)}%</span>
    </div>
  );
}
export function closureLabel(closure?: string) {
  return (
    ({ completed: '已完成', abandoned: '已放弃', superseded: '已被替代' } as Record<string, string>)[
      closure ?? ''
    ] ??
    closure ??
    '归档'
  );
}
export function RecordList({
  records,
  selected,
  onSelect,
  compact = false,
}: {
  records: RecordSummary[];
  selected?: string;
  onSelect: (key: string) => void;
  compact?: boolean;
}) {
  if (!records.length) return <EmptyState title="没有匹配的记录">调整领域或搜索关键词后重试。</EmptyState>;
  return (
    <div className={`record-list ${compact ? 'compact' : ''}`}>
      {records.map((record) => (
        <button
          className={`record-row ${selected === record.key ? 'selected' : ''}`}
          key={record.key}
          onClick={() => onSelect(record.key)}
        >
          <span className={`record-icon ${record.kind}`}>
            <FolderOpen size={19} />
          </span>
          <span className="record-main">
            <span className="record-domain">{record.domain || 'workspace'}</span>
            <strong>{record.title}</strong>
            <span className="record-id">{record.id}</span>
            {!compact && record.description && (
              <span className="record-description">{record.description}</span>
            )}
          </span>
          <span className="record-meta">
            <Progress record={record} />
            {record.kind === 'change' && (
              <span className={`artifact-state ${record.artifactComplete ? 'complete' : ''}`}>
                {record.artifactComplete ? (
                  <>
                    <Check size={12} />
                    产物齐备
                  </>
                ) : (
                  <>
                    <CircleDashed size={12} />
                    产物待完善
                  </>
                )}
              </span>
            )}
            <span className="record-date">{formatDate(record.archivedAt ?? record.createdAt)}</span>
          </span>
          <ArrowUpRight size={16} className="row-arrow" />
        </button>
      ))}
    </div>
  );
}
