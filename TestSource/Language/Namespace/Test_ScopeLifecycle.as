// Theme: Language.Namespace. WorldStory: local scope lifetime plus actor BeginPlay/EndPlay/Destroyed.
// C++: AngelscriptCoverageNamespaceTests.cpp::ScopeLifecycle ExpectGlobalReturn + ReadPropertyValue.
// sha256=f578b1086233d72c38633cd11da2de752ac643dbb9c8cde420b8ce440b8ad9c4; lines 657-726.
// Oracle: ScopeEntryConstructsLocals() == 123; BlockExitKeepsOuterState() == 456;
// LocalContainerDestroyedAfterFunction() == 6; BeginPlayCount == 1 after play.
// Extra: empty FVector (0,0,0) encodes to 0; actor counters default 0.
// FixtureIsolated. Keep UPROPERTY names BeginPlayCount, EndPlayCount, DestroyedCount.

int ScopeEntryConstructsLocals()
{
	FVector Local = FVector(1, 2, 3);
	TArray<int> Values;
	Values.Add(int(Local.X));
	Values.Add(int(Local.Y));
	Values.Add(int(Local.Z));
	return Values[0] * 100 + Values[1] * 10 + Values[2];
}

int BlockExitKeepsOuterState()
{
	int Result = 0;
	{
		TArray<int> Temp;
		Temp.Add(4);
		Temp.Add(5);
		Result = Temp[0] * 10 + Temp[1];
	}

	TArray<int> Temp;
	Temp.Add(6);
	return Result * 10 + Temp[0];
}

int LocalContainerDestroyedAfterFunction()
{
	int Total = 0;
	for (int Iteration = 0; Iteration < 3; ++Iteration)
	{
		TArray<int> Values;
		Values.Add(Iteration);
		Values.Add(Iteration + 1);
		Total += Values.Num();
	}
	return Total;
}

UCLASS()
class AScopeLifecycleActor : AActor
{
	UPROPERTY()
	int BeginPlayCount = 0;

	UPROPERTY()
	int EndPlayCount = 0;

	UPROPERTY()
	int DestroyedCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCount += 1;
	}

	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason Reason)
	{
		EndPlayCount += 1;
	}

	UFUNCTION(BlueprintOverride)
	void Destroyed()
	{
		DestroyedCount += 1;
	}
}

bool Observe_ScopeLifecycle_Nominal()
{
	return ScopeEntryConstructsLocals() == 123
		&& BlockExitKeepsOuterState() == 456
		&& LocalContainerDestroyedAfterFunction() == 6;
}

int Observe_ScopeEntry_ZeroVectorBoundary()
{
	FVector Local = FVector(0, 0, 0);
	return int(Local.X) + int(Local.Y) + int(Local.Z);
}
