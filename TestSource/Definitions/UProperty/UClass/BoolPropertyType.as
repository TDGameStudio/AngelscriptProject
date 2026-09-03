/**
 * A UPROPERTY bool compiles. The observers cover bIsAlive true, a false write,
 * and copy independence of a local snapshot.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.BoolPropertyType
 * @Harness UClass
 * @Tag Definitions.UProperty.BoolPropertyType
 * @Provenance Theme: Definitions.UProperty. WorldStory: UPROPERTY bool.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Positive AssertCompiles
 * @Provenance UPropTP_Bool; lines 398-404;
 * @Provenance sha256=157d730bfd248fb15145483a59a5c872711ce23cd9997c4da7300c0c15d1e60a.
 * @Provenance Oracle: bIsAlive default is true on the spawned actor.
 * @Provenance Extra: false empty/default write; copy-independence of a local snapshot.
 * @Provenance FixtureIsolated.
 */

class AUPropBoolActor : AActor
{
	UPROPERTY()
	bool bIsAlive = true;

	/**
	 * Observe the default bIsAlive of true.
	 *
	 * @Kind Observe
	 * @Covers UProperty.BoolPropertyType
	 * @Inputs none
	 * @Return true when bIsAlive is true
	 */
	UFUNCTION()
	bool IsAliveDefault()
	{
		return bIsAlive == true;
	}

	/**
	 * Observe a false write that restores true.
	 *
	 * @Kind Observe
	 * @Covers UProperty.BoolPropertyType
	 * @Inputs bIsAlive written to false then restored
	 * @Return true when the false write lands and the saved default is true
	 * @Boundary false write
	 */
	UFUNCTION()
	bool IsAliveFalseBoundary()
	{
		bool Saved = bIsAlive;
		bIsAlive = false;
		bool bCleared = bIsAlive == false;
		bIsAlive = Saved;
		if (!bCleared)
		{
			return false;
		}
		return Saved == true;
	}

	/**
	 * Observe that mutating a local copy leaves bIsAlive true.
	 *
	 * @Kind Observe
	 * @Covers UProperty.BoolPropertyType
	 * @Inputs a local copy written to false
	 * @Return true when bIsAlive stays true and the copy is false
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool IsAliveCopyIndependence()
	{
		bool Original = bIsAlive;
		bool Copy = Original;
		Copy = false;
		if (bIsAlive != Original)
		{
			return false;
		}
		if (Copy != false)
		{
			return false;
		}
		return Original == true;
	}
}
