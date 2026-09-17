/**
 * @version v1
 * @summary Six runtime exception oracles. The module compiles; what C++ asserts is that each entrypoint raises a specific script exception at run time, so this is not a compile failure. No observer calls any of these entrypoints.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Six runtime exception oracles. The module compiles; what C++ asserts is that each entrypoint raises a specific script exception at run time, so this is not a compile failure. No observer calls any of these entrypoints.
 * @topic Baseline
 */
namespace DebugTest
{
	/**
	 * Write past the end of a one-element array. C++ expects "Array index out of bounds.";
	 * no observer calls this.
	 *
	 * @Kind Action
	 * @Covers Debug.NegativeRuntimeAndCompileBoundaries
	 * @Inputs none
	 * @Return nothing; throws before it can return
	 * @Boundary index past the end
	 */
	UFUNCTION()
	void TriggerArrayOutOfBounds()
	{
		TArray<int> Values;
		Values.Add(10);
		Values[1] = 20;
	}

	/**
	 * Read through an unassigned actor handle. C++ expects "Null pointer access"; no
	 * observer calls this.
	 *
	 * @Kind Action
	 * @Covers Debug.NegativeRuntimeAndCompileBoundaries
	 * @Inputs none
	 * @Return nothing reachable; throws before a value can be produced
	 * @Boundary null handle
	 */
	UFUNCTION()
	FVector TriggerNullObjectAccess()
	{
		AActor Actor;
		return Actor.GetActorLocation();
	}

	/**
	 * Divide by zero through the truncating integer helper. C++ expects "Division by
	 * zero"; no observer calls this.
	 *
	 * @Kind Action
	 * @Covers Debug.NegativeRuntimeAndCompileBoundaries
	 * @Inputs a numerator and a zero denominator
	 * @Return nothing; throws before it can return
	 * @Boundary zero denominator
	 */
	UFUNCTION()
	void TriggerDivideByZero()
	{
		int Numerator = 12;
		int Denominator = 0;
		int Result = Math::IntegerDivisionTrunc(Numerator, Denominator);
		ThrowIf(Result != 0, "CoverageUnexpectedDivideResult");
	}

	/**
	 * Insert past the end of an empty array. C++ expects "Need to insert between 0 and
	 * ArraySize"; no observer calls this.
	 *
	 * @Kind Action
	 * @Covers Debug.NegativeRuntimeAndCompileBoundaries
	 * @Inputs none
	 * @Return nothing; throws before it can return
	 * @Boundary insert index past the end
	 */
	UFUNCTION()
	void TriggerInsertOutOfBounds()
	{
		TArray<int> Values;
		Values.Insert(10, 1);
	}

	/**
	 * Resize an array to a negative length. C++ expects "Invalid negative Num"; no
	 * observer calls this.
	 *
	 * @Kind Action
	 * @Covers Debug.NegativeRuntimeAndCompileBoundaries
	 * @Inputs none
	 * @Return nothing; throws before it can return
	 * @Boundary negative length
	 */
	UFUNCTION()
	void TriggerNegativeArraySize()
	{
		TArray<int> Values;
		Values.SetNum(-1);
	}

	/**
	 * Move-assign an array into itself. C++ expects "Cannot move assign an array into
	 * itself"; no observer calls this.
	 *
	 * @Kind Action
	 * @Covers Debug.NegativeRuntimeAndCompileBoundaries
	 * @Inputs none
	 * @Return nothing; throws before it can return
	 * @Boundary self move-assign
	 */
	UFUNCTION()
	void TriggerMoveAssignSelf()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.MoveAssignFrom(Values);
	}
}
/** @end */
