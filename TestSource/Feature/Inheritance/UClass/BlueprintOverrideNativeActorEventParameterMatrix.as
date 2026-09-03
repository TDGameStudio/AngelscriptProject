/**
 * Native actor event BlueprintOverride parameter matrix. C++ verifies OnReset
 * ResetCount==1, self EndOverlap LastReason==22, ReadTransformByConstRef(10,20,12)
 * LastTransformScore==42, and Destroy EndPlayCount==1 DestroyedCount==1.
 *
 * @Theme Feature.Inheritance
 * @Subject Inheritance.BlueprintOverrideNativeActorEventParameterMatrix
 * @Harness UClass
 * @Tag Feature.Inheritance.BlueprintOverrideNativeActorEventParameterMatrix
 * @Provenance Theme: Feature.Inheritance. WorldStory native actor event BlueprintOverride parameter matrix.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::BlueprintOverrideNativeActorEventParameterMatrix
 * @Provenance Oracle: OnReset -> ResetCount==1; self EndOverlap -> LastReason==22;
 * @Provenance ReadTransformByConstRef(10,20,12) -> LastTransformScore==42;
 * @Provenance Destroy -> EndPlayCount==1, DestroyedCount==1.
 * @Provenance Extra: empty handle null; pre-notify counters 0; self BeginOverlap LastReason==11.
 * @Provenance FixtureIsolated. Keep ConstructionCount/DestroyedCount/EndPlayCount/ResetCount/LastReason/LastTransformScore.
 */

UCLASS()
class ACoverageUFunctionNativeEventActor : AActor
{
	UPROPERTY()
	int ConstructionCount = 0;

	UPROPERTY()
	int DestroyedCount = 0;

	UPROPERTY()
	int EndPlayCount = 0;

	UPROPERTY()
	int ResetCount = 0;

	UPROPERTY()
	int LastReason = -1;

	UPROPERTY()
	int LastTransformScore = 0;

	/**
	 * WorldStory: UserConstructionScript increments ConstructionCount.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.BlueprintOverrideNativeActorEventParameterMatrix
	 * @Inputs none
	 * @Return ConstructionCount incremented
	 */
	UFUNCTION(BlueprintOverride)
	void UserConstructionScript()
	{
		ConstructionCount += 1;
	}

	/**
	 * WorldStory: ActorBeginOverlap records 11 when OtherActor is this.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.BlueprintOverrideNativeActorEventParameterMatrix
	 * @Inputs the other actor
	 * @Return LastReason 11 when OtherActor is this, otherwise -11
	 * @Param OtherActor the overlapping actor
	 */
	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		LastReason = OtherActor == this ? 11 : -11;
	}

	/**
	 * WorldStory: ActorEndOverlap records 22 when OtherActor is this.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.BlueprintOverrideNativeActorEventParameterMatrix
	 * @Inputs the other actor
	 * @Return LastReason 22 when OtherActor is this, otherwise -22
	 * @Param OtherActor the overlapping actor
	 */
	UFUNCTION(BlueprintOverride)
	void ActorEndOverlap(AActor OtherActor)
	{
		LastReason = OtherActor == this ? 22 : -22;
	}

	/**
	 * WorldStory: EndPlay increments EndPlayCount and stores the reason.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.BlueprintOverrideNativeActorEventParameterMatrix
	 * @Inputs the end-play reason
	 * @Return EndPlayCount incremented; LastReason set to the reason
	 * @Param EndPlayReason the engine end-play reason
	 */
	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason EndPlayReason)
	{
		EndPlayCount += 1;
		LastReason = int(EndPlayReason);
	}

	/**
	 * WorldStory: Destroyed increments DestroyedCount.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.BlueprintOverrideNativeActorEventParameterMatrix
	 * @Inputs none
	 * @Return DestroyedCount incremented
	 */
	UFUNCTION(BlueprintOverride)
	void Destroyed()
	{
		DestroyedCount += 1;
	}

	/**
	 * WorldStory: OnReset increments ResetCount.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.BlueprintOverrideNativeActorEventParameterMatrix
	 * @Inputs none
	 * @Return ResetCount incremented
	 */
	UFUNCTION(BlueprintOverride)
	void OnReset()
	{
		ResetCount += 1;
	}

	/**
	 * Read a const-ref transform into LastTransformScore as X+Y+Z.
	 *
	 * @Kind Action
	 * @Covers Inheritance.BlueprintOverrideNativeActorEventParameterMatrix
	 * @Inputs a const FTransform&in
	 * @Return LastTransformScore set to int(X+Y+Z)
	 * @Param Transform the transform whose location is scored
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|NativeEvents")
	void ReadTransformByConstRef(const FTransform&in Transform)
	{
		FVector Location = Transform.GetLocation();
		LastTransformScore = int(Location.X + Location.Y + Location.Z);
	}

	/**
	 * Observe that a locally constructed actor has not been notified.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.BlueprintOverrideNativeActorEventParameterMatrix
	 * @Inputs an actor that has not been notified
	 * @Return the sum of destroy/endplay/reset/score counters, expected to be 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	int CountersBeforeNotify()
	{
		return DestroyedCount + EndPlayCount + ResetCount + LastTransformScore;
	}

	/**
	 * Observe a self BeginOverlap writing LastReason 11.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.BlueprintOverrideNativeActorEventParameterMatrix
	 * @Inputs ActorBeginOverlap(this)
	 * @Return LastReason, expected to be 11
	 */
	UFUNCTION()
	int SelfBeginOverlapReason()
	{
		ActorBeginOverlap(this);
		return LastReason;
	}

	/**
	 * Observe a self EndOverlap writing LastReason 22.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.BlueprintOverrideNativeActorEventParameterMatrix
	 * @Inputs ActorEndOverlap(this)
	 * @Return LastReason, expected to be 22
	 */
	UFUNCTION()
	int SelfEndOverlapReason()
	{
		ActorEndOverlap(this);
		return LastReason;
	}

	/**
	 * Observe OnReset incrementing ResetCount.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.BlueprintOverrideNativeActorEventParameterMatrix
	 * @Inputs OnReset()
	 * @Return ResetCount, expected to be 1
	 */
	UFUNCTION()
	int OnResetCount()
	{
		OnReset();
		return ResetCount;
	}

	/**
	 * Observe ReadTransformByConstRef writing LastTransformScore.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.BlueprintOverrideNativeActorEventParameterMatrix
	 * @Inputs a transform whose location scores the sum
	 * @Return LastTransformScore
	 * @Param Transform the transform passed by const ref
	 */
	UFUNCTION()
	int ConstRefTransformScore(FTransform Transform)
	{
		ReadTransformByConstRef(Transform);
		return LastTransformScore;
	}

	/**
	 * Observe a zero transform scoring 0.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.BlueprintOverrideNativeActorEventParameterMatrix
	 * @Inputs a default FTransform
	 * @Return LastTransformScore, expected to be 0
	 * @Boundary zero transform
	 */
	UFUNCTION()
	int ZeroTransformScoreBoundary()
	{
		FTransform Transform;
		ReadTransformByConstRef(Transform);
		return LastTransformScore;
	}
}
