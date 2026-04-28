#include "../Shared/AngelscriptTestEngineHelper.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/UnrealType.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace UPropertySpecifierMatrixTest
{
	static const FName EditConstModule(TEXT("Tests.Compiler.EditConstSpecifier"));
	static const FName NotEditableModule(TEXT("Tests.Compiler.NotEditableSpecifier"));
	static const FName AdvancedDisplayModule(TEXT("Tests.Compiler.AdvancedDisplaySpecifier"));
	static const FName SaveGameModule(TEXT("Tests.Compiler.SaveGameSpecifier"));
	static const FName TransientModule(TEXT("Tests.Compiler.TransientSpecifier"));
	static const FName ConfigModule(TEXT("Tests.Compiler.ConfigSpecifier"));
}

// ============================================================================
// EditConst -> CPF_EditConst
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptEditConstSpecifierTest,
	"Angelscript.TestModule.Compiler.EndToEnd.EditConstSpecifierSetsCPFEditConst",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptEditConstSpecifierTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*UPropertySpecifierMatrixTest::EditConstModule.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::Error;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		UPropertySpecifierMatrixTest::EditConstModule,
		TEXT("Tests/Compiler/EditConstSpecifier.as"),
		TEXT(R"AS(
UCLASS()
class UEditConstTestObj : UObject
{
	UPROPERTY(EditConst)
	int LockedValue;
}
)AS"),
		CompileResult);

	if (!TestTrue(TEXT("EditConst should compile"), bCompiled))
		return false;

	UClass* GeneratedClass = FindGeneratedClass(&Engine, TEXT("UEditConstTestObj"));
	if (!TestNotNull(TEXT("Class should exist"), GeneratedClass))
		return false;

	FProperty* Prop = GeneratedClass->FindPropertyByName(TEXT("LockedValue"));
	if (!TestNotNull(TEXT("Property should exist"), Prop))
		return false;

	TestTrue(TEXT("EditConst should set CPF_EditConst"), Prop->HasAnyPropertyFlags(CPF_EditConst));

	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// NotEditable -> no CPF_Edit
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptNotEditableSpecifierTest,
	"Angelscript.TestModule.Compiler.EndToEnd.NotEditableSpecifierClearsCPFEdit",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptNotEditableSpecifierTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*UPropertySpecifierMatrixTest::NotEditableModule.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::Error;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		UPropertySpecifierMatrixTest::NotEditableModule,
		TEXT("Tests/Compiler/NotEditableSpecifier.as"),
		TEXT(R"AS(
UCLASS()
class UNotEditableTestObj : UObject
{
	UPROPERTY(NotEditable)
	int HiddenValue;
}
)AS"),
		CompileResult);

	if (!TestTrue(TEXT("NotEditable should compile"), bCompiled))
		return false;

	UClass* GeneratedClass = FindGeneratedClass(&Engine, TEXT("UNotEditableTestObj"));
	if (!TestNotNull(TEXT("Class should exist"), GeneratedClass))
		return false;

	FProperty* Prop = GeneratedClass->FindPropertyByName(TEXT("HiddenValue"));
	if (!TestNotNull(TEXT("Property should exist"), Prop))
		return false;

	TestFalse(TEXT("NotEditable should clear CPF_Edit"), Prop->HasAnyPropertyFlags(CPF_Edit));

	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// AdvancedDisplay -> CPF_AdvancedDisplay
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptAdvancedDisplaySpecifierTest,
	"Angelscript.TestModule.Compiler.EndToEnd.AdvancedDisplaySpecifierSetsCPFAdvancedDisplay",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptAdvancedDisplaySpecifierTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*UPropertySpecifierMatrixTest::AdvancedDisplayModule.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::Error;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		UPropertySpecifierMatrixTest::AdvancedDisplayModule,
		TEXT("Tests/Compiler/AdvancedDisplaySpecifier.as"),
		TEXT(R"AS(
UCLASS()
class UAdvancedDisplayTestObj : UObject
{
	UPROPERTY(AdvancedDisplay)
	int AdvancedProp;
}
)AS"),
		CompileResult);

	if (!TestTrue(TEXT("AdvancedDisplay should compile"), bCompiled))
		return false;

	UClass* GeneratedClass = FindGeneratedClass(&Engine, TEXT("UAdvancedDisplayTestObj"));
	if (!TestNotNull(TEXT("Class should exist"), GeneratedClass))
		return false;

	FProperty* Prop = GeneratedClass->FindPropertyByName(TEXT("AdvancedProp"));
	if (!TestNotNull(TEXT("Property should exist"), Prop))
		return false;

	TestTrue(TEXT("AdvancedDisplay should set CPF_AdvancedDisplay"), Prop->HasAnyPropertyFlags(CPF_AdvancedDisplay));

	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// SaveGame -> CPF_SaveGame
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptSaveGameSpecifierTest,
	"Angelscript.TestModule.Compiler.EndToEnd.SaveGameSpecifierSetsCPFSaveGame",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptSaveGameSpecifierTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*UPropertySpecifierMatrixTest::SaveGameModule.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::Error;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		UPropertySpecifierMatrixTest::SaveGameModule,
		TEXT("Tests/Compiler/SaveGameSpecifier.as"),
		TEXT(R"AS(
UCLASS()
class USaveGameTestObj : UObject
{
	UPROPERTY(SaveGame)
	int SavedScore;
}
)AS"),
		CompileResult);

	if (!TestTrue(TEXT("SaveGame should compile"), bCompiled))
		return false;

	UClass* GeneratedClass = FindGeneratedClass(&Engine, TEXT("USaveGameTestObj"));
	if (!TestNotNull(TEXT("Class should exist"), GeneratedClass))
		return false;

	FProperty* Prop = GeneratedClass->FindPropertyByName(TEXT("SavedScore"));
	if (!TestNotNull(TEXT("Property should exist"), Prop))
		return false;

	TestTrue(TEXT("SaveGame should set CPF_SaveGame"), Prop->HasAnyPropertyFlags(CPF_SaveGame));

	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// Transient -> CPF_Transient
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTransientSpecifierTest,
	"Angelscript.TestModule.Compiler.EndToEnd.TransientSpecifierSetsCPFTransient",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptTransientSpecifierTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*UPropertySpecifierMatrixTest::TransientModule.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::Error;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		UPropertySpecifierMatrixTest::TransientModule,
		TEXT("Tests/Compiler/TransientSpecifier.as"),
		TEXT(R"AS(
UCLASS()
class UTransientTestObj : UObject
{
	UPROPERTY(Transient)
	int CachedValue;
}
)AS"),
		CompileResult);

	if (!TestTrue(TEXT("Transient should compile"), bCompiled))
		return false;

	UClass* GeneratedClass = FindGeneratedClass(&Engine, TEXT("UTransientTestObj"));
	if (!TestNotNull(TEXT("Class should exist"), GeneratedClass))
		return false;

	FProperty* Prop = GeneratedClass->FindPropertyByName(TEXT("CachedValue"));
	if (!TestNotNull(TEXT("Property should exist"), Prop))
		return false;

	TestTrue(TEXT("Transient should set CPF_Transient"), Prop->HasAnyPropertyFlags(CPF_Transient));

	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// Config -> CPF_Config
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptConfigSpecifierTest,
	"Angelscript.TestModule.Compiler.EndToEnd.ConfigSpecifierSetsCPFConfig",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptConfigSpecifierTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*UPropertySpecifierMatrixTest::ConfigModule.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::Error;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		UPropertySpecifierMatrixTest::ConfigModule,
		TEXT("Tests/Compiler/ConfigSpecifier.as"),
		TEXT(R"AS(
UCLASS(Config=Game)
class UConfigTestObj : UObject
{
	UPROPERTY(Config)
	int ConfigValue;
}
)AS"),
		CompileResult);

	if (!TestTrue(TEXT("Config should compile"), bCompiled))
		return false;

	UClass* GeneratedClass = FindGeneratedClass(&Engine, TEXT("UConfigTestObj"));
	if (!TestNotNull(TEXT("Class should exist"), GeneratedClass))
		return false;

	FProperty* Prop = GeneratedClass->FindPropertyByName(TEXT("ConfigValue"));
	if (!TestNotNull(TEXT("Property should exist"), Prop))
		return false;

	TestTrue(TEXT("Config should set CPF_Config"), Prop->HasAnyPropertyFlags(CPF_Config));

	ASTEST_END_SHARE_CLEAN
	return true;
}

#endif
