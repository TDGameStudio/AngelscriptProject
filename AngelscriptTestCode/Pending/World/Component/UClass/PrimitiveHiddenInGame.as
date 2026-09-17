/**
 * @version v1
 * @summary SetHiddenInGame accepted on a static mesh component. C++ verifies the flag and the native bHiddenInGame by path. The observers cover the declared defaults and copy independence.
 * @topic World
 */
/**
 * @version root
 * @summary SetHiddenInGame accepted on a static mesh component. C++ verifies the flag and the native bHiddenInGame by path. The observers cover the declared defaults and copy independence.
 * @topic Baseline
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
/** @end */
