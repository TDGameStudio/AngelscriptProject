#include "Shared/AngelscriptFunctionalTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "ClassGenerator/AngelscriptClassGenerator.h"
#include "Components/ActorTestSpawner.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

// Test Layer: UE Scenario
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Inheritance_AngelscriptInheritanceScenarioTests_Private
{
	using namespace AngelscriptFunctionalTestUtils;

	void InitializeInheritanceScenarioSpawner(FActorTestSpawner& Spawner)
	{
		Spawner.InitializeGameSubsystems();
	}
}

using namespace AngelscriptTest_Inheritance_AngelscriptInheritanceScenarioTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestInheritanceScriptToScriptTest,
	"Angelscript.TestModule.Inheritance.ScriptToScript",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestInheritanceSuperTest,
	"Angelscript.TestModule.Inheritance.Super",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptTestInheritanceIsATest,
	"Angelscript.TestModule.Inheritance.IsA",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptTestInheritanceScriptToScriptTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("TestInheritanceScriptToScript"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	const FString BaselineScript = TEXT(R"AS(
UCLASS()
class ATestInheritanceBaseline : AActor
{
}
)AS");
	if (!TestTrue(TEXT("Scenario inheritance baseline module should compile before reload analysis"),
		CompileAnnotatedModuleFromMemory(&Engine, ModuleName, TEXT("TestInheritanceScriptToScript.as"), BaselineScript)))
	{
		return false;
	}

	FAngelscriptClassGenerator::EReloadRequirement ReloadRequirement = FAngelscriptClassGenerator::Error;
	bool bWantsFullReload = false;
	bool bNeedsFullReload = false;
	const bool bAnalyzed = AnalyzeReloadFromMemory(
		&Engine,
		ModuleName,
		TEXT("TestInheritanceScriptToScript.as"),
		TEXT(R"AS(
UCLASS()
class ATestInheritanceBase : AActor
{
	UFUNCTION()
	int GetScenarioValue()
	{
		return 1;
	}
}

UCLASS()
class ATestInheritanceDerived : AScenarioInheritanceBase
{
	UFUNCTION()
	int GetScenarioValue()
	{
		return 2;
	}
}
)AS"),
		ReloadRequirement,
		bWantsFullReload,
		bNeedsFullReload);

	if (!TestFalse(TEXT("Scenario script-to-script actor inheritance with overridden UFUNCTIONs remains unsupported on this branch"), bAnalyzed))
	{
		return false;
	}

	TestEqual(TEXT("Scenario script-to-script actor inheritance should currently stay in the error state"), ReloadRequirement, FAngelscriptClassGenerator::Error);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptTestInheritanceSuperTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("TestInheritanceSuper"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	const FString BaselineScript = TEXT(R"AS(
UCLASS()
class ATestInheritanceSuperBaseline : AActor
{
}
)AS");
	if (!TestTrue(TEXT("Scenario inheritance super baseline module should compile before reload analysis"),
		CompileAnnotatedModuleFromMemory(&Engine, ModuleName, TEXT("TestInheritanceSuper.as"), BaselineScript)))
	{
		return false;
	}

	FAngelscriptClassGenerator::EReloadRequirement ReloadRequirement = FAngelscriptClassGenerator::Error;
	bool bWantsFullReload = false;
	bool bNeedsFullReload = false;
	const bool bAnalyzed = AnalyzeReloadFromMemory(
		&Engine,
		ModuleName,
		TEXT("TestInheritanceSuper.as"),
		TEXT(R"AS(
UCLASS()
class ATestInheritanceSuperBase : AActor
{
	UFUNCTION()
	int GetScenarioValue()
	{
		return 10;
	}
}

UCLASS()
class ATestInheritanceSuperDerived : AScenarioInheritanceSuperBase
{
	UFUNCTION()
	int GetScenarioValue()
	{
		return Super::GetScenarioValue() + 5;
	}
}
)AS"),
		ReloadRequirement,
		bWantsFullReload,
		bNeedsFullReload);

	if (!TestFalse(TEXT("Scenario script-to-script Super calls remain unsupported on this branch"), bAnalyzed))
	{
		return false;
	}

	TestEqual(TEXT("Scenario inheritance with Super should currently stay in the error state"), ReloadRequirement, FAngelscriptClassGenerator::Error);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptTestInheritanceIsATest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("TestInheritanceIsA"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	const FString BaselineScript = TEXT(R"AS(
UCLASS()
class ATestInheritanceIsABaseline : AActor
{
}
)AS");
	if (!TestTrue(TEXT("Scenario inheritance IsA baseline module should compile before reload analysis"),
		CompileAnnotatedModuleFromMemory(&Engine, ModuleName, TEXT("TestInheritanceIsA.as"), BaselineScript)))
	{
		return false;
	}

	FAngelscriptClassGenerator::EReloadRequirement ReloadRequirement = FAngelscriptClassGenerator::Error;
	bool bWantsFullReload = false;
	bool bNeedsFullReload = false;
	const bool bAnalyzed = AnalyzeReloadFromMemory(
		&Engine,
		ModuleName,
		TEXT("TestInheritanceIsA.as"),
		TEXT(R"AS(
UCLASS()
class ATestInheritanceIsABase : AActor
{
}

UCLASS()
class ATestInheritanceIsADerived : AScenarioInheritanceIsABase
{
	UFUNCTION()
	int VerifyBaseCast()
	{
		AScenarioInheritanceIsABase BaseRef = Cast<AScenarioInheritanceIsABase>(this);
		return BaseRef == null ? 0 : 1;
	}
}
)AS"),
		ReloadRequirement,
		bWantsFullReload,
		bNeedsFullReload);

	if (!TestTrue(TEXT("Scenario inheritance IsA/Cast syntax should analyze without crashing"), bAnalyzed))
	{
		return false;
	}

	TestTrue(TEXT("Scenario inheritance IsA/Cast currently requires the full-reload path on this branch"), bWantsFullReload || bNeedsFullReload);
	TestTrue(TEXT("Scenario inheritance IsA/Cast should not remain on the soft-reload path"),
		ReloadRequirement == FAngelscriptClassGenerator::FullReloadRequired
		|| ReloadRequirement == FAngelscriptClassGenerator::FullReloadSuggested);
	ASTEST_END_SHARE_CLEAN

	return true;
}

#endif
