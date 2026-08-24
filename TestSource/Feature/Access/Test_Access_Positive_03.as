// Theme: Feature.Access. WorldStory: protected member and method declarations compile.
// C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Positive block 3 AssertCompiles.
// Oracle: ProtectedVal default 0 is readable from a derived type; ProtectedFunc is callable there.
// Extra: empty/default 0; copy independence of two derived instances.
// FixtureIsolated.

class AActorProtDecl : AActor
{
	protected int ProtectedVal = 0;

	protected void ProtectedFunc()
	{
	}
}

class AActorProtDeclDerived : AActorProtDecl
{
	int ReadProtected()
	{
		return ProtectedVal;
	}

	void CallProtected()
	{
		ProtectedFunc();
	}

	void WriteProtected(int Val)
	{
		ProtectedVal = Val;
	}
}

int Observe_ProtectedDefaultZero(AActorProtDeclDerived Actor)
{
	if (Actor is null)
	{
		throw("Test_Access_Positive_03 setup: required Actor is null");
	}
	return Actor.ReadProtected();
}

int Observe_ProtectedFuncLeavesDefault(AActorProtDeclDerived Actor)
{
	if (Actor is null)
	{
		throw("Test_Access_Positive_03 setup: required Actor is null");
	}
	Actor.CallProtected();
	return Actor.ReadProtected();
}

bool Observe_ProtectedCopyIndependence(AActorProtDeclDerived Original, AActorProtDeclDerived Copy)
{
	if (Original is null)
	{
		throw("Test_Access_Positive_03 setup: required Original is null");
	}
	if (Copy is null)
	{
		throw("Test_Access_Positive_03 setup: required Copy is null");
	}
	Copy.WriteProtected(4);
	return Original.ReadProtected() == 0 && Copy.ReadProtected() == 4;
}
