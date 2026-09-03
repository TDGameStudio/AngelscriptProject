/**
 * CreateComponent returning named scene and billboard components to C++. The
 * entrypoint names are part of the C++ contract and are kept verbatim, including
 * the lookup with a deliberately wrong type. The observer covers the state before
 * any component has been created.
 *
 * @Theme World.Component
 * @Subject Component.CreateComponent
 * @Harness UClass
 * @Tag World.Component.CreateComponent
 * @Provenance Theme: World.Component. WorldStory: CreateComponent returns named scene
 * @Provenance and billboard components to C++.
 * @Provenance C++: AngelscriptActorComponentTests.cpp::CreateComponent
 * @Provenance sha256=1e4bdfcc46807fa61cae29802577616d7ad9f1c86d7b355fcab2bf69f61242b3; lines 214-260.
 * @Provenance Oracle C++ receives DynamicRoot/DynamicChild/DynamicBillboard and
 * @Provenance FindDynamicBillboardAsWrongTypeForCpp is null. Extra: local construct
 * @Provenance FindDynamicRootForCpp / FindDynamicBillboardForCpp / wrong type all null
 * @Provenance because Create* was not called. FixtureIsolated.
 */

UCLASS()
class ATestActorCreateComponent : AActor
{
	/**
	 * Create the dynamic root scene component for C++.
	 *
	 * @Kind Action
	 * @Covers Component.CreateComponent
	 * @Inputs none
	 * @Return the new scene component named DynamicRoot
	 */
	UFUNCTION()
	USceneComponent CreateDynamicRootForCpp()
	{
		return Cast<USceneComponent>(CreateComponent(USceneComponent::StaticClass(), n"DynamicRoot"));
	}

	/**
	 * Create the dynamic child scene component for C++.
	 *
	 * @Kind Action
	 * @Covers Component.CreateComponent
	 * @Inputs none
	 * @Return the new scene component named DynamicChild
	 */
	UFUNCTION()
	USceneComponent CreateDynamicChildForCpp()
	{
		return Cast<USceneComponent>(CreateComponent(USceneComponent::StaticClass(), n"DynamicChild"));
	}

	/**
	 * Create the dynamic billboard component for C++.
	 *
	 * @Kind Action
	 * @Covers Component.CreateComponent
	 * @Inputs none
	 * @Return the new billboard component named DynamicBillboard
	 */
	UFUNCTION()
	UBillboardComponent CreateDynamicBillboardForCpp()
	{
		return Cast<UBillboardComponent>(CreateComponent(UBillboardComponent::StaticClass(), n"DynamicBillboard"));
	}

	/**
	 * Create another named scene component for C++.
	 *
	 * @Kind Action
	 * @Covers Component.CreateComponent
	 * @Inputs none
	 * @Return the new scene component named CppReturnedNamedScene
	 */
	UFUNCTION()
	USceneComponent CreateNamedSceneForCpp()
	{
		return Cast<USceneComponent>(CreateComponent(USceneComponent::StaticClass(), n"CppReturnedNamedScene"));
	}

	/**
	 * Look up the dynamic root by name for C++.
	 *
	 * @Kind Observe
	 * @Covers Component.CreateComponent
	 * @Inputs none
	 * @Return the component named DynamicRoot, or null before it is created
	 */
	UFUNCTION()
	UActorComponent FindDynamicRootForCpp()
	{
		return GetComponent(USceneComponent::StaticClass(), n"DynamicRoot");
	}

	/**
	 * Look up the dynamic billboard by name for C++.
	 *
	 * @Kind Observe
	 * @Covers Component.CreateComponent
	 * @Inputs none
	 * @Return the component named DynamicBillboard, or null before it is created
	 */
	UFUNCTION()
	UActorComponent FindDynamicBillboardForCpp()
	{
		return GetComponent(UBillboardComponent::StaticClass(), n"DynamicBillboard");
	}

	/**
	 * Look up the dynamic billboard under a type it does not have, which must not
	 * resolve.
	 *
	 * @Kind Observe
	 * @Covers Component.CreateComponent
	 * @Inputs none
	 * @Return null, even after the billboard has been created
	 * @Boundary wrong type lookup
	 */
	UFUNCTION()
	UActorComponent FindDynamicBillboardAsWrongTypeForCpp()
	{
		return GetComponent(UStaticMeshComponent::StaticClass(), n"DynamicBillboard");
	}

	/**
	 * Observe that nothing resolves before any component has been created.
	 *
	 * @Kind Observe
	 * @Covers Component.CreateComponent
	 * @Inputs an actor on which no Create* entrypoint has run
	 * @Return true when all three lookups return null
	 * @Boundary create not yet called
	 */
	UFUNCTION()
	bool DefaultMissingNull()
	{
		if (FindDynamicRootForCpp() != nullptr)
		{
			return false;
		}
		if (FindDynamicBillboardForCpp() != nullptr)
		{
			return false;
		}
		return FindDynamicBillboardAsWrongTypeForCpp() == nullptr;
	}
}
