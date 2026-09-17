/**
 * @version v1
 * @summary Meta ClampMin/ClampMax on Health compiles. The observers cover Health 50, the ClampMin 0 write, and the ClampMax 100 write.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Meta ClampMin/ClampMax on Health compiles. The observers cover Health 50, the ClampMin 0 write, and the ClampMax 100 write.
 * @topic Baseline
 */
class AUPropMetaActor : AActor
{
	UPROPERTY(Meta = (ClampMin = 0, ClampMax = 100))
	int Health = 50;

	/**
	 * Observe the default Health of 50.
	 *
	 * @Kind Observe
	 * @Covers UProperty.MetaClampMinMax
	 * @Inputs none
	 * @Return true when Health is 50
	 */
	UFUNCTION()
	bool HealthDefault()
	{
		return Health == 50;
	}

	/**
	 * Observe a ClampMin 0 write that restores 50.
	 *
	 * @Kind Observe
	 * @Covers UProperty.MetaClampMinMax
	 * @Inputs Health written to 0 then restored
	 * @Return true when the min write lands and the saved default is 50
	 * @Boundary ClampMin
	 */
	UFUNCTION()
	bool HealthClampMinEmpty()
	{
		int Saved = Health;
		Health = 0;
		bool bMin = Health == 0;
		Health = Saved;
		if (!bMin)
		{
			return false;
		}
		return Saved == 50;
	}

	/**
	 * Observe a ClampMax 100 write that restores 50.
	 *
	 * @Kind Observe
	 * @Covers UProperty.MetaClampMinMax
	 * @Inputs Health written to 100 then restored
	 * @Return true when the max write lands and the saved default is 50
	 * @Boundary ClampMax
	 */
	UFUNCTION()
	bool HealthClampMaxBoundary()
	{
		int Saved = Health;
		Health = 100;
		bool bMax = Health == 100;
		Health = Saved;
		if (!bMax)
		{
			return false;
		}
		return Saved == 50;
	}
}
/** @end */
