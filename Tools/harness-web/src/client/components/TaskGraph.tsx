import { useMemo } from 'react';
import { Background, Controls, MarkerType, ReactFlow, type Edge, type Node } from '@xyflow/react';
import dagre from '@dagrejs/dagre';
import '@xyflow/react/dist/style.css';
import type { TaskPlan } from '../../shared/types';
import { invalidPlan, PlanIssues, taskStatus } from './TaskViews';
import { EmptyState } from './State';

export default function TaskGraph({
  plan,
  selected,
  onSelect,
}: {
  plan: TaskPlan;
  selected?: string;
  onSelect: (id: string) => void;
}) {
  const { nodes, edges } = useMemo(() => {
    const graph = new dagre.graphlib.Graph()
      .setDefaultEdgeLabel(() => ({}))
      .setGraph({ rankdir: 'TB', nodesep: 28, ranksep: 64, marginx: 35, marginy: 35 });
    plan.tasks.forEach((task) => graph.setNode(task.id, { width: 235, height: 100 }));
    plan.tasks.forEach((task) => task.after.forEach((id) => graph.setEdge(id, task.id)));
    if (!invalidPlan(plan)) dagre.layout(graph);
    const related = new Set(
      selected
        ? [
            selected,
            ...(plan.tasks.find((t) => t.id === selected)?.after ?? []),
            ...plan.tasks.filter((t) => t.after.includes(selected)).map((t) => t.id),
          ]
        : plan.tasks.map((t) => t.id),
    );
    const nodes: Node[] = plan.tasks.map((task) => {
      const position = graph.node(task.id);
      return {
        id: task.id,
        position: { x: (position?.x ?? 0) - 117, y: (position?.y ?? 0) - 50 },
        data: {
          label: (
            <div className="graph-node-label">
              <span>
                <code>{task.id}</code>
                <span className={`graph-status ${taskStatus(task)}`}>
                  {task.done ? '已完成' : task.ready ? '可开始' : '等待'}
                </span>
              </span>
              <strong>{task.description}</strong>
            </div>
          ),
        },
        className: `graph-node ${selected === task.id ? 'focused' : ''} ${selected && !related.has(task.id) ? 'dimmed' : ''}`,
        style: { width: 235, height: 100 },
        selected: task.id === selected,
      };
    });
    const edges: Edge[] = plan.tasks.flatMap((task) =>
      task.after.map((id) => ({
        id: `${id}:${task.id}`,
        source: id,
        target: task.id,
        markerEnd: { type: MarkerType.ArrowClosed },
        style: {
          stroke: selected && (id === selected || task.id === selected) ? 'var(--accent)' : 'var(--edge)',
          strokeWidth: selected && (id === selected || task.id === selected) ? 2.4 : 1.2,
          opacity: selected && !related.has(id) ? 0.25 : 1,
        },
      })),
    );
    return { nodes, edges };
  }, [plan, selected]);
  if (invalidPlan(plan)) return <PlanIssues plan={plan} />;
  if (!plan.tasks.length) return <EmptyState title="任务待编制">添加任务和依赖后可查看 DAG。</EmptyState>;
  return (
    <div className="task-graph" aria-label="任务依赖图">
      <div className="graph-hint">选择任务，聚焦前置依赖与后续影响</div>
      <ReactFlow
        nodes={nodes}
        edges={edges}
        fitView
        minZoom={0.25}
        maxZoom={1.5}
        nodesDraggable={false}
        nodesConnectable={false}
        onNodeClick={(_, node) => onSelect(node.id)}
        colorMode={document.documentElement.dataset.theme === 'dark' ? 'dark' : 'light'}
      >
        <Background gap={22} size={1} />
        <Controls showInteractive={false} />
      </ReactFlow>
    </div>
  );
}
