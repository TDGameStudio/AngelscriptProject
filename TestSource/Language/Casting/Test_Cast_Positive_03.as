// Theme: Language.Casting. Positive Cast<APawn> with a null check.
// C++: AngelscriptSyntaxCastingTests.cpp::Cast_Positive AssertCompiles
// Oracle: null actor downcasts to nullptr; a pawn handle round-trips through AActor.
// Extra: null actor is the empty/default vector.
// DefaultSafe. Actor/Pawn handles are runner-owned when non-null.

void Test(AActor A)
{
	APawn P = Cast<APawn>(A);
	if (P != nullptr)
	{
	}
}

bool Observe_CastNullCheck_NullDefault()
{
	AActor A = nullptr;
	APawn P = Cast<APawn>(A);
	return P == nullptr;
}

bool Observe_CastNullCheck_PawnIdentity(APawn P)
{
	AActor A = P;
	APawn Down = Cast<APawn>(A);
	return Down == P;
}
