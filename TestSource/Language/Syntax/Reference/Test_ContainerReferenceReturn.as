// Theme: Language.Syntax.Reference. WorldStory: member TArray returned by reference.
// C++: AngelscriptCoverageContainerAdvancedTests.cpp::ContainerReferenceReturn
// CompileScriptModule + spawn + BeginPlay + VerifyByPath RefSize=3, FirstValue=10.
// sha256=b266017e8edba8c4f35bddbbdb37f04a777ed1af587bccb6ae944eb6acc02e1b; lines 258-289.
// Extra: local construct leaves Values empty, RefSize=0, FirstValue=0.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageContainerReferenceReturnActor : AActor
{
	UPROPERTY()
	TArray<int> Values;

	UPROPERTY()
	int RefSize = 0;

	UPROPERTY()
	int FirstValue = 0;

	TArray<int>& GetValuesRef()
	{
		return Values;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Values.Add(10);
		Values.Add(20);

		TArray<int>& Ref = GetValuesRef();
		Ref.Add(30);

		RefSize = Values.Num();
		FirstValue = Ref[0];
	}
}

bool Observe_ContainerRef_DefaultEmpty(ACoverageContainerReferenceReturnActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ContainerReferenceReturn setup: required Actor is null");
	}
	return Actor.RefSize == 0 && Actor.FirstValue == 0 && Actor.Values.Num() == 0;
}
