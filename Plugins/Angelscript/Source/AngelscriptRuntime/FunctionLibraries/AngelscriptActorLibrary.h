#pragma once
#include "GameFramework/Actor.h"
#include "AngelscriptActorLibrary.generated.h"

UCLASS(meta = (ScriptMixin = "AActor"))
class UAngelscriptActorLibrary : public UObject
{
	GENERATED_BODY()

public:

	UFUNCTION()
	static void SetActorRelativeLocation(AActor* Actor, const FVector& NewRelativeLocation)
	{
		Actor->SetActorRelativeLocation(NewRelativeLocation);
	}

	UFUNCTION()
	static FVector GetActorRelativeLocation(const AActor* Actor)
	{
		if (auto* RootComp = Actor->GetRootComponent())
			return RootComp->GetRelativeLocation();
		return FVector::ZeroVector;
	}

	UFUNCTION()
	static void SetActorRelativeRotation(AActor* Actor, const FRotator& NewRelativeRotation)
	{
		Actor->SetActorRelativeRotation(NewRelativeRotation);
	}

	UFUNCTION()
	static void SetActorRelativeRotationQuat(AActor* Actor, const FQuat& NewRelativeRotation)
	{
		Actor->SetActorRelativeRotation(NewRelativeRotation);
	}

	UFUNCTION()
	static FRotator GetActorRelativeRotation(const AActor* Actor)
	{
		if (auto* RootComp = Actor->GetRootComponent())
			return RootComp->GetRelativeRotation();
		return FRotator::ZeroRotator;
	}

	UFUNCTION()
	static void SetActorRelativeTransform(AActor* Actor, const FTransform& NewRelativeTransform)
	{
		Actor->SetActorRelativeTransform(NewRelativeTransform);
	}

	UFUNCTION()
	static FTransform GetActorRelativeTransform(const AActor* Actor)
	{
		if (auto* RootComp = Actor->GetRootComponent())
			return RootComp->GetRelativeTransform();
		return FTransform::Identity;
	}

	UFUNCTION()
	static void SetActorLocation(AActor* Actor, const FVector& NewLocation)
	{
		Actor->SetActorLocation(NewLocation);
	}

	UFUNCTION(BlueprintCallable)
	static FVector GetActorLocation(const AActor* Actor)
	{
		return Actor->GetActorLocation();
	}

	UFUNCTION(meta = (ScriptName = "SetActorLocation", NotAngelscriptProperty))
	static bool SetActorLocationAdvanced(AActor* Actor, const FVector& NewLocation, bool bSweep, FHitResult& SweepHitResult, bool bTeleport = false)
	{
		return Actor->K2_SetActorLocation(NewLocation, bSweep, SweepHitResult, bTeleport);
	}

	UFUNCTION()
	static void SetActorRotation(AActor* Actor, const FRotator& NewRotation)
	{
		Actor->SetActorRotation(NewRotation);
	}

	UFUNCTION(BlueprintCallable)
	static FRotator GetActorRotation(const AActor* Actor)
	{
		return Actor->GetActorRotation();
	}

	UFUNCTION()
	static void SetActorRotationQuat(AActor* Actor, const FQuat& NewRotation)
	{
		Actor->SetActorRotation(NewRotation);
	}

	UFUNCTION()
	static void SetActorLocationAndRotation(AActor* Actor, const FVector& NewLocation, const FRotator& NewRotation, bool bTeleport = false)
	{
		Actor->SetActorLocationAndRotation(NewLocation, NewRotation, false, nullptr, TeleportFlagToEnum(bTeleport));
	}

	UFUNCTION()
	static void SetActorLocationAndRotationQuat(AActor* Actor, const FVector& NewLocation, const FQuat& NewRotation, bool bTeleport = false)
	{
		Actor->SetActorLocationAndRotation(NewLocation, NewRotation, false, nullptr, TeleportFlagToEnum(bTeleport));
	}

	UFUNCTION()
	static void SetActorTransform(AActor* Actor, const FTransform& NewTransform)
	{
		Actor->SetActorTransform(NewTransform);
	}

	UFUNCTION()
	static void SetActorQuat(AActor* Actor, const FQuat& NewRotation)
	{
		Actor->SetActorRotation(NewRotation);
	}

	UFUNCTION()
	static FQuat GetActorQuat(const AActor* Actor)
	{
		return Actor->GetActorQuat();
	}

	UFUNCTION()
	static void AddActorLocalOffset(AActor* Actor, const FVector& DeltaLocation)
	{
		Actor->AddActorLocalOffset(DeltaLocation);
	}

	UFUNCTION()
	static void AddActorLocalRotation(AActor* Actor, const FRotator& DeltaRotation)
	{
		Actor->AddActorLocalRotation(DeltaRotation);
	}

	UFUNCTION()
	static void AddActorLocalRotationQuat(AActor* Actor, const FQuat& DeltaRotation)
	{
		Actor->AddActorLocalRotation(DeltaRotation);
	}

	UFUNCTION()
	static void AddActorLocalTransform(AActor* Actor, const FTransform& DeltaTransform)
	{
		Actor->AddActorLocalTransform(DeltaTransform);
	}

	UFUNCTION()
	static void AddActorWorldOffset(AActor* Actor, const FVector& DeltaLocation)
	{
		Actor->AddActorWorldOffset(DeltaLocation);
	}

	UFUNCTION()
	static void AddActorWorldRotation(AActor* Actor, const FRotator& DeltaRotation)
	{
		Actor->AddActorWorldRotation(DeltaRotation);
	}

	UFUNCTION()
	static void AddActorWorldRotationQuat(AActor* Actor, const FQuat& DeltaRotation)
	{
		Actor->AddActorWorldRotation(DeltaRotation);
	}

	UFUNCTION()
	static void AddActorWorldTransform(AActor* Actor, const FTransform& DeltaTransform)
	{
		Actor->AddActorWorldTransform(DeltaTransform);
	}

	UFUNCTION()
	static void AttachToComponent(AActor* Actor, USceneComponent* Parent, FName SocketName = NAME_None, EAttachmentRule AttachmentRule = EAttachmentRule::SnapToTarget)
	{
		Actor->K2_AttachToComponent(Parent, SocketName, AttachmentRule, AttachmentRule, EAttachmentRule::KeepWorld, false);
	}

	UFUNCTION()
	static void AttachToActor(AActor* Actor, AActor* ParentActor, FName SocketName = NAME_None, EAttachmentRule AttachmentRule = EAttachmentRule::SnapToTarget)
	{
	    Actor->K2_AttachToActor(ParentActor, SocketName, AttachmentRule, AttachmentRule, EAttachmentRule::KeepWorld, false);
	}

	UFUNCTION()
	static void SetbRunConstructionScriptOnDrag(AActor* Actor, bool Value)
	{
#if WITH_EDITOR
		Actor->bRunConstructionScriptOnDrag = Value;
#endif
	}

#if WITH_EDITOR
	UFUNCTION()
	static void RerunConstructionScripts(AActor* Actor)
	{
		Actor->RerunConstructionScripts();
	}
#endif
};
