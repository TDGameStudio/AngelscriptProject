/**
 * The FQuat X, Y, Z and W components read and written as members. C++ executes each
 * entrypoint and checks the value it produces, so those names are part of the contract
 * and are kept verbatim.
 *
 * @Theme Gameplay.FQuat
 * @Subject FQuat.MemberAccess
 * @Harness Function
 * @Tag Gameplay.FQuat.QuatMemberAccess
 * @Namespace FQuatTest
 * @Provenance Theme: Gameplay.FQuat. Positive X/Y/Z/W getter and setter oracles.
 * @Provenance C++: AngelscriptCoverageFQuatExpressionTests.cpp::QuatMemberAccess
 * @Provenance Oracle: GetX 0.1; GetY 0.2; GetZ 0.3; GetW 0.9; SetX/Y/Z/W each 0.5.
 * @Provenance Extra: default Identity W 1 X 0; copy independence of SetX. DefaultSafe.
 */

namespace FQuatTest
{
	/**
	 * Read the X component of a known quaternion.
	 *
	 * @Kind Observe
	 * @Covers FQuat.MemberAccess
	 * @Inputs none
	 * @Return 0.1
	 */
	UFUNCTION()
	float GetX()
	{
		FQuat q = FQuat(0.1, 0.2, 0.3, 0.9);
		return q.X;
	}

	/**
	 * Read the Y component of a known quaternion.
	 *
	 * @Kind Observe
	 * @Covers FQuat.MemberAccess
	 * @Inputs none
	 * @Return 0.2
	 */
	UFUNCTION()
	float GetY()
	{
		FQuat q = FQuat(0.1, 0.2, 0.3, 0.9);
		return q.Y;
	}

	/**
	 * Read the Z component of a known quaternion.
	 *
	 * @Kind Observe
	 * @Covers FQuat.MemberAccess
	 * @Inputs none
	 * @Return 0.3
	 */
	UFUNCTION()
	float GetZ()
	{
		FQuat q = FQuat(0.1, 0.2, 0.3, 0.9);
		return q.Z;
	}

	/**
	 * Read the W component of a known quaternion.
	 *
	 * @Kind Observe
	 * @Covers FQuat.MemberAccess
	 * @Inputs none
	 * @Return 0.9
	 */
	UFUNCTION()
	float GetW()
	{
		FQuat q = FQuat(0.1, 0.2, 0.3, 0.9);
		return q.W;
	}

	/**
	 * Write the X component of an identity quaternion.
	 *
	 * @Kind Observe
	 * @Covers FQuat.MemberAccess
	 * @Inputs none
	 * @Return the identity quaternion with X set to 0.5
	 */
	UFUNCTION()
	FQuat SetX()
	{
		FQuat q = FQuat::Identity;
		q.X = 0.5;
		return q;
	}

	/**
	 * Write the Y component of an identity quaternion.
	 *
	 * @Kind Observe
	 * @Covers FQuat.MemberAccess
	 * @Inputs none
	 * @Return the identity quaternion with Y set to 0.5
	 */
	UFUNCTION()
	FQuat SetY()
	{
		FQuat q = FQuat::Identity;
		q.Y = 0.5;
		return q;
	}

	/**
	 * Write the Z component of an identity quaternion.
	 *
	 * @Kind Observe
	 * @Covers FQuat.MemberAccess
	 * @Inputs none
	 * @Return the identity quaternion with Z set to 0.5
	 */
	UFUNCTION()
	FQuat SetZ()
	{
		FQuat q = FQuat::Identity;
		q.Z = 0.5;
		return q;
	}

	/**
	 * Write the W component of an identity quaternion.
	 *
	 * @Kind Observe
	 * @Covers FQuat.MemberAccess
	 * @Inputs none
	 * @Return the identity quaternion with W set to 0.5
	 */
	UFUNCTION()
	FQuat SetW()
	{
		FQuat q = FQuat::Identity;
		q.W = 0.5;
		return q;
	}

	/**
	 * Observe that all four getters read their own component.
	 *
	 * @Kind Observe
	 * @Covers FQuat.MemberAccess
	 * @Inputs none
	 * @Return true when X, Y, Z and W read 0.1, 0.2, 0.3 and 0.9
	 */
	UFUNCTION()
	bool GettersNominal()
	{
		if (GetX() != 0.1)
		{
			return false;
		}
		if (GetY() != 0.2)
		{
			return false;
		}
		if (GetZ() != 0.3)
		{
			return false;
		}
		return GetW() == 0.9;
	}

	/**
	 * Observe that writing X is visible on the result.
	 *
	 * @Kind Observe
	 * @Covers FQuat.MemberAccess
	 * @Inputs none
	 * @Return true when X reads 0.5
	 */
	UFUNCTION()
	bool SetXNominal()
	{
		return SetX().X == 0.5;
	}

	/**
	 * Observe that writing Y is visible on the result.
	 *
	 * @Kind Observe
	 * @Covers FQuat.MemberAccess
	 * @Inputs none
	 * @Return true when Y reads 0.5
	 */
	UFUNCTION()
	bool SetYNominal()
	{
		return SetY().Y == 0.5;
	}

	/**
	 * Observe that writing Z is visible on the result.
	 *
	 * @Kind Observe
	 * @Covers FQuat.MemberAccess
	 * @Inputs none
	 * @Return true when Z reads 0.5
	 */
	UFUNCTION()
	bool SetZNominal()
	{
		return SetZ().Z == 0.5;
	}

	/**
	 * Observe that writing W is visible on the result.
	 *
	 * @Kind Observe
	 * @Covers FQuat.MemberAccess
	 * @Inputs none
	 * @Return true when W reads 0.5
	 */
	UFUNCTION()
	bool SetWNominal()
	{
		return SetW().W == 0.5;
	}

	/**
	 * Observe that a default quaternion has the identity's components.
	 *
	 * @Kind Observe
	 * @Covers FQuat.MemberAccess
	 * @Inputs a default-constructed quaternion
	 * @Return true when X, Y and Z are 0 and W is 1
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultIdentity()
	{
		FQuat Empty = FQuat();

		if (Empty.X != 0.0)
		{
			return false;
		}
		if (Empty.Y != 0.0)
		{
			return false;
		}
		if (Empty.Z != 0.0)
		{
			return false;
		}
		return Empty.W == 1.0;
	}

	/**
	 * Observe that mutating a copy leaves the source quaternion untouched.
	 *
	 * @Kind Observe
	 * @Covers FQuat.MemberAccess
	 * @Inputs an identity quaternion and a mutated copy of it
	 * @Return true when the source is still the identity and the copy holds 0.5
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool SetXCopyIndependence()
	{
		FQuat Source = FQuat::Identity;
		FQuat Mutated = Source;
		Mutated.X = 0.5;

		if (!Source.Equals(FQuat::Identity, 0.001))
		{
			return false;
		}
		return Mutated.X == 0.5;
	}
}
