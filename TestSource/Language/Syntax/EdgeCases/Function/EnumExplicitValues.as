/**
 * An enum whose enumerators carry explicit values rather than following the
 * implicit sequence. The observers read each value, including the zero default
 * and the highest assigned value.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.EnumExplicitValues
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.EnumExplicitValues
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Enum_Positive block 3 AssertCompiles.
 * @Provenance sha256=a454f499bb2f7a1b29845c9be2bdbf54d8377285f85c2598bc3a62e0ef123d08; lines 350-352.
 * @Provenance Oracle: Value1 is 0, Value2 is 5, Value3 is 10.
 * @Provenance Extra: 0 is the empty/default first value; 10 is the high boundary.
 * @Provenance DefaultSafe. Source owns locals.
 */

enum EEnumExplicit
{
	Value1 = 0,
	Value2 = 5,
	Value3 = 10
}

namespace SyntaxTest
{
	/**
	 * Observe the explicitly zero first enumerator.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs EEnumExplicit::Value1
	 * @Return 0
	 * @Boundary zero value
	 */
	UFUNCTION()
	int ExplicitEnumFirstValueIsZero()
	{
		return int(EEnumExplicit::Value1);
	}

	/**
	 * Observe the explicitly assigned middle value.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs EEnumExplicit::Value2
	 * @Return 5
	 */
	UFUNCTION()
	int ExplicitEnumMiddleValue()
	{
		return int(EEnumExplicit::Value2);
	}

	/**
	 * Observe the highest explicitly assigned value.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs EEnumExplicit::Value3
	 * @Return 10
	 * @Boundary high value
	 */
	UFUNCTION()
	int ExplicitEnumHighValueBoundary()
	{
		return int(EEnumExplicit::Value3);
	}
}
