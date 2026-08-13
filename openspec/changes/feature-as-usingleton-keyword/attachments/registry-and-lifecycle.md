# Singleton registry and lifecycle design

## 1. Ownership hierarchy

```text
FAngelscriptEngine
└─ FAngelscriptSingletonRegistry
   ├─ Named Global slots:  DefinitionId -> Slot
   ├─ Named World slots:   WeakWorld -> (DefinitionId -> Slot)
   ├─ Default Global slots: StableClassPath -> Slot
   └─ Default World slots:  WeakWorld -> (StableClassPath -> Slot)
```

There is no process-static fallback map. A bound function resolves the owning `FAngelscriptEngine` from the executing AngelScript engine/context before it resolves a slot. This is required for isolated tests and tool Engines as well as production.

## 2. Identity and separation

| Kind | Definition key | Actual instance key |
| --- | --- | --- |
| named Global | `(Global, ModuleStableId, Namespace, Name)` | definition key |
| named World | `(World, ModuleStableId, Namespace, Name)` | definition key + weak `UWorld` |
| default Global | `(DefaultGlobal, StableClassPath)` | definition key |
| default World | `(DefaultWorld, StableClassPath)` | definition key + weak `UWorld` |

The key includes a kind discriminator, so a named `DefaultConfig of UGameConfig` never aliases `Singleton::GetGlobal(UGameConfig)`. A named declaration's Type is compared during reconciliation but not folded into its identity; a source Type change is explicitly delete+add.

World keys retain no World strongly. Slot values may contain World-owned objects while the World is alive, but the World cleanup hook removes those strong values before teardown completes.

## 3. Slot data and state machine

Minimum slot state:

```text
Key / descriptor reference
Resolved current UClass
Weak World (World slots only)
Strong candidate/ready UObject
State: Empty | Creating | Initializing | Ready | Releasing
CreationSequence
LastError / failure generation
```

Transitions:

```text
Empty -> Creating -> Initializing -> Ready -> Releasing -> Empty/removed
          |             |
          +--failure----+-------------------------------> Empty
```

- A candidate remains private while Creating/Initializing.
- Re-entry into a slot in Creating or Initializing is a cycle, not a successful lookup.
- Only Ready is returned to script.
- Releasing blocks resurrection through the same slot and reports a lifecycle error.
- Failure clears strong candidate references after applying the correct UE destruction path.

A Game-Thread-local creation stack contains human-readable slot identities. On A -> B -> A, the exception reports the complete chain, and the outer failures unwind both unpublished candidates.

## 4. Creation matrix

| UObject family | Global built-in | World built-in | Notes |
| --- | --- | --- | --- |
| ordinary concrete UObject | yes | yes | transient Engine-owned holder for Global; resolved World ownership for World |
| AActor | no | yes | target-World Spawn/finish path; never `NewObject<AActor>` |
| UUserWidget | no | yes | `CreateWidget` with resolved World/player-compatible Context |
| UActorComponent | no | yes | `NewObject` plus target-World registration; special Owner/attachment uses custom Create |
| USubsystem family | no | no | collection-owned; use existing subsystem API |
| abstract/template/CDO/archetype | no | no | always invalid |

The built-in path fully completes the relevant Unreal construction/registration protocol before Init. Init still runs before the Registry publishes Ready, so other Singleton callers cannot observe the object between UE construction and script initialization.

“Any UObject subclass” therefore means any concrete subclass for which one of these legal protocols or a validated custom Create exists. It does not authorize spawning World-owned types globally or stealing objects from another owner.

## 5. Custom Create validation

Custom Create is useful for a non-default Outer, Actor spawn parameters, a player-owned widget or attached component. It does not weaken Registry ownership. After the function returns, validate in this order:

1. non-null and valid low-level UObject;
2. exact class or subclass assignable to the declared Type;
3. not CDO, archetype, default subobject, pending kill or newer-version residue;
4. not a USubsystem/collection-owned instance;
5. not already present in any named/default slot of this Engine;
6. for World scope, `GetWorld()` equals the resolved World and the World is eligible/not tearing down;
7. for Global scope, the object is not an Actor/Widget/Component and has no borrowed unrelated World lifecycle;
8. ownership can be transferred to the Registry until Deinit/release.

On failure, the Registry never publishes the object. It only destroys a candidate that the call demonstrably created for the Registry; it must not destruct an ambiguous borrowed object while reporting that borrowing is invalid.

## 6. Init, publication and retry

First Get sequence:

1. resolve current Engine, descriptor/default Type and optional World;
2. reject off-thread, invalid World, invalid Type and Releasing state;
3. return immediately if Ready;
4. mark Creating and push slot on creation stack;
5. execute built-in or custom Create;
6. validate and strongly retain the private candidate;
7. mark Initializing and invoke the optional generated global Init with the private candidate as real argument zero/implicit-this alias;
8. assign creation sequence, mark Ready, pop creation stack and return;
9. on any exception, run candidate-specific destruction, clear strong reference, record error, restore Empty, pop stack and propagate the exception.

Retry is explicit: the next Get after a failure repeats the entire flow with a fresh candidate. There is no permanent poison state. State Dump exposes LastError/failure generation without triggering a retry.

## 7. Release order

Each Ready transition gets a monotonically increasing sequence within the Registry. For World cleanup, select that World's Ready slots and sort descending. For Engine shutdown:

1. reject new Get operations;
2. release every remaining World bucket, each in descending sequence;
3. release named/default Global slots together in descending sequence;
4. detach delegates and destroy the Registry before destroying the AngelScript engine.

Release sequence per slot:

1. transition Ready -> Releasing;
2. invoke the optional generated global Deinit once with the Ready object as real argument zero/implicit-this alias;
3. capture but do not rethrow Deinit errors across the shutdown loop;
4. perform Actor destroy, Component unregister/destroy, Widget/object reference release as applicable;
5. clear the strong holder and remove/reset the slot.

Reverse order supports dependencies established by nested Get during Init. It cannot solve arbitrary external references; such references may keep the UObject memory alive after Registry release, but the object is no longer a singleton and Deinit has already run.

## 8. GC and UObject reference policy

The Registry must expose candidates and Ready instances to Unreal GC through a supported strong-reference mechanism. The selected implementation must satisfy all of these tests:

- no legacy `/Script/AngelscriptAssets` package or `RF_MarkAsRootSet` is used;
- a Ready object's reflected child references survive collection;
- an Empty descriptor retains no UObject;
- a failed candidate is collectible after rollback;
- World cleanup removes the Registry's last strong reference;
- one Engine cannot report another Engine's instances through its collector.

## 9. Default slot limitations

Default slots have no source declaration and therefore no Create/Init/Reload/Deinit block. They use only built-in creation and generic release. A default Actor/Widget/Component must use `GetWorld`; `GetGlobal` rejects it. If a project needs custom creation or initialization, it must define a named `singleton`.

Class reinstancing updates a default slot's resolved pointer using stable class path plus the authoritative old/new class map. A call passing an obsolete UClass pointer is normalized to the most-up-to-date class before key lookup.
