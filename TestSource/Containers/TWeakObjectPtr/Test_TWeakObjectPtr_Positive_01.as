// Theme: Containers.TWeakObjectPtr. WorldStory: TWeakObjectPtr UPROPERTY declaration.
// C++: AngelscriptSyntaxSmartPointerTests.cpp::TWeakObjectPtr_Positive AssertCompiles ASSyntaxSPWeakDecl.
// Oracle: WeakRef default is null / not valid. Extra: a second instance stays independent.
// FixtureIsolated. Source owns locals.

class AActorSPWeakDecl : AActor
{
	UPROPERTY()
	TWeakObjectPtr<AActor> WeakRef;
}

bool Observe_WeakDecl_DefaultNull(AActorSPWeakDecl Actor)
{
	if (Actor is null)
	{
		throw("Test_TWeakObjectPtr_Positive_01 setup: required Actor is null");
	}
	return Actor.WeakRef == nullptr && Actor.WeakRef.IsValid() == false && Actor.WeakRef.Get() == nullptr;
}

bool Observe_WeakDecl_CopyIndependence(AActorSPWeakDecl First, AActorSPWeakDecl Second)
{
	if (First is null)
	{
		throw("Test_TWeakObjectPtr_Positive_01 setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_TWeakObjectPtr_Positive_01 setup: required Second is null");
	}
	TWeakObjectPtr<AActor> Empty;
	First.WeakRef = Empty;
	return First.WeakRef == nullptr && Second.WeakRef == nullptr && Second.WeakRef.IsValid() == false;
}
