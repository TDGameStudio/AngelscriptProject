/**
 * @version v1
 * @summary Advanced container iterators: copying and assigning array, map and set iterators, writing through an array iterator, and mutating a map while iterating it by removing and updating entries.
 * @topic Language
 */
/**
 * @version root
 * @summary Advanced container iterators: copying and assigning array, map and set iterators, writing through an array iterator, and mutating a map while iterating it by removing and updating entries.
 * @topic Baseline
 */
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

	/**
	 * Copies and assigns an array iterator, then writes through one.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the array counters record the outcome
	 */
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

	/**
	 * Copies and assigns a map iterator, then mutates a map while iterating.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the map counters record the outcome
	 */
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

	/**
	 * Copies and assigns a set iterator.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the set counters record the outcome
	 */
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

	/**
	 * Runs all three iterator exercises.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; every counter is populated
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ExerciseArrayIterator();
		ExerciseMapIterator();
		ExerciseSetIterator();
	}

	/**
	 * Observe that a locally constructed actor leaves every counter at zero.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all ten counters are 0
	 * @Boundary default values
	 */
	UFUNCTION()
	bool IteratorCountersDefaultToZero()
	{
		if (ArrayCopyAssignSum != 0)
		{
			return false;
		}

		if (ArrayMutableWriteSum != 0)
		{
			return false;
		}

		if (MapCopyAssignKeySum != 0)
		{
			return false;
		}

		if (MapCopyAssignValueSum != 0)
		{
			return false;
		}

		if (MapMutationVisitedCount != 0)
		{
			return false;
		}

		if (MapMutationRemainingCount != 0)
		{
			return false;
		}

		if (MapMutationUpdatedValueSum != 0)
		{
			return false;
		}

		if (MapMutationRemovedKeyCount != 0)
		{
			return false;
		}

		if (SetCopyAssignSum != 0)
		{
			return false;
		}

		return SetCopyAssignVisitCount == 0;
	}

	/**
	 * Observe every counter after the three exercises run.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs all three exercises then all ten counters
	 * @Return true when every counter matches its expected value
	 */
	UFUNCTION()
	bool IteratorCountersMatchAfterExercises()
	{
		ExerciseArrayIterator();
		ExerciseMapIterator();
		ExerciseSetIterator();

		if (ArrayCopyAssignSum != 30)
		{
			return false;
		}

		if (ArrayMutableWriteSum != 19)
		{
			return false;
		}

		if (MapCopyAssignKeySum != 18)
		{
			return false;
		}

		if (MapCopyAssignValueSum != 180)
		{
			return false;
		}

		if (MapMutationVisitedCount != 4)
		{
			return false;
		}

		if (MapMutationRemainingCount != 2)
		{
			return false;
		}

		if (MapMutationUpdatedValueSum != 240)
		{
			return false;
		}

		if (MapMutationRemovedKeyCount != 0)
		{
			return false;
		}

		if (SetCopyAssignSum != 42)
		{
			return false;
		}

		return SetCopyAssignVisitCount == 9;
	}
}
/** @end */
