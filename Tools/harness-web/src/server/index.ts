import path from 'node:path';
import { access } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { createApp } from './app.js';

export function parseArguments(args: string[]) {
  let workspace: string | undefined;
  let port = 4310;
  let dev = false;
  for (let index = 0; index < args.length; index++) {
    const argument = args[index];
    if (argument === '--dev') dev = true;
    else if (argument === '--workspace' && args[index + 1]) workspace = path.resolve(args[++index]);
    else if (argument === '--port' && args[index + 1]) port = Number(args[++index]);
    else throw new Error(`Unknown argument: ${argument}`);
  }
  if (!Number.isInteger(port) || port < 1 || port > 65535)
    throw new Error('Port must be an integer from 1 to 65535.');
  return { workspace, port, dev };
}
async function discoverRoot(start: string) {
  let current = path.resolve(start);
  while (true) {
    try {
      await access(path.join(current, '.git'));
      await access(path.join(current, 'openspec/project.yaml'));
      return current;
    } catch {
      /* inspect parent */
    }
    const parent = path.dirname(current);
    if (parent === current) throw new Error('Workspace not found. Use --workspace <Git workspace root>.');
    current = parent;
  }
}
async function main() {
  const options = parseArguments(process.argv.slice(2));
  const root = options.workspace ?? (await discoverRoot(path.dirname(fileURLToPath(import.meta.url))));
  const app = await createApp({ workspaceRoot: root, frontend: options.dev ? 'dev' : 'production' });
  await app.listen({ host: '127.0.0.1', port: options.port });
  process.stdout.write(`Harness Web: http://127.0.0.1:${options.port}\nWorkspace: ${root}\n`);
  let closing = false;
  const close = () => {
    if (closing) return;
    closing = true;
    void app.close().then(() => process.exit(0));
  };
  process.on('SIGINT', close);
  process.on('SIGTERM', close);
}
if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url))
  void main().catch((error) => {
    process.stderr.write(`${error instanceof Error ? error.message : String(error)}\n`);
    process.exitCode = 1;
  });
