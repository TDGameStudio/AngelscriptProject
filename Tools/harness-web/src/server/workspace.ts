import { createHash, randomBytes } from 'node:crypto';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { EventEmitter } from 'node:events';
import { access, lstat, readFile, realpath, rename, rm, stat, writeFile } from 'node:fs/promises';
import path from 'node:path';
import chokidar, { type FSWatcher } from 'chokidar';
import MiniSearch from 'minisearch';
import { parseDocument } from 'yaml';
import { assertProtectedContentUnchanged } from '../shared/documents.js';
import type {
  DocumentContent,
  DocumentSummary,
  Metrics,
  RecordDetail,
  RecordKind,
  RecordSummary,
  SearchHit,
  TaskPlan,
  WorkspaceInfo,
} from '../shared/types.js';
import { ApiFailure } from './errors.js';
import { manifestSchema, OpenSpecReader, type NativeObject } from './native.js';

const execute = promisify(execFile);
const MAX_DOCUMENT = 2 * 1024 * 1024;
const excluded =
  /(?:^|\/)(?:\.git|Reference|external|vendor|ThirdParty|node_modules|dist|build|target|Saved|Intermediate|Binaries|DerivedDataCache|\.cache|coverage|test-results|playwright-report)(?:\/|$)/i;
const markdown = /\.(?:md|markdown)$/i;
const imageExtension = /\.(?:png|jpe?g|gif|webp|avif)$/i;
const slash = (value: string) => value.replaceAll('\\', '/');
const digest = (value: Buffer | string) => createHash('sha256').update(value).digest('hex');
interface Catalog {
  documents: DocumentContent[];
  search: MiniSearch<DocumentContent>;
}

function readOnlyReason(relative: string): string | undefined {
  if (/(?:^|\/)openspec\/archive\//i.test(relative)) return '历史归档保持只读';
  if (/\/attachments\/replans\//i.test(relative)) return '已应用的 Replan 是不可改写的历史';
  if (/\/attachments\/reviews\//i.test(relative)) return '固定快照 Review 由其生命周期管理';
  if (/\/attachments\/data\/workflow-evaluation\.md$/i.test(relative)) return '工作流评估与输入摘要绑定';
  return undefined;
}

export class Workspace extends EventEmitter {
  readonly native: OpenSpecReader;
  readonly sessionToken: string;
  private indexPromise?: Promise<Map<string, string>>;
  private recordsPromise?: Promise<RecordSummary[]>;
  private catalogPromise?: Promise<Catalog>;
  private tasksCache = new Map<string, Promise<TaskPlan>>();
  private locks = new Map<string, Promise<unknown>>();
  private watcher?: FSWatcher;
  private timer?: ReturnType<typeof setTimeout>;
  private diagnostics = new Set<string>();

  constructor(
    readonly root: string,
    options: { cliPath?: string; sessionToken?: string } = {},
  ) {
    super();
    this.native = new OpenSpecReader(root, options.cliPath);
    this.sessionToken = options.sessionToken ?? randomBytes(32).toString('hex');
  }
  private async git(args: string[], cwd = this.root): Promise<string> {
    return (
      await execute('git', args, {
        cwd,
        windowsHide: true,
        timeout: 15000,
        maxBuffer: 16 * 1024 * 1024,
        encoding: 'utf8',
      })
    ).stdout;
  }
  async initialize(watch: boolean) {
    const actual = (await this.git(['rev-parse', '--show-toplevel'])).trim();
    if (path.resolve(actual).toLowerCase() !== path.resolve(this.root).toLowerCase())
      throw new ApiFailure(400, 'WORKSPACE_ROOT', '请选择 Git 工作区根目录。');
    if (watch) {
      const ignoredDirectories = new Set<string>();
      for (const repository of await this.ownedRepositories()) {
        // Git collapses wholly ignored trees without descending into their generated contents.
        // A directory containing a tracked file is not collapsed, so its document stays watched.
        const ignored = await this.git(
          [
            'ls-files',
            '--others',
            '--ignored',
            '--exclude-standard',
            '--directory',
            '--no-empty-directory',
            '-z',
          ],
          repository.root,
        );
        for (const entry of ignored.split('\0')) {
          if (entry.endsWith('/')) ignoredDirectories.add(`${repository.prefix}${slash(entry).slice(0, -1)}`);
        }
      }
      const isIgnoredDirectory = (relative: string) => {
        for (
          let candidate = relative;
          candidate;
          candidate = candidate.slice(0, candidate.lastIndexOf('/'))
        ) {
          if (ignoredDirectories.has(candidate)) return true;
          if (!candidate.includes('/')) break;
        }
        return false;
      };
      this.watcher = new chokidar.FSWatcher({
        ignoreInitial: true,
        followSymlinks: false,
        // Native directory watch handles block external OpenSpec archive moves on Windows.
        usePolling: process.platform === 'win32',
        interval: 500,
        atomic: true,
        ignored: (candidate, stats) => {
          const relative = slash(path.relative(this.root, candidate));
          if (
            excluded.test(relative) ||
            /^(?:Content|Config|\.vs)(?:\/|$)/i.test(relative) ||
            isIgnoredDirectory(relative)
          )
            return true;
          return Boolean(
            stats?.isFile() &&
            !markdown.test(relative) &&
            !/\.(?:yaml|yml)$/i.test(relative) &&
            !['.gitignore', '.gitmodules'].includes(path.basename(relative)),
          );
        },
        awaitWriteFinish: { stabilityThreshold: 120, pollInterval: 30 },
      });
      // Chokidar applies environment overrides before freezing its effective options.
      // Check before add() creates handles, without changing the process environment.
      if (process.platform === 'win32' && !this.watcher.options.usePolling) {
        await this.watcher.close();
        throw new ApiFailure(
          400,
          'WATCH_CONFIGURATION',
          'Windows 文件监听需要轮询以支持外部归档移动。请取消 CHOKIDAR_USEPOLLING=0/false 后重新启动。',
        );
      }
      this.watcher.on('all', (_event, target) => {
        const relative = slash(path.relative(this.root, target));
        this.clearCaches();
        clearTimeout(this.timer);
        this.timer = setTimeout(() => this.emit('invalidate', { path: relative }), 160);
      });
      this.watcher.on('error', (error) => {
        this.diagnostics.add(`文件监听不可用：${String(error)}`);
      });
      const ready = new Promise<void>((resolve) => this.watcher!.once('ready', resolve));
      this.watcher.add(this.root);
      await ready;
    }
  }
  private clearCaches() {
    this.indexPromise = undefined;
    this.catalogPromise = undefined;
    this.recordsPromise = undefined;
    this.tasksCache.clear();
  }
  invalidate(relative?: string) {
    this.clearCaches();
    this.emit('invalidate', relative ? { path: relative } : {});
  }
  async close() {
    clearTimeout(this.timer);
    await this.watcher?.close();
    this.clearCaches();
    this.removeAllListeners();
  }
  async info(): Promise<WorkspaceInfo> {
    let branch = 'unborn';
    try {
      branch = (await this.git(['symbolic-ref', '--short', 'HEAD'])).trim();
    } catch {
      try {
        branch = (await this.git(['rev-parse', '--short', 'HEAD'])).trim();
      } catch {
        /* empty repository */
      }
    }
    const cliAvailable = await this.native.available();
    return {
      name: path.basename(this.root),
      root: this.root,
      branch,
      sessionToken: this.sessionToken,
      cliAvailable,
      diagnostics: [
        ...this.diagnostics,
        ...(!cliAvailable ? ['项目内的 OpenSpec 可执行文件不可用；仅提供文档与归档浏览。'] : []),
      ],
    };
  }
  private async ownedRepositories(): Promise<{ root: string; prefix: string }[]> {
    const repositories = [{ root: this.root, prefix: '' }];
    try {
      const settings = await this.git([
        'config',
        '--file',
        '.gitmodules',
        '--get-regexp',
        '^submodule\\..*\\.(path|url)$',
      ]);
      const modules = new Map<string, { path?: string; url?: string }>();
      for (const line of settings.split('\n')) {
        const match = /^submodule\.(.+)\.(path|url) (.+)$/.exec(line.trim());
        if (!match) continue;
        const item = modules.get(match[1]) ?? {};
        item[match[2] as 'path' | 'url'] = match[3];
        modules.set(match[1], item);
      }
      const gitlinks = new Set(
        (await this.git(['ls-files', '--stage', '-z']))
          .split('\0')
          .filter((line) => line.startsWith('160000 '))
          .map((line) => line.slice(line.indexOf('\t') + 1)),
      );
      for (const item of modules.values()) {
        if (
          !item.path ||
          !item.url ||
          !/(?:github\.com[:/])TDGameStudio\//i.test(item.url) ||
          !gitlinks.has(item.path) ||
          excluded.test(slash(item.path))
        )
          continue;
        const absolute = await this.safePath(item.path);
        try {
          await access(path.join(absolute, '.git'));
          repositories.push({ root: absolute, prefix: `${slash(item.path)}/` });
        } catch {
          /* uninitialized submodule */
        }
      }
    } catch {
      /* no submodule configuration */
    }
    return repositories;
  }
  private async buildIndex(): Promise<Map<string, string>> {
    const repositories = await this.ownedRepositories();
    const index = new Map<string, string>();
    for (const repository of repositories) {
      const files = (
        await this.git(['ls-files', '--cached', '--others', '--exclude-standard', '-z'], repository.root)
      ).split('\0');
      for (const local of files) {
        if (!local) continue;
        const relative = repository.prefix + slash(local);
        if (
          excluded.test(relative) ||
          (!markdown.test(relative) &&
            !imageExtension.test(relative) &&
            !/(?:^|\/)(?:change|spec|domain)\.yaml$/.test(relative))
        )
          continue;
        try {
          const absolute = await this.safePath(relative);
          const details = await lstat(absolute);
          if (details.isFile() && !details.isSymbolicLink()) index.set(relative, absolute);
        } catch {
          /* deleted or external file */
        }
      }
    }
    return index;
  }
  private index() {
    return (this.indexPromise ??= this.buildIndex().catch((error) => {
      this.indexPromise = undefined;
      throw error;
    }));
  }
  private async safePath(relative: string): Promise<string> {
    if (
      !relative ||
      relative.includes('\0') ||
      relative.includes('\\') ||
      path.isAbsolute(relative) ||
      relative.split('/').some((part) => part === '..' || part === '.' || part === '') ||
      relative.includes(':')
    )
      throw new ApiFailure(400, 'INVALID_PATH', '文件路径必须是工作区内的相对路径。');
    const absolute = path.resolve(this.root, relative);
    const resolved = await realpath(absolute);
    const actualRoot = await realpath(this.root);
    const relation = path.relative(actualRoot, resolved);
    if (!relation || relation.startsWith(`..${path.sep}`) || relation === '..' || path.isAbsolute(relation))
      throw new ApiFailure(403, 'PATH_OUTSIDE_WORKSPACE', '文件不在选定工作区内。');
    // Reject symlink or junction aliases even when they point back inside the root.
    let cursor = this.root;
    for (const segment of relative.split('/')) {
      cursor = path.join(cursor, segment);
      if ((await lstat(cursor)).isSymbolicLink())
        throw new ApiFailure(403, 'LINK_NOT_ALLOWED', '符号链接不属于可编辑文件范围。');
    }
    return absolute;
  }
  private async owned(
    relative: string,
    kind: 'document' | 'image' | 'manifest' = 'document',
  ): Promise<string> {
    if (excluded.test(relative)) throw new ApiFailure(403, 'FILE_EXCLUDED', '该路径不属于项目文档范围。');
    const absolute = await this.safePath(relative);
    if (!(await this.index()).has(relative))
      throw new ApiFailure(404, 'DOCUMENT_NOT_FOUND', '文档未列入当前工作区的 Git 文件索引。');
    if (
      (kind === 'document' && !markdown.test(relative)) ||
      (kind === 'image' && !imageExtension.test(relative))
    )
      throw new ApiFailure(403, 'FILE_TYPE', '不支持该文件类型。');
    return absolute;
  }
  async document(relative: string): Promise<DocumentContent> {
    const absolute = await this.owned(relative);
    const details = await stat(absolute);
    if (details.size > MAX_DOCUMENT)
      throw new ApiFailure(413, 'DOCUMENT_TOO_LARGE', '文档超过 2 MiB，无法在编辑器中打开。');
    const bytes = await readFile(absolute);
    const content = bytes.toString('utf8');
    if (!Buffer.from(content, 'utf8').equals(bytes))
      throw new ApiFailure(415, 'DOCUMENT_ENCODING', '编辑器仅支持 UTF-8 文档。');
    const readonlyReason = readOnlyReason(relative);
    const title =
      /^#{1,6}\s+(.+)$/m.exec(content)?.[1]?.replace(/[*`]/g, '').trim() ?? path.basename(relative);
    return {
      path: relative,
      title,
      readonly: Boolean(readonlyReason),
      ...(readonlyReason ? { readonlyReason } : {}),
      modifiedAt: details.mtime.toISOString(),
      content,
      revision: digest(bytes),
    };
  }
  private async buildCatalog(): Promise<Catalog> {
    const paths = [...(await this.index()).keys()].filter((relative) => markdown.test(relative)).sort();
    const result: DocumentContent[] = [];
    for (let start = 0; start < paths.length; start += 24) {
      const batch = await Promise.all(
        paths.slice(start, start + 24).map(async (relative) => {
          try {
            return await this.document(relative);
          } catch (error) {
            this.diagnostics.add(
              `文档未读取：${relative}（${error instanceof Error ? error.message : 'unknown'}）`,
            );
            return undefined;
          }
        }),
      );
      result.push(...batch.filter((item): item is DocumentContent => Boolean(item)));
    }
    const search = new MiniSearch<DocumentContent>({
      idField: 'path',
      fields: ['title', 'path', 'content'],
      storeFields: ['path'],
      searchOptions: { prefix: true, boost: { title: 3, path: 2 } },
    });
    search.addAll(result);
    return { documents: result, search };
  }
  private catalog() {
    return (this.catalogPromise ??= this.buildCatalog().catch((error) => {
      this.catalogPromise = undefined;
      throw error;
    }));
  }
  async documents(prefix?: string): Promise<DocumentSummary[]> {
    return (await this.catalog()).documents
      .filter(
        (document) =>
          !prefix ||
          document.path.startsWith(prefix.endsWith('/') ? prefix : `${prefix}/`) ||
          document.path === prefix,
      )
      .map(({ content: _content, revision: _revision, ...summary }) => summary);
  }
  async save(relative: string, content: string, baseRevision: string): Promise<DocumentContent> {
    const prior = this.locks.get(relative) ?? Promise.resolve();
    const operation = prior
      .catch(() => {})
      .then(async () => {
        const current = await this.document(relative);
        if (current.readonly) throw new ApiFailure(403, 'DOCUMENT_READONLY', current.readonlyReason!);
        if (current.revision !== baseRevision)
          throw new ApiFailure(409, 'REVISION_CONFLICT', '文件已被其他编辑器修改，请比较当前版本。', current);
        if (Buffer.byteLength(content) > MAX_DOCUMENT)
          throw new ApiFailure(413, 'DOCUMENT_TOO_LARGE', '文档超过 2 MiB。');
        try {
          assertProtectedContentUnchanged(current.content, content);
        } catch (error) {
          throw new ApiFailure(
            422,
            'PROTECTED_CONTENT',
            error instanceof Error ? error.message : '受保护的原文结构不能修改。',
          );
        }
        if (content === current.content) return current;
        const absolute = await this.owned(relative);
        const temp = `${absolute}.harness-web-${randomBytes(8).toString('hex')}.tmp`;
        try {
          const permissions = (await stat(absolute)).mode;
          await writeFile(temp, content, { encoding: 'utf8', mode: permissions, flag: 'wx' });
          // Recheck after temp write so competing editors cannot be silently overwritten.
          const latest = await this.document(relative);
          if (latest.revision !== baseRevision)
            throw new ApiFailure(
              409,
              'REVISION_CONFLICT',
              '文件已被其他编辑器修改，请比较当前版本。',
              latest,
            );
          await rename(temp, absolute);
        } finally {
          await rm(temp, { force: true });
        }
        this.invalidate(relative);
        return this.document(relative);
      });
    this.locks.set(relative, operation);
    try {
      return await operation;
    } finally {
      if (this.locks.get(relative) === operation) this.locks.delete(relative);
    }
  }
  async image(relative: string) {
    const absolute = await this.owned(relative, 'image');
    if ((await stat(absolute)).size > 8 * 1024 * 1024)
      throw new ApiFailure(413, 'IMAGE_TOO_LARGE', '图片超过 8 MiB。');
    return readFile(absolute);
  }
  async search(query: string): Promise<SearchHit[]> {
    if (!query.trim()) return [];
    const term = query.trim().toLocaleLowerCase();
    const hits: SearchHit[] = [];
    const catalog = await this.catalog();
    const ranked = new Map(catalog.search.search(term).map((item, index) => [String(item.id), index]));
    // Literal matching also finds Chinese substrings that do not form token boundaries.
    const candidates = catalog.documents
      .filter(
        (document) =>
          ranked.has(document.path) ||
          `${document.path}\n${document.content}`.toLocaleLowerCase().includes(term),
      )
      .sort(
        (a, b) =>
          (ranked.get(a.path) ?? Number.MAX_SAFE_INTEGER) - (ranked.get(b.path) ?? Number.MAX_SAFE_INTEGER),
      );
    for (const document of candidates) {
      const lines = document.content.split(/\r?\n/);
      let added = false;
      for (let line = 0; line < lines.length; line++)
        if (lines[line].toLocaleLowerCase().includes(term)) {
          hits.push({
            path: document.path,
            title: document.title,
            excerpt: lines[line].trim().slice(0, 260),
            line: line + 1,
          });
          added = true;
          if (hits.length >= 100) return hits;
          break;
        }
      if (!added && (document.path.toLocaleLowerCase().includes(term) || ranked.has(document.path)))
        hits.push({ path: document.path, title: document.title, excerpt: document.path, line: 1 });
      if (hits.length >= 100) return hits;
    }
    return hits;
  }
  private summary(kind: RecordKind, value: NativeObject): RecordSummary {
    const relative = slash(path.relative(this.root, value.path));
    const { manifest } = value;
    return {
      key: `${kind}:${relative}`,
      kind,
      id: value.id,
      path: relative,
      title: manifest.metadata.title,
      description: manifest.metadata.description,
      domain: value.id.includes('/') ? value.id.slice(0, value.id.lastIndexOf('/')) : value.id,
      createdAt: manifest.created_at,
      archivedAt: manifest.archived_at,
      closure: manifest.closure?.kind ?? (kind === 'archive' ? 'legacy-completed' : undefined),
    };
  }
  private async loadRecords(): Promise<RecordSummary[]> {
    const records: RecordSummary[] = [];
    if (await this.native.available()) {
      for (const kind of ['domain', 'spec', 'change'] as const) {
        try {
          for (const item of await this.native.records(kind)) {
            const record = this.summary(kind, item);
            if (kind === 'change')
              try {
                const [status, tasks] = await Promise.all([
                  this.native.status(item.id),
                  this.loadTasks(item.id),
                ]);
                record.artifactComplete = status.isComplete;
                record.progress = tasks.progress;
                record.invalid = tasks.taskIssues.length > 0;
              } catch (error) {
                record.invalid = true;
                this.diagnostics.add(error instanceof Error ? error.message : String(error));
              }
            records.push(record);
          }
        } catch (error) {
          this.diagnostics.add(error instanceof Error ? error.message : String(error));
        }
      }
    }
    for (const [relative, absolute] of await this.index()) {
      if (!/^openspec\/archive\/changes\/.+\/change\.yaml$/.test(relative)) continue;
      try {
        const verified = await this.owned(relative, 'manifest');
        const parsed = parseDocument(await readFile(verified, 'utf8'), { uniqueKeys: true });
        if (parsed.errors.length) throw parsed.errors[0];
        const manifest = manifestSchema.parse(parsed.toJS({ maxAliasCount: 50 }));
        records.push(
          this.summary('archive', { id: manifest.metadata.id, path: path.dirname(absolute), manifest }),
        );
      } catch {
        this.diagnostics.add(`归档清单无效：${relative}`);
      }
    }
    return records.sort((a, b) => a.id.localeCompare(b.id));
  }
  async records(kind?: RecordKind): Promise<RecordSummary[]> {
    const records = await (this.recordsPromise ??= this.loadRecords().catch((error) => {
      this.recordsPromise = undefined;
      throw error;
    }));
    return kind ? records.filter((record) => record.kind === kind) : records;
  }
  private loadTasks(id: string) {
    let cached = this.tasksCache.get(id);
    if (!cached) {
      cached = this.native.tasks(id);
      this.tasksCache.set(id, cached);
      cached.catch(() => this.tasksCache.delete(id));
    }
    return cached;
  }
  async tasks(id: string): Promise<TaskPlan> {
    if (!(await this.native.records('change')).some((record) => record.id === id))
      throw new ApiFailure(404, 'CHANGE_NOT_FOUND', '找不到该活动 Change。');
    return this.loadTasks(id);
  }
  async record(key: string): Promise<RecordDetail> {
    const record = (await this.records()).find((item) => item.key === key);
    if (!record) throw new ApiFailure(404, 'RECORD_NOT_FOUND', '找不到该记录。');
    const documents = await this.documents(record.path);
    if (record.kind === 'change') {
      const [status, taskPlan] = await Promise.all([
        this.native.status(record.id),
        this.loadTasks(record.id),
      ]);
      return { record, documents, artifacts: status.artifacts, taskPlan };
    }
    return { record, documents, artifacts: [] };
  }
  async metrics(): Promise<Metrics> {
    const records = await this.records();
    const result: Metrics = {
      records: { changes: 0, specs: 0, archives: 0, domains: 0 },
      tasks: { ready: 0, waiting: 0, done: 0, invalid: 0 },
      domains: [],
      timeline: [],
    };
    const domains = new Map<string, { domain: string; changes: number; specs: number }>();
    const timeline = new Map<string, { date: string; created: number; archived: number }>();
    for (const record of records) {
      result.records[`${record.kind}s` as keyof Metrics['records']]++;
      const group = domains.get(record.domain) ?? { domain: record.domain, changes: 0, specs: 0 };
      if (record.kind === 'change') group.changes++;
      if (record.kind === 'spec') group.specs++;
      if (record.kind === 'change' || record.kind === 'spec') domains.set(record.domain, group);
      for (const [field, date] of [
        ['created', record.createdAt],
        ['archived', record.archivedAt],
      ] as const)
        if (date && /^\d{4}-\d{2}-\d{2}/.test(date)) {
          const day = date.slice(0, 10);
          const item = timeline.get(day) ?? { date: day, created: 0, archived: 0 };
          item[field]++;
          timeline.set(day, item);
        }
      if (record.kind === 'change')
        try {
          const plan = await this.loadTasks(record.id);
          if (plan.taskIssues.length) {
            result.tasks.invalid += Math.max(plan.tasks.length, 1);
            continue;
          }
          for (const task of plan.tasks)
            result.tasks[task.done ? 'done' : task.ready ? 'ready' : 'waiting']++;
        } catch {
          result.tasks.invalid++;
        }
    }
    result.domains = [...domains.values()].sort((a, b) => a.domain.localeCompare(b.domain));
    result.timeline = [...timeline.values()].sort((a, b) => a.date.localeCompare(b.date));
    return result;
  }
}
