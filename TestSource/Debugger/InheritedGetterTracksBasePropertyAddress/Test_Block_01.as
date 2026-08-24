// Theme: Debugger marker. Derived getter tracks inherited Health address.
// C++: InheritedGetterTracksBasePropertyAddress. Health=42 on base.
// Extra: derived does not redeclare Health. DiagnosticOnly.

UCLASS()
class ADebuggerValueBaseProbe : AActor
{
	UPROPERTY()
	int Health = 42;
}

UCLASS()
class ADebuggerValueDerivedProbe : ADebuggerValueBaseProbe
{
	UFUNCTION()
	int GetHealth() const
	{
		return Health;
	}
}
