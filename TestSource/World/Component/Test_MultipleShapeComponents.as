// Theme: World.Component. WorldStory: capsule/box/sphere DefaultComponents
// and GetComponentsByClass(UShapeComponent).
// C++: AngelscriptCoverageSpecialComponentTests.cpp::MultipleShapeComponents
// sha256=8f848b734125188394025dd8f864fd7c26b5350ccc8a5011e21b6eee671bc596; lines 715-750.
// Oracle AllComponentsValid true, ShapeComponentCount=3.
// Extra: local construct valid false, count 0, handles null. FixtureIsolated.

UCLASS()
class ACoverageSpecialMultipleShapesActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UCapsuleComponent CapsuleComp;

	UPROPERTY(DefaultComponent, Attach=CapsuleComp)
	UBoxComponent BoxComp;

	UPROPERTY(DefaultComponent, Attach=CapsuleComp)
	USphereComponent SphereComp;

	UPROPERTY()
	bool AllComponentsValid = false;

	UPROPERTY()
	int ShapeComponentCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		AllComponentsValid = (CapsuleComp != nullptr && BoxComp != nullptr && SphereComp != nullptr);

		// Set sizes
		CapsuleComp.SetCapsuleSize(40.0f, 90.0f);
		BoxComp.SetBoxExtent(FVector(50.0f, 50.0f, 50.0f));
		SphereComp.SetSphereRadius(30.0f);

		// Count shape components
		TArray<UShapeComponent> ShapeComps;
		GetComponentsByClass(UShapeComponent::StaticClass(), ShapeComps);
		ShapeComponentCount = ShapeComps.Num();
	}
}

bool Observe_MultipleShapes_DefaultEmpty(ACoverageSpecialMultipleShapesActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MultipleShapeComponents setup: required Actor is null");
	}
	return !Actor.AllComponentsValid
		&& Actor.ShapeComponentCount == 0
		&& Actor.CapsuleComp == nullptr
		&& Actor.BoxComp == nullptr
		&& Actor.SphereComp == nullptr;
}

bool Observe_MultipleShapes_CopyIndependence(ACoverageSpecialMultipleShapesActor First, ACoverageSpecialMultipleShapesActor Second)
{
	if (First is null)
	{
		throw("Test_MultipleShapeComponents setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_MultipleShapeComponents setup: required Second is null");
	}
	First.AllComponentsValid = true;
	First.ShapeComponentCount = 3;
	return First.AllComponentsValid
		&& First.ShapeComponentCount == 3
		&& !Second.AllComponentsValid
		&& Second.ShapeComponentCount == 0;
}
