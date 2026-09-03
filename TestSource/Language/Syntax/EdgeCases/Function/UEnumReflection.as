/**
 * A UENUM-marked enum, which is exposed to reflection in addition to being a
 * plain script enum. The observers read both enumerators and confirm they differ.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.UEnumReflection
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.UEnumReflection
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Enum_Positive block 2 AssertCompiles.
 * @Provenance sha256=fb9ff343240dbbd778a95c2767ab64c9f569431e1a2af9ee835c0212d878cad4; lines 343-346.
 * @Provenance Oracle: Value1 is 0; Value2 is 1.
 * @Provenance Extra: default first enumerator is 0; Value2 is the last-index boundary.
 * @Provenance DefaultSafe. Source owns locals.
 */

UENUM()
enum EEnumUENUM
{
	Value1,
	Value2
}

namespace SyntaxTest
{
	/**
	 * Observe the value of the first reflected enumerator.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs EEnumUENUM::Value1
	 * @Return 0
	 * @Boundary default first value
	 */
	UFUNCTION()
	int ReflectedEnumFirstValueDefaultsToZero()
	{
		return int(EEnumUENUM::Value1);
	}

	/**
	 * Observe the value of the last reflected enumerator.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs EEnumUENUM::Value2
	 * @Return 1
	 * @Boundary last index
	 */
	UFUNCTION()
	int ReflectedEnumLastValueBoundary()
	{
		return int(EEnumUENUM::Value2);
	}

	/**
	 * Observe that the two enumerators are distinct.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs EEnumUENUM::Value1 and EEnumUENUM::Value2
	 * @Return true when they compare unequal
	 */
	UFUNCTION()
	bool ReflectedEnumEnumeratorsAreDistinct()
	{
		return EEnumUENUM::Value1 != EEnumUENUM::Value2;
	}
}
