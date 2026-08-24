// Theme: Containers.TWeakObjectPtr. Positive: TWeakObjectPtr.IsValid() on a parameter.
// C++: AngelscriptSyntaxSmartPointerTests.cpp::TWeakObjectPtr_Positive AssertCompiles ASSyntaxSPWeakIsValid.
// Oracle: empty IsValid is false. Extra: two empty refs stay independent nulls.
// DefaultSafe. Source owns locals.

void Test(TWeakObjectPtr<AActor> Weak)
{
	if (Weak.IsValid())
	{
	}
}

bool Observe_WeakIsValid_EmptyDefault()
{
	TWeakObjectPtr<AActor> Weak;
	Test(Weak);
	return Weak.IsValid() == false && Weak == nullptr;
}

bool Observe_WeakIsValid_CopyIndependence()
{
	TWeakObjectPtr<AActor> First;
	TWeakObjectPtr<AActor> Second;
	Test(First);
	Test(Second);
	return First.IsValid() == false && Second.IsValid() == false && Second.Get() == nullptr;
}
