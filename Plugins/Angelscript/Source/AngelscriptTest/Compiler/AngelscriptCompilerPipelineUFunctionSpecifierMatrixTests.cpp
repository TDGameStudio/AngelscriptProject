#include "../Shared/AngelscriptTestEngineHelper.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/UnrealType.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace UFunctionSpecifierMatrixTest
{
	static const FName CallInEditorModule(TEXT("Tests.Compiler.CallInEditorSpecifier"));
	static const FName AuthorityOnlyModule(TEXT("Tests.Compiler.BlueprintAuthorityOnlySpecifier"));
	static const FName ExecModule(TEXT("Tests.Compiler.ExecSpecifier"));
}

// ============================================================================
// CallInEditor specifier
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCallInEditorSpecifierTest,
	"Angelscript.TestModule.Compiler.EndToEnd.CallInEditorSpecifierSetsFlag",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptCallInEditorSpecifierTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*UFunctionSpecifierMatrixTest::CallInEditorModule.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::Error;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		UFunctionSpecifierMatrixTest::CallInEditorModule,
		TEXT("Tests/Compiler/CallInEditorSpecifier.as"),
		TEXT(R"AS(
UCLASS()
class UCallInEditorTestObj : UObject
{
	UFUNCTION(CallInEditor)
	void EditorOnlyAction()
	{
	}
}
)AS"),
		CompileResult);

	if (!TestTrue(TEXT("CallInEditor specifier should compile"), bCompiled))
		return false;

	UClass* GeneratedClass = FindGeneratedClass(&Engine, TEXT("UCallInEditorTestObj"));
	if (!TestNotNull(TEXT("Class should be materialized"), GeneratedClass))
		return false;

	UFunction* Func = GeneratedClass->FindFunctionByName(TEXT("EditorOnlyAction"));
	if (!TestNotNull(TEXT("Function should exist"), Func))
		return false;

	TestTrue(TEXT("CallInEditor function should have CallInEditor metadata"),
		Func->HasMetaData(TEXT("CallInEditor")));

	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// BlueprintAuthorityOnly specifier
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBlueprintAuthorityOnlySpecifierTest,
	"Angelscript.TestModule.Compiler.EndToEnd.BlueprintAuthorityOnlySpecifierSetsFlag",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptBlueprintAuthorityOnlySpecifierTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*UFunctionSpecifierMatrixTest::AuthorityOnlyModule.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::Error;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		UFunctionSpecifierMatrixTest::AuthorityOnlyModule,
		TEXT("Tests/Compiler/BlueprintAuthorityOnlySpecifier.as"),
		TEXT(R"AS(
UCLASS()
class UAuthorityOnlyTestObj : UObject
{
	UFUNCTION(BlueprintAuthorityOnly)
	void AuthorityAction()
	{
	}
}
)AS"),
		CompileResult);

	if (!TestTrue(TEXT("BlueprintAuthorityOnly specifier should compile"), bCompiled))
		return false;

	UClass* GeneratedClass = FindGeneratedClass(&Engine, TEXT("UAuthorityOnlyTestObj"));
	if (!TestNotNull(TEXT("Class should be materialized"), GeneratedClass))
		return false;

	UFunction* Func = GeneratedClass->FindFunctionByName(TEXT("AuthorityAction"));
	if (!TestNotNull(TEXT("Function should exist"), Func))
		return false;

	TestTrue(TEXT("BlueprintAuthorityOnly should set FUNC_BlueprintAuthorityOnly"),
		Func->HasAnyFunctionFlags(FUNC_BlueprintAuthorityOnly));

	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// Exec specifier
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptExecSpecifierTest,
	"Angelscript.TestModule.Compiler.EndToEnd.ExecSpecifierSetsFlag",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptExecSpecifierTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*UFunctionSpecifierMatrixTest::ExecModule.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::Error;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		UFunctionSpecifierMatrixTest::ExecModule,
		TEXT("Tests/Compiler/ExecSpecifier.as"),
		TEXT(R"AS(
UCLASS()
class UExecTestObj : UObject
{
	UFUNCTION(Exec)
	void ConsoleCommand()
	{
	}
}
)AS"),
		CompileResult);

	if (!TestTrue(TEXT("Exec specifier should compile"), bCompiled))
		return false;

	UClass* GeneratedClass = FindGeneratedClass(&Engine, TEXT("UExecTestObj"));
	if (!TestNotNull(TEXT("Class should be materialized"), GeneratedClass))
		return false;

	UFunction* Func = GeneratedClass->FindFunctionByName(TEXT("ConsoleCommand"));
	if (!TestNotNull(TEXT("Function should exist"), Func))
		return false;

	TestTrue(TEXT("Exec should set FUNC_Exec flag"),
		Func->HasAnyFunctionFlags(FUNC_Exec));

	ASTEST_END_SHARE_CLEAN
	return true;
}

#endif
