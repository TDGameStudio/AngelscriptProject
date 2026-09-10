import { lazy, Suspense } from 'react';
import { useQuery } from '@tanstack/react-query';
import { Link, useNavigate } from 'react-router-dom';
import { Archive, ArrowRight, BookOpen, CheckCircle2, Layers3, Network, Sparkles } from 'lucide-react';
import { api, useDocuments, useRecords, useWorkspace } from '../lib/api';
import { documentUrl, formatDate } from '../lib/paths';
import { ErrorState, Loading, PageHeading, PanelHeading } from '../components/State';
import { RecordList } from '../components/RecordList';
const TaskChart = lazy(() => import('../components/Charts').then((m) => ({ default: m.TaskChart })));
const DomainChart = lazy(() => import('../components/Charts').then((m) => ({ default: m.DomainChart })));
const TimelineChart = lazy(() => import('../components/Charts').then((m) => ({ default: m.TimelineChart })));

export default function OverviewPage() {
  const metrics = useQuery({ queryKey: ['metrics'], queryFn: api.metrics });
  const records = useRecords();
  const docs = useDocuments();
  const workspace = useWorkspace();
  const navigate = useNavigate();
  return (
    <div className="page overview-page">
      <PageHeading
        eyebrow="WORKSPACE / OVERVIEW"
        title="把想法，推进成改变"
        description="规范、任务与证据，汇聚在同一个工作现场。"
      >
        <Link className="button primary" to="/changes">
          浏览 Changes <ArrowRight size={16} />
        </Link>
      </PageHeading>
      <div className="workspace-strip">
        <span className="status-light" />
        <span>{workspace.data?.name ?? '当前工作区'}</span>
        <span className="strip-divider" />
        <span className="mono">{workspace.data?.branch || 'detached'}</span>
        <span className="workspace-local">LOCAL WORKSPACE</span>
      </div>
      {metrics.isPending ? (
        <Loading />
      ) : metrics.error ? (
        <ErrorState error={metrics.error} retry={() => void metrics.refetch()} />
      ) : (
        <>
          <div className="stats-grid">
            {[
              {
                label: '活跃 Changes',
                value: metrics.data.records.changes,
                icon: Layers3,
                link: '/changes',
                hint: '从提案到交付',
              },
              {
                label: '当前 Specs',
                value: metrics.data.records.specs,
                icon: BookOpen,
                link: '/specs',
                hint: '持续演进的行为契约',
              },
              {
                label: '可开始任务',
                value: metrics.data.tasks.ready,
                icon: Network,
                link: '/tasks?status=ready',
                hint: '前置依赖已满足',
              },
              {
                label: '归档记录',
                value: metrics.data.records.archives,
                icon: Archive,
                link: '/archives',
                hint: '保存决策与演进证据',
              },
            ].map((item) => (
              <Link className="stat-card" to={item.link} key={item.label}>
                <div>
                  <span>{item.label}</span>
                  <item.icon size={18} />
                </div>
                <strong>{item.value.toLocaleString()}</strong>
                <span className="stat-hint">
                  {item.hint}
                  <ArrowRight size={14} />
                </span>
              </Link>
            ))}
          </div>
          <div className="overview-grid">
            <section className="panel active-changes">
              <PanelHeading title="正在推进" count={metrics.data.records.changes}>
                <Link className="text-link" to="/changes">
                  全部 Changes <ArrowRight size={14} />
                </Link>
              </PanelHeading>
              {records.isPending ? (
                <Loading />
              ) : records.error ? (
                <ErrorState error={records.error} />
              ) : (
                <RecordList
                  records={records.data.filter((r) => r.kind === 'change').slice(0, 5)}
                  compact
                  onSelect={(key) => navigate(`/changes?selected=${encodeURIComponent(key)}`)}
                />
              )}
            </section>
            <section className="panel">
              <PanelHeading title="任务状态">
                <CheckCircle2 size={16} className="muted-text" />
              </PanelHeading>
              <Suspense fallback={<Loading />}>
                <TaskChart
                  metrics={metrics.data}
                  onSelect={(status) => navigate(`/tasks?status=${status}`)}
                />
              </Suspense>
              <p className="panel-footnote">任务状态来自当前计划；无效计划单独计数。</p>
            </section>
            <section className="panel">
              <PanelHeading title="领域分布">
                <span className="eyebrow">CHANGES · SPECS</span>
              </PanelHeading>
              <Suspense fallback={<Loading />}>
                <DomainChart
                  metrics={metrics.data}
                  onSelect={(domain) => navigate(`/changes?domain=${encodeURIComponent(domain)}`)}
                />
              </Suspense>
            </section>
            <section className="panel">
              <PanelHeading title="创建与归档">
                <span className="eyebrow">RECORD EVENTS</span>
              </PanelHeading>
              <Suspense fallback={<Loading />}>
                <TimelineChart
                  metrics={metrics.data}
                  onSelect={(date, kind) =>
                    navigate(
                      kind === 'created'
                        ? `/changes?date=${date}&includeArchive=1`
                        : `/archives?date=${date}`,
                    )
                  }
                />
              </Suspense>
            </section>
          </div>
        </>
      )}
      <section className="panel recent-panel">
        <PanelHeading title="最近更新的文档">
          <Link className="text-link" to="/documents">
            文档库 <ArrowRight size={14} />
          </Link>
        </PanelHeading>
        {docs.isPending ? (
          <Loading />
        ) : docs.error ? (
          <ErrorState error={docs.error} />
        ) : (
          <div className="recent-documents">
            {[...docs.data]
              .sort((a, b) => (b.modifiedAt ?? '').localeCompare(a.modifiedAt ?? ''))
              .slice(0, 4)
              .map((doc) => (
                <Link to={documentUrl(doc.path)} key={doc.path}>
                  <span className="recent-doc-icon">
                    <BookOpen size={17} />
                  </span>
                  <span>
                    <strong>{doc.title}</strong>
                    <small title={doc.path}>{doc.path}</small>
                  </span>
                  <time>{formatDate(doc.modifiedAt)}</time>
                </Link>
              ))}
            {!docs.data.length && <p className="muted-text">工作区中暂无 Markdown 文档。</p>}
          </div>
        )}
      </section>
      <div className="workspace-caption">
        <Sparkles size={13} />
        一份规范，一条依赖，一次有据可查的前进。
      </div>
    </div>
  );
}
