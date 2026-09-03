/**
 * Broadcasting a multicast event with the wrong argument type is rejected.
 * FOnChangedBadArgType takes an int, so Broadcast of a string fails.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.BroadcastWrongArgumentType
 * @Harness CompileReject
 * @Tag Feature.Delegates.BroadcastWrongArgumentType
 * @Kind CompileReject
 * @Covers Delegates.Binding
 * @Inputs OnChanged.Broadcast("hello") against int Val
 * @Return does not compile
 * @Provenance Theme: Feature.Delegates. Isolated compile-fail: Broadcast string vs int Val.
 * @Provenance C++: AngelscriptSyntaxDelegateEventTests.cpp::Binding_Negative_WrongArgTypeBroadcast
 * @Provenance sha256 from theme-refs TS-FEAT-0348; lines 431-444.
 * @Provenance Expected diagnostic: "Broadcast with wrong argument type should fail".
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
event void FOnChangedBadArgType(int Val);

class ADelBadArgTypeActor : AActor
{
	UPROPERTY()
	FOnChangedBadArgType OnChanged;

	/**
	 * The isolated failing program: Broadcast of a string against an int.
	 *
	 * @Kind CompileReject
	 * @Covers Delegates.Binding
	 * @Inputs none
	 * @Return does not compile; the event requires an int
	 */
	void Fire()
	{
		OnChanged.Broadcast("hello");
	}
}
