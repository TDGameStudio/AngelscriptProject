import { createStore, del, get, set } from 'idb-keyval';
import type { DocumentContent } from '../../shared/types';

export interface DocumentDraft {
  base: DocumentContent;
  content: string;
  updatedAt: number;
}
let draftStore: ReturnType<typeof createStore> | undefined;
const store = () => (draftStore ??= createStore('harness-web-drafts', 'documents'));
const key = (workspace: string, path: string) => JSON.stringify([workspace, path]);
const pending = new Map<string, Promise<void>>();
function write(workspace: string, path: string, operation: (id: string) => Promise<void>): Promise<void> {
  const id = key(workspace, path);
  const result = (pending.get(id) ?? Promise.resolve()).catch(() => {}).then(() => operation(id));
  pending.set(id, result);
  void result
    .finally(() => {
      if (pending.get(id) === result) pending.delete(id);
    })
    .catch(() => {});
  return result;
}
export const loadDraft = async (workspace: string, path: string): Promise<DocumentDraft | undefined> => {
  await pending.get(key(workspace, path))?.catch(() => {});
  return get(key(workspace, path), store());
};
export const saveDraft = (workspace: string, path: string, draft: DocumentDraft): Promise<void> =>
  write(workspace, path, (id) => set(id, draft, store()));
export const clearDraft = (workspace: string, path: string): Promise<void> =>
  write(workspace, path, (id) => del(id, store()));
