/**
 * @version v1
 * @summary Capsule, box and sphere default components, counted through a UShapeComponent query. C++ verifies the validity flag and the count. The observers cover the local-construct default and copy independence.
 * @topic World
 */
/**
 * @version root
 * @summary Capsule, box and sphere default components, counted through a UShapeComponent query. C++ verifies the validity flag and the count. The observers cover the local-construct default and copy independence.
 * @topic Baseline
 */
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

	/**
	 * WorldStory: BeginPlay sizes all three shapes, then counts the shape components
	 * the actor reports.
	 *
	 * @Kind WorldStory
	 * @Covers Component.MultipleShapeComponents
	 * @Inputs three default-attached shape components
	 * @Return AllComponentsValid true and ShapeComponentCount == 3
	 */
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

	/**
	 * Observe that a locally constructed actor has no shapes and no count.
	 *
	 * @Kind Observe
	 * @Covers Component.MultipleShapeComponents
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when the flag is clear, the count is 0 and all three handles are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (AllComponentsValid)
		{
			return false;
		}
		if (ShapeComponentCount != 0)
		{
			return false;
		}
		if (CapsuleComp != nullptr)
		{
			return false;
		}
		if (BoxComp != nullptr)
		{
			return false;
		}
		return SphereComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.MultipleShapeComponents
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds the counted state and the other stays at zero
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSpecialMultipleShapesActor Second)
	{
		if (Second is null)
		{
			throw("MultipleShapeComponents setup: required Second is null");
		}
		AllComponentsValid = true;
		ShapeComponentCount = 3;

		if (!AllComponentsValid)
		{
			return false;
		}
		if (ShapeComponentCount != 3)
		{
			return false;
		}
		if (Second.AllComponentsValid)
		{
			return false;
		}
		return Second.ShapeComponentCount == 0;
	}
}
/** @end */
