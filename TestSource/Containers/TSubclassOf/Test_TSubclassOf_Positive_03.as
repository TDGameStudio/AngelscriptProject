// Theme: Containers.TSubclassOf. Positive: TSubclassOf.IsValid() on a parameter.
// C++: AngelscriptSyntaxSmartPointerTests.cpp::TSubclassOf_Positive AssertCompiles
// ASSyntaxSPSubclassNullCheck. Oracle: empty IsValid is false. Extra: assigned
// AActor::StaticClass is valid; a second empty copy stays independent.
// DefaultSafe. Source owns locals.

void Test(TSubclassOf<AActor> Class)
{
	if (Class.IsValid())
	{
	}
}

bool Observe_SubclassIsValid_EmptyDefault()
{
	TSubclassOf<AActor> Empty;
	Test(Empty);
	return Empty.IsValid() == false && Empty == nullptr;
}

bool Observe_SubclassIsValid_AssignedIdentity()
{
	TSubclassOf<AActor> Class = AActor::StaticClass();
	Test(Class);
	return Class.IsValid() && Class == AActor::StaticClass();
}

bool Observe_SubclassIsValid_CopyIndependence()
{
	TSubclassOf<AActor> First = AActor::StaticClass();
	TSubclassOf<AActor> Second;
	Test(First);
	Test(Second);
	return First.IsValid() && Second.IsValid() == false && Second == nullptr;
}
