// Theme: Containers.TWeakObjectPtr. Positive: TWeakObjectPtr.Get() on a parameter.
// C++: AngelscriptSyntaxSmartPointerTests.cpp::TWeakObjectPtr_Positive AssertCompiles ASSyntaxSPWeakGet.
// Oracle: empty Get() is null. Extra: two empty refs stay independent nulls.
// DefaultSafe. Source owns locals.

void Test(TWeakObjectPtr<AActor> Weak)
{
	AActor A = Weak.Get();
}

bool Observe_WeakGet_EmptyDefault()
{
	TWeakObjectPtr<AActor> Weak;
	Test(Weak);
	return Weak.Get() == nullptr && Weak.IsValid() == false;
}

bool Observe_WeakGet_CopyIndependence()
{
	TWeakObjectPtr<AActor> First;
	TWeakObjectPtr<AActor> Second;
	AActor Retrieved = First.Get();
	return Retrieved == nullptr && Second.Get() == nullptr;
}
