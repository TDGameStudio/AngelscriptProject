# Singleton reload and PIE policy

## 1. Classification inputs

Reload classification occurs before active module swap and compares:

- stable definition IDs and descriptor hashes;
- per-lifecycle body hashes;
- declared class stable paths and class replacement/shape plan;
- generated Getter signatures/routes;
- currently materialized default-slot classes;
- whether any Game/PIE/GamePreview World is in an active PIE session.

The result is computed for the whole candidate batch. A related module must not be partially accepted while another related module is deferred.

## 2. Classification matrix

| Change | Outside PIE | During PIE |
| --- | --- | --- |
| unrelated ordinary function body | existing soft reload | existing soft reload |
| named Type ordinary method body | preserve instance/route | reject and queue |
| lifecycle block body | preserve instance, update route, no callback replay | reject and queue |
| lifecycle presence/signature | structural reconciliation | reject and queue |
| reflected field/superclass shape | compatible replacement or candidate failure | reject and queue |
| declaration Name/namespace/module identity | delete old + add new lazy | reject and queue |
| Scope change | delete old + add new lazy | reject and queue |
| declared Type change | delete old + add new lazy | reject and queue |
| active default-slot class body/shape | route update or class replacement | reject and queue |
| inactive class with no named/default dependency | normal existing policy | normal existing policy |

“Reject and queue” means return the existing full-reload-needed/partially-handled signal expected by the Editor pipeline, retain last-good code and state, and coalesce subsequent edits so the latest source is compiled once after PIE.

## 3. Non-PIE body-only update

When identity, descriptor shape and UClass shape are unchanged:

1. compile and validate new hidden/public functions;
2. atomically switch function routing with the module's existing soft-reload mechanism;
3. retain all Empty/Ready slots and object addresses;
4. do not call Create, Init, Reload or Deinit;
5. future explicit lifecycle events use the newest function bodies.

This includes editing an Init body after an instance is Ready: the existing instance is not reinitialized, but a later newly created World slot uses the new Init.

## 4. Compatible structural replacement

A slot is eligible only if its stable named identity and declared Type semantic identity remain unchanged, or it is a default slot whose stable class path is being authoritatively reinstanced.

Transaction outline:

1. candidate module/class generation and descriptor validation succeed;
2. freeze Gets for affected slots;
3. create one replacement per Ready slot using its actual scope/World and new class;
4. copy same-name reflected properties only when property types/containers are compatible;
5. keep new-class defaults for added/incompatible fields;
6. preserve Actor World, Level and Transform through the Actor replacement protocol;
7. validate the complete replacement set before publishing;
8. publish the Registry pointers and one old-to-new UObject map;
9. let `ClassReloadHelper` replace external references without spawning objects;
10. call Reload exactly once on each new object after state copy/reference routing;
11. Deinit/release obsolete objects according to the reload-specific replacement protocol, avoiding normal final-release callbacks twice;
12. unfreeze Gets.

The implementation must define the exact old-object Deinit point in code/tests so Reload replacement cannot double-call Deinit. The required observable contract is one Reload on the published replacement and at most one Deinit for each retired instance.

## 5. Identity change

Changing Name, namespace, module stable identity, Scope or declared Type is not migration. Reconcile as:

1. validate the complete candidate definition set;
2. release old Ready slots with Deinit in reverse sequence;
3. remove old descriptor/routes;
4. install new descriptor/routes with Empty slots only;
5. create the new instance only on a later Get.

No reflected state, object reference, creation sequence or LastError crosses the identity boundary.

## 6. Failure boundaries

| Failure point | Required outcome |
| --- | --- |
| preprocess/compile/descriptor validation | active modules, routes, descriptors and slots unchanged |
| replacement creation/state copy before commit | destroy all unpublished replacements; old instances stay Ready |
| Editor reference-map validation before commit | abort and preserve old state |
| Reload callback after committed class swap | record error, invalidate/release only the affected replacement, leave slot retryable under the new module |
| Deinit exception during removal | record error, continue removing other slots and finish reconciliation |

If the existing class-generation pipeline cannot preserve old classes at a particular failure point, the implementation must move all fallible Singleton work earlier or document/test the post-commit retry behavior; it must not claim last-good rollback where the engine can no longer provide it.

## 7. PIE rejection details

During PIE, the protected dependency set contains:

- every module with a named singleton descriptor;
- every lifecycle hidden/public function generated by those descriptors;
- every script UClass referenced by a named descriptor;
- every UClass with a materialized default singleton slot in any active Engine/World;
- generated Getter routes and descriptor/archive data.

If a candidate touches this set, reject before module swap. No hidden lifecycle body, ordinary member body of a protected Type, descriptor, UClass, Getter route or instance is replaced. The old object continues serving calls for the remainder of PIE.

Completely unrelated function-body reloads stay eligible. This distinction preserves useful PIE iteration without accepting a half-updated singleton graph.

## 8. Multiple PIE Worlds and Engines

The decision is candidate-wide, but state remains Engine-local. One protected class edit during a two-player PIE session cannot update the server instance while deferring the client instance. After PIE, reconciliation enumerates every Engine registry and every affected World slot, builds all replacement pairs, validates them, then commits through the normal multi-engine reload hook ordering.

## 9. Queue coalescing

Repeated related edits during PIE coalesce by source/module identity. Diagnostics report the first rejection and current queued set without spamming one error per frame. At PIE end, compile the latest file contents, not every intermediate version. If the latest source is invalid, last-good stays active and the queue remains diagnosable for the next explicit reload.
