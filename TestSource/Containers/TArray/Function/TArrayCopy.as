/**
 * TArray.Copy copies a counted run of elements from a source index into a
 * target index. It overwrites in place and never changes Num, so the target
 * must already be long enough — growing is SetNum's job, not Copy's. Copying
 * an array into itself, a negative count, or an out-of-bounds source/target
 * range all throw; those paths live in ../Exception/, not here.
 * Observed locally, then through UFUNCTION in, out, and inout directions.
 *
 * @Theme Containers.TArray
 * @Subject TArray.Copy
 * @Harness Function
 * @Tag Containers.TArray.TArrayCopy
 * @Namespace TArrayTest
 */

UCLASS()
class UTArrayCopyObject : UObject
{
}

namespace TArrayTest
{
	/**
	 * Observe Copy: a counted run is written over the target slots.
	 *
	 * @Kind Observe
	 * @Covers TArray.Copy
	 * @Inputs Target [0,0,0,0]; Source [7,8,9]; Copy(Source, 0, 3, 1)
	 * @Return true when the target reads [0,7,8,9]
	 */
	UFUNCTION()
	bool CopyWritesRunIntoTargetSlots()
	{
		TArray<int> Target;
		Target.Add(0);
		Target.Add(0);
		Target.Add(0);
		Target.Add(0);

		TArray<int> Source;
		Source.Add(7);
		Source.Add(8);
		Source.Add(9);

		Target.Copy(Source, 0, 3, 1);
		if (Target.Num() != 4)
		{
			return false;
		}
		if (Target[0] != 0)
		{
			return false;
		}
		if (Target[1] != 7)
		{
			return false;
		}
		if (Target[2] != 8)
		{
			return false;
		}
		return Target[3] == 9;
	}

	/**
	 * Observe that Copy reads a sub-range: SourceIndex picks where in the
	 * source the run starts.
	 *
	 * @Kind Observe
	 * @Covers TArray.Copy
	 * @Inputs Target [0,0]; Source [5,6,7]; Copy(Source, 1, 2, 0)
	 * @Return true when the target reads [6,7]
	 */
	UFUNCTION()
	bool CopyReadsSubRangeFromSourceIndex()
	{
		TArray<int> Target;
		Target.Add(0);
		Target.Add(0);

		TArray<int> Source;
		Source.Add(5);
		Source.Add(6);
		Source.Add(7);

		Target.Copy(Source, 1, 2, 0);
		if (Target.Num() != 2)
		{
			return false;
		}
		if (Target[0] != 6)
		{
			return false;
		}
		return Target[1] == 7;
	}

	/**
	 * Observe that Copy leaves the source untouched: it is a read of Source,
	 * not a move.
	 *
	 * @Kind Observe
	 * @Covers TArray.Copy
	 * @Inputs Target [0,0]; Source [1,2]; Copy(Source, 0, 2, 0)
	 * @Return true when the source still holds [1,2]
	 */
	UFUNCTION()
	bool CopyLeavesSourceUnchanged()
	{
		TArray<int> Target;
		Target.Add(0);
		Target.Add(0);

		TArray<int> Source;
		Source.Add(1);
		Source.Add(2);

		Target.Copy(Source, 0, 2, 0);
		if (Source.Num() != 2)
		{
			return false;
		}
		if (Source[0] != 1)
		{
			return false;
		}
		return Source[1] == 2;
	}

	/**
	 * Observe that Copy never changes Num: it overwrites in place rather than
	 * appending or resizing.
	 *
	 * @Kind Observe
	 * @Covers TArray.Copy
	 * @Inputs Target [0,0,0]; Source [4,5]; Copy(Source, 0, 2, 0)
	 * @Return true when Num stays 3 after the copy
	 * @Boundary Copy overwrites, it does not grow
	 */
	UFUNCTION()
	bool CopyDoesNotChangeNum()
	{
		TArray<int> Target;
		Target.Add(0);
		Target.Add(0);
		Target.Add(0);

		TArray<int> Source;
		Source.Add(4);
		Source.Add(5);

		Target.Copy(Source, 0, 2, 0);
		if (Target.Num() != 3)
		{
			return false;
		}
		if (Target[0] != 4)
		{
			return false;
		}
		if (Target[1] != 5)
		{
			return false;
		}
		return Target[2] == 0;
	}

	/**
	 * Observe a zero-count Copy: it is a legal no-op.
	 *
	 * @Kind Observe
	 * @Covers TArray.Copy
	 * @Inputs Target [1,2]; Source [7,8]; Copy(Source, 0, 0, 0)
	 * @Return true when the target is unchanged
	 */
	UFUNCTION()
	bool CopyZeroCountIsNoOp()
	{
		TArray<int> Target;
		Target.Add(1);
		Target.Add(2);

		TArray<int> Source;
		Source.Add(7);
		Source.Add(8);

		Target.Copy(Source, 0, 0, 0);
		if (Target.Num() != 2)
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
	 * In-only: read the copied result from a const&in array.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Copy
	 * @Param Values Source array received as const TArray<int>&in
	 * @Inputs Values holds [0,7,8,9]
	 * @Return true when Num is 4 and the copied run reads back
	 */
	UFUNCTION()
	bool ReadCopiedRun(const TArray<int>&in Values)
	{
		if (Values.Num() != 4)
		{
			return false;
		}
		if (Values[0] != 0)
		{
			return false;
		}
		if (Values[1] != 7)
		{
			return false;
		}
		if (Values[2] != 8)
		{
			return false;
		}
		return Values[3] == 9;
	}

	/**
	 * Out-only: build an &out array and overwrite part of it with Copy.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Copy
	 * @Param Result Destination received as TArray<int>&out
	 * @Inputs Empty &out TArray<int>
	 * @Return void; Result reads [0,7,8,9]
	 */
	UFUNCTION()
	void FillAndCopyRun(TArray<int>&out Result)
	{
		Result.Add(0);
		Result.Add(0);
		Result.Add(0);
		Result.Add(0);

		TArray<int> Source;
		Source.Add(7);
		Source.Add(8);
		Source.Add(9);
		Result.Copy(Source, 0, 3, 1);
	}

	/**
	 * Inout: overwrite part of an existing array with Copy.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Copy
	 * @Param Values Array received as TArray<int>&inout, holds [0,0,0]
	 * @Inputs Values.Num() is 3
	 * @Return void; Values reads [4,5,0]
	 */
	UFUNCTION()
	void OverwriteRunInPlace(TArray<int>&inout Values)
	{
		TArray<int> Source;
		Source.Add(4);
		Source.Add(5);
		Values.Copy(Source, 0, 2, 0);
	}


	/**
	 * Observe Copy for FString: the run is written over the target slots.
	 *
	 * @Kind Observe
	 * @Covers TArray.Copy
	 * @Inputs Target ["-","-","-"]; Source ["x","y"]; Copy(Source, 0, 2, 1)
	 * @Return true when the target reads ["-","x","y"]
	 */
	UFUNCTION()
	bool CopyWritesRunIntoTargetSlots_FString()
	{
		TArray<FString> Target;
		Target.Add("-");
		Target.Add("-");
		Target.Add("-");

		TArray<FString> Source;
		Source.Add("x");
		Source.Add("y");

		Target.Copy(Source, 0, 2, 1);
		if (Target.Num() != 3)
		{
			return false;
		}
		if (Target[0] != "-")
		{
			return false;
		}
		if (Target[1] != "x")
		{
			return false;
		}
		return Target[2] == "y";
	}

	/**
	 * In-only: read the copied result from a const&in TArray<FString>.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Copy
	 * @Param Values Source array received as const TArray<FString>&in
	 * @Inputs Values holds ["-","x","y"]
	 * @Return true when Num is 3 and the copied run reads back
	 */
	UFUNCTION()
	bool ReadCopiedRun_FString(const TArray<FString>&in Values)
	{
		if (Values.Num() != 3)
		{
			return false;
		}
		if (Values[0] != "-")
		{
			return false;
		}
		if (Values[1] != "x")
		{
			return false;
		}
		return Values[2] == "y";
	}

	/**
	 * Out-only: build an &out TArray<FString> and overwrite part of it.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Copy
	 * @Param Result Destination received as TArray<FString>&out
	 * @Inputs Empty &out TArray<FString>
	 * @Return void; Result reads ["-","x","y"]
	 */
	UFUNCTION()
	void FillAndCopyRun_FString(TArray<FString>&out Result)
	{
		Result.Add("-");
		Result.Add("-");
		Result.Add("-");

		TArray<FString> Source;
		Source.Add("x");
		Source.Add("y");
		Result.Copy(Source, 0, 2, 1);
	}

	/**
	 * Inout: overwrite part of an existing TArray<FString>.
	 *
	 * @Kind RoundTrip
	 * @Covers TArray.Copy
	 * @Param Values Array received as TArray<FString>&inout, holds ["-","-","-"]
	 * @Inputs Values.Num() is 3
	 * @Return void; Values reads ["p","q","-"]
	 */
	UFUNCTION()
	void OverwriteRunInPlace_FString(TArray<FString>&inout Values)
	{
		TArray<FString> Source;
		Source.Add("p");
		Source.Add("q");
		Values.Copy(Source, 0, 2, 0);
	}
}
