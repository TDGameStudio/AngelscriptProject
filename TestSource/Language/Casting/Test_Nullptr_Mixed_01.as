// Theme: Language.Casting. Positive assign nullptr to an object reference.
// C++: AngelscriptSyntaxCastingTests.cpp::Nullptr_Mixed AssertCompiles
// Oracle: AActor A = nullptr yields a null handle.
// Extra: default-constructed null handle; overwrite of a live handle is the null boundary.
// DefaultSafe. Non-null A is runner-owned.

void Test()
{
	AActor A = nullptr;
}

AActor Observe_NullAssign_Handle()
{
	AActor A = nullptr;
	return A;
}

AActor Observe_NullAssign_OverwriteBoundary(AActor A)
{
	A = nullptr;
	return A;
}
