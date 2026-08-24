// Theme: Feature.Access. WorldStory: private member and method declarations compile.
// C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Positive block 2 AssertCompiles.
// Oracle: AActorPrivDecl constructs; SecretFunc stays private and is not called from outside.
// Extra: empty construct; two instances are independent objects.
// FixtureIsolated.

class AActorPrivDecl : AActor
{
	private int SecretVal = 42;

	private void SecretFunc()
	{
		SecretVal = 10;
	}
}

bool Observe_PrivateDecl_EmptyConstruct()
{
	AActorPrivDecl Actor;
	return Actor != nullptr;
}

bool Observe_PrivateDecl_CopyIndependence()
{
	AActorPrivDecl First;
	AActorPrivDecl Second;
	return First != nullptr && Second != nullptr && First != Second;
}
