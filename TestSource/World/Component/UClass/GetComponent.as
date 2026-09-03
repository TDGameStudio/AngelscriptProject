/**
 * GetComponent by class and by name, including the missing-name, missing-class and
 * wrong-class vectors that must all return null. C++ calls the entrypoints by
 * name, so the names are part of the contract and are kept verbatim. The observers
 * cover the local-construct default and the null vectors.
 *
 * @Theme World.Component
 * @Subject Component.GetComponent
 * @Harness UClass
 * @Tag World.Component.GetComponent
 * @Provenance Theme: World.Component. WorldStory: GetComponent by class/name, including
 * @Provenance missing and wrong-class nulls.
 * @Provenance C++: AngelscriptActorComponentTests.cpp::GetComponent
 * @Provenance sha256=185eaeda72c445ce175de052d9f110a4581ffd3d8e25119de393c4afa547dad1; lines 329-389.
 * @Provenance Oracle FindBillboardWithWrongClassForCpp, FindMissingSceneByNameForCpp,
 * @Provenance FindMissingComponentByClassForCpp return null. Extra: local construct all
 * @Provenance Find* return null. FixtureIsolated.
 */

UCLASS()
class UTestActorGetComponentMissing : UActorComponent
{
}

UCLASS()
class ATestActorGetComponent : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UStaticMeshComponent Mesh;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UBillboardComponent Billboard;

	/**
	 * Resolve the first scene component by class for C++.
	 *
	 * @Kind Observe
	 * @Covers Component.GetComponent
	 * @Inputs none
	 * @Return the first USceneComponent, or null before the actor is spawned
	 */
	UFUNCTION()
	UActorComponent FindFirstSceneByClassForCpp()
	{
		return GetComponent(USceneComponent::StaticClass());
	}

	/**
	 * Resolve the static mesh component by class for C++.
	 *
	 * @Kind Observe
	 * @Covers Component.GetComponent
	 * @Inputs none
	 * @Return the UStaticMeshComponent, or null before the actor is spawned
	 */
	UFUNCTION()
	UActorComponent FindMeshByClassForCpp()
	{
		return GetComponent(UStaticMeshComponent::StaticClass());
	}

	/**
	 * Resolve the root by both class and name for C++.
	 *
	 * @Kind Observe
	 * @Covers Component.GetComponent
	 * @Inputs none
	 * @Return the component named RootScene, or null before the actor is spawned
	 */
	UFUNCTION()
	UActorComponent FindRootByClassAndNameForCpp()
	{
		return GetComponent(USceneComponent::StaticClass(), n"RootScene");
	}

	/**
	 * Resolve the mesh through its parent class rather than its own for C++.
	 *
	 * @Kind Observe
	 * @Covers Component.GetComponent
	 * @Inputs none
	 * @Return the component named Mesh found as a USceneComponent
	 */
	UFUNCTION()
	UActorComponent FindMeshByParentClassAndNameForCpp()
	{
		return GetComponent(USceneComponent::StaticClass(), n"Mesh");
	}

	/**
	 * Resolve the billboard under a type it does not have, which must not resolve.
	 *
	 * @Kind Observe
	 * @Covers Component.GetComponent
	 * @Inputs none
	 * @Return null
	 * @Boundary wrong class
	 */
	UFUNCTION()
	UActorComponent FindBillboardWithWrongClassForCpp()
	{
		return GetComponent(UStaticMeshComponent::StaticClass(), n"Billboard");
	}

	/**
	 * Resolve a name the actor does not carry, which must not resolve.
	 *
	 * @Kind Observe
	 * @Covers Component.GetComponent
	 * @Inputs none
	 * @Return null
	 * @Boundary missing name
	 */
	UFUNCTION()
	UActorComponent FindMissingSceneByNameForCpp()
	{
		return GetComponent(USceneComponent::StaticClass(), n"MissingScene");
	}

	/**
	 * Resolve a class the actor does not carry, which must not resolve.
	 *
	 * @Kind Observe
	 * @Covers Component.GetComponent
	 * @Inputs none
	 * @Return null
	 * @Boundary missing class
	 */
	UFUNCTION()
	UActorComponent FindMissingComponentByClassForCpp()
	{
		return GetComponent(UTestActorGetComponentMissing::StaticClass());
	}

	/**
	 * Observe that a locally constructed actor has none of the three components.
	 *
	 * @Kind Observe
	 * @Covers Component.GetComponent
	 * @Inputs an actor that has not been spawned
	 * @Return true when all three handles are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultNull()
	{
		if (RootScene != nullptr)
		{
			return false;
		}
		if (Mesh != nullptr)
		{
			return false;
		}
		return Billboard == nullptr;
	}

	/**
	 * Observe that the three negative lookups all return null.
	 *
	 * @Kind Observe
	 * @Covers Component.GetComponent
	 * @Inputs an actor with a billboard but no static mesh and no missing names
	 * @Return true when all three negative lookups return null
	 * @Boundary wrong class, missing name, missing class
	 */
	UFUNCTION()
	bool MissingAndWrongClassNull()
	{
		if (FindBillboardWithWrongClassForCpp() != nullptr)
		{
			return false;
		}
		if (FindMissingSceneByNameForCpp() != nullptr)
		{
			return false;
		}
		return FindMissingComponentByClassForCpp() == nullptr;
	}
}
