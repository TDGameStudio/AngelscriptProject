// Theme: World.Component. WorldStory: script USceneComponent CustomRadius,
// CustomColor, GetArea.
// C++: AngelscriptCoverageSpecialComponentTests.cpp::CustomScriptSceneComponent
// sha256=60f9a53f42a66697cb73419aff76644699a813f481720e56682b2791be5b78a0; lines 616-663.
// Oracle RetrievedRadius=100, RetrievedColor red, CalculatedArea~31415.9,
// CustomComponentValid true. Extra: local construct radius/area 0, color
// default, CustomComp null, GetArea on a local component uses CustomRadius 100.
// FixtureIsolated.

UCLASS()
class UCustomSceneComponent : USceneComponent
{
	UPROPERTY()
	float CustomRadius = 100.0f;

	UPROPERTY()
	FLinearColor CustomColor = FLinearColor::Red;

	UFUNCTION()
	float GetArea()
	{
		return 3.14159f * CustomRadius * CustomRadius;
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
}

bool Observe_CustomSceneComponent_DefaultEmpty(ACoverageSpecialCustomSceneActor Actor)
{
	if (Actor is null)
	{
		throw("Test_CustomScriptSceneComponent setup: required Actor is null");
	}
	return Actor.RetrievedRadius == 0.0f
		&& Actor.CalculatedArea == 0.0f
		&& !Actor.CustomComponentValid
		&& Actor.CustomComp == nullptr;
}

float Observe_CustomSceneComponent_GetArea_ZeroBoundary(UCustomSceneComponent Comp)
{
	if (Comp is null)
	{
		throw("Test_CustomScriptSceneComponent setup: required Comp is null");
	}
	Comp.CustomRadius = 0.0f;
	return Comp.GetArea();
}
