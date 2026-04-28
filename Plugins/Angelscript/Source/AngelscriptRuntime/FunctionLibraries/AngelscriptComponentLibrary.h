#pragma once
#include "GameFramework/Actor.h"
#include "Components/SceneComponent.h"
#include "AngelscriptEngine.h"
#include "AngelscriptComponentLibrary.generated.h"

UCLASS(meta = (ScriptMixin = "USceneComponent"))
class UAngelscriptComponentLibrary : public UObject
{
	GENERATED_BODY()

public:

	UFUNCTION(BlueprintCallable)
	static FVector GetRelativeLocation(const USceneComponent* Component)
	{
		return Component->GetRelativeLocation();
	}

	UFUNCTION(BlueprintCallable)
	static FRotator GetRelativeRotation(const USceneComponent* Component)
	{
		return Component->GetRelativeRotation();
	}

	UFUNCTION(BlueprintCallable)
	static FVector GetRelativeScale3D(const USceneComponent* Component)
	{
		return Component->GetRelativeScale3D();
	}

	UFUNCTION(BlueprintCallable)
	static void SetRelativeLocation(USceneComponent* Component, const FVector& NewLocation)
	{
		Component->SetRelativeLocation(NewLocation);
	}

	UFUNCTION(BlueprintCallable)
	static void SetRelativeRotation(USceneComponent* Component, const FRotator& NewRotation)
	{
		Component->SetRelativeRotation(NewRotation);
	}

	UFUNCTION(BlueprintCallable, Meta = (ScriptName = "SetRelativeRotation", NotAngelscriptProperty))
	static void SetRelativeRotationQuat(USceneComponent* Component, const FQuat& NewRotation)
	{
		Component->SetRelativeRotation(NewRotation);
	}

	UFUNCTION(BlueprintCallable)
	static void SetRelativeTransform(USceneComponent* Component, const FTransform& NewTransform)
	{
		Component->SetRelativeTransform(NewTransform);
	}

	UFUNCTION(BlueprintCallable)
	static void SetRelativeLocationAndRotation(USceneComponent* Component, const FVector& NewLocation, const FRotator& NewRotation)
	{
		Component->SetRelativeLocationAndRotation(NewLocation, NewRotation);
	}

	UFUNCTION(BlueprintCallable, Meta = (ScriptName = "SetRelativeLocationAndRotation"))
	static void SetRelativeLocationAndRotationQuat(USceneComponent* Component, const FVector& NewLocation, const FQuat& NewRotation)
	{
		Component->SetRelativeLocationAndRotation(NewLocation, NewRotation);
	}

	UFUNCTION(BlueprintCallable)
	static FQuat GetSocketQuaternion(USceneComponent* Component, const FName& SocketName)
	{
		return Component->GetSocketQuaternion(SocketName);
	}

	UFUNCTION(BlueprintCallable)
	static void SetComponentQuat(USceneComponent* Component, const FQuat& NewRotation)
	{
		Component->SetWorldRotation(NewRotation);
	}

	UFUNCTION(BlueprintCallable)
	static FQuat GetComponentQuat(const USceneComponent* Component)
	{
		return Component->GetComponentQuat();
	}

	UFUNCTION(BlueprintCallable)
	static int32 GetNumChildrenComponents(const USceneComponent* Component)
	{
		return Component->GetNumChildrenComponents();
	}

	UFUNCTION(BlueprintCallable)
	static void AddRelativeLocation(USceneComponent* Component, const FVector& DeltaLocation)
	{
		Component->AddRelativeLocation(DeltaLocation);
	}

	UFUNCTION(BlueprintCallable)
	static void AddRelativeRotation(USceneComponent* Component, const FRotator& DeltaRotation)
	{
		Component->AddRelativeRotation(DeltaRotation);
	}

	UFUNCTION(BlueprintCallable, Meta = (ScriptName = "AddRelativeRotation"))
	static void AddRelativeRotationQuat(USceneComponent* Component, const FQuat& DeltaRotation)
	{
		Component->AddRelativeRotation(DeltaRotation);
	}

	UFUNCTION(BlueprintCallable)
	static void AddLocalOffset(USceneComponent* Component, const FVector& DeltaLocation)
	{
		Component->AddLocalOffset(DeltaLocation);
	}

	UFUNCTION(BlueprintCallable)
	static void AddLocalRotation(USceneComponent* Component, const FRotator& DeltaRotation)
	{
		Component->AddLocalRotation(DeltaRotation);
	}

	UFUNCTION(BlueprintCallable, Meta = (ScriptName = "AddLocalRotation"))
	static void AddLocalRotationQuat(USceneComponent* Component, const FQuat& DeltaRotation)
	{
		Component->AddLocalRotation(DeltaRotation);
	}

	UFUNCTION(BlueprintCallable)
	static void AddLocalTransform(USceneComponent* Component, const FTransform& DeltaTransform)
	{
		Component->AddLocalTransform(DeltaTransform);
	}

	UFUNCTION(BlueprintCallable)
	static void SetWorldLocation(USceneComponent* Component, const FVector& NewLocation)
	{
		Component->SetWorldLocation(NewLocation);
	}

	UFUNCTION(BlueprintCallable)
	static void SetWorldRotation(USceneComponent* Component, const FRotator& NewRotation)
	{
		Component->SetWorldRotation(NewRotation);
	}

	UFUNCTION(BlueprintCallable, Meta = (ScriptName = "SetWorldRotation", NotAngelscriptProperty))
	static void SetWorldRotationQuat(USceneComponent* Component, const FQuat& NewRotation)
	{
		Component->SetWorldRotation(NewRotation);
	}

	UFUNCTION(BlueprintCallable)
	static void SetWorldTransform(USceneComponent* Component, const FTransform& NewTransform)
	{
		Component->SetWorldTransform(NewTransform);
	}

	UFUNCTION(BlueprintCallable)
	static void SetWorldLocationAndRotation(USceneComponent* Component, const FVector& NewLocation, const FRotator& NewRotation)
	{
		Component->SetWorldLocationAndRotation(NewLocation, NewRotation);
	}

	UFUNCTION(BlueprintCallable, Meta = (ScriptName = "SetWorldLocationAndRotation"))	
	static void SetWorldLocationAndRotationQuat(USceneComponent* Component, const FVector& NewLocation, const FQuat& NewRotation)
	{
		Component->SetWorldLocationAndRotation(NewLocation, NewRotation);
	}

	UFUNCTION(BlueprintCallable)
	static void AddWorldOffset(USceneComponent* Component, const FVector& DeltaLocation)
	{
		Component->AddWorldOffset(DeltaLocation);
	}

	UFUNCTION(BlueprintCallable)
	static void AddWorldRotation(USceneComponent* Component, const FRotator& DeltaRotation)
	{
		Component->AddWorldRotation(DeltaRotation);
	}

	UFUNCTION(BlueprintCallable, Meta = (ScriptName = "AddWorldRotation"))
	static void AddWorldRotationQuat(USceneComponent* Component, const FQuat& DeltaRotation)
	{
		Component->AddWorldRotation(DeltaRotation);
	}

	UFUNCTION(BlueprintCallable)
	static void AddWorldTransform(USceneComponent* Component, const FTransform& DeltaTransform)
	{
		Component->AddWorldTransform(DeltaTransform);
	}

	UFUNCTION(BlueprintCallable)
	static void AttachToComponent(USceneComponent* Component, USceneComponent* Parent, const FName& SocketName = NAME_None, EAttachmentRule AttachmentRule = EAttachmentRule::SnapToTarget)
	{
#if WITH_EDITOR
		FUObjectThreadContext& ThreadContext = FUObjectThreadContext::Get();
		if (ThreadContext.IsInConstructor)
		{
			FAngelscriptEngine::Throw("Calling AttachToComponent in a default statement is invalid. Please use the 'Attach =' and 'AttachSocket = ' UPROPERTY specifiers instead.");
			return;
		}
#endif
		Component->K2_AttachToComponent(Parent, SocketName, AttachmentRule, AttachmentRule, EAttachmentRule::KeepWorld, false);
	}

	UFUNCTION(BlueprintCallable)
	static void SetbVisualizeComponent(USceneComponent* Component, bool bVisualize)
	{
#if WITH_EDITORONLY_DATA
		Component->bVisualizeComponent = bVisualize;
#endif
	}

	UFUNCTION(BlueprintCallable)
	static bool IsAttachedTo(const USceneComponent* Component, const USceneComponent* CheckComponent)
	{
		return Component->IsAttachedTo(CheckComponent);
	}

	UFUNCTION(BlueprintCallable, Meta = (ScriptName = "IsAttachedTo", ScriptTrivial))
	static bool IsAttachedTo_Actor(const USceneComponent* Component, const AActor* CheckActor)
	{
		const USceneComponent* CheckComp = Component;
		while(CheckComp != nullptr)
		{
			if (CheckComp->GetOwner() == CheckActor)
				return true;
			CheckComp = CheckComp->GetAttachParent();
		}

		return false;
	}

	UFUNCTION(BlueprintCallable)
	static FBoxSphereBounds GetBounds(const USceneComponent* Component)
	{
		return Component->Bounds;
	}

	UFUNCTION(BlueprintCallable, Meta = (ScriptTrivial, DeprecatedFunction, DeprecationMessage = "Get Bounds.Origin instead"))
	static FVector GetShapeCenter(const USceneComponent* Component)
	{
		return Component->Bounds.Origin;
	}
};
