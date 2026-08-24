// Theme: World.Component. WorldStory: IsVisible, SetVisibility, SetCastShadow,
// custom depth setters.
// C++: AngelscriptCoveragePrimitiveComponentTests.cpp::PrimitiveRendering
// sha256=5aa6e7d178d9536a3ab474201ef5257891d9de8d71e884053a627dd68090b17b; lines 71-109.
// Oracle VerifyByPath: InitiallyVisible=true, AfterSetVisible=false,
// AfterSetCastShadow=true, CustomDepthCallAccepted=true. Extra: local
// construct all bools false, MeshComp null. FixtureIsolated.

UCLASS()
class ACoveragePrimitiveRenderingActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UStaticMeshComponent MeshComp;

	UPROPERTY()
	bool InitiallyVisible = false;

	UPROPERTY()
	bool AfterSetVisible = false;

	UPROPERTY()
	bool InitiallyCastsShadow = false;

	UPROPERTY()
	bool AfterSetCastShadow = false;

	UPROPERTY()
	bool CustomDepthCallAccepted = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		InitiallyVisible = MeshComp.IsVisible();

		MeshComp.SetVisibility(false);
		AfterSetVisible = MeshComp.IsVisible();

		MeshComp.SetCastShadow(false);
		AfterSetCastShadow = true;

		MeshComp.SetRenderCustomDepth(true);
		MeshComp.SetCustomDepthStencilValue(128);
		CustomDepthCallAccepted = true;
	}
}

bool Observe_PrimitiveRendering_DefaultFalse(ACoveragePrimitiveRenderingActor Actor)
{
	if (Actor is null)
	{
		throw("Test_PrimitiveRendering setup: required Actor is null");
	}
	return !Actor.InitiallyVisible
		&& !Actor.AfterSetVisible
		&& !Actor.InitiallyCastsShadow
		&& !Actor.AfterSetCastShadow
		&& !Actor.CustomDepthCallAccepted
		&& Actor.MeshComp == nullptr;
}

bool Observe_PrimitiveRendering_CopyIndependence(ACoveragePrimitiveRenderingActor First, ACoveragePrimitiveRenderingActor Second)
{
	if (First is null)
	{
		throw("Test_PrimitiveRendering setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_PrimitiveRendering setup: required Second is null");
	}
	First.CustomDepthCallAccepted = true;
	First.AfterSetCastShadow = true;
	return First.CustomDepthCallAccepted
		&& First.AfterSetCastShadow
		&& !Second.CustomDepthCallAccepted
		&& !Second.AfterSetCastShadow;
}
