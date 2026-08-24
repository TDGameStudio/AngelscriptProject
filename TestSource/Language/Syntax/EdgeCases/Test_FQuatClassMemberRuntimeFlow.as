// Theme: Language.Syntax.EdgeCases. WorldStory class-member FQuat copy/assign/inverse/rotate.
// C++: AngelscriptCoverageFQuatPropertyTests.cpp::FQuatClassMemberRuntimeFlow
// sha256=7d8596d884fdc6275d7434af861183641ba8e76a78a4c46096a94e6e8d14b44b; lines 332-385.
// Oracle after BeginPlay: CurrentQuat equals UpVector * half-pi; AssignedQuat equals Current;
// RotatedForward equals RightVector; History.Num=3; bool flags true.
// Extra: local construct Identity current, empty History, flags false. FixtureIsolated.

UCLASS()
class ACoverageFQuatRuntimeFlowActor : AActor
{
	UPROPERTY()
	FQuat CurrentQuat = FQuat::Identity;

	UPROPERTY()
	FQuat CopyConstructedQuat;

	UPROPERTY()
	FQuat AssignedQuat;

	UPROPERTY()
	FQuat InverseQuat;

	UPROPERTY()
	FVector RotatedForward;

	UPROPERTY()
	TArray<FQuat> History;

	UPROPERTY()
	bool bCopyEqualsAssigned = false;

	UPROPERTY()
	bool bInverseComposesToIdentity = false;

	UPROPERTY()
	bool bHistoryPreservesValues = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		const FQuat LocalTurn = FQuat(FVector::UpVector, 1.5707963267948966);
		CurrentQuat = LocalTurn;
		CopyConstructedQuat = FQuat(CurrentQuat);
		AssignedQuat = FQuat::Identity;
		AssignedQuat = CopyConstructedQuat;
		InverseQuat = CurrentQuat.Inverse();
		RotatedForward = CurrentQuat.RotateVector(FVector::ForwardVector);

		History.Add(FQuat::Identity);
		History.Add(CurrentQuat);
		History.Add(InverseQuat);

		bCopyEqualsAssigned = CopyConstructedQuat == AssignedQuat;
		bInverseComposesToIdentity = (CurrentQuat * InverseQuat).IsIdentity(0.001);
		bHistoryPreservesValues = History.Num() == 3
			&& History[1].Equals(CurrentQuat, 0.001)
			&& History[2].Equals(InverseQuat, 0.001);
	}
}

bool Observe_FQuatRuntimeFlow_DefaultEmpty(ACoverageFQuatRuntimeFlowActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FQuatClassMemberRuntimeFlow setup: required Actor is null");
	}
	return Actor.CurrentQuat.IsIdentity(0.001) && Actor.History.Num() == 0 && !Actor.bCopyEqualsAssigned && !Actor.bInverseComposesToIdentity && !Actor.bHistoryPreservesValues;
}

bool Observe_FQuatRuntimeFlow_CopyIndependenceHint(ACoverageFQuatRuntimeFlowActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FQuatClassMemberRuntimeFlow setup: required Actor is null");
	}
	FQuat LocalTurn = FQuat(FVector::UpVector, 1.5707963267948966);
	Actor.CurrentQuat = LocalTurn;
	Actor.CopyConstructedQuat = FQuat(Actor.CurrentQuat);
	Actor.AssignedQuat = Actor.CopyConstructedQuat;
	return Actor.CopyConstructedQuat.Equals(Actor.AssignedQuat, 0.001) && Actor.CurrentQuat.Equals(LocalTurn, 0.001);
}
