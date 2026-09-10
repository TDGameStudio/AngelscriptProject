import Fastify from 'fastify';
import type { ServerResponse } from 'node:http';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { z } from 'zod';
import { Workspace } from './workspace.js';
import { ApiFailure } from './errors.js';
import type { RecordKind } from '../shared/types.js';

export interface AppOptions {
  workspaceRoot: string;
  watch?: boolean;
  frontend?: false | 'dev' | 'production';
  /** Internal fixture seam; never read from an HTTP request or runtime CLI argument. */
  cliPath?: string;
  sessionToken?: string;
}
const single = z.string().min(1).max(2048);
const queryPath = z.object({ path: single }).strict();
const kinds = ['domain', 'spec', 'change', 'archive'] as const;
const loopback = new Set(['localhost', '127.0.0.1', '[::1]']);
function localOrigin(host: string, origin?: string): boolean {
  try {
    const target = new URL(`http://${host}`);
    if (!loopback.has(target.hostname) || target.username || target.password || target.pathname !== '/')
      return false;
    if (!origin) return true;
    const source = new URL(origin);
    return source.origin === target.origin;
  } catch {
    return false;
  }
}

export async function createApp(options: AppOptions) {
  const app = Fastify({
    logger: false,
    bodyLimit: 3 * 1024 * 1024,
    requestTimeout: 30000,
    connectionTimeout: 30000,
  });
  const workspace = new Workspace(path.resolve(options.workspaceRoot), options);
  await workspace.initialize(options.watch ?? true);
  const streams = new Set<ServerResponse>();
  app.addHook('onRequest', async (request, reply) => {
    const host = request.headers.host ?? '';
    const origin = request.headers.origin;
    if (!localOrigin(host, origin) || request.headers['sec-fetch-site'] === 'cross-site')
      throw new ApiFailure(403, 'LOCAL_REQUEST_REQUIRED', '仅允许当前本机工作台发起请求。');
    if (
      !['GET', 'HEAD', 'OPTIONS'].includes(request.method) &&
      request.headers['x-harness-session'] !== workspace.sessionToken
    )
      throw new ApiFailure(403, 'SESSION_REQUIRED', '请求缺少当前工作台会话标识。');
    reply.header('X-Content-Type-Options', 'nosniff');
    reply.header('Referrer-Policy', 'no-referrer');
    reply.header('X-Frame-Options', 'DENY');
    if (request.url.startsWith('/api/')) reply.header('Cache-Control', 'no-store');
  });
  app.setErrorHandler((error, _request, reply) => {
    if (error instanceof ApiFailure)
      return reply.code(error.statusCode).send({
        message: error.message,
        code: error.code,
        ...(error.current ? { current: error.current } : {}),
      });
    if (error instanceof z.ZodError)
      return reply.code(400).send({ message: '请求参数或数据格式不正确。', code: 'INVALID_REQUEST' });
    if (error instanceof Error && 'code' in error && ['ENOENT', 'ENOTDIR'].includes(String(error.code)))
      return reply.code(404).send({ message: '文件不存在，可能已被外部修改。', code: 'DOCUMENT_NOT_FOUND' });
    const failure = error as { statusCode?: number; message?: string };
    const status = typeof failure.statusCode === 'number' ? failure.statusCode : 500;
    return reply.code(status).send({
      message: status >= 500 ? '读取工作区时发生错误。' : failure.message,
      code: status >= 500 ? 'INTERNAL_ERROR' : 'INVALID_REQUEST',
    });
  });
  app.get('/api/workspace', () => workspace.info());
  app.get('/api/records', (request) => {
    const { kind } = z
      .object({ kind: z.enum(kinds).optional() })
      .strict()
      .parse(request.query);
    return workspace.records(kind as RecordKind | undefined);
  });
  app.get('/api/record', (request) =>
    workspace.record(z.object({ key: single }).strict().parse(request.query).key),
  );
  app.get('/api/tasks', (request) =>
    workspace.tasks(z.object({ change: single }).strict().parse(request.query).change),
  );
  app.get('/api/documents', (request) =>
    workspace.documents(z.object({ prefix: single.optional() }).strict().parse(request.query).prefix),
  );
  app.get('/api/document', (request) => workspace.document(queryPath.parse(request.query).path));
  app.put('/api/document', (request) => {
    const input = z
      .object({ path: single, content: z.string(), baseRevision: z.string().regex(/^[a-f0-9]{64}$/) })
      .strict()
      .parse(request.body);
    return workspace.save(input.path, input.content, input.baseRevision);
  });
  app.get('/api/search', (request) =>
    workspace.search(
      z
        .object({ q: z.string().max(250) })
        .strict()
        .parse(request.query).q,
    ),
  );
  app.get('/api/metrics', () => workspace.metrics());
  app.get('/api/image', async (request, reply) => {
    const relative = queryPath.parse(request.query).path;
    const data = await workspace.image(relative);
    const extensions: Record<string, string> = {
      '.png': 'image/png',
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
      '.gif': 'image/gif',
      '.webp': 'image/webp',
      '.avif': 'image/avif',
    };
    reply.header('Content-Security-Policy', "default-src 'none'; sandbox");
    return reply
      .type(extensions[path.extname(relative).toLowerCase()] ?? 'application/octet-stream')
      .send(data);
  });
  app.get('/api/events', (_request, reply) => {
    reply.hijack();
    const stream = reply.raw;
    stream.writeHead(200, {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache, no-transform',
      Connection: 'keep-alive',
      'X-Content-Type-Options': 'nosniff',
    });
    stream.write(': connected\n\n');
    streams.add(stream);
    stream.on('close', () => streams.delete(stream));
  });
  const broadcast = (event: unknown) => {
    for (const stream of streams)
      if (!stream.destroyed) stream.write(`event: invalidate\ndata: ${JSON.stringify(event)}\n\n`);
  };
  workspace.on('invalidate', broadcast);
  const heartbeat = setInterval(() => {
    for (const stream of streams) if (!stream.destroyed) stream.write(': heartbeat\n\n');
  }, 20000);
  heartbeat.unref();
  app.addHook('preClose', async () => {
    clearInterval(heartbeat);
    for (const stream of streams) stream.end();
    streams.clear();
    await workspace.close();
  });

  if (options.frontend) {
    const here = path.dirname(fileURLToPath(import.meta.url));
    const packageRoot = path.resolve(here, '../..');
    if (options.frontend === 'dev') {
      const [{ createServer }, { default: middie }] = await Promise.all([
        import('vite'),
        import('@fastify/middie'),
      ]);
      const vite = await createServer({
        root: packageRoot,
        server: { middlewareMode: true, hmr: { server: app.server } },
        appType: 'spa',
      });
      await app.register(middie);
      app.use((request, response, next) => {
        if (request.url?.startsWith('/api/')) next();
        else vite.middlewares(request, response, next);
      });
      app.addHook('onClose', () => vite.close());
    } else {
      const { default: staticPlugin } = await import('@fastify/static');
      await app.register(staticPlugin, {
        root: path.join(packageRoot, 'dist/client'),
        prefix: '/',
        wildcard: false,
      });
      app.setNotFoundHandler((request, reply) =>
        request.url.startsWith('/api/')
          ? reply.code(404).send({ message: '未知 API 路径。', code: 'NOT_FOUND' })
          : reply.sendFile('index.html'),
      );
    }
  }
  return app;
}
