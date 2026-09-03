/**
 * Derived-component type matrix. StaticMesh is a UStaticMeshComponent and a
 * USceneComponent; CharacterMovement is a UCharacterMovementComponent and not
 * a USceneComponent.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.UClassComponentDerivedTypeMatrix
 * @Harness UClass
 * @Tag Definitions.UClass.UClassComponentDerivedTypeMatrix
 * @Provenance Theme: Definitions.UClass. Positive derived-component type matrix.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassComponentDerivedTypeMatrix CompileUClassFixture.
 * @Provenance Oracle: each subclass generates; StaticMesh is a UStaticMeshComponent and USceneComponent;
 * @Provenance CharacterMovement is a UCharacterMovementComponent and not a USceneComponent.
 * @Provenance Extra: unset StaticMesh handle is the null/empty vector.
 * @Provenance DefaultSafe. Component handles are runner-owned when non-null.
 */

UCLASS()
class UCoverageUClassDerivedStaticMeshComponent : UStaticMeshComponent
{
	/**
	 * Observe that the derived static mesh is a UStaticMeshComponent child.
	 *
	 * @Kind Observe
	 * @Covers UClass.ComponentType
	 * @Inputs StaticClass() versus UStaticMeshComponent
	 * @Return true when IsChildOf(UStaticMeshComponent)
	 */
	UFUNCTION()
	bool IsChildOfNative()
	{
		return UCoverageUClassDerivedStaticMeshComponent::StaticClass().IsChildOf(UStaticMeshComponent::StaticClass());
	}

	/**
	 * Observe that the derived static mesh is a USceneComponent child.
	 *
	 * @Kind Observe
	 * @Covers UClass.ComponentType
	 * @Inputs StaticClass() versus USceneComponent
	 * @Return true when IsChildOf(USceneComponent)
	 */
	UFUNCTION()
	bool IsSceneComponent()
	{
		return UCoverageUClassDerivedStaticMeshComponent::StaticClass().IsChildOf(USceneComponent::StaticClass());
	}

	/**
	 * Observe that a nullptr static-mesh handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.ComponentType
	 * @Inputs UCoverageUClassDerivedStaticMeshComponent Component = nullptr
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UCoverageUClassDerivedStaticMeshComponent Component = nullptr;
		return Component == nullptr;
	}
}

UCLASS()
class UCoverageUClassDerivedSkeletalMeshComponent : USkeletalMeshComponent
{
}

UCLASS()
class UCoverageUClassDerivedCapsuleComponent : UCapsuleComponent
{
}

UCLASS()
class UCoverageUClassDerivedBoxComponent : UBoxComponent
{
}

UCLASS()
class UCoverageUClassDerivedSphereComponent : USphereComponent
{
}

UCLASS()
class UCoverageUClassDerivedSpringArmComponent : USpringArmComponent
{
}

UCLASS()
class UCoverageUClassDerivedCameraComponent : UCameraComponent
{
}

UCLASS()
class UCoverageUClassDerivedPointLightComponent : UPointLightComponent
{
}

UCLASS()
class UCoverageUClassDerivedArrowComponent : UArrowComponent
{
}

UCLASS()
class UCoverageUClassDerivedCharacterMovementComponent : UCharacterMovementComponent
{
	/**
	 * Observe that the derived movement component is a UCharacterMovementComponent child.
	 *
	 * @Kind Observe
	 * @Covers UClass.ComponentType
	 * @Inputs StaticClass() versus UCharacterMovementComponent
	 * @Return true when IsChildOf(UCharacterMovementComponent)
	 */
	UFUNCTION()
	bool IsChildOfNative()
	{
		return UCoverageUClassDerivedCharacterMovementComponent::StaticClass().IsChildOf(UCharacterMovementComponent::StaticClass());
	}

	/**
	 * Observe that character movement is not a USceneComponent.
	 *
	 * @Kind Observe
	 * @Covers UClass.ComponentType
	 * @Inputs StaticClass() versus USceneComponent
	 * @Return true when not IsChildOf(USceneComponent)
	 * @Boundary not a scene component
	 */
	UFUNCTION()
	bool NotSceneComponentBoundary()
	{
		return !UCoverageUClassDerivedCharacterMovementComponent::StaticClass().IsChildOf(USceneComponent::StaticClass());
	}
}
