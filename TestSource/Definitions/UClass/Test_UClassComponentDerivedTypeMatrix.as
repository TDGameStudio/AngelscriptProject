// Theme: Definitions.UClass. Positive derived-component type matrix.
// C++: AngelscriptCoverageUClassTests.cpp::UClassComponentDerivedTypeMatrix CompileUClassFixture.
// Oracle: each subclass generates; StaticMesh is a UStaticMeshComponent and USceneComponent;
// CharacterMovement is a UCharacterMovementComponent and not a USceneComponent.
// Extra: unset StaticMesh handle is the null/empty vector.
// DefaultSafe. Component handles are runner-owned when non-null.

UCLASS()
class UCoverageUClassDerivedStaticMeshComponent : UStaticMeshComponent
{
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
}

bool Observe_DerivedStaticMesh_IsChildOfNative()
{
	return UCoverageUClassDerivedStaticMeshComponent::StaticClass().IsChildOf(UStaticMeshComponent::StaticClass());
}

bool Observe_DerivedStaticMesh_IsSceneComponent()
{
	return UCoverageUClassDerivedStaticMeshComponent::StaticClass().IsChildOf(USceneComponent::StaticClass());
}

bool Observe_DerivedCharacterMovement_IsChildOfNative()
{
	return UCoverageUClassDerivedCharacterMovementComponent::StaticClass().IsChildOf(UCharacterMovementComponent::StaticClass());
}

bool Observe_DerivedCharacterMovement_NotSceneComponentBoundary()
{
	return !UCoverageUClassDerivedCharacterMovementComponent::StaticClass().IsChildOf(USceneComponent::StaticClass());
}

bool Observe_DerivedStaticMesh_NullDefault()
{
	UCoverageUClassDerivedStaticMeshComponent Component = nullptr;
	return Component == nullptr;
}
