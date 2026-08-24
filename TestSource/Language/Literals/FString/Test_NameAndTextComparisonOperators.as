// Theme: Language.Literals.FString. Positive FName.Compare and FText.IdenticalTo.
// C++: AngelscriptCoverageFStringExpressionTests.cpp::NameAndTextComparisonOperators
// sha256=4f4dba0a72bf6fde5f481e7f9fd73926f7d0ae845889925bd92d68bae86b51a4; lines 759-773.
// Oracle: NameCompareOrdersValues true; TextIdentical true (separate FromString are not IdenticalTo).
// Extra: two default FNames Compare equal; same FText IdenticalTo itself.
// DefaultSafe. Source owns locals.

bool NameCompareOrdersValues()
{
	FName Left = n"Alpha";
	FName Right = n"Beta";
	return Left.Compare(Right) < 0 && Right.Compare(Left) > 0;
}

bool TextIdentical()
{
	FText Left = FText::FromString("A");
	FText Right = FText::FromString("A");
	return !Left.IdenticalTo(Right);
}

bool Observe_NameAndTextCompare_Nominal()
{
	return NameCompareOrdersValues() && TextIdentical();
}

bool Observe_NameCompare_EmptyNone()
{
	FName Left;
	FName Right;
	return Left.Compare(Right) == 0;
}

bool Observe_TextIdentical_SameObjectBoundary()
{
	FText Value = FText::FromString("A");
	return Value.IdenticalTo(Value);
}
