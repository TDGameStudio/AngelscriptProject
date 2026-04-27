#include "GAS/AngelscriptAbilityAsyncLibrary.h"
#include "AngelscriptBinds.h"

AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_AngelscriptGAS
(
	(int32)FAngelscriptBinds::EOrder::Late - 1,
	[]()
	{
		FAngelscriptBinds::AddFunctionEntry(UAngelscriptAbilityAsyncLibrary::StaticClass(), "WaitForAttributeChanged", { ERASE_FUNCTION_PTR(UAngelscriptAbilityAsyncLibrary::WaitForAttributeChanged, (AActor*, const FGameplayAttribute&, const bool), ERASE_ARGUMENT_PACK(UAbilityAsync_WaitAttributeChanged*)) });
		FAngelscriptBinds::AddFunctionEntry(UAngelscriptAbilityAsyncLibrary::StaticClass(), "WaitGameplayEventToActor", { ERASE_FUNCTION_PTR(UAngelscriptAbilityAsyncLibrary::WaitGameplayEventToActor, (AActor*, const FGameplayTag, const bool, const bool), ERASE_ARGUMENT_PACK(UAbilityAsync_WaitGameplayEvent*)) });
		FAngelscriptBinds::AddFunctionEntry(UAngelscriptAbilityAsyncLibrary::StaticClass(), "WaitGameplayTagAddToActor", { ERASE_FUNCTION_PTR(UAngelscriptAbilityAsyncLibrary::WaitGameplayTagAddToActor, (AActor*, const FGameplayTag, const bool), ERASE_ARGUMENT_PACK(UAbilityAsync_WaitGameplayTagAdded*)) });
		FAngelscriptBinds::AddFunctionEntry(UAngelscriptAbilityAsyncLibrary::StaticClass(), "WaitGameplayTagRemoveFromActor", { ERASE_FUNCTION_PTR(UAngelscriptAbilityAsyncLibrary::WaitGameplayTagRemoveFromActor, (AActor*, const FGameplayTag, const bool), ERASE_ARGUMENT_PACK(UAbilityAsync_WaitGameplayTagRemoved*)) });
		//FAngelscriptBinds::AddFunctionEntry(UAngelscriptAbilityAsyncLibrary::StaticClass(), "WaitForAttributeChanged", { ERASE_FUNCTION_PTR(UAngelscriptAbilityAsyncLibrary::WaitForAttributeChanged, (AActor*, const FGameplayAttribute&, const bool), ERASE_ARGUMENT_PACK(UAbilityAsync_WaitAttributeChanged*)) });
	}
);
