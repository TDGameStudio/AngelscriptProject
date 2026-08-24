// Theme: Feature.Delegates. Isolated compile-fail: Broadcast string vs int Val.
// C++: AngelscriptSyntaxDelegateEventTests.cpp::Binding_Negative_WrongArgTypeBroadcast
// sha256 from theme-refs TS-FEAT-0348; lines 431-444.
// Expected diagnostic: "Broadcast with wrong argument type should fail".
// Isolate this failing program; do not add declarations that would compile it away.
// DiagnosticOnly.

event void FOnChangedBadArgType(int Val);

class ADelBadArgTypeActor : AActor
{
	UPROPERTY()
	FOnChangedBadArgType OnChanged;

	void Fire()
	{
		OnChanged.Broadcast("hello");
	}
}
