/**
 * @version v1
 * @summary The FRotator Pitch, Yaw and Roll components read and written as members. C++ executes each entrypoint and checks the value it produces, so those names are part of the contract and are kept verbatim.
 * @topic Math
 */
/**
 * @version root
 * @summary The FRotator Pitch, Yaw and Roll components read and written as members. C++ executes each entrypoint and checks the value it produces, so those names are part of the contract and are kept verbatim.
 * @topic Baseline
 */
namespace FRotatorTest
{
	/**
	 * Read the pitch of a known rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.MemberAccess
	 * @Inputs none
	 * @Return 10
	 */
	UFUNCTION()
	float GetPitch()
	{
		FRotator r = FRotator(10, 20, 30);
		return r.Pitch;
	}

	/**
	 * Read the yaw of a known rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.MemberAccess
	 * @Inputs none
	 * @Return 20
	 */
	UFUNCTION()
	float GetYaw()
	{
		FRotator r = FRotator(10, 20, 30);
		return r.Yaw;
	}

	/**
	 * Read the roll of a known rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.MemberAccess
	 * @Inputs none
	 * @Return 30
	 */
	UFUNCTION()
	float GetRoll()
	{
		FRotator r = FRotator(10, 20, 30);
		return r.Roll;
	}

	/**
	 * Write pitch on a known rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.MemberAccess
	 * @Inputs none
	 * @Return FRotator(45, 20, 30)
	 */
	UFUNCTION()
	FRotator SetPitch()
	{
		FRotator r = FRotator(10, 20, 30);
		r.Pitch = 45;
		return r;
	}

	/**
	 * Write yaw on a known rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.MemberAccess
	 * @Inputs none
	 * @Return FRotator(10, 90, 30)
	 */
	UFUNCTION()
	FRotator SetYaw()
	{
		FRotator r = FRotator(10, 20, 30);
		r.Yaw = 90;
		return r;
	}

	/**
	 * Write roll on a known rotator.
	 *
	 * @Kind Observe
	 * @Covers FRotator.MemberAccess
	 * @Inputs none
	 * @Return FRotator(10, 20, 180)
	 */
	UFUNCTION()
	FRotator SetRoll()
	{
		FRotator r = FRotator(10, 20, 30);
		r.Roll = 180;
		return r;
	}

	/**
	 * Observe that all three getters read their own component.
	 *
	 * @Kind Observe
	 * @Covers FRotator.MemberAccess
	 * @Inputs none
	 * @Return true when Pitch, Yaw and Roll read 10, 20 and 30
	 */
	UFUNCTION()
	bool GettersNominal()
	{
		if (GetPitch() != 10.0)
		{
			return false;
		}
		if (GetYaw() != 20.0)
		{
			return false;
		}
		return GetRoll() == 30.0;
	}

	/**
	 * Observe that writing pitch is visible on the result.
	 *
	 * @Kind Observe
	 * @Covers FRotator.MemberAccess
	 * @Inputs none
	 * @Return true when SetPitch equals (45, 20, 30)
	 */
	UFUNCTION()
	bool SetPitchNominal()
	{
		return SetPitch() == FRotator(45, 20, 30);
	}

	/**
	 * Observe that writing yaw is visible on the result.
	 *
	 * @Kind Observe
	 * @Covers FRotator.MemberAccess
	 * @Inputs none
	 * @Return true when SetYaw equals (10, 90, 30)
	 */
	UFUNCTION()
	bool SetYawNominal()
	{
		return SetYaw() == FRotator(10, 90, 30);
	}

	/**
	 * Observe that writing roll is visible on the result.
	 *
	 * @Kind Observe
	 * @Covers FRotator.MemberAccess
	 * @Inputs none
	 * @Return true when SetRoll equals (10, 20, 180)
	 */
	UFUNCTION()
	bool SetRollNominal()
	{
		return SetRoll() == FRotator(10, 20, 180);
	}

	/**
	 * Observe that a default rotator has zero components.
	 *
	 * @Kind Observe
	 * @Covers FRotator.MemberAccess
	 * @Inputs a default-constructed rotator
	 * @Return true when Pitch, Yaw and Roll are 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool MemberDefaultEmptyZero()
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
	 * Observe that mutating a copy leaves the source rotator untouched.
	 *
	 * @Kind Observe
	 * @Covers FRotator.MemberAccess
	 * @Inputs a rotator and a mutated copy of it
	 * @Return true when the source is still (10, 20, 30) and the copy holds 45 pitch
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool SetPitchCopyIndependence()
	{
		FRotator Source = FRotator(10, 20, 30);
		FRotator Mutated = Source;
		Mutated.Pitch = 45;

		if (!(Source == FRotator(10, 20, 30)))
		{
			return false;
		}
		return Mutated.Pitch == 45.0;
	}
}
/** @end */
