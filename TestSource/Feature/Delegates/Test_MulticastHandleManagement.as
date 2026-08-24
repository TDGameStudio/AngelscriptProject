// Theme: Feature.Delegates. Isolated compile-fail: FDelegateHandle add/remove is not an AS API.
// C++: AngelscriptCoverageMulticastDelegateTests.cpp::MulticastHandleManagement
// CompileAndExpectFailure diagnostic contains "FDelegateHandle".
// AS multicast uses AddUFunction/Unbind by object and function name, not C++ handles.
// Isolate this failing construct; do not add declarations that would compile it away.
// DiagnosticOnly. FixtureIsolated.

event void FCoverageMulticastHandleSignal();

UCLASS()
class ACoverageMulticastHandleActor : AActor
{
	UPROPERTY()
	FCoverageMulticastHandleSignal OnMulticast;

	FDelegateHandle Handle1;

	UFUNCTION()
	void Listener1()
	{
	}

	void TryHandleManagement()
	{
		Handle1 = OnMulticast.AddUFunction(this, n"Listener1");
		OnMulticast.Remove(Handle1);
	}
}
