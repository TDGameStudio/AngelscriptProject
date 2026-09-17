/**
 * @version v1
 * @summary Combined EditAnywhere, BlueprintReadWrite, Category compiles. The observers cover Damage 10.0f, an empty 0.0f write, and copy independence of a local snapshot.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Combined EditAnywhere, BlueprintReadWrite, Category compiles. The observers cover Damage 10.0f, an empty 0.0f write, and copy independence of a local snapshot.
 * @topic Baseline
 */
class AUPropMultiActor : AActor
{
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Combat")
	float Damage = 10.0f;

	/**
	 * Observe the default Damage of 10.0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.MultipleSpecifiers
	 * @Inputs none
	 * @Return true when Damage is 10.0
	 */
	UFUNCTION()
	bool DamageDefault()
	{
		return Damage == 10.0f;
	}

	/**
	 * Observe an empty 0.0 write that restores 10.0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.MultipleSpecifiers
	 * @Inputs Damage written to 0.0 then restored
	 * @Return true when the empty write lands and the saved default is 10.0
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool DamageEmptyWrite()
	{
		float Saved = Damage;
		Damage = 0.0f;
		bool bEmpty = Damage == 0.0f;
		Damage = Saved;
		if (!bEmpty)
		{
			return false;
		}
		return Saved == 10.0f;
	}

	/**
	 * Observe that mutating a local copy leaves Damage at 10.0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.MultipleSpecifiers
	 * @Inputs a local copy written to 99.0
	 * @Return true when Damage stays 10.0 and the copy is 99.0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool DamageCopyIndependence()
	{
		float Original = Damage;
		float Copy = Original;
		Copy = 99.0f;
		if (Damage != Original)
		{
			return false;
		}
		if (Copy != 99.0f)
		{
			return false;
		}
		return Original == 10.0f;
	}
}
/** @end */
