/**
 * @version v1
 * @summary A UPROPERTY float compiles. The observers cover Speed 5.0f, an empty 0.0 write, and copy independence of a local snapshot.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UPROPERTY float compiles. The observers cover Speed 5.0f, an empty 0.0 write, and copy independence of a local snapshot.
 * @topic Baseline
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
/** @end */
