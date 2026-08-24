// Theme: World.Component. WorldStory: GetNumMaterials on a mesh with no asset.
// C++: AngelscriptCoverageSpecialComponentTests.cpp::StaticMeshComponent
// sha256=85a7db91cc7319ad6277bd7f54ad9d34bbe339243db64863c7d98590089b3aa3; lines 81-101.
// Oracle VerifyByPath MaterialCount=0; native GetStaticMesh null.
// Extra: local construct MeshWasNull stays declared true, MaterialCount 0,
// MeshComp null. FixtureIsolated.

UCLASS()
class ACoverageSpecialStaticMeshActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UStaticMeshComponent MeshComp;

	UPROPERTY()
	bool MeshWasNull = true;

	UPROPERTY()
	int MaterialCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Get material count
		MaterialCount = MeshComp.GetNumMaterials();
	}
}

bool Observe_StaticMeshComponent_DefaultEmpty(ACoverageSpecialStaticMeshActor Actor)
{
	if (Actor is null)
	{
		throw("Test_StaticMeshComponent setup: required Actor is null");
	}
	return Actor.MeshWasNull
		&& Actor.MaterialCount == 0
		&& Actor.MeshComp == nullptr;
}

bool Observe_StaticMeshComponent_CopyIndependence(ACoverageSpecialStaticMeshActor First, ACoverageSpecialStaticMeshActor Second)
{
	if (First is null)
	{
		throw("Test_StaticMeshComponent setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_StaticMeshComponent setup: required Second is null");
	}
	First.MeshWasNull = false;
	First.MaterialCount = 1;
	return !First.MeshWasNull
		&& First.MaterialCount == 1
		&& Second.MeshWasNull
		&& Second.MaterialCount == 0;
}
