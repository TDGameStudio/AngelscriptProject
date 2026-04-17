#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestEngineHelper.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

// Test Layer: Runtime Integration
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace LiteralAssetPostInitTest
{
	static const FName ModuleName(TEXT("ASLiteralAssetPostInit"));
	static const FString ScriptFilename(TEXT("ASLiteralAssetPostInit.as"));
	static const FName GeneratedClassName(TEXT("ULiteralPostInitAsset"));
	static const FName AssetName(TEXT("ExampleAsset"));
	static const FName WasPostInitPropertyName(TEXT("bWasPostInit"));
	static const FName PostInitCallsPropertyName(TEXT("PostInitCalls"));
	static const FName InitMarkerPropertyName(TEXT("InitMarker"));
	static constexpr int32 ExpectedInitMarker = 1337;

	struct FLiteralAssetSnapshot
	{
		bool bWasPostInit = false;
		int32 PostInitCalls = INDEX_NONE;
		int32 InitMarker = INDEX_NONE;
	};

	UObject* FindLiteralAsset()
	{
		return FindObject<UObject>(FAngelscriptEngine::Get().AssetsPackage, *AssetName.ToString());
	}

	UClass* CompileLiteralAssetCarrier(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine)
	{
		const FString ScriptSource = TEXT(R"AS(
UCLASS()
class ULiteralPostInitAsset : UObject
{
	UPROPERTY()
	bool bWasPostInit = false;

	UPROPERTY()
	int PostInitCalls = 0;

	UPROPERTY()
	int InitMarker = 0;
}

asset ExampleAsset of ULiteralPostInitAsset
{
	bWasPostInit = true;
	PostInitCalls += 1;
	InitMarker = 1337;
}

int TouchExampleAssetAgain()
{
	ULiteralPostInitAsset ExampleAsset = GetExampleAsset();
	if (ExampleAsset == null)
		return -1;

	return ExampleAsset.InitMarker;
}
)AS");

		return CompileScriptModule(
			Test,
			Engine,
			ModuleName,
			ScriptFilename,
			ScriptSource,
			GeneratedClassName);
	}

	bool ReadLiteralAssetSnapshot(
		FAutomationTestBase& Test,
		UObject* Object,
		FLiteralAssetSnapshot& OutSnapshot)
	{
		if (!ReadPropertyValue<FBoolProperty>(Test, Object, WasPostInitPropertyName, OutSnapshot.bWasPostInit))
		{
			return false;
		}

		if (!ReadPropertyValue<FIntProperty>(Test, Object, PostInitCallsPropertyName, OutSnapshot.PostInitCalls))
		{
			return false;
		}

		if (!ReadPropertyValue<FIntProperty>(Test, Object, InitMarkerPropertyName, OutSnapshot.InitMarker))
		{
			return false;
		}

		return true;
	}

	bool ExecuteModuleInt(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		const FString& Declaration,
		const TCHAR* Context,
		int32& OutResult)
	{
		const bool bExecuted = ExecuteIntFunction(&Engine, ModuleName, Declaration, OutResult);
		return Test.TestTrue(Context, bExecuted);
	}
}

using namespace LiteralAssetPostInitTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptLiteralAssetPostInitMaterializesAssetOnceTest,
	"Angelscript.TestModule.ClassGenerator.LiteralAsset.PostInitMaterializesAssetOnce",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptLiteralAssetPostInitMaterializesAssetOnceTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	AddExpectedError(TEXT("LogUObjectBase: Class pointer is invalid or CDO is invalid."), EAutomationExpectedErrorFlags::Contains, 1);

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*LiteralAssetPostInitTest::ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* GeneratedClass = LiteralAssetPostInitTest::CompileLiteralAssetCarrier(*this, Engine);
	if (!TestNotNull(
			TEXT("Literal-asset post-init scenario should compile the generated asset carrier class"),
			GeneratedClass))
	{
		return false;
	}

	UObject* LiteralAssetBeforeTouch = LiteralAssetPostInitTest::FindLiteralAsset();
	if (!TestNotNull(
			TEXT("Literal-asset post-init scenario should materialize the asset object before any explicit getter call"),
			LiteralAssetBeforeTouch))
	{
		return false;
	}

	LiteralAssetPostInitTest::FLiteralAssetSnapshot SnapshotBeforeTouch;
	if (!LiteralAssetPostInitTest::ReadLiteralAssetSnapshot(*this, LiteralAssetBeforeTouch, SnapshotBeforeTouch))
	{
		return false;
	}

	if (!TestEqual(
			TEXT("Literal-asset post-init scenario should keep the generated literal asset on the expected script class"),
			LiteralAssetBeforeTouch->GetClass(),
			GeneratedClass)
		|| !TestEqual(
			TEXT("Literal-asset post-init scenario should execute __Init_ExampleAsset exactly once during compile teardown"),
			SnapshotBeforeTouch.PostInitCalls,
			1)
		|| !TestTrue(
			TEXT("Literal-asset post-init scenario should preserve the bool flag written by __Init_ExampleAsset"),
			SnapshotBeforeTouch.bWasPostInit)
		|| !TestEqual(
			TEXT("Literal-asset post-init scenario should preserve the init marker written by __Init_ExampleAsset"),
			SnapshotBeforeTouch.InitMarker,
			LiteralAssetPostInitTest::ExpectedInitMarker))
	{
		return false;
	}

	int32 TouchResult = INDEX_NONE;
	if (!LiteralAssetPostInitTest::ExecuteModuleInt(
			*this,
			Engine,
			TEXT("int TouchExampleAssetAgain()"),
			TEXT("Literal-asset post-init test should execute TouchExampleAssetAgain()"),
			TouchResult))
	{
		return false;
	}

	UObject* LiteralAssetAfterTouch = LiteralAssetPostInitTest::FindLiteralAsset();
	if (!TestNotNull(
			TEXT("Literal-asset post-init scenario should still expose the canonical asset after repeated getter access"),
			LiteralAssetAfterTouch))
	{
		return false;
	}

	LiteralAssetPostInitTest::FLiteralAssetSnapshot SnapshotAfterTouch;
	if (!LiteralAssetPostInitTest::ReadLiteralAssetSnapshot(*this, LiteralAssetAfterTouch, SnapshotAfterTouch))
	{
		return false;
	}

	TestEqual(
		TEXT("Literal-asset post-init test should return the initialized marker when the generated getter is touched again"),
		TouchResult,
		LiteralAssetPostInitTest::ExpectedInitMarker);
	TestTrue(
		TEXT("Literal-asset post-init test should keep returning the same materialized asset on repeated getter access"),
		LiteralAssetAfterTouch == LiteralAssetBeforeTouch);
	TestEqual(
		TEXT("Literal-asset post-init test should not rerun __Init_ExampleAsset when the generated getter is touched again"),
		SnapshotAfterTouch.PostInitCalls,
		1);
	TestTrue(
		TEXT("Literal-asset post-init test should preserve the bool flag after repeated getter access"),
		SnapshotAfterTouch.bWasPostInit);
	TestEqual(
		TEXT("Literal-asset post-init test should preserve the init marker after repeated getter access"),
		SnapshotAfterTouch.InitMarker,
		LiteralAssetPostInitTest::ExpectedInitMarker);

	ASTEST_END_SHARE_FRESH
	return true;
}

namespace LiteralAssetPostInitNameCollisionTest
{
	static const FName ModuleName(TEXT("ASLiteralAssetPostInitNameCollision"));
	static const FString ScriptFilename(TEXT("ASLiteralAssetPostInitNameCollision.as"));
	static const FName GeneratedClassName(TEXT("ULiteralPostInitCollisionAsset"));
	static const FName AssetName(TEXT("CollisionExampleAsset"));
	static const FName RightCallsPropertyName(TEXT("RightCalls"));
	static const FName WrongCallsPropertyName(TEXT("WrongCalls"));

	struct FLiteralAssetCollisionSnapshot
	{
		int32 RightCalls = INDEX_NONE;
		int32 WrongCalls = INDEX_NONE;
	};

	UObject* FindLiteralAsset()
	{
		return FindObject<UObject>(FAngelscriptEngine::Get().AssetsPackage, *AssetName.ToString());
	}

	UClass* CompileLiteralAssetCarrier(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine)
	{
		const FString ScriptSource = TEXT(R"AS(
UCLASS()
class ULiteralPostInitCollisionAsset : UObject
{
	UPROPERTY()
	int RightCalls = 0;

	UPROPERTY()
	int WrongCalls = 0;
}

namespace Shadow
{
	UObject GetCollisionExampleAsset()
	{
		ULiteralPostInitCollisionAsset ExampleAsset = Cast<ULiteralPostInitCollisionAsset>(__CreateLiteralAsset(ULiteralPostInitCollisionAsset, "CollisionExampleAsset"));
		if (ExampleAsset != null)
		{
			ExampleAsset.WrongCalls += 1;
			__PostLiteralAssetSetup(ExampleAsset, "CollisionExampleAsset");
		}
		return ExampleAsset;
	}
}

asset CollisionExampleAsset of ULiteralPostInitCollisionAsset
{
	RightCalls += 1;
}

int TouchExampleAssetAgain()
{
	ULiteralPostInitCollisionAsset ExampleAsset = GetCollisionExampleAsset();
	return ExampleAsset == null ? 0 : 1;
}
)AS");

		return CompileScriptModule(
			Test,
			Engine,
			ModuleName,
			ScriptFilename,
			ScriptSource,
			GeneratedClassName);
	}

	bool ReadLiteralAssetSnapshot(
		FAutomationTestBase& Test,
		UObject* Object,
		FLiteralAssetCollisionSnapshot& OutSnapshot)
	{
		if (!ReadPropertyValue<FIntProperty>(Test, Object, RightCallsPropertyName, OutSnapshot.RightCalls))
		{
			return false;
		}

		if (!ReadPropertyValue<FIntProperty>(Test, Object, WrongCallsPropertyName, OutSnapshot.WrongCalls))
		{
			return false;
		}

		return true;
	}

	bool ExecuteModuleInt(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		const FString& Declaration,
		const TCHAR* Context,
		int32& OutResult)
	{
		const bool bExecuted = ExecuteIntFunction(&Engine, ModuleName, Declaration, OutResult);
		return Test.TestTrue(Context, bExecuted);
	}
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptLiteralAssetPostInitResolvesGeneratedGetterInsteadOfNameCollisionTest,
	"Angelscript.TestModule.ClassGenerator.LiteralAsset.PostInitResolvesGeneratedGetterInsteadOfNameCollision",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptLiteralAssetPostInitResolvesGeneratedGetterInsteadOfNameCollisionTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	AddExpectedError(TEXT("LogUObjectBase: Class pointer is invalid or CDO is invalid."), EAutomationExpectedErrorFlags::Contains, 1);

	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*LiteralAssetPostInitNameCollisionTest::ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* GeneratedClass = LiteralAssetPostInitNameCollisionTest::CompileLiteralAssetCarrier(*this, Engine);
	if (!TestNotNull(
			TEXT("Literal-asset short-name collision scenario should compile the generated asset carrier class"),
			GeneratedClass))
	{
		return false;
	}

	UObject* LiteralAssetAfterCompile = LiteralAssetPostInitNameCollisionTest::FindLiteralAsset();
	if (!TestNotNull(
			TEXT("Literal-asset short-name collision scenario should materialize the canonical asset during compile teardown"),
			LiteralAssetAfterCompile))
	{
		return false;
	}

	LiteralAssetPostInitNameCollisionTest::FLiteralAssetCollisionSnapshot SnapshotAfterCompile;
	if (!LiteralAssetPostInitNameCollisionTest::ReadLiteralAssetSnapshot(*this, LiteralAssetAfterCompile, SnapshotAfterCompile))
	{
		return false;
	}

	if (!TestEqual(
			TEXT("Literal-asset short-name collision scenario should keep the materialized asset on the generated carrier class"),
			LiteralAssetAfterCompile->GetClass(),
			GeneratedClass)
		|| !TestEqual(
			TEXT("Literal-asset short-name collision scenario should execute the generated getter exactly once during post-init"),
			SnapshotAfterCompile.RightCalls,
			1)
		|| !TestEqual(
			TEXT("Literal-asset short-name collision scenario should never execute the namespaced short-name collision getter during post-init"),
			SnapshotAfterCompile.WrongCalls,
			0))
	{
		return false;
	}

	int32 TouchResult = INDEX_NONE;
	if (!LiteralAssetPostInitNameCollisionTest::ExecuteModuleInt(
			*this,
			Engine,
			TEXT("int TouchExampleAssetAgain()"),
			TEXT("Literal-asset short-name collision test should execute TouchExampleAssetAgain()"),
			TouchResult))
	{
		return false;
	}

	UObject* LiteralAssetAfterTouch = LiteralAssetPostInitNameCollisionTest::FindLiteralAsset();
	if (!TestNotNull(
			TEXT("Literal-asset short-name collision scenario should still expose the canonical asset after the explicit getter touch"),
			LiteralAssetAfterTouch))
	{
		return false;
	}

	LiteralAssetPostInitNameCollisionTest::FLiteralAssetCollisionSnapshot SnapshotAfterTouch;
	if (!LiteralAssetPostInitNameCollisionTest::ReadLiteralAssetSnapshot(*this, LiteralAssetAfterTouch, SnapshotAfterTouch))
	{
		return false;
	}

	TestEqual(
		TEXT("Literal-asset short-name collision test should return a non-null result when the explicit getter is touched again"),
		TouchResult,
		1);
	TestTrue(
		TEXT("Literal-asset short-name collision test should keep returning the same canonical asset on repeated getter access"),
		LiteralAssetAfterTouch == LiteralAssetAfterCompile);
	TestEqual(
		TEXT("Literal-asset short-name collision test should keep the generated getter hit count stable after explicit getter access"),
		SnapshotAfterTouch.RightCalls,
		1);
	TestEqual(
		TEXT("Literal-asset short-name collision test should keep the namespaced collision getter hit count at zero after explicit getter access"),
		SnapshotAfterTouch.WrongCalls,
		0);

	ASTEST_END_SHARE_FRESH
	return true;
}

#endif
