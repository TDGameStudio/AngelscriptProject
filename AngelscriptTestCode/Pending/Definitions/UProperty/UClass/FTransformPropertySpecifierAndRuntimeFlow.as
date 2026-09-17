/**
 * @version v1
 * @summary EditAnywhere FTransform plus runtime array/map/plain-member snapshot. C++ verifies named properties by path, so those UPROPERTY names are kept. The observers cover empty array Num 0 and that Identity is independent of.
 * @topic Definitions
 */
/**
 * @version root
 * @summary EditAnywhere FTransform plus runtime array/map/plain-member snapshot. C++ verifies named properties by path, so those UPROPERTY names are kept. The observers cover empty array Num 0 and that Identity is independent of.
 * @topic Baseline
 */
UCLASS()
class ACoverageFTransformRuntimeFlowActor : AActor
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Coverage|Transform", meta = (DisplayName = "Editable Transform"))
	FTransform EditableTransform;

	UPROPERTY()
	TArray<FTransform> ReflectedTransforms;

	UPROPERTY()
	TMap<int, FTransform> ReflectedTransformMap;

	UPROPERTY()
	FTransform PlainMemberSnapshot;

	UPROPERTY()
	FVector RotatedForward;

	UPROPERTY()
	bool bPlainMemberMatchesSnapshot = false;

	FTransform PlainMember;

	/**
	 * WorldStory: snapshot the 90-yaw transform into reflected containers and the plain member.
	 *
	 * @Kind WorldStory
	 * @Covers UProperty.FTransformPropertySpecifierAndRuntimeFlow
	 * @Inputs none
	 * @Return reflected arrays/maps filled; bPlainMemberMatchesSnapshot true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		EditableTransform = FTransform(FRotator(0, 90, 0), FVector(10, 20, 30), FVector(2, 3, 4));
		PlainMember = FTransform(FRotator(0, 90, 0), FVector(3, 4, 5), FVector(1, 1, 1));
		PlainMemberSnapshot = PlainMember;
		RotatedForward = PlainMember.TransformVector(FVector::ForwardVector);

		ReflectedTransforms.Add(EditableTransform);
		ReflectedTransforms.Add(PlainMember);

		ReflectedTransformMap.Add(9, EditableTransform);
		ReflectedTransformMap.Add(11, PlainMember);

		bPlainMemberMatchesSnapshot = PlainMemberSnapshot.Equals(PlainMember, 0.001);
	}

	/**
	 * Observe that an empty transform array has Num 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.FTransformPropertySpecifierAndRuntimeFlow
	 * @Inputs a default-constructed TArray<FTransform>
	 * @Return 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	int FTransformEmptyArrayNum()
	{
		TArray<FTransform> ReflectedTransforms;
		return ReflectedTransforms.Num();
	}

	/**
	 * Observe that Identity is independent of the 90-yaw snapshot.
	 *
	 * @Kind Observe
	 * @Covers UProperty.FTransformPropertySpecifierAndRuntimeFlow
	 * @Inputs Identity and a 90-yaw transform
	 * @Return true when they are not equal
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool FTransformIdentityIndependentOfYaw()
	{
		FTransform Identity;
		FTransform Yaw = FTransform(FRotator(0, 90, 0), FVector(10, 20, 30), FVector(2, 3, 4));
		return !Identity.Equals(Yaw, 0.001);
	}
}
/** @end */
