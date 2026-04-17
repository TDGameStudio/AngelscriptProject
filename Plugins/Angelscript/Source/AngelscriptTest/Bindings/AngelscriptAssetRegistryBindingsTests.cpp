#include "../Shared/AngelscriptTestMacros.h"
#include "../Shared/AngelscriptTestUtilities.h"

#include "AssetRegistry/AssetRegistryModule.h"
#include "Engine/Blueprint.h"
#include "GameFramework/Actor.h"
#include "Misc/ScopeExit.h"
#include "Templates/Function.h"
#include "UObject/SoftObjectPath.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Bindings_AngelscriptAssetRegistryBindingsTests_Private
{
	static constexpr ANSICHAR AssetRegistryBindingsModuleName[] = "ASAssetRegistryTopLevelPathAndNullParent";
	static constexpr ANSICHAR AssetRegistryQueryCompatModuleName[] = "ASAssetRegistryQueryCompat";

	IAssetRegistry& GetAssetRegistryChecked()
	{
		FAssetRegistryModule& AssetRegistryModule = FModuleManager::Get().LoadModuleChecked<FAssetRegistryModule>(TEXT("AssetRegistry"));
		return AssetRegistryModule.Get();
	}

	bool ContainsAssetObjectPath(const TArray<FAssetData>& Assets, const FString& ObjectPath)
	{
		return Assets.ContainsByPredicate([&ObjectPath](const FAssetData& AssetData)
		{
			return AssetData.GetObjectPathString() == ObjectPath;
		});
	}

	bool SetArgAddressChecked(
		FAutomationTestBase& Test,
		asIScriptContext& Context,
		asUINT ArgumentIndex,
		void* Address,
		const TCHAR* ContextLabel)
	{
		return Test.TestEqual(
			*FString::Printf(TEXT("%s should bind address argument %u"), ContextLabel, static_cast<uint32>(ArgumentIndex)),
			Context.SetArgAddress(ArgumentIndex, Address),
			static_cast<int32>(asSUCCESS));
	}

	bool ExecuteFunctionExpectingException(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		asIScriptModule& Module,
		const TCHAR* FunctionDecl,
		TFunctionRef<bool(asIScriptContext&)> BindArguments,
		const TCHAR* ContextLabel,
		FString& OutExceptionString)
	{
		asIScriptFunction* Function = GetFunctionByDecl(Test, Module, FunctionDecl);
		if (Function == nullptr)
		{
			return false;
		}

		FAngelscriptEngineScope EngineScope(Engine);
		asIScriptContext* Context = Engine.CreateContext();
		if (!Test.TestNotNull(*FString::Printf(TEXT("%s should create an execution context"), ContextLabel), Context))
		{
			return false;
		}

		ON_SCOPE_EXIT
		{
			Context->Release();
		};

		const int PrepareResult = Context->Prepare(Function);
		if (!Test.TestEqual(
			*FString::Printf(TEXT("%s should prepare successfully"), ContextLabel),
			PrepareResult,
			static_cast<int32>(asSUCCESS)))
		{
			return false;
		}

		if (!BindArguments(*Context))
		{
			return false;
		}

		const int ExecuteResult = Context->Execute();
		if (!Test.TestEqual(
			*FString::Printf(TEXT("%s should fail with a script exception"), ContextLabel),
			ExecuteResult,
			static_cast<int32>(asEXECUTION_EXCEPTION)))
		{
			return false;
		}

		OutExceptionString = Context->GetExceptionString() != nullptr ? UTF8_TO_TCHAR(Context->GetExceptionString()) : TEXT("");
		return true;
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptAssetRegistryBindingsTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptAssetRegistryBindingsTest,
	"Angelscript.TestModule.Bindings.AssetRegistryTopLevelPathAndNullParent",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptAssetRegistryQueryCompatTest,
	"Angelscript.TestModule.Bindings.AssetRegistryQueryCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptAssetRegistryBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	AddExpectedError(TEXT("A null Class was passed to GetBlueprintCDOsByParentClass."), EAutomationExpectedErrorFlags::Contains, 0);
	AddExpectedError(TEXT("ASAssetRegistryTopLevelPathAndNullParent"), EAutomationExpectedErrorFlags::Contains, 0);
	AddExpectedError(TEXT("void TriggerNullParent(UObject[]&)"), EAutomationExpectedErrorFlags::Contains, 0, false);

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASAssetRegistryTopLevelPathAndNullParent"));
	};

	const FString Script = TEXT(R"(
int Entry()
{
	FTopLevelAssetPath PathFromClass(AActor::StaticClass());
	if (!PathFromClass.IsValid())
		return 10;
	if (PathFromClass.IsNull())
		return 20;

	FString PathString = PathFromClass.ToString();
	if (PathString.IsEmpty())
		return 30;

	FTopLevelAssetPath PathFromString(PathString);
	if (!PathFromString.IsValid())
		return 40;
	if (!(PathFromString == PathFromClass))
		return 50;

	FTopLevelAssetPath AssignedPath;
	AssignedPath = PathString;
	if (!(AssignedPath == PathFromClass))
		return 60;

	TArray<FAssetData> Assets;
	if (!AssetRegistry::GetAssetsByClass(FTopLevelAssetPath(UBlueprint::StaticClass()), Assets))
		return 70;

	for (int Index = 0; Index < Assets.Num(); ++Index)
	{
		if (Assets[Index].GetObjectPathString().IsEmpty())
			return 80;
		if (Assets[Index].GetSoftObjectPath().ToString().IsEmpty())
			return 90;
	}

	return Assets.Num() + 1;
}

void TriggerNullParent(TArray<UObject>& OutAssets)
{
	UClass NullClass;
	AssetRegistry::GetBlueprintCDOsByParentClass(NullClass, OutAssets);
}
)");

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		AssetRegistryBindingsModuleName,
		Script);
	if (Module == nullptr)
	{
		return false;
	}

	TArray<FAssetData> NativeAssets;
	const bool bNativeQuerySucceeded = GetAssetRegistryChecked().GetAssetsByClass(FTopLevelAssetPath(UBlueprint::StaticClass()), NativeAssets);
	if (!TestTrue(TEXT("Native AssetRegistry GetAssetsByClass(UBlueprint) baseline should succeed"), bNativeQuerySucceeded))
	{
		return false;
	}

	asIScriptFunction* EntryFunction = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (EntryFunction == nullptr)
	{
		return false;
	}

	int32 ScriptResult = INDEX_NONE;
	if (!ExecuteIntFunction(*this, Engine, *EntryFunction, ScriptResult))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("FTopLevelAssetPath round-trip and AssetRegistry::GetAssetsByClass should preserve the native UBlueprint asset count and non-empty paths"),
		ScriptResult,
		NativeAssets.Num() + 1);

	TArray<UObject*> NativeBlueprintCDOs;
	FString ExceptionString;
	if (!ExecuteFunctionExpectingException(
		*this,
		Engine,
		*Module,
		TEXT("void TriggerNullParent(TArray<UObject>& OutAssets)"),
		[this, &NativeBlueprintCDOs](asIScriptContext& Context)
		{
			return SetArgAddressChecked(*this, Context, 0, &NativeBlueprintCDOs, TEXT("TriggerNullParent"));
		},
		TEXT("TriggerNullParent"),
		ExceptionString))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("GetBlueprintCDOsByParentClass(null, ...) should report the expected exception text"),
		ExceptionString,
		FString(TEXT("A null Class was passed to GetBlueprintCDOsByParentClass.")));
	bPassed &= TestEqual(
		TEXT("GetBlueprintCDOsByParentClass(null, ...) should leave the output array empty"),
		NativeBlueprintCDOs.Num(),
		0);

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

bool FAngelscriptAssetRegistryQueryCompatTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASAssetRegistryQueryCompat"));
	};

	static const FName EngineMaterialsPath(TEXT("/Engine/EngineMaterials"));
	static const FString TargetObjectPath(TEXT("/Engine/EngineMaterials/DefaultMaterial.DefaultMaterial"));

	IAssetRegistry& AssetRegistry = GetAssetRegistryChecked();
	const bool bNativeHasAssets = AssetRegistry.HasAssets(EngineMaterialsPath, false);

	TArray<FAssetData> NativeAssetsByPath;
	const bool bNativeGetAssetsByPath = AssetRegistry.GetAssetsByPath(EngineMaterialsPath, NativeAssetsByPath, false, false);

	const FAssetData NativeAssetByObjectPath = AssetRegistry.GetAssetByObjectPath(FSoftObjectPath(TargetObjectPath), false);
	const FString NativeObjectPathString = NativeAssetByObjectPath.GetObjectPathString();
	const FString NativeSoftObjectPathString = NativeAssetByObjectPath.GetSoftObjectPath().ToString();

	TArray<FAssetData> NativeAllAssets;
	const bool bNativeGetAllAssets = AssetRegistry.GetAllAssets(NativeAllAssets, false);
	const bool bNativeAllAssetsContainTarget = ContainsAssetObjectPath(NativeAllAssets, TargetObjectPath);

	const FTopLevelAssetPath NativeTopLevelPath(TargetObjectPath);
	const FString NativeTopLevelPathString = NativeTopLevelPath.ToString();

	if (!TestTrue(TEXT("Native AssetRegistry HasAssets(/Engine/EngineMaterials) baseline should be true"), bNativeHasAssets)
		|| !TestTrue(TEXT("Native AssetRegistry GetAssetsByPath(/Engine/EngineMaterials) baseline should succeed"), bNativeGetAssetsByPath)
		|| !TestTrue(TEXT("Native AssetRegistry GetAssetByObjectPath(DefaultMaterial) baseline should resolve the known engine asset"), NativeObjectPathString == TargetObjectPath)
		|| !TestTrue(TEXT("Native AssetRegistry GetAllAssets baseline should succeed"), bNativeGetAllAssets)
		|| !TestTrue(TEXT("Native AssetRegistry GetAllAssets baseline should contain the known engine asset"), bNativeAllAssetsContainTarget)
		|| !TestTrue(TEXT("Native FTopLevelAssetPath(DefaultMaterial) baseline should be valid"), NativeTopLevelPath.IsValid()))
	{
		return false;
	}

	FString Script = TEXT(R"(
int Entry()
{
	const FString TargetObjectPath = "__TARGET_OBJECT_PATH__";
	const FString ExpectedTopLevelPath = "__EXPECTED_TOP_LEVEL_PATH__";
	const bool bExpectedHasAssets = __EXPECTED_HAS_ASSETS__;
	const bool bExpectedGetAssetsByPath = __EXPECTED_GET_ASSETS_BY_PATH__;
	const bool bExpectedGetAllAssets = __EXPECTED_GET_ALL_ASSETS__;
	const bool bExpectedAllAssetsContainTarget = __EXPECTED_ALL_ASSETS_CONTAIN_TARGET__;
	const int ExpectedAssetsByPathCount = __EXPECTED_ASSETS_BY_PATH_COUNT__;
	const int ExpectedAllAssetsCount = __EXPECTED_ALL_ASSETS_COUNT__;
	const FString ExpectedObjectPathString = "__EXPECTED_OBJECT_PATH_STRING__";
	const FString ExpectedSoftObjectPathString = "__EXPECTED_SOFT_OBJECT_PATH_STRING__";

	FTopLevelAssetPath PathFromString(TargetObjectPath);
	if (!PathFromString.IsValid())
		return 10;
	if (PathFromString.IsNull())
		return 20;
	if (PathFromString.ToString() != ExpectedTopLevelPath)
		return 30;

	if (AssetRegistry::HasAssets(n"__ENGINE_MATERIALS_PATH__", false) != bExpectedHasAssets)
		return 40;

	TArray<FAssetData> AssetsByPath;
	if (AssetRegistry::GetAssetsByPath(n"__ENGINE_MATERIALS_PATH__", AssetsByPath, false, false) != bExpectedGetAssetsByPath)
		return 50;
	if (AssetsByPath.Num() != ExpectedAssetsByPathCount)
		return 60;

	bool bFoundTargetByPath = false;
	for (int Index = 0; Index < AssetsByPath.Num(); ++Index)
	{
		FString AssetObjectPathString = AssetsByPath[Index].GetObjectPathString();
		if (AssetObjectPathString == ExpectedObjectPathString)
		{
			bFoundTargetByPath = true;
			if (AssetsByPath[Index].GetSoftObjectPath().ToString() != ExpectedSoftObjectPathString)
				return 70;
		}
	}
	if (!bFoundTargetByPath)
		return 80;

	FAssetData AssetByObjectPath = AssetRegistry::GetAssetByObjectPath(FSoftObjectPath(TargetObjectPath), false);
	if (AssetByObjectPath.GetObjectPathString() != ExpectedObjectPathString)
		return 90;
	if (AssetByObjectPath.GetSoftObjectPath().ToString() != ExpectedSoftObjectPathString)
		return 100;

	TArray<FAssetData> AllAssets;
	if (AssetRegistry::GetAllAssets(AllAssets, false) != bExpectedGetAllAssets)
		return 110;
	if (AllAssets.Num() != ExpectedAllAssetsCount)
		return 120;

	bool bFoundTargetInAllAssets = false;
	for (int Index = 0; Index < AllAssets.Num(); ++Index)
	{
		if (AllAssets[Index].GetObjectPathString() == ExpectedObjectPathString)
		{
			bFoundTargetInAllAssets = true;
			break;
		}
	}
	if (bFoundTargetInAllAssets != bExpectedAllAssetsContainTarget)
		return 130;

	return 0;
}
)");

	Script.ReplaceInline(TEXT("__TARGET_OBJECT_PATH__"), *TargetObjectPath, ESearchCase::CaseSensitive);
	Script.ReplaceInline(TEXT("__EXPECTED_TOP_LEVEL_PATH__"), *NativeTopLevelPathString, ESearchCase::CaseSensitive);
	Script.ReplaceInline(TEXT("__EXPECTED_HAS_ASSETS__"), bNativeHasAssets ? TEXT("true") : TEXT("false"), ESearchCase::CaseSensitive);
	Script.ReplaceInline(TEXT("__EXPECTED_GET_ASSETS_BY_PATH__"), bNativeGetAssetsByPath ? TEXT("true") : TEXT("false"), ESearchCase::CaseSensitive);
	Script.ReplaceInline(TEXT("__EXPECTED_GET_ALL_ASSETS__"), bNativeGetAllAssets ? TEXT("true") : TEXT("false"), ESearchCase::CaseSensitive);
	Script.ReplaceInline(TEXT("__EXPECTED_ALL_ASSETS_CONTAIN_TARGET__"), bNativeAllAssetsContainTarget ? TEXT("true") : TEXT("false"), ESearchCase::CaseSensitive);
	Script.ReplaceInline(TEXT("__EXPECTED_ASSETS_BY_PATH_COUNT__"), *FString::FromInt(NativeAssetsByPath.Num()), ESearchCase::CaseSensitive);
	Script.ReplaceInline(TEXT("__EXPECTED_ALL_ASSETS_COUNT__"), *FString::FromInt(NativeAllAssets.Num()), ESearchCase::CaseSensitive);
	Script.ReplaceInline(TEXT("__EXPECTED_OBJECT_PATH_STRING__"), *NativeObjectPathString, ESearchCase::CaseSensitive);
	Script.ReplaceInline(TEXT("__EXPECTED_SOFT_OBJECT_PATH_STRING__"), *NativeSoftObjectPathString, ESearchCase::CaseSensitive);
	Script.ReplaceInline(TEXT("__ENGINE_MATERIALS_PATH__"), *EngineMaterialsPath.ToString(), ESearchCase::CaseSensitive);

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		AssetRegistryQueryCompatModuleName,
		Script);
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}

	int32 Result = INDEX_NONE;
	if (!ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}

	TestEqual(TEXT("AssetRegistry query compat operations should match native baselines"), Result, 0);
	ASTEST_END_SHARE_CLEAN

	return true;
}

#endif
