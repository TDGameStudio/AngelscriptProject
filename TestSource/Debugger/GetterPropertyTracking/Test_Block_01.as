// Theme: Debugger marker payload. Getter tracks the Health property address.
// C++: AngelscriptDebuggerValueTests.cpp::GetterPropertyTracking
// Oracle (DAP/C++): Health UPROPERTY 42, GetHealth resolves, actor in a World.
// Extra: default Health 42 is the nominal marker; 0 would be a different probe.
// DiagnosticOnly for the debug session; this file is a stable marker program.

UCLASS()
class ADebuggerValueGetterProbe : AActor
{
	UPROPERTY()
	int Health = 42;

	UFUNCTION()
	int GetHealth() const
	{
		return Health;
	}
}
