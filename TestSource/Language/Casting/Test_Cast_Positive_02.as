// Theme: Language.Casting. Positive downcast with Cast<APawn>.
// C++: AngelscriptSyntaxCastingTests.cpp::Cast_Positive AssertCompiles
// Oracle: Cast<APawn>(A) returns the pawn when A is a pawn; nullptr in, nullptr out.
// Extra: null actor is the empty/default vector.
// DefaultSafe. Actor handles are runner-owned when non-null.

void Test(AActor A)
{
	APawn P = Cast<APawn>(A);
}

APawn Observe_Downcast_Result(AActor A)
{
	return Cast<APawn>(A);
}

bool Observe_Downcast_NullDefault()
{
	AActor A = nullptr;
	APawn P = Cast<APawn>(A);
	return P == nullptr;
}
