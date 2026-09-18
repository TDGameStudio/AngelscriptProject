## Start from actual source

- Locate the owning module/file, the subject's role and relevant callers and callees. Check source context rather than copying an isolated search hit.
- Identify the source version or commit when available. Do not treat main-branch knowledge as proof of a fixed Unreal release.
- Keep actual identifiers and important control order. Label excerpts with their source; label simplifications and identify omitted detail.
- Do not manufacture a class, function, CVar, field or signature to complete an example. Proposed design shapes must be clearly labeled.
- A source excerpt and a simplified overview serve different needs. Show both only when each adds useful information; there is no compulsory two-block rule.

## Explain inside the code

- Put concrete functional explanation beside the relevant statement, branch, variable or phase in a language-tagged code block.
- Explain why the step exists, where inputs come from, what it produces or changes, what the branch selects and how it connects to lifetime/state.
- Preserve the function's recognizable structure. Remove unrelated boilerplate with explicit omission markers; do not rearrange behavior into a cleaner but inaccurate implementation.
- Use code comments understandable to someone new to the source. Unexplained phrases such as “put in bucket” or “prepare context” are insufficient.
- Use surrounding prose to establish purpose, architecture and conclusions. Inline functional comments do not prohibit explaining context outside a code block.

```cpp
// Simplified from <module>/<relative source path>, <verified version or commit>.
// <Subject>::<Method> is called by <verified caller> when <actual trigger>.
<Return> <Subject>::<Method>(<key parameters>)
{
    <Input> input = <Read>();       // Comes from <owner>; valid because <precondition>.
    if (<condition>)                // Selects <behavior>; otherwise <other behavior>.
    {
        <Operation>(input);        // Changes <state/resource>; <consumer> reads it next.
    }
    <Publish>();                   // Makes <result> visible until <lifetime boundary>.
    // <Unrelated details omitted; state what the simplification excludes.>
}
```

- This shape is an authoring guide, not executable source. Replace it with verified real identifiers in an actual explanation.

## Trace callers and callees

- Show the caller side up to the relevant entry point or trigger: who reaches the function, under which condition, how often where known, and what state exists on entry.
- Show the callee side down to the meaningful boundary: helpers, reads, writes, creation, scheduling and downstream consumers.
- Distinguish synchronous calls from registration, deferred execution, event delivery and later reads. Do not draw them as interchangeable calls.
- Mark the subject with `◆` when useful. Use edge labels such as `[calls]`, `[schedules]`, `[reads]` and `[writes]`, with a `//` explanatory clause on meaningful nodes.
- Include signatures or arguments when they explain routing. Put source paths/version in banners or nearby links rather than every tree node.
- Avoid both a hard recursion limit and an unbounded graph dump. Stop when the relevant responsibility, side effect or external contract is clear; name unresolved boundaries instead of guessing.

```text
<verified trigger>                                  // Starts this path under <condition>.
└─[calls] <Caller>::<Method>(<key args>)              // Establishes <state> before delegation.
   └─[calls] <Subject>::<Method>(<key args>) ◆        // Owns the behavior being explained.
      ├─[calls] <Helper>(<arg>) → <result>           // Computes <meaning> with <invariant>.
      └─[writes] <Store>.<Operation>(<key>, <value>)  // Publishes data owned by <owner>.

<Consumer>::<Method>()                               // Runs later under <trigger>.
└─[reads] <Store>                                    // Consumes <value>; a miss means <meaning>.
```

## Validate the explanation

- Compare simplified code and tree with actual source: order, guards, ownership, scheduling and side effects must agree.
- Ensure class role, architecture, lifecycle and data vocabulary match the code. Resolve inconsistent names before presenting a choice.
- Do not claim runtime execution from static source reading. Cite observed traces or tests separately.
- If a version differs, explain the discrepancy and how to find the corresponding symbol in the target source.
