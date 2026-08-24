// Theme: Language.Syntax.Keywords. WorldStory: this.X assignment through SetX.
// C++: AngelscriptSyntaxMiscTests.cpp::Keywords_Positive block 1 AssertCompiles.
// sha256=725539f37361e9c48be2628aaccf770a652b819c847de033fc2f723b5ec86a2d; lines 108-118.
// Oracle: SetX(5) writes X=5 via this. Extra: default X is 0; SetX(0) stays 0;
// a second instance stays 0. FixtureIsolated.

class AActorThis : AActor
{
	int X = 0;

	void SetX(int Val)
	{
		this.X = Val;
	}
}

int Observe_ThisSetX_Nominal(AActorThis Actor)
{
	if (Actor is null)
	{
		throw("Test_Keywords_Positive_01 setup: required Actor is null");
	}
	Actor.SetX(5);
	return Actor.X;
}

int Observe_ThisSetX_DefaultZero(AActorThis Actor)
{
	if (Actor is null)
	{
		throw("Test_Keywords_Positive_01 setup: required Actor is null");
	}
	return Actor.X;
}

int Observe_ThisSetX_ZeroBoundary(AActorThis Actor)
{
	if (Actor is null)
	{
		throw("Test_Keywords_Positive_01 setup: required Actor is null");
	}
	Actor.SetX(0);
	return Actor.X;
}

bool Observe_ThisSetX_CopyIndependence(AActorThis First, AActorThis Second)
{
	if (First is null)
	{
		throw("Test_Keywords_Positive_01 setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_Keywords_Positive_01 setup: required Second is null");
	}
	First.SetX(8);
	return First.X == 8 && Second.X == 0;
}
