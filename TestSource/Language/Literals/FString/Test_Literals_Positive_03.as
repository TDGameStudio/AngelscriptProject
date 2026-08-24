// Theme: Language.Literals.FString. Positive: concatenation with +.
// C++: AngelscriptSyntaxFStringTests.cpp::Literals_Positive block 3 AssertCompiles.
// sha256=835dd583e2cc42912d55fb3df3a6c6087df24ec843b041081f10f67d9735bad5; lines 69-76.
// Oracle: "Hello" + " World" == "Hello World".
// Extra: empty + " World" == " World"; + does not mutate A.
// DefaultSafe.

void Test()
{
	FString A = "Hello";
	FString B = " World";
	FString C = A + B;
}

bool Observe_ConcatPlus_Nominal()
{
	FString A = "Hello";
	FString B = " World";
	FString C = A + B;
	return C == "Hello World";
}

bool Observe_ConcatPlus_EmptyLeft()
{
	FString A = "";
	FString B = " World";
	return A + B == " World";
}

bool Observe_ConcatPlus_CopyIndependence()
{
	FString A = "Hello";
	FString B = " World";
	FString C = A + B;
	A = "changed";
	return C == "Hello World";
}
