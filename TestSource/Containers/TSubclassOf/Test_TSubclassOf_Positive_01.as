// Theme: Containers.TSubclassOf. WorldStory: TSubclassOf UPROPERTY declaration.
// C++: AngelscriptSyntaxSmartPointerTests.cpp::TSubclassOf_Positive AssertCompiles ASSyntaxSPSubclassDecl.
// Oracle: ActorClass default is null. Extra: assignment vs a second instance stays independent.
// FixtureIsolated. Source owns locals.

class AActorSPSubDecl : AActor
{
	UPROPERTY()
	TSubclassOf<AActor> ActorClass;
}

bool Observe_SubclassDecl_DefaultNull(AActorSPSubDecl Actor)
{
	if (Actor is null)
	{
		throw("Test_TSubclassOf_Positive_01 setup: required Actor is null");
	}
	return Actor.ActorClass == nullptr;
}

bool Observe_SubclassDecl_CopyIndependence(AActorSPSubDecl First, AActorSPSubDecl Second)
{
	if (First is null)
	{
		throw("Test_TSubclassOf_Positive_01 setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_TSubclassOf_Positive_01 setup: required Second is null");
	}
	First.ActorClass = AActor::StaticClass();
	return First.ActorClass != nullptr && Second.ActorClass == nullptr;
}
