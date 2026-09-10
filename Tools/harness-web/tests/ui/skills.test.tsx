// @vitest-environment jsdom
import '@testing-library/jest-dom/vitest';
import { afterEach, beforeEach, expect, it, vi } from 'vitest';
import { cleanup, render, screen, waitFor, within } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import DocumentsPage from '../../src/client/pages/DocumentsPage';
import { api } from '../../src/client/lib/api';
import type { DocumentSummary, WorkspaceInfo } from '../../src/shared/types';

vi.mock('react-resizable-panels', async () => {
  // @ts-expect-error The package types describe its public export, not this browser test entry.
  return import('../../node_modules/react-resizable-panels/dist/react-resizable-panels.browser.js');
});

vi.mock('../../src/client/components/DocumentPane', () => ({
  DocumentPane: ({ path }: { path: string }) => <article aria-label="文档正文">{path || '未选择'}</article>,
}));

const browserEnvironment = (
  globalThis as typeof globalThis & {
    jsdom: { window: Window; reconfigure(options: { url: string }): void };
  }
).jsdom;
browserEnvironment.reconfigure({ url: 'http://localhost:3000/' });
const browserStorage = browserEnvironment.window.localStorage;

const workspace: WorkspaceInfo = {
  name: 'AngelscriptProject',
  root: 'D:/Workspace/AngelscriptProject',
  branch: 'main',
  sessionToken: 'token',
  cliAvailable: true,
  diagnostics: [],
};

const documents: DocumentSummary[] = [
  { path: 'README.md', title: 'Readme', readonly: false },
  { path: 'openspec/specs/harness/spec.md', title: 'Harness spec', readonly: false },
  { path: '.agents/skills/harness/SKILL.md', title: 'Harness', readonly: false },
  { path: '.agents/skills/harness/references/routing.md', title: 'Routing', readonly: false },
  { path: '.agents/skills/README.md', title: 'Skills index', readonly: false },
];

beforeEach(() => {
  browserStorage.clear();
  vi.stubGlobal('localStorage', browserStorage);
  window.matchMedia ??= ((query: string) => ({
    matches: false,
    media: query,
    onchange: null,
    addListener() {},
    removeListener() {},
    addEventListener() {},
    removeEventListener() {},
    dispatchEvent() {
      return false;
    },
  })) as typeof window.matchMedia;
  vi.spyOn(api, 'workspace').mockResolvedValue(workspace);
  vi.spyOn(api, 'documents').mockResolvedValue(documents);
});

afterEach(() => {
  cleanup();
  browserStorage.clear();
  vi.unstubAllGlobals();
  vi.restoreAllMocks();
});

function renderSkills() {
  return render(
    <QueryClientProvider client={new QueryClient({ defaultOptions: { queries: { retry: false } } })}>
      <MemoryRouter initialEntries={['/skills']}>
        <DocumentsPage skills />
      </MemoryRouter>
    </QueryClientProvider>,
  );
}

it('lists only markdown under .agents/skills and opens a skill document', async () => {
  renderSkills();
  const skill = await screen.findByTitle('.agents/skills/harness/SKILL.md');
  expect(skill).toBeVisible();
  expect(screen.getByTitle('.agents/skills/README.md')).toBeVisible();
  expect(screen.queryByTitle('README.md')).not.toBeInTheDocument();
  expect(screen.queryByTitle('openspec/specs/harness/spec.md')).not.toBeInTheDocument();
  expect(screen.getByLabelText('文档正文')).toHaveTextContent('.agents/skills/harness/SKILL.md');
});

it('exposes Skills in workspace navigation at /skills', async () => {
  vi.stubGlobal(
    'EventSource',
    class {
      onopen: (() => void) | null = null;
      onerror: (() => void) | null = null;
      addEventListener() {}
      close() {}
    },
  );
  const { default: App } = await import('../../src/client/App');
  render(
    <QueryClientProvider client={new QueryClient({ defaultOptions: { queries: { retry: false } } })}>
      <MemoryRouter initialEntries={['/skills']}>
        <App />
      </MemoryRouter>
    </QueryClientProvider>,
  );
  const nav = screen.getByRole('navigation', { name: '主导航' });
  expect(within(nav).getByRole('link', { name: 'Skills' })).toHaveAttribute('href', '/skills');
  await waitFor(() => expect(screen.getByTitle('.agents/skills/harness/SKILL.md')).toBeVisible());
  expect(screen.getByText('项目 Skills')).toBeVisible();
});
