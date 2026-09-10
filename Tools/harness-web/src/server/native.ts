import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { access } from 'node:fs/promises';
import path from 'node:path';
import { z } from 'zod';
import type { TaskPlan } from '../shared/types.js';
import { ApiFailure } from './errors.js';

const execute = promisify(execFile);
const metadata = z
  .object({ id: z.string(), title: z.string(), description: z.string().optional() })
  .passthrough();
export const manifestSchema = z
  .object({
    metadata,
    created_at: z.string().optional(),
    archived_at: z.string().optional(),
    closure: z.object({ kind: z.string() }).passthrough().optional(),
    archive_schema: z.string().optional(),
  })
  .passthrough();
export const objectSchema = z.object({ id: z.string(), path: z.string(), manifest: manifestSchema });
export type NativeObject = z.infer<typeof objectSchema>;
const taskSchema = z.object({
  id: z.string(),
  description: z.string(),
  done: z.boolean(),
  verify: z.string(),
  after: z.array(z.string()),
  files: z.array(z.string()),
  ready: z.boolean(),
  line: z.number(),
});
const taskPlanSchema = z.object({
  changeId: z.string(),
  state: z.string(),
  tasks: z.array(taskSchema).default([]),
  taskIssues: z
    .array(
      z.object({
        code: z.string(),
        message: z.string(),
        line: z.number().optional(),
        taskId: z.string().optional(),
      }),
    )
    .default([]),
  progress: z.object({ total: z.number(), complete: z.number(), remaining: z.number() }),
  missingRequires: z.array(z.string()).default([]),
});
export const statusSchema = z.object({
  isComplete: z.boolean(),
  artifacts: z.array(
    z.object({
      id: z.string(),
      state: z.string(),
      required: z.boolean(),
      outputPath: z.string().optional(),
      missingRequires: z.array(z.string()).optional(),
    }),
  ),
});

/** Native, read-only product adapter. No shell and no caller-provided commands. */
export class OpenSpecReader {
  readonly executable: string;
  constructor(
    private readonly root: string,
    executable?: string,
  ) {
    this.executable = executable ?? path.join(root, '.agents/skills/openspec/bin/openspec.exe');
  }
  async available() {
    try {
      await access(this.executable);
      return true;
    } catch {
      return false;
    }
  }
  private async run(args: string[]): Promise<unknown> {
    if (!(await this.available()))
      throw new ApiFailure(503, 'CLI_UNAVAILABLE', '项目内的 OpenSpec 可执行文件不可用。文档仍可浏览。');
    let stdout: string;
    try {
      ({ stdout } = await execute(this.executable, args, {
        cwd: this.root,
        windowsHide: true,
        timeout: 15000,
        maxBuffer: 8 * 1024 * 1024,
        encoding: 'utf8',
      }));
    } catch (error) {
      const failure = error as { stderr?: string; message?: string };
      throw new ApiFailure(
        503,
        'CLI_FAILURE',
        `OpenSpec 读取失败：${(failure.stderr || failure.message || 'unknown error').trim().slice(0, 1500)}`,
      );
    }
    try {
      return JSON.parse(stdout);
    } catch {
      throw new ApiFailure(503, 'CLI_INVALID_JSON', 'OpenSpec 返回了无效 JSON。');
    }
  }
  async records(kind: 'domain' | 'spec' | 'change'): Promise<NativeObject[]> {
    return z.array(objectSchema).parse(await this.run([kind, 'list', '--json']));
  }
  async status(id: string) {
    return statusSchema.parse(await this.run(['status', '--change', id, '--json']));
  }
  async tasks(id: string): Promise<TaskPlan> {
    return taskPlanSchema.parse(await this.run(['instructions', 'apply', '--change', id, '--json']));
  }
}
