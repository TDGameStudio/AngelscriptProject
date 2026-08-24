// Theme: Language.Preprocessor. Positive n"Name" rewrite to __STATIC_NAME.
// C++: AngelscriptPreprocessorLiteralTests.cpp::NameLiteralRoundTrip
// sha256=42357bab2ece2ad66c429cfafd0a05b8a13146226409d2ff0b5badffb2ee88c3; lines 46-54.
// Oracle: Entry() == 42 because n"Alpha" == n"Alpha" and n"Alpha" != n"Beta"; duplicate Alpha shares index.
// Extra: default FName is not Alpha/Beta. DefaultSafe.

int Entry()
{
	FName A = n"Alpha";
	FName B = n"Alpha";
	FName C = n"Beta";
	return A == B && A != C ? 42 : 0;
}

bool Observe_Entry_Nominal()
{
	return Entry() == 42;
}

bool Observe_NameLiteral_EmptyDefault()
{
	FName Empty;
	return Empty != n"Alpha" && Empty != n"Beta";
}

bool Observe_NameLiteral_CopyIndependence()
{
	FName First = n"Alpha";
	FName Second = First;
	return First == Second && First != n"Beta" && Entry() == 42;
}
