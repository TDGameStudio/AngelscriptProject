// Theme: World.Component. WorldStory: script-derived UActorComponent fields
// and GetDoubledValue.
// C++: AngelscriptCoverageComponentTests.cpp::CustomScriptComponent
// sha256=2248a6e3beef73e5943f6e9bcd24761cd8ee0bbcc617d045e95856af84eee79b; lines 2207-2250.
// Oracle VerifyByPath: RetrievedValue=42, RetrievedName="TestComponent",
// DoubledValue=84. Extra: local construct RetrievedValue 0, empty name,
// DoubledValue 0, CustomComp null. FixtureIsolated.

UCLASS()
class UCustomLogicComponent : UActorComponent
{
	UPROPERTY()
	int CustomValue = 42;

	UPROPERTY()
	FString CustomName = "TestComponent";

	UFUNCTION()
	int GetDoubledValue()
	{
		return CustomValue * 2;
	}
}

UCLASS()
class ACoverageComponentCustomScriptActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCustomLogicComponent CustomComp;

	UPROPERTY()
	int RetrievedValue = 0;

	UPROPERTY()
	FString RetrievedName;

	UPROPERTY()
	int DoubledValue = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (CustomComp != nullptr)
		{
			RetrievedValue = CustomComp.CustomValue;
			RetrievedName = CustomComp.CustomName;
			DoubledValue = CustomComp.GetDoubledValue();
		}
	}
}

bool Observe_CustomScriptComponent_DefaultEmpty(ACoverageComponentCustomScriptActor Actor)
{
	if (Actor is null)
	{
		throw("Test_CustomScriptComponent setup: required Actor is null");
	}
	return Actor.RetrievedValue == 0
		&& Actor.RetrievedName.Len() == 0
		&& Actor.DoubledValue == 0
		&& Actor.CustomComp == nullptr;
}

int Observe_CustomScriptComponent_GetDoubledValue_Default(UCustomLogicComponent Comp)
{
	if (Comp is null)
	{
		throw("Test_CustomScriptComponent setup: required Comp is null");
	}
	return Comp.GetDoubledValue();
}

int Observe_CustomScriptComponent_GetDoubledValue_ZeroBoundary(UCustomLogicComponent Comp)
{
	if (Comp is null)
	{
		throw("Test_CustomScriptComponent setup: required Comp is null");
	}
	Comp.CustomValue = 0;
	return Comp.GetDoubledValue();
}
