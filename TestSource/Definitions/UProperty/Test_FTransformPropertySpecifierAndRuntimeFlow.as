// Theme: Definitions.UProperty. WorldStory: EditAnywhere FTransform plus runtime array/map/plain-member snapshot.
// C++: EditableTransform CPF_Edit/BlueprintVisible/ReadOnly; Category Coverage|Transform; DisplayName Editable Transform.
// Extra: empty ReflectedTransforms Num 0; Identity transform is independent of the 90-yaw snapshot. FixtureIsolated.

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
}

int Observe_FTransform_EmptyArrayNum()
{
	TArray<FTransform> ReflectedTransforms;
	return ReflectedTransforms.Num();
}

bool Observe_FTransform_IdentityIndependentOfYaw()
{
	FTransform Identity;
	FTransform Yaw = FTransform(FRotator(0, 90, 0), FVector(10, 20, 30), FVector(2, 3, 4));
	return !Identity.Equals(Yaw, 0.001);
}
