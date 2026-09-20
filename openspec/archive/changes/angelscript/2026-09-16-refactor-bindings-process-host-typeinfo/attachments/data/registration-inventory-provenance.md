# Registration inventory provenance

This CSV is a planning seed copied from the predecessor's data/provider-migration.csv on 2026-09-16. Original source, line, symbol, phase, family and file_sha256 fields are retained as historical observations. The task column maps families to this replacement: Core 4.1, Math 4.2, Containers 4.3, ObjectsReflection 4.4, EngineGameplay 4.5, EngineServices 4.6.

The predecessor's lexical count and hashes are not current eligibility or runtime proof. Task 3.1 refreshes source sites and effective registration/module/phase conditions; tasks 4.1-4.6 reconcile independently expected symbols and actual native/VM calls. Missing, renamed, compiled-out, policy-excluded and intentional no-output registrations require explicit dispositions. Imported entries do not authorize edits outside their owning source family or same-owner companion files.

This is a retained source inventory, not executable code or a compatibility requirement to preserve the old descriptor pipeline. No complete-family pass is claimed in this creation delivery.

Task 3.1 refreshed the CSV against current `Binds/**`, `Core/AngelscriptBinds.cpp`, `Core/AngelscriptSkipBinds.cpp`, and `Testing/*.cpp` bind sites on 2026-09-16. New columns: `disposition` (`present`, `companion_no_output`, `missing_or_renamed`) and `condition_present`. Historical family/task ownership is preserved when the source file still exists; companion files without `FAngelscriptBind` keep `companion_no_output`. Family tasks 4.1-4.6 still own per-member eligibility and executable proof.
