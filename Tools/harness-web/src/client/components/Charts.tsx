import {
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  Legend,
  Pie,
  PieChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';
import type { Metrics } from '../../shared/types';
import { EmptyState } from './State';
const colors = ['#2563eb', '#b7791f', '#13866a', '#c64e52'];
export function TaskChart({ metrics, onSelect }: { metrics: Metrics; onSelect: (status: string) => void }) {
  const data = [
    { name: '可开始', value: metrics.tasks.ready, status: 'ready' },
    { name: '等待依赖', value: metrics.tasks.waiting, status: 'waiting' },
    { name: '已完成', value: metrics.tasks.done, status: 'done' },
  ];
  if (!data.some((item) => item.value) && !metrics.tasks.invalid)
    return <EmptyState title="还没有任务统计">已编制的任务会出现在这里。</EmptyState>;
  return (
    <div className="task-chart">
      <div className="donut">
        <ResponsiveContainer width="100%" height={195}>
          <PieChart>
            <Pie
              isAnimationActive={false}
              data={data}
              dataKey="value"
              nameKey="name"
              innerRadius={61}
              outerRadius={82}
              paddingAngle={4}
              stroke="none"
              onClick={(_, index) => onSelect(data[index]!.status)}
            >
              {data.map((item, index) => (
                <Cell key={item.status} fill={colors[index]} cursor="pointer" />
              ))}
            </Pie>
            <Tooltip />
          </PieChart>
        </ResponsiveContainer>
        <div className="donut-label">
          <strong>{metrics.tasks.ready + metrics.tasks.waiting + metrics.tasks.done}</strong>
          <span>任务总数</span>
        </div>
      </div>
      <div className="chart-legend">
        {data.map((item, i) => (
          <button key={item.status} onClick={() => onSelect(item.status)}>
            <span className="legend-dot" style={{ background: colors[i] }} />
            <span>{item.name}</span>
            <strong>{item.value}</strong>
          </button>
        ))}
        {metrics.tasks.invalid > 0 && (
          <button className="invalid-plan-count" onClick={() => onSelect('invalid')}>
            <span className="legend-dot" style={{ background: colors[3] }} />
            <span>无效计划</span>
            <strong>{metrics.tasks.invalid}</strong>
          </button>
        )}
      </div>
    </div>
  );
}
export function DomainChart({ metrics, onSelect }: { metrics: Metrics; onSelect: (domain: string) => void }) {
  if (!metrics.domains.length) return <EmptyState title="还没有领域统计" />;
  return (
    <>
      <ResponsiveContainer width="100%" height={Math.max(190, Math.min(metrics.domains.length * 45, 320))}>
        <BarChart
          layout="vertical"
          data={metrics.domains.slice(0, 7)}
          margin={{ left: 0, right: 15, top: 5, bottom: 0 }}
        >
          <CartesianGrid horizontal={false} strokeDasharray="3 3" stroke="var(--border)" />
          <XAxis
            type="number"
            allowDecimals={false}
            tick={{ fill: 'var(--muted)', fontSize: 11 }}
            axisLine={false}
            tickLine={false}
          />
          <YAxis
            dataKey="domain"
            tickFormatter={(value) =>
              String(value).length > 16 ? `…/${String(value).split('/').at(-1)}` : String(value)
            }
            type="category"
            width={95}
            tick={{ fill: 'var(--muted)', fontSize: 11 }}
            axisLine={false}
            tickLine={false}
          />
          <Tooltip />
          <Legend />
          <Bar
            isAnimationActive={false}
            dataKey="changes"
            name="Changes"
            stackId="domain"
            fill="#2563eb"
            maxBarSize={18}
            cursor="pointer"
            onClick={(_, index) => onSelect(metrics.domains[index]!.domain)}
          />
          <Bar
            isAnimationActive={false}
            dataKey="specs"
            name="Specs"
            stackId="domain"
            fill="#13866a"
            radius={[0, 3, 3, 0]}
            maxBarSize={18}
            cursor="pointer"
            onClick={(_, index) => onSelect(metrics.domains[index]!.domain)}
          />
        </BarChart>
      </ResponsiveContainer>
      <details className="chart-data">
        <summary>查看统计表</summary>
        <table>
          <thead>
            <tr>
              <th>领域</th>
              <th>Changes</th>
              <th>Specs</th>
            </tr>
          </thead>
          <tbody>
            {metrics.domains.map((d) => (
              <tr key={d.domain}>
                <td>
                  <button onClick={() => onSelect(d.domain)}>{d.domain}</button>
                </td>
                <td>{d.changes}</td>
                <td>{d.specs}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </details>
    </>
  );
}
export function TimelineChart({
  metrics,
  onSelect,
}: {
  metrics: Metrics;
  onSelect: (date: string, kind: string) => void;
}) {
  if (!metrics.timeline.length)
    return <EmptyState title="暂无创建与归档时间记录">只有记录中明确的日期会进入趋势图。</EmptyState>;
  return (
    <>
      <ResponsiveContainer width="100%" height={210}>
        <BarChart data={metrics.timeline} margin={{ top: 12, right: 8, left: -26, bottom: 0 }}>
          <CartesianGrid vertical={false} strokeDasharray="3 3" stroke="var(--border)" />
          <XAxis
            dataKey="date"
            tick={{ fill: 'var(--muted)', fontSize: 10 }}
            tickFormatter={(value) => String(value).slice(5)}
            axisLine={false}
            tickLine={false}
          />
          <YAxis
            allowDecimals={false}
            tick={{ fill: 'var(--muted)', fontSize: 10 }}
            axisLine={false}
            tickLine={false}
          />
          <Tooltip />
          <Legend />
          <Bar
            isAnimationActive={false}
            dataKey="created"
            name="创建"
            fill="#2563eb"
            radius={[3, 3, 0, 0]}
            maxBarSize={22}
            cursor="pointer"
            onClick={(_, index) => onSelect(metrics.timeline[index]!.date, 'created')}
          />
          <Bar
            isAnimationActive={false}
            dataKey="archived"
            name="归档"
            fill="#13866a"
            radius={[3, 3, 0, 0]}
            maxBarSize={22}
            cursor="pointer"
            onClick={(_, index) => onSelect(metrics.timeline[index]!.date, 'archives')}
          />
        </BarChart>
      </ResponsiveContainer>
      <details className="chart-data">
        <summary>查看时间记录</summary>
        <table>
          <thead>
            <tr>
              <th>日期</th>
              <th>创建</th>
              <th>归档</th>
            </tr>
          </thead>
          <tbody>
            {metrics.timeline.map((t) => (
              <tr key={t.date}>
                <td>{t.date}</td>
                <td>
                  <button onClick={() => onSelect(t.date, 'created')}>{t.created}</button>
                </td>
                <td>
                  <button onClick={() => onSelect(t.date, 'archives')}>{t.archived}</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </details>
    </>
  );
}
