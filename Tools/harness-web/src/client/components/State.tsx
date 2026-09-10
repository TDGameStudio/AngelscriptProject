import { AlertTriangle, ArrowUpRight, FileSearch, LoaderCircle } from 'lucide-react';
import type { ReactNode } from 'react';
export function Loading({ label = '正在读取工作区…' }: { label?: string }) {
  return (
    <div className="state-panel" role="status">
      <LoaderCircle className="spin" size={24} />
      <p>{label}</p>
    </div>
  );
}
export function ErrorState({ error, retry }: { error: unknown; retry?: () => void }) {
  return (
    <div className="state-panel error-state" role="alert">
      <AlertTriangle size={24} />
      <h3>暂时无法读取</h3>
      <p>{error instanceof Error ? error.message : String(error)}</p>
      {retry && (
        <button className="button" onClick={retry}>
          重新加载
        </button>
      )}
    </div>
  );
}
export function EmptyState({ title, children }: { title: string; children?: ReactNode }) {
  return (
    <div className="state-panel empty-state">
      <FileSearch size={30} strokeWidth={1.3} />
      <h3>{title}</h3>
      {children && <p>{children}</p>}
    </div>
  );
}
export function PageHeading({
  eyebrow,
  title,
  description,
  children,
}: {
  eyebrow: string;
  title: string;
  description?: string;
  children?: ReactNode;
}) {
  return (
    <header className="page-heading">
      <div>
        <span className="eyebrow">{eyebrow}</span>
        <h1>
          {title}
          <span className="heading-dot">.</span>
        </h1>
        {description && <p>{description}</p>}
      </div>
      {children && <div className="page-actions">{children}</div>}
    </header>
  );
}
export function PanelHeading({
  title,
  count,
  children,
}: {
  title: string;
  count?: number;
  children?: ReactNode;
}) {
  return (
    <div className="panel-heading">
      <h2>
        {title}
        {count !== undefined && <span className="count-label">{count}</span>}
      </h2>
      {children}
    </div>
  );
}
export function ExternalArrow() {
  return <ArrowUpRight size={15} aria-hidden />;
}
