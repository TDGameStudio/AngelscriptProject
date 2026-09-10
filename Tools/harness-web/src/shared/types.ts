export type RecordKind = 'domain' | 'spec' | 'change' | 'archive';
export interface RecordSummary {
  key: string;
  id: string;
  kind: RecordKind;
  title: string;
  description?: string;
  path: string;
  domain: string;
  createdAt?: string;
  archivedAt?: string;
  closure?: string;
  progress?: { total: number; complete: number; remaining: number };
  artifactComplete?: boolean;
  invalid?: boolean;
}
export interface DocumentSummary {
  path: string;
  title: string;
  readonly: boolean;
  readonlyReason?: string;
  modifiedAt?: string;
}
export interface DocumentContent extends DocumentSummary {
  content: string;
  revision: string;
}
export interface TaskNode {
  id: string;
  description: string;
  done: boolean;
  verify: string;
  after: string[];
  files: string[];
  ready: boolean;
  line: number;
}
export interface TaskIssue {
  code: string;
  message: string;
  line?: number;
  taskId?: string;
}
export interface TaskPlan {
  changeId: string;
  tasks: TaskNode[];
  taskIssues: TaskIssue[];
  state: string;
  progress: { total: number; complete: number; remaining: number };
  missingRequires: string[];
}
export interface Artifact {
  id: string;
  state: string;
  required: boolean;
  outputPath?: string;
  missingRequires?: string[];
}
export interface RecordDetail {
  record: RecordSummary;
  documents: DocumentSummary[];
  artifacts: Artifact[];
  taskPlan?: TaskPlan;
}
export interface WorkspaceInfo {
  name: string;
  root: string;
  branch: string;
  sessionToken: string;
  cliAvailable: boolean;
  diagnostics: string[];
}
export interface SearchHit {
  path: string;
  title: string;
  excerpt: string;
  line: number;
}
export interface Metrics {
  records: { changes: number; specs: number; archives: number; domains: number };
  tasks: { ready: number; waiting: number; done: number; invalid: number };
  domains: { domain: string; changes: number; specs: number }[];
  timeline: { date: string; created: number; archived: number }[];
}
export interface ApiError {
  message: string;
  code?: string;
  current?: DocumentContent;
}
