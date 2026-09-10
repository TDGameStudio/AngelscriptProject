import { lazy, Suspense, useEffect, useState } from 'react';
import { NavLink, Route, Routes, useLocation } from 'react-router-dom';
import { useQueryClient } from '@tanstack/react-query';
import {
  Archive,
  ArrowUpRight,
  BookOpen,
  ChevronLeft,
  ChevronRight,
  CircleHelp,
  FileText,
  GitBranch,
  LayoutDashboard,
  Layers3,
  Menu,
  Moon,
  Network,
  PanelLeftClose,
  PanelLeftOpen,
  Search,
  Sparkles,
  Sun,
  X,
} from 'lucide-react';
import { useWorkspace } from './lib/api';
import { useNavigationPreferences, useWorkspaceSetting } from './lib/preferences';
import { SearchDialog } from './components/SearchDialog';
import { Loading } from './components/State';
const OverviewPage = lazy(() => import('./pages/OverviewPage'));
const RecordsPage = lazy(() => import('./pages/RecordsPage'));
const DocumentsPage = lazy(() => import('./pages/DocumentsPage'));
const TasksPage = lazy(() => import('./pages/TasksPage'));

const navigation = [
  { to: '/', label: '工作台', english: 'Overview', icon: LayoutDashboard },
  { to: '/changes', label: 'Changes', english: 'Active changes', icon: Layers3 },
  { to: '/specs', label: 'Specs', english: 'Specifications', icon: BookOpen },
  { to: '/tasks', label: '任务', english: 'Task explorer', icon: Network },
  { to: '/documents', label: '文档', english: 'Workspace docs', icon: FileText },
  { to: '/skills', label: 'Skills', english: 'Project skills', icon: Sparkles },
  { to: '/archives', label: '归档', english: 'Evolution archive', icon: Archive },
];
function initialTheme() {
  return window.matchMedia?.('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
}
export default function App() {
  const workspace = useWorkspace();
  const client = useQueryClient();
  const location = useLocation();
  const [theme, setTheme] = useWorkspaceSetting(workspace.data?.root, 'theme', initialTheme());
  const sidebarDestination = useNavigationPreferences(workspace.data?.root);
  const [search, setSearch] = useState(false);
  const [drawer, setDrawer] = useState(false);
  const [collapsed, setCollapsed] = useWorkspaceSetting(workspace.data?.root, 'sidebarCollapsed', false);
  const [live, setLive] = useState(false);
  useEffect(() => {
    document.documentElement.dataset.theme = theme;
    document.documentElement.style.colorScheme = theme;
  }, [theme]);
  useEffect(() => {
    setDrawer(false);
  }, [location.pathname, location.search]);
  useEffect(() => {
    const key = (event: KeyboardEvent) => {
      if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === 'k') {
        event.preventDefault();
        setSearch((open) => !open);
      }
      if (event.key === 'Escape') setDrawer(false);
    };
    window.addEventListener('keydown', key);
    return () => window.removeEventListener('keydown', key);
  }, []);
  useEffect(() => {
    if (typeof EventSource === 'undefined') return;
    const events = new EventSource('/api/events');
    events.onopen = () => setLive(true);
    events.onerror = () => setLive(false);
    events.addEventListener('invalidate', (event) => {
      let path: string | undefined;
      try {
        path = (JSON.parse((event as MessageEvent).data) as { path?: string }).path;
      } catch {
        /* A complete refresh is safe. */
      }
      void client.invalidateQueries({
        predicate: (query) => query.queryKey[0] !== 'document' || !path || query.queryKey[1] === path,
      });
    });
    return () => events.close();
  }, [client]);
  const page = navigation.find((item) => item.to === location.pathname) ?? navigation[0]!;
  return (
    <div className={`app-shell ${collapsed ? 'sidebar-collapsed' : ''} ${drawer ? 'drawer-open' : ''}`}>
      <a className="skip-link" href="#main-content">
        跳到主要内容
      </a>
      {drawer && (
        <button className="drawer-backdrop" aria-label="关闭导航" onClick={() => setDrawer(false)} />
      )}
      <aside className="sidebar">
        <NavLink className="brand" to="/" aria-label="Harness Web 工作台">
          <span className="brand-mark">
            <span />
            <span />
            <span />
          </span>
          <span className="brand-name">
            harness<span>workspace</span>
          </span>
          <span className="brand-beta">WEB</span>
        </NavLink>
        <button className="workspace-selector" onClick={() => setSearch(true)}>
          <span className="workspace-avatar">{(workspace.data?.name ?? 'A')[0]?.toUpperCase()}</span>
          <span>
            <strong>{workspace.data?.name ?? '当前工作区'}</strong>
            <small>
              <span className="status-light" />
              本地工作区
            </small>
          </span>
          <ChevronRight size={14} />
        </button>
        <div className="nav-label">WORKSPACE</div>
        <nav className="main-nav" aria-label="主导航">
          {navigation.map((item) => (
            <NavLink
              to={sidebarDestination(item.to)}
              end={item.to === '/'}
              key={item.to}
              title={collapsed ? item.label : undefined}
            >
              <item.icon size={19} strokeWidth={1.65} />
              <span>{item.label}</span>
              {item.to === '/tasks' && <span className="nav-node" />}
            </NavLink>
          ))}
        </nav>
        <div className="sidebar-bottom">
          <div className="workspace-context">
            <GitBranch size={14} />
            <code>{workspace.data?.branch || 'workspace'}</code>
            <span
              className={`live-indicator ${live ? 'connected' : ''}`}
              title={live ? '文件变化实时同步' : '正在连接实时同步'}
            />
          </div>
          <button className="sidebar-search" onClick={() => setSearch(true)}>
            <Search size={16} />
            <span>搜索工作区</span>
            <kbd>Ctrl K</kbd>
          </button>
          <div className="sidebar-utilities">
            <button
              className="icon-button"
              aria-label={theme === 'light' ? '切换深色主题' : '切换浅色主题'}
              title={theme === 'light' ? '切换深色主题' : '切换浅色主题'}
              onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')}
            >
              {theme === 'light' ? <Moon size={17} /> : <Sun size={17} />}
            </button>
            <span>
              Harness Web <code>0.1</code>
            </span>
            <button
              className="icon-button collapse-button"
              aria-label={collapsed ? '展开侧栏' : '收起侧栏'}
              onClick={() => setCollapsed(!collapsed)}
            >
              {collapsed ? <PanelLeftOpen size={17} /> : <PanelLeftClose size={17} />}
            </button>
          </div>
        </div>
      </aside>
      <div className="main-shell">
        <header className="topbar">
          <button
            className="icon-button mobile-menu"
            aria-label="打开导航"
            onClick={() => setDrawer(!drawer)}
          >
            {drawer ? <X size={19} /> : <Menu size={19} />}
          </button>
          <div className="breadcrumbs">
            <span>Workspace</span>
            <ChevronRight size={13} />
            <strong>{page.label}</strong>
          </div>
          <div className="topbar-actions">
            <span className={`connection-status ${live ? 'online' : ''}`}>
              <span />
              {live ? '已同步' : '连接中'}
            </span>
            <button className="topbar-search" onClick={() => setSearch(true)}>
              <Search size={15} />
              <span>搜索</span>
              <kbd>Ctrl K</kbd>
            </button>
          </div>
        </header>
        {workspace.error && (
          <div className="workspace-warning" role="alert">
            工作区连接失败：{workspace.error.message}
            <button onClick={() => void workspace.refetch()}>重试</button>
          </div>
        )}
        {workspace.data && !workspace.data.cliAvailable && (
          <div className="workspace-warning" role="status">
            <CircleHelp size={16} />
            OpenSpec 暂不可用，文档仍可浏览。{workspace.data.diagnostics.join(' ')}
          </div>
        )}
        <main id="main-content">
          <Suspense fallback={<Loading />}>
            <Routes>
              <Route path="/" element={<OverviewPage />} />
              <Route path="/changes" element={<RecordsPage kind="change" />} />
              <Route path="/archives" element={<RecordsPage kind="archive" />} />
              <Route path="/specs" element={<DocumentsPage specs />} />
              <Route path="/tasks" element={<TasksPage />} />
              <Route path="/documents" element={<DocumentsPage />} />
              <Route path="/skills" element={<DocumentsPage skills />} />
              <Route
                path="*"
                element={
                  <div className="state-panel">
                    <h1>页面不存在</h1>
                    <NavLink className="text-link" to="/">
                      返回工作台
                      <ArrowUpRight size={15} />
                    </NavLink>
                  </div>
                }
              />
            </Routes>
          </Suspense>
        </main>
        <footer className="app-footer">
          <span>HARNESS / WORKSPACE INTELLIGENCE</span>
          <span>规范驱动 · 本地优先</span>
        </footer>
      </div>
      <SearchDialog open={search} onOpenChange={setSearch} />
    </div>
  );
}
