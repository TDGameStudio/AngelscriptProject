export function resolveDocumentLink(from: string, href: string): { path: string; hash: string } | null {
  if (/^[a-z][a-z\d+.-]*:/i.test(href) || href.startsWith('//') || href.startsWith('#')) return null;
  const [pathname, fragment] = href.split('#', 2);
  let decoded: string;
  try {
    decoded = decodeURIComponent(pathname!.split('?')[0]!);
  } catch {
    return null;
  }
  if (!/\.(?:md|markdown)$/i.test(decoded)) return null;
  const pieces = decoded.startsWith('/') ? [] : from.split('/').slice(0, -1);
  for (const part of decoded.replaceAll('\\', '/').split('/')) {
    if (!part || part === '.') continue;
    if (part === '..') {
      if (!pieces.length) return null;
      pieces.pop();
    } else pieces.push(part);
  }
  return { path: pieces.join('/'), hash: fragment ? `#${fragment}` : '' };
}
export function documentUrl(path: string, extra?: Record<string, string>) {
  return `/documents?${new URLSearchParams({ path, ...extra }).toString()}`;
}
export function formatDate(date?: string) {
  if (!date) return '—';
  const parsed = new Date(date);
  return Number.isNaN(parsed.getTime())
    ? date
    : new Intl.DateTimeFormat('zh-CN', { month: 'short', day: 'numeric' }).format(parsed);
}
export function labelForKind(kind: string) {
  return (
    ({ change: 'Change', spec: 'Spec', archive: '归档', domain: '领域' } as Record<string, string>)[kind] ??
    kind
  );
}
export function slug(value: string) {
  return value
    .toLowerCase()
    .replace(/[^\p{L}\p{N}\s-]/gu, '')
    .trim()
    .replace(/\s+/g, '-');
}
