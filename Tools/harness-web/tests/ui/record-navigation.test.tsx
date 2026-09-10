// @vitest-environment jsdom
import '@testing-library/jest-dom/vitest';
import { afterEach, expect, it, vi } from 'vitest';
import { cleanup, fireEvent, render, screen, within } from '@testing-library/react';
import { MemoryRouter, useLocation } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { RecordDocumentsNav } from '../../src/client/components/RecordDocumentsNav';
import RecordsPage from '../../src/client/pages/RecordsPage';
import { api } from '../../src/client/lib/api';
import type { DocumentSummary, RecordSummary } from '../../src/shared/types';

vi.mock('../../src/client/components/DocumentPane', () => ({
  DocumentPane: ({ path }: { path: string }) => (
    <article aria-label="文档正文">
      <p>{path}</p>
      <input aria-label="未保存文档内容" defaultValue="当前草稿" />
    </article>
  ),
}));
afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
});

const basePath = 'openspec/changes/harness/feature-alpha';
const documents: DocumentSummary[] = [
  { path: `${basePath}/proposal.md`, title: 'Proposal', readonly: false },
  { path: `${basePath}/design.md`, title: 'Design', readonly: false },
  { path: `${basePath}/specs/alpha/spec.md`, title: 'Alpha contract', readonly: false },
  { path: `${basePath}/specs/beta/spec.md`, title: 'Beta contract', readonly: false },
  {
    path: `${basePath}/attachments/data/very-long-browser-verification-evidence-filename.md`,
    title: 'Browser evidence',
    readonly: true,
  },
];
it('shows a vertical relative file tree with unambiguous nested selections and immediately reveals filtered files', () => {
  const select = vi.fn();
  render(
    <RecordDocumentsNav
      documents={documents}
      basePath={basePath}
      selected={`${basePath}/specs/alpha/spec.md`}
      onSelect={select}
    />,
  );
  const navigation = screen.getByRole('navigation', { name: '记录文档' });
  expect(within(navigation).queryByText('openspec')).not.toBeInTheDocument();
  expect(within(navigation).getByTitle(`${basePath}/specs/alpha/spec.md`)).toHaveAttribute(
    'aria-current',
    'page',
  );
  fireEvent.change(screen.getByLabelText('筛选记录文档'), { target: { value: 'specs/beta' } });
  const beta = within(navigation).getByTitle(`${basePath}/specs/beta/spec.md`);
  expect(beta).toBeVisible();
  fireEvent.click(beta);
  expect(select).toHaveBeenCalledWith(`${basePath}/specs/beta/spec.md`);
  fireEvent.change(screen.getByLabelText('筛选记录文档'), { target: { value: 'very-long-browser' } });
  expect(
    within(navigation).getByRole('button', { name: 'very-long-browser-verification-evidence-filename.md' }),
  ).toBeVisible();
  fireEvent.change(screen.getByLabelText('筛选记录文档'), { target: { value: 'no-matching-document' } });
  expect(within(navigation).getByText('没有匹配的文档')).toBeVisible();
});

function CurrentLocation() {
  const location = useLocation();
  return (
    <output data-testid="location">
      {location.pathname}
      {location.search}
    </output>
  );
}
it('prioritizes the selected document, preserves record filters on return, and clears editing state only when switching files', async () => {
  const records: RecordSummary[] = [
    {
      key: 'change:alpha',
      id: 'harness/feature-alpha',
      title: 'Change Alpha',
      kind: 'change',
      domain: 'harness',
      path: basePath,
    },
    {
      key: 'change:beta',
      id: 'harness/feature-beta',
      title: 'Change Beta',
      kind: 'change',
      domain: 'harness',
      path: 'openspec/changes/harness/feature-beta',
    },
  ];
  vi.spyOn(api, 'records').mockResolvedValue(records);
  vi.spyOn(api, 'record').mockResolvedValue({ record: records[0], documents, artifacts: [] });
  const initial = `/changes?selected=change%3Aalpha&domain=harness&q=Change&doc=${encodeURIComponent(documents[0].path)}&mode=edit&line=8`;
  render(
    <QueryClientProvider client={new QueryClient({ defaultOptions: { queries: { retry: false } } })}>
      <MemoryRouter initialEntries={[initial]}>
        <RecordsPage kind="change" />
        <CurrentLocation />
      </MemoryRouter>
    </QueryClientProvider>,
  );
  const navigation = await screen.findByRole('navigation', { name: '记录文档' });
  expect(document.querySelector('.records-index')).toBeNull();
  expect(screen.queryByRole('tablist')).not.toBeInTheDocument();
  const draft = screen.getByLabelText('未保存文档内容');
  fireEvent.change(draft, { target: { value: '编辑中的草稿' } });
  fireEvent.click(screen.getByRole('button', { name: /选择文档/ }));
  expect(screen.getByLabelText('未保存文档内容')).toBe(draft);
  expect(draft).toHaveValue('编辑中的草稿');
  expect(screen.getByTestId('location')).toHaveTextContent('mode=edit');
  fireEvent.click(within(navigation).getByRole('button', { name: 'design.md' }));
  const location = screen.getByTestId('location').textContent!;
  expect(location).toContain('doc=openspec%2Fchanges%2Fharness%2Ffeature-alpha%2Fdesign.md');
  expect(location).toContain('domain=harness');
  expect(location).toContain('q=Change');
  expect(location).not.toContain('mode=');
  expect(location).not.toContain('line=');
  expect(screen.getByRole('button', { name: /选择文档/ })).toHaveAttribute('aria-expanded', 'false');
  fireEvent.click(screen.getByRole('button', { name: '返回记录' }));
  expect(screen.getByRole('textbox', { name: '筛选记录' })).toHaveValue('Change');
  expect(screen.getByRole('combobox', { name: '筛选领域' })).toHaveValue('harness');
  expect(document.querySelector('.records-index')).not.toBeNull();
});
