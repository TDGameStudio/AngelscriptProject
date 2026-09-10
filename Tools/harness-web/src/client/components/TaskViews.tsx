import {
  ArrowDownRight,
  ArrowUpRight,
  CheckCircle2,
  Circle,
  Clock3,
  FileCode2,
  Link2,
  Terminal,
  TriangleAlert,
} from 'lucide-react';
import type { TaskNode, TaskPlan } from '../../shared/types';
import { EmptyState } from './State';

export function taskStatus(task: TaskNode) {
  return task.done ? 'done' : task.ready ? 'ready' : 'waiting';
}
export function TaskStatus({ task }: { task: TaskNode }) {
  const status = taskStatus(task);
  return (
    <span className={`tag ${status}`}>
      {status === 'done' ? (
        <CheckCircle2 size={12} />
      ) : status === 'waiting' ? (
        <Clock3 size={12} />
      ) : (
        <Circle size={12} />
      )}
      {status === 'done' ? '已完成' : status === 'waiting' ? '等待依赖' : '可开始'}
    </span>
  );
}
export function PlanIssues({ plan }: { plan: TaskPlan }) {
  return (
    <div className="plan-issues" role="alert">
      <TriangleAlert size={20} />
      <div>
        <strong>任务计划需要修复</strong>
        <p>修复任务源文件后，看板和依赖图将自动更新。</p>
        {plan.taskIssues.map((issue, i) => (
          <p key={i}>
            <code>{issue.code}</code> {issue.message}
          </p>
        ))}
        {plan.missingRequires.map((value) => (
          <p key={value}>缺少前置产物：{value}</p>
        ))}
      </div>
    </div>
  );
}
export function invalidPlan(plan: TaskPlan) {
  return plan.taskIssues.length > 0 || plan.state === 'invalid';
}
export function TaskBoard({
  plan,
  selected,
  onSelect,
}: {
  plan: TaskPlan;
  selected?: string;
  onSelect: (id: string) => void;
}) {
  if (invalidPlan(plan)) return <PlanIssues plan={plan} />;
  if (!plan.tasks.length)
    return (
      <EmptyState title={plan.progress.total ? '没有匹配当前筛选的任务' : '任务待编制'}>
        {plan.progress.total
          ? '清除状态筛选以查看此 Change 的其他任务。'
          : '此 Change 还没有任务。编制 tasks.md 后即可查看任务和依赖。'}
      </EmptyState>
    );
  const columns = [
    { id: 'ready', label: '可开始', icon: Circle },
    { id: 'waiting', label: '等待依赖', icon: Clock3 },
    { id: 'done', label: '已完成', icon: CheckCircle2 },
  ];
  return (
    <div className="task-board">
      {columns.map((column) => {
        const tasks = plan.tasks.filter((task) => taskStatus(task) === column.id);
        return (
          <section
            role="region"
            aria-label={column.label}
            className={`board-column ${column.id}`}
            key={column.id}
          >
            <header>
              <column.icon size={15} />
              <h2>{column.label}</h2>
              <span className="count-label">{tasks.length}</span>
            </header>
            <div className="board-cards">
              {tasks.map((task) => (
                <button
                  key={task.id}
                  className={`task-card ${selected === task.id ? 'selected' : ''}`}
                  aria-label={`${task.id} ${task.description}`}
                  aria-pressed={selected === task.id}
                  onClick={() => onSelect(task.id)}
                >
                  <span className="task-card-id">{task.id}</span>
                  <strong>{task.description}</strong>
                  <span className="task-card-footer">
                    {task.after.length ? (
                      <>
                        <Link2 size={12} />
                        {task.after.length} 个前置任务
                      </>
                    ) : (
                      <>
                        <Circle size={12} />
                        无前置依赖
                      </>
                    )}
                    <ArrowUpRight size={14} />
                  </span>
                </button>
              ))}
              {!tasks.length && <p className="board-empty">暂无{column.label}任务</p>}
            </div>
          </section>
        );
      })}
    </div>
  );
}
export function TaskList({
  plan,
  selected,
  onSelect,
}: {
  plan: TaskPlan;
  selected?: string;
  onSelect: (id: string) => void;
}) {
  if (invalidPlan(plan)) return <PlanIssues plan={plan} />;
  if (!plan.tasks.length)
    return <EmptyState title={plan.progress.total ? '没有匹配当前筛选的任务' : '任务待编制'} />;
  return (
    <div className="task-list">
      <div className="task-list-header">
        <span>任务</span>
        <span>依赖</span>
        <span>状态</span>
      </div>
      {plan.tasks.map((task) => (
        <button
          key={task.id}
          className={`task-list-row ${selected === task.id ? 'selected' : ''}`}
          onClick={() => onSelect(task.id)}
        >
          <span>
            <code>{task.id}</code>
            <strong>{task.description}</strong>
          </span>
          <span className="muted-text">{task.after.join(', ') || '—'}</span>
          <TaskStatus task={task} />
        </button>
      ))}
    </div>
  );
}
export function TaskDetail({
  plan,
  task,
  onSelect,
  documentPath,
  onDocument,
}: {
  plan: TaskPlan;
  task: TaskNode;
  onSelect: (id: string) => void;
  documentPath: string;
  onDocument: (path: string, line: number) => void;
}) {
  const after = task.after
    .map((id) => plan.tasks.find((item) => item.id === id))
    .filter((item): item is TaskNode => Boolean(item));
  const downstream = plan.tasks.filter((item) => item.after.includes(task.id));
  return (
    <aside className="task-detail">
      <div className="detail-eyebrow">
        TASK <span>{task.id}</span>
      </div>
      <h2>{task.description}</h2>
      <TaskStatus task={task} />
      <section>
        <h3>
          <ArrowDownRight size={14} />
          前置依赖 <span>{after.length}</span>
        </h3>
        {after.length ? (
          after.map((item) => (
            <button
              className="dependency-link"
              aria-label={`${item.id} ${item.description}`}
              key={item.id}
              onClick={() => onSelect(item.id)}
            >
              {item.done ? <CheckCircle2 size={14} className="teal" /> : <Clock3 size={14} />}
              <code>{item.id}</code>
              <span>{item.description}</span>
            </button>
          ))
        ) : (
          <p className="muted-text">此任务没有前置依赖。</p>
        )}
      </section>
      <section>
        <h3>
          <ArrowUpRight size={14} />
          后续影响 <span>{downstream.length}</span>
        </h3>
        {downstream.length ? (
          downstream.map((item) => (
            <button
              className="dependency-link"
              aria-label={`${item.id} ${item.description}`}
              key={item.id}
              onClick={() => onSelect(item.id)}
            >
              <code>{item.id}</code>
              <span>{item.description}</span>
            </button>
          ))
        ) : (
          <p className="muted-text">此任务没有直接后续任务。</p>
        )}
      </section>
      <section>
        <h3>
          <Terminal size={14} />
          验证命令
        </h3>
        <pre className="verify-command">{task.verify || '未提供验证命令'}</pre>
      </section>
      <section>
        <h3>
          <FileCode2 size={14} />
          文件范围
        </h3>
        {task.files.length ? (
          <ul className="file-scopes">
            {task.files.map((path) => (
              <li key={path}>
                <code>{path}</code>
              </li>
            ))}
          </ul>
        ) : (
          <p className="muted-text">未声明文件范围。</p>
        )}
      </section>
      <button className="button source-button" onClick={() => onDocument(documentPath, task.line)}>
        查看任务源文档 <ArrowUpRight size={15} />
      </button>
    </aside>
  );
}
