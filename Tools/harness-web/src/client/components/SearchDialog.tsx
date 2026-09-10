import * as Dialog from '@radix-ui/react-dialog';
import { useDeferredValue, useEffect, useRef, useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { useVirtualizer } from '@tanstack/react-virtual';
import { useNavigate } from 'react-router-dom';
import { ArrowUpRight, FileText, Search, X } from 'lucide-react';
import { readPreference } from '../lib/preferences';
import { api, useWorkspace } from '../lib/api';
import { documentUrl } from '../lib/paths';
import { EmptyState, ErrorState, Loading } from './State';

export function SearchDialog({
  open,
  onOpenChange,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}) {
  const workspace = useWorkspace();
  const [text, setText] = useState('');
  const [active, setActive] = useState(0);
  const query = useDeferredValue(text);
  const navigate = useNavigate();
  const parent = useRef<HTMLDivElement>(null);
  const results = useQuery({
    queryKey: ['search', query],
    queryFn: () => api.search(query),
    enabled: open && query.trim().length > 0,
  });
  const hits = results.data ?? [];
  const virtualizer = useVirtualizer({
    count: hits.length,
    getScrollElement: () => parent.current,
    estimateSize: () => 88,
    overscan: 5,
  });
  useEffect(() => {
    setActive(0);
  }, [query]);
  const go = (index: number) => {
    const hit = hits[index];
    if (!hit) return;
    navigate(documentUrl(hit.path, { line: String(hit.line) }));
    onOpenChange(false);
  };
  const storedRecent = readPreference<string[]>(workspace.data?.root, 'recent', []);
  const recent = Array.isArray(storedRecent) ? storedRecent.filter((path) => typeof path === 'string') : [];
  return (
    <Dialog.Root open={open} onOpenChange={onOpenChange}>
      <Dialog.Portal>
        <Dialog.Overlay className="dialog-overlay" />
        <Dialog.Content
          className="search-dialog"
          onKeyDown={(event) => {
            if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
              event.preventDefault();
              const next = Math.min(
                Math.max(active + (event.key === 'ArrowDown' ? 1 : -1), 0),
                hits.length - 1,
              );
              setActive(next);
              virtualizer.scrollToIndex(next);
            }
            if (event.key === 'Enter' && hits.length) {
              event.preventDefault();
              go(active);
            }
          }}
        >
          <Dialog.Title className="sr-only">搜索工作区</Dialog.Title>
          <Dialog.Description className="sr-only">
            搜索文档正文，使用上下方向键选择结果，回车打开。
          </Dialog.Description>
          <div className="command-input">
            <Search size={20} />
            <input
              aria-label="全局搜索"
              autoFocus
              value={text}
              onChange={(event) => setText(event.target.value)}
              placeholder="搜索文档、规范或任务…"
            />
            <Dialog.Close className="icon-button" aria-label="关闭搜索">
              <X size={17} />
            </Dialog.Close>
          </div>
          {!query.trim() ? (
            <div className="search-intro">
              <span className="eyebrow">最近打开</span>
              {recent.length ? (
                recent.map((path) => (
                  <button
                    key={path}
                    onClick={() => {
                      navigate(documentUrl(path));
                      onOpenChange(false);
                    }}
                  >
                    <FileText size={16} />
                    <span>{path}</span>
                    <ArrowUpRight size={14} />
                  </button>
                ))
              ) : (
                <p>输入关键词，搜索当前工作区的 Markdown 内容。</p>
              )}
              <span className="eyebrow">快速导航</span>
              <div className="search-shortcuts">
                {[
                  { path: '/changes', label: 'Changes' },
                  { path: '/specs', label: 'Specs' },
                  { path: '/tasks', label: '任务看板' },
                  { path: '/documents', label: '文档库' },
                ].map((item) => (
                  <button
                    key={item.path}
                    onClick={() => {
                      navigate(item.path);
                      onOpenChange(false);
                    }}
                  >
                    {item.label}
                    <ArrowUpRight size={13} />
                  </button>
                ))}
              </div>
            </div>
          ) : results.isPending ? (
            <Loading label="正在搜索…" />
          ) : results.error ? (
            <ErrorState error={results.error} retry={() => void results.refetch()} />
          ) : !hits.length ? (
            <EmptyState title="没有找到匹配内容">尝试更短的关键词，或使用文件名搜索。</EmptyState>
          ) : (
            <div className="search-results" ref={parent} role="listbox" aria-label="搜索结果">
              <div style={{ height: virtualizer.getTotalSize(), position: 'relative' }}>
                {virtualizer.getVirtualItems().map((item) => {
                  const hit = hits[item.index]!;
                  return (
                    <button
                      className={`search-result ${active === item.index ? 'active' : ''}`}
                      key={`${hit.path}:${hit.line}:${item.index}`}
                      role="option"
                      aria-selected={active === item.index}
                      onMouseEnter={() => setActive(item.index)}
                      onClick={() => go(item.index)}
                      style={{
                        position: 'absolute',
                        top: 0,
                        left: 0,
                        width: '100%',
                        height: item.size,
                        transform: `translateY(${item.start}px)`,
                      }}
                    >
                      <FileText size={18} />
                      <span>
                        <strong>{hit.title}</strong>
                        <small>{hit.excerpt}</small>
                        <code>
                          {hit.path}:{hit.line}
                        </code>
                      </span>
                      <ArrowUpRight size={14} />
                    </button>
                  );
                })}
              </div>
            </div>
          )}
          <footer className="search-footer">
            <span>
              <kbd>↑</kbd>
              <kbd>↓</kbd> 选择
            </span>
            <span>
              <kbd>↵</kbd> 打开
            </span>
            <span>
              <kbd>esc</kbd> 关闭
            </span>
            {query && <span>{hits.length} 个结果</span>}
          </footer>
        </Dialog.Content>
      </Dialog.Portal>
    </Dialog.Root>
  );
}
