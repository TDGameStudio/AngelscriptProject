// Theme: Gameplay.FVector. WorldStory local/const/raw/reflected member oracles.
// C++: AngelscriptCoverageFVectorPropertyTests.cpp::FVectorScriptMemberAndLocalUsage
// Oracle: ReadLocalAndConstVectors == 0; ReadRawAndReflectedMembers == 0;
// VerifyByPath ReflectedMember (7,8,9) after the write. Extra: default
// ReflectedMember is RightVector; RawMember default (4,5,6). FixtureIsolated.
// Keep UPROPERTY names.

const FVector GlobalForward = FVector::ForwardVector;

UCLASS()
class ACoverageFVectorScriptMemberActor : AActor
{
	FVector RawMember = FVector(4, 5, 6);

	UPROPERTY()
	FVector ReflectedMember = FVector::RightVector;

	UFUNCTION()
	int ReadLocalAndConstVectors()
	{
		FVector DefaultLocal;
		FVector CustomLocal = FVector(1, 2, 3);
		const FVector ConstLocal = FVector::UpVector;

		if (DefaultLocal != FVector::ZeroVector)
			return 1;
		if (CustomLocal != FVector(1, 2, 3))
			return 2;
		if (ConstLocal != FVector(0, 0, 1))
			return 3;
		if (GlobalForward != FVector(1, 0, 0))
			return 4;
		return 0;
	}

	UFUNCTION()
	int ReadRawAndReflectedMembers()
	{
		if (RawMember != FVector(4, 5, 6))
			return 10;
		if (ReflectedMember != FVector::RightVector)
			return 20;
		RawMember = RawMember + FVector(1, 1, 1);
		ReflectedMember = FVector(7, 8, 9);
		if (RawMember != FVector(5, 6, 7))
			return 30;
		if (ReflectedMember != FVector(7, 8, 9))
			return 40;
		return 0;
	}
}

bool Observe_ReadLocalAndConstVectors(ACoverageFVectorScriptMemberActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FVectorScriptMemberAndLocalUsage setup: required Actor is null");
	}
	return Actor.ReadLocalAndConstVectors() == 0;
}

bool Observe_ReadRawAndReflectedMembers(ACoverageFVectorScriptMemberActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FVectorScriptMemberAndLocalUsage setup: required Actor is null");
	}
	return Actor.ReadRawAndReflectedMembers() == 0
		&& Actor.ReflectedMember.X == 7.0
		&& Actor.ReflectedMember.Y == 8.0
		&& Actor.ReflectedMember.Z == 9.0;
}

bool Observe_ReflectedMember_DefaultEmptyRight(ACoverageFVectorScriptMemberActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FVectorScriptMemberAndLocalUsage setup: required Actor is null");
	}
	return Actor.ReflectedMember == FVector::RightVector
		&& Actor.RawMember == FVector(4, 5, 6);
}

bool Observe_ReadLocalAndConstVectors_CopyIndependence(ACoverageFVectorScriptMemberActor First, ACoverageFVectorScriptMemberActor Second)
{
	if (First is null)
	{
		throw("Test_FVectorScriptMemberAndLocalUsage setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_FVectorScriptMemberAndLocalUsage setup: required Second is null");
	}
	First.ReadRawAndReflectedMembers();
	return First.ReflectedMember == FVector(7, 8, 9)
		&& Second.ReflectedMember == FVector::RightVector;
}
