/**
 * A script-derived scene component carrying a radius, a colour and an area
 * method. C++ reads the retrieved radius, colour, calculated area and validity
 * flag by path. The observers cover the local-construct default and the area
 * method at a zeroed radius.
 *
 * @Theme World.Component
 * @Subject Component.CustomScriptSceneComponent
 * @Harness UClass
 * @Tag World.Component.CustomScriptSceneComponent
 * @Provenance Theme: World.Component. WorldStory: script USceneComponent CustomRadius,
 * @Provenance CustomColor, GetArea.
 * @Provenance C++: AngelscriptCoverageSpecialComponentTests.cpp::CustomScriptSceneComponent
 * @Provenance sha256=60f9a53f42a66697cb73419aff76644699a813f481720e56682b2791be5b78a0; lines 616-663.
 * @Provenance Oracle RetrievedRadius=100, RetrievedColor red, CalculatedArea~31415.9,
 * @Provenance CustomComponentValid true. Extra: local construct radius/area 0, color
 * @Provenance default, CustomComp null, GetArea on a local component uses CustomRadius 100.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UCustomSceneComponent : USceneComponent
{
	UPROPERTY()
	float CustomRadius = 100.0f;

	UPROPERTY()
	FLinearColor CustomColor = FLinearColor::Red;

	/**
	 * Compute the circular area from the custom radius.
	 *
	 * @Kind Action
	 * @Covers Component.CustomScriptSceneComponent
	 * @Inputs none
	 * @Return pi * CustomRadius * CustomRadius
	 */
	UFUNCTION()
	float GetArea()
	{
		return 3.14159f * CustomRadius * CustomRadius;
	}

	/**
	 * Observe that a zeroed radius yields a zero area.
	 *
	 * @Kind Observe
	 * @Covers Component.CustomScriptSceneComponent
	 * @Inputs a component whose CustomRadius has been set to 0
	 * @Return GetArea(), expected to be 0
	 * @Boundary zero radius
	 */
	UFUNCTION()
	float GetAreaZeroBoundary()
	{
		CustomRadius = 0.0f;
		return GetArea();
	}
}

UCLASS()
class ACoverageSpecialCustomSceneActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UCustomSceneComponent CustomComp;

	UPROPERTY()
	float RetrievedRadius = 0.0f;

	UPROPERTY()
	FLinearColor RetrievedColor;

	UPROPERTY()
	float CalculatedArea = 0.0f;

	UPROPERTY()
	bool CustomComponentValid = false;

	/**
	 * WorldStory: BeginPlay copies the radius and colour off the component and calls
	 * its area method.
	 *
	 * @Kind WorldStory
	 * @Covers Component.CustomScriptSceneComponent
	 * @Inputs a default-attached UCustomSceneComponent
	 * @Return RetrievedRadius 100, RetrievedColor red, CalculatedArea ~31415.9, CustomComponentValid true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (CustomComp != nullptr)
		{
			CustomComponentValid = true;
			RetrievedRadius = CustomComp.CustomRadius;
			RetrievedColor = CustomComp.CustomColor;
			CalculatedArea = CustomComp.GetArea();
		}
	}

	/**
	 * Observe that a locally constructed actor has retrieved nothing.
	 *
	 * @Kind Observe
	 * @Covers Component.CustomScriptSceneComponent
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when radius and area are 0, the flag is clear and CustomComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (RetrievedRadius != 0.0f)
		{
			return false;
		}
		if (CalculatedArea != 0.0f)
		{
			return false;
		}
		if (CustomComponentValid)
		{
			return false;
		}
		return CustomComp == nullptr;
	}
}
