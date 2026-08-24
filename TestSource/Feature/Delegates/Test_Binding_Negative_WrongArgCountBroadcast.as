// Theme: Feature.Delegates. Isolated compile-fail: Broadcast with zero args vs int Val.
// C++: AngelscriptSyntaxDelegateEventTests.cpp::Binding_Negative_WrongArgCountBroadcast
// sha256 from theme-refs TS-FEAT-0347; lines 408-421.
// Expected diagnostic: "Broadcast with wrong argument count should fail".
// Isolate this failing program; do not add declarations that would compile it away.
// DiagnosticOnly.

event void FOnChangedBadArgCnt(int Val);

class ADelBadArgCntActor : AActor
{
	UPROPERTY()
	FOnChangedBadArgCnt OnChanged;

	void Fire()
	{
		OnChanged.Broadcast();
	}
}
