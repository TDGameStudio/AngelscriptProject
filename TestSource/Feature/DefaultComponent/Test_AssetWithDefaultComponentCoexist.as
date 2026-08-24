// Theme: Feature.DefaultComponent. Literal asset coexists with a DefaultComponent actor.
// C++: AngelscriptLiteralAssetPostInitTests.cpp::AssetWithDefaultComponentCoexist
// CSV NegativeDiagnostic is wrong: C++ CompileModuleWithResult bCompiled==true.
// Oracle: AAssetAndComponentActor and UAssetCarrier materialize; MyCoexistAsset CoexistMarker==99.
// Extra: empty carrier is null; class CoexistMarker default 0. Isolation=none.

UCLASS()
class UAssetCarrier : UObject
{
	UPROPERTY()
	int CoexistMarker = 0;
}

UCLASS()
class AAssetAndComponentActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;
}

asset MyCoexistAsset of UAssetCarrier
{
	CoexistMarker = 99;
}

bool Observe_AssetCarrier_EmptyDefaultIsNull()
{
	UAssetCarrier Carrier;
	return Carrier == nullptr;
}

int Observe_AssetCarrier_CoexistMarkerDefault(UAssetCarrier Carrier)
{
	if (Carrier == nullptr)
	{
		throw("TS-FEAT-0246 setup: required UAssetCarrier is null");
	}
	return Carrier.CoexistMarker;
}

bool Observe_AssetActor_EmptyDefaultIsNull()
{
	AAssetAndComponentActor Actor;
	return Actor == nullptr;
}
