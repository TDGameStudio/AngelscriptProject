# Fragment-bound streaming diagnostics

English translation of angelscript/diagnostic-engine/findings/streaming-diag-how.md, 2026-09-14. Q7 requested streaming; Q8 and N1d selected the initial overload set and asCDiagnostic.

Diag returns a short-lived move-only object. operator<< fills the existing diagnostic payload. Destruction reports that payload to the bound fragment, not to an engine-wide in-flight slot. Copying is forbidden and moving transfers the single reporting obligation. Basic does not acquire a semantic QualType dependency; a future Sema-local formatter can add a semantic overload in its owning layer.

The accepted name avoids both asCBuilder and the separately planned asCDiagnosticResult snapshot. Draft/Pending/Streaming alternatives were rejected.

```cpp
// Interface shape in as_diagnostics.h; overload mechanics must support temporaries.
class asCDiagnostic {
    asCDiagnosticFragment* Target = nullptr;
    asSDiagnosticRecord Pending;
    bool bCommit = false;
    // Construction binds Target and payload; move transfers bCommit.
    // Destruction reports once when bCommit is true.
};
// Fragment.Diag(Range, ID) returns asCDiagnostic.
// Streaming values: asSDiagnosticArgument, asSDiagnosticFixIt,
// asCSourceRange (RelatedRanges), FStringView, int64, bool.
```

The original source sketch used non-member lvalue-reference overloads as a conceptual shape. The executable contract is a temporary-friendly chain such as Diag(Range, 1005) << FStringView(...); planning does not prescribe that non-compiling binding shape.

An unterminated string may simply call Diag(Range, 1005) without streaming. Destruction writes to the fragment and explicit Flush later submits it. Additional arguments/fixes use the same API, not a second reporting path. Note is outside the initial streaming slice.
