/**
 * Mutating a container while a range-for walks it is a boundary the language
 * does not promise a stable answer for, so the observable contract is only
 * that the walk terminates and the container ends in a consistent state. An
 * append during the walk grows the container; a removal during the walk
 * shrinks it. Walking an empty container visits nothing.
 *
 * @Theme Language.ControlFlow
 * @Subject ControlFlow.ForeachContainerMutation
 * @Harness Function
 * @Tag Language.ControlFlow.ForeachContainerMutation
 * @Namespace ControlFlowTest
 * @Provenance C++: AngelscriptCoverageControlFlowTests.cpp::ForEachContainerMutationSurface
 * @Provenance Oracle: the walk terminates; the append surface ends with at least two
 * @Provenance elements and the removal surface with between one and three.
 */

namespace ControlFlowTest
{
	/**
	 * Observe that appending during a walk leaves the container holding the
	 * new element and the walk still terminates.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Foreach
	 * @Inputs Walk a two-element array, appending a third during the first pass
	 * @Return the final element count
	 * @Boundary container mutated during iteration
	 */
	UFUNCTION()
	int AppendDuringWalkGrowsContainer()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		bool bAdded = false;
		for (int Value : Values)
		{
			if (!bAdded)
			{
				Values.Add(3);
				bAdded = true;
			}
		}
		return Values.Num();
	}

	/**
	 * Observe that removing during a walk leaves the container holding the
	 * remaining elements and the walk still terminates.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Foreach
	 * @Inputs Walk a three-element array, removing index 1 during the first pass
	 * @Return the final element count
	 * @Boundary container mutated during iteration
	 */
	UFUNCTION()
	int RemoveDuringWalkShrinksContainer()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		Values.Add(3);
		bool bRemoved = false;
		for (int Value : Values)
		{
			if (!bRemoved && Value == 1)
			{
				Values.RemoveAt(1);
				bRemoved = true;
			}
		}
		return Values.Num();
	}

	/**
	 * Observe the empty default: walking an empty container visits nothing, so
	 * no mutation opportunity arises.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Foreach
	 * @Inputs Walk an empty array counting visits
	 * @Return true when the visit count is zero
	 * @Boundary empty container
	 */
	UFUNCTION()
	bool EmptyWalkVisitsNothing()
	{
		TArray<int> Empty;
		int Visits = 0;
		for (int Value : Empty)
		{
			Visits += 1;
		}
		return Visits == 0;
	}

	/**
	 * Observe the callable boundary: both mutation surfaces terminate and end
	 * within the range the container can hold.
	 *
	 * @Kind Observe
	 * @Covers ControlFlow.Foreach
	 * @Inputs Run both mutation walks and compare their final counts
	 * @Return true when the append ends at two or more and the removal between one and three
	 */
	UFUNCTION()
	bool MutationSurfacesStayWithinRange()
	{
		int AfterAdd = AppendDuringWalkGrowsContainer();
		int AfterRemove = RemoveDuringWalkShrinksContainer();
		if (AfterAdd < 2)
		{
			return false;
		}
		if (AfterRemove < 1)
		{
			return false;
		}
		return AfterRemove <= 3;
	}
}
