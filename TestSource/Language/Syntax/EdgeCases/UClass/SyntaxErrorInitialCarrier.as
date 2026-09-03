/**
 * The initial valid module in the compile-failure lifecycle: an annotated carrier
 * whose GetValue returns 7. After a later module breaks and is fixed, this value
 * must still be reachable through a fresh instance.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.SyntaxErrorInitialCarrier
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.SyntaxErrorInitialCarrier
 * @Provenance C++: AngelscriptCompilerFailureTests.cpp::SyntaxErrorFailsWithoutResidualReflection block 1
 * @Provenance sha256=d90cd300d6a64ea61217049be42b63544b3eaca6f35685785e71b1ac6c7b1e26; lines 169-179.
 * @Provenance Oracle: GetValue returns 7. Extra: a second instance also returns 7.
 * @Provenance DefaultSafe.
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
