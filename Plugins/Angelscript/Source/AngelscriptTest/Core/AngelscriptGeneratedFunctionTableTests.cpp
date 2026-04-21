#include "../../AngelscriptRuntime/Core/AngelscriptBinds.h"
#include "AngelscriptEngine.h"
#include "Camera/PlayerCameraManager.h"
#include "GameFramework/Actor.h"
#include "Misc/FileHelper.h"
#include "Misc/AutomationTest.h"
#include "Misc/Paths.h"
#include "Misc/ScopeExit.h"
#include "Dom/JsonObject.h"
#include "Serialization/JsonReader.h"
#include "Serialization/JsonSerializer.h"
#include "HAL/FileManager.h"
#include "UObject/UObjectGlobals.h"
#include "UObject/Package.h"
#include "Shared/AngelscriptTestUtilities.h"

#if WITH_DEV_AUTOMATION_TESTS

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGeneratedFunctionTablePopulatesClassFuncMapsTest,
	"Angelscript.TestModule.Engine.GeneratedFunctionTable.PopulatesClassFuncMaps",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGeneratedFunctionTablePreservesHandwrittenGASEntriesTest,
	"Angelscript.TestModule.Engine.GeneratedFunctionTable.PreservesHandwrittenGASEntries",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGeneratedFunctionTableEditorOutputsUseWithEditorGuardTest,
	"Angelscript.TestModule.Engine.GeneratedFunctionTable.EditorOutputsUseWithEditorGuard",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGeneratedFunctionTableOutputsShardTimingHooksTest,
	"Angelscript.TestModule.Engine.GeneratedFunctionTable.OutputsShardTimingHooks",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGeneratedFunctionTableRepresentativeCoverageTest,
	"Angelscript.TestModule.Engine.GeneratedFunctionTable.RepresentativeCoverage",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGeneratedFunctionTableMinimalApiFunctionLevelExportTest,
	"Angelscript.TestModule.Engine.GeneratedFunctionTable.MinimalApiFunctionLevelExports",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGeneratedFunctionTableReflectiveFallbackStatsTest,
	"Angelscript.TestModule.Engine.GeneratedFunctionTable.ReflectiveFallbackStats",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGeneratedFunctionTableSummaryOutputTest,
	"Angelscript.TestModule.Engine.GeneratedFunctionTable.SummaryOutput",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGeneratedFunctionTableCsvOutputTest,
	"Angelscript.TestModule.Engine.GeneratedFunctionTable.CsvOutput",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGeneratedFunctionTableSkippedCsvOutputTest,
	"Angelscript.TestModule.Engine.GeneratedFunctionTable.SkippedCsvOutput",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGeneratedFunctionTableSkippedReasonSummaryCsvOutputTest,
	"Angelscript.TestModule.Engine.GeneratedFunctionTable.SkippedReasonSummaryCsvOutput",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGeneratedFunctionTableMacroQualifiedDirectBindingsTest,
	"Angelscript.TestModule.Engine.GeneratedFunctionTable.MacroQualifiedDirectBindings",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Core_AngelscriptGeneratedFunctionTableTests_Private
{
	int32 CountGeneratedBindingRegistrations(const FString& GeneratedDirectory)
	{
		TArray<FString> GeneratedFiles;
		IFileManager::Get().FindFilesRecursive(GeneratedFiles, *GeneratedDirectory, TEXT("AS_FunctionTable_*.cpp"), true, false);

		int32 RegistrationCount = 0;
		for (const FString& GeneratedFile : GeneratedFiles)
		{
			FString FileContents;
			if (!FFileHelper::LoadFileToString(FileContents, *GeneratedFile))
			{
				continue;
			}

			TArray<FString> Lines;
			FileContents.ParseIntoArrayLines(Lines);
			for (const FString& Line : Lines)
			{
				if (Line.Contains(TEXT("FAngelscriptBinds::AddFunctionEntry(")))
				{
					RegistrationCount++;
				}
			}
		}

		return RegistrationCount;
	}

	bool FindGeneratedBindingLine(const FString& GeneratedDirectory, const FString& FunctionName, FString& OutLine)
	{
		TArray<FString> GeneratedFiles;
		IFileManager::Get().FindFilesRecursive(GeneratedFiles, *GeneratedDirectory, TEXT("AS_FunctionTable_*.cpp"), true, false);

		for (const FString& GeneratedFile : GeneratedFiles)
		{
			FString FileContents;
			if (!FFileHelper::LoadFileToString(FileContents, *GeneratedFile))
			{
				continue;
			}

			TArray<FString> Lines;
			FileContents.ParseIntoArrayLines(Lines);
			for (const FString& Line : Lines)
			{
				if (Line.Contains(FunctionName))
				{
					OutLine = Line;
					return true;
				}
			}
		}

		return false;
	}

	TArray<FString> LoadNonEmptyFileLines(const FString& FilePath)
	{
		FString FileContents;
		if (!FFileHelper::LoadFileToString(FileContents, *FilePath))
		{
			return {};
		}

		TArray<FString> Lines;
		FileContents.ParseIntoArrayLines(Lines);
		Lines.RemoveAll([](const FString& Line)
		{
			return Line.TrimStartAndEnd().IsEmpty();
		});
		return Lines;
	}
}

using namespace AngelscriptTest_Core_AngelscriptGeneratedFunctionTableTests_Private;

bool FAngelscriptGeneratedFunctionTablePopulatesClassFuncMapsTest::RunTest(const FString& Parameters)
{
	if (!TestTrue(TEXT("Generated function table test requires the runtime engine to be initialized in editor automation"), FAngelscriptEngine::IsInitialized()))
	{
		return false;
	}

	FAngelscriptEngine& Engine = FAngelscriptEngine::Get();
	(void)Engine;

	const TMap<UClass*, TMap<FString, FFuncEntry>>& ClassFuncMaps = FAngelscriptBinds::GetClassFuncMaps();
	int32 TotalFunctionEntryCount = 0;
	for (const TPair<UClass*, TMap<FString, FFuncEntry>>& ClassEntry : ClassFuncMaps)
	{
		TotalFunctionEntryCount += ClassEntry.Value.Num();
	}

	if (!TestTrue(TEXT("Generated function table startup pass should populate many ClassFuncMaps entries beyond the legacy handwritten baseline"), TotalFunctionEntryCount > 1000))
	{
		return false;
	}

	const TMap<FString, FFuncEntry>* ActorFunctionMap = ClassFuncMaps.Find(AActor::StaticClass());
	if (!TestNotNull(TEXT("Generated function table startup pass should register an entry map for AActor"), ActorFunctionMap))
	{
		return false;
	}

	const FFuncEntry* ActorTimeDilationEntry = ActorFunctionMap->Find(TEXT("GetActorTimeDilation"));
	if (!TestNotNull(TEXT("Generated function table startup pass should register the generated AActor::GetActorTimeDilation entry"), ActorTimeDilationEntry))
	{
		return false;
	}

	bool bHasCallableActorEntry = false;
	for (const TPair<FString, FFuncEntry>& ActorEntry : *ActorFunctionMap)
	{
		FGenericFuncPtr ActorFuncPtr = ActorEntry.Value.FuncPtr;
		if (ActorFuncPtr.IsBound() || ActorEntry.Value.bReflectiveFallbackBound)
		{
			bHasCallableActorEntry = true;
			break;
		}
	}

	TestTrue(TEXT("Generated function table startup pass should leave at least one callable generated AActor entry in ClassFuncMaps"), bHasCallableActorEntry);
	return true;
}

bool FAngelscriptGeneratedFunctionTablePreservesHandwrittenGASEntriesTest::RunTest(const FString& Parameters)
{
	if (!TestTrue(TEXT("Generated GAS compatibility test requires the runtime engine to be initialized in editor automation"), FAngelscriptEngine::IsInitialized()))
	{
		return false;
	}

	UClass* AbilityAsyncLibraryClass = FindObject<UClass>(nullptr, TEXT("/Script/AngelscriptRuntime.AngelscriptAbilityAsyncLibrary"));
	if (!TestNotNull(TEXT("Generated GAS compatibility test should locate UAngelscriptAbilityAsyncLibrary"), AbilityAsyncLibraryClass))
	{
		return false;
	}

	const TMap<UClass*, TMap<FString, FFuncEntry>>& ClassFuncMaps = FAngelscriptBinds::GetClassFuncMaps();
	const TMap<FString, FFuncEntry>* AsyncLibraryFunctionMap = ClassFuncMaps.Find(AbilityAsyncLibraryClass);
	if (!TestNotNull(TEXT("Generated GAS compatibility test should expose the async ability helper class in ClassFuncMaps"), AsyncLibraryFunctionMap))
	{
		return false;
	}

	const FFuncEntry* WaitForAttributeChangedEntry = AsyncLibraryFunctionMap->Find(TEXT("WaitForAttributeChanged"));
	if (!TestNotNull(TEXT("Generated GAS compatibility test should keep the handwritten WaitForAttributeChanged function entry"), WaitForAttributeChangedEntry))
	{
		return false;
	}

	FGenericFuncPtr WaitForAttributeChangedPointer = WaitForAttributeChangedEntry->FuncPtr;
	if (!TestTrue(TEXT("Generated GAS compatibility test should preserve the handwritten direct-call pointer for WaitForAttributeChanged"), WaitForAttributeChangedPointer.IsBound()))
	{
		return false;
	}

	const FFuncEntry* WaitGameplayTagRemoveEntry = AsyncLibraryFunctionMap->Find(TEXT("WaitGameplayTagRemoveFromActor"));
	if (!TestNotNull(TEXT("Generated GAS compatibility test should expose WaitGameplayTagRemoveFromActor under its own key"), WaitGameplayTagRemoveEntry))
	{
		return false;
	}

	FGenericFuncPtr WaitGameplayTagRemovePointer = WaitGameplayTagRemoveEntry->FuncPtr;
	TestTrue(TEXT("Generated GAS compatibility test should keep WaitGameplayTagRemoveFromActor bound after handwritten registration"), WaitGameplayTagRemovePointer.IsBound());
	return true;
}

bool FAngelscriptGeneratedFunctionTableEditorOutputsUseWithEditorGuardTest::RunTest(const FString& Parameters)
{
	const FString GeneratedDirectory = FPaths::Combine(
		FPaths::ProjectPluginsDir(),
		TEXT("Angelscript"),
		TEXT("Intermediate/Build/Win64/UnrealEditor/Inc/AngelscriptRuntime/UHT"));

	const FString EditorOutputPath = FPaths::Combine(GeneratedDirectory, TEXT("AS_FunctionTable_UMGEditor_000.cpp"));
	const FString RuntimeOutputPath = FPaths::Combine(GeneratedDirectory, TEXT("AS_FunctionTable_Engine_000.cpp"));

	FString EditorOutput;
	if (!TestTrue(TEXT("Generated strategy test should find the editor-only UHT output"), FFileHelper::LoadFileToString(EditorOutput, *EditorOutputPath)))
	{
		return false;
	}

	FString RuntimeOutput;
	if (!TestTrue(TEXT("Generated strategy test should find the runtime UHT output"), FFileHelper::LoadFileToString(RuntimeOutput, *RuntimeOutputPath)))
	{
		return false;
	}

	TestTrue(TEXT("Generated strategy test should wrap editor-only outputs with #if WITH_EDITOR"), EditorOutput.StartsWith(TEXT("#if WITH_EDITOR")));
	TestFalse(TEXT("Generated strategy test should not wrap runtime outputs with #if WITH_EDITOR"), RuntimeOutput.StartsWith(TEXT("#if WITH_EDITOR")));
	return true;
}

bool FAngelscriptGeneratedFunctionTableOutputsShardTimingHooksTest::RunTest(const FString& Parameters)
{
	const FString GeneratedDirectory = FPaths::Combine(
		FPaths::ProjectPluginsDir(),
		TEXT("Angelscript"),
		TEXT("Intermediate/Build/Win64/UnrealEditor/Inc/AngelscriptRuntime/UHT"));
	const FString RuntimeOutputPath = FPaths::Combine(GeneratedDirectory, TEXT("AS_FunctionTable_Engine_000.cpp"));

	FString RuntimeOutput;
	if (!TestTrue(TEXT("Generated timing hook test should find the runtime UHT output"), FFileHelper::LoadFileToString(RuntimeOutput, *RuntimeOutputPath)))
	{
		return false;
	}

	TestTrue(
		TEXT("Generated timing hook test should emit the generated shard timing recorder call"),
		RuntimeOutput.Contains(TEXT("FAngelscriptBinds::RecordGeneratedFunctionTableShardTiming(")));
	return true;
}

bool FAngelscriptGeneratedFunctionTableRepresentativeCoverageTest::RunTest(const FString& Parameters)
{
	if (!TestTrue(TEXT("Generated representative coverage test requires the runtime engine to be initialized in editor automation"), FAngelscriptEngine::IsInitialized()))
	{
		return false;
	}

	const TMap<UClass*, TMap<FString, FFuncEntry>>& ClassFuncMaps = FAngelscriptBinds::GetClassFuncMaps();

	struct FRepresentativeClassExpectation
	{
		const TCHAR* ObjectPath;
		const TCHAR* DisplayName;
	};

	const FRepresentativeClassExpectation Expectations[] =
	{
		{ TEXT("/Script/Engine.Actor"), TEXT("AActor") },
		{ TEXT("/Script/Engine.World"), TEXT("UWorld") },
		{ TEXT("/Script/Engine.GameplayStatics"), TEXT("UGameplayStatics") },
		{ TEXT("/Script/Engine.PlayerController"), TEXT("APlayerController") },
		{ TEXT("/Script/Engine.ActorComponent"), TEXT("UActorComponent") },
		{ TEXT("/Script/Engine.SceneComponent"), TEXT("USceneComponent") },
		{ TEXT("/Script/Engine.KismetSystemLibrary"), TEXT("UKismetSystemLibrary") },
		{ TEXT("/Script/UMG.UserWidget"), TEXT("UUserWidget") },
		{ TEXT("/Script/AssetRegistry.AssetRegistryHelpers"), TEXT("UAssetRegistryHelpers") },
		{ TEXT("/Script/AngelscriptRuntime.AngelscriptAbilityAsyncLibrary"), TEXT("UAngelscriptAbilityAsyncLibrary") },
	};

	for (const FRepresentativeClassExpectation& Expectation : Expectations)
	{
		UClass* ExpectedClass = FindObject<UClass>(nullptr, Expectation.ObjectPath);
		if (!TestNotNull(FString::Printf(TEXT("Representative coverage test should resolve %s"), Expectation.DisplayName), ExpectedClass))
		{
			return false;
		}

		const TMap<FString, FFuncEntry>* FunctionMap = ClassFuncMaps.Find(ExpectedClass);
		if (!TestNotNull(FString::Printf(TEXT("Representative coverage test should populate ClassFuncMaps for %s"), Expectation.DisplayName), FunctionMap))
		{
			return false;
		}

		if (!TestTrue(FString::Printf(TEXT("Representative coverage test should add at least one generated function entry for %s"), Expectation.DisplayName), FunctionMap->Num() > 0))
		{
			return false;
		}
	}

	return true;
}

bool FAngelscriptGeneratedFunctionTableMinimalApiFunctionLevelExportTest::RunTest(const FString& Parameters)
{
	if (!TestTrue(TEXT("MinimalAPI function export regression test requires the runtime engine to be initialized in editor automation"), FAngelscriptEngine::IsInitialized()))
	{
		return false;
	}

	const TMap<UClass*, TMap<FString, FFuncEntry>>& ClassFuncMaps = FAngelscriptBinds::GetClassFuncMaps();
	const TMap<FString, FFuncEntry>* PlayerCameraManagerEntries = ClassFuncMaps.Find(APlayerCameraManager::StaticClass());
	if (!TestNotNull(TEXT("MinimalAPI function export regression test should expose generated entries for APlayerCameraManager"), PlayerCameraManagerEntries))
	{
		return false;
	}

	const TCHAR* ExpectedBoundFunctions[] =
	{
		TEXT("SetManualCameraFade"),
		TEXT("StartCameraFade"),
		TEXT("StopCameraFade"),
	};

	for (const TCHAR* ExpectedFunctionName : ExpectedBoundFunctions)
	{
		const FFuncEntry* Entry = PlayerCameraManagerEntries->Find(ExpectedFunctionName);
		if (!TestNotNull(FString::Printf(TEXT("MinimalAPI function export regression test should register %s"), ExpectedFunctionName), Entry))
		{
			return false;
		}

		FGenericFuncPtr FunctionPointer = Entry->FuncPtr;
		if (!TestTrue(FString::Printf(TEXT("MinimalAPI function export regression test should recover a direct-call pointer for %s"), ExpectedFunctionName), FunctionPointer.IsBound()))
		{
			return false;
		}
	}

	return true;
}

bool FAngelscriptGeneratedFunctionTableReflectiveFallbackStatsTest::RunTest(const FString& Parameters)
{
	if (!TestTrue(TEXT("Generated reflective fallback stats test requires the runtime engine to be initialized in editor automation"), FAngelscriptEngine::IsInitialized()))
	{
		return false;
	}

	const TMap<UClass*, TMap<FString, FFuncEntry>>& ClassFuncMaps = FAngelscriptBinds::GetClassFuncMaps();
	int32 DirectCount = 0;
	int32 ReflectiveCount = 0;
	int32 UnresolvedCount = 0;
	TMap<FString, int32> ReflectiveCountsByModule;

	for (const TPair<UClass*, TMap<FString, FFuncEntry>>& ClassEntry : ClassFuncMaps)
	{
		const FString PackageName = ClassEntry.Key != nullptr && ClassEntry.Key->GetOutermost() != nullptr
			? ClassEntry.Key->GetOutermost()->GetName()
			: FString();
		FString ModuleName = PackageName;
		ModuleName.RemoveFromStart(TEXT("/Script/"));

		for (const TPair<FString, FFuncEntry>& FunctionEntry : ClassEntry.Value)
		{
			FGenericFuncPtr FunctionPointer = FunctionEntry.Value.FuncPtr;
			if (FunctionPointer.IsBound())
			{
				++DirectCount;
				continue;
			}

			if (FunctionEntry.Value.bReflectiveFallbackBound)
			{
				++ReflectiveCount;
				ReflectiveCountsByModule.FindOrAdd(ModuleName) += 1;
				continue;
			}

			++UnresolvedCount;
		}
	}

	if (!TestTrue(TEXT("Generated function table stats should still report direct bindings after reflective fallback lands"), DirectCount > 0))
	{
		return false;
	}

	if (!TestTrue(TEXT("Generated function table stats should report at least one reflective fallback binding"), ReflectiveCount > 0))
	{
		return false;
	}

	if (!TestTrue(TEXT("Generated function table stats should continue to report unresolved entries after reflective fallback lands"), UnresolvedCount > 0))
	{
		return false;
	}

	if (!TestTrue(TEXT("Generated function table stats should record reflective fallback coverage in AIModule"), ReflectiveCountsByModule.FindRef(TEXT("AIModule")) > 0))
	{
		return false;
	}

	if (!TestTrue(TEXT("Generated function table stats should record reflective fallback coverage in GameplayTags"), ReflectiveCountsByModule.FindRef(TEXT("GameplayTags")) > 0))
	{
		return false;
	}

	if (!TestTrue(TEXT("Generated function table stats should record reflective fallback coverage in UMG"), ReflectiveCountsByModule.FindRef(TEXT("UMG")) > 0))
	{
		return false;
	}

	UClass* AbilityAsyncLibraryClass = FindObject<UClass>(nullptr, TEXT("/Script/AngelscriptRuntime.AngelscriptAbilityAsyncLibrary"));
	if (!TestNotNull(TEXT("Generated reflective fallback stats test should locate UAngelscriptAbilityAsyncLibrary"), AbilityAsyncLibraryClass))
	{
		return false;
	}

	const TMap<FString, FFuncEntry>* AsyncLibraryFunctionMap = ClassFuncMaps.Find(AbilityAsyncLibraryClass);
	if (!TestNotNull(TEXT("Generated reflective fallback stats test should expose handwritten GAS entries in ClassFuncMaps"), AsyncLibraryFunctionMap))
	{
		return false;
	}

	const FFuncEntry* WaitForAttributeChangedEntry = AsyncLibraryFunctionMap->Find(TEXT("WaitForAttributeChanged"));
	if (!TestNotNull(TEXT("Generated reflective fallback stats test should keep WaitForAttributeChanged present"), WaitForAttributeChangedEntry))
	{
		return false;
	}

	FGenericFuncPtr WaitForAttributeChangedPointer = WaitForAttributeChangedEntry->FuncPtr;
	if (!TestTrue(TEXT("Generated reflective fallback stats test should keep handwritten GAS entries on the direct path"), WaitForAttributeChangedPointer.IsBound()))
	{
		return false;
	}

	TestTrue(TEXT("Generated reflective fallback stats test should not reclassify handwritten GAS entries as reflective fallback"), !WaitForAttributeChangedEntry->bReflectiveFallbackBound);
	return true;
}

bool FAngelscriptGeneratedFunctionTableSummaryOutputTest::RunTest(const FString& Parameters)
{
	const FString GeneratedDirectory = FPaths::Combine(
		FPaths::ProjectPluginsDir(),
		TEXT("Angelscript"),
		TEXT("Intermediate/Build/Win64/UnrealEditor/Inc/AngelscriptRuntime/UHT"));
	const FString SummaryPath = FPaths::Combine(GeneratedDirectory, TEXT("AS_FunctionTable_Summary.json"));

	FString SummaryJson;
	if (!TestTrue(TEXT("Generated function table summary test should find the UHT summary json output"), FFileHelper::LoadFileToString(SummaryJson, *SummaryPath)))
	{
		return false;
	}

	TSharedPtr<FJsonObject> SummaryObject;
	const TSharedRef<TJsonReader<>> Reader = TJsonReaderFactory<>::Create(SummaryJson);
	if (!TestTrue(TEXT("Generated function table summary test should parse the summary json"), FJsonSerializer::Deserialize(Reader, SummaryObject) && SummaryObject.IsValid()))
	{
		return false;
	}

	int32 TotalGeneratedEntries = 0;
	if (!TestTrue(TEXT("Generated function table summary test should expose totalGeneratedEntries"), SummaryObject->TryGetNumberField(TEXT("totalGeneratedEntries"), TotalGeneratedEntries)))
	{
		return false;
	}

	int32 TotalDirectBindEntries = 0;
	if (!TestTrue(TEXT("Generated function table summary test should expose totalDirectBindEntries"), SummaryObject->TryGetNumberField(TEXT("totalDirectBindEntries"), TotalDirectBindEntries)))
	{
		return false;
	}

	int32 TotalStubEntries = 0;
	if (!TestTrue(TEXT("Generated function table summary test should expose totalStubEntries"), SummaryObject->TryGetNumberField(TEXT("totalStubEntries"), TotalStubEntries)))
	{
		return false;
	}

	double DirectBindRate = 0.0;
	if (!TestTrue(TEXT("Generated function table summary test should expose directBindRate"), SummaryObject->TryGetNumberField(TEXT("directBindRate"), DirectBindRate)))
	{
		return false;
	}

	double StubRate = 0.0;
	if (!TestTrue(TEXT("Generated function table summary test should expose stubRate"), SummaryObject->TryGetNumberField(TEXT("stubRate"), StubRate)))
	{
		return false;
	}

	const int32 CountedRegistrations = CountGeneratedBindingRegistrations(GeneratedDirectory);
	if (!TestTrue(TEXT("Generated function table summary test should count generated registration lines from UHT output"), CountedRegistrations > 0))
	{
		return false;
	}

	TestEqual(TEXT("Generated function table summary test should match the generated binding registration count"), TotalGeneratedEntries, CountedRegistrations);

	if (!TestEqual(TEXT("Generated function table summary test should keep direct and stub totals aligned with totalGeneratedEntries"), TotalGeneratedEntries, TotalDirectBindEntries + TotalStubEntries))
	{
		return false;
	}

	const double ExpectedDirectBindRate = TotalGeneratedEntries > 0 ? static_cast<double>(TotalDirectBindEntries) / static_cast<double>(TotalGeneratedEntries) : 0.0;
	const double ExpectedStubRate = TotalGeneratedEntries > 0 ? static_cast<double>(TotalStubEntries) / static_cast<double>(TotalGeneratedEntries) : 0.0;
	TestTrue(TEXT("Generated function table summary test should keep directBindRate aligned with entry counts"), FMath::Abs(DirectBindRate - ExpectedDirectBindRate) < 1.e-9);
	TestTrue(TEXT("Generated function table summary test should keep stubRate aligned with entry counts"), FMath::Abs(StubRate - ExpectedStubRate) < 1.e-9);
	TestTrue(TEXT("Generated function table summary test should keep directBindRate and stubRate normalized"), FMath::Abs((DirectBindRate + StubRate) - 1.0) < 1.e-9);

	const TArray<TSharedPtr<FJsonValue>>* Modules = nullptr;
	if (!TestTrue(TEXT("Generated function table summary test should expose per-module summaries"), SummaryObject->TryGetArrayField(TEXT("modules"), Modules) && Modules != nullptr))
	{
		return false;
	}

	int32 SummedModuleEntries = 0;
	for (const TSharedPtr<FJsonValue>& ModuleValue : *Modules)
	{
		const TSharedPtr<FJsonObject>* ModuleObject = nullptr;
		if (ModuleValue.IsValid() && ModuleValue->TryGetObject(ModuleObject) && ModuleObject != nullptr)
		{
			int32 ModuleEntries = 0;
			int32 ModuleDirectBindEntries = 0;
			int32 ModuleStubEntries = 0;
			double ModuleDirectBindRate = 0.0;
			double ModuleStubRate = 0.0;
			if ((*ModuleObject)->TryGetNumberField(TEXT("totalEntries"), ModuleEntries))
			{
				SummedModuleEntries += ModuleEntries;
			}

			if (!TestTrue(TEXT("Generated function table summary test should expose per-module directBindEntries"), (*ModuleObject)->TryGetNumberField(TEXT("directBindEntries"), ModuleDirectBindEntries)))
			{
				return false;
			}

			if (!TestTrue(TEXT("Generated function table summary test should expose per-module stubEntries"), (*ModuleObject)->TryGetNumberField(TEXT("stubEntries"), ModuleStubEntries)))
			{
				return false;
			}

			if (!TestTrue(TEXT("Generated function table summary test should expose per-module directBindRate"), (*ModuleObject)->TryGetNumberField(TEXT("directBindRate"), ModuleDirectBindRate)))
			{
				return false;
			}

			if (!TestTrue(TEXT("Generated function table summary test should expose per-module stubRate"), (*ModuleObject)->TryGetNumberField(TEXT("stubRate"), ModuleStubRate)))
			{
				return false;
			}

			if (!TestEqual(TEXT("Generated function table summary test should keep module totals aligned"), ModuleEntries, ModuleDirectBindEntries + ModuleStubEntries))
			{
				return false;
			}

			const double ExpectedModuleDirectRate = ModuleEntries > 0 ? static_cast<double>(ModuleDirectBindEntries) / static_cast<double>(ModuleEntries) : 0.0;
			const double ExpectedModuleStubRate = ModuleEntries > 0 ? static_cast<double>(ModuleStubEntries) / static_cast<double>(ModuleEntries) : 0.0;
			if (!TestTrue(TEXT("Generated function table summary test should keep module directBindRate aligned with entry counts"), FMath::Abs(ModuleDirectBindRate - ExpectedModuleDirectRate) < 1.e-9))
			{
				return false;
			}

			if (!TestTrue(TEXT("Generated function table summary test should keep module stubRate aligned with entry counts"), FMath::Abs(ModuleStubRate - ExpectedModuleStubRate) < 1.e-9))
			{
				return false;
			}
		}
	}

	TestEqual(TEXT("Generated function table summary test should keep totalGeneratedEntries equal to the sum of module totals"), TotalGeneratedEntries, SummedModuleEntries);
	return true;
}

bool FAngelscriptGeneratedFunctionTableCsvOutputTest::RunTest(const FString& Parameters)
{
	const FString GeneratedDirectory = FPaths::Combine(
		FPaths::ProjectPluginsDir(),
		TEXT("Angelscript"),
		TEXT("Intermediate/Build/Win64/UnrealEditor/Inc/AngelscriptRuntime/UHT"));
	const FString SummaryPath = FPaths::Combine(GeneratedDirectory, TEXT("AS_FunctionTable_Summary.json"));
	const FString ModuleCsvPath = FPaths::Combine(GeneratedDirectory, TEXT("AS_FunctionTable_ModuleSummary.csv"));
	const FString EntryCsvPath = FPaths::Combine(GeneratedDirectory, TEXT("AS_FunctionTable_Entries.csv"));

	FString SummaryJson;
	if (!TestTrue(TEXT("Generated function table csv test should find the summary json output"), FFileHelper::LoadFileToString(SummaryJson, *SummaryPath)))
	{
		return false;
	}

	TSharedPtr<FJsonObject> SummaryObject;
	const TSharedRef<TJsonReader<>> Reader = TJsonReaderFactory<>::Create(SummaryJson);
	if (!TestTrue(TEXT("Generated function table csv test should parse the summary json"), FJsonSerializer::Deserialize(Reader, SummaryObject) && SummaryObject.IsValid()))
	{
		return false;
	}

	int32 TotalGeneratedEntries = 0;
	if (!TestTrue(TEXT("Generated function table csv test should expose totalGeneratedEntries"), SummaryObject->TryGetNumberField(TEXT("totalGeneratedEntries"), TotalGeneratedEntries)))
	{
		return false;
	}

	const TArray<TSharedPtr<FJsonValue>>* Modules = nullptr;
	if (!TestTrue(TEXT("Generated function table csv test should expose per-module summaries"), SummaryObject->TryGetArrayField(TEXT("modules"), Modules) && Modules != nullptr))
	{
		return false;
	}

	const TArray<FString> ModuleLines = LoadNonEmptyFileLines(ModuleCsvPath);
	if (!TestTrue(TEXT("Generated function table csv test should write the module summary csv"), ModuleLines.Num() > 0))
	{
		return false;
	}

	TestEqual(TEXT("Generated function table csv test should keep one module csv row per module summary"), ModuleLines.Num() - 1, Modules->Num());
	TestEqual(TEXT("Generated function table csv test should write the expected module csv header"), ModuleLines[0], TEXT("ModuleName,EditorOnly,TotalEntries,DirectBindEntries,StubEntries,DirectBindRate,StubRate,ShardCount"));

	const TArray<FString> EntryLines = LoadNonEmptyFileLines(EntryCsvPath);
	if (!TestTrue(TEXT("Generated function table csv test should write the entry detail csv"), EntryLines.Num() > 0))
	{
		return false;
	}

	TestEqual(TEXT("Generated function table csv test should keep one entry csv row per generated binding entry"), EntryLines.Num() - 1, TotalGeneratedEntries);
	TestEqual(TEXT("Generated function table csv test should write the expected entry csv header"), EntryLines[0], TEXT("ModuleName,EditorOnly,ClassName,FunctionName,EntryKind,EraseMacro,ShardIndex"));

	FString RunBehaviorTreeCsvLine;
	if (!TestTrue(TEXT("Generated function table csv test should include RunBehaviorTree in the entry csv"), FindGeneratedBindingLine(GeneratedDirectory, TEXT("\"RunBehaviorTree\""), RunBehaviorTreeCsvLine)))
	{
		return false;
	}

	bool bFoundRunBehaviorTreeCsv = false;
	for (const FString& EntryLine : EntryLines)
	{
		if (EntryLine.Contains(TEXT(",RunBehaviorTree,")))
		{
			bFoundRunBehaviorTreeCsv = true;
			TestTrue(TEXT("Generated function table csv test should classify RunBehaviorTree as a direct entry"), EntryLine.Contains(TEXT(",Direct,")));
			TestFalse(TEXT("Generated function table csv test should not emit ERASE_NO_FUNCTION for RunBehaviorTree in the csv"), EntryLine.Contains(TEXT("ERASE_NO_FUNCTION()")));
			break;
		}
	}

	TestTrue(TEXT("Generated function table csv test should locate RunBehaviorTree in the entry csv"), bFoundRunBehaviorTreeCsv);
	return true;
}

bool FAngelscriptGeneratedFunctionTableSkippedCsvOutputTest::RunTest(const FString& Parameters)
{
	const FString GeneratedDirectory = FPaths::Combine(
		FPaths::ProjectPluginsDir(),
		TEXT("Angelscript"),
		TEXT("Intermediate/Build/Win64/UnrealEditor/Inc/AngelscriptRuntime/UHT"));
	const FString SkippedCsvPath = FPaths::Combine(GeneratedDirectory, TEXT("AS_FunctionTable_SkippedEntries.csv"));

	const TArray<FString> SkippedLines = LoadNonEmptyFileLines(SkippedCsvPath);
	if (!TestTrue(TEXT("Generated function table skipped csv test should write the skipped entry csv"), SkippedLines.Num() > 0))
	{
		return false;
	}

	TestEqual(TEXT("Generated function table skipped csv test should write the expected skipped csv header"), SkippedLines[0], TEXT("ModuleName,ClassName,FunctionName,FailureReason"));
	TestTrue(TEXT("Generated function table skipped csv test should contain at least one skipped function row"), SkippedLines.Num() > 1);

	bool bFoundFailureReason = false;
	for (int32 LineIndex = 1; LineIndex < SkippedLines.Num(); ++LineIndex)
	{
		TArray<FString> Columns;
		SkippedLines[LineIndex].ParseIntoArray(Columns, TEXT(","), false);
		if (!TestTrue(TEXT("Generated function table skipped csv rows should expose four columns"), Columns.Num() == 4))
		{
			return false;
		}

		if (!Columns[3].IsEmpty())
		{
			bFoundFailureReason = true;
		}
	}

	TestTrue(TEXT("Generated function table skipped csv rows should include non-empty failure reasons"), bFoundFailureReason);
	return true;
}

bool FAngelscriptGeneratedFunctionTableSkippedReasonSummaryCsvOutputTest::RunTest(const FString& Parameters)
{
	const FString GeneratedDirectory = FPaths::Combine(
		FPaths::ProjectPluginsDir(),
		TEXT("Angelscript"),
		TEXT("Intermediate/Build/Win64/UnrealEditor/Inc/AngelscriptRuntime/UHT"));
	const FString SkippedCsvPath = FPaths::Combine(GeneratedDirectory, TEXT("AS_FunctionTable_SkippedEntries.csv"));
	const FString ReasonSummaryCsvPath = FPaths::Combine(GeneratedDirectory, TEXT("AS_FunctionTable_SkippedReasonSummary.csv"));

	const TArray<FString> SkippedLines = LoadNonEmptyFileLines(SkippedCsvPath);
	if (!TestTrue(TEXT("Generated function table skipped reason summary test should find the skipped entry csv"), SkippedLines.Num() > 0))
	{
		return false;
	}

	const TArray<FString> SummaryLines = LoadNonEmptyFileLines(ReasonSummaryCsvPath);
	if (!TestTrue(TEXT("Generated function table skipped reason summary test should write the skipped reason summary csv"), SummaryLines.Num() > 0))
	{
		return false;
	}

	TestEqual(TEXT("Generated function table skipped reason summary test should write the expected summary csv header"), SummaryLines[0], TEXT("FailureReason,SkippedCount"));
	TestTrue(TEXT("Generated function table skipped reason summary test should contain at least one reason row"), SummaryLines.Num() > 1);

	int32 SummedSkippedCount = 0;
	for (int32 LineIndex = 1; LineIndex < SummaryLines.Num(); ++LineIndex)
	{
		TArray<FString> Columns;
		SummaryLines[LineIndex].ParseIntoArray(Columns, TEXT(","), false);
		if (!TestTrue(TEXT("Generated function table skipped reason summary rows should expose two columns"), Columns.Num() == 2))
		{
			return false;
		}

		if (!TestTrue(TEXT("Generated function table skipped reason summary rows should include a non-empty reason"), !Columns[0].IsEmpty()))
		{
			return false;
		}

		SummedSkippedCount += FCString::Atoi(*Columns[1]);
	}

	TestEqual(TEXT("Generated function table skipped reason summary test should keep aggregate counts aligned with the skipped entry csv"), SummedSkippedCount, SkippedLines.Num() - 1);
	return true;
}

bool FAngelscriptGeneratedFunctionTableMacroQualifiedDirectBindingsTest::RunTest(const FString& Parameters)
{
	const FString GeneratedDirectory = FPaths::Combine(
		FPaths::ProjectPluginsDir(),
		TEXT("Angelscript"),
		TEXT("Intermediate/Build/Win64/UnrealEditor/Inc/AngelscriptRuntime/UHT"));

	FString RunBehaviorTreeLine;
	if (!TestTrue(TEXT("Macro-qualified direct bindings test should find generated entry for RunBehaviorTree"), FindGeneratedBindingLine(GeneratedDirectory, TEXT("\"RunBehaviorTree\""), RunBehaviorTreeLine)))
	{
		return false;
	}

	TestFalse(TEXT("Macro-qualified direct bindings test should not reduce RunBehaviorTree to ERASE_NO_FUNCTION"), RunBehaviorTreeLine.Contains(TEXT("ERASE_NO_FUNCTION()")));
	TestTrue(TEXT("Macro-qualified direct bindings test should keep RunBehaviorTree on a direct erase macro path"), RunBehaviorTreeLine.Contains(TEXT("ERASE_AUTO_METHOD_PTR")) || RunBehaviorTreeLine.Contains(TEXT("ERASE_METHOD_PTR")));

	FString ReportPerceptionEventLine;
	if (!TestTrue(TEXT("Macro-qualified direct bindings test should find generated entry for ReportPerceptionEvent"), FindGeneratedBindingLine(GeneratedDirectory, TEXT("\"ReportPerceptionEvent\""), ReportPerceptionEventLine)))
	{
		return false;
	}

	TestFalse(TEXT("Macro-qualified direct bindings test should not reduce ReportPerceptionEvent to ERASE_NO_FUNCTION"), ReportPerceptionEventLine.Contains(TEXT("ERASE_NO_FUNCTION()")));
	TestTrue(TEXT("Macro-qualified direct bindings test should keep ReportPerceptionEvent on a direct erase macro path"), ReportPerceptionEventLine.Contains(TEXT("ERASE_AUTO_FUNCTION_PTR")) || ReportPerceptionEventLine.Contains(TEXT("ERASE_FUNCTION_PTR")));
	return true;
}
#endif
