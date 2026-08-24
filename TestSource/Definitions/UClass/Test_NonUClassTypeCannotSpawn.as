// Theme: Definitions.UClass. C++ compiles a UObject (CSV NegativeDiagnostic is spawn rejection, not compile-fail).
// C++: AngelscriptScriptClassCreationTests.cpp::NonUClassTypeCannotSpawn
// Oracle: class is not actor-derived; NewObject succeeds; world SpawnActor returns null. Value default 5.
// Extra: nullptr handle is the empty vector; mutating First does not write Second.
// FixtureIsolated. Runner owns NewObject vs SpawnActor. Keep Value.

UCLASS()
class UTestScriptClassNonUClassTypeCannotSpawn : UObject
{
	UPROPERTY()
	int Value = 5;
}

bool Observe_NonActorDefault_Nominal(UTestScriptClassNonUClassTypeCannotSpawn Object)
{
	return Object.Value == 5;
}

bool Observe_NonActorDefault_NullDefault()
{
	UTestScriptClassNonUClassTypeCannotSpawn Object = nullptr;
	return Object == nullptr;
}

bool Observe_NonActorDefault_CopyIndependent(
	UTestScriptClassNonUClassTypeCannotSpawn First,
	UTestScriptClassNonUClassTypeCannotSpawn Second)
{
	First.Value = 0;
	return Second.Value == 5;
}
