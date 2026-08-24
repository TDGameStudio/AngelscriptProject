// Theme: Language.Literals.FString. Positive assignment, concat, compare, index, FName/FText.
// C++: AngelscriptCoverageFStringExpressionTests.cpp::StringOperators
// sha256 from TS-LANG-0127; lines 237-327.
// Oracle: First; Hello World; true compares; OpIndex 'Z' (90); FName copy independence; FText IdenticalTo false.
// Extra: empty concat; assignment copy independence.
// DefaultSafe. Source owns locals.

FString OpAssignment()
{
	FString a = "First";
	FString b = a;
	return b;
}

FString OpConcatenation()
{
	return "Hello" + " " + "World";
}

FString OpConcatAssignment()
{
	FString s = "Hello";
	s += " World";
	return s;
}

bool OpEquals()
{
	return "Test" == "Test";
}

bool OpNotEquals()
{
	return "ABC" != "XYZ";
}

bool OpLessThan()
{
	return "AAA" < "BBB";
}

bool OpGreaterThan()
{
	return "ZZZ" > "AAA";
}

bool OpLessEqual()
{
	return "AAA" <= "AAA";
}

bool OpGreaterEqual()
{
	return "BBB" >= "AAA";
}

int OpIndex()
{
	FString s = "AZ";
	return s[1];
}

bool OpNameEquals()
{
	FName a = n"Test";
	FName b = n"Test";
	return a == b;
}

bool OpNameNotEquals()
{
	FName a = n"Alpha";
	FName b = n"Beta";
	return a != b;
}

bool OpNameEqualsString()
{
	FName a = n"StringMatch";
	return a.ToString() == "StringMatch";
}

bool OpNameReassignmentKeepsPreviousCopiesStable()
{
	FName original = n"Original";
	FName copy = original;
	original = n"Updated";
	return copy == n"Original" && original == n"Updated";
}

bool OpTextIdentical()
{
	FText a = FText::FromString("Display");
	FText b = FText::FromString("Display");
	return !a.IdenticalTo(b);
}

bool Observe_StringOperators_Nominal()
{
	return OpAssignment() == "First"
		&& OpConcatenation() == "Hello World"
		&& OpConcatAssignment() == "Hello World"
		&& OpEquals()
		&& OpNotEquals()
		&& OpLessThan()
		&& OpGreaterThan()
		&& OpLessEqual()
		&& OpGreaterEqual()
		&& OpIndex() == 90
		&& OpNameEquals()
		&& OpNameNotEquals()
		&& OpNameEqualsString()
		&& OpNameReassignmentKeepsPreviousCopiesStable()
		&& OpTextIdentical();
}

bool Observe_OpConcat_EmptyDefault()
{
	return ("" + "") == "";
}

bool Observe_OpAssignment_CopyIndependence()
{
	FString a = "First";
	FString b = a;
	a = "Second";
	return b == "First" && a == "Second";
}
