// Theme: Language.Syntax.EdgeCases. WorldStory advanced container iterators.
// C++: AngelscriptCoverageContainerAdvancedTests.cpp::ContainerIteratorAdvancedOperations
// sha256=d8510b716ad4e12f48fafa78d43b3e30a423929d7b120f88551929bf2bc9ec74; lines 439-629.
// Oracle after Exercise*: ArrayCopyAssignSum=30, ArrayMutableWriteSum=19,
// MapCopyAssignKeySum=18, MapCopyAssignValueSum=180, MapMutationVisitedCount=4,
// MapMutationRemainingCount=2, MapMutationUpdatedValueSum=240,
// MapMutationRemovedKeyCount=0, SetCopyAssignSum=42, SetCopyAssignVisitCount=9.
// Extra: local construct leaves all sums 0. FixtureIsolated.

UCLASS()
class ACoverageContainerIteratorAdvancedActor : AActor
{
	UPROPERTY()
	int ArrayCopyAssignSum = 0;

	UPROPERTY()
	int ArrayMutableWriteSum = 0;

	UPROPERTY()
	int MapCopyAssignKeySum = 0;

	UPROPERTY()
	int MapCopyAssignValueSum = 0;

	UPROPERTY()
	int MapMutationVisitedCount = 0;

	UPROPERTY()
	int MapMutationRemainingCount = 0;

	UPROPERTY()
	int MapMutationUpdatedValueSum = 0;

	UPROPERTY()
	int MapMutationRemovedKeyCount = 0;

	UPROPERTY()
	int SetCopyAssignSum = 0;

	UPROPERTY()
	int SetCopyAssignVisitCount = 0;

	void ExerciseArrayIterator()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		Values.Add(3);
		Values.Add(4);

		TArrayIterator<int> Original = Values.Iterator();
		TArrayIterator<int> Copied = Original;
		TArrayIterator<int> Assigned = Values.Iterator();
		Assigned = Copied;

		while (Original.CanProceed)
		{
			ArrayCopyAssignSum += Original.Proceed();
		}

		while (Copied.CanProceed)
		{
			ArrayCopyAssignSum += Copied.Proceed();
		}

		while (Assigned.CanProceed)
		{
			ArrayCopyAssignSum += Assigned.Proceed();
		}

		TArrayIterator<int> Mutating = Values.Iterator();
		if (Mutating.CanProceed)
		{
			Mutating.Proceed() = 10;
		}

		ArrayMutableWriteSum = Values[0] + Values[1] + Values[2] + Values[3];
	}

	void ExerciseMapIterator()
	{
		TMap<int, int> Values;
		Values.Add(1, 10);
		Values.Add(2, 20);
		Values.Add(3, 30);

		TMapIterator<int, int> Original = Values.Iterator();
		TMapIterator<int, int> Copied = Original;
		TMapIterator<int, int> Assigned = Values.Iterator();
		Assigned = Copied;

		while (Original.CanProceed)
		{
			Original.Proceed();
			MapCopyAssignKeySum += Original.GetKey();
			MapCopyAssignValueSum += Original.GetValue();
		}

		while (Copied.CanProceed)
		{
			Copied.Proceed();
			MapCopyAssignKeySum += Copied.GetKey();
			MapCopyAssignValueSum += Copied.GetValue();
		}

		while (Assigned.CanProceed)
		{
			Assigned.Proceed();
			MapCopyAssignKeySum += Assigned.GetKey();
			MapCopyAssignValueSum += Assigned.GetValue();
		}

		TMap<int, int> MutableValues;
		MutableValues.Add(1, 10);
		MutableValues.Add(2, 20);
		MutableValues.Add(3, 30);
		MutableValues.Add(4, 40);

		TMapIterator<int, int> Mutating = MutableValues.Iterator();
		while (Mutating.CanProceed)
		{
			Mutating.Proceed();
			MapMutationVisitedCount++;

			if (Mutating.GetKey() == 2 || Mutating.GetKey() == 4)
			{
				Mutating.RemoveCurrent();
			}
			else
			{
				int NewValue = Mutating.GetValue() + 100;
				Mutating.SetValue(NewValue);
			}
		}

		MapMutationRemainingCount = MutableValues.Num();

		int FoundValue = 0;
		if (MutableValues.Find(1, FoundValue))
		{
			MapMutationUpdatedValueSum += FoundValue;
		}

		if (MutableValues.Find(3, FoundValue))
		{
			MapMutationUpdatedValueSum += FoundValue;
		}

		if (MutableValues.Contains(2))
		{
			MapMutationRemovedKeyCount++;
		}

		if (MutableValues.Contains(4))
		{
			MapMutationRemovedKeyCount++;
		}
	}

	void ExerciseSetIterator()
	{
		TSet<int> Values;
		Values.Add(2);
		Values.Add(4);
		Values.Add(8);

		TSetIterator<int> Original = Values.Iterator();
		TSetIterator<int> Copied = Original;
		TSetIterator<int> Assigned = Values.Iterator();
		Assigned = Copied;

		while (Original.CanProceed)
		{
			SetCopyAssignSum += Original.Proceed();
			SetCopyAssignVisitCount++;
		}

		while (Copied.CanProceed)
		{
			SetCopyAssignSum += Copied.Proceed();
			SetCopyAssignVisitCount++;
		}

		while (Assigned.CanProceed)
		{
			SetCopyAssignSum += Assigned.Proceed();
			SetCopyAssignVisitCount++;
		}
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ExerciseArrayIterator();
		ExerciseMapIterator();
		ExerciseSetIterator();
	}
}

bool Observe_IteratorAdvanced_DefaultEmpty(ACoverageContainerIteratorAdvancedActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ContainerIteratorAdvancedOperations setup: required Actor is null");
	}
	return Actor.ArrayCopyAssignSum == 0
		&& Actor.ArrayMutableWriteSum == 0
		&& Actor.MapCopyAssignKeySum == 0
		&& Actor.MapCopyAssignValueSum == 0
		&& Actor.MapMutationVisitedCount == 0
		&& Actor.MapMutationRemainingCount == 0
		&& Actor.MapMutationUpdatedValueSum == 0
		&& Actor.MapMutationRemovedKeyCount == 0
		&& Actor.SetCopyAssignSum == 0
		&& Actor.SetCopyAssignVisitCount == 0;
}

bool Observe_IteratorAdvanced_Nominal(ACoverageContainerIteratorAdvancedActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ContainerIteratorAdvancedOperations setup: required Actor is null");
	}
	Actor.ExerciseArrayIterator();
	Actor.ExerciseMapIterator();
	Actor.ExerciseSetIterator();
	return Actor.ArrayCopyAssignSum == 30
		&& Actor.ArrayMutableWriteSum == 19
		&& Actor.MapCopyAssignKeySum == 18
		&& Actor.MapCopyAssignValueSum == 180
		&& Actor.MapMutationVisitedCount == 4
		&& Actor.MapMutationRemainingCount == 2
		&& Actor.MapMutationUpdatedValueSum == 240
		&& Actor.MapMutationRemovedKeyCount == 0
		&& Actor.SetCopyAssignSum == 42
		&& Actor.SetCopyAssignVisitCount == 9;
}
