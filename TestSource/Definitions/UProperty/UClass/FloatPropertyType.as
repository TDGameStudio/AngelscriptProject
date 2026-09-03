/**
 * A UPROPERTY float compiles. The observers cover Speed 5.0f, an empty 0.0
 * write, and copy independence of a local snapshot.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.FloatPropertyType
 * @Harness UClass
 * @Tag Definitions.UProperty.FloatPropertyType
 * @Provenance Theme: Definitions.UProperty. WorldStory: UPROPERTY float.
 * @Provenance C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Positive AssertCompiles
 * @Provenance UPropTP_Float; lines 387-393;
 * @Provenance sha256=ef123a72e8c7af5e5565aa3f4ef657e6de386196cd35dce732ef82f0d2fa27d2.
 * @Provenance Oracle: Speed default is 5.0f on the spawned actor.
 * @Provenance Extra: 0.0f empty/default write; copy-independence of a local snapshot.
 * @Provenance FixtureIsolated.
 */

class AUPropFloatActor : AActor
{
	UPROPERTY()
	float Speed = 5.0f;

	/**
	 * Observe the default Speed of 5.0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.FloatPropertyType
	 * @Inputs none
	 * @Return true when Speed is 5.0
	 */
	UFUNCTION()
	bool SpeedDefault()
	{
		return Speed == 5.0f;
	}

	/**
	 * Observe an empty 0.0 write that restores 5.0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.FloatPropertyType
	 * @Inputs Speed written to 0.0 then restored
	 * @Return true when the empty write lands and the saved default is 5.0
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool SpeedEmptyWrite()
	{
		float Saved = Speed;
		Speed = 0.0f;
		bool bEmpty = Speed == 0.0f;
		Speed = Saved;
		if (!bEmpty)
		{
			return false;
		}
		return Saved == 5.0f;
	}

	/**
	 * Observe that mutating a local copy leaves Speed at 5.0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.FloatPropertyType
	 * @Inputs a local copy written to 99.0
	 * @Return true when Speed stays 5.0 and the copy is 99.0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool SpeedCopyIndependence()
	{
		float Original = Speed;
		float Copy = Original;
		Copy = 99.0f;
		if (Speed != Original)
		{
			return false;
		}
		if (Copy != 99.0f)
		{
			return false;
		}
		return Original == 5.0f;
	}
}
