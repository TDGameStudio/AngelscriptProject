// Theme: Containers.TSubclassOf. WorldStory: TSubclassOf as a function parameter.
// C++: AngelscriptSyntaxSmartPointerTests.cpp::TSubclassOf_Positive AssertCompiles ASSyntaxSPSubclassParam.
// Oracle: SpawnActor accepts a null class. Extra: assigned AActor::StaticClass stays identity.
// FixtureIsolated. Source owns locals.

void SpawnActor(TSubclassOf<AActor> Class)
{
}

bool Observe_SubclassParam_EmptyNull()
{
	TSubclassOf<AActor> Empty;
	SpawnActor(Empty);
	return Empty == nullptr;
}

bool Observe_SubclassParam_AssignedIdentity()
{
	TSubclassOf<AActor> Class = AActor::StaticClass();
	SpawnActor(Class);
	return Class == AActor::StaticClass();
}

bool Observe_SubclassParam_CopyIndependence()
{
	TSubclassOf<AActor> First = AActor::StaticClass();
	TSubclassOf<AActor> Second;
	SpawnActor(First);
	SpawnActor(Second);
	return First != nullptr && Second == nullptr;
}
