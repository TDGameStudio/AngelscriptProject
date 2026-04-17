#include "../Shared/AngelscriptTestMacros.h"
#include "../Shared/AngelscriptTestEngineHelper.h"
#include "../Shared/AngelscriptTestUtilities.h"

#include "FunctionLibraries/UAssetManagerMixinLibrary.h"

#include "Engine/AssetManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/UnrealType.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Bindings_AngelscriptAssetManagerFunctionLibraryTests_Private
{
	static constexpr ANSICHAR AssetManagerGuardModuleName[] = "ASAssetManagerNullAndInvalidCallbackGuards";
	static constexpr TCHAR AssetManagerGuardFilename[] = TEXT("ASAssetManagerNullAndInvalidCallbackGuards.as");
	static constexpr TCHAR ValidReceiverClassName[] = TEXT("UAssetManagerValidScanReceiver");
	static constexpr TCHAR MissingReceiverClassName[] = TEXT("UAssetManagerMissingScanReceiver");
	static constexpr TCHAR CallbackCountPropertyName[] = TEXT("CallbackCount");

	bool ReadIntPropertyChecked(
		FAutomationTestBase& Test,
		UObject& Object,
		FName PropertyName,
		const TCHAR* ContextLabel,
		int32& OutValue)
	{
		FIntProperty* Property = FindFProperty<FIntProperty>(Object.GetClass(), PropertyName);
		if (!Test.TestNotNull(
			*FString::Printf(TEXT("%s should expose int property '%s'"), ContextLabel, *PropertyName.ToString()),
			Property))
		{
			return false;
		}

		OutValue = Property->GetPropertyValue_InContainer(&Object);
		return true;
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptAssetManagerFunctionLibraryTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptAssetManagerNullAndInvalidCallbackGuardsTest,
	"Angelscript.TestModule.FunctionLibraries.AssetManagerNullAndInvalidCallbackGuards",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptAssetManagerNullAndInvalidCallbackGuardsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASAssetManagerNullAndInvalidCallbackGuards"));
	};

	const FString ReceiverScript = TEXT(R"AS(
UCLASS()
class UAssetManagerValidScanReceiver : UObject
{
	UPROPERTY()
	int CallbackCount;

	UFUNCTION()
	void OnScanComplete()
	{
		CallbackCount += 1;
	}
}

UCLASS()
class UAssetManagerMissingScanReceiver : UObject
{
	UPROPERTY()
	int CallbackCount;

	UFUNCTION()
	void DifferentFunction()
	{
		CallbackCount += 1;
	}
}
)AS");

	if (!TestTrue(
			TEXT("AssetManager guard test should compile the callback receiver module"),
			CompileAnnotatedModuleFromMemory(&Engine, TEXT("ASAssetManagerNullAndInvalidCallbackGuards"), AssetManagerGuardFilename, ReceiverScript)))
	{
		return false;
	}

	UClass* ValidReceiverClass = FindGeneratedClass(&Engine, ValidReceiverClassName);
	UClass* MissingReceiverClass = FindGeneratedClass(&Engine, MissingReceiverClassName);
	if (!TestNotNull(TEXT("AssetManager guard test should generate the valid callback receiver class"), ValidReceiverClass)
		|| !TestNotNull(TEXT("AssetManager guard test should generate the missing-callback receiver class"), MissingReceiverClass))
	{
		return false;
	}

	UObject* ValidReceiver = NewObject<UObject>(GetTransientPackage(), ValidReceiverClass);
	UObject* MissingReceiver = NewObject<UObject>(GetTransientPackage(), MissingReceiverClass);
	if (!TestNotNull(TEXT("AssetManager guard test should instantiate the valid callback receiver"), ValidReceiver)
		|| !TestNotNull(TEXT("AssetManager guard test should instantiate the missing-callback receiver"), MissingReceiver))
	{
		return false;
	}

	UAssetManager* AssetManager = UAssetManager::GetIfInitialized();
	if (!TestNotNull(TEXT("AssetManager guard test should resolve an initialized asset manager"), AssetManager))
	{
		return false;
	}

	if (!TestTrue(TEXT("AssetManager guard test requires the asset manager initial scan to be complete"), AssetManager->HasInitialScanCompleted()))
	{
		return false;
	}

	const FPrimaryAssetId DummyPrimaryAssetId(TEXT("MissingType"), TEXT("MissingName"));
	const FPrimaryAssetType DummyPrimaryAssetType(TEXT("MissingType"));

	FAssetData AssetData;
	TArray<FAssetData> AssetDataList;
	AssetDataList.AddDefaulted();
	TArray<FPrimaryAssetId> PrimaryAssetIdList;
	PrimaryAssetIdList.Add(DummyPrimaryAssetId);
	FPrimaryAssetTypeInfo AssetTypeInfo(FName(TEXT("DirtyType")), UObject::StaticClass(), false, false);
	TArray<FPrimaryAssetTypeInfo> AssetTypeInfoList;
	AssetTypeInfoList.Add(FPrimaryAssetTypeInfo(FName(TEXT("DirtyListType")), UObject::StaticClass(), false, false));
	const FPrimaryAssetRules DefaultRules;
	const FPrimaryAssetTypeInfo DefaultTypeInfo;

	if (!TestFalse(
			TEXT("Null asset manager should fail GetPrimaryAssetData"),
			UAssetManagerMixinLibrary::GetPrimaryAssetData(nullptr, DummyPrimaryAssetId, AssetData))
		|| !TestFalse(
			TEXT("Null asset manager should fail GetPrimaryAssetDataList"),
			UAssetManagerMixinLibrary::GetPrimaryAssetDataList(nullptr, DummyPrimaryAssetType, AssetDataList))
		|| !TestNull(
			TEXT("Null asset manager should return null from GetPrimaryAssetObject"),
			UAssetManagerMixinLibrary::GetPrimaryAssetObject(nullptr, DummyPrimaryAssetId))
		|| !TestFalse(
			TEXT("Null asset manager should return an invalid primary asset id for objects"),
			UAssetManagerMixinLibrary::GetPrimaryAssetIdForObject(nullptr, ValidReceiver).IsValid())
		|| !TestFalse(
			TEXT("Null asset manager should fail GetPrimaryAssetIdList"),
			UAssetManagerMixinLibrary::GetPrimaryAssetIdList(nullptr, DummyPrimaryAssetType, PrimaryAssetIdList))
		|| !TestFalse(
			TEXT("Null asset manager should fail GetPrimaryAssetTypeInfo"),
			UAssetManagerMixinLibrary::GetPrimaryAssetTypeInfo(nullptr, DummyPrimaryAssetType, AssetTypeInfo)))
	{
		return false;
	}

	UAssetManagerMixinLibrary::GetPrimaryAssetTypeInfoList(nullptr, AssetTypeInfoList);
	const FPrimaryAssetRules Rules = UAssetManagerMixinLibrary::GetPrimaryAssetRules(nullptr, DummyPrimaryAssetId);

	if (!TestFalse(TEXT("Null asset manager should leave asset data invalid"), AssetData.IsValid())
		|| !TestEqual(TEXT("Null asset manager should clear the asset data list"), AssetDataList.Num(), 0)
		|| !TestEqual(TEXT("Null asset manager should clear the primary asset id list"), PrimaryAssetIdList.Num(), 0)
		|| !TestEqual(TEXT("Null asset manager should reset the primary asset type info type"), AssetTypeInfo.PrimaryAssetType, DefaultTypeInfo.PrimaryAssetType)
		|| !TestTrue(TEXT("Null asset manager should reset the primary asset type info base class to UObject"), AssetTypeInfo.AssetBaseClassLoaded.Get() == UObject::StaticClass())
		|| !TestEqual(TEXT("Null asset manager should reset the primary asset type info dynamic flag"), AssetTypeInfo.bIsDynamicAsset, DefaultTypeInfo.bIsDynamicAsset)
		|| !TestEqual(TEXT("Null asset manager should reset the primary asset type info asset count"), AssetTypeInfo.NumberOfAssets, DefaultTypeInfo.NumberOfAssets)
		|| !TestEqual(TEXT("Null asset manager should reset the primary asset type info scan paths"), AssetTypeInfo.AssetScanPaths.Num(), DefaultTypeInfo.AssetScanPaths.Num())
		|| !TestEqual(TEXT("Null asset manager should reset the primary asset type info rules"), AssetTypeInfo.Rules, DefaultRules)
		|| !TestEqual(TEXT("Null asset manager should clear the asset type info list"), AssetTypeInfoList.Num(), 0)
		|| !TestEqual(TEXT("Null asset manager should return default primary asset rules"), Rules, DefaultRules))
	{
		return false;
	}

	int32 ValidCallbackCount = INDEX_NONE;
	int32 MissingCallbackCount = INDEX_NONE;
	if (!ReadIntPropertyChecked(*this, *ValidReceiver, CallbackCountPropertyName, TEXT("Valid asset manager receiver"), ValidCallbackCount)
		|| !ReadIntPropertyChecked(*this, *MissingReceiver, CallbackCountPropertyName, TEXT("Missing asset manager receiver"), MissingCallbackCount))
	{
		return false;
	}

	UAssetManagerMixinLibrary::CallOrRegister_OnCompletedInitialScan(nullptr, ValidReceiver, TEXT("OnScanComplete"));
	UAssetManagerMixinLibrary::CallOrRegister_OnCompletedInitialScan(AssetManager, nullptr, TEXT("OnScanComplete"));
	UAssetManagerMixinLibrary::CallOrRegister_OnCompletedInitialScan(AssetManager, MissingReceiver, TEXT("OnScanComplete"));
	UAssetManagerMixinLibrary::CallOrRegister_OnCompletedInitialScan(AssetManager, ValidReceiver, TEXT("DoesNotExist"));

	if (!ReadIntPropertyChecked(*this, *ValidReceiver, CallbackCountPropertyName, TEXT("Valid asset manager receiver after invalid callbacks"), ValidCallbackCount)
		|| !ReadIntPropertyChecked(*this, *MissingReceiver, CallbackCountPropertyName, TEXT("Missing asset manager receiver after invalid callbacks"), MissingCallbackCount))
	{
		return false;
	}

	if (!TestEqual(
			TEXT("Invalid asset manager callback inputs should not trigger the valid receiver"),
			ValidCallbackCount,
			0)
		|| !TestEqual(
			TEXT("Invalid asset manager callback inputs should not trigger the missing-callback receiver"),
			MissingCallbackCount,
			0))
	{
		return false;
	}

	UAssetManagerMixinLibrary::CallOrRegister_OnCompletedInitialScan(AssetManager, ValidReceiver, TEXT("OnScanComplete"));
	if (!ReadIntPropertyChecked(*this, *ValidReceiver, CallbackCountPropertyName, TEXT("Valid asset manager receiver after baseline callback"), ValidCallbackCount))
	{
		return false;
	}

	TestEqual(TEXT("Valid asset manager callback path should still trigger exactly once"), ValidCallbackCount, 1);
	ASTEST_END_SHARE_CLEAN

	return true;
}

#endif
