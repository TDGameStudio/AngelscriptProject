#include "AngelscriptBinds.h"
#include "AngelscriptEngine.h"
#include "AngelscriptSettings.h"
#include "AngelscriptUhtCoverageTestTypes.h"
#include "Binds/Helper_FunctionSignature.h"
#include "Testing/AngelscriptUhtOverloadCoverageTypes.h"
#include "ClassGenerator/ASClass.h"
#include "../Shared/AngelscriptTestUtilities.h"
#include "Testing/AngelscriptBindExecutionObservation.h"
#include "FunctionLibraries/RuntimeFloatCurveMixinLibrary.h"
#include "GameFramework/Actor.h"
#include "Kismet/GameplayStatics.h"
#include "Misc/AutomationTest.h"
#include "Misc/Guid.h"
#include "Misc/ScopeExit.h"

#include "StartAngelscriptHeaders.h"
#include "source/as_scriptfunction.h"
#include "EndAngelscriptHeaders.h"

#if WITH_DEV_AUTOMATION_TESTS

class asIScriptGeneric;

struct FAngelscriptBindConfigTestAccess
{
	static void CallBinds(const TSet<FName>& DisabledBindNames)
	{
		FAngelscriptBinds::CallBinds(DisabledBindNames);
	}

	static void BindScriptTypes(FAngelscriptEngine& Engine)
	{
		Engine.BindScriptTypes();
	}

	static void SetRuntimeConfig(FAngelscriptEngine& Engine, const FAngelscriptEngineConfig& Config)
	{
		Engine.RuntimeConfig = Config;
	}

	static void DestroyGlobalEngine()
	{
		FAngelscriptEngine::DestroyGlobal();
	}

	static TSet<FName> CollectDisabledBindNames(const FAngelscriptEngine& Engine)
	{
		return Engine.CollectDisabledBindNames();
	}
};

namespace AngelscriptTest_Core_AngelscriptBindConfigTests_Private
{
	struct FBindExecutionRecorder
	{
		static TMap<FName, int32>& GetCounts()
		{
			static TMap<FName, int32> Counts;
			return Counts;
		}

		static void Reset(const FName CounterKey)
		{
			GetCounts().FindOrAdd(CounterKey) = 0;
		}

		static void Increment(const FName CounterKey)
		{
			++GetCounts().FindOrAdd(CounterKey);
		}

		static int32 Get(const FName CounterKey)
		{
			return GetCounts().FindRef(CounterKey);
		}
	};

	FName MakeUniqueBindTestName(const TCHAR* Prefix)
	{
		return FName(*FString::Printf(TEXT("%s.%s"), Prefix, *FGuid::NewGuid().ToString(EGuidFormats::Digits)));
	}

	TArray<FName> FindNewBindNames(const TArray<FName>& BeforeNames, const TArray<FName>& AfterNames)
	{
		TSet<FName> ExistingNames;
		for (const FName& BeforeName : BeforeNames)
		{
			ExistingNames.Add(BeforeName);
		}

		TArray<FName> NewNames;
		for (const FName& AfterName : AfterNames)
		{
			if (!ExistingNames.Contains(AfterName))
			{
				NewNames.Add(AfterName);
			}
		}

		return NewNames;
	}

	TSet<FName> BuildDisabledSetExcluding(const TArray<FName>& AllBindNames, const TSet<FName>& AllowedNames)
	{
		TSet<FName> DisabledBindNames;
		for (const FName& BindName : AllBindNames)
		{
			if (!AllowedNames.Contains(BindName))
			{
				DisabledBindNames.Add(BindName);
			}
		}

		return DisabledBindNames;
	}

	void ExecuteIsolatedBinds(const TSet<FName>& DisabledBindNames)
	{
		UE_SET_LOG_VERBOSITY(Angelscript, Fatal);
		FAngelscriptBindConfigTestAccess::CallBinds(DisabledBindNames);
		UE_SET_LOG_VERBOSITY(Angelscript, Log);
	}

	FAngelscriptBindExecutionSnapshot ObserveStartupBindPass(const FAngelscriptEngineConfig& Config)
	{
		AngelscriptTestSupport::DestroySharedTestEngine();
		if (FAngelscriptEngine::IsInitialized())
		{
			FAngelscriptBindConfigTestAccess::DestroyGlobalEngine();
		}

		FAngelscriptBindExecutionObservation::Reset();
		const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
		TUniquePtr<FAngelscriptEngine> Engine = FAngelscriptEngine::CreateTestingFullEngine(Config, Dependencies);
		check(Engine.IsValid());
		FAngelscriptBindExecutionSnapshot Snapshot = FAngelscriptBindExecutionObservation::GetLastSnapshot();
		Engine.Reset();
		AngelscriptTestSupport::DestroySharedTestEngine();

		if (FAngelscriptEngine::IsInitialized())
		{
			FAngelscriptBindConfigTestAccess::DestroyGlobalEngine();
		}

		return Snapshot;
	}

	int32 FindBindIndexByName(const TArray<FAngelscriptBinds::FBindInfo>& BindInfos, const FName BindName)
	{
		for (int32 BindIndex = 0; BindIndex < BindInfos.Num(); ++BindIndex)
		{
			if (BindInfos[BindIndex].BindName == BindName)
			{
				return BindIndex;
			}
		}

		return INDEX_NONE;
	}

	const FAngelscriptBinds::FBindInfo* FindBindInfoByName(const TArray<FAngelscriptBinds::FBindInfo>& BindInfos, const FName BindName)
	{
		for (const FAngelscriptBinds::FBindInfo& BindInfo : BindInfos)
		{
			if (BindInfo.BindName == BindName)
			{
				return &BindInfo;
			}
		}

		return nullptr;
	}

	bool IsFunctionEntryBound(const FFuncEntry& Entry)
	{
		FGenericFuncPtr FuncPtr = Entry.FuncPtr;
		return FuncPtr.IsBound() && Entry.Caller.IsBound();
	}

	bool AreFunctionEntriesEqual(const FFuncEntry& Left, const FFuncEntry& Right)
	{
		return FMemory::Memcmp(&Left.FuncPtr, &Right.FuncPtr, sizeof(FGenericFuncPtr)) == 0 &&
			FMemory::Memcmp(&Left.Caller, &Right.Caller, sizeof(ASAutoCaller::FunctionCaller)) == 0;
	}

	void CDECL NoOpGeneric(asIScriptGeneric* Generic)
	{
		(void)Generic;
	}
}

using namespace AngelscriptTest_Core_AngelscriptBindConfigTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGlobalDisabledBindNamesTest,
	"Angelscript.TestModule.Engine.BindConfig.GlobalDisabledBindNames",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptEngineDisabledBindNamesTest,
	"Angelscript.TestModule.Engine.BindConfig.EngineDisabledBindNames",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptUnnamedBindBackwardCompatibilityTest,
	"Angelscript.TestModule.Engine.BindConfig.UnnamedBindBackwardCompatibility",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptStartupBindOrderCoverageTest,
	"Angelscript.TestModule.Engine.BindConfig.StartupBindInfoPreservesOrder",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptStartupDisabledBindMergeCoverageTest,
	"Angelscript.TestModule.Engine.BindConfig.StartupPathMergesDisabledBindNames",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptGeneratedFunctionEntryPopulationTest,
	"Angelscript.TestModule.Engine.BindConfig.GeneratedBlueprintCallableEntriesPopulateClassMaps",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptFunctionEntryDeduplicationTest,
	"Angelscript.TestModule.Engine.BindConfig.AddFunctionEntryPreservesFirstRegistration",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBlueprintInternalUseOnlyOverrideTest,
	"Angelscript.TestModule.Engine.BindConfig.BlueprintInternalUseOnlyCanBeOverriddenForAngelscript",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScriptMethodMetadataCoverageTest,
	"Angelscript.TestModule.Engine.BindConfig.FunctionLevelScriptMethodUsesFirstParameterAsMixin",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter | EAutomationTestFlags::Disabled) // TODO(#ue57-binding): ScriptMethod first-parameter-as-mixin binding broken on UE 5.7; UFunction metadata layout change

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCallableWithoutWorldContextMetadataTest,
	"Angelscript.TestModule.Engine.BindConfig.CallableWithoutWorldContextKeepsHiddenWorldContextButClearsTrait",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter | EAutomationTestFlags::Disabled) // TODO(#ue57-binding): CallableWithoutWorldContext trait clearing regressed on UE 5.7; world-context metadata handling changed

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptOverloadResolutionCoverageTest,
	"Angelscript.TestModule.Engine.BindConfig.OverloadedExportedFunctionsCanRecoverDirectBind",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptInlineDefinitionCoverageTest,
	"Angelscript.TestModule.Engine.BindConfig.InlineDefinitionFunctionsCanRecoverDirectBind",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptInlineOutRefCoverageTest,
	"Angelscript.TestModule.Engine.BindConfig.InlineOutRefFunctionsCanRecoverDirectBind",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptGlobalDisabledBindNamesTest::RunTest(const FString& Parameters)
{
	UAngelscriptSettings* Settings = GetMutableDefault<UAngelscriptSettings>();
	if (!TestNotNull(TEXT("BindConfig.GlobalDisabledBindNames should access mutable settings"), Settings))
	{
		return false;
	}

	const TArray<FName> PreviousDisabledBindNames = Settings->DisabledBindNames;
	ON_SCOPE_EXIT
	{
		Settings->DisabledBindNames = PreviousDisabledBindNames;
	};

	const FName NamedBindName = MakeUniqueBindTestName(TEXT("Automation.BindConfig.Global"));
	const FName CounterKey = MakeUniqueBindTestName(TEXT("Automation.BindConfig.Global.Counter"));
	FBindExecutionRecorder::Reset(CounterKey);

	FAngelscriptBinds::FBind NamedBind(NamedBindName, [CounterKey]()
	{
		FBindExecutionRecorder::Increment(CounterKey);
	});

	const TArray<FName> AllBindNames = FAngelscriptBinds::GetAllRegisteredBindNames();
	TestTrue(TEXT("BindConfig.GlobalDisabledBindNames should expose newly registered named binds"), AllBindNames.Contains(NamedBindName));

	TSet<FName> AllowedBindNames;
	AllowedBindNames.Add(NamedBindName);

	ExecuteIsolatedBinds(BuildDisabledSetExcluding(AllBindNames, AllowedBindNames));
	TestEqual(TEXT("BindConfig.GlobalDisabledBindNames should execute the named bind when it is enabled"), FBindExecutionRecorder::Get(CounterKey), 1);

	FBindExecutionRecorder::Reset(CounterKey);
	Settings->DisabledBindNames = { NamedBindName };

	FAngelscriptEngineConfig Config;
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	FAngelscriptEngine Engine(Config, Dependencies);
	FAngelscriptEngineScope EngineScope(Engine);
	const TSet<FName> MergedDisabledBindNames = FAngelscriptBindConfigTestAccess::CollectDisabledBindNames(Engine);
	TestTrue(TEXT("BindConfig.GlobalDisabledBindNames should merge the settings-level disabled bind name"), MergedDisabledBindNames.Contains(NamedBindName));

	TSet<FName> DisabledBindNames = BuildDisabledSetExcluding(AllBindNames, AllowedBindNames);
	DisabledBindNames.Append(MergedDisabledBindNames);
	ExecuteIsolatedBinds(DisabledBindNames);

	TestEqual(TEXT("BindConfig.GlobalDisabledBindNames should skip execution when disabled in settings"), FBindExecutionRecorder::Get(CounterKey), 0);

	const TArray<FAngelscriptBinds::FBindInfo> BindInfos = FAngelscriptBinds::GetBindInfoList(MergedDisabledBindNames);
	const FAngelscriptBinds::FBindInfo* NamedBindInfo = FindBindInfoByName(BindInfos, NamedBindName);
	if (!TestNotNull(TEXT("BindConfig.GlobalDisabledBindNames should expose bind info for the named bind"), NamedBindInfo))
	{
		return false;
	}

	TestFalse(TEXT("BindConfig.GlobalDisabledBindNames should report the disabled named bind as disabled"), NamedBindInfo->bEnabled);
	return true;
}

bool FAngelscriptEngineDisabledBindNamesTest::RunTest(const FString& Parameters)
{
	UAngelscriptSettings* Settings = GetMutableDefault<UAngelscriptSettings>();
	if (!TestNotNull(TEXT("BindConfig.EngineDisabledBindNames should access mutable settings"), Settings))
	{
		return false;
	}

	const TArray<FName> PreviousDisabledBindNames = Settings->DisabledBindNames;
	ON_SCOPE_EXIT
	{
		Settings->DisabledBindNames = PreviousDisabledBindNames;
	};
	Settings->DisabledBindNames.Reset();

	const FName NamedBindName = MakeUniqueBindTestName(TEXT("Automation.BindConfig.Engine"));
	const FName CounterKey = MakeUniqueBindTestName(TEXT("Automation.BindConfig.Engine.Counter"));
	FBindExecutionRecorder::Reset(CounterKey);

	FAngelscriptBinds::FBind NamedBind(NamedBindName, [CounterKey]()
	{
		FBindExecutionRecorder::Increment(CounterKey);
	});

	const TArray<FName> AllBindNames = FAngelscriptBinds::GetAllRegisteredBindNames();
	TestTrue(TEXT("BindConfig.EngineDisabledBindNames should expose the named bind through the query API"), AllBindNames.Contains(NamedBindName));

	TSet<FName> AllowedBindNames;
	AllowedBindNames.Add(NamedBindName);

	ExecuteIsolatedBinds(BuildDisabledSetExcluding(AllBindNames, AllowedBindNames));
	TestEqual(TEXT("BindConfig.EngineDisabledBindNames should execute the named bind before engine-level filtering is applied"), FBindExecutionRecorder::Get(CounterKey), 1);

	FBindExecutionRecorder::Reset(CounterKey);

	FAngelscriptEngineConfig Config;
	Config.DisabledBindNames.Add(NamedBindName);
	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	FAngelscriptEngine Engine(Config, Dependencies);
	FAngelscriptEngineScope EngineScope(Engine);
	const TSet<FName> MergedDisabledBindNames = FAngelscriptBindConfigTestAccess::CollectDisabledBindNames(Engine);
	TestTrue(TEXT("BindConfig.EngineDisabledBindNames should include the engine-level disabled bind name"), MergedDisabledBindNames.Contains(NamedBindName));

	TSet<FName> DisabledBindNames = BuildDisabledSetExcluding(AllBindNames, AllowedBindNames);
	DisabledBindNames.Append(MergedDisabledBindNames);
	ExecuteIsolatedBinds(DisabledBindNames);

	TestEqual(TEXT("BindConfig.EngineDisabledBindNames should skip execution when disabled in the engine config"), FBindExecutionRecorder::Get(CounterKey), 0);
	return true;
}

bool FAngelscriptUnnamedBindBackwardCompatibilityTest::RunTest(const FString& Parameters)
{
	const TArray<FName> BaselineBindNames = FAngelscriptBinds::GetAllRegisteredBindNames();
	const FName CounterKey = MakeUniqueBindTestName(TEXT("Automation.BindConfig.Unnamed.Counter"));
	FBindExecutionRecorder::Reset(CounterKey);

	FAngelscriptBinds::FBind UnnamedBind([CounterKey]()
	{
		FBindExecutionRecorder::Increment(CounterKey);
	});

	const TArray<FName> AllBindNames = FAngelscriptBinds::GetAllRegisteredBindNames();
	const TArray<FName> NewBindNames = FindNewBindNames(BaselineBindNames, AllBindNames);

	FName GeneratedUnnamedBindName = NAME_None;
	for (const FName& NewBindName : NewBindNames)
	{
		if (NewBindName.ToString().StartsWith(TEXT("UnnamedBind_")))
		{
			GeneratedUnnamedBindName = NewBindName;
			break;
		}
	}

	if (!TestFalse(TEXT("BindConfig.UnnamedBindBackwardCompatibility should register at least one new bind name"), NewBindNames.IsEmpty()))
	{
		return false;
	}

	if (!TestTrue(TEXT("BindConfig.UnnamedBindBackwardCompatibility should auto-generate an unnamed bind name"), GeneratedUnnamedBindName != NAME_None))
	{
		return false;
	}

	const TArray<FAngelscriptBinds::FBindInfo> BindInfos = FAngelscriptBinds::GetBindInfoList();
	const FAngelscriptBinds::FBindInfo* UnnamedBindInfo = FindBindInfoByName(BindInfos, GeneratedUnnamedBindName);
	if (!TestNotNull(TEXT("BindConfig.UnnamedBindBackwardCompatibility should expose bind info for the unnamed bind"), UnnamedBindInfo))
	{
		return false;
	}

	TestEqual(TEXT("BindConfig.UnnamedBindBackwardCompatibility should default unnamed bind order to zero"), UnnamedBindInfo->BindOrder, 0);
	TestTrue(TEXT("BindConfig.UnnamedBindBackwardCompatibility should report unnamed binds as enabled by default"), UnnamedBindInfo->bEnabled);

	TSet<FName> AllowedBindNames;
	AllowedBindNames.Add(GeneratedUnnamedBindName);
	ExecuteIsolatedBinds(BuildDisabledSetExcluding(AllBindNames, AllowedBindNames));

	TestEqual(TEXT("BindConfig.UnnamedBindBackwardCompatibility should continue executing unnamed binds"), FBindExecutionRecorder::Get(CounterKey), 1);
	return true;
}

bool FAngelscriptStartupBindOrderCoverageTest::RunTest(const FString& Parameters)
{
	const FName EarlyBindName = MakeUniqueBindTestName(TEXT("Automation.BindConfig.StartupOrder.Early"));
	const FName LateBindName = MakeUniqueBindTestName(TEXT("Automation.BindConfig.StartupOrder.Late"));
	FAngelscriptBinds::FBind EarlyBind(EarlyBindName, -100, []() {});
	FAngelscriptBinds::FBind LateBind(LateBindName, 100, []() {});

	const TArray<FAngelscriptBinds::FBindInfo> BindInfos = FAngelscriptBinds::GetBindInfoList();
	const int32 EarlyInfoIndex = FindBindIndexByName(BindInfos, EarlyBindName);
	const int32 LateInfoIndex = FindBindIndexByName(BindInfos, LateBindName);
	if (!TestTrue(TEXT("BindConfig.StartupBindInfoPreservesOrder should expose the early named bind in bind info"), EarlyInfoIndex != INDEX_NONE)
		|| !TestTrue(TEXT("BindConfig.StartupBindInfoPreservesOrder should expose the late named bind in bind info"), LateInfoIndex != INDEX_NONE))
	{
		return false;
	}

	const FAngelscriptBindExecutionSnapshot Snapshot = ObserveStartupBindPass(FAngelscriptEngineConfig());
	if (!TestEqual(TEXT("BindConfig.StartupBindInfoPreservesOrder should observe a single startup bind pass"), FAngelscriptBindExecutionObservation::GetInvocationCount(), 1))
	{
		return false;
	}

	const int32 EarlyExecutionIndex = Snapshot.ExecutedBindNames.IndexOfByKey(EarlyBindName);
	const int32 LateExecutionIndex = Snapshot.ExecutedBindNames.IndexOfByKey(LateBindName);
	if (!TestTrue(TEXT("BindConfig.StartupBindInfoPreservesOrder should execute the early named bind during startup"), EarlyExecutionIndex != INDEX_NONE)
		|| !TestTrue(TEXT("BindConfig.StartupBindInfoPreservesOrder should execute the late named bind during startup"), LateExecutionIndex != INDEX_NONE))
	{
		return false;
	}

	TestTrue(TEXT("BindConfig.StartupBindInfoPreservesOrder should sort bind info by bind order"), EarlyInfoIndex < LateInfoIndex);
	return TestTrue(TEXT("BindConfig.StartupBindInfoPreservesOrder should preserve the same order in the startup bind pass"), EarlyExecutionIndex < LateExecutionIndex);
}

bool FAngelscriptStartupDisabledBindMergeCoverageTest::RunTest(const FString& Parameters)
{
	UAngelscriptSettings* Settings = GetMutableDefault<UAngelscriptSettings>();
	if (!TestNotNull(TEXT("BindConfig.StartupPathMergesDisabledBindNames should access mutable settings"), Settings))
	{
		return false;
	}

	const TArray<FName> PreviousDisabledBindNames = Settings->DisabledBindNames;
	ON_SCOPE_EXIT
	{
		Settings->DisabledBindNames = PreviousDisabledBindNames;
	};
	Settings->DisabledBindNames.Reset();

	const FName SettingsDisabledBindName = MakeUniqueBindTestName(TEXT("Automation.BindConfig.Startup.SettingsDisabled"));
	const FName EngineDisabledBindName = MakeUniqueBindTestName(TEXT("Automation.BindConfig.Startup.EngineDisabled"));
	const FName EnabledBindName = MakeUniqueBindTestName(TEXT("Automation.BindConfig.Startup.Enabled"));
	FAngelscriptBinds::FBind SettingsDisabledBind(SettingsDisabledBindName, []() {});
	FAngelscriptBinds::FBind EngineDisabledBind(EngineDisabledBindName, []() {});
	FAngelscriptBinds::FBind EnabledBind(EnabledBindName, []() {});

	Settings->DisabledBindNames = { SettingsDisabledBindName };
	FAngelscriptEngineConfig Config;
	Config.DisabledBindNames.Add(EngineDisabledBindName);

	const FAngelscriptBindExecutionSnapshot Snapshot = ObserveStartupBindPass(Config);
	if (!TestEqual(TEXT("BindConfig.StartupPathMergesDisabledBindNames should observe one startup bind pass"), FAngelscriptBindExecutionObservation::GetInvocationCount(), 1))
	{
		return false;
	}

	TestTrue(TEXT("BindConfig.StartupPathMergesDisabledBindNames should surface the settings-level disabled bind in the observed startup pass"), Snapshot.DisabledBindNames.Contains(SettingsDisabledBindName));
	TestTrue(TEXT("BindConfig.StartupPathMergesDisabledBindNames should surface the engine-level disabled bind in the observed startup pass"), Snapshot.DisabledBindNames.Contains(EngineDisabledBindName));
	TestFalse(TEXT("BindConfig.StartupPathMergesDisabledBindNames should skip the settings-disabled bind during startup"), Snapshot.ExecutedBindNames.Contains(SettingsDisabledBindName));
	TestFalse(TEXT("BindConfig.StartupPathMergesDisabledBindNames should skip the engine-disabled bind during startup"), Snapshot.ExecutedBindNames.Contains(EngineDisabledBindName));
	return TestTrue(TEXT("BindConfig.StartupPathMergesDisabledBindNames should keep enabled binds visible in the startup execution list"), Snapshot.ExecutedBindNames.Contains(EnabledBindName));
}

bool FAngelscriptGeneratedFunctionEntryPopulationTest::RunTest(const FString& Parameters)
{
	AngelscriptTestSupport::DestroySharedTestEngine();
	if (FAngelscriptEngine::IsInitialized())
	{
		FAngelscriptBindConfigTestAccess::DestroyGlobalEngine();
	}

	FAngelscriptBinds::ResetBindState();
	ON_SCOPE_EXIT
	{
		FAngelscriptBinds::ResetBindState();
		AngelscriptTestSupport::DestroySharedTestEngine();
		if (FAngelscriptEngine::IsInitialized())
		{
			FAngelscriptBindConfigTestAccess::DestroyGlobalEngine();
		}
	};

	UFunction* DestroyActorFunction = AActor::StaticClass()->FindFunctionByName(TEXT("K2_DestroyActor"));
	UFunction* GetPlayerControllerFunction = UGameplayStatics::StaticClass()->FindFunctionByName(TEXT("GetPlayerController"));
	UFunction* IsDeveloperOnlyFunction = UASClass::StaticClass()->FindFunctionByName(TEXT("IsDeveloperOnly"));
	if (!TestNotNull(TEXT("GeneratedBlueprintCallableEntriesPopulateClassMaps should find AActor::K2_DestroyActor"), DestroyActorFunction)
		|| !TestNotNull(TEXT("GeneratedBlueprintCallableEntriesPopulateClassMaps should find UGameplayStatics::GetPlayerController"), GetPlayerControllerFunction)
		|| !TestNotNull(TEXT("GeneratedBlueprintCallableEntriesPopulateClassMaps should find UASClass::IsDeveloperOnly"), IsDeveloperOnlyFunction))
	{
		return false;
	}

	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> Engine = FAngelscriptEngine::CreateTestingFullEngine(FAngelscriptEngineConfig(), Dependencies);
	if (!TestTrue(TEXT("GeneratedBlueprintCallableEntriesPopulateClassMaps should create a testing engine"), Engine.IsValid()))
	{
		return false;
	}
	FAngelscriptEngineScope EngineScope(*Engine);

	auto& ClassFuncMaps = FAngelscriptBinds::GetClassFuncMaps();
	const TMap<FString, FFuncEntry>* ActorEntries = ClassFuncMaps.Find(AActor::StaticClass());
	const TMap<FString, FFuncEntry>* GameplayStaticsEntries = ClassFuncMaps.Find(UGameplayStatics::StaticClass());
	const TMap<FString, FFuncEntry>* ScriptClassEntries = ClassFuncMaps.Find(UASClass::StaticClass());
	if (!TestNotNull(TEXT("GeneratedBlueprintCallableEntriesPopulateClassMaps should populate entries for AActor"), ActorEntries)
		|| !TestNotNull(TEXT("GeneratedBlueprintCallableEntriesPopulateClassMaps should populate entries for UGameplayStatics"), GameplayStaticsEntries)
		|| !TestNotNull(TEXT("GeneratedBlueprintCallableEntriesPopulateClassMaps should populate entries for UASClass"), ScriptClassEntries))
	{
		return false;
	}

	const FFuncEntry* DestroyActorEntry = ActorEntries->Find(DestroyActorFunction->GetName());
	const FFuncEntry* GetPlayerControllerEntry = GameplayStaticsEntries->Find(GetPlayerControllerFunction->GetName());
	const FFuncEntry* IsDeveloperOnlyEntry = ScriptClassEntries->Find(IsDeveloperOnlyFunction->GetName());
	if (!TestNotNull(TEXT("GeneratedBlueprintCallableEntriesPopulateClassMaps should register AActor::K2_DestroyActor"), DestroyActorEntry)
		|| !TestNotNull(TEXT("GeneratedBlueprintCallableEntriesPopulateClassMaps should register UGameplayStatics::GetPlayerController"), GetPlayerControllerEntry)
		|| !TestNotNull(TEXT("GeneratedBlueprintCallableEntriesPopulateClassMaps should register UASClass::IsDeveloperOnly"), IsDeveloperOnlyEntry))
	{
		return false;
	}

	TestTrue(TEXT("GeneratedBlueprintCallableEntriesPopulateClassMaps should bind UASClass::IsDeveloperOnly to a direct native function entry"), IsFunctionEntryBound(*IsDeveloperOnlyEntry));
	return true;
}

bool FAngelscriptFunctionEntryDeduplicationTest::RunTest(const FString& Parameters)
{
	FAngelscriptBinds::ResetBindState();
	ON_SCOPE_EXIT
	{
		FAngelscriptBinds::ResetBindState();
	};

	const FString FunctionName = TEXT("K2_DestroyActor");
	const FFuncEntry FirstEntry = { ERASE_METHOD_PTR(AActor, K2_DestroyActor, (), ERASE_ARGUMENT_PACK(void)) };
	const FFuncEntry SecondEntry = { ERASE_NO_FUNCTION() };

	FAngelscriptBinds::AddFunctionEntry(AActor::StaticClass(), FunctionName, FirstEntry);
	FAngelscriptBinds::AddFunctionEntry(AActor::StaticClass(), FunctionName, SecondEntry);

	const TMap<FString, FFuncEntry>* ActorEntries = FAngelscriptBinds::GetClassFuncMaps().Find(AActor::StaticClass());
	if (!TestNotNull(TEXT("AddFunctionEntryPreservesFirstRegistration should create a function entry map for AActor"), ActorEntries))
	{
		return false;
	}

	const FFuncEntry* StoredEntry = ActorEntries->Find(FunctionName);
	if (!TestNotNull(TEXT("AddFunctionEntryPreservesFirstRegistration should keep the first function entry"), StoredEntry))
	{
		return false;
	}

	TestTrue(TEXT("AddFunctionEntryPreservesFirstRegistration should keep the first registration bound"), IsFunctionEntryBound(*StoredEntry));
	TestTrue(TEXT("AddFunctionEntryPreservesFirstRegistration should preserve the first stored function pointer and caller"), AreFunctionEntriesEqual(*StoredEntry, FirstEntry));
	TestFalse(TEXT("AddFunctionEntryPreservesFirstRegistration should ignore the later duplicate registration"), AreFunctionEntriesEqual(*StoredEntry, SecondEntry));
	return true;
}

bool FAngelscriptBlueprintInternalUseOnlyOverrideTest::RunTest(const FString& Parameters)
{
	UFunction* WithOverride = UAngelscriptUhtCoverageTestLibrary::StaticClass()->FindFunctionByName(TEXT("InternalCallableWithOverride"));
	UFunction* WithoutOverride = UAngelscriptUhtCoverageTestLibrary::StaticClass()->FindFunctionByName(TEXT("InternalCallableWithoutOverride"));
	if (!TestNotNull(TEXT("BlueprintInternalUseOnlyCanBeOverriddenForAngelscript should find the override test function"), WithOverride)
		|| !TestNotNull(TEXT("BlueprintInternalUseOnlyCanBeOverriddenForAngelscript should find the control test function"), WithoutOverride))
	{
		return false;
	}

	TestTrue(TEXT("BlueprintInternalUseOnlyCanBeOverriddenForAngelscript should keep the control function marked as BlueprintInternalUseOnly"), WithoutOverride->HasMetaData(TEXT("BlueprintInternalUseOnly")));
	TestTrue(TEXT("BlueprintInternalUseOnlyCanBeOverriddenForAngelscript should mark the override function as UsableInAngelscript"), WithOverride->HasMetaData(TEXT("UsableInAngelscript")));
	TestFalse(TEXT("BlueprintInternalUseOnlyCanBeOverriddenForAngelscript should not skip override-marked functions"), FAngelscriptBinds::ShouldSkipBlueprintCallableFunction(WithOverride));
	return TestTrue(TEXT("BlueprintInternalUseOnlyCanBeOverriddenForAngelscript should still skip BlueprintInternalUseOnly functions without an override"), FAngelscriptBinds::ShouldSkipBlueprintCallableFunction(WithoutOverride));
}

bool FAngelscriptScriptMethodMetadataCoverageTest::RunTest(const FString& Parameters)
{
	AngelscriptTestSupport::DestroySharedTestEngine();
	if (FAngelscriptEngine::IsInitialized())
	{
		FAngelscriptBindConfigTestAccess::DestroyGlobalEngine();
	}

	FAngelscriptBinds::ResetBindState();
	ON_SCOPE_EXIT
	{
		FAngelscriptBinds::ResetBindState();
		AngelscriptTestSupport::DestroySharedTestEngine();
		if (FAngelscriptEngine::IsInitialized())
		{
			FAngelscriptBindConfigTestAccess::DestroyGlobalEngine();
		}
	};

	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> Engine = FAngelscriptEngine::CreateTestingFullEngine(FAngelscriptEngineConfig(), Dependencies);
	if (!TestTrue(TEXT("FunctionLevelScriptMethodUsesFirstParameterAsMixin should create a testing engine"), Engine.IsValid()))
	{
		return false;
	}
	FAngelscriptEngineScope EngineScope(*Engine);

	TSharedPtr<FAngelscriptType> HostType = FAngelscriptType::GetByClass(UObject::StaticClass());
	UFunction* ScriptMethodFunction = UAngelscriptUhtCoverageTestLibrary::StaticClass()->FindFunctionByName(TEXT("GetCoverageValue"));
	if (!TestTrue(TEXT("FunctionLevelScriptMethodUsesFirstParameterAsMixin should resolve a host type for signature construction"), HostType.IsValid())
		|| !TestNotNull(TEXT("FunctionLevelScriptMethodUsesFirstParameterAsMixin should find the ScriptMethod test function"), ScriptMethodFunction))
	{
		return false;
	}

	FAngelscriptFunctionSignature Signature(HostType.ToSharedRef(), ScriptMethodFunction);
	TestTrue(TEXT("FunctionLevelScriptMethodUsesFirstParameterAsMixin should keep the Unreal function static"), Signature.bStaticInUnreal);
	TestFalse(TEXT("FunctionLevelScriptMethodUsesFirstParameterAsMixin should bind ScriptMethod functions as script members"), Signature.bStaticInScript);
	TestEqual(TEXT("FunctionLevelScriptMethodUsesFirstParameterAsMixin should remove the first parameter from the exposed signature"), Signature.ArgumentTypes.Num(), 0);
	TestTrue(TEXT("FunctionLevelScriptMethodUsesFirstParameterAsMixin should expose a const member declaration when the first parameter is const"), Signature.Declaration.Contains(TEXT("const")));
	return TestTrue(TEXT("FunctionLevelScriptMethodUsesFirstParameterAsMixin should keep the generated script name"), Signature.Declaration.Contains(TEXT("GetCoverageValue")));
}

bool FAngelscriptCallableWithoutWorldContextMetadataTest::RunTest(const FString& Parameters)
{
	AngelscriptTestSupport::DestroySharedTestEngine();
	if (FAngelscriptEngine::IsInitialized())
	{
		FAngelscriptBindConfigTestAccess::DestroyGlobalEngine();
	}

	FAngelscriptBinds::ResetBindState();
	ON_SCOPE_EXIT
	{
		FAngelscriptBinds::ResetBindState();
		AngelscriptTestSupport::DestroySharedTestEngine();
		if (FAngelscriptEngine::IsInitialized())
		{
			FAngelscriptBindConfigTestAccess::DestroyGlobalEngine();
		}
	};

	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> Engine = FAngelscriptEngine::CreateTestingFullEngine(FAngelscriptEngineConfig(), Dependencies);
	if (!TestTrue(TEXT("CallableWithoutWorldContextKeepsHiddenWorldContextButClearsTrait should create a testing engine"), Engine.IsValid()))
	{
		return false;
	}
	FAngelscriptEngineScope EngineScope(*Engine);

	TSharedPtr<FAngelscriptType> HostType = FAngelscriptType::GetByClass(UObject::StaticClass());
	UFunction* RequiredWorldContextFunction = UAngelscriptUhtCoverageTestLibrary::StaticClass()->FindFunctionByName(TEXT("RequiresWorldContext"));
	UFunction* OptionalWorldContextFunction = UAngelscriptUhtCoverageTestLibrary::StaticClass()->FindFunctionByName(TEXT("CallableWithoutWorldContext"));
	if (!TestTrue(TEXT("CallableWithoutWorldContextKeepsHiddenWorldContextButClearsTrait should resolve a host type for signature construction"), HostType.IsValid())
		|| !TestNotNull(TEXT("CallableWithoutWorldContextKeepsHiddenWorldContextButClearsTrait should find the required world-context function"), RequiredWorldContextFunction)
		|| !TestNotNull(TEXT("CallableWithoutWorldContextKeepsHiddenWorldContextButClearsTrait should find the optional world-context function"), OptionalWorldContextFunction))
	{
		return false;
	}

	FAngelscriptFunctionSignature RequiredSignature(HostType.ToSharedRef(), RequiredWorldContextFunction);
	FAngelscriptFunctionSignature OptionalSignature(HostType.ToSharedRef(), OptionalWorldContextFunction);

	int RequiredFunctionId = FAngelscriptBinds::BindGlobalGenericFunction(RequiredSignature.Declaration, &NoOpGeneric);
	int OptionalFunctionId = FAngelscriptBinds::BindGlobalGenericFunction(OptionalSignature.Declaration, &NoOpGeneric);
	RequiredSignature.ModifyScriptFunction(RequiredFunctionId);
	OptionalSignature.ModifyScriptFunction(OptionalFunctionId);

	auto* RequiredScriptFunction = reinterpret_cast<asCScriptFunction*>(FAngelscriptEngine::Get().GetScriptEngine()->GetFunctionById(RequiredFunctionId));
	auto* OptionalScriptFunction = reinterpret_cast<asCScriptFunction*>(FAngelscriptEngine::Get().GetScriptEngine()->GetFunctionById(OptionalFunctionId));
	if (!TestNotNull(TEXT("CallableWithoutWorldContextKeepsHiddenWorldContextButClearsTrait should create a script function for the required world-context case"), RequiredScriptFunction)
		|| !TestNotNull(TEXT("CallableWithoutWorldContextKeepsHiddenWorldContextButClearsTrait should create a script function for the optional world-context case"), OptionalScriptFunction))
	{
		return false;
	}

	TestEqual(TEXT("CallableWithoutWorldContextKeepsHiddenWorldContextButClearsTrait should hide the world-context argument for required functions"), RequiredScriptFunction->hiddenArgumentIndex, 0);
	TestEqual(TEXT("CallableWithoutWorldContextKeepsHiddenWorldContextButClearsTrait should hide the world-context argument for callable-without-world-context functions"), OptionalScriptFunction->hiddenArgumentIndex, 0);
	TestTrue(TEXT("CallableWithoutWorldContextKeepsHiddenWorldContextButClearsTrait should mark required world-context functions with the world-context trait"), RequiredScriptFunction->traits.GetTrait(asTRAIT_USES_WORLDCONTEXT));
	return TestFalse(TEXT("CallableWithoutWorldContextKeepsHiddenWorldContextButClearsTrait should not mark callable-without-world-context functions with the world-context trait"), OptionalScriptFunction->traits.GetTrait(asTRAIT_USES_WORLDCONTEXT));
}

bool FAngelscriptOverloadResolutionCoverageTest::RunTest(const FString& Parameters)
{
	AngelscriptTestSupport::DestroySharedTestEngine();
	if (FAngelscriptEngine::IsInitialized())
	{
		FAngelscriptBindConfigTestAccess::DestroyGlobalEngine();
	}

	FAngelscriptBinds::ResetBindState();
	ON_SCOPE_EXIT
	{
		FAngelscriptBinds::ResetBindState();
		AngelscriptTestSupport::DestroySharedTestEngine();
		if (FAngelscriptEngine::IsInitialized())
		{
			FAngelscriptBindConfigTestAccess::DestroyGlobalEngine();
		}
	};

	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> Engine = FAngelscriptEngine::CreateTestingFullEngine(FAngelscriptEngineConfig(), Dependencies);
	if (!TestTrue(TEXT("OverloadedExportedFunctionsCanRecoverDirectBind should create a testing engine"), Engine.IsValid()))
	{
		return false;
	}
	FAngelscriptEngineScope EngineScope(*Engine);

	UFunction* OverloadFunction = UAngelscriptUhtOverloadCoverageLibrary::StaticClass()->FindFunctionByName(TEXT("ResolveCoverageOverload"));
	if (!TestNotNull(TEXT("OverloadedExportedFunctionsCanRecoverDirectBind should find the reflected overload function"), OverloadFunction))
	{
		return false;
	}

	const TMap<FString, FFuncEntry>* OverloadEntries = FAngelscriptBinds::GetClassFuncMaps().Find(UAngelscriptUhtOverloadCoverageLibrary::StaticClass());
	if (!TestNotNull(TEXT("OverloadedExportedFunctionsCanRecoverDirectBind should populate entries for the overload test library"), OverloadEntries))
	{
		return false;
	}

	const FFuncEntry* OverloadEntry = OverloadEntries->Find(OverloadFunction->GetName());
	if (!TestNotNull(TEXT("OverloadedExportedFunctionsCanRecoverDirectBind should register the reflected overload function"), OverloadEntry))
	{
		return false;
	}

	return TestTrue(TEXT("OverloadedExportedFunctionsCanRecoverDirectBind should recover a direct bind instead of ERASE_NO_FUNCTION"), IsFunctionEntryBound(*OverloadEntry));
}

bool FAngelscriptInlineDefinitionCoverageTest::RunTest(const FString& Parameters)
{
	AngelscriptTestSupport::DestroySharedTestEngine();
	if (FAngelscriptEngine::IsInitialized())
	{
		FAngelscriptBindConfigTestAccess::DestroyGlobalEngine();
	}

	FAngelscriptBinds::ResetBindState();
	ON_SCOPE_EXIT
	{
		FAngelscriptBinds::ResetBindState();
		AngelscriptTestSupport::DestroySharedTestEngine();
		if (FAngelscriptEngine::IsInitialized())
		{
			FAngelscriptBindConfigTestAccess::DestroyGlobalEngine();
		}
	};

	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> Engine = FAngelscriptEngine::CreateTestingFullEngine(FAngelscriptEngineConfig(), Dependencies);
	if (!TestTrue(TEXT("InlineDefinitionFunctionsCanRecoverDirectBind should create a testing engine"), Engine.IsValid()))
	{
		return false;
	}
	FAngelscriptEngineScope EngineScope(*Engine);

	UFunction* InlineFunction = URuntimeFloatCurveMixinLibrary::StaticClass()->FindFunctionByName(TEXT("GetNumKeys"));
	if (!TestNotNull(TEXT("InlineDefinitionFunctionsCanRecoverDirectBind should find the reflected inline function"), InlineFunction))
	{
		return false;
	}

	const TMap<FString, FFuncEntry>* InlineEntries = FAngelscriptBinds::GetClassFuncMaps().Find(URuntimeFloatCurveMixinLibrary::StaticClass());
	if (!TestNotNull(TEXT("InlineDefinitionFunctionsCanRecoverDirectBind should populate entries for the inline function library"), InlineEntries))
	{
		return false;
	}

	const FFuncEntry* InlineEntry = InlineEntries->Find(InlineFunction->GetName());
	if (!TestNotNull(TEXT("InlineDefinitionFunctionsCanRecoverDirectBind should register the reflected inline function"), InlineEntry))
	{
		return false;
	}

	return TestTrue(TEXT("InlineDefinitionFunctionsCanRecoverDirectBind should recover a direct bind instead of ERASE_NO_FUNCTION"), IsFunctionEntryBound(*InlineEntry));
}

bool FAngelscriptInlineOutRefCoverageTest::RunTest(const FString& Parameters)
{
	AngelscriptTestSupport::DestroySharedTestEngine();
	if (FAngelscriptEngine::IsInitialized())
	{
		FAngelscriptBindConfigTestAccess::DestroyGlobalEngine();
	}

	FAngelscriptBinds::ResetBindState();
	ON_SCOPE_EXIT
	{
		FAngelscriptBinds::ResetBindState();
		AngelscriptTestSupport::DestroySharedTestEngine();
		if (FAngelscriptEngine::IsInitialized())
		{
			FAngelscriptBindConfigTestAccess::DestroyGlobalEngine();
		}
	};

	const FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
	TUniquePtr<FAngelscriptEngine> Engine = FAngelscriptEngine::CreateTestingFullEngine(FAngelscriptEngineConfig(), Dependencies);
	if (!TestTrue(TEXT("InlineOutRefFunctionsCanRecoverDirectBind should create a testing engine"), Engine.IsValid()))
	{
		return false;
	}
	FAngelscriptEngineScope EngineScope(*Engine);

	UFunction* InlineFunction = URuntimeFloatCurveMixinLibrary::StaticClass()->FindFunctionByName(TEXT("GetTimeRange"));
	if (!TestNotNull(TEXT("InlineOutRefFunctionsCanRecoverDirectBind should find the reflected out-ref function"), InlineFunction))
	{
		return false;
	}

	const TMap<FString, FFuncEntry>* InlineEntries = FAngelscriptBinds::GetClassFuncMaps().Find(URuntimeFloatCurveMixinLibrary::StaticClass());
	if (!TestNotNull(TEXT("InlineOutRefFunctionsCanRecoverDirectBind should populate entries for the inline function library"), InlineEntries))
	{
		return false;
	}

	const FFuncEntry* InlineEntry = InlineEntries->Find(InlineFunction->GetName());
	if (!TestNotNull(TEXT("InlineOutRefFunctionsCanRecoverDirectBind should register the reflected out-ref function"), InlineEntry))
	{
		return false;
	}

	return TestTrue(TEXT("InlineOutRefFunctionsCanRecoverDirectBind should recover a direct bind instead of ERASE_NO_FUNCTION"), IsFunctionEntryBound(*InlineEntry));
}

#endif
