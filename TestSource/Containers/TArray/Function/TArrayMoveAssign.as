/**
 * TArray.MoveAssignFrom transfers the source array's storage into the target
 * and leaves the source empty. It is the explicit counterpart of a move: the
 * target takes over the elements, and the source is spent rather than copied.
 * Moving an array into itself throws; that path lives in
 * ../Exception/TArrayMoveAssignSelf.
 * Observed locally, then through UFUNCTION in, out, and inout directions.
 *
 * @Theme Containers.TArray
 * @Subject TArray.MoveAssignFrom
 * @Harness Function
 * @Tag Containers.TArray.TArrayMoveAssign
 * @Namespace TArrayTest
 */

UCLASS()
class UTArrayMoveAssignObject : UObject
{
}

namespace TArrayTest
{
	/**
	 * Observe MoveAssignFrom: the target ends up holding the source's elements.
	 *
	 * @Kind Observe
	 * @Covers TArray.MoveAssignFrom
	 * @Inputs Target empty; Source [1,2,3]; Target.MoveAssignFrom(Source)
	 * @Return true when the target reads [1,2,3]
	 */
	UFUNCTION()
	bool MoveAssignTransfersElementsToTarget()
	{
		TArray<int> Target;

		TArray<int> Source;
		Source.Add(1);
		Source.Add(2);
		Source.Add(3);

		Target.MoveAssignFrom(Source);
		if (Target.Num() != 3)
		{
			return false;
		}
		if (Target[0] != 1)
		{
			return false;
		}
		if (Target[1] != 2)
		{
			return false;
		}
		return Target[2] == 3;
	}

	/**
	 * Observe that MoveAssignFrom empties the source: the storage moved, it
	 * was not shared.
	 *
	 * @Kind Observe
	 * @Covers TArray.MoveAssignFrom
	 * @Inputs Target empty; Source [1,2,3]; Target.MoveAssignFrom(Source)
	 * @Return true when the source is empty afterwards
	 * @Boundary move, not copy
	 */
	UFUNCTION()
	bool MoveAssignLeavesSourceEmpty()
	{
		TArray<int> Target;

		TArray<int> Source;
		Source.Add(1);
		Source.Add(2);
		Source.Add(3);

		Target.MoveAssignFrom(Source);
		if (Source.Num() != 0)
		{
			return false;
		}
		return Source.IsEmpty();
	}

	/**
	 * Observe that MoveAssignFrom replaces whatever the target held: prior
	 * contents are discarded, not appended to.
	 *
	 * @Kind Observe
	 * @Covers TArray.MoveAssignFrom
	 * @Inputs Target [9,9,9,9]; Source [1,2]; Target.MoveAssignFrom(Source)
	 * @Return true when the target reads [1,2] and not the old contents
	 */
	UFUNCTION()
	bool MoveAssignReplacesTargetContents()
	{
		TArray<int> Target;
		Target.Add(9);
		Target.Add(9);
		Target.Add(9);
		Target.Add(9);

		TArray<int> Source;
		Source.Add(1);
		Source.Add(2);

		Target.MoveAssignFrom(Source);
		if (Target.Num() != 2)
		{
			return false;
		}
		if (Target.Contains(9))
		{
			return false;
		}
		if (Target[0] != 1)
		{
			return false;
		}
		return Target[1] == 2;
	}

	/**
	 * Observe MoveAssignFrom from an empty source: the target ends up empty.
	 *
	 * @Kind Observe
	 * @Covers TArray.MoveAssignFrom
	 * @Inputs Target [1,2]; Source empty; Target.MoveAssignFrom(Source)
	 * @Return true when the target is empty afterwards
	 */
	UFUNCTION()
	bool MoveAssignFromEmptyClearsTarget()
	{
		TArray<int> Target;
		Target.Add(1);
		Target.Add(2);

		TArray<int> Source;

		Target.MoveAssignFrom(Source);
		if (Target.Num() != 0)
		{
			return false;
		}
		return Target.IsEmpty();
	}

	/**
	 * Observe that the target is usable after a move: adding to it works and
	 * does not disturb the moved-in elements.
	 *
	 * @Kind Observe
	 * @Covers TArray.MoveAssignFrom
	 * @Inputs Target empty; Source [1,2]; move; then Add(3)
	 * @Return true when the target reads [1,2,3]
	 */
	UFUNCTION()
	bool MovedIntoTargetStaysUsable()
	{
		TArray<int> Target;

		TArray<int> Source;
		Source.Add(1);
		Source.Add(2);

		Target.MoveAssignFrom(Source);
		Target.Add(3);
		if (Target.Num() != 3)
		{
			return false;
		}
		if (Target[0] != 1)
		{
			return false;
		}
		if (Target[1] != 2)
		{
			return false;
		}
		return Target[2] == 3;
	}

	/**
	 * In-only: read the moved-in contents from a const&in array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.MoveAssignFrom
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values holds [1,2,3]
	 * @Return true when Num is 3 and the elements read back in order
	 */
	UFUNCTION()
	bool ReadMovedContents(const TArray<int>&in Values)
	{
		if (Values.Num() != 3)
		{
			return false;
		}
		if (Values[0] != 1)
		{
			return false;
		}
		if (Values[1] != 2)
		{
			return false;
		}
		return Values[2] == 3;
	}

	/**
	 * Out-only: move a locally built array into an &out destination.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.MoveAssignFrom
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result holds [1,2,3]
	 */
	UFUNCTION()
	void FillByMoveAssign(TArray<int>&out Result)
	{
		TArray<int> Source;
		Source.Add(1);
		Source.Add(2);
		Source.Add(3);
		Result.MoveAssignFrom(Source);
	}

	/**
	 * Inout: move an array into an existing one, replacing its contents.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.MoveAssignFrom
	 * @Param Values Array received as TArray<int>&inout, holds [9,9,9,9]
	 * @Inputs Values.Num() is 4
	 * @Return void; Values holds [1,2]
	 */
	UFUNCTION()
	void ReplaceByMoveAssign(TArray<int>&inout Values)
	{
		TArray<int> Source;
		Source.Add(1);
		Source.Add(2);
		Values.MoveAssignFrom(Source);
	}


	/**
	 * Observe MoveAssignFrom for FString: elements transfer and the source empties.
	 *
	 * @Kind Observe
	 * @Covers TArray.MoveAssignFrom
	 * @Inputs Target empty; Source ["a","b"]; Target.MoveAssignFrom(Source)
	 * @Return true when the target reads ["a","b"] and the source is empty
	 */
	UFUNCTION()
	bool MoveAssignTransfersElementsAndEmptiesSource_FString()
	{
		TArray<FString> Target;

		TArray<FString> Source;
		Source.Add("a");
		Source.Add("b");

		Target.MoveAssignFrom(Source);
		if (Target.Num() != 2)
		{
			return false;
		}
		if (Target[0] != "a")
		{
			return false;
		}
		if (Target[1] != "b")
		{
			return false;
		}
		if (Source.Num() != 0)
		{
			return false;
		}
		return Source.IsEmpty();
	}

	/**
	 * In-only: read the moved-in contents from a const&in TArray<FString>.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.MoveAssignFrom
	 * @Param Values Source array received as const TArray<FString>&in
	 * @Inputs Values holds ["a","b"]
	 * @Return true when Num is 2 and the strings read back
	 */
	UFUNCTION()
	bool ReadMovedContents_FString(const TArray<FString>&in Values)
	{
		if (Values.Num() != 2)
		{
			return false;
		}
		if (Values[0] != "a")
		{
			return false;
		}
		return Values[1] == "b";
	}

	/**
	 * Out-only: move a locally built TArray<FString> into an &out destination.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.MoveAssignFrom
	 * @Param Result Destination received as TArray<FString>&out
	 * @Inputs Empty &out TArray<FString>
	 * @Return void; Result holds ["a","b"]
	 */
	UFUNCTION()
	void FillByMoveAssign_FString(TArray<FString>&out Result)
	{
		TArray<FString> Source;
		Source.Add("a");
		Source.Add("b");
		Result.MoveAssignFrom(Source);
	}

	/**
	 * Inout: move an array into an existing TArray<FString>.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.MoveAssignFrom
	 * @Param Values Array received as TArray<FString>&inout, holds ["z","z","z"]
	 * @Inputs Values.Num() is 3
	 * @Return void; Values holds ["a","b"]
	 */
	UFUNCTION()
	void ReplaceByMoveAssign_FString(TArray<FString>&inout Values)
	{
		TArray<FString> Source;
		Source.Add("a");
		Source.Add("b");
		Values.MoveAssignFrom(Source);
	}
}
