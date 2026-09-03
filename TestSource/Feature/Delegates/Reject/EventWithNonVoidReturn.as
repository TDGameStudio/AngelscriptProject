/**
 * A multicast event with a non-void return is rejected. Events fan out to many
 * listeners and cannot return a value.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.EventWithNonVoidReturn
 * @Harness CompileReject
 * @Tag Feature.Delegates.EventWithNonVoidReturn
 * @Kind CompileReject
 * @Covers Delegates.Declaration
 * @Inputs event int FOnChangedReturn()
 * @Return does not compile
 * @Provenance Theme: Feature.Delegates. Isolated compile-fail: event with a non-void return.
 * @Provenance C++: AngelscriptSyntaxDelegateEventTests.cpp::Declaration_Negative_VoidDelegateWithReturn
 * @Provenance sha256 from theme-refs TS-FEAT-0340; lines 268-270.
 * @Provenance Expected diagnostic: "Event (multicast) with non-void return should fail".
 * @Provenance Isolate this failing program; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

/**
 * The isolated failing program: a multicast event that returns int.
 *
 * @Kind CompileReject
 * @Covers Delegates.Declaration
 * @Inputs none
 * @Return does not compile; events are void
 */
event int FOnChangedReturn();
