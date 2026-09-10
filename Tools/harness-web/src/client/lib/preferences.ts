import { useEffect, useState } from 'react';
import { useLocation } from 'react-router-dom';

export function preferenceKey(workspaceId: string, name: string) {
  return `harness:${encodeURIComponent(workspaceId)}:${name}`;
}
export function readPreference<T>(workspaceId: string | undefined, name: string, fallback: T): T {
  if (!workspaceId) return fallback;
  try {
    const stored = window.localStorage.getItem(preferenceKey(workspaceId, name));
    return stored === null ? fallback : (JSON.parse(stored) as T);
  } catch {
    return fallback;
  }
}
export function writePreference(workspaceId: string | undefined, name: string, value: unknown) {
  if (!workspaceId) return;
  try {
    window.localStorage.setItem(preferenceKey(workspaceId, name), JSON.stringify(value));
  } catch {
    /* Browsing remains available without storage. */
  }
}
export function useWorkspaceSetting<T>(
  workspaceId: string | undefined,
  name: string,
  fallback: T,
): [T, (value: T) => void] {
  const [setting, setSetting] = useState<{ scope?: string; value: T }>(() => ({
    scope: workspaceId,
    value: readPreference(workspaceId, name, fallback),
  }));
  const value = setting.scope === workspaceId ? setting.value : readPreference(workspaceId, name, fallback);
  return [
    value,
    (next) => {
      setSetting({ scope: workspaceId, value: next });
      writePreference(workspaceId, name, next);
    },
  ];
}

const pages = new Set(['/', '/changes', '/specs', '/tasks', '/documents', '/archives']);
const restorable = new Set([
  'q',
  'domain',
  'closure',
  'date',
  'includeArchive',
  'selected',
  'doc',
  'path',
  'focus',
  'status',
  'view',
  'change',
  'task',
  'taskChange',
]);
function selectionQuery(search: string) {
  const query = new URLSearchParams(search);
  for (const key of [...query.keys()]) if (!restorable.has(key)) query.delete(key);
  const value = query.toString();
  return value ? `?${value}` : '';
}
export function useNavigationPreferences(workspaceId: string | undefined) {
  const location = useLocation();
  useEffect(() => {
    if (pages.has(location.pathname))
      writePreference(workspaceId, `page:${location.pathname}`, selectionQuery(location.search));
  }, [workspaceId, location.pathname, location.search]);
  return (destination: string) => {
    // Only a plain sidebar destination restores state. Explicit deep links keep their own filters.
    if (!workspaceId || !pages.has(destination)) return destination;
    const search =
      destination === location.pathname
        ? selectionQuery(location.search)
        : readPreference(workspaceId, `page:${destination}`, '');
    return `${destination}${selectionQuery(typeof search === 'string' ? search : '')}`;
  };
}
