#pragma once

#include "CoreMinimal.h"

struct FAngelscriptSourceNavigationLocation
{
	FString Path;
	int32 LineNumber = INDEX_NONE;
};

namespace AngelscriptSourceNavigation
{
	using FOpenLocationOverride = TFunction<void(const FAngelscriptSourceNavigationLocation&)>;

	ANGELSCRIPTEDITOR_API bool NavigateToFunctionForTesting(const UFunction* InFunction);
	ANGELSCRIPTEDITOR_API bool NavigateToPropertyForTesting(const FProperty* InProperty);
	ANGELSCRIPTEDITOR_API bool NavigateToStructForTesting(const UStruct* InStruct);
	ANGELSCRIPTEDITOR_API void SetOpenLocationOverrideForTesting(FOpenLocationOverride InOverride);
	ANGELSCRIPTEDITOR_API void ResetOpenLocationOverrideForTesting();
}
