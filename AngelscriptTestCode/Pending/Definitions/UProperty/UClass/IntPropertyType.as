/**
 * @version v1
 * @summary A UPROPERTY int compiles. The observers cover Health 100, an empty 0 write, and copy independence of a local snapshot.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UPROPERTY int compiles. The observers cover Health 100, an empty 0 write, and copy independence of a local snapshot.
 * @topic Baseline
 */
class AUPropIntActor : AActor
{
	UPROPERTY()
	int Health = 100;

	/**
	 * Observe the default Health of 100.
	 *
	 * @Kind Observe
	 * @Covers UProperty.IntPropertyType
	 * @Inputs none
	 * @Return true when Health is 100
	 */
	UFUNCTION()
	bool HealthDefault()
	{
		return Health == 100;
	}

	/**
	 * Observe an empty 0 write that restores 100.
	 *
	 * @Kind Observe
	 * @Covers UProperty.IntPropertyType
	 * @Inputs Health written to 0 then restored
	 * @Return true when the empty write lands and the saved default is 100
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool HealthEmptyWrite()
	{
		int Saved = Health;
		Health = 0;
		bool bEmpty = Health == 0;
		Health = Saved;
		if (!bEmpty)
		{
			return false;
		}
		return Saved == 100;
	}

	/**
	 * Observe that mutating a local copy leaves Health at 100.
	 *
	 * @Kind Observe
	 * @Covers UProperty.IntPropertyType
	 * @Inputs a local copy written to -1
	 * @Return true when Health stays 100 and the copy is -1
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool HealthCopyIndependence()
	{
		int Original = Health;
		int Copy = Original;
		Copy = -1;
		if (Health != Original)
		{
			return false;
		}
		if (Copy != -1)
		{
			return false;
		}
		return Original == 100;
	}
}
/** @end */
