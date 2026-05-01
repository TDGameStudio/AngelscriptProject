#include "Shared/AngelscriptFunctionalTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Components/SceneComponent.h"
#include "Components/SplineComponent.h"
#include "GameFramework/Actor.h"
#include "CQTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/UnrealType.h"

// Test Layer: UE Functional - Round1 vacuum-fill (USplineComponent default + AS API surface)
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

TEST_CLASS_WITH_FLAGS(FAngelscriptComponentSplineUsageTests,
	"Angelscript.TestModule.Functional.Component.SplineUsage",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	TEST_METHOD(SplineDefaultComponentRegistersAndAPICompiles)
	{
		using namespace AngelscriptFunctionalTestUtils;
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_FULL();
		FAngelscriptEngineScope EngineScope(Engine);

		static const FName ModuleName(TEXT("FunctionalSplineUsage"));
		ON_SCOPE_EXIT { Engine.DiscardModule(*ModuleName.ToString()); };

		UClass* ActorClass = CompileScriptModule(
			*TestRunner,
			Engine,
			ModuleName,
			TEXT("FunctionalSplineUsage.as"),
			TEXT(R"AS(
UCLASS()
class AFunctionalSplineActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach = Root)
	USplineComponent Spline;

	UPROPERTY()
	float SampledLength = 0.0;

	UPROPERTY()
	FVector SampledLocation = FVector::ZeroVector;

	UPROPERTY()
	FRotator SampledRotation = FRotator::ZeroRotator;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		SampledLength = Spline.GetSplineLength();
		SampledLocation = Spline.GetLocationAtDistanceAlongSpline(0.0, ESplineCoordinateSpace::World);
		SampledRotation = Spline.GetRotationAtDistanceAlongSpline(0.0, ESplineCoordinateSpace::World);
	}
}
)AS"),
			TEXT("AFunctionalSplineActor"));
		if (ActorClass == nullptr) { return; }

		TestRunner->TestTrue(
			TEXT("AFunctionalSplineActor should derive from AActor"),
			ActorClass->IsChildOf(AActor::StaticClass()));

		FObjectProperty* SplineProp = FindFProperty<FObjectProperty>(ActorClass, TEXT("Spline"));
		if (TestRunner->TestNotNull(TEXT("Spline FObjectProperty should be registered"), SplineProp))
		{
			TestRunner->TestTrue(
				TEXT("Spline property class should reference USplineComponent"),
				SplineProp->PropertyClass != nullptr
				&& SplineProp->PropertyClass->IsChildOf(USplineComponent::StaticClass()));
		}

		FObjectProperty* RootProp = FindFProperty<FObjectProperty>(ActorClass, TEXT("Root"));
		if (TestRunner->TestNotNull(TEXT("Root FObjectProperty should be registered"), RootProp))
		{
			TestRunner->TestTrue(
				TEXT("Root property class should reference USceneComponent"),
				RootProp->PropertyClass != nullptr
				&& RootProp->PropertyClass->IsChildOf(USceneComponent::StaticClass()));
		}

		// AngelscriptSettings::bScriptFloatIsFloat64 defaults to true, so AS 'float' lowers to FDoubleProperty.
		FDoubleProperty* SampledLengthProp = FindFProperty<FDoubleProperty>(ActorClass, TEXT("SampledLength"));
		TestRunner->TestNotNull(TEXT("SampledLength FDoubleProperty should be registered"), SampledLengthProp);

		FStructProperty* SampledLocationProp = FindFProperty<FStructProperty>(ActorClass, TEXT("SampledLocation"));
		TestRunner->TestNotNull(TEXT("SampledLocation FStructProperty should be registered"), SampledLocationProp);

		FStructProperty* SampledRotationProp = FindFProperty<FStructProperty>(ActorClass, TEXT("SampledRotation"));
		TestRunner->TestNotNull(TEXT("SampledRotation FStructProperty should be registered"), SampledRotationProp);
	}
};

#endif // WITH_DEV_AUTOMATION_TESTS
