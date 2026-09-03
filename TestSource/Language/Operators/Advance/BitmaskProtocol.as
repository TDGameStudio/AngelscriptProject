/**
 * A permission bitmask built from bitwise operators, which is the case where
 * they earn their keep. Each permission is one bit, so a set of permissions is
 * a single int: or adds one, and-not clears one, xor toggles one, and and tests
 * one. Testing with and is what makes the whole scheme work, because it reads
 * one bit without disturbing the others.
 * This is a composition: bitwise operators combine with assignment to mutate
 * the mask and with comparison to report the result, so no single-operator
 * Function file covers it.
 *
 * @Theme Language.Operators
 * @Subject Operators.BitmaskProtocol
 * @Harness Advance
 * @Tag Language.Operators.BitmaskProtocol
 * @Namespace OperatorsTest
 */

namespace OperatorsTest
{
	const int Perm_None  = 0x00;
	const int Perm_Read  = 0x01;
	const int Perm_Write = 0x02;
	const int Perm_Exec  = 0x04;
	const int Perm_Admin = 0x08;

	/**
	 * Add one permission to a mask, leaving the others as they were.
	 */
	int GrantPermission(int Mask, int Permission)
	{
		return Mask | Permission;
	}

	/**
	 * Clear one permission from a mask, leaving the others as they were.
	 */
	int RevokePermission(int Mask, int Permission)
	{
		return Mask & ~Permission;
	}

	/**
	 * Flip one permission, turning it on when off and off when on.
	 */
	int TogglePermission(int Mask, int Permission)
	{
		return Mask ^ Permission;
	}

	/**
	 * Report whether a mask carries one permission.
	 */
	bool HasPermission(int Mask, int Permission)
	{
		return (Mask & Permission) == Permission;
	}

	/**
	 * Report whether a mask carries every permission in a required set.
	 */
	bool HasAllPermissions(int Mask, int Required)
	{
		return (Mask & Required) == Required;
	}

	/**
	 * Observe granting: adding two permissions leaves both set, and adding one
	 * again changes nothing.
	 *
	 * @Kind Observe
	 * @Covers Operators.Bitwise
	 * @Inputs Grant read then write, then grant read a second time
	 * @Return true when both permissions are held and re-granting is a no-op
	 */
	UFUNCTION()
	bool GrantingPermissionsAccumulates()
	{
		int Mask = Perm_None;
		Mask = GrantPermission(Mask, Perm_Read);
		Mask = GrantPermission(Mask, Perm_Write);
		if (!HasPermission(Mask, Perm_Read))
		{
			return false;
		}
		if (!HasPermission(Mask, Perm_Write))
		{
			return false;
		}

		int Before = Mask;
		Mask = GrantPermission(Mask, Perm_Read);
		return Mask == Before;
	}

	/**
	 * Observe revoking: clearing one permission leaves the other intact, and
	 * clearing an absent permission is a no-op.
	 *
	 * @Kind Observe
	 * @Covers Operators.Bitwise
	 * @Inputs Grant read and write, revoke read, then revoke exec which was
	 *         never granted
	 * @Return true when write survives, read is gone, and the no-op holds
	 */
	UFUNCTION()
	bool RevokingPermissionsLeavesOthersIntact()
	{
		int Mask = Perm_None;
		Mask = GrantPermission(Mask, Perm_Read);
		Mask = GrantPermission(Mask, Perm_Write);
		Mask = RevokePermission(Mask, Perm_Read);
		if (HasPermission(Mask, Perm_Read))
		{
			return false;
		}
		if (!HasPermission(Mask, Perm_Write))
		{
			return false;
		}

		int Before = Mask;
		Mask = RevokePermission(Mask, Perm_Exec);
		return Mask == Before;
	}

	/**
	 * Observe toggling: flipping a permission twice returns to the original
	 * mask, and flipping one leaves its neighbour alone.
	 *
	 * @Kind Observe
	 * @Covers Operators.Bitwise
	 * @Inputs Toggle exec on, then off, checking read throughout
	 * @Return true when the mask returns to its starting value and read is
	 *         untouched either way
	 */
	UFUNCTION()
	bool TogglingPermissionsIsReversible()
	{
		int Start = Perm_Read;
		int Mask = TogglePermission(Start, Perm_Exec);
		if (!HasPermission(Mask, Perm_Exec))
		{
			return false;
		}
		if (!HasPermission(Mask, Perm_Read))
		{
			return false;
		}

		Mask = TogglePermission(Mask, Perm_Exec);
		if (HasPermission(Mask, Perm_Exec))
		{
			return false;
		}
		return Mask == Start;
	}

	/**
	 * Observe the all-required case: a mask must carry every bit in the
	 * required set, not merely one of them.
	 *
	 * @Kind Observe
	 * @Covers Operators.Bitwise
	 * @Inputs A mask holding read and write, tested against read+write and
	 *         against read+admin
	 * @Return true when the first requirement is met and the second is not
	 */
	UFUNCTION()
	bool RequiringAllPermissionsRejectsPartialMatches()
	{
		int Mask = GrantPermission(Perm_None, Perm_Read);
		Mask = GrantPermission(Mask, Perm_Write);

		int RequiredMet = Perm_Read | Perm_Write;
		int RequiredUnmet = Perm_Read | Perm_Admin;
		if (!HasAllPermissions(Mask, RequiredMet))
		{
			return false;
		}
		return !HasAllPermissions(Mask, RequiredUnmet);
	}

	/**
	 * Observe the empty default: a zero mask grants nothing, and clearing every
	 * permission returns a mask to zero.
	 *
	 * @Kind Observe
	 * @Covers Operators.Bitwise
	 * @Inputs An empty mask, then a full mask with everything revoked
	 * @Return true when the empty mask holds nothing and the revoked one is zero
	 * @Boundary empty mask
	 */
	UFUNCTION()
	bool EmptyMaskGrantsNothing()
	{
		if (HasPermission(Perm_None, Perm_Read))
		{
			return false;
		}
		if (HasPermission(Perm_None, Perm_Admin))
		{
			return false;
		}

		int Full = Perm_Read | Perm_Write | Perm_Exec | Perm_Admin;
		Full = RevokePermission(Full, Perm_Read);
		Full = RevokePermission(Full, Perm_Write);
		Full = RevokePermission(Full, Perm_Exec);
		Full = RevokePermission(Full, Perm_Admin);
		return Full == Perm_None;
	}

	/**
	 * Observe that a high permission bit does not disturb a low one, which is
	 * what makes packing several permissions into one int safe.
	 *
	 * @Kind Observe
	 * @Covers Operators.Bitwise
	 * @Inputs Grant admin to a mask already holding read, then test both
	 * @Return true when both permissions read back independently
	 * @Boundary adjacent bits stay independent
	 */
	UFUNCTION()
	bool AdjacentBitsStayIndependent()
	{
		int Mask = GrantPermission(Perm_None, Perm_Read);
		Mask = GrantPermission(Mask, Perm_Admin);
		if (!HasPermission(Mask, Perm_Read))
		{
			return false;
		}
		if (!HasPermission(Mask, Perm_Admin))
		{
			return false;
		}
		if (HasPermission(Mask, Perm_Write))
		{
			return false;
		}
		return !HasPermission(Mask, Perm_Exec);
	}
}
