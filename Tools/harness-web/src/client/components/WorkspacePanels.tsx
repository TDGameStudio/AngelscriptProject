import type { ReactNode } from 'react';
import { Panel, PanelGroup, PanelResizeHandle, type PanelGroupStorage } from 'react-resizable-panels';
import { GripVertical } from 'lucide-react';
import { preferenceKey } from '../lib/preferences';
import { Loading } from './State';

const storage: PanelGroupStorage = {
  getItem: (name) => {
    try {
      return window.localStorage.getItem(name);
    } catch {
      return null;
    }
  },
  setItem: (name, value) => {
    try {
      window.localStorage.setItem(name, value);
    } catch {
      /* Widths remain adjustable without storage. */
    }
  },
};
export function WorkspacePanels({
  workspaceId,
  name,
  first,
  second,
  focused = false,
}: {
  workspaceId?: string;
  name: string;
  first: ReactNode;
  second: ReactNode;
  focused?: boolean;
}) {
  // The library restores saved layout during panel registration, not when autoSaveId changes.
  // Wait for the identity so a cold page load cannot persist defaults over the saved widths.
  if (!workspaceId) return <Loading label="正在读取工作区布局…" />;
  const layoutId = preferenceKey(workspaceId, `panels:${name}`);
  return (
    <PanelGroup
      key={layoutId}
      className={`workspace-panels ${focused ? 'focused' : ''}`}
      direction="horizontal"
      keyboardResizeBy={5}
      autoSaveId={layoutId}
      storage={storage}
      style={{ height: 'auto', overflow: 'visible' }}
    >
      <Panel
        className="workspace-panel-first"
        id={`${name}-index`}
        order={1}
        defaultSize={24}
        minSize={16}
        maxSize={40}
        style={{ overflow: 'visible' }}
      >
        {first}
      </Panel>
      <PanelResizeHandle className="workspace-panel-handle" aria-label="调整面板宽度" disabled={focused}>
        <GripVertical size={12} />
      </PanelResizeHandle>
      <Panel
        className="workspace-panel-content"
        id={`${name}-content`}
        order={2}
        defaultSize={76}
        minSize={45}
        style={{ overflow: 'visible' }}
      >
        {second}
      </Panel>
    </PanelGroup>
  );
}
