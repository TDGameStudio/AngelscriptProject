// Theme: Containers.TSoftObjectPtr. Positive: TSoftObjectPtr.Get() on a parameter.
// C++: AngelscriptSyntaxSmartPointerTests.cpp::TSoftObjectPtr_Positive AssertCompiles ASSyntaxSPSoftGet.
// Oracle: empty Get() is null. Extra: two empty refs stay independent nulls.
// DefaultSafe. Source owns locals.

void Test(TSoftObjectPtr<UStaticMesh> Soft)
{
	UStaticMesh Mesh = Soft.Get();
}

bool Observe_SoftGet_EmptyDefault()
{
	TSoftObjectPtr<UStaticMesh> Soft;
	Test(Soft);
	return Soft.Get() == nullptr;
}

bool Observe_SoftGet_CopyIndependence()
{
	TSoftObjectPtr<UStaticMesh> First;
	TSoftObjectPtr<UStaticMesh> Second;
	UStaticMesh Mesh = First.Get();
	return Mesh == nullptr && Second.Get() == nullptr;
}
