// Theme: Language.Casting. Positive implicit derived-to-base argument conversion.
// C++: AngelscriptSyntaxCastingTests.cpp::Implicit_Positive AssertCompiles
// Oracle: APawn assigns to AActor with identity; nullptr stays nullptr.
// Extra: null pawn is the empty/default vector.
// DefaultSafe. Pawn handles are runner-owned when non-null.

void TakeActor(AActor A)
{
}

void Test(APawn P)
{
	TakeActor(P);
}

AActor Observe_DerivedToBase_Identity(APawn P)
{
	TakeActor(P);
	AActor A = P;
	return A;
}

bool Observe_DerivedToBase_NullDefault()
{
	APawn P = nullptr;
	TakeActor(P);
	AActor A = P;
	return A == nullptr;
}
