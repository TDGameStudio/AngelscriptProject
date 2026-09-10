# Document editor behavior

The editor keeps the Markdown file as its source of truth. Ordinary body segments use Milkdown Crepe; frontmatter, task machine definitions, Files lines and opaque syntax stay outside the rich-text editing boundary. Saving always validates protected source against the current save base.

Saving is explicit. The Save button remains available while an editable document is open, even before the debounced dirty indicator updates. Save and Ctrl/Cmd+S read live editor contents. A click with no changes reports that nothing needs saving and sends no write request. Navigation flushes live content to a workspace/path-scoped IndexedDB draft.

When an external writer advances the file revision, any local body edits remain visible and the draft retains its original base revision. The conflict panel offers comparison, draft download, discarding the draft, and **以磁盘版本为基准继续合并**. That last action explicitly adopts the displayed disk revision while keeping the live rich-text draft unchanged. It opens the difference view and asks the user to reconcile the body, then save explicitly. It does not automatically combine text or write the file.

Before adopting a newer base, protected fields in that disk version must exactly match the draft. If an external writer changed frontmatter, machine task lines, file scopes or opaque blocks, the rebase action fails, leaves the conflict active, and retains the original draft. The user can download their draft and load the disk version to transfer ordinary body changes. Protected fields are never silently copied between versions. Another external update during manual reconciliation starts a new revision conflict.
