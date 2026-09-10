// @vitest-environment jsdom
import '@testing-library/jest-dom/vitest';
import { afterEach, beforeEach, expect, it, vi } from 'vitest';
import { cleanup, fireEvent, render, screen, waitFor } from '@testing-library/react';
import { Link, MemoryRouter, useLocation } from 'react-router-dom';
import { useNavigationPreferences } from '../../src/client/lib/preferences';
import { WorkspacePanels } from '../../src/client/components/WorkspacePanels';

// Exercise the actual browser build; Vitest's Node export is intentionally inert for SSR.
vi.mock('react-resizable-panels', async () => {
  // @ts-expect-error The package types describe its public export, not this browser test entry.
  return import('../../node_modules/react-resizable-panels/dist/react-resizable-panels.browser.js');
});

// Vitest keeps Node 25's pre-existing localStorage global when populating window.
// Bind the actual JSDOM Storage for a concrete origin instead of a storage mock.
const browserEnvironment = (
  globalThis as typeof globalThis & {
    jsdom: { window: Window; reconfigure(options: { url: string }): void };
  }
).jsdom;
browserEnvironment.reconfigure({ url: 'http://localhost:3000/' });
const browserStorage = browserEnvironment.window.localStorage;
beforeEach(() => {
  browserStorage.clear();
  vi.stubGlobal('localStorage', browserStorage);
});

afterEach(() => {
  cleanup();
  browserStorage.clear();
  vi.unstubAllGlobals();
});
function NavigationHarness({ workspace }: { workspace: string }) {
  const location = useLocation();
  const destination = useNavigationPreferences(workspace);
  return (
    <>
      <output>
        {location.pathname}
        {location.search}
      </output>
      <Link to={destination('/tasks')}>任务侧栏</Link>
      <Link to="/documents">切换文档</Link>
      <Link to={destination('/tasks?status=done')}>明确状态</Link>
    </>
  );
}
it('restores sidebar page filters without replacing explicit navigation and keeps workspaces separate', async () => {
  const first = render(
    <MemoryRouter initialEntries={['/tasks?status=ready&view=list&mode=edit']}>
      <NavigationHarness workspace="D:/one" />
    </MemoryRouter>,
  );
  fireEvent.click(screen.getByRole('link', { name: '切换文档' }));
  expect(screen.getByRole('link', { name: '任务侧栏' })).toHaveAttribute(
    'href',
    '/tasks?status=ready&view=list',
  );
  fireEvent.click(screen.getByRole('link', { name: '任务侧栏' }));
  expect(screen.getByRole('status')).toHaveTextContent('/tasks?status=ready&view=list');
  fireEvent.click(screen.getByRole('link', { name: '明确状态' }));
  expect(screen.getByRole('status')).toHaveTextContent('/tasks?status=done');
  first.unmount();
  render(
    <MemoryRouter initialEntries={['/documents']}>
      <NavigationHarness workspace="D:/two" />
    </MemoryRouter>,
  );
  expect(screen.getByRole('link', { name: '任务侧栏' })).toHaveAttribute('href', '/tasks');
});
it('uses the panel library keyboard resizing and restores layout only for its workspace', async () => {
  const contents = { first: <div>文件树</div>, second: <div>文档内容</div> };
  const first = render(<WorkspacePanels workspaceId="D:/one" name="documents" {...contents} />);
  const handle = screen.getByRole('separator', { name: '调整面板宽度' });
  await waitFor(() => expect(handle).toHaveAttribute('aria-valuenow', '24'));
  fireEvent.keyDown(handle, { key: 'ArrowRight' });
  await waitFor(() => expect(handle).toHaveAttribute('aria-valuenow', '29'));
  await waitFor(() =>
    expect(Object.keys(window.localStorage).some((key) => key.includes('D%3A%2Fone'))).toBe(true),
  );
  first.unmount();
  const second = render(<WorkspacePanels workspaceId="D:/one" name="documents" {...contents} />);
  await waitFor(() => expect(screen.getByRole('separator')).toHaveAttribute('aria-valuenow', '29'));
  second.unmount();
  render(<WorkspacePanels workspaceId="D:/two" name="documents" {...contents} />);
  expect(screen.getByRole('separator')).toHaveAttribute('aria-valuenow', '24');
});

it('restores saved widths after cold loading the workspace identity without remounting content on focus changes', async () => {
  const contents = {
    first: <div>文件树</div>,
    second: <input aria-label="未保存内容" defaultValue="草稿" />,
  };
  const seed = render(<WorkspacePanels workspaceId="D:/reload" name="documents" {...contents} />);
  fireEvent.keyDown(screen.getByRole('separator'), { key: 'ArrowRight' });
  await waitFor(() => expect(screen.getByRole('separator')).toHaveAttribute('aria-valuenow', '29'));
  await waitFor(() => {
    const key = Object.keys(browserStorage).find((item) => item.includes('D%3A%2Freload'));
    expect(key && browserStorage.getItem(key)).toContain('[29,71]');
  });
  seed.unmount();

  const cold = render(<WorkspacePanels name="documents" {...contents} />);
  expect(screen.queryByRole('separator')).not.toBeInTheDocument();
  expect(screen.getByRole('status')).toHaveTextContent('正在读取工作区布局');
  cold.rerender(<WorkspacePanels workspaceId="D:/reload" name="documents" {...contents} />);
  await waitFor(() => expect(screen.getByRole('separator')).toHaveAttribute('aria-valuenow', '29'));
  fireEvent.change(screen.getByLabelText('未保存内容'), { target: { value: '仍在编辑的草稿' } });
  cold.rerender(<WorkspacePanels workspaceId="D:/reload" name="documents" focused {...contents} />);
  expect(screen.getByLabelText('未保存内容')).toHaveValue('仍在编辑的草稿');
  cold.rerender(<WorkspacePanels workspaceId="D:/reload" name="documents" {...contents} />);
  expect(screen.getByLabelText('未保存内容')).toHaveValue('仍在编辑的草稿');
  expect(screen.getByRole('separator')).toHaveAttribute('aria-valuenow', '29');
});
