// Theme: Definitions.UFunction. WorldStory: const &in, &out, and &inout reference directions.
// C++: AngelscriptCoverageUFunctionTests.cpp::ReferenceDirectionFlagAndRuntimeMatrix
// Oracle: ReadConstRefs(30,"Input",(7,8,9))==42 LastLabel Input; FillOutRefs writes 42/"OutLabel"/(4,5,6);
// MutateInoutRefs(10,"InLabel",(1,2,3)) returns 37, writes 15/"InLabel|Mutated"/(3,5,7), bInoutSawOriginal true.
// Extra: ReadConstRefs(0,"",Zero) == 0; default LastReadScore 0 and bInoutSawOriginal false.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageUFunctionReferenceDirectionActor : AActor
{
	UPROPERTY()
	int LastReadScore = 0;

	UPROPERTY()
	bool bInoutSawOriginal = false;

	UPROPERTY()
	FString LastLabel;

	UPROPERTY()
	FVector LastVector = FVector::ZeroVector;

	UFUNCTION(BlueprintCallable, Category="Coverage|References")
	int ReadConstRefs(const int&in Count, const FString&in Label, const FVector&in Location)
	{
		LastReadScore = Count + Label.Len() + int(Location.X);
		LastLabel = Label;
		LastVector = Location;
		return LastReadScore;
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|References")
	void FillOutRefs(int&out Count, FString&out Label, FVector&out Location)
	{
		Count = 42;
		Label = "OutLabel";
		Location = FVector(4.0, 5.0, 6.0);
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|References")
	int MutateInoutRefs(int&inout Count, FString&inout Label, FVector&inout Location)
	{
		bInoutSawOriginal = Count == 10 && Label == "InLabel" && Location.X == 1.0;
		Count += 5;
		Label += "|Mutated";
		Location += FVector(2.0, 3.0, 4.0);
		return Count + Label.Len() + int(Location.Z);
	}
}

int Observe_RefDir_ReadConstNominal(ACoverageUFunctionReferenceDirectionActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ReferenceDirectionFlagAndRuntimeMatrix setup: required Actor is null");
	}
	return Actor.ReadConstRefs(30, "Input", FVector(7.0, 8.0, 9.0));
}

bool Observe_RefDir_FillOutNominal(ACoverageUFunctionReferenceDirectionActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ReferenceDirectionFlagAndRuntimeMatrix setup: required Actor is null");
	}
	int Count = 0;
	FString Label;
	FVector Location = FVector::ZeroVector;
	Actor.FillOutRefs(Count, Label, Location);
	return Count == 42 && Label == "OutLabel" && Location.X == 4.0 && Location.Y == 5.0 && Location.Z == 6.0;
}

int Observe_RefDir_MutateInoutNominal(ACoverageUFunctionReferenceDirectionActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ReferenceDirectionFlagAndRuntimeMatrix setup: required Actor is null");
	}
	int Count = 10;
	FString Label = "InLabel";
	FVector Location = FVector(1.0, 2.0, 3.0);
	int Result = Actor.MutateInoutRefs(Count, Label, Location);
	if (!Actor.bInoutSawOriginal || Count != 15 || Label != "InLabel|Mutated")
	{
		return -1;
	}
	if (Location.X != 3.0 || Location.Y != 5.0 || Location.Z != 7.0)
	{
		return -2;
	}
	return Result;
}

int Observe_RefDir_ReadEmptyZero(ACoverageUFunctionReferenceDirectionActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ReferenceDirectionFlagAndRuntimeMatrix setup: required Actor is null");
	}
	return Actor.ReadConstRefs(0, "", FVector::ZeroVector);
}

int Observe_RefDir_DefaultScore(ACoverageUFunctionReferenceDirectionActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ReferenceDirectionFlagAndRuntimeMatrix setup: required Actor is null");
	}
	return Actor.LastReadScore;
}

bool Observe_RefDir_DefaultInoutFlag(ACoverageUFunctionReferenceDirectionActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ReferenceDirectionFlagAndRuntimeMatrix setup: required Actor is null");
	}
	return !Actor.bInoutSawOriginal;
}
