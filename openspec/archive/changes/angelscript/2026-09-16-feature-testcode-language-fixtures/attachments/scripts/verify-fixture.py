"""Read-only exact fixture/projection check. Run from the repository root.
Usage: python <this-file> --tag Language/Syntax/StructFields
       python <this-file> --inventory-only
Uses the project CodeGenTool parser/renderer; never writes or executes AS.
"""
from pathlib import Path
import argparse,re,sys
p=argparse.ArgumentParser();p.add_argument('--tag');p.add_argument('--inventory-only',action='store_true');a=p.parse_args()
root=next(x for x in Path(__file__).resolve().parents if (x/'AngelscriptTestCode/CodeGenTool/codegen.py').is_file())
change=Path(__file__).resolve().parents[2]
inventory=(change/'attachments/drafts/findings/container-inventory.md').read_text(encoding='utf-8')
tags=re.findall(r'^\| [0-9.]+ \| `(Language/[^`]+)` \|',inventory,re.M)
assert len(tags)==47 and len(set(tags))==47,'inventory must contain 47 unique tags'
if a.inventory_only:
 print('47 unique accepted FileTags');sys.exit(0)
assert a.tag in tags,'select an exact accepted FileTag'
sys.path.insert(0,str(root/'AngelscriptTestCode/CodeGenTool'))
from angelscript_test_codegen.discovery import discover_sources
from angelscript_test_codegen.container_parser import parse_source_file
from angelscript_test_codegen.cpp_renderer import render_projection
sources=[s for s in discover_sources(root/'AngelscriptTestCode') if s.file_tag==a.tag]
assert len(sources)==1,'missing or duplicate authored fixture: '+a.tag
source=sources[0];parsed=parse_source_file(source)
assert parsed.format_version=='v1' and parsed.summary.strip()
assert 'Language' in parsed.topics and a.tag.split('/')[1] in parsed.topics
assert sum(v.parent is None for v in parsed.versions)==1
assert any(v.tag=='root' and v.parent is None for v in parsed.versions)
for v in parsed.versions:
 assert v.summary.strip() and v.clean_source.strip(),v.tag
 if v.tag!='root':assert v.parent=='root',v.tag
 if v.tag.startswith('invalid-'):assert 'Negative' in v.topics,v.tag
output=root/'Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated'/source.output_relative_path
assert output.is_file(),'missing projection: '+str(output)
assert output.read_bytes()==render_projection(parsed),'stale projection: '+str(output)
print(a.tag+': complete container and exact structured projection passed; versions='+str(len(parsed.versions)))
