// @vitest-environment jsdom
import '@testing-library/jest-dom/vitest';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { cleanup, fireEvent, render, screen, within } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { TaskBoard, TaskDetail } from '../../src/client/components/TaskViews';
import { RecordList } from '../../src/client/components/RecordList';
import { MarkdownDocument } from '../../src/client/components/MarkdownDocument';
import { resolveDocumentLink } from '../../src/client/lib/paths';
import type { TaskPlan } from '../../src/shared/types';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import TasksPage from '../../src/client/pages/TasksPage';
import { api } from '../../src/client/lib/api';

afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});
const plan: TaskPlan = {
  changeId: 'harness/feature-web',
  state: 'ready',
  taskIssues: [],
  missingRequires: [],
  progress: { total: 3, complete: 1, remaining: 2 },
  tasks: [
    {
      id: '1.1',
      description: '读取规范',
      done: true,
      ready: false,
      verify: 'npm test',
      after: [],
      files: ['spec.md'],
      line: 4,
    },
    {
      id: '1.2',
      description: '实现工作台',
      done: false,
      ready: true,
      verify: 'npm run test:ui',
      after: ['1.1'],
      files: ['client/**'],
      line: 8,
    },
    {
      id: '1.3',
      description: '验证交付',
      done: false,
      ready: false,
      verify: 'npm run test:e2e',
      after: ['1.2'],
      files: ['tests/**'],
      line: 12,
    },
  ],
};
describe('task views preserve native task facts', () => {
  it('groups tasks by actual readiness and retains selection across view changes', () => {
    const select = vi.fn();
    render(<TaskBoard plan={plan} selected="1.3" onSelect={select} />);
    expect(within(screen.getByRole('region', { name: '可开始' })).getByText('实现工作台')).toBeVisible();
    expect(within(screen.getByRole('region', { name: '等待依赖' })).getByText('验证交付')).toBeVisible();
    expect(within(screen.getByRole('region', { name: '已完成' })).getByText('读取规范')).toBeVisible();
    fireEvent.click(screen.getByRole('button', { name: /1.3 验证交付/ }));
    expect(select).toHaveBeenCalledWith('1.3');
  });
  it('shows task prerequisites, downstream impact and exact proof in detail rail', () => {
    const select = vi.fn();
    render(
      <TaskDetail
        plan={plan}
        task={plan.tasks[1]}
        onSelect={select}
        documentPath="openspec/changes/harness/feature-web/tasks.md"
        onDocument={vi.fn()}
      />,
    );
    expect(screen.getByText('npm run test:ui')).toBeVisible();
    expect(screen.getByText('client/**')).toBeVisible();
    fireEvent.click(screen.getByRole('button', { name: /1.1 读取规范/ }));
    expect(select).toHaveBeenCalledWith('1.1');
    expect(screen.getByRole('button', { name: /1.3 验证交付/ })).toBeVisible();
  });
  it('does not invent readiness for an invalid plan', () => {
    render(
      <TaskBoard
        plan={{ ...plan, state: 'invalid', taskIssues: [{ code: 'CYCLE', message: '存在循环依赖' }] }}
        onSelect={vi.fn()}
      />,
    );
    expect(screen.getByRole('alert')).toHaveTextContent('存在循环依赖');
    expect(screen.queryByRole('region', { name: '可开始' })).not.toBeInTheDocument();
  });
  it('keeps global status drilldowns across every matching Change', async () => {
    vi.spyOn(api, 'records').mockResolvedValue([
      {
        key: 'change:a',
        id: 'harness/a',
        kind: 'change',
        title: 'A',
        domain: 'harness',
        path: 'openspec/changes/harness/a',
      },
      {
        key: 'change:b',
        id: 'harness/b',
        kind: 'change',
        title: 'B',
        domain: 'harness',
        path: 'openspec/changes/harness/b',
      },
    ]);
    vi.spyOn(api, 'tasks').mockImplementation(async (id) => ({
      ...plan,
      changeId: id,
      tasks: plan.tasks.map((t) => ({ ...t, description: `${id} ${t.description}` })),
    }));
    render(
      <QueryClientProvider client={new QueryClient({ defaultOptions: { queries: { retry: false } } })}>
        <MemoryRouter initialEntries={['/tasks?status=ready']}>
          <TasksPage />
        </MemoryRouter>
      </QueryClientProvider>,
    );
    expect(await screen.findByText('harness/a 实现工作台')).toBeVisible();
    expect(await screen.findByText('harness/b 实现工作台')).toBeVisible();
    expect(screen.queryByText('harness/a 验证交付')).not.toBeInTheDocument();
    fireEvent.click(screen.getByRole('button', { name: /1.2 harness\/b 实现工作台/ }));
    expect(screen.getByRole('heading', { name: 'harness/b 实现工作台' })).toBeVisible();
    fireEvent.click(screen.getByRole('button', { name: '列表' }));
    expect(screen.getByRole('heading', { name: 'harness/b 实现工作台' })).toBeVisible();
  });
  it('distinguishes a status filter with no matches from an uncompiled plan', () => {
    render(<TaskBoard plan={{ ...plan, tasks: [] }} onSelect={vi.fn()} />);
    expect(screen.getByText('没有匹配当前筛选的任务')).toBeVisible();
    expect(screen.queryByText('任务待编制')).not.toBeInTheDocument();
  });
});
describe('record and document reading', () => {
  it('distinguishes a missing task plan from completion and artifact readiness', () => {
    render(
      <MemoryRouter>
        <RecordList
          records={[
            {
              key: 'change:one',
              id: 'harness/one',
              kind: 'change',
              title: '尚未编制的变更',
              path: 'openspec/changes/harness/one',
              domain: 'harness',
              artifactComplete: true,
            },
          ]}
          onSelect={vi.fn()}
        />
      </MemoryRouter>,
    );
    expect(screen.getByText('待编制任务')).toBeVisible();
    expect(screen.queryByText('100%')).not.toBeInTheDocument();
    expect(screen.getByText('产物齐备')).toBeVisible();
  });
  it('renders scenario nesting, a navigable outline and safe source links', () => {
    render(
      <MemoryRouter>
        <MarkdownDocument
          path="openspec/specs/harness/spec.md"
          content={
            '# Harness\n\n## 场景\n\n> - 条件\n>   - 结果\n\n[相关规范](../editor/spec.md)\n\n<script>alert(1)</script>'
          }
        />
      </MemoryRouter>,
    );
    expect(screen.getByRole('heading', { name: '场景' })).toBeVisible();
    expect(screen.getByRole('navigation', { name: '文档目录' })).toBeVisible();
    expect(screen.getByRole('link', { name: '相关规范' })).toHaveAttribute(
      'href',
      '/documents?path=openspec%2Fspecs%2Feditor%2Fspec.md',
    );
    expect(document.querySelector('script')).toBeNull();
  });
  it('resolves only workspace-local Markdown paths without escaping root', () => {
    expect(resolveDocumentLink('openspec/specs/harness/spec.md', '../editor/spec.md#scenario')).toEqual({
      path: 'openspec/specs/editor/spec.md',
      hash: '#scenario',
    });
    expect(resolveDocumentLink('README.md', '../../secrets.md')).toBeNull();
    expect(resolveDocumentLink('README.md', 'javascript:alert(1)')).toBeNull();
  });
  it('preserves source line navigation after frontmatter and aligns formatted duplicate outline headings', () => {
    const content =
      '---\ntask_graph:\n  version: 1\n---\n\n# **Task** `DAG`\n\n## [Scenario](other.md)\n\n- [ ] 1.2 Implement view\n\n## [Scenario](other.md)';
    render(
      <MemoryRouter>
        <MarkdownDocument path="tasks.md" content={content} line={10} />
      </MemoryRouter>,
    );
    expect(document.querySelector('li[data-line="10"]')).toHaveClass('source-highlight');
    const outline = screen.getByRole('navigation', { name: '文档目录' });
    expect(within(outline).getByRole('link', { name: 'Task DAG' })).toHaveAttribute('href', '#task-dag');
    expect(
      within(outline)
        .getAllByRole('link', { name: 'Scenario' })
        .map((a) => a.getAttribute('href')),
    ).toEqual(['#scenario', '#scenario-1']);
    expect(document.getElementById('scenario-1')).toHaveTextContent('Scenario');
  });
  it('retains source highlights through parent refreshes and outline changes using the nearest rendered source line', () => {
    const content = '---\ntitle: Tasks\n---\n\n# Plan\n\n- [ ] 1.1 First task\n\n- [ ] 1.2 Second task\n\n';
    const tree = () => (
      <MemoryRouter>
        <MarkdownDocument path="tasks.md" content={content} line={10} />
      </MemoryRouter>
    );
    const view = render(tree());
    expect(document.querySelector('li[data-line="9"]')).toHaveClass('source-highlight');
    view.rerender(tree());
    expect(document.querySelector('li[data-line="9"]')).toHaveClass('source-highlight');
    fireEvent.click(screen.getByRole('button', { name: '收起文档目录' }));
    expect(document.querySelector('li[data-line="9"]')).toHaveClass('source-highlight');
    expect(document.querySelector('li[data-line="7"]')).not.toHaveClass('source-highlight');
  });
});
