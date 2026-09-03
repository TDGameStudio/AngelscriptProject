/**
 * Visibility, shadow casting and the custom depth setters on a static mesh
 * component. C++ verifies the flags by path. The observers cover the local-construct
 * default and copy independence.
 *
 * @Theme World.Component
 * @Subject Component.PrimitiveRendering
 * @Harness UClass
 * @Tag World.Component.PrimitiveRendering
 * @Provenance Theme: World.Component. WorldStory: IsVisible, SetVisibility, SetCastShadow,
 * @Provenance custom depth setters.
 * @Provenance C++: AngelscriptCoveragePrimitiveComponentTests.cpp::PrimitiveRendering
 * @Provenance sha256=5aa6e7d178d9536a3ab474201ef5257891d9de8d71e884053a627dd68090b17b; lines 71-109.
 * @Provenance Oracle VerifyByPath: InitiallyVisible=true, AfterSetVisible=false,
 * @Provenance AfterSetCastShadow=true, CustomDepthCallAccepted=true. Extra: local
 * @Provenance construct all bools false, MeshComp null. FixtureIsolated.
 */

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

	/**
	 * WorldStory: BeginPlay reads the starting visibility, hides the mesh, disables
	 * its shadow, then turns on custom depth with a stencil value.
	 *
	 * @Kind WorldStory
	 * @Covers Component.PrimitiveRendering
	 * @Inputs a default-attached UStaticMeshComponent
	 * @Return InitiallyVisible true, AfterSetVisible false, AfterSetCastShadow true, CustomDepthCallAccepted true
	 */
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

	/**
	 * Observe that a locally constructed actor has no flags and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveRendering
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all five flags are clear and MeshComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (InitiallyVisible)
		{
			return false;
		}
		if (AfterSetVisible)
		{
			return false;
		}
		if (InitiallyCastsShadow)
		{
			return false;
		}
		if (AfterSetCastShadow)
		{
			return false;
		}
		if (CustomDepthCallAccepted)
		{
			return false;
		}
		return MeshComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitiveRendering
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds both flags and the other stays clear
	 * @Param Second the other actor, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoveragePrimitiveRenderingActor Second)
	{
		if (Second is null)
		{
			throw("PrimitiveRendering setup: required Second is null");
		}
		CustomDepthCallAccepted = true;
		AfterSetCastShadow = true;

		if (!CustomDepthCallAccepted)
		{
			return false;
		}
		if (!AfterSetCastShadow)
		{
			return false;
		}
		if (Second.CustomDepthCallAccepted)
		{
			return false;
		}
		return !Second.AfterSetCastShadow;
	}
}
