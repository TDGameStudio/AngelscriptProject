/**
 * A delegate declaration without a parameter list is rejected. The type must
 * spell its signature in parentheses even when that list is empty.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DelegateWithoutParentheses
 * @Harness CompileReject
 * @Tag Feature.Delegates.DelegateWithoutParentheses
 * @Kind CompileReject
 * @Covers Delegates.Declaration
 * @Inputs delegate void FOnActionNoParens
 * @Return does not compile
 * @Provenance Theme: Feature.Delegates. Isolated compile-fail: delegate without parentheses.
 * @Provenance C++: AngelscriptSyntaxDelegateEventTests.cpp::Declaration_Negative_DelegateEmptyParens
 * @Provenance sha256 from theme-refs TS-FEAT-0342; lines 292-294.
 * @Provenance Expected diagnostic: "Delegate without parentheses should fail".
 * @Provenance Isolate this failing program; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

delegate void FOnActionNoParens;
