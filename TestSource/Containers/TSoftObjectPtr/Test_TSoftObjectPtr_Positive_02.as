// Theme: Containers.TSoftObjectPtr. Positive: TSoftObjectPtr.IsValid() on a parameter.
// C++: AngelscriptSyntaxSmartPointerTests.cpp::TSoftObjectPtr_Positive AssertCompiles ASSyntaxSPSoftIsValid.
// Oracle: empty IsValid is false. Extra: default-constructed param is null.
// DefaultSafe. Source owns locals.

void Test(TSoftObjectPtr<UStaticMesh> Soft)
{
	bool B = Soft.IsValid();
}

bool Observe_SoftIsValid_EmptyDefault()
{
	TSoftObjectPtr<UStaticMesh> Soft;
	Test(Soft);
	return Soft.IsValid() == false && Soft.IsNull();
}

bool Observe_SoftIsValid_CopyIndependence()
{
	TSoftObjectPtr<UStaticMesh> First;
	TSoftObjectPtr<UStaticMesh> Second;
	Test(First);
	return First.IsNull() && Second.IsNull();
}
