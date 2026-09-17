/**
 * @version v1
 * @summary UCLASS actor declaration forms that do not compile.
 * @topic Unreal
 * @topic ActorClass
 *
 * inherit-from-final-actor
 * syntax-error-initial-carrier
 * syntax-error-recovered-carrier
 */
/**
 * @begin inherit-from-final-actor
 * @summary A class deriving from a final actor. C++ originally expected this to be rejected, but the live C++ wraps it in #if 0 because structural validation is absent: the child compiles. The observers prove the child is a usable.
 * @topic Negative
 */
class AFinalInheritActor : AActor final
{
}

class AChildInheritActor : AFinalInheritActor
{
	/**
	 * Observe that the child of the final class is still that class.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a default-constructed AChildInheritActor handle
	 * @Return 1 when the value is an AFinalInheritActor, otherwise 0
	 */
	UFUNCTION()
	int FinalChildIsFinalActor()
	{
		AChildInheritActor Child;
		if (Child is AFinalInheritActor)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that an unset child handle is null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs an unset AChildInheritActor handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int FinalChildDefaultsToNull()
	{
		AChildInheritActor Child;
		if (Child is null)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that assigning one handle to another aliases them.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs two handles, one assigned from the other
	 * @Return true when both refer to the same object
	 * @Boundary handle aliasing
	 */
	UFUNCTION()
	bool FinalChildAssignAliases()
	{
		AChildInheritActor First;
		AChildInheritActor Second;
		First = Second;
		return First is Second;
	}
}
/** @end */
/**
 * @begin syntax-error-initial-carrier
 * @summary The initial valid module in the compile-failure lifecycle: an annotated carrier whose GetValue returns 7. After a later module breaks and is fixed, this value must still be reachable through a fresh instance.
 * @topic Negative
 */
UCLASS()
class UBrokenCarrier : UObject
{
	/**
	 * Returns the initial module's value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 7
	 */
	UFUNCTION()
	int GetValue()
	{
		return 7;
	}

	/**
	 * Observe the initial value.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed carrier
	 * @Return true when the value is 7
	 */
	UFUNCTION()
	bool SyntaxErrorInitialNominal()
	{
		return GetValue() == 7;
	}

	/**
	 * Observe that a second instance also reports 7.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs this carrier and a second carrier
	 * @Return true when both report 7
	 * @Boundary second instance
	 */
	UFUNCTION()
	bool SyntaxErrorInitialSecondInstance()
	{
		UBrokenCarrier Second =
			Cast<UBrokenCarrier>(
				NewObject(GetTransientPackage(), UBrokenCarrier::StaticClass(), n"SyntaxErrorInitialSecond"));
		if (Second == nullptr)
		{
			throw("Test_SyntaxErrorFailsWithoutResidualReflection_01 setup: NewObject returned null");
		}

		if (GetValue() != 7)
		{
			return false;
		}

		return Second.GetValue() == 7;
	}
}
/** @end */
/**
 * @begin syntax-error-recovered-carrier
 * @summary The recovered final module of the compile-failure lifecycle: the same annotated carrier, now valid again, with GetValue returning 9.
 * @topic Negative
 */
UCLASS()
class UBrokenCarrier : UObject
{
	/**
	 * Returns the recovered module's value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 9
	 */
	UFUNCTION()
	int GetValue()
	{
		return 9;
	}

	/**
	 * Observe the recovered value.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed carrier
	 * @Return true when the value is 9
	 */
	UFUNCTION()
	bool SyntaxErrorFixedNominal()
	{
		return GetValue() == 9;
	}

	/**
	 * Observe that a second instance also reports 9.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs this carrier and a second carrier
	 * @Return true when both report 9
	 * @Boundary second instance
	 */
	UFUNCTION()
	bool SyntaxErrorFixedSecondInstance()
	{
		UBrokenCarrier Second =
			Cast<UBrokenCarrier>(
				NewObject(GetTransientPackage(), UBrokenCarrier::StaticClass(), n"SyntaxErrorFixedSecond"));
		if (Second == nullptr)
		{
			throw("Test_SyntaxErrorFailsWithoutResidualReflection_03 setup: NewObject returned null");
		}

		if (GetValue() != 9)
		{
			return false;
		}

		return Second.GetValue() == 9;
	}
}
/** @end */
