#include "Shared/AngelscriptTestEngineHelper.h"
#include "Shared/AngelscriptTestMacros.h"

#include "ClassGenerator/ASStruct.h"
#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/Paths.h"
#include "Misc/ScopeExit.h"
#include "UObject/UObjectGlobals.h"
#include "UObject/UnrealType.h"

// Test Layer: Runtime Integration
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace ASGeneratedTypeIdentityTest
{
	static const FName StructModuleName(TEXT("ASGeneratedStructIdentity"));
	static const FName StructName(TEXT("StructIdentityTarget"));
	static const FString StructScriptFilename(TEXT("ASGeneratedStructIdentity.as"));

	FString GetScriptAbsoluteFilename()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), StructScriptFilename);
	}

	UScriptStruct* FindStructObjectByName(const FName InStructName)
	{
		return FindObject<UScriptStruct>(FAngelscriptEngine::GetPackage(), *InStructName.ToString());
	}

	UASStruct* FindCurrentStruct()
	{
		return Cast<UASStruct>(FindStructObjectByName(StructName));
	}

	bool VerifyHandledReloadResult(FAutomationTestBase& Test, const TCHAR* Context, const ECompileResult ReloadResult)
	{
		return Test.TestTrue(
			Context,
			ReloadResult == ECompileResult::FullyHandled || ReloadResult == ECompileResult::PartiallyHandled);
	}

	bool VerifyLiveStructIdentity(
		FAutomationTestBase& Test,
		UASStruct* Struct,
		const TCHAR* StageLabel)
	{
		const FString StructMessage = FString::Printf(TEXT("%s should publish a generated UASStruct"), StageLabel);
		if (!Test.TestNotNull(*StructMessage, Struct))
		{
			return false;
		}

		const bool bIsScriptStructMatches = Test.TestTrue(
			*FString::Printf(TEXT("%s should mark the struct as script-generated"), StageLabel),
			Struct->bIsScriptStruct);
		const bool bScriptTypeMatches = Test.TestNotNull(
			*FString::Printf(TEXT("%s should publish a live script type pointer"), StageLabel),
			Struct->ScriptType);
		const bool bNewestVersionMatches = Test.TestEqual(
			*FString::Printf(TEXT("%s should resolve GetNewestVersion to itself while canonical"), StageLabel),
			Struct->GetNewestVersion(),
			static_cast<UScriptStruct*>(Struct));
		return bIsScriptStructMatches && bScriptTypeMatches && bNewestVersionMatches;
	}

	bool VerifyReplacedStructIdentity(
		FAutomationTestBase& Test,
		UASStruct* Struct,
		UASStruct* ExpectedNewestVersion,
		const TCHAR* StageLabel)
	{
		const FString StructMessage = FString::Printf(TEXT("%s should keep the replaced struct alive for version-chain lookups"), StageLabel);
		if (!Test.TestNotNull(*StructMessage, Struct))
		{
			return false;
		}

		const bool bIsScriptStructMatches = Test.TestTrue(
			*FString::Printf(TEXT("%s should keep the replaced struct tagged as a script struct"), StageLabel),
			Struct->bIsScriptStruct);
		const bool bNewestVersionMatches = Test.TestEqual(
			*FString::Printf(TEXT("%s should point GetNewestVersion at the replacement struct"), StageLabel),
			Struct->GetNewestVersion(),
			static_cast<UScriptStruct*>(ExpectedNewestVersion));
		const bool bDirectVersionLinkMatches = Test.TestEqual(
			*FString::Printf(TEXT("%s should wire NewerVersion directly to the replacement struct"), StageLabel),
			Struct->NewerVersion,
			ExpectedNewestVersion);
		const bool bClearedScriptTypeMatches = Test.TestNull(
			*FString::Printf(TEXT("%s should clear the stale script type pointer after full reload"), StageLabel),
			Struct->ScriptType);
		return bIsScriptStructMatches
			&& bNewestVersionMatches
			&& bDirectVersionLinkMatches
			&& bClearedScriptTypeMatches;
	}
}

using namespace ASGeneratedTypeIdentityTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptASStructScriptIdentityFieldsTrackFullReloadLifecycleTest,
	"Angelscript.TestModule.ClassGenerator.ASStruct.ScriptIdentityFieldsTrackFullReloadLifecycle",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptASStructScriptIdentityFieldsTrackFullReloadLifecycleTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ASGeneratedTypeIdentityTest::StructModuleName.ToString());
		IFileManager::Get().Delete(*ASGeneratedTypeIdentityTest::GetScriptAbsoluteFilename(), false, true, true);
		ResetSharedCloneEngine(Engine);
	};

	const FString ScriptV1 = TEXT(R"AS(
USTRUCT()
struct FStructIdentityTarget
{
	UPROPERTY()
	int Value = 1;
};
)AS");

	const FString ScriptV2 = TEXT(R"AS(
USTRUCT()
struct FStructIdentityTarget
{
	UPROPERTY()
	int Value = 1;

	UPROPERTY()
	int AddedValue = 2;
};
)AS");

	if (!TestTrue(
			TEXT("Struct identity baseline compile should succeed"),
			CompileAnnotatedModuleFromMemory(&Engine, ASGeneratedTypeIdentityTest::StructModuleName, ASGeneratedTypeIdentityTest::StructScriptFilename, ScriptV1)))
	{
		return false;
	}

	UASStruct* StructV1 = ASGeneratedTypeIdentityTest::FindCurrentStruct();
	if (!ASGeneratedTypeIdentityTest::VerifyLiveStructIdentity(*this, StructV1, TEXT("Struct identity baseline")))
	{
		return false;
	}

	bPassed &= TestNull(
		TEXT("Struct identity baseline should not publish a newer version link before reload"),
		StructV1->NewerVersion);
	bPassed &= TestNull(
		TEXT("Struct identity baseline should not expose the structural-change property before reload"),
		StructV1->FindPropertyByName(TEXT("AddedValue")));

	ECompileResult ReloadResult = ECompileResult::Error;
	if (!TestTrue(
			TEXT("Struct identity full reload should compile successfully"),
			CompileModuleWithResult(
				&Engine,
				ECompileType::FullReload,
				ASGeneratedTypeIdentityTest::StructModuleName,
				ASGeneratedTypeIdentityTest::StructScriptFilename,
				ScriptV2,
				ReloadResult)))
	{
		return false;
	}

	if (!ASGeneratedTypeIdentityTest::VerifyHandledReloadResult(
			*this,
			TEXT("Struct identity full reload should be handled by the full reload pipeline"),
			ReloadResult))
	{
		return false;
	}

	UASStruct* StructV2 = ASGeneratedTypeIdentityTest::FindCurrentStruct();
	if (!ASGeneratedTypeIdentityTest::VerifyLiveStructIdentity(*this, StructV2, TEXT("Struct identity replacement")))
	{
		return false;
	}

	bPassed &= TestNotEqual(
		TEXT("Struct identity full reload should replace the canonical struct object"),
		static_cast<UScriptStruct*>(StructV1),
		static_cast<UScriptStruct*>(StructV2));
	bPassed &= TestNotNull(
		TEXT("Struct identity replacement should expose the newly added reflected property"),
		StructV2->FindPropertyByName(TEXT("AddedValue")));
	bPassed &= TestNull(
		TEXT("Struct identity replacement should become the leaf of the version chain"),
		StructV2->NewerVersion);
	bPassed &= TestNull(
		TEXT("Struct identity replaced struct should keep its original reflected layout"),
		StructV1->FindPropertyByName(TEXT("AddedValue")));
	bPassed &= ASGeneratedTypeIdentityTest::VerifyReplacedStructIdentity(
		*this,
		StructV1,
		StructV2,
		TEXT("Struct identity replaced struct"));

	ASTEST_END_SHARE_FRESH
	return bPassed;
}

#endif
