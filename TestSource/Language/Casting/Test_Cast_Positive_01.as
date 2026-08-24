// Theme: Language.Casting. Positive Cast<T> to parent class.
// C++: AngelscriptSyntaxCastingTests.cpp::Cast_Positive AssertCompiles
// Oracle: Cast<AActor>(P) identity-equals P; nullptr stays nullptr.
// Extra: null pawn is the empty/default vector.
// DefaultSafe. Pawn/Actor handles are runner-owned when non-null.

void Test(APawn P)
{
	AActor A = Cast<AActor>(P);
}

AActor Observe_CastToParent_Identity(APawn P)
{
	return Cast<AActor>(P);
}

bool Observe_CastToParent_NullDefault()
{
	APawn P = nullptr;
	AActor A = Cast<AActor>(P);
	return A == nullptr;
}
