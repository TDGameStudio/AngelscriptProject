/**
 * SetHiddenInGame accepted on a static mesh component. C++ verifies the flag and
 * the native bHiddenInGame by path. The observers cover the declared defaults and
 * copy independence.
 *
 * @Theme World.Component
 * @Subject Component.PrimitiveHiddenInGame
 * @Harness UClass
 * @Tag World.Component.PrimitiveHiddenInGame
 * @Provenance Theme: World.Component. WorldStory: SetHiddenInGame(true).
 * @Provenance C++: AngelscriptCoveragePrimitiveComponentTests.cpp::PrimitiveHiddenInGame
 * @Provenance sha256=63973f9c665eb981aa0fb22e4887d7240cebad555d30d3895478232303bc2e31; lines 1085-1105.
 * @Provenance Oracle VerifyByPath SetHiddenInGameAccepted=true; native bHiddenInGame true.
 * @Provenance Extra: local construct InitiallyHidden stays declared true, accepted false,
 * @Provenance MeshComp null. FixtureIsolated.
 */

UCLASS()
class ACoveragePrimitiveHiddenInGameActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UStaticMeshComponent MeshComp;

	UPROPERTY()
	bool InitiallyHidden = true;

	UPROPERTY()
	bool SetHiddenInGameAccepted = false;

	/**
	 * WorldStory: BeginPlay hides the mesh in game and records that the call was
	 * accepted.
	 *
	 * @Kind WorldStory
	 * @Covers Component.PrimitiveHiddenInGame
	 * @Inputs a default-attached UStaticMeshComponent
	 * @Return SetHiddenInGameAccepted true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		MeshComp.SetHiddenInGame(true);
		SetHiddenInGameAccepted = true;
	}

	/**
	 * Observe that a locally constructed actor keeps its declared defaults.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveHiddenInGame
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when InitiallyHidden is true, the flag is clear and MeshComp is null
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (!InitiallyHidden)
		{
			return false;
		}
		if (SetHiddenInGameAccepted)
		{
			return false;
		}
		return MeshComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveHiddenInGame
	 * @Inputs this actor plus a second actor
	 * @Return true when this is flipped and the other keeps its declared defaults
	 * @Param Second the other actor, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoveragePrimitiveHiddenInGameActor Second)
	{
		if (Second is null)
		{
			throw("PrimitiveHiddenInGame setup: required Second is null");
		}
		SetHiddenInGameAccepted = true;
		InitiallyHidden = false;

		if (!SetHiddenInGameAccepted)
		{
			return false;
		}
		if (InitiallyHidden)
		{
			return false;
		}
		if (Second.SetHiddenInGameAccepted)
		{
			return false;
		}
		return Second.InitiallyHidden;
	}
}
