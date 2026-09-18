"""One append-only recorder shared by Harness public record routes (stdlib only).

Codex JSONL is not a stable API. This adapter recognizes 0.154.x; unknown
records stop the coverage checkpoint rather than silently losing messages.
"""
import argparse
from contextlib import contextmanager
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import re
import sys
import time
import uuid


def digest(data):
    return hashlib.sha256(data).hexdigest()


def local_path(root, relative):
    root = Path(root).absolute()
    candidate = root / relative
    if candidate.is_absolute() and not candidate.is_relative_to(root):
        raise ValueError("Path leaves the selected workspace")
    if ".." in Path(relative).parts:
        raise ValueError("Parent traversal is not a local record path")
    for cursor in [root, *candidate.parents, candidate]:
        if cursor.is_symlink() or (hasattr(cursor, "is_junction") and cursor.is_junction()):
            raise ValueError("Record paths cannot traverse links or junctions")
    return candidate


@contextmanager
def locked(path):
    """OS releases the byte lock even if an interrupt kills the hook process."""
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a+b") as stream:
        if stream.tell() == 0:
            stream.write(b"\0")
            stream.flush()
        deadline = time.monotonic() + 0.7
        while True:
            try:
                stream.seek(0)
                if os.name == "nt":
                    import msvcrt
                    msvcrt.locking(stream.fileno(), msvcrt.LK_NBLCK, 1)
                else:
                    import fcntl
                    fcntl.flock(stream, fcntl.LOCK_EX | fcntl.LOCK_NB)
                break
            except OSError:
                if time.monotonic() >= deadline:
                    raise TimeoutError("Recorder busy; next hook or sync will retry")
                time.sleep(0.02)
        try:
            yield
        finally:
            stream.seek(0)
            if os.name == "nt":
                msvcrt.locking(stream.fileno(), msvcrt.LK_UNLCK, 1)
            else:
                fcntl.flock(stream, fcntl.LOCK_UN)


def save_state(path, state):
    temp = path.with_suffix("." + uuid.uuid4().hex + ".tmp")
    try:
        with temp.open("w", encoding="utf8", newline="\n") as stream:
            json.dump(state, stream, ensure_ascii=False, indent=2)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temp, path)
    finally:
        temp.unlink(missing_ok=True)


def source_bytes(source, session, workspace):
    data = Path(source).read_bytes()
    header = json.loads(data.split(b"\n", 1)[0])
    meta = header.get("payload", {})
    if header.get("type") != "session_meta" or meta.get("id") != session:
        raise ValueError("Transcript session identity does not match binding")
    if Path(meta.get("cwd", "")).resolve() != workspace.resolve():
        raise ValueError("Transcript workspace identity does not match binding")
    if not re.fullmatch(r"0\.154\.\d+", meta.get("cli_version", "")):
        raise ValueError("Unsupported Codex transcript version; use manual source reconciliation")
    return data


def visible(item, questions):
    if not isinstance(item, dict) or not isinstance(item.get("payload"), dict):
        raise ValueError("Unsupported transcript record or payload shape")
    kind = item.get("type")
    payload = item.get("payload", {})
    if kind in {"session_meta", "turn_context", "token_usage_record", "world_state", "compacted", "inter_agent_communication_metadata"}:
        return None
    if kind == "event_msg":
        if payload.get("type") not in {"item_completed", "token_count", "thread_settings_applied", "task_started", "task_complete", "turn_aborted", "agent_message", "agent_reasoning", "user_message", "context_compacted"}:
            raise ValueError("Unsupported event_msg type: " + str(payload.get("type")))
        return None  # response_item is the source, never duplicate event notifications.
    if kind != "response_item":
        raise ValueError("Unsupported transcript record: " + str(kind))
    subtype = payload.get("type")
    if subtype == "message":
        role = payload.get("role")
        if role in {"system", "developer"}:
            return None
        if role not in {"user", "assistant"}:
            raise ValueError("Unsupported message role")
        phase = payload.get("phase") or "unspecified"
        if phase not in {"commentary", "final_answer", "unspecified"}:
            raise ValueError("Unsupported assistant phase: " + phase)
        parts = []
        for content in payload.get("content", []):
            if content.get("type") in {"input_text", "output_text", "text"}:
                parts.append(content["text"])
            elif content.get("type") in {"input_image", "image", "image_url"}:
                parts.append("[Image source: " + json.dumps(content, ensure_ascii=False) + "]")
            else:
                raise ValueError("Unsupported message content: " + str(content.get("type")))
        return role + "/" + phase, "\n".join(parts)
    if subtype == "function_call":
        if payload.get("name", "").split(".")[-1] in {"request_user_input", "request_user_input_async", "AskQuestion"}:
            questions.add(payload["call_id"])
            return "question/" + payload["call_id"], payload["arguments"]
        return None
    if subtype == "function_call_output":
        if payload.get("call_id") in questions:
            questions.remove(payload["call_id"])
            return "answer/" + payload["call_id"], payload["output"]
        return None
    if subtype in {"reasoning", "agent_message", "custom_tool_call", "custom_tool_call_output", "web_search_call", "local_shell_call"}:
        return None
    raise ValueError("Unsupported response_item type: " + str(subtype))


def binding_target(workspace, binding):
    records_root = binding.get('records_root', workspace)
    if binding.get('talk_id'):
        from discussions import record_path, record_lock
        target = record_path({'OpenSpecRoot': records_root}, binding['change'], binding['talk_id'])
        return target, record_lock(records_root, target)
    relative = binding.get('record_file', 'log.md')
    if relative not in ('log.md', 'attachments/transcript.md'):
        raise ValueError('Unsupported exact draft recording target')
    target = local_path(records_root, 'openspec/drafts/' + binding['draft_id'] + '/' + relative)
    return target, target.with_suffix('.record.lock')


def sync_binding(workspace, session, binding, end_line=None, hook_input=None):
    result = {"status": "covered", "draft_id": binding["draft_id"], "appended": 0,
              "through_line": binding["through_line"], "gaps": [], "legacy_overlap": []}
    try:
        if hook_input is not None:
            path = hook_input.get("transcript_path")
            if not path or Path(path).absolute() != Path(binding["source"]):
                raise ValueError("Hook transcript is missing or differs from the bound source; reconcile explicitly")
        data = source_bytes(binding["source"], session, workspace)
        lines = data.splitlines(keepends=True)
        previous = b"".join(lines[:binding["through_line"]])
        if len(lines) < binding["through_line"] or digest(previous) != binding["prefix_sha256"]:
            raise ValueError("Transcript prefix changed or was truncated; checkpoint preserved")
        log, log_lock = binding_target(workspace, binding)
        if not log.is_file():
            raise ValueError("Bound draft log is missing; no replacement draft selected")
        questions = set(binding.get("questions", []))
        with locked(log_lock):
            old = log.read_text(encoding="utf8")
            chunks = []
            through = binding["through_line"]
            current_turn = binding.get("current_turn")
            last_assistant = binding.get("last_assistant", {})
            for number, raw in enumerate(lines, 1):
                if number <= through:
                    continue
                if end_line is not None and number > end_line:
                    break
                try:
                    if not raw.endswith(b"\n"):
                        raise ValueError("Partial JSONL line; retry when the producer completes it")
                    item = json.loads(raw)
                    event = visible(item, questions)
                    if item["type"] == "turn_context":
                        current_turn = item["payload"].get("turn_id")
                    if event and number >= binding["start_line"]:
                        label, body = event
                        event_id = digest((session + ":" + str(number) + ":").encode() + raw)
                        body = body.replace("\r\n", "\n")
                        if label.startswith("assistant/"):
                            last_assistant = {"sha256": digest(body.encode()), "turn_id": current_turn, "phase": label.split("/", 1)[1]}
                        # Whole-frame matching survives append success + checkpoint failure.
                        frame = (f"\n<!-- draft-record:{event_id}:begin -->\n"
                                 f"### {label} · source L{number}\n\n"
                                 f"- Source: `{binding['source']}`; session `{session}`; UTC {item.get('timestamp', 'unavailable')}.\n\n"
                                 + body + f"\n<!-- draft-record:{event_id}:end -->\n")
                        if frame not in old:
                            if body and body in old:
                                result["legacy_overlap"].append(number)
                            chunks.append(frame)
                            result["appended"] += 1
                    through = number
                except (ValueError, KeyError, TypeError) as error:
                    result["gaps"].append(f"L{number}: {error}")
                    break
            if chunks:
                with log.open("a", encoding="utf8", newline="\n") as stream:
                    stream.write("".join(chunks))
                    stream.flush()
                    os.fsync(stream.fileno())
            binding.update(through_line=through, prefix_sha256=digest(b"".join(lines[:through])), questions=sorted(questions), current_turn=current_turn, last_assistant=last_assistant)
            result["through_line"] = through
            if hook_input and hook_input.get("last_assistant_message"):
                expected = digest(hook_input["last_assistant_message"].replace("\r\n", "\n").encode())
                if expected != last_assistant.get("sha256") or (hook_input.get("turn_id") and hook_input["turn_id"] != last_assistant.get("turn_id")):
                    result["gaps"].append("Stop final is not yet in the recorded source range; retry on the next hook or sync")
    except (OSError, ValueError) as error:
        result["gaps"].append(str(error))
    if result["gaps"]:
        result["status"] = "partial"
    binding["legacy_overlap"] = sorted(set(binding.get("legacy_overlap", []) + result["legacy_overlap"]))
    result["legacy_mapping"] = "unresolved; source occurrences appended independently" if binding["legacy_overlap"] else "no ambiguous overlap observed"
    if hook_input:
        binding["last_hook"] = {"event": hook_input.get("hook_event_name"), "turn_id": hook_input.get("turn_id"),
                                "at": datetime.now(timezone.utc).isoformat(), "through_line": result["through_line"], "status": result["status"]}
    binding["coverage"] = result
    return result


def record(workspace, session, action, *, draft_id=None, source=None, start_line=None, hook_input=None, records_root=None, change=None, talk_id=None):
    workspace = Path(workspace).absolute()
    records_root = Path(records_root or workspace).absolute()
    if not re.fullmatch(r"[A-Za-z0-9_-]+", session):
        raise ValueError("An exact session ID is required")
    state_path = local_path(workspace, "Saved/Harness/draft-record/" + session + ".json")
    unbound = {"status": "unbound", "appended": 0, "through_line": 0, "gaps": []}
    if action not in {"bind", "sync", "status", "unbind"}:
        raise ValueError("Unknown recording action")
    if action != "bind" and not state_path.exists():
        return unbound
    if action == "status":
        state = json.loads(state_path.read_text(encoding="utf8"))
        active = state.get("active")
        return dict(active["coverage"], binding=active, history=state["history"]) if active else unbound
    with locked(state_path.with_suffix(".lock")):
        state = json.loads(state_path.read_text(encoding="utf8")) if state_path.exists() else {"schema": 1, "workspace": str(workspace), "session": session, "active": None, "history": []}
        if state["schema"] != 1 or state["session"] != session or Path(state["workspace"]) != workspace:
            raise ValueError("Invalid recorder state identity")
        active = state["active"]
        if action == "bind":
            if talk_id:
                if draft_id or not change:
                    raise ValueError('Bind one exact draft or Change talk, never both')
                binding_target(workspace, {'records_root': str(records_root), 'change': change, 'talk_id': talk_id})
            elif not draft_id or not re.fullmatch(r"[a-z0-9-]+/[a-z0-9-]+", draft_id):
                raise ValueError("Bind needs an exact domain/topic draft ID")
            if not source or not start_line or start_line < 2:
                raise ValueError("Bind needs a transcript and explicit first message line (>= 2)")
            record_file = 'log.md'
            if not talk_id:
                readme = local_path(records_root, 'openspec/drafts/' + draft_id + '/README.md')
                if readme.is_file() and re.search(r'^schema:\s*harness-draft-v2\s*$', readme.read_text('utf-8-sig'), re.M):
                    record_file = 'attachments/transcript.md'
            target, target_lock = binding_target(workspace, dict(records_root=str(records_root), draft_id=draft_id, change=change, talk_id=talk_id, record_file=record_file))
            if not target.is_file() and record_file != 'attachments/transcript.md':
                raise ValueError("Bind requires an existing draft log")
            if talk_id:
                from discussions import read_record
                discussion, _ = read_record(target)
                if not discussion or Path(discussion['workspace_root']).resolve() != workspace.resolve():
                    raise ValueError('Talk recorder cannot bind another execution workspace')
            source = str(Path(source).absolute())
            data = source_bytes(source, session, workspace)
            lines = data.splitlines(keepends=True)
            if start_line > len(lines) + 1:
                raise ValueError("Start line is beyond the transcript boundary")
            same = active and all(active.get(key) == value for key, value in {"source": source, "draft_id": draft_id, "start_line": start_line, 'talk_id': talk_id, 'change': change}.items())
            if active and Path(active.get('records_root', workspace)) != records_root:
                raise ValueError('Record root changed; unbind the old range before rebinding')
            if active and not same:
                if active["source"] != source or start_line <= active["through_line"]:
                    raise ValueError("Switch needs the same source and a new nonoverlapping start line; unbind first for another source")
                result = sync_binding(workspace, session, active, start_line - 1)
                if result["gaps"]:
                    save_state(state_path, state)
                    return result
                state["history"].append(active)
            if not same:
                # Parse pre-range calls to retain an answer whose form preceded binding.
                questions = set()
                for raw in lines[:start_line - 1]:
                    visible(json.loads(raw), questions)
                if record_file == 'attachments/transcript.md':
                    with locked(target_lock):
                        target.parent.mkdir(parents=True, exist_ok=True)
                        if not target.exists():
                            target.write_text('# Optional conversation transcript\n', encoding='utf8')
                        index = target.parent / 'INDEX.md'
                        index_text = index.read_text('utf-8-sig') if index.exists() else '# Attachments\n\n'
                        if '](transcript.md)' not in index_text:
                            index.write_text(index_text + '- [Optional conversation transcript](transcript.md)\n', encoding='utf8')
                active = {"draft_id": draft_id, 'change': change, 'talk_id': talk_id, 'record_file': record_file, "source": source, "records_root": str(records_root), "start_line": start_line,
                          "through_line": start_line - 1, "prefix_sha256": digest(b"".join(lines[:start_line - 1])), "questions": sorted(questions)}
                state["active"] = active
        if not active:
            return unbound
        result = sync_binding(workspace, session, active, hook_input=hook_input)
        if action == "unbind" and not result["gaps"]:
            state["history"].append(active)
            state["active"] = None
            result = dict(result, status="unbound")
        save_state(state_path, state)
        return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["bind", "sync", "status", "unbind"])
    parser.add_argument("--workspace", required=True)
    parser.add_argument("--records-root")
    parser.add_argument("--session", required=True)
    parser.add_argument("--draft-id")
    parser.add_argument("--source")
    parser.add_argument("--start-line", type=int)
    parser.add_argument("--hook-input", action="store_true", help="Read the native hook payload from stdin")
    parser.add_argument('--change')
    parser.add_argument('--talk-id')
    args = vars(parser.parse_args())
    try:
        args["hook_input"] = json.load(sys.stdin) if args["hook_input"] else None
        result = record(**args)
        print(json.dumps(result, ensure_ascii=False))
        return 2 if result["status"] == "partial" else 0
    except (OSError, ValueError) as error:
        print(json.dumps({"status": "partial", "gaps": [str(error)]}))
        return 2


if __name__ == "__main__":
    sys.exit(main())
