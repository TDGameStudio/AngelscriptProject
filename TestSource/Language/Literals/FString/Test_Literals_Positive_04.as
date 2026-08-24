// Theme: Language.Literals.FString. Positive: concatenation with +=.
// C++: AngelscriptSyntaxFStringTests.cpp::Literals_Positive block 4 AssertCompiles.
// sha256=579289c89456a762869e55c4a2a32a6177a8dc6a943c0be72f96f09455e5784f; lines 81-83.
// Oracle: "Hello" += " World" yields "Hello World".
// Extra: empty += " World"; += "" leaves "Hello" unchanged.
// DefaultSafe. += mutates the destination.

void Test()
{
	FString S = "Hello";
	S += " World";
}

bool Observe_ConcatPlusEq_Nominal()
{
	FString S = "Hello";
	S += " World";
	return S == "Hello World";
}

bool Observe_ConcatPlusEq_EmptyDestination()
{
	FString S = "";
	S += " World";
	return S == " World";
}

bool Observe_ConcatPlusEq_EmptyAppendBoundary()
{
	FString S = "Hello";
	S += "";
	return S == "Hello";
}
