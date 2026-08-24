// Theme: Containers.TSoftObjectPtr. WorldStory: TSoftClassPtr UPROPERTY specifiers.
// C++: AngelscriptCoverageSoftReferenceTests.cpp::SoftClassPtrAsProperty
// CompileScriptModule + spawn + BeginPlay. Oracle: PropertiesSet true; EditDefaultsOnly and
// BlueprintReadWrite flags on the reflected properties.
// Extra: local construct leaves PropertiesSet false and both class refs null.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageSoftClassPropertyActor : AActor
{
	UPROPERTY(EditDefaultsOnly)
	TSoftClassPtr<AActor> ActorClassSoft;

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	TSoftClassPtr<APawn> PawnClassSoft;

	UPROPERTY()
	bool PropertiesSet = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ActorClassSoft = AActor::StaticClass();
		PawnClassSoft = APawn::StaticClass();

		if (ActorClassSoft.IsValid() && PawnClassSoft.IsValid())
		{
			PropertiesSet = true;
		}
	}
}

bool Observe_SoftClassProperty_DefaultEmpty(ACoverageSoftClassPropertyActor Actor)
{
	if (Actor is null)
	{
		throw("Test_SoftClassPtrAsProperty setup: required Actor is null");
	}
	return Actor.PropertiesSet == false
		&& Actor.ActorClassSoft.IsNull()
		&& Actor.PawnClassSoft.IsNull();
}

bool Observe_SoftClassProperty_CopyIndependence(ACoverageSoftClassPropertyActor First, ACoverageSoftClassPropertyActor Second)
{
	if (First is null)
	{
		throw("Test_SoftClassPtrAsProperty setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_SoftClassPtrAsProperty setup: required Second is null");
	}
	First.ActorClassSoft = AActor::StaticClass();
	return First.ActorClassSoft.IsValid() && Second.ActorClassSoft.IsNull();
}
