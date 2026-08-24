// Theme: Gameplay.FLinearColor. WorldStory UPROPERTY declaration defaults.
// C++: AngelscriptCoverageFLinearColorPropertyTests.cpp::FLinearColorDeclarationDefaults
// Oracle VerifyByPath: White 1,1,1,1; Red 1,0,0; Black 0,0,0; Custom 0.5,0.25,0.75,1;
// NoDefault R 0 A 1; Blue B 1.
// Extra: default NoDefault G/B 0. FixtureIsolated. Keep UPROPERTY names.

UCLASS()
class ACoverageFLinearColorDefaultsActor : AActor
{
	UPROPERTY()
	FLinearColor WhiteColor = FLinearColor::White;

	UPROPERTY()
	FLinearColor RedColor = FLinearColor::Red;

	UPROPERTY()
	FLinearColor BlackColor = FLinearColor::Black;

	UPROPERTY()
	FLinearColor CustomColor = FLinearColor(0.5, 0.25, 0.75, 1.0);

	UPROPERTY()
	FLinearColor NoDefaultColor;

	UPROPERTY()
	FLinearColor BlueColor = FLinearColor::Blue;
}

bool Observe_WhiteColor(ACoverageFLinearColorDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FLinearColorDeclarationDefaults setup: required Actor is null");
	}
	return Actor.WhiteColor.R == 1.0
		&& Actor.WhiteColor.G == 1.0
		&& Actor.WhiteColor.B == 1.0
		&& Actor.WhiteColor.A == 1.0;
}

bool Observe_RedColor(ACoverageFLinearColorDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FLinearColorDeclarationDefaults setup: required Actor is null");
	}
	return Actor.RedColor.R == 1.0 && Actor.RedColor.G == 0.0 && Actor.RedColor.B == 0.0;
}

bool Observe_BlackColor(ACoverageFLinearColorDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FLinearColorDeclarationDefaults setup: required Actor is null");
	}
	return Actor.BlackColor.R == 0.0 && Actor.BlackColor.G == 0.0 && Actor.BlackColor.B == 0.0;
}

bool Observe_CustomColor(ACoverageFLinearColorDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FLinearColorDeclarationDefaults setup: required Actor is null");
	}
	return Actor.CustomColor.R == 0.5
		&& Actor.CustomColor.G == 0.25
		&& Actor.CustomColor.B == 0.75
		&& Actor.CustomColor.A == 1.0;
}

bool Observe_NoDefaultColor(ACoverageFLinearColorDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FLinearColorDeclarationDefaults setup: required Actor is null");
	}
	return Actor.NoDefaultColor.R == 0.0 && Actor.NoDefaultColor.A == 1.0;
}

bool Observe_BlueColor(ACoverageFLinearColorDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FLinearColorDeclarationDefaults setup: required Actor is null");
	}
	return Actor.BlueColor.B == 1.0;
}

bool Observe_NoDefaultColor_EmptyGB(ACoverageFLinearColorDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FLinearColorDeclarationDefaults setup: required Actor is null");
	}
	return Actor.NoDefaultColor.G == 0.0 && Actor.NoDefaultColor.B == 0.0;
}

bool Observe_CustomColor_CopyIndependence(ACoverageFLinearColorDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FLinearColorDeclarationDefaults setup: required Actor is null");
	}
	FLinearColor Copy = Actor.CustomColor;
	Copy.R = 0.0;
	return Actor.CustomColor.Equals(FLinearColor(0.5, 0.25, 0.75, 1.0));
}
