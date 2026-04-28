#include "Shared/AngelscriptFunctionalTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "ClassGenerator/AngelscriptClassGenerator.h"
#include "Components/ActorTestSpawner.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

// Test Layer: UE Functional
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Inheritance_AngelscriptInheritanceTestCaseTests_Private
{
	using namespace AngelscriptFunctionalTestUtils;

	void InitializeInheritanceTestCaseSpawner(FActorTestSpawner& Spawner)
	{
		Spawner.InitializeGameSubsystems();
	}
}

using namespace AngelscriptTest_Inheritance_AngelscriptInheritanceTestCaseTests_Private;

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
	if (!TestTrue(TEXT("TestCase inheritance baseline module should compile before reload analysis"),
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
	int GetTestCaseValue()
	{
		return 1;
	}
}

UCLASS()
class ATestInheritanceDerived : ATestCaseInheritanceBase
{
	UFUNCTION()
	int GetTestCaseValue()
	{
		return 2;
	}
}
)AS"),
		ReloadRequirement,
		bWantsFullReload,
		bNeedsFullReload);

	if (!TestFalse(TEXT("TestCase script-to-script actor inheritance with overridden UFUNCTIONs remains unsupported on this branch"), bAnalyzed))
	{
		return false;
	}

	TestEqual(TEXT("TestCase script-to-script actor inheritance should currently stay in the error state"), ReloadRequirement, FAngelscriptClassGenerator::Error);
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
	if (!TestTrue(TEXT("TestCase inheritance super baseline module should compile before reload analysis"),
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
	int GetTestCaseValue()
	{
		return 10;
	}
}

UCLASS()
class ATestInheritanceSuperDerived : ATestCaseInheritanceSuperBase
{
	UFUNCTION()
	int GetTestCaseValue()
	{
		return Super::GetTestCaseValue() + 5;
	}
}
)AS"),
		ReloadRequirement,
		bWantsFullReload,
		bNeedsFullReload);

	if (!TestFalse(TEXT("TestCase script-to-script Super calls remain unsupported on this branch"), bAnalyzed))
	{
		return false;
	}

	TestEqual(TEXT("TestCase inheritance with Super should currently stay in the error state"), ReloadRequirement, FAngelscriptClassGenerator::Error);
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
	if (!TestTrue(TEXT("TestCase inheritance IsA baseline module should compile before reload analysis"),
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
class ATestInheritanceIsADerived : ATestInheritanceIsABase
{
	UFUNCTION()
	int VerifyBaseCast()
	{
		ATestInheritanceIsABase BaseRef = Cast<ATestInheritanceIsABase>(this);
		return BaseRef == null ? 0 : 1;
	}
}
)AS"),
		ReloadRequirement,
		bWantsFullReload,
		bNeedsFullReload);

	if (!TestTrue(TEXT("TestCase inheritance IsA/Cast syntax should analyze without crashing"), bAnalyzed))
	{
		return false;
	}

	TestTrue(TEXT("TestCase inheritance IsA/Cast currently requires the full-reload path on this branch"), bWantsFullReload || bNeedsFullReload);
	TestTrue(TEXT("TestCase inheritance IsA/Cast should not remain on the soft-reload path"),
		ReloadRequirement == FAngelscriptClassGenerator::FullReloadRequired
		|| ReloadRequirement == FAngelscriptClassGenerator::FullReloadSuggested);
	ASTEST_END_SHARE_CLEAN

	return true;
}

#endif
