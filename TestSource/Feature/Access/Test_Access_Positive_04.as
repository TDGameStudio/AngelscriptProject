// Theme: Feature.Access. WorldStory: a class may read and write its own private field.
// C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Positive block 4 AssertCompiles.
// Oracle: GetX default 0; SetX stores the given value including a negative boundary.
// Extra: empty/default 0; copy independence of two instances.
// FixtureIsolated.

class AActorSelfPriv : AActor
{
	private int X = 0;

	void SetX(int Val)
	{
		X = Val;
	}

	int GetX()
	{
		return X;
	}
}

int Observe_SelfPrivate_EmptyDefault(AActorSelfPriv Actor)
{
	if (Actor is null)
	{
		throw("Test_Access_Positive_04 setup: required Actor is null");
	}
	return Actor.GetX();
}

int Observe_SelfPrivate_NegativeBoundary(AActorSelfPriv Actor)
{
	if (Actor is null)
	{
		throw("Test_Access_Positive_04 setup: required Actor is null");
	}
	Actor.SetX(-1);
	return Actor.GetX();
}

bool Observe_SelfPrivate_CopyIndependence(AActorSelfPriv Original, AActorSelfPriv Copy)
{
	if (Original is null)
	{
		throw("Test_Access_Positive_04 setup: required Original is null");
	}
	if (Copy is null)
	{
		throw("Test_Access_Positive_04 setup: required Copy is null");
	}
	Copy.SetX(8);
	return Original.GetX() == 0 && Copy.GetX() == 8;
}
