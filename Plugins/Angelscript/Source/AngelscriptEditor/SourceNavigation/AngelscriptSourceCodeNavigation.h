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

	ANGELSCRIPTEDITOR_API bool NavigateToFunction(const UFunction* InFunction);
	ANGELSCRIPTEDITOR_API bool NavigateToProperty(const FProperty* InProperty);
	ANGELSCRIPTEDITOR_API bool NavigateToStruct(const UStruct* InStruct);
	ANGELSCRIPTEDITOR_API FString BuildVSCodeOpenParameters(FString Params, const FString& VSCodeWorkspacePath, bool bOpenFolderOnVSCodeSourceLinks, const FString& ScriptRootDirectory);
	ANGELSCRIPTEDITOR_API bool NavigateToFunctionForTesting(const UFunction* InFunction);
	ANGELSCRIPTEDITOR_API bool NavigateToPropertyForTesting(const FProperty* InProperty);
	ANGELSCRIPTEDITOR_API bool NavigateToStructForTesting(const UStruct* InStruct);
	ANGELSCRIPTEDITOR_API void SetOpenLocationOverrideForTesting(FOpenLocationOverride InOverride);
	ANGELSCRIPTEDITOR_API void ResetOpenLocationOverrideForTesting();
	ANGELSCRIPTEDITOR_API FString BuildVSCodeOpenParametersForTesting(FString Params, const FString& VSCodeWorkspacePath, bool bOpenFolderOnVSCodeSourceLinks, const FString& ScriptRootDirectory);
}
