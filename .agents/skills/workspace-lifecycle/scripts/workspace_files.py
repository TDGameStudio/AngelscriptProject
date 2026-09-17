"""Minimal project snapshots and plugin worktrees. No parent worktree is created."""
import argparse
import hashlib
import io
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import uuid
import zipfile
import xml.etree.ElementTree as ET

MARKER = '.harness/workspace.json'
BUILD_CONFIG = 'Saved/UnrealBuildTool/BuildConfiguration.xml'
BUILD_CONFIG_TEXT = '''<?xml version="1.0" encoding="utf-8"?>
<Configuration xmlns="https://www.unrealengine.com/BuildConfiguration">
  <SourceFileWorkingSet><Provider>None</Provider></SourceFileWorkingSet>
</Configuration>
'''


def git(root, *args, check=True):
    result = subprocess.run(['git', '-C', str(root), *args], capture_output=True)
    if check and result.returncode:
        raise ValueError(result.stderr.decode('utf8', errors='replace').strip())
    return result


def git_text(root, *args):
    return git(root, *args).stdout.decode('utf8').strip()


def safe(root, relative):
    root = Path(root).absolute()
    path = root / relative
    if '..' in Path(relative).parts or not path.is_relative_to(root):
        raise ValueError('Path escapes workspace: ' + str(relative))
    for item in [path, *path.parents]:
        if item.is_symlink() or (hasattr(item, 'is_junction') and item.is_junction()):
            raise ValueError('Workspace path traverses a link: ' + str(item))
    return path


def save(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    temp = path.with_name(path.name + '.' + uuid.uuid4().hex + '.tmp')
    try:
        with temp.open('w', encoding='utf8', newline='\n') as stream:
            json.dump(data, stream, ensure_ascii=False, indent=2)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temp, path)
    finally:
        temp.unlink(missing_ok=True)


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read_descriptor(root):
    root = Path(root).absolute()
    data = json.loads(safe(root, MARKER).read_text('utf8'))
    if data['schemaVersion'] != 1 or Path(data['WorkspaceRoot']) != root:
        raise ValueError('Workspace identity mismatch; copied descriptors are not registrations')
    primary = Path(data['PrimaryRoot'])
    registration = safe(primary, 'Saved/Harness/Workspaces/' + data['WorkspaceId'] + '.json')
    if not registration.is_file() or json.loads(registration.read_text('utf8')) != {
        'WorkspaceId': data['WorkspaceId'], 'WorkspaceRoot': str(root)
    }:
        raise ValueError('Workspace registration mismatch')
    return data


def plugin_catalog(primary):
    catalog = {}
    plugin_root = primary / 'Plugins'
    if not plugin_root.exists():
        return catalog
    for path in plugin_root.iterdir():
        if not path.is_dir() or not (path / (path.name + '.uplugin')).is_file():
            continue
        safe(primary, path.relative_to(primary))
        result = git(path, 'rev-parse', '--show-toplevel', check=False)
        if result.returncode or Path(result.stdout.decode().strip()) != path:
            continue
        head = git_text(path, 'rev-parse', 'HEAD')
        descriptor = json.loads(git_text(path, 'show', head + ':' + path.name + '.uplugin'))
        catalog[path.name] = {
            'Path': 'Plugins/' + path.name, 'SourceRoot': str(path), 'BaseCommit': head,
            'Dependencies': [x['Name'] for x in (descriptor.get('Plugins') or []) if x.get('Enabled', False)]
        }
    return catalog


def closure(catalog, selected):
    result = set()
    def visit(name):
        if name in result:
            return
        if name not in catalog:
            raise ValueError('Requested plugin has no pinned repository: ' + name)
        result.add(name)
        for dependency in catalog[name]['Dependencies']:
            if dependency in catalog:
                visit(dependency)
    for name in selected:
        visit(name)
    return sorted(result)


def snapshot_files(root):
    return {str(path.relative_to(root)).replace('\\', '/'): sha(path)
            for path in root.rglob('*') if path.is_file()}


def export_plugin(source, commit, destination):
    content = git(source, 'archive', '--format=zip', commit).stdout
    with zipfile.ZipFile(io.BytesIO(content)) as archive:
        for item in archive.infolist():
            target = safe(destination, item.filename)
            if ((item.external_attr >> 16) & 0o170000) == 0o120000:
                raise ValueError('Plugin snapshot contains symlink: ' + item.filename)
            if item.is_dir():
                target.mkdir(parents=True, exist_ok=True)
            else:
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(archive.read(item))


def prepare(root, editable, required):
    root = Path(root).absolute()
    data = read_descriptor(root)
    project = safe(root, data['ProjectFile'])
    if sha(project) != data['HostFiles'][data['ProjectFile']]['sha256']:
        raise ValueError('Host project has local edits; reconcile before preparing plugins')
    # UBT 5.8 probes ParentDirectory at a drive-mapped project root, which is null.
    # Disable only that optional source working-set optimization for this project.
    config = safe(root, BUILD_CONFIG)
    if BUILD_CONFIG not in data['HostFiles']:
        if config.exists() and config.read_text('utf8') != BUILD_CONFIG_TEXT:
            existing_config = ET.parse(config).getroot()
            if existing_config.tag != '{https://www.unrealengine.com/BuildConfiguration}Configuration' or len(existing_config):
                raise ValueError('Existing build configuration preserved: ' + str(config))
        config.parent.mkdir(parents=True, exist_ok=True)
        config.write_text(BUILD_CONFIG_TEXT, 'utf8')
        data['HostFiles'][BUILD_CONFIG] = {'source': 'generated', 'sha256': sha(config)}
        save(root / MARKER, data)
    catalog = data['Catalog']
    requested = closure(catalog, [*editable, *required])
    for name in requested:
        entry = catalog[name]
        destination = safe(root, entry['Path'])
        mode = 'Worktree' if name in editable else 'Snapshot'
        previous = data['Repositories'].get(name)
        if previous and (previous['Mode'] == 'Worktree' or mode == 'Snapshot'):
            continue
        if previous:
            changed = [p for p, digest in previous['Files'].items()
                       if not safe(destination, p).is_file() or sha(safe(destination, p)) != digest]
            extras = {p for p in set(snapshot_files(destination)) - set(previous['Files'])
                      if Path(p).parts[0] not in ('Binaries', 'Intermediate', 'Saved', '.vs')}
            if changed or extras:
                raise ValueError('Snapshot has local data; preserve it before upgrading: ' + name)
            # Preserve the whole snapshot during conversion; no recursive deletion.
            backup = safe(root, 'Saved/Harness/WorkspaceSnapshots/' + name + '-' + uuid.uuid4().hex)
            backup.parent.mkdir(parents=True, exist_ok=True)
            destination.rename(backup)
        elif destination.exists():
            # Recover an interrupted worktree add only if Git proves its exact source and branch.
            if mode != 'Worktree' or git_text(destination, 'rev-parse', '--show-toplevel') != str(destination).replace('\\', '/'):
                raise ValueError('Unregistered plugin payload preserved: ' + str(destination))
        if mode == 'Worktree':
            branch = data['PluginBranch']
            if not destination.exists():
                destination.parent.mkdir(parents=True, exist_ok=True)
                try:
                    git(entry['SourceRoot'], 'worktree', 'add', '-b', branch, str(destination), entry['BaseCommit'])
                except ValueError:
                    if previous and not destination.exists():
                        backup.rename(destination)
                    raise
            if Path(git_text(destination, 'rev-parse', '--path-format=absolute', '--git-common-dir')) != Path(git_text(entry['SourceRoot'], 'rev-parse', '--path-format=absolute', '--git-common-dir')):
                raise ValueError('Plugin repository identity mismatch')
            if git_text(destination, 'branch', '--show-current') != branch:
                raise ValueError('Plugin branch mismatch')
            if previous:
                for folder in ('Binaries', 'Intermediate', 'Saved', '.vs'):
                    source = safe(backup, folder)
                    target = safe(destination, folder)
                    if source.exists() and not target.exists():
                        source.rename(target)
        else:
            export_plugin(entry['SourceRoot'], entry['BaseCommit'], destination)
        data['Repositories'][name] = {**entry, 'Mode': mode, 'Root': str(destination),
                                      'Files': snapshot_files(destination) if mode == 'Snapshot' else {}}
        save(root / MARKER, data)
    document = json.loads(project.read_text('utf8'))
    document['Plugins'] = [{'Name': n, 'Enabled': True} for n in sorted(data['Repositories'])]
    project.write_text(json.dumps(document, indent=2) + '\n', 'utf8')
    data['HostFiles'][data['ProjectFile']]['sha256'] = sha(project)
    save(root / MARKER, data)
    return data


def create(primary, name, editable=(), required=(), branch='', host_files=()):
    primary = Path(primary).absolute()
    if not re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9._-]{0,79}', name):
        raise ValueError('Invalid workspace name')
    root = safe(primary, '.workspaces/' + name)
    if root.exists():
        raise ValueError('Workspace target already exists')
    if git(primary, 'check-ignore', '--quiet', '--', '.workspaces/__probe__', check=False).returncode:
        raise ValueError('.workspaces/ must be ignored before workspace creation')
    projects = list(primary.glob('*.uproject'))
    if len(projects) != 1:
        raise ValueError('Expected one host project')
    source_project = projects[0]
    original = json.loads(source_project.read_text('utf-8-sig'))
    modules = [x for x in original.get('Modules', []) if x['Name'] == source_project.stem]
    if not modules:
        modules = [x for x in original.get('Modules', []) if x.get('Type') == 'Runtime'][:1]
    catalog = plugin_catalog(primary)
    closure(catalog, [*editable, *required])  # Validate before creating payload.
    root.mkdir(parents=True)
    descriptor = {'schemaVersion': 1, 'WorkspaceId': 'workspace_' + uuid.uuid4().hex,
                  'WorkspaceRoot': str(root), 'PrimaryRoot': str(primary), 'Topology': 'Replica',
                  'ProjectFile': source_project.name, 'PluginBranch': branch or name,
                  'HostBaseCommit': git_text(primary, 'rev-parse', 'HEAD'),
                  'HostFiles': {}, 'Catalog': catalog, 'Repositories': {}}
    copied = set(host_files)
    for module in modules:
        source = safe(primary, 'Source/' + module['Name'])
        if source.exists():
            copied.update(str(p.relative_to(primary)).replace('\\', '/') for p in source.rglob('*') if p.is_file())
    # Keep the runtime's declared native-module configuration when it is selected.
    if 'Angelscript' in closure(catalog, [*editable, *required]):
        candidate = 'Config/DefaultAngelscriptCompileOptions.ini'
        if (primary / candidate).is_file():
            copied.add(candidate)
    for relative in sorted(copied):
        if not relative.startswith(('Source/', 'Config/', 'Content/', 'Script/')):
            raise ValueError('HostFiles must be explicit engineering inputs: ' + relative)
        source, destination = safe(primary, relative), safe(root, relative)
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, destination)
        descriptor['HostFiles'][relative] = {'source': relative, 'sha256': sha(destination)}
    project = {key: value for key, value in original.items() if key not in ('Modules', 'Plugins')}
    project.update(Modules=modules, Plugins=[])
    (root / source_project.name).write_text(json.dumps(project, indent=2) + '\n', 'utf8')
    descriptor['HostFiles'][source_project.name] = {'source': source_project.name, 'sha256': sha(root / source_project.name)}
    for suffix, target_type in [('', 'Game'), ('Editor', 'Editor')]:
        target = source_project.stem + suffix
        extra = '\n'.join('        ExtraModuleNames.Add("' + x['Name'] + '");' for x in modules)
        relative = 'Source/' + target + '.Target.cs'
        target_path = safe(root, relative)
        target_path.parent.mkdir(parents=True, exist_ok=True)
        target_path.write_text('using UnrealBuildTool;\npublic class ' + target + 'Target : TargetRules\n{\n    public ' + target + 'Target(TargetInfo Target) : base(Target)\n    {\n        Type = TargetType.' + target_type + ';\n        DefaultBuildSettings = BuildSettingsVersion.V7;\n        IncludeOrderVersion = EngineIncludeOrderVersion.Unreal5_8;\n' + extra + '\n    }\n}\n', 'utf8')
        descriptor['HostFiles'][relative] = {'source': 'generated', 'sha256': sha(target_path)}
    (root / 'AGENTS.md').write_text('# Selected Harness workspace\n\n- Read `' + str(primary / 'AGENTS.md') + '`.\n- This project replica is the execution workspace; its parent is the control center.\n- Import Harness from `' + str(primary / '.agents/skills/harness/scripts/Harness.psd1') + '` and pass this directory as WorkspaceRoot.\n- Read and update OpenSpec at the control center; resolve task implementation paths against this workspace.\n', 'utf8')
    descriptor['HostFiles']['AGENTS.md'] = {'source': 'generated', 'sha256': sha(root / 'AGENTS.md')}
    save(root / MARKER, descriptor)
    save(primary / ('Saved/Harness/Workspaces/' + descriptor['WorkspaceId'] + '.json'),
         {'WorkspaceId': descriptor['WorkspaceId'], 'WorkspaceRoot': str(root)})
    return prepare(root, list(editable), list(required))


def verify(root):
    root = Path(root).absolute()
    data = read_descriptor(root)
    errors = []
    for relative, entry in data['HostFiles'].items():
        path = safe(root, relative)
        if not path.is_file() or sha(path) != entry['sha256']:
            errors.append('Host snapshot changed: ' + relative)
    for name, entry in data['Repositories'].items():
        path = safe(root, entry['Path'])
        if entry['Mode'] == 'Snapshot':
            for relative, digest in entry['Files'].items():
                file = safe(path, relative)
                if not file.is_file() or sha(file) != digest:
                    errors.append('Plugin snapshot changed: ' + name + '/' + relative)
            for extra in set(snapshot_files(path)) - set(entry['Files']):
                if Path(extra).parts[0] not in ('Binaries', 'Intermediate', 'Saved', '.vs'):
                    errors.append('Plugin snapshot has extra source: ' + name + '/' + extra)
        else:
            if not path.exists() or git(path, 'rev-parse', '--show-toplevel', check=False).returncode:
                errors.append('Plugin worktree missing: ' + name)
            elif Path(git_text(path, 'rev-parse', '--show-toplevel')) != path or Path(git_text(path, 'rev-parse', '--path-format=absolute', '--git-common-dir')) != Path(git_text(entry['SourceRoot'], 'rev-parse', '--path-format=absolute', '--git-common-dir')):
                errors.append('Plugin worktree identity changed: ' + name)
    return {'IsValid': not errors, 'Errors': errors, 'Workspace': data}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('action', choices=['create', 'prepare', 'verify', 'identity'])
    parser.add_argument('--root', required=True)
    parser.add_argument('--name', default='')
    parser.add_argument('--branch', default='')
    parser.add_argument('--editable', action='append', default=[])
    parser.add_argument('--required', action='append', default=[])
    parser.add_argument('--host-file', action='append', default=[])
    args = parser.parse_args()
    try:
        if args.action == 'create':
            result = create(args.root, args.name, args.editable, args.required, args.branch, args.host_file)
        elif args.action == 'prepare':
            result = prepare(args.root, args.editable, args.required)
        elif args.action == 'verify':
            result = verify(args.root)
        else:
            result = read_descriptor(args.root)
        print(json.dumps(result, ensure_ascii=False))
    except (ValueError, OSError, KeyError) as error:
        print(str(error), file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
