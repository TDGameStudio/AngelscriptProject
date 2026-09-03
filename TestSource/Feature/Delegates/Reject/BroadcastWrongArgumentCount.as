/**
 * Broadcasting a multicast event with the wrong argument count is rejected.
 * FOnChangedBadArgCnt takes one int, so Broadcast() with no arguments fails.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.BroadcastWrongArgumentCount
 * @Harness CompileReject
 * @Tag Feature.Delegates.BroadcastWrongArgumentCount
 * @Kind CompileReject
 * @Covers Delegates.Binding
 * @Inputs OnChanged.Broadcast() against int Val
 * @Return does not compile
 * @Provenance Theme: Feature.Delegates. Isolated compile-fail: Broadcast with zero args vs int Val.
 * @Provenance C++: AngelscriptSyntaxDelegateEventTests.cpp::Binding_Negative_WrongArgCountBroadcast
 * @Provenance sha256 from theme-refs TS-FEAT-0347; lines 408-421.
 * @Provenance Expected diagnostic: "Broadcast with wrong argument count should fail".
 * @Provenance Isolate this failing program; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

/**
 * A multicast event that takes one int.
 *
 * @Kind CompileReject
 * @Covers Delegates.Binding
 * @Inputs int Val
 * @Return nothing when broadcast
 */
event void FOnChangedBadArgCnt(int Val);

class ADelBadArgCntActor : AActor
{
	UPROPERTY()
	FOnChangedBadArgCnt OnChanged;

	/**
	 * The isolated failing program: Broadcast with no arguments.
	 *
	 * @Kind CompileReject
	 * @Covers Delegates.Binding
	 * @Inputs none
	 * @Return does not compile; the event requires one int
	 */
	void Fire()
	{
		OnChanged.Broadcast();
	}
}
