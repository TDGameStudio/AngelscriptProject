#include "BlueprintImpact/AngelscriptBlueprintImpactScanCommandlet.h"

#include "BlueprintImpact/AngelscriptBlueprintImpactScanner.h"

#include "AssetRegistry/AssetRegistryModule.h"
#include "Core/AngelscriptEngine.h"
#include "Misc/FileHelper.h"
#include "Misc/Parse.h"

namespace
{
	const TCHAR* const BlueprintImpactCommandletParamKeys[] = {
		TEXT("ChangedScript="),
		TEXT("ChangedScriptFile=")
	};

	bool TryExtractCommandletParamValue(const FString& Params, const FString& Key, FString& OutValue)
	{
		const int32 KeyIndex = Params.Find(Key, ESearchCase::IgnoreCase);
		if (KeyIndex == INDEX_NONE)
		{
			return false;
		}

		const int32 ValueStart = KeyIndex + Key.Len();
		int32 ValueEnd = Params.Len();
		for (int32 Index = ValueStart; Index < Params.Len(); ++Index)
		{
			if (!FChar::IsWhitespace(Params[Index]))
			{
				continue;
			}

			const int32 CandidateStart = Index + 1;
			for (const TCHAR* CandidateKey : BlueprintImpactCommandletParamKeys)
			{
				if (Params.Mid(CandidateStart, FCString::Strlen(CandidateKey)).Equals(CandidateKey, ESearchCase::IgnoreCase))
				{
					ValueEnd = Index;
					Index = Params.Len();
					break;
				}
			}
		}

		OutValue = Params.Mid(ValueStart, ValueEnd - ValueStart).TrimStartAndEnd();
		if (OutValue.StartsWith(TEXT("\"")) && OutValue.EndsWith(TEXT("\"")) && OutValue.Len() >= 2)
		{
			OutValue = OutValue.Mid(1, OutValue.Len() - 2);
		}

		return true;
	}

	enum class EBlueprintImpactCommandletExitCode : int32
	{
		Success = 0,
		InvalidArguments = 1,
		EngineNotReady = 2,
		AssetScanFailure = 3,
	};

	void AppendChangedScriptsFromDelimitedValue(const FString& Value, TArray<FString>& OutScripts)
	{
		const TCHAR* const Delimiters[] = {
			TEXT(","),
			TEXT(";")
		};

		TArray<FString> Parts;
		Value.ParseIntoArray(Parts, Delimiters, UE_ARRAY_COUNT(Delimiters), true);
		for (const FString& Part : Parts)
		{
			const FString Trimmed = Part.TrimStartAndEnd();
			if (!Trimmed.IsEmpty())
			{
				OutScripts.Add(Trimmed);
			}
		}
	}

	bool TryReadChangedScriptsFile(const FString& FilePath, TArray<FString>& OutScripts)
	{
		TArray<FString> Lines;
		if (!FFileHelper::LoadFileToStringArray(Lines, *FilePath))
		{
			return false;
		}

		for (const FString& Line : Lines)
		{
			const FString Trimmed = Line.TrimStartAndEnd();
			if (!Trimmed.IsEmpty())
			{
				OutScripts.Add(Trimmed);
			}
		}

		return true;
	}

	bool TryBuildBlueprintImpactRequest(
		const FString& Params,
		AngelscriptEditor::BlueprintImpact::FBlueprintImpactRequest& OutRequest,
		FString* OutErrorMessage)
	{
		FString ChangedScriptsValue;
		if (TryExtractCommandletParamValue(Params, TEXT("ChangedScript="), ChangedScriptsValue))
		{
			AppendChangedScriptsFromDelimitedValue(ChangedScriptsValue, OutRequest.ChangedScripts);
		}

		FString ChangedScriptsFile;
		if (TryExtractCommandletParamValue(Params, TEXT("ChangedScriptFile="), ChangedScriptsFile))
		{
			if (!TryReadChangedScriptsFile(ChangedScriptsFile, OutRequest.ChangedScripts))
			{
				if (OutErrorMessage != nullptr)
				{
					*OutErrorMessage = ChangedScriptsFile;
				}
				return false;
			}
		}

		return true;
	}
}

int32 UAngelscriptBlueprintImpactScanCommandlet::Main(const FString& Params)
{
	if (!FAngelscriptEngine::Get().bDidInitialCompileSucceed)
	{
		UE_LOG(Angelscript, Error, TEXT("Blueprint impact commandlet requires a successfully initialized Angelscript engine."));
		return static_cast<int32>(EBlueprintImpactCommandletExitCode::EngineNotReady);
	}

	AngelscriptEditor::BlueprintImpact::FBlueprintImpactRequest Request;
	FString ChangedScriptsFileError;
	if (!TryBuildBlueprintImpactRequest(Params, Request, &ChangedScriptsFileError))
	{
		UE_LOG(Angelscript, Error, TEXT("Blueprint impact commandlet failed to read ChangedScriptFile: %s"), *ChangedScriptsFileError);
		return static_cast<int32>(EBlueprintImpactCommandletExitCode::InvalidArguments);
	}

	FAssetRegistryModule& AssetRegistryModule = FModuleManager::LoadModuleChecked<FAssetRegistryModule>(TEXT("AssetRegistry"));
	const AngelscriptEditor::BlueprintImpact::FBlueprintImpactScanResult ScanResult = AngelscriptEditor::BlueprintImpact::ScanBlueprintAssets(
		FAngelscriptEngine::Get(),
		AssetRegistryModule.Get(),
		Request);

	UE_LOG(
		Angelscript,
		Display,
		TEXT("{ \"BlueprintImpact\": { \"FullScan\": %s, \"ChangedScripts\": %d, \"MatchingModules\": %d, \"Classes\": %d, \"Structs\": %d, \"Enums\": %d, \"Delegates\": %d, \"CandidateAssets\": %d, \"Matches\": %d, \"FailedAssetLoads\": %d } }"),
		Request.IsFullScan() ? TEXT("true") : TEXT("false"),
		ScanResult.NormalizedChangedScripts.Num(),
		ScanResult.MatchingModules.Num(),
		ScanResult.Symbols.Classes.Num(),
		ScanResult.Symbols.Structs.Num(),
		ScanResult.Symbols.Enums.Num(),
		ScanResult.Symbols.Delegates.Num(),
		ScanResult.CandidateAssets.Num(),
		ScanResult.Matches.Num(),
		ScanResult.FailedAssetLoads);

	for (const AngelscriptEditor::BlueprintImpact::FBlueprintImpactMatch& Match : ScanResult.Matches)
	{
		TArray<FString> ReasonStrings;
		for (const AngelscriptEditor::BlueprintImpact::EBlueprintImpactReason Reason : Match.Reasons)
		{
			ReasonStrings.Add(AngelscriptEditor::BlueprintImpact::LexToString(Reason));
		}

		UE_LOG(
			Angelscript,
			Display,
			TEXT("[BlueprintImpact] %s | Reasons=%s"),
			*Match.AssetData.GetObjectPathString(),
			*FString::Join(ReasonStrings, TEXT(",")));
	}

	return ScanResult.FailedAssetLoads > 0
		? static_cast<int32>(EBlueprintImpactCommandletExitCode::AssetScanFailure)
		: static_cast<int32>(EBlueprintImpactCommandletExitCode::Success);
}

#if WITH_DEV_AUTOMATION_TESTS
bool UAngelscriptBlueprintImpactScanCommandlet::BuildRequestForTesting(
	const FString& Params,
	AngelscriptEditor::BlueprintImpact::FBlueprintImpactRequest& OutRequest,
	FString& OutErrorMessage)
{
	OutRequest = AngelscriptEditor::BlueprintImpact::FBlueprintImpactRequest();
	OutErrorMessage.Reset();
	return TryBuildBlueprintImpactRequest(Params, OutRequest, &OutErrorMessage);
}
#endif
