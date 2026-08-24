// Theme: Gameplay.FVector2D. WorldStory declaration defaults after spawn.
// C++: AngelscriptCoverageFVector2DPropertyTests.cpp::FVector2DDeclarationDefaults
// Oracle VerifyByPath: ZeroVec (0,0); OneVec (1,1); CustomVec (5,10);
// NoDefaultVec (0,0); UnitXVec (1,0). Extra: NoDefaultVec empty zero.
// FixtureIsolated. Keep UPROPERTY names.

UCLASS()
class ACoverageFVector2DDefaultsActor : AActor
{
	UPROPERTY()
	FVector2D ZeroVec = FVector2D::ZeroVector;

	UPROPERTY()
	FVector2D OneVec = FVector2D(1, 1);

	UPROPERTY()
	FVector2D CustomVec = FVector2D(5, 10);

	UPROPERTY()
	FVector2D NoDefaultVec;

	UPROPERTY()
	FVector2D UnitXVec = FVector2D(1, 0);
}

bool Observe_ZeroVec(ACoverageFVector2DDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FVector2DDeclarationDefaults setup: required Actor is null");
	}
	return Actor.ZeroVec.X == 0.0 && Actor.ZeroVec.Y == 0.0;
}

bool Observe_OneVec(ACoverageFVector2DDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FVector2DDeclarationDefaults setup: required Actor is null");
	}
	return Actor.OneVec.X == 1.0 && Actor.OneVec.Y == 1.0;
}

bool Observe_CustomVec(ACoverageFVector2DDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FVector2DDeclarationDefaults setup: required Actor is null");
	}
	return Actor.CustomVec.X == 5.0 && Actor.CustomVec.Y == 10.0;
}

bool Observe_NoDefaultVec_EmptyZero(ACoverageFVector2DDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FVector2DDeclarationDefaults setup: required Actor is null");
	}
	return Actor.NoDefaultVec.X == 0.0 && Actor.NoDefaultVec.Y == 0.0;
}

bool Observe_UnitXVec(ACoverageFVector2DDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FVector2DDeclarationDefaults setup: required Actor is null");
	}
	return Actor.UnitXVec.X == 1.0 && Actor.UnitXVec.Y == 0.0;
}

bool Observe_CustomVec_CopyIndependence(ACoverageFVector2DDefaultsActor First, ACoverageFVector2DDefaultsActor Second)
{
	if (First is null)
	{
		throw("Test_FVector2DDeclarationDefaults setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_FVector2DDeclarationDefaults setup: required Second is null");
	}
	First.CustomVec.X = 0.0;
	return First.CustomVec.X == 0.0 && Second.CustomVec.X == 5.0;
}
