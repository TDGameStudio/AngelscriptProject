import { lazy, Suspense } from 'react';
import type { RecordSummary, TaskPlan } from '../../shared/types';
import { useQueries, type UseQueryResult } from '@tanstack/react-query';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { Columns3, List, Network, X } from 'lucide-react';
import { api, useRecords } from '../lib/api';
import { documentUrl } from '../lib/paths';
import { EmptyState, ErrorState, Loading, PageHeading } from '../components/State';
import { invalidPlan, TaskBoard, TaskDetail, TaskList, taskStatus } from '../components/TaskViews';
const TaskGraph = lazy(() => import('../components/TaskGraph'));

export default function TasksPage() {
  const records = useRecords();
  const [params, setParams] = useSearchParams();
  const navigate = useNavigate();
  const changes = records.data?.filter((r) => r.kind === 'change') ?? [];
  const change = params.get('change') ?? '';
  const selected = params.get('task') ?? '';
  const view = params.get('view') ?? 'board';
  const status = params.get('status') ?? '';
  const taskChange = params.get('taskChange') ?? change;
  const candidates = changes.filter((record) => !change || record.id === change);
  const queries = useQueries({
    queries: candidates.map((record) => ({
      queryKey: ['tasks', record.id],
      queryFn: () => api.tasks(record.id),
    })),
  });
  const selectedIndex = candidates.findIndex((record) => record.id === taskChange);
  const selectedPlan = queries[selectedIndex]?.data;
  const selectedTask = selectedPlan?.tasks.find((task) => task.id === selected);
  const selectTask = (changeId: string, id: string) =>
    setParams((current) => {
      current.set('taskChange', changeId);
      current.set('task', id);
      return current;
    });
  const completed = queries.reduce((sum, query) => sum + (query.data?.progress.complete ?? 0), 0);
  const total = queries.reduce((sum, query) => sum + (query.data?.progress.total ?? 0), 0);
  const displayed = candidates.flatMap<{
    record: RecordSummary;
    query: UseQueryResult<TaskPlan, Error>;
    plan?: TaskPlan;
  }>((record, index) => {
    const query = queries[index]!;
    if (!query.data) return [{ record, query, plan: undefined }];
    if (status === 'invalid') return invalidPlan(query.data) ? [{ record, query, plan: query.data }] : [];
    if (status && invalidPlan(query.data)) return [];
    const filtered = status
      ? { ...query.data, tasks: query.data.tasks.filter((task) => taskStatus(task) === status) }
      : query.data;
    if (status && !filtered.tasks.length) return [];
    return [{ record, query, plan: filtered }];
  });
  return (
    <div className="page tasks-page">
      <PageHeading
        eyebrow="OPENSPEC / TASK EXPLORER"
        title="看清下一步"
        description="把依赖展开，让每项任务的来路、去向与验证方式都清晰可见。"
      >
        <div className="segmented">
          {[
            { id: 'list', label: '列表', icon: List },
            { id: 'board', label: '看板', icon: Columns3 },
            { id: 'graph', label: '依赖图', icon: Network },
          ].map((item) => (
            <button
              className={view === item.id ? 'active' : ''}
              key={item.id}
              onClick={() =>
                setParams((current) => {
                  current.set('view', item.id);
                  return current;
                })
              }
            >
              <item.icon size={15} />
              {item.label}
            </button>
          ))}
        </div>
      </PageHeading>
      <div className="filter-bar">
        <label className="field-label" htmlFor="task-change">
          Change
        </label>
        <select
          id="task-change"
          className="change-select"
          value={change}
          onChange={(e) =>
            setParams((current) => {
              e.target.value ? current.set('change', e.target.value) : current.delete('change');
              current.delete('task');
              current.delete('taskChange');
              return current;
            })
          }
        >
          <option value="">所有活跃 Changes</option>
          {changes.map((record) => (
            <option key={record.key} value={record.id}>
              {record.id}
            </option>
          ))}
        </select>
        {status && (
          <button
            className="tag filter-tag"
            onClick={() =>
              setParams((current) => {
                current.delete('status');
                return current;
              })
            }
          >
            {{ ready: '可开始', waiting: '等待依赖', done: '已完成', invalid: '无效计划' }[status] ?? status}
            <X size={12} />
          </button>
        )}
        <span className="filter-count">
          {completed} / {total} 已完成
        </span>
      </div>
      {records.isPending ? (
        <Loading />
      ) : records.error ? (
        <ErrorState error={records.error} retry={() => void records.refetch()} />
      ) : !changes.length ? (
        <EmptyState title="还没有活跃 Change">建立 Change 并编制任务后，可在这里探索依赖。</EmptyState>
      ) : (
        <div className={`tasks-workspace ${selectedTask ? 'with-detail' : ''}`}>
          <div className="tasks-canvas">
            {view === 'graph' && !change ? (
              <EmptyState title="选择一个 Change 查看依赖图">
                依赖图按单个 Change 展开；上方选择器可切换 Change。
              </EmptyState>
            ) : !displayed.length ? (
              <EmptyState title="没有匹配当前筛选的任务">清除状态筛选，或切换 Change。</EmptyState>
            ) : (
              displayed.map(({ record, query, plan }) => (
                <section className="task-group" key={record.key}>
                  {!change && (
                    <div className="task-group-title">
                      <strong>{record.id}</strong>
                      <button
                        onClick={() =>
                          setParams((current) => {
                            current.set('change', record.id);
                            return current;
                          })
                        }
                      >
                        聚焦此 Change
                      </button>
                    </div>
                  )}
                  {query.isPending ? (
                    <Loading label={`正在读取 ${record.id}…`} />
                  ) : query.error ? (
                    <ErrorState error={query.error} retry={() => void query.refetch()} />
                  ) : (
                    plan &&
                    (view === 'graph' ? (
                      <Suspense fallback={<Loading label="正在绘制依赖图…" />}>
                        <TaskGraph
                          plan={query.data!}
                          selected={taskChange === record.id ? selected : undefined}
                          onSelect={(id) => selectTask(record.id, id)}
                        />
                      </Suspense>
                    ) : view === 'list' ? (
                      <TaskList
                        plan={plan}
                        selected={taskChange === record.id ? selected : undefined}
                        onSelect={(id) => selectTask(record.id, id)}
                      />
                    ) : (
                      <TaskBoard
                        plan={plan}
                        selected={taskChange === record.id ? selected : undefined}
                        onSelect={(id) => selectTask(record.id, id)}
                      />
                    ))
                  )}
                </section>
              ))
            )}
          </div>
          {selectedTask && selectedPlan && (
            <div className="task-detail-shell">
              <button
                className="detail-close icon-button"
                aria-label="关闭任务详情"
                onClick={() =>
                  setParams((current) => {
                    current.delete('task');
                    current.delete('taskChange');
                    return current;
                  })
                }
              >
                <X size={15} />
              </button>
              <TaskDetail
                plan={selectedPlan}
                task={selectedTask}
                onSelect={(id) => selectTask(taskChange, id)}
                documentPath={`${candidates[selectedIndex]!.path}/tasks.md`}
                onDocument={(path, line) => navigate(documentUrl(path, { line: String(line) }))}
              />
            </div>
          )}
        </div>
      )}
    </div>
  );
}
