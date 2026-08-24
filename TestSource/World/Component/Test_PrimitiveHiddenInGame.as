// Theme: World.Component. WorldStory: SetHiddenInGame(true).
// C++: AngelscriptCoveragePrimitiveComponentTests.cpp::PrimitiveHiddenInGame
// sha256=63973f9c665eb981aa0fb22e4887d7240cebad555d30d3895478232303bc2e31; lines 1085-1105.
// Oracle VerifyByPath SetHiddenInGameAccepted=true; native bHiddenInGame true.
// Extra: local construct InitiallyHidden stays declared true, accepted false,
// MeshComp null. FixtureIsolated.

UCLASS()
class ACoveragePrimitiveHiddenInGameActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UStaticMeshComponent MeshComp;

	UPROPERTY()
	bool InitiallyHidden = true;

	UPROPERTY()
	bool SetHiddenInGameAccepted = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		MeshComp.SetHiddenInGame(true);
		SetHiddenInGameAccepted = true;
	}
}

bool Observe_HiddenInGame_DefaultEmpty(ACoveragePrimitiveHiddenInGameActor Actor)
{
	if (Actor is null)
	{
		throw("Test_PrimitiveHiddenInGame setup: required Actor is null");
	}
	return Actor.InitiallyHidden
		&& !Actor.SetHiddenInGameAccepted
		&& Actor.MeshComp == nullptr;
}

bool Observe_HiddenInGame_CopyIndependence(ACoveragePrimitiveHiddenInGameActor First, ACoveragePrimitiveHiddenInGameActor Second)
{
	if (First is null)
	{
		throw("Test_PrimitiveHiddenInGame setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_PrimitiveHiddenInGame setup: required Second is null");
	}
	First.SetHiddenInGameAccepted = true;
	First.InitiallyHidden = false;
	return First.SetHiddenInGameAccepted
		&& !First.InitiallyHidden
		&& !Second.SetHiddenInGameAccepted
		&& Second.InitiallyHidden;
}
