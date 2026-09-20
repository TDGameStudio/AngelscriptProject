# Stable keys and VM execution

English rendering of the accepted findings from 2026-09-15, with the 2026-09-16 admission clarification.

Renaming classes, fields and queries does not change asSStableKey's 32-byte identity or schema/layout hash meaning. CreateObjectType/CreateFunction establish the stable key; injection indexes the same key and pointer in A and B. Shared BoundTypeIds require one preassigned process ID rather than per-Engine mutation.

VM changes are behavioral: Prepare currently compares function ownership, object allocation and some cleanup paths ask Type.GetEngine, and GetEngine can fall back through Definitions.BoundEngine. Host objects must remain null. Execution ownership must come from Context or object headers, with receiving-engine admission and native leases. Script objects still acquire a unique Engine during registration.

Existing link checks that tolerate a null owner are insufficient proof of admission. A function having a stable key or process ID does not authorize an uninjected Engine to execute it. Retain script and live isolation and mixed-closure lifetime when adapting the VM.
