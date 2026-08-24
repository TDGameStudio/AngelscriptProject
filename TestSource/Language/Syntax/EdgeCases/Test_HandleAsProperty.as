// Theme: Language.Syntax.EdgeCases. WorldStory handle UPROPERTY specifiers and assign.
// C++: AngelscriptCoverageHandleTests.cpp::HandleAsProperty
// sha256=fd7776416e48293547702235fa57da10d6834e099b10a276fd76d9f06725bcd9; lines 344-372.
// Oracle: TargetActor CPF_Edit; TargetPawn CPF_BlueprintVisible; PropertiesAssigned=true.
// Extra: handles default null and PropertiesAssigned false. FixtureIsolated.

UCLASS()
class ACoverageHandlePropertyActor : AActor
{
	UPROPERTY(EditAnywhere)
	AActor TargetActor;

	UPROPERTY(BlueprintReadWrite)
	APawn TargetPawn;

	UPROPERTY(Category="Refs")
	UActorComponent TargetComponent;

	UPROPERTY()
	bool PropertiesAssigned = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TargetActor = this;
		TargetPawn = Cast<APawn>(SpawnActor(APawn::StaticClass()));

		if (TargetActor != nullptr && TargetPawn != nullptr)
		{
			PropertiesAssigned = true;
		}
	}
}

bool Observe_HandleAsProperty_DefaultEmpty(ACoverageHandlePropertyActor Actor)
{
	if (Actor is null)
	{
		throw("Test_HandleAsProperty setup: required Actor is null");
	}
	return Actor.TargetActor == nullptr && Actor.TargetPawn == nullptr && Actor.TargetComponent == nullptr && !Actor.PropertiesAssigned;
}
