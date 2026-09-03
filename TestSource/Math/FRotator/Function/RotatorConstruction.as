/**
 * The FRotator construction paths: the default constructor, the three-parameter
 * constructor, the zero constant, and the pitch-only, yaw-only and roll-only
 * constructors. C++ executes each entrypoint and compares the result with the native
 * equivalent, so those names are part of the contract and are kept verbatim.
 *
 * @Theme Math.FRotator
 * @Subject FRotator.Construction
 * @Harness Function
 * @Tag Math.FRotator.RotatorConstruction
 * @Namespace FRotatorTest
 * @Provenance Theme: Gameplay.FRotator. Positive construction oracles.
 * @Provenance C++: AngelscriptCoverageFRotatorExpressionTests.cpp::RotatorConstruction
 * @Provenance Oracle: default ZeroRotator; (10,20,30); ZeroRotator; (45,0,0); (0,90,0); (0,0,180).
 * @Provenance Extra: default empty; copy independence of three-param. DefaultSafe.
 */

namespace FRotatorTest
{
	/**
	 * Construct a rotator with no arguments.
	 *
	 * @Kind Observe
	 * @Covers FRotator.Construction
	 * @Inputs none
	 * @Return FRotator(), which should be the zero rotator
	 * @Boundary default constructor
	 */
	UFUNCTION()
	FRotator ConstructDefault()
	{
		return FRotator();
	}

	/**
	 * Construct a rotator from pitch, yaw and roll.
	 *
	 * @Kind Observe
	 * @Covers FRotator.Construction
	 * @Inputs none
	 * @Return FRotator(10, 20, 30)
	 */
	UFUNCTION()
	FRotator ConstructThreeParams()
	{
		return FRotator(10, 20, 30);
	}

	/**
	 * Read the zero rotator constant.
	 *
	 * @Kind Observe
	 * @Covers FRotator.Construction
	 * @Inputs none
	 * @Return FRotator::ZeroRotator
	 */
	UFUNCTION()
	FRotator ConstructZeroRotator()
	{
		return FRotator::ZeroRotator;
	}

	/**
	 * Construct a rotator with only pitch set.
	 *
	 * @Kind Observe
	 * @Covers FRotator.Construction
	 * @Inputs none
	 * @Return FRotator(45, 0, 0)
	 */
	UFUNCTION()
	FRotator ConstructPitchOnly()
	{
		return FRotator(45, 0, 0);
	}

	/**
	 * Construct a rotator with only yaw set.
	 *
	 * @Kind Observe
	 * @Covers FRotator.Construction
	 * @Inputs none
	 * @Return FRotator(0, 90, 0)
	 */
	UFUNCTION()
	FRotator ConstructYawOnly()
	{
		return FRotator(0, 90, 0);
	}

	/**
	 * Construct a rotator with only roll set.
	 *
	 * @Kind Observe
	 * @Covers FRotator.Construction
	 * @Inputs none
	 * @Return FRotator(0, 0, 180)
	 */
	UFUNCTION()
	FRotator ConstructRollOnly()
	{
		return FRotator(0, 0, 180);
	}

	/**
	 * Observe that the default constructor yields the zero rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.Construction
	 * @Inputs none
	 * @Return true when the default equals ZeroRotator
	 */
	UFUNCTION()
	bool DefaultIsZero()
	{
		return ConstructDefault() == FRotator::ZeroRotator;
	}

	/**
	 * Observe that the three-parameter constructor keeps its components.
	 *
	 * @Kind Observe
	 * @Covers FRotator.Construction
	 * @Inputs none
	 * @Return true when the result equals FRotator(10, 20, 30)
	 */
	UFUNCTION()
	bool ThreeParamsNominal()
	{
		return ConstructThreeParams() == FRotator(10, 20, 30);
	}

	/**
	 * Observe that reading the zero constant yields the zero rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.Construction
	 * @Inputs none
	 * @Return true when the result equals ZeroRotator
	 */
	UFUNCTION()
	bool ZeroRotatorNominal()
	{
		return ConstructZeroRotator() == FRotator::ZeroRotator;
	}

	/**
	 * Observe that the pitch-only constructor keeps pitch 45.
	 *
	 * @Kind Observe
	 * @Covers FRotator.Construction
	 * @Inputs none
	 * @Return true when the result equals FRotator(45, 0, 0)
	 */
	UFUNCTION()
	bool PitchOnlyNominal()
	{
		return ConstructPitchOnly() == FRotator(45, 0, 0);
	}

	/**
	 * Observe that the yaw-only constructor keeps yaw 90.
	 *
	 * @Kind Observe
	 * @Covers FRotator.Construction
	 * @Inputs none
	 * @Return true when the result equals FRotator(0, 90, 0)
	 */
	UFUNCTION()
	bool YawOnlyNominal()
	{
		return ConstructYawOnly() == FRotator(0, 90, 0);
	}

	/**
	 * Observe that the roll-only constructor keeps roll 180.
	 *
	 * @Kind Observe
	 * @Covers FRotator.Construction
	 * @Inputs none
	 * @Return true when the result equals FRotator(0, 0, 180)
	 */
	UFUNCTION()
	bool RollOnlyNominal()
	{
		return ConstructRollOnly() == FRotator(0, 0, 180);
	}

	/**
	 * Observe that a default rotator reads as zero on every axis.
	 *
	 * @Kind Observe
	 * @Covers FRotator.Construction
	 * @Inputs a default-constructed rotator
	 * @Return true when Pitch, Yaw and Roll are 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultEmptyZero()
	{
		FRotator Empty = FRotator();

		if (Empty.Pitch != 0.0)
		{
			return false;
		}
		if (Empty.Yaw != 0.0)
		{
			return false;
		}
		return Empty.Roll == 0.0;
	}

	/**
	 * Observe that mutating a copy leaves the three-parameter result untouched.
	 *
	 * @Kind Observe
	 * @Covers FRotator.Construction
	 * @Inputs the three-parameter result and a mutated copy of it
	 * @Return true when the original still equals (10, 20, 30) and the copy holds 0 pitch
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ThreeParamsCopyIndependence()
	{
		FRotator Original = ConstructThreeParams();
		FRotator Copy = Original;
		Copy.Pitch = 0.0;

		if (!(Original == FRotator(10, 20, 30)))
		{
			return false;
		}
		return Copy.Pitch == 0.0;
	}
}
