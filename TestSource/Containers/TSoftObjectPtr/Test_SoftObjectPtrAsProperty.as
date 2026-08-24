// Theme: Containers.TSoftObjectPtr. WorldStory: TSoftObjectPtr UPROPERTY specifiers.
// C++: AngelscriptCoverageSoftReferenceTests.cpp::SoftObjectPtrAsProperty
// CompileScriptModule + spawn + BeginPlay. Oracle: PropertiesAssigned true; SoftActor EditAnywhere,
// SoftMesh BlueprintReadWrite, SoftPawn Category.
// Extra: local construct leaves PropertiesAssigned false and SoftMesh null.
// FixtureIsolated. Runner owns spawned actors.

UCLASS()
class ACoverageSoftRefPropertyActor : AActor
{
	UPROPERTY(EditAnywhere)
	TSoftObjectPtr<AActor> SoftActor;

	UPROPERTY(BlueprintReadWrite)
	TSoftObjectPtr<UStaticMesh> SoftMesh;

	UPROPERTY(Category="SoftRefs")
	TSoftObjectPtr<APawn> SoftPawn;

	UPROPERTY()
	bool PropertiesAssigned = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		SoftActor = SpawnActor(AActor::StaticClass());
		SoftPawn = Cast<APawn>(SpawnActor(APawn::StaticClass()));

		if (SoftActor.IsValid() && SoftPawn.IsValid())
		{
			PropertiesAssigned = true;
		}
	}
}

bool Observe_SoftRefProperty_DefaultEmpty(ACoverageSoftRefPropertyActor Actor)
{
	if (Actor is null)
	{
		throw("Test_SoftObjectPtrAsProperty setup: required Actor is null");
	}
	return Actor.PropertiesAssigned == false
		&& Actor.SoftActor.IsNull()
		&& Actor.SoftMesh.IsNull()
		&& Actor.SoftPawn.IsNull();
}

bool Observe_SoftRefProperty_CopyIndependence(ACoverageSoftRefPropertyActor First, ACoverageSoftRefPropertyActor Second)
{
	if (First is null)
	{
		throw("Test_SoftObjectPtrAsProperty setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_SoftObjectPtrAsProperty setup: required Second is null");
	}
	First.PropertiesAssigned = true;
	return First.PropertiesAssigned == true && Second.PropertiesAssigned == false && Second.SoftActor.IsNull();
}
