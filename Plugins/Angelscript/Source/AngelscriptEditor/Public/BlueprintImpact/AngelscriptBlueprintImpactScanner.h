#pragma once

#include "AssetRegistry/AssetData.h"
#include "AssetRegistry/IAssetRegistry.h"
#include "CoreMinimal.h"

#include "Engine/Blueprint.h"

#include "Core/AngelscriptEngine.h"

namespace AngelscriptEditor::BlueprintImpact
{
	enum class EBlueprintImpactReason : uint8
	{
		ScriptParentClass,
		NodeDependency,
		PinType,
		VariableType,
		DelegateSignature,
		ReferencedAsset,
	};

	struct FBlueprintImpactSymbols
	{
		TSet<UClass*> Classes;
		TSet<UScriptStruct*> Structs;
		TSet<UEnum*> Enums;
		TSet<UDelegateFunction*> Delegates;
		TMap<UObject*, UObject*> ReplacementObjects;

		bool IsEmpty() const;
	};

	struct FBlueprintImpactRequest
	{
		TArray<FString> ChangedScripts;
		bool bIncludeOnlyOnDiskAssets = true;

		bool IsFullScan() const
		{
			return ChangedScripts.IsEmpty();
		}
	};

	struct FBlueprintImpactMatch
	{
		TWeakObjectPtr<UBlueprint> Blueprint;
		FAssetData AssetData;
		TArray<EBlueprintImpactReason> Reasons;
	};

	struct FBlueprintImpactScanResult
	{
		TArray<FString> NormalizedChangedScripts;
		TArray<TSharedRef<FAngelscriptModuleDesc>> MatchingModules;
		FBlueprintImpactSymbols Symbols;
		TArray<FAssetData> CandidateAssets;
		TArray<FBlueprintImpactMatch> Matches;
		int32 FailedAssetLoads = 0;
	};

	ANGELSCRIPTEDITOR_API TArray<FString> NormalizeChangedScriptPaths(const TArray<FString>& ChangedScripts);
	ANGELSCRIPTEDITOR_API TArray<TSharedRef<FAngelscriptModuleDesc>> FindModulesForChangedScripts(const TArray<TSharedRef<FAngelscriptModuleDesc>>& Modules, const TArray<FString>& ChangedScripts);
	ANGELSCRIPTEDITOR_API FBlueprintImpactSymbols BuildImpactSymbols(const TArray<TSharedRef<FAngelscriptModuleDesc>>& Modules);
	ANGELSCRIPTEDITOR_API bool AnalyzeLoadedBlueprint(UBlueprint& Blueprint, const FBlueprintImpactSymbols& Symbols, TArray<EBlueprintImpactReason>& OutReasons);
	ANGELSCRIPTEDITOR_API TArray<FAssetData> FindBlueprintAssets(IAssetRegistry& AssetRegistry, bool bIncludeOnlyOnDiskAssets);
	ANGELSCRIPTEDITOR_API FBlueprintImpactScanResult ScanBlueprintAssets(const FAngelscriptEngine& Engine, IAssetRegistry& AssetRegistry, const FBlueprintImpactRequest& Request);
	ANGELSCRIPTEDITOR_API const TCHAR* LexToString(EBlueprintImpactReason Reason);

#if WITH_DEV_AUTOMATION_TESTS
	ANGELSCRIPTEDITOR_API void SetBlueprintAssetsOverrideForTesting(TArray<FAssetData> InAssets);
	ANGELSCRIPTEDITOR_API void ClearBlueprintAssetsOverrideForTesting();
#endif
}
