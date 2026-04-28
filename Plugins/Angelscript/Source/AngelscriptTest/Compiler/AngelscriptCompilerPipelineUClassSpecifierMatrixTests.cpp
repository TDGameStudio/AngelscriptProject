#include "../Shared/AngelscriptTestEngineHelper.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/Class.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace UClassSpecifierMatrixTest
{
	static const FName AbstractModule(TEXT("Tests.Compiler.AbstractClassSpecifier"));
	static const FName BlueprintTypeModule(TEXT("Tests.Compiler.BlueprintTypeClassSpecifier"));
	static const FName DefaultToInstancedModule(TEXT("Tests.Compiler.DefaultToInstancedClassSpecifier"));
	static const FName DeprecatedModule(TEXT("Tests.Compiler.DeprecatedClassSpecifier"));
	static const FName HideCategoriesModule(TEXT("Tests.Compiler.HideCategoriesClassSpecifier"));
}

// ============================================================================
// Abstract -> CLASS_Abstract
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptAbstractClassSpecifierTest,
	"Angelscript.TestModule.Compiler.EndToEnd.AbstractClassSpecifierSetsFlag",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptAbstractClassSpecifierTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*UClassSpecifierMatrixTest::AbstractModule.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::Error;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		UClassSpecifierMatrixTest::AbstractModule,
		TEXT("Tests/Compiler/AbstractClassSpecifier.as"),
		TEXT(R"AS(
UCLASS(Abstract)
class UAbstractTestObj : UObject
{
	UPROPERTY()
	int Value;
}
)AS"),
		CompileResult);

	if (!TestTrue(TEXT("Abstract class specifier should compile"), bCompiled))
		return false;

	UClass* GeneratedClass = FindGeneratedClass(&Engine, TEXT("UAbstractTestObj"));
	if (!TestNotNull(TEXT("Class should exist"), GeneratedClass))
		return false;

	TestTrue(TEXT("Abstract should set CLASS_Abstract"), GeneratedClass->HasAnyClassFlags(CLASS_Abstract));

	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// BlueprintType -> Meta BlueprintType=true
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBlueprintTypeClassSpecifierTest,
	"Angelscript.TestModule.Compiler.EndToEnd.BlueprintTypeClassSpecifierSetsMeta",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptBlueprintTypeClassSpecifierTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*UClassSpecifierMatrixTest::BlueprintTypeModule.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::Error;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		UClassSpecifierMatrixTest::BlueprintTypeModule,
		TEXT("Tests/Compiler/BlueprintTypeClassSpecifier.as"),
		TEXT(R"AS(
UCLASS(BlueprintType)
class UBlueprintTypeTestObj : UObject
{
	UPROPERTY()
	int Value;
}
)AS"),
		CompileResult);

	if (!TestTrue(TEXT("BlueprintType class specifier should compile"), bCompiled))
		return false;

	UClass* GeneratedClass = FindGeneratedClass(&Engine, TEXT("UBlueprintTypeTestObj"));
	if (!TestNotNull(TEXT("Class should exist"), GeneratedClass))
		return false;

	TestTrue(TEXT("BlueprintType should set metadata"),
		GeneratedClass->HasMetaData(TEXT("BlueprintType")));

	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// DefaultToInstanced -> CLASS_DefaultToInstanced
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDefaultToInstancedClassSpecifierTest,
	"Angelscript.TestModule.Compiler.EndToEnd.DefaultToInstancedClassSpecifierSetsFlag",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDefaultToInstancedClassSpecifierTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*UClassSpecifierMatrixTest::DefaultToInstancedModule.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::Error;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		UClassSpecifierMatrixTest::DefaultToInstancedModule,
		TEXT("Tests/Compiler/DefaultToInstancedClassSpecifier.as"),
		TEXT(R"AS(
UCLASS(DefaultToInstanced)
class UInstancedTestObj : UObject
{
	UPROPERTY()
	int Value;
}
)AS"),
		CompileResult);

	if (!TestTrue(TEXT("DefaultToInstanced class specifier should compile"), bCompiled))
		return false;

	UClass* GeneratedClass = FindGeneratedClass(&Engine, TEXT("UInstancedTestObj"));
	if (!TestNotNull(TEXT("Class should exist"), GeneratedClass))
		return false;

	TestTrue(TEXT("DefaultToInstanced should set CLASS_DefaultToInstanced"),
		GeneratedClass->HasAnyClassFlags(CLASS_DefaultToInstanced));

	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// Deprecated -> CLASS_Deprecated
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDeprecatedClassSpecifierTest,
	"Angelscript.TestModule.Compiler.EndToEnd.DeprecatedClassSpecifierSetsFlag",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDeprecatedClassSpecifierTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*UClassSpecifierMatrixTest::DeprecatedModule.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::Error;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		UClassSpecifierMatrixTest::DeprecatedModule,
		TEXT("Tests/Compiler/DeprecatedClassSpecifier.as"),
		TEXT(R"AS(
UCLASS(Deprecated)
class UDeprecatedTestObj : UObject
{
	UPROPERTY()
	int Value;
}
)AS"),
		CompileResult);

	if (!TestTrue(TEXT("Deprecated class specifier should compile"), bCompiled))
		return false;

	UClass* GeneratedClass = FindGeneratedClass(&Engine, TEXT("UDeprecatedTestObj"));
	if (!TestNotNull(TEXT("Class should exist"), GeneratedClass))
		return false;

	TestTrue(TEXT("Deprecated should set CLASS_Deprecated"),
		GeneratedClass->HasAnyClassFlags(CLASS_Deprecated));

	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// HideCategories -> Meta HideCategories
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptHideCategoriesClassSpecifierTest,
	"Angelscript.TestModule.Compiler.EndToEnd.HideCategoriesClassSpecifierSetsMeta",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptHideCategoriesClassSpecifierTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*UClassSpecifierMatrixTest::HideCategoriesModule.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::Error;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		UClassSpecifierMatrixTest::HideCategoriesModule,
		TEXT("Tests/Compiler/HideCategoriesClassSpecifier.as"),
		TEXT(R"AS(
UCLASS(HideCategories = "Rendering")
class UHideCategoriesTestObj : UObject
{
	UPROPERTY()
	int Value;
}
)AS"),
		CompileResult);

	if (!TestTrue(TEXT("HideCategories class specifier should compile"), bCompiled))
		return false;

	UClass* GeneratedClass = FindGeneratedClass(&Engine, TEXT("UHideCategoriesTestObj"));
	if (!TestNotNull(TEXT("Class should exist"), GeneratedClass))
		return false;

	TestTrue(TEXT("HideCategories should set metadata"),
		GeneratedClass->HasMetaData(TEXT("HideCategories")));

	ASTEST_END_SHARE_CLEAN
	return true;
}

#endif
