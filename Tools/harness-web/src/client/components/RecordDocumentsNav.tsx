import { useId, useState } from 'react';
import { ChevronDown, Files, Search, X } from 'lucide-react';
import type { DocumentSummary } from '../../shared/types';
import { FileTree } from './FileTree';

export function RecordDocumentsNav({
  documents,
  basePath,
  selected,
  onSelect,
}: {
  documents: DocumentSummary[];
  basePath: string;
  selected?: string;
  onSelect: (path: string) => void;
}) {
  const [filter, setFilter] = useState('');
  const [expanded, setExpanded] = useState(false);
  const bodyId = useId();
  const matches = documents.filter((document) =>
    `${document.path.slice(basePath.length + 1)} ${document.title}`
      .toLowerCase()
      .includes(filter.trim().toLowerCase()),
  );
  return (
    <nav className={`record-documents-nav ${expanded ? 'files-expanded' : ''}`} aria-label="记录文档">
      <div className="record-files-heading">
        <Files size={15} />
        <strong>文件</strong>
        <span className="count-label">{documents.length}</span>
      </div>
      <button
        className="record-files-toggle"
        aria-expanded={expanded}
        aria-controls={bodyId}
        onClick={() => setExpanded(!expanded)}
      >
        <Files size={16} />
        <span>选择文档</span>
        <strong>{selected?.split('/').at(-1) ?? '尚未选择'}</strong>
        <ChevronDown size={15} />
      </button>
      <div className="record-files-body" id={bodyId}>
        <label className="search-field record-files-search">
          <Search size={14} />
          <input
            aria-label="筛选记录文档"
            placeholder="查找文件…"
            value={filter}
            onChange={(event) => setFilter(event.target.value)}
          />
          {filter && (
            <button className="icon-button" aria-label="清除文档筛选" onClick={() => setFilter('')}>
              <X size={13} />
            </button>
          )}
        </label>
        {matches.length ? (
          <FileTree
            documents={matches}
            basePath={basePath}
            selected={selected}
            expandAll={Boolean(filter.trim())}
            onSelect={(path) => {
              onSelect(path);
              setExpanded(false);
            }}
          />
        ) : (
          <p className="record-files-empty">没有匹配的文档</p>
        )}
        {filter && (
          <p className="record-files-match-count">
            {matches.length} / {documents.length} 个文件
          </p>
        )}
      </div>
    </nav>
  );
}
