// Theme: Language.Casting. C++ wraps AssertFailsToCompile in #if 0
// (#as-engine-behavior implicit-conversion-permissive): Cast<T>(nullptr) compiles.
// CSV NegativeDiagnostic is wrong; this is a null-handle value oracle.
// Oracle: Cast<APawn>(nullptr) is nullptr.
// Extra: the same null vector as Test(). DefaultSafe.

void Test()
{
	auto X = Cast<APawn>(nullptr);
}

bool Observe_CastNullptrLiteral_IsNull()
{
	APawn X = Cast<APawn>(nullptr);
	return X == nullptr;
}
