/**
 * @version v1
 * @summary GetNumMaterials on a static mesh component that has no asset assigned. C++ verifies the count and the native null mesh. The observers cover the declared defaults and copy independence.
 * @topic World
 */
/**
 * @version root
 * @summary GetNumMaterials on a static mesh component that has no asset assigned. C++ verifies the count and the native null mesh. The observers cover the declared defaults and copy independence.
 * @topic Baseline
 */
UCLASS()
class ACoverageSpecialStaticMeshActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UStaticMeshComponent MeshComp;

	UPROPERTY()
	bool MeshWasNull = true;

	UPROPERTY()
	int MaterialCount = 0;

	/**
	 * WorldStory: BeginPlay reads the material count off a component with no mesh
	 * assigned.
	 *
	 * @Kind WorldStory
	 * @Covers Component.StaticMeshComponent
	 * @Inputs a default-attached UStaticMeshComponent with no asset
	 * @Return MaterialCount == 0
	 * @Boundary no asset assigned
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Get material count
		MaterialCount = MeshComp.GetNumMaterials();
	}

	/**
	 * Observe that a locally constructed actor keeps its declared defaults.
	 *
	 * @Kind Observe
	 * @Covers Component.StaticMeshComponent
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when MeshWasNull is true, the count is 0 and MeshComp is null
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (!MeshWasNull)
		{
			return false;
		}
		if (MaterialCount != 0)
		{
			return false;
		}
		return MeshComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.StaticMeshComponent
	 * @Inputs this actor plus a second actor
	 * @Return true when this is flipped and the other keeps its declared defaults
	 * @Param Second the other actor, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSpecialStaticMeshActor Second)
	{
		if (Second is null)
		{
			throw("StaticMeshComponent setup: required Second is null");
		}
		MeshWasNull = false;
		MaterialCount = 1;

		if (MeshWasNull)
		{
			return false;
		}
		if (MaterialCount != 1)
		{
			return false;
		}
		if (!Second.MeshWasNull)
		{
			return false;
		}
		return Second.MaterialCount == 0;
	}
}
/** @end */
