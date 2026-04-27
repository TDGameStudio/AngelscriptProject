#include "AngelscriptGASAbility.h"
#include "GameplayCueNotify_Actor.h"
#include "GameplayCueNotify_Static.h"
#include "ClassGenerator/ASClass.h"

UAngelscriptGASAbility::UAngelscriptGASAbility(const FObjectInitializer& ObjectInitializer /*= FObjectInitializer::Get()*/) : Super(ObjectInitializer)
{
	auto ImplementedInAS = [](const UFunction* Func) -> bool {
		return Func && ensure(Func->GetOuter()) && Func->GetOuter()->IsA(UASClass::StaticClass());
	};

	if (!bHasBlueprintShouldAbilityRespondToEvent)
	{
		static FName FuncName = FName(TEXT("K2_ShouldAbilityRespondToEvent"));
		UFunction* ShouldRespondFunction = GetClass()->FindFunctionByName(FuncName);
		bHasBlueprintShouldAbilityRespondToEvent = ImplementedInAS(ShouldRespondFunction);
	}
	if (!bHasBlueprintCanUse)
	{
		static FName FuncName = FName(TEXT("K2_CanActivateAbility"));
		UFunction* CanActivateFunction = GetClass()->FindFunctionByName(FuncName);
		bHasBlueprintCanUse = ImplementedInAS(CanActivateFunction);
	}
	if (!bHasBlueprintActivate)
	{
		static FName FuncName = FName(TEXT("K2_ActivateAbility"));
		UFunction* ActivateFunction = GetClass()->FindFunctionByName(FuncName);
		// Apparently this check was done to deal with a crash. If they remove this check in GameplayAbilities then remove it here as well
		if (ActivateFunction && (HasAnyFlags(RF_ClassDefaultObject) || ActivateFunction->IsValidLowLevelFast()))
		{
			bHasBlueprintActivate = ImplementedInAS(ActivateFunction);
		}
	}
	if (!bHasBlueprintActivateFromEvent)
	{
		static FName FuncName = FName(TEXT("K2_ActivateAbilityFromEvent"));
		UFunction* ActivateFunction = GetClass()->FindFunctionByName(FuncName);
		bHasBlueprintActivateFromEvent = ImplementedInAS(ActivateFunction);
	}
}

void UAngelscriptGASAbility::K2_ExecuteGameplayCue_Actor(TSubclassOf<AGameplayCueNotify_Actor> GameplayCue, FGameplayEffectContextHandle Context)
{
	ensureMsgf(GameplayCue != nullptr, TEXT("Please provide a valid GameplayCue to K2_ExecuteGameplayCue_Actor()"));

	if (GameplayCue)
	{
		K2_ExecuteGameplayCue(GameplayCue.GetDefaultObject()->GameplayCueTag, Context);
	}
}

void UAngelscriptGASAbility::K2_ExecuteGameplayCueWithParams_Actor(TSubclassOf<AGameplayCueNotify_Actor> GameplayCue, const FGameplayCueParameters& GameplayCueParameters)
{
	ensureMsgf(GameplayCue != nullptr, TEXT("Please provide a valid GameplayCue to K2_ExecuteGameplayCueWithParams_Actor()"));

	if (GameplayCue)
	{
		K2_ExecuteGameplayCueWithParams(GameplayCue.GetDefaultObject()->GameplayCueTag, GameplayCueParameters);
	}
}

void UAngelscriptGASAbility::K2_AddGameplayCue_Actor(TSubclassOf<AGameplayCueNotify_Actor> GameplayCue, FGameplayEffectContextHandle Context, bool bRemoveOnAbilityEnd)
{
	ensureMsgf(GameplayCue != nullptr, TEXT("Please provide a valid GameplayCue to K2_AddGameplayCue_Actor()"));

	if (GameplayCue)
	{
		K2_AddGameplayCue(GameplayCue.GetDefaultObject()->GameplayCueTag, Context, bRemoveOnAbilityEnd);
	}
}

void UAngelscriptGASAbility::K2_AddGameplayCueWithParams_Actor(TSubclassOf<AGameplayCueNotify_Actor> GameplayCue, const FGameplayCueParameters& GameplayCueParameter, bool bRemoveOnAbilityEnd)
{
	ensureMsgf(GameplayCue != nullptr, TEXT("Please provide a valid GameplayCue to K2_AddGameplayCueWithParams_Actor()"));

	if (GameplayCue)
	{
		K2_AddGameplayCueWithParams(GameplayCue.GetDefaultObject()->GameplayCueTag, GameplayCueParameter, bRemoveOnAbilityEnd);
	}
}

void UAngelscriptGASAbility::K2_RemoveGameplayCue_Actor(TSubclassOf<AGameplayCueNotify_Actor> GameplayCue)
{
	ensureMsgf(GameplayCue != nullptr, TEXT("Please provide a valid GameplayCue to K2_RemoveGameplayCue_Actor()"));

	if (GameplayCue)
	{
		K2_RemoveGameplayCue(GameplayCue.GetDefaultObject()->GameplayCueTag);
	}
}

//////////////////////////////////////////////////////////////////////////////

void UAngelscriptGASAbility::K2_ExecuteGameplayCue_Static(TSubclassOf<UGameplayCueNotify_Static> GameplayCue, FGameplayEffectContextHandle Context)
{
	ensureMsgf(GameplayCue != nullptr, TEXT("Please provide a valid GameplayCue to K2_ExecuteGameplayCue_Static()"));

	if (GameplayCue)
	{
		K2_ExecuteGameplayCue(GameplayCue.GetDefaultObject()->GameplayCueTag, Context);
	}
}

void UAngelscriptGASAbility::K2_ExecuteGameplayCueWithParams_Static(TSubclassOf<UGameplayCueNotify_Static> GameplayCue, const FGameplayCueParameters& GameplayCueParameters)
{
	ensureMsgf(GameplayCue != nullptr, TEXT("Please provide a valid GameplayCue to K2_ExecuteGameplayCueWithParams_Static()"));

	if (GameplayCue)
	{
		K2_ExecuteGameplayCueWithParams(GameplayCue.GetDefaultObject()->GameplayCueTag, GameplayCueParameters);
	}
}

void UAngelscriptGASAbility::K2_AddGameplayCue_Static(TSubclassOf<UGameplayCueNotify_Static> GameplayCue, FGameplayEffectContextHandle Context, bool bRemoveOnAbilityEnd)
{
	ensureMsgf(GameplayCue != nullptr, TEXT("Please provide a valid GameplayCue to K2_AddGameplayCue_Static()"));

	if (GameplayCue)
	{
		K2_AddGameplayCue(GameplayCue.GetDefaultObject()->GameplayCueTag, Context, bRemoveOnAbilityEnd);
	}
}

void UAngelscriptGASAbility::K2_AddGameplayCueWithParams_Static(TSubclassOf<UGameplayCueNotify_Static> GameplayCue, const FGameplayCueParameters& GameplayCueParameter, bool bRemoveOnAbilityEnd)
{
	ensureMsgf(GameplayCue != nullptr, TEXT("Please provide a valid GameplayCue to K2_AddGameplayCueWithParams_Static()"));

	if (GameplayCue)
	{
		K2_AddGameplayCueWithParams(GameplayCue.GetDefaultObject()->GameplayCueTag, GameplayCueParameter, bRemoveOnAbilityEnd);
	}
}

void UAngelscriptGASAbility::K2_RemoveGameplayCue_Static(TSubclassOf<UGameplayCueNotify_Static> GameplayCue)
{
	ensureMsgf(GameplayCue != nullptr, TEXT("Please provide a valid GameplayCue to K2_RemoveGameplayCue_Static()"));

	if (GameplayCue)
	{
		K2_RemoveGameplayCue(GameplayCue.GetDefaultObject()->GameplayCueTag);
	}
}

