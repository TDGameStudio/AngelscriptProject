import { useEffect, useMemo, useState } from 'react';
import { ChevronRight, FileText, Folder, LockKeyhole } from 'lucide-react';
import type { DocumentSummary } from '../../shared/types';

interface Branch {
  name: string;
  path: string;
  children: Map<string, Branch>;
  document?: DocumentSummary;
}
function TreeBranch({
  item,
  selected,
  onSelect,
  expandAll = false,
}: {
  item: Branch;
  selected?: string;
  onSelect: (path: string) => void;
  expandAll?: boolean;
}) {
  const [open, setOpen] = useState(
    expandAll || Boolean(selected?.startsWith(`${item.path}/`)) || item.path === 'openspec',
  );
  useEffect(() => {
    if (expandAll || selected?.startsWith(`${item.path}/`)) setOpen(true);
  }, [selected, item.path, expandAll]);
  if (item.document)
    return (
      <button
        className={`tree-file ${item.path === selected ? 'active' : ''}`}
        title={item.path}
        aria-current={item.path === selected ? 'page' : undefined}
        onClick={() => onSelect(item.path)}
      >
        <FileText size={14} />
        <span>{item.name}</span>
        {item.document.readonly && <LockKeyhole size={11} />}
      </button>
    );
  return (
    <details className="tree-folder" open={open} onToggle={(event) => setOpen(event.currentTarget.open)}>
      <summary>
        <ChevronRight size={12} />
        <Folder size={14} />
        <span>{item.name}</span>
      </summary>
      {open && (
        <div>
          {[...item.children.values()]
            .sort(
              (a, b) =>
                Number(Boolean(a.document)) - Number(Boolean(b.document)) || a.name.localeCompare(b.name),
            )
            .map((child) => (
              <TreeBranch
                key={child.path}
                item={child}
                selected={selected}
                onSelect={onSelect}
                expandAll={expandAll}
              />
            ))}
        </div>
      )}
    </details>
  );
}
export function FileTree({
  documents,
  selected,
  onSelect,
  basePath = '',
  expandAll = false,
}: {
  documents: DocumentSummary[];
  selected?: string;
  onSelect: (path: string) => void;
  basePath?: string;
  expandAll?: boolean;
}) {
  const tree = useMemo(() => {
    const root: Branch = { name: '', path: '', children: new Map() };
    for (const doc of documents) {
      let cursor = root;
      const prefix = basePath && doc.path.startsWith(`${basePath}/`) ? `${basePath}/` : '';
      const parts = doc.path.slice(prefix.length).split('/');
      parts.forEach((part, index) => {
        if (!cursor.children.has(part))
          cursor.children.set(part, {
            name: part,
            path: prefix + parts.slice(0, index + 1).join('/'),
            children: new Map(),
          });
        cursor = cursor.children.get(part)!;
        if (index === parts.length - 1) cursor.document = doc;
      });
    }
    return root;
  }, [documents, basePath]);
  return (
    <div className="file-tree">
      {[...tree.children.values()]
        .sort(
          (a, b) => Number(Boolean(a.document)) - Number(Boolean(b.document)) || a.name.localeCompare(b.name),
        )
        .map((item) => (
          <TreeBranch
            key={item.path}
            item={item}
            selected={selected}
            onSelect={onSelect}
            expandAll={expandAll}
          />
        ))}
    </div>
  );
}
