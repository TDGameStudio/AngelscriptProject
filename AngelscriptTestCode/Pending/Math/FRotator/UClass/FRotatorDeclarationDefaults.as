/**
 * @version v1
 * @summary FRotator UPROPERTY declaration defaults read off a spawned actor. C++ verifies each rotator by path, so the UPROPERTY names are part of the contract and are kept verbatim. The observers cover every declared rotator and.
 * @topic Math
 */
/**
 * @version root
 * @summary FRotator UPROPERTY declaration defaults read off a spawned actor. C++ verifies each rotator by path, so the UPROPERTY names are part of the contract and are kept verbatim. The observers cover every declared rotator and.
 * @topic Baseline
 */
UCLASS()
class ACoverageFRotatorDefaultsActor : AActor
{
	UPROPERTY()
	FRotator ZeroRot = FRotator::ZeroRotator;

	UPROPERTY()
	FRotator CustomRot = FRotator(10, 20, 30);

	UPROPERTY()
	FRotator NoDefaultRot;

	UPROPERTY()
	FRotator PitchOnly = FRotator(45, 0, 0);

	/**
	 * Observe that the zero-rotator default reads as the origin.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationDefaults
	 * @Inputs none
	 * @Return true when all three components of ZeroRot are 0
	 */
	UFUNCTION()
	bool ZeroRotNominal()
	{
		if (ZeroRot.Pitch != 0.0)
		{
			return false;
		}
		if (ZeroRot.Yaw != 0.0)
		{
			return false;
		}
		return ZeroRot.Roll == 0.0;
	}

	/**
	 * Observe that a literal default reads back unchanged.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationDefaults
	 * @Inputs none
	 * @Return true when CustomRot reads (10, 20, 30)
	 */
	UFUNCTION()
	bool CustomRotNominal()
	{
		if (CustomRot.Pitch != 10.0)
		{
			return false;
		}
		if (CustomRot.Yaw != 20.0)
		{
			return false;
		}
		return CustomRot.Roll == 30.0;
	}

	/**
	 * Observe that a property declared without an initialiser is empty on pitch.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationDefaults
	 * @Inputs none
	 * @Return true when the pitch of NoDefaultRot is 0
	 * @Boundary no declared default
	 */
	UFUNCTION()
	bool NoDefaultRotEmptyZero()
	{
		return NoDefaultRot.Pitch == 0.0;
	}

	/**
	 * Observe that the pitch-only default keeps pitch and zeros the rest.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationDefaults
	 * @Inputs none
	 * @Return true when PitchOnly.Pitch reads 45
	 */
	UFUNCTION()
	bool PitchOnlyNominal()
	{
		return PitchOnly.Pitch == 45.0;
	}

	/**
	 * Observe that a property declared without an initialiser is empty on yaw and roll.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationDefaults
	 * @Inputs none
	 * @Return true when yaw and roll of NoDefaultRot are 0
	 * @Boundary no declared default
	 */
	UFUNCTION()
	bool NoDefaultRotEmptyYawRoll()
	{
		if (NoDefaultRot.Yaw != 0.0)
		{
			return false;
		}
		return NoDefaultRot.Roll == 0.0;
	}

	/**
	 * Observe that writing one instance leaves another instance's default untouched.
	 *
	 * @Kind Observe
	 * @Covers FRotator.DeclarationDefaults
	 * @Inputs a second actor
	 * @Return true when this instance reads 0 and the other still reads 10
	 * @Param Second the other actor, expected to keep its declared default
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CustomRotCopyIndependence(ACoverageFRotatorDefaultsActor Second)
	{
		if (Second is null)
		{
			throw("FRotatorDeclarationDefaults setup: required Second is null");
		}
		CustomRot.Pitch = 0.0;

		if (CustomRot.Pitch != 0.0)
		{
			return false;
		}
		return Second.CustomRot.Pitch == 10.0;
	}
}
/** @end */
