/**
 * Guarded map and array reads that fall back rather than proceeding on a miss. The CSV
 * NegativeDiagnostic label is a heuristic: C++ compiles this and executes each
 * entrypoint expecting its fallback or hit value, so this is a value oracle.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.GuardedNegativeBoundaries
 * @Harness Function
 * @Tag Gameplay.Debug.GuardedNegativeBoundariesPreserveFallbacks
 * @Namespace DebugTest
 * @Provenance Theme: Gameplay.Debug. Value oracle: guarded map/array fallbacks.
 * @Provenance C++: AngelscriptCoverageErrorHandlingTests.cpp::GuardedNegativeBoundariesPreserveFallbacks
 * @Provenance CSV NegativeDiagnostic; C++ compiles. GuardedMapMissingKey 77; GuardedMapHit 10;
 * @Provenance GuardedArrayInvalidIndex 31; GuardedArrayValidIndex 8.
 * @Provenance Extra: empty map keeps 77; empty array IsValidIndex false. DefaultSafe.
 */

namespace DebugTest
{
	/**
	 * Observe that a missing map key leaves the caller's initial value untouched.
	 *
	 * @Kind Observe
	 * @Covers Debug.GuardedNegativeBoundaries
	 * @Inputs a map holding Alpha and a lookup for Missing
	 * @Return 77, the value the caller supplied before the lookup
	 * @Boundary missing key
	 */
	UFUNCTION()
	int GuardedMapMissingKey()
	{
		TMap<FName, int> Values;
		Values.Add(FName("Alpha"), 10);

		int FoundValue = 77;
		if (Values.Find(FName("Missing"), FoundValue))
		{
			return FoundValue;
		}

		return FoundValue;
	}

	/**
	 * Observe that a present map key overwrites the caller's initial value.
	 *
	 * @Kind Observe
	 * @Covers Debug.GuardedNegativeBoundaries
	 * @Inputs a map holding Alpha and a lookup for Alpha
	 * @Return 10, or -1 when the lookup reported a miss
	 */
	UFUNCTION()
	int GuardedMapHit()
	{
		TMap<FName, int> Values;
		Values.Add(FName("Alpha"), 10);

		int FoundValue = 77;
		if (!Values.Find(FName("Alpha"), FoundValue))
		{
			return -1;
		}

		return FoundValue;
	}

	/**
	 * Observe that a negative index is rejected before it can be used.
	 *
	 * @Kind Observe
	 * @Covers Debug.GuardedNegativeBoundaries
	 * @Inputs an array and index -1
	 * @Return 31 when the index was refused
	 * @Boundary negative index
	 */
	UFUNCTION()
	int GuardedArrayInvalidIndex()
	{
		TArray<int> Values;
		Values.Add(4);
		Values.Add(8);

		if (!Values.IsValidIndex(-1))
		{
			return 31;
		}

		return Values[-1];
	}

	/**
	 * Observe that a valid index reads through.
	 *
	 * @Kind Observe
	 * @Covers Debug.GuardedNegativeBoundaries
	 * @Inputs an array and index 1
	 * @Return the element at index 1, or -1 when the index was refused
	 */
	UFUNCTION()
	int GuardedArrayValidIndex()
	{
		TArray<int> Values;
		Values.Add(4);
		Values.Add(8);

		if (!Values.IsValidIndex(1))
		{
			return -1;
		}

		return Values[1];
	}

	/**
	 * Observe that the missing-key guard reports its fallback value.
	 *
	 * @Kind Observe
	 * @Covers Debug.GuardedNegativeBoundaries
	 * @Inputs none
	 * @Return true when the entrypoint returned 77
	 */
	UFUNCTION()
	bool GuardedMapMissingKeyNominal()
	{
		return GuardedMapMissingKey() == 77;
	}

	/**
	 * Observe that the map hit reads the stored value.
	 *
	 * @Kind Observe
	 * @Covers Debug.GuardedNegativeBoundaries
	 * @Inputs none
	 * @Return true when the entrypoint returned 10
	 */
	UFUNCTION()
	bool GuardedMapHitNominal()
	{
		return GuardedMapHit() == 10;
	}

	/**
	 * Observe that the invalid-index guard reports its sentinel.
	 *
	 * @Kind Observe
	 * @Covers Debug.GuardedNegativeBoundaries
	 * @Inputs none
	 * @Return true when the entrypoint returned 31
	 */
	UFUNCTION()
	bool GuardedArrayInvalidIndexNominal()
	{
		return GuardedArrayInvalidIndex() == 31;
	}

	/**
	 * Observe that the valid-index read reports the element.
	 *
	 * @Kind Observe
	 * @Covers Debug.GuardedNegativeBoundaries
	 * @Inputs none
	 * @Return true when the entrypoint returned 8
	 */
	UFUNCTION()
	bool GuardedArrayValidIndexNominal()
	{
		return GuardedArrayValidIndex() == 8;
	}

	/**
	 * Observe that an empty map leaves the caller's initial value untouched.
	 *
	 * @Kind Observe
	 * @Covers Debug.GuardedNegativeBoundaries
	 * @Inputs an empty map
	 * @Return true when the value is still 77
	 * @Boundary empty map
	 */
	UFUNCTION()
	bool GuardedMapEmptyDefault()
	{
		TMap<FName, int> Values;
		int FoundValue = 77;
		if (Values.Find(n"Missing", FoundValue))
		{
			return FoundValue == 10;
		}
		return FoundValue == 77;
	}

	/**
	 * Observe that an empty array rejects every index.
	 *
	 * @Kind Observe
	 * @Covers Debug.GuardedNegativeBoundaries
	 * @Inputs an empty array
	 * @Return true when index 0 is reported invalid
	 * @Boundary empty array
	 */
	UFUNCTION()
	bool GuardedArrayEmptyDefault()
	{
		TArray<int> Values;
		return !Values.IsValidIndex(0);
	}
}
