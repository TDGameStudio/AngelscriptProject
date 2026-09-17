/**
 * @version v1
 * @summary FQuat members inside TArray and TMap containers, filled during BeginPlay. The observers confirm the defaults are empty and that a script-side fill lands the identity and yawed values.
 * @topic Language
 */
/**
 * @version root
 * @summary FQuat members inside TArray and TMap containers, filled during BeginPlay. The observers confirm the defaults are empty and that a script-side fill lands the identity and yawed values.
 * @topic Baseline
 */
UCLASS()
class ACoverageFQuatContainerActor : AActor
{
	UPROPERTY()
	TArray<FQuat> QuatArray;

	UPROPERTY()
	TMap<int, FQuat> IntToQuatMap;

	/**
	 * Fills both containers with their oracle values.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; both containers are populated
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		QuatArray.Add(FQuat::Identity);
		QuatArray.Add(FQuat(FRotator(0, 90, 0)));
		QuatArray.Add(FQuat(FRotator(90, 0, 0)));

		IntToQuatMap.Add(1, FQuat::Identity);
		IntToQuatMap.Add(2, FQuat(FRotator(0, 45, 0)));
		IntToQuatMap.Add(3, FQuat(FRotator(45, 0, 0)));
	}

	/**
	 * Observe that a locally constructed actor leaves both containers empty.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when both containers report 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool FQuatContainersDefaultToEmpty()
	{
		if (QuatArray.Num() != 0)
		{
			return false;
		}

		return IntToQuatMap.Num() == 0;
	}

	/**
	 * Observe that a script-side fill lands the expected values.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs both containers filled from script
	 * @Return true when the count, identity and yawed entries match
	 * @Boundary script fill
	 */
	UFUNCTION()
	bool FQuatContainersScriptFillBoundary()
	{
		QuatArray.Add(FQuat::Identity);
		QuatArray.Add(FQuat(FRotator(0, 90, 0)));
		IntToQuatMap.Add(1, FQuat::Identity);

		if (QuatArray.Num() != 2)
		{
			return false;
		}

		if (!QuatArray[0].Equals(FQuat::Identity, 0.001))
		{
			return false;
		}

		if (Math::Abs(QuatArray[1].Z) <= 0.5)
		{
			return false;
		}

		return IntToQuatMap[1].Equals(FQuat::Identity, 0.001);
	}
}
/** @end */
