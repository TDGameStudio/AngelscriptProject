/**
 * An enum used as the type of a local variable. The observers declare locals of
 * that type and read back each enumerator's underlying value.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.EnumLocalUsage
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.EnumLocalUsage
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Enum_Positive block 4 AssertCompiles.
 * @Provenance sha256=c1cb1c70671e0d8302e4aa5c2bc9308aa91e457a16bcd7a14e0316e53236d22e; lines 356-363.
 * @Provenance Oracle: Test assigns EEnumUsage::Val1; Val1 is 0 and Val2 is 1.
 * @Provenance Extra: default Val1 is 0; Val2 is the other enumerator boundary.
 * @Provenance DefaultSafe. Source owns locals.
 */

enum EEnumUsage
{
	Val1,
	Val2
}

namespace SyntaxTest
{
	/**
	 * Declares a local of the enum type.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing
	 */
	void Test()
	{
		EEnumUsage E = EEnumUsage::Val1;
	}

	/**
	 * Observe the value held by a local set to the first enumerator.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a local initialised to EEnumUsage::Val1
	 * @Return 0
	 * @Boundary default enumerator
	 */
	UFUNCTION()
	int EnumLocalFirstValueDefaultsToZero()
	{
		EEnumUsage E = EEnumUsage::Val1;
		return int(E);
	}

	/**
	 * Observe the value held by a local set to the second enumerator.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a local initialised to EEnumUsage::Val2
	 * @Return 1
	 * @Boundary other enumerator
	 */
	UFUNCTION()
	int EnumLocalSecondValueBoundary()
	{
		EEnumUsage E = EEnumUsage::Val2;
		return int(E);
	}
}
