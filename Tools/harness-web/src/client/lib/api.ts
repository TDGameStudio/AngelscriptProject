import { useQuery } from '@tanstack/react-query';
import type {
  ApiError,
  DocumentContent,
  DocumentSummary,
  Metrics,
  RecordDetail,
  RecordSummary,
  SearchHit,
  TaskPlan,
  WorkspaceInfo,
} from '../../shared/types';

export class RequestError extends Error {
  status: number;
  code?: string;
  current?: DocumentContent;
  constructor(status: number, body: ApiError) {
    super(body.message);
    this.status = status;
    this.code = body.code;
    this.current = body.current;
  }
}
export async function request<T>(url: string, init?: RequestInit): Promise<T> {
  const response = await fetch(url, init);
  const body = await response.json();
  if (!response.ok) throw new RequestError(response.status, body as ApiError);
  return body as T;
}
export const api = {
  workspace: () => request<WorkspaceInfo>('/api/workspace'),
  records: () => request<RecordSummary[]>('/api/records'),
  record: (key: string) => request<RecordDetail>(`/api/record?key=${encodeURIComponent(key)}`),
  tasks: (change: string) => request<TaskPlan>(`/api/tasks?change=${encodeURIComponent(change)}`),
  documents: () => request<DocumentSummary[]>('/api/documents'),
  document: (path: string) => request<DocumentContent>(`/api/document?path=${encodeURIComponent(path)}`),
  search: (q: string) => request<SearchHit[]>(`/api/search?q=${encodeURIComponent(q)}`),
  metrics: () => request<Metrics>('/api/metrics'),
  save: (path: string, content: string, baseRevision: string, session: string) =>
    request<DocumentContent>('/api/document', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json', 'X-Harness-Session': session },
      body: JSON.stringify({ path, content, baseRevision }),
    }),
};
export function useWorkspace() {
  return useQuery({ queryKey: ['workspace'], queryFn: api.workspace });
}
export function useRecords() {
  return useQuery({ queryKey: ['records'], queryFn: api.records });
}
export function useDocuments() {
  return useQuery({ queryKey: ['documents'], queryFn: api.documents });
}
export function useDocument(path: string) {
  return useQuery({
    queryKey: ['document', path],
    queryFn: () => api.document(path),
    enabled: Boolean(path),
  });
}
export function useRecord(key: string) {
  return useQuery({ queryKey: ['record', key], queryFn: () => api.record(key), enabled: Boolean(key) });
}
