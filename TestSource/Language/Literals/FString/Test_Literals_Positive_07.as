// Theme: Language.Literals.FString. Positive: f-string with int and float interpolations.
// C++: AngelscriptSyntaxFStringTests.cpp::Literals_Positive block 7 AssertCompiles.
// sha256=b52c4e5ed6623ddc07a2696fd52955c5458efad242e2f52e69e10b117fb52ca4; lines 102-104.
// Oracle: f"{1} and {2.5f}" starts with "1 and ".
// Extra: A = 0, B = 0.0f interpolates zeros; mutating A/B after interpolation does not rewrite S.
// DefaultSafe.

void Test()
{
	int A = 1;
	float B = 2.5f;
	FString S = f"{A} and {B}";
}

bool Observe_FStringMulti_Nominal()
{
	int A = 1;
	float B = 2.5f;
	FString S = f"{A} and {B}";
	return S.StartsWith("1 and ");
}

bool Observe_FStringMulti_ZeroBoundary()
{
	int A = 0;
	float B = 0.0f;
	FString S = f"{A} and {B}";
	return S.StartsWith("0 and ");
}

bool Observe_FStringMulti_CopyIndependence()
{
	int A = 1;
	float B = 2.5f;
	FString S = f"{A} and {B}";
	A = 0;
	B = 0.0f;
	return S.StartsWith("1 and ");
}
