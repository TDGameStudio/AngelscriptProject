#include "Misc/AutomationTest.h"

#include "Shared/AngelscriptTestEngineHelper.h"
#include "Shared/AngelscriptTestMacros.h"
#include "StaticJIT/PrecompiledData.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_StaticJIT_AngelscriptPrecompiledDataArchiveTests_Private
{
	constexpr TCHAR SourceFilename[] = TEXT("PrecompiledDataBuildIdentifierValidation.as");
	const FName ModuleName(TEXT("ASPrecompiledDataBuildIdentifierValidation"));

	FString MakeScriptSource()
	{
		return
			TEXT("int Add(int Left, int Right)\n")
			TEXT("{\n")
			TEXT("    return Left + Right;\n")
			TEXT("}\n")
			TEXT("\n")
			TEXT("int Entry()\n")
			TEXT("{\n")
			TEXT("    return Add(20, 22);\n")
			TEXT("}\n");
	}

	FString DescribeSavedModuleNames(const FAngelscriptPrecompiledData& Data)
	{
		TArray<FString> ModuleNames;
		Data.Modules.GetKeys(ModuleNames);
		ModuleNames.Sort();
		return FString::Join(ModuleNames, TEXT(", "));
	}

	FString GuidToString(const FGuid& Guid)
	{
		return Guid.ToString(EGuidFormats::DigitsWithHyphensLower);
	}

	int32 MakeInvalidBuildIdentifier(int32 CurrentBuildIdentifier)
	{
		if (CurrentBuildIdentifier == -1)
		{
			return 1;
		}

		return CurrentBuildIdentifier + 100;
	}

	bool ValidateRoundtripSnapshot(
		FAutomationTestBase& Test,
		const FAngelscriptPrecompiledData& Snapshot,
		FAngelscriptPrecompiledData& Loaded,
		const FString& ExpectedModuleName)
	{
		const bool bGuidMatches = Test.TestEqual(
			TEXT("StaticJIT.PrecompiledData.BuildIdentifierValidation should preserve DataGuid across Save/Load"),
			GuidToString(Loaded.DataGuid),
			GuidToString(Snapshot.DataGuid));
		const bool bBuildIdentifierMatches = Test.TestEqual(
			TEXT("StaticJIT.PrecompiledData.BuildIdentifierValidation should preserve BuildIdentifier across Save/Load"),
			Loaded.BuildIdentifier,
			Snapshot.BuildIdentifier);
		const bool bModuleCountMatches = Test.TestEqual(
			TEXT("StaticJIT.PrecompiledData.BuildIdentifierValidation should preserve the module count across Save/Load"),
			Loaded.Modules.Num(),
			Snapshot.Modules.Num());
		const bool bModuleKeyExists = Test.TestTrue(
			TEXT("StaticJIT.PrecompiledData.BuildIdentifierValidation should retain the compiled module in the loaded archive"),
			Loaded.Modules.Contains(ExpectedModuleName));

		if (!bModuleKeyExists)
		{
			Test.AddInfo(FString::Printf(TEXT("Observed loaded precompiled modules: [%s]"), *DescribeSavedModuleNames(Loaded)));
		}

		const bool bStillValid = Test.TestTrue(
			TEXT("StaticJIT.PrecompiledData.BuildIdentifierValidation should accept the freshly loaded archive for the current build"),
			Loaded.IsValidForCurrentBuild());
		return bGuidMatches && bBuildIdentifierMatches && bModuleCountMatches && bModuleKeyExists && bStillValid;
	}

	bool SimulateEngineStartupDiscard(
		FAutomationTestBase& Test,
		TUniquePtr<FAngelscriptPrecompiledData>& PrecompiledData)
	{
		const bool bPointerWasLiveBeforeDiscard = Test.TestNotNull(
			TEXT("StaticJIT.PrecompiledData.BuildIdentifierValidation should still hold a loaded cache pointer before the discard branch"),
			PrecompiledData.Get());
		if (!bPointerWasLiveBeforeDiscard)
		{
			return false;
		}

		if (!PrecompiledData->IsValidForCurrentBuild())
		{
			PrecompiledData.Reset();
		}

		return Test.TestNull(
			TEXT("StaticJIT.PrecompiledData.BuildIdentifierValidation should discard the stale cache before later precompiled-data use"),
			PrecompiledData.Get());
	}
}

using namespace AngelscriptTest_StaticJIT_AngelscriptPrecompiledDataArchiveTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPrecompiledDataBuildIdentifierValidationTest,
	"Angelscript.TestModule.StaticJIT.PrecompiledData.BuildIdentifierValidation",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPrecompiledDataBuildIdentifierValidationTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_FULL();
	ASTEST_BEGIN_FULL

	do
	{
		const FString ScriptSource = MakeScriptSource();
		const bool bCompiled = AngelscriptTestSupport::CompileModuleFromMemory(
			&Engine,
			ModuleName,
			SourceFilename,
			ScriptSource);
		if (!TestTrue(TEXT("StaticJIT.PrecompiledData.BuildIdentifierValidation should compile the archive fixture module"), bCompiled))
		{
			break;
		}

		FAngelscriptPrecompiledData Snapshot(Engine.GetScriptEngine());
		Snapshot.InitFromActiveScript();

		const FString ModuleNameString = ModuleName.ToString();
		if (!TestEqual(
				TEXT("StaticJIT.PrecompiledData.BuildIdentifierValidation should stamp the snapshot with the current build identifier"),
				Snapshot.BuildIdentifier,
				Snapshot.GetCurrentBuildIdentifier())
			|| !TestTrue(
				TEXT("StaticJIT.PrecompiledData.BuildIdentifierValidation should serialize the newly compiled module into the snapshot"),
				Snapshot.Modules.Contains(ModuleNameString)))
		{
			AddInfo(FString::Printf(TEXT("Observed saved precompiled modules: [%s]"), *DescribeSavedModuleNames(Snapshot)));
			break;
		}

		AngelscriptTestSupport::FScopedTempPrecompiledCacheFile CacheFile(TEXT("PrecompiledDataBuildIdentifierValidation"));
		TUniquePtr<FAngelscriptPrecompiledData> LoadedData;
		FString SaveAndReloadError;
		const bool bRoundtripped = AngelscriptTestSupport::SaveAndReloadPrecompiledData(
			&Engine,
			Snapshot,
			CacheFile.GetFilename(),
			LoadedData,
			&SaveAndReloadError);
		if (!TestTrue(TEXT("StaticJIT.PrecompiledData.BuildIdentifierValidation should roundtrip the archive through Save/Load"), bRoundtripped))
		{
			if (!SaveAndReloadError.IsEmpty())
			{
				AddError(SaveAndReloadError);
			}
			break;
		}

		if (!TestNotNull(TEXT("StaticJIT.PrecompiledData.BuildIdentifierValidation should load a new precompiled data instance from disk"), LoadedData.Get()))
		{
			break;
		}

		if (!ValidateRoundtripSnapshot(*this, Snapshot, *LoadedData, ModuleNameString))
		{
			break;
		}

		const int32 CurrentBuildIdentifier = LoadedData->GetCurrentBuildIdentifier();
		if (!TestTrue(
				TEXT("StaticJIT.PrecompiledData.BuildIdentifierValidation should run in a known UE build configuration"),
				CurrentBuildIdentifier != -1))
		{
			break;
		}

		LoadedData->BuildIdentifier = MakeInvalidBuildIdentifier(CurrentBuildIdentifier);
		if (!TestFalse(
				TEXT("StaticJIT.PrecompiledData.BuildIdentifierValidation should reject archives whose BuildIdentifier no longer matches the active build"),
				LoadedData->IsValidForCurrentBuild()))
		{
			break;
		}

		if (!SimulateEngineStartupDiscard(*this, LoadedData))
		{
			break;
		}

		bPassed = true;
	}
	while (false);

	ASTEST_END_FULL
	return bPassed;
}

#endif
