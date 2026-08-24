// Theme: Feature.Access. WorldStory: mixed public/private/protected members in one class.
// C++: AngelscriptSyntaxAccessSpecifierTests.cpp::Access_Positive block 6 AssertCompiles.
// Oracle: PubA default 0; PubMethod assigns PrivB from ProtC (2) without changing PubA.
// Extra: empty/default 0; copy independence of PubA.
// FixtureIsolated.

class AActorMixedLevels : AActor
{
	int PubA = 0;
	private int PrivB = 1;
	protected int ProtC = 2;

	void PubMethod()
	{
		PrivB = ProtC;
	}
}

int Observe_MixedLevels_EmptyDefault(AActorMixedLevels Actor)
{
	if (Actor is null)
	{
		throw("Test_Access_Positive_06 setup: required Actor is null");
	}
	return Actor.PubA;
}

int Observe_MixedLevels_PubMethodLeavesPublic(AActorMixedLevels Actor)
{
	if (Actor is null)
	{
		throw("Test_Access_Positive_06 setup: required Actor is null");
	}
	Actor.PubMethod();
	return Actor.PubA;
}

bool Observe_MixedLevels_CopyIndependence(AActorMixedLevels Original, AActorMixedLevels Copy)
{
	if (Original is null)
	{
		throw("Test_Access_Positive_06 setup: required Original is null");
	}
	if (Copy is null)
	{
		throw("Test_Access_Positive_06 setup: required Copy is null");
	}
	Copy.PubA = 5;
	Copy.PubMethod();
	return Original.PubA == 0 && Copy.PubA == 5;
}
