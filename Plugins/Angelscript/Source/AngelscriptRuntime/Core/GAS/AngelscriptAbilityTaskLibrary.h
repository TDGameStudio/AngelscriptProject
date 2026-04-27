#pragma once

#include "CoreMinimal.h"

#include "Abilities/Tasks/AbilityTask_PlayMontageAndWait.h"
#include "Abilities/Tasks/AbilityTask_WaitGameplayEvent.h"
#include "Abilities/Tasks/AbilityTask_WaitGameplayTag.h"
#include "Abilities/Tasks/AbilityTask_WaitDelay.h"
#include "Abilities/Tasks/AbilityTask_NetworkSyncPoint.h"
#include "Abilities/Tasks/AbilityTask_ApplyRootMotionConstantForce.h"
#include "Abilities/Tasks/AbilityTask_ApplyRootMotionJumpForce.h"
#include "Abilities/Tasks/AbilityTask_ApplyRootMotionMoveToActorForce.h"
#include "Abilities/Tasks/AbilityTask_ApplyRootMotionMoveToForce.h"
#include "Abilities/Tasks/AbilityTask_ApplyRootMotionRadialForce.h"
#include "Abilities/Tasks/AbilityTask_MoveToLocation.h"
#include "Abilities/Tasks/AbilityTask_Repeat.h"
#include "Abilities/Tasks/AbilityTask_SpawnActor.h"
#include "Abilities/Tasks/AbilityTask_StartAbilityState.h"
#include "Abilities/Tasks/AbilityTask_VisualizeTargeting.h"
#include "Abilities/Tasks/AbilityTask_WaitAbilityActivate.h"
#include "Abilities/Tasks/AbilityTask_WaitAbilityCommit.h"
#include "Abilities/Tasks/AbilityTask_WaitAttributeChange.h"
#include "Abilities/Tasks/AbilityTask_WaitAttributeChangeRatioThreshold.h"
#include "Abilities/Tasks/AbilityTask_WaitAttributeChangeThreshold.h"
#include "Abilities/Tasks/AbilityTask_WaitCancel.h"
#include "Abilities/Tasks/AbilityTask_WaitConfirm.h"
#include "Abilities/Tasks/AbilityTask_WaitConfirmCancel.h"
#include "Abilities/Tasks/AbilityTask_WaitGameplayEffectApplied_Self.h"
#include "Abilities/Tasks/AbilityTask_WaitGameplayEffectApplied_Target.h"
#include "Abilities/Tasks/AbilityTask_WaitGameplayEffectBlockedImmunity.h"
#include "Abilities/Tasks/AbilityTask_WaitGameplayEffectRemoved.h"
#include "Abilities/Tasks/AbilityTask_WaitGameplayEffectStackChange.h"
#include "Abilities/Tasks/AbilityTask_WaitGameplayTagQuery.h"
#include "Abilities/Tasks/AbilityTask_WaitInputPress.h"
#include "Abilities/Tasks/AbilityTask_WaitInputRelease.h"
#include "Abilities/Tasks/AbilityTask_WaitMovementModeChange.h"
#include "Abilities/Tasks/AbilityTask_WaitOverlap.h"
#include "Abilities/Tasks/AbilityTask_WaitTargetData.h"
#include "Abilities/Tasks/AbilityTask_WaitVelocityChange.h"
#include "Kismet/BlueprintFunctionLibrary.h"

#include "AngelscriptAbilityTaskLibrary.generated.h"

UCLASS()
class ANGELSCRIPTRUNTIME_API UAngelscriptAbilityTaskLibrary : public UBlueprintFunctionLibrary
{
	GENERATED_BODY()

public:

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_ApplyRootMotionConstantForce* ApplyRootMotionConstantForce(
		UGameplayAbility* OwningAbility,
		const FName TaskInstanceName,
		const FVector& WorldDirection,
		const float Strength,
		const float Duration,
		const bool bIsAdditive, 
		UCurveFloat* StrengthOverTime,
		const ERootMotionFinishVelocityMode VelocityOnFinishMode,
		const FVector& SetVelocityOnFinish,
		const float ClampVelocityOnFinish,
		const bool bEnableGravity
	)
	{
		return UAbilityTask_ApplyRootMotionConstantForce::ApplyRootMotionConstantForce(
			OwningAbility, 
			TaskInstanceName, 
			WorldDirection, 
			Strength, 
			Duration, 
			bIsAdditive, 
			StrengthOverTime,
			VelocityOnFinishMode, 
			SetVelocityOnFinish, 
			ClampVelocityOnFinish,
			bEnableGravity
		);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_ApplyRootMotionJumpForce* ApplyRootMotionJumpForce(
		UGameplayAbility* OwningAbility,
		const FName TaskInstanceName,
		const FRotator& Rotation,
		const float Distance,
		const float Height,
		const float Duration,
		const float MinimumLandedTriggerTime,
		const bool bFinishOnLanded,
		const ERootMotionFinishVelocityMode VelocityOnFinishMode,
		const FVector& SetVelocityOnFinish,
		const float ClampVelocityOnFinish,
		UCurveVector* PathOffsetCurve,
		UCurveFloat* TimeMappingCurve
	)
	{
		return UAbilityTask_ApplyRootMotionJumpForce::ApplyRootMotionJumpForce(
			OwningAbility,
			TaskInstanceName,
			Rotation,
			Distance,
			Height,
			Duration,
			MinimumLandedTriggerTime,
			bFinishOnLanded,
			VelocityOnFinishMode,
			SetVelocityOnFinish,
			ClampVelocityOnFinish,
			PathOffsetCurve,
			TimeMappingCurve
		);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_ApplyRootMotionMoveToActorForce* ApplyRootMotionMoveToActorForce(
		UGameplayAbility* OwningAbility,
		const FName TaskInstanceName,
		AActor* TargetActor,
		const FVector& TargetLocationOffset,
		const ERootMotionMoveToActorTargetOffsetType OffsetAlignment,
		const float Duration,
		UCurveFloat* TargetLerpSpeedHorizontal,
		UCurveFloat* TargetLerpSpeedVertical,
		const bool bSetNewMovementMode,
		const EMovementMode MovementMode,
		const bool bRestrictSpeedToExpected,
		UCurveVector* PathOffsetCurve,
		UCurveFloat* TimeMappingCurve,
		const ERootMotionFinishVelocityMode VelocityOnFinishMode,
		const FVector& SetVelocityOnFinish,
		const float ClampVelocityOnFinish,
		const bool bDisableDestinationReachedInterrupt
	)
	{
		return UAbilityTask_ApplyRootMotionMoveToActorForce::ApplyRootMotionMoveToActorForce(
			OwningAbility,
			TaskInstanceName,
			TargetActor,
			TargetLocationOffset,
			OffsetAlignment,
			Duration,
			TargetLerpSpeedHorizontal,
			TargetLerpSpeedVertical,
			bSetNewMovementMode,
			MovementMode,
			bRestrictSpeedToExpected,
			PathOffsetCurve,
			TimeMappingCurve,
			VelocityOnFinishMode,
			SetVelocityOnFinish,
			ClampVelocityOnFinish,
			bDisableDestinationReachedInterrupt
		);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_ApplyRootMotionMoveToActorForce* ApplyRootMotionMoveToTargetDataActorForce(
		UGameplayAbility* OwningAbility,
		const FName TaskInstanceName,
		const FGameplayAbilityTargetDataHandle& TargetDataHandle,
		const int32 TargetDataIndex,
		const int32 TargetActorIndex,
		const FVector& TargetLocationOffset,
		const ERootMotionMoveToActorTargetOffsetType OffsetAlignment,
		const float Duration,
		UCurveFloat* TargetLerpSpeedHorizontal,
		UCurveFloat* TargetLerpSpeedVertical,
		const bool bSetNewMovementMode,
		const EMovementMode MovementMode,
		const bool bRestrictSpeedToExpected,
		UCurveVector* PathOffsetCurve,
		UCurveFloat* TimeMappingCurve,
		const ERootMotionFinishVelocityMode VelocityOnFinishMode,
		const FVector& SetVelocityOnFinish,
		const float ClampVelocityOnFinish,
		const bool bDisableDestinationReachedInterrupt
	)
	{
		return UAbilityTask_ApplyRootMotionMoveToActorForce::ApplyRootMotionMoveToTargetDataActorForce(
			OwningAbility,
			TaskInstanceName,
			TargetDataHandle,
			TargetDataIndex,
			TargetActorIndex,
			TargetLocationOffset,
			OffsetAlignment,
			Duration,
			TargetLerpSpeedHorizontal,
			TargetLerpSpeedVertical,
			bSetNewMovementMode,
			MovementMode,
			bRestrictSpeedToExpected,
			PathOffsetCurve,
			TimeMappingCurve,
			VelocityOnFinishMode,
			SetVelocityOnFinish,
			ClampVelocityOnFinish,
			bDisableDestinationReachedInterrupt
		);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_ApplyRootMotionMoveToForce* ApplyRootMotionMoveToForce(
		UGameplayAbility* OwningAbility,
		const FName TaskInstanceName,
		const FVector& TargetLocation,
		const float Duration,
		const bool bSetNewMovementMode,
		const EMovementMode MovementMode,
		const bool bRestrictSpeedToExpected,
		UCurveVector* PathOffsetCurve,
		const ERootMotionFinishVelocityMode VelocityOnFinishMode,
		const FVector& SetVelocityOnFinish,
		const float ClampVelocityOnFinish
	)
	{
		 return UAbilityTask_ApplyRootMotionMoveToForce::ApplyRootMotionMoveToForce(
			OwningAbility,
			TaskInstanceName,
			TargetLocation,
			Duration,
			bSetNewMovementMode,
			MovementMode,
			bRestrictSpeedToExpected,
			PathOffsetCurve,
			VelocityOnFinishMode,
			SetVelocityOnFinish,
			ClampVelocityOnFinish
		 );
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_ApplyRootMotionRadialForce* ApplyRootMotionRadialForce(
		UGameplayAbility* OwningAbility,
		const FName TaskInstanceName,
		const FVector& Location,
		AActor* LocationActor,
		const float Strength,
		const float Duration,
		const float Radius,
		const bool bIsPush,
		const bool bIsAdditive,
		const bool bNoZForce,
		UCurveFloat* StrengthDistanceFalloff,
		UCurveFloat* StrengthOverTime,
		const bool bUseFixedWorldDirection,
		const FRotator& FixedWorldDirection,
		const ERootMotionFinishVelocityMode VelocityOnFinishMode,
		const FVector& SetVelocityOnFinish,
		const float ClampVelocityOnFinish
	)
	{
		return UAbilityTask_ApplyRootMotionRadialForce::ApplyRootMotionRadialForce(
			OwningAbility,
			TaskInstanceName,
			Location,
			LocationActor,
			Strength,
			Duration,
			Radius,
			bIsPush,
			bIsAdditive,
			bNoZForce,
			StrengthDistanceFalloff,
			StrengthOverTime,
			bUseFixedWorldDirection,
			FixedWorldDirection,
			VelocityOnFinishMode,
			SetVelocityOnFinish,
			ClampVelocityOnFinish
		);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_MoveToLocation* MoveToLocation(
		UGameplayAbility* OwningAbility,
		const FName TaskInstanceName,
		const FVector& Location,
		const float Duration,
		UCurveFloat* InterpolationCurve = nullptr,
		UCurveVector* VectorInterpolationCurve = nullptr
	)
	{
		return UAbilityTask_MoveToLocation::MoveToLocation(
			OwningAbility,
			TaskInstanceName,
			Location,
			Duration,
			InterpolationCurve,
			VectorInterpolationCurve
		);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_NetworkSyncPoint* WaitNetSync(UGameplayAbility* OwningAbility, const EAbilityTaskNetSyncType SyncType)
	{
		return UAbilityTask_NetworkSyncPoint::WaitNetSync(OwningAbility, SyncType);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_PlayMontageAndWait* PlayMontageAndWait(
		UGameplayAbility* OwningAbility,
		const FName TaskInstanceName,
		UAnimMontage *MontageToPlay,
		const float Rate = 1.f,
		const FName StartSection = NAME_None,
		const bool bStopWhenAbilityEnds = true,
		const float AnimRootMotionTranslationScale = 1.f,
		const float StartTimeSeconds = 0.f
	)
	{
		return UAbilityTask_PlayMontageAndWait::CreatePlayMontageAndWaitProxy(
			OwningAbility,
			TaskInstanceName,
			MontageToPlay,
			Rate,
			StartSection,
			bStopWhenAbilityEnds,
			AnimRootMotionTranslationScale,
			StartTimeSeconds
		);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_Repeat* RepeatAction(UGameplayAbility* OwningAbility, const float TimeBetweenActions, const int32 TotalActionCount)
	{
		return UAbilityTask_Repeat::RepeatAction(OwningAbility, TimeBetweenActions, TotalActionCount);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_SpawnActor* SpawnActor(UGameplayAbility* OwningAbility, const FGameplayAbilityTargetDataHandle& TargetData, const TSubclassOf<AActor> Class)
	{
		return UAbilityTask_SpawnActor::SpawnActor(OwningAbility, TargetData, Class);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_StartAbilityState* StartAbilityState(UGameplayAbility* OwningAbility, const FName StateName, const bool bEndCurrentState = true)
	{
		return UAbilityTask_StartAbilityState::StartAbilityState(OwningAbility, StateName, bEndCurrentState);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_VisualizeTargeting* VisualizeTargeting(
		UGameplayAbility* OwningAbility,
		const TSubclassOf<AGameplayAbilityTargetActor> TargetClass,
		const FName TaskInstanceName,
		const float Duration = -1.0f
	)
	{
		return UAbilityTask_VisualizeTargeting::VisualizeTargeting(
			OwningAbility,
			TargetClass,
			TaskInstanceName,
			Duration
		);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_VisualizeTargeting* VisualizeTargetingUsingActor(
		UGameplayAbility* OwningAbility,
		AGameplayAbilityTargetActor* TargetActor,
		const FName TaskInstanceName,
		const float Duration = -1.0f
	)
	{
		return UAbilityTask_VisualizeTargeting::VisualizeTargetingUsingActor(
			OwningAbility,
			TargetActor,
			TaskInstanceName,
			Duration
		);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_WaitAbilityActivate* WaitForAbilityActivate(
		UGameplayAbility* OwningAbility,
		const FGameplayTag WithTag,
		const FGameplayTag WithoutTag,
		const bool bIncludeTriggeredAbilities = false,
		const bool bTriggerOnce = true
	)
	{
		return UAbilityTask_WaitAbilityActivate::WaitForAbilityActivate(
			OwningAbility,
			WithTag,
			WithoutTag,
			bIncludeTriggeredAbilities,
			bTriggerOnce	
		);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_WaitAbilityActivate* WaitForAbilityActivateQuery(
		UGameplayAbility* OwningAbility,
		const FGameplayTagQuery& Query,
		const bool bIncludeTriggeredAbilities = false,
		const bool bTriggerOnce = true
	)
	{
		return UAbilityTask_WaitAbilityActivate::WaitForAbilityActivate_Query(
			OwningAbility,
			Query,
			bIncludeTriggeredAbilities,
			bTriggerOnce	
		);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_WaitAbilityActivate* WaitForAbilityActivateWithTagRequirements(
		UGameplayAbility* OwningAbility,
		const FGameplayTagRequirements& TagRequirements,
		const bool bIncludeTriggeredAbilities = false,
		const bool bTriggerOnce = true
	)
	{
		return UAbilityTask_WaitAbilityActivate::WaitForAbilityActivateWithTagRequirements(
			OwningAbility,
			TagRequirements,
			bIncludeTriggeredAbilities,
			bTriggerOnce	
		);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_WaitAbilityCommit* WaitForNewAbilityCommit(
		UGameplayAbility* OwningAbility,
		const FGameplayTag WithTag,
		const FGameplayTag WithoutTag,
		const bool bTriggerOnce = true
	)
	{
		return UAbilityTask_WaitAbilityCommit::WaitForAbilityCommit(
			OwningAbility,
			WithTag,
			WithoutTag,
			bTriggerOnce
		);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_WaitAbilityCommit* WaitForNewAbilityCommitQuery(
		UGameplayAbility* OwningAbility,
		const FGameplayTagQuery& Query,
		const bool bTriggerOnce = true
	)
	{
		return UAbilityTask_WaitAbilityCommit::WaitForAbilityCommit_Query(
			OwningAbility,
			Query,
			bTriggerOnce
		);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_WaitAttributeChange* WaitForAttributeChange(
		UGameplayAbility* OwningAbility,
		const FGameplayAttribute& Attribute,
		const FGameplayTag WithTag,
		const FGameplayTag WithoutTag,
		const bool bTriggerOnce = true,
		AActor* ExternalOwner = nullptr
	)
	{
		return UAbilityTask_WaitAttributeChange::WaitForAttributeChange(
			OwningAbility,
			Attribute,
			WithTag,
			WithoutTag,
			bTriggerOnce,
			ExternalOwner
		);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_WaitAttributeChange* WaitForAttributeChangeWithComparison(
		UGameplayAbility* OwningAbility,
		const FGameplayAttribute& Attribute,
		const FGameplayTag WithTag,
		const FGameplayTag WithoutTag,
		const TEnumAsByte<EWaitAttributeChangeComparison::Type> ComparisonType,
		const float ComparisonValue,
		const bool bTriggerOnce = true,
		AActor* ExternalOwner = nullptr
	)
	{
		return UAbilityTask_WaitAttributeChange::WaitForAttributeChangeWithComparison(
			OwningAbility,
			Attribute,
			WithTag,
			WithoutTag,
			ComparisonType,
			ComparisonValue,
			bTriggerOnce,
			ExternalOwner
		);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_WaitAttributeChangeRatioThreshold* WaitForAttributeChangeRatioThreshold(
		UGameplayAbility* OwningAbility,
		const FGameplayAttribute& AttributeNumerator,
		const FGameplayAttribute& AttributeDenominator,
		const TEnumAsByte<EWaitAttributeChangeComparison::Type> ComparisonType,
		const float ComparisonValue,
		const bool bTriggerOnce = true,
		AActor* ExternalOwner = nullptr
	)
	{
		return UAbilityTask_WaitAttributeChangeRatioThreshold::WaitForAttributeChangeRatioThreshold(
			OwningAbility,
			AttributeNumerator,
			AttributeDenominator,
			ComparisonType,
			ComparisonValue,
			bTriggerOnce,
			ExternalOwner
		);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_WaitAttributeChangeThreshold* WaitForAttributeChangeThreshold(
		UGameplayAbility* OwningAbility,
		const FGameplayAttribute& Attribute,
		const TEnumAsByte<EWaitAttributeChangeComparison::Type> ComparisonType,
		const float ComparisonValue,
		const bool bTriggerOnce = true,
		AActor* ExternalOwner = nullptr
	)
	{
		return UAbilityTask_WaitAttributeChangeThreshold::WaitForAttributeChangeThreshold(
			OwningAbility,
			Attribute,
			ComparisonType,
			ComparisonValue,
			bTriggerOnce,
			ExternalOwner
		);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_WaitCancel* WaitForCancelInput(UGameplayAbility* OwningAbility)
	{
		return UAbilityTask_WaitCancel::WaitCancel(OwningAbility);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_WaitConfirm* WaitForConfirmInput(UGameplayAbility* OwningAbility)
	{
		return UAbilityTask_WaitConfirm::WaitConfirm(OwningAbility);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_WaitConfirmCancel* WaitConfirmCancel(UGameplayAbility* OwningAbility)
	{
		return UAbilityTask_WaitConfirmCancel::WaitConfirmCancel(OwningAbility);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_WaitDelay* WaitDelay(UGameplayAbility* OwningAbility, const float Time)
	{
		return UAbilityTask_WaitDelay::WaitDelay(OwningAbility, Time);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_WaitGameplayEffectApplied_Self* WaitGameplayEffectAppliedToSelf(
		UGameplayAbility* OwningAbility,
		const FGameplayTargetDataFilterHandle& Filter,
		const FGameplayTagRequirements& SourceTagRequirements,
		const FGameplayTagRequirements& TargetTagRequirements,
		const bool bTriggerOnce = false,
		AActor* ExternalOwner = nullptr,
		const bool bListenForPeriodicEffect = false
	)
	{
		return UAbilityTask_WaitGameplayEffectApplied_Self::WaitGameplayEffectAppliedToSelf(
			OwningAbility,
			Filter,
			SourceTagRequirements,
			TargetTagRequirements,
			FGameplayTagRequirements(),
			FGameplayTagRequirements(),
			bTriggerOnce,
			ExternalOwner,
			bListenForPeriodicEffect
		);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_WaitGameplayEffectApplied_Self* WaitGameplayEffectAppliedToSelfQuery(
		UGameplayAbility* OwningAbility,
		const FGameplayTargetDataFilterHandle& Filter,
		const FGameplayTagQuery& SourceTagQuery,
		const FGameplayTagQuery& TargetTagQuery,
		const bool bTriggerOnce = false,
		AActor* ExternalOwner = nullptr,
		const bool bListenForPeriodicEffect = false
	)
	{
		return UAbilityTask_WaitGameplayEffectApplied_Self::WaitGameplayEffectAppliedToSelf_Query(
			OwningAbility,
			Filter,
			SourceTagQuery,
			TargetTagQuery,
			FGameplayTagQuery(),
			FGameplayTagQuery(),
			bTriggerOnce,
			ExternalOwner,
			bListenForPeriodicEffect
		);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_WaitGameplayEffectApplied_Target* WaitGameplayEffectAppliedToTarget(
		UGameplayAbility* OwningAbility,
		const FGameplayTargetDataFilterHandle& Filter,
		const FGameplayTagRequirements& SourceTagRequirements,
		const FGameplayTagRequirements& TargetTagRequirements,
		const bool bTriggerOnce = false,
		AActor* ExternalOwner = nullptr,
		const bool bListenForPeriodicEffect = false
	)
	{
		return UAbilityTask_WaitGameplayEffectApplied_Target::WaitGameplayEffectAppliedToTarget(
			OwningAbility,
			Filter,
			SourceTagRequirements,
			TargetTagRequirements,
			FGameplayTagRequirements(),
			FGameplayTagRequirements(),
			bTriggerOnce,
			ExternalOwner,
			bListenForPeriodicEffect
		);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_WaitGameplayEffectApplied_Target* WaitGameplayEffectAppliedToTargetQuery(
		UGameplayAbility* OwningAbility,
		const FGameplayTargetDataFilterHandle& Filter,
		const FGameplayTagQuery& SourceTagQuery,
		const FGameplayTagQuery& TargetTagQuery,
		const bool bTriggerOnce = false,
		AActor* ExternalOwner = nullptr,
		const bool bListenForPeriodicEffect = false
	)
	{
		return UAbilityTask_WaitGameplayEffectApplied_Target::WaitGameplayEffectAppliedToTarget_Query(
			OwningAbility,
			Filter,
			SourceTagQuery,
			TargetTagQuery,
			FGameplayTagQuery(),
			FGameplayTagQuery(),
			bTriggerOnce,
			ExternalOwner,
			bListenForPeriodicEffect
		);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_WaitGameplayEffectBlockedImmunity* WaitGameplayEffectBlockedByImmunity(
		UGameplayAbility* OwningAbility,
		const FGameplayTagRequirements& SourceTagRequirements,
		const FGameplayTagRequirements& TargetTagRequirements,
		AActor* ExternalTarget = nullptr,
		const bool bTriggerOnce = false
	)
	{
		return UAbilityTask_WaitGameplayEffectBlockedImmunity::WaitGameplayEffectBlockedByImmunity(
			OwningAbility,
			SourceTagRequirements,
			TargetTagRequirements,
			ExternalTarget,
			bTriggerOnce
		);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_WaitGameplayEffectRemoved* WaitForGameplayEffectRemoved(UGameplayAbility* OwningAbility, const FActiveGameplayEffectHandle Handle)
	{
		return UAbilityTask_WaitGameplayEffectRemoved::WaitForGameplayEffectRemoved(OwningAbility, Handle);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_WaitGameplayEffectStackChange* WaitForGameplayEffectStackChange(UGameplayAbility* OwningAbility, const FActiveGameplayEffectHandle Handle)
	{
		return UAbilityTask_WaitGameplayEffectStackChange::WaitForGameplayEffectStackChange(OwningAbility, Handle);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_WaitGameplayEvent* WaitGameplayEvent(
		UGameplayAbility* OwningAbility,
		const FGameplayTag Tag,
		AActor* ExternalTarget = nullptr,
		const bool bTriggerOnce = false,
		const bool bMatchExact = true
	)
	{
		return UAbilityTask_WaitGameplayEvent::WaitGameplayEvent(
			OwningAbility,
			Tag,
			ExternalTarget,
			bTriggerOnce,
			bMatchExact
		);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_WaitGameplayTagAdded* WaitGameplayTagAdd(
		UGameplayAbility* OwningAbility,
		const FGameplayTag Tag,
		AActor* ExternalTarget = nullptr,
		const bool bTriggerOnce = false
	)
	{
		return UAbilityTask_WaitGameplayTagAdded::WaitGameplayTagAdd(
			OwningAbility,
			Tag,
			ExternalTarget,
			bTriggerOnce
		);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_WaitGameplayTagRemoved* WaitGameplayTagRemove(
		UGameplayAbility* OwningAbility,
		const FGameplayTag Tag,
		AActor* ExternalTarget = nullptr,
		const bool bTriggerOnce = false
	)
	{
		return UAbilityTask_WaitGameplayTagRemoved::WaitGameplayTagRemove(
			OwningAbility,
			Tag,
			ExternalTarget,
			bTriggerOnce
		);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_WaitGameplayTagQuery* WaitGameplayTagQuery(
		UGameplayAbility* OwningAbility,
		const FGameplayTagQuery& Query,
		const AActor* ExternalTarget = nullptr,
		const EWaitGameplayTagQueryTriggerCondition TriggerCondition = EWaitGameplayTagQueryTriggerCondition::WhenTrue,
		const bool bTriggerOnce = false
	)
	{
		return UAbilityTask_WaitGameplayTagQuery::WaitGameplayTagQuery(
			OwningAbility,
			Query,
			ExternalTarget,
			TriggerCondition,
			bTriggerOnce
		);
	}
	
	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_WaitInputPress* WaitInputPress(UGameplayAbility* OwningAbility, const bool bTestAlreadyPressed = false)
	{
		return UAbilityTask_WaitInputPress::WaitInputPress(OwningAbility, bTestAlreadyPressed);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_WaitInputRelease* WaitInputRelease(UGameplayAbility* OwningAbility, const bool bTestAlreadyReleased = false)
	{
		return UAbilityTask_WaitInputRelease::WaitInputRelease(OwningAbility, bTestAlreadyReleased);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_WaitMovementModeChange* WaitMovementModeChange(UGameplayAbility* OwningAbility, const EMovementMode NewMode)
	{
		return UAbilityTask_WaitMovementModeChange::CreateWaitMovementModeChange(OwningAbility, NewMode);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_WaitOverlap* WaitForOverlap(UGameplayAbility* OwningAbility)
	{
		return UAbilityTask_WaitOverlap::WaitForOverlap(OwningAbility);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_WaitTargetData* WaitTargetData(
		UGameplayAbility* OwningAbility,
		const FName TaskInstanceName,
		const TEnumAsByte<EGameplayTargetingConfirmation::Type> ConfirmationType,
		const TSubclassOf<AGameplayAbilityTargetActor> TargetClass
	)
	{
		return UAbilityTask_WaitTargetData::WaitTargetData(
			OwningAbility,
			TaskInstanceName,
			ConfirmationType,
			TargetClass
		);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_WaitTargetData* WaitTargetDataUsingActor(
		UGameplayAbility* OwningAbility,
		const FName TaskInstanceName,
		const TEnumAsByte<EGameplayTargetingConfirmation::Type> ConfirmationType,
		AGameplayAbilityTargetActor* TargetActor
	)
	{
		return UAbilityTask_WaitTargetData::WaitTargetDataUsingActor(
			OwningAbility,
			TaskInstanceName,
			ConfirmationType,
			TargetActor
		);
	}

	UFUNCTION(BlueprintCallable, Category = "Ability|Tasks")
	static UAbilityTask_WaitVelocityChange* WaitVelocityChange(UGameplayAbility* OwningAbility, const FVector& Direction, const float MinimumMagnitude)
	{
		return UAbilityTask_WaitVelocityChange::CreateWaitVelocityChange(OwningAbility, Direction, MinimumMagnitude);
	}
};
