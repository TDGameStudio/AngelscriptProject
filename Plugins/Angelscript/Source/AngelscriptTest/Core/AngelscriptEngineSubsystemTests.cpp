#include "AngelscriptEngineSubsystem.h"

#include "AngelscriptEngine.h"
#include "Shared/AngelscriptTestUtilities.h"

#include "Engine/Engine.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Core_AngelscriptEngineSubsystemTests_Private
{
	struct FEngineSubsystemContextStackGuard
	{
		TArray<FAngelscriptEngine*> SavedStack;

		FEngineSubsystemContextStackGuard()
		{
			SavedStack = FAngelscriptEngineContextStack::SnapshotAndClear();
		}

		~FEngineSubsystemContextStackGuard()
		{
			FAngelscriptEngineContextStack::RestoreSnapshot(MoveTemp(SavedStack));
		}

		void DiscardSavedStack()
		{
			SavedStack.Reset();
		}
	};
}


struct FAngelscriptEngineSubsystemTestAccess
{
	static void SetStartupEnvironmentOverride(const TOptional<bool>& bIsEditorOverride, const TOptional<bool>& bIsRunningCommandletOverride)
	{
		UAngelscriptEngineSubsystem::SetStartupEnvironmentOverrideForTesting(bIsEditorOverride, bIsRunningCommandletOverride);
	}

	static void ClearStartupEnvironmentOverride()
	{
		UAngelscriptEngineSubsystem::ClearStartupEnvironmentOverrideForTesting();
	}

	static void SetInitializeOverride(TFunction<FAngelscriptEngine*()> InOverride)
	{
		UAngelscriptEngineSubsystem::SetInitializeOverrideForTesting(MoveTemp(InOverride));
	}

	static void ResetInitializeState()
	{
		UAngelscriptEngineSubsystem::ResetInitializeStateForTesting();
	}

	static bool ShouldCreateSubsystem(const UAngelscriptEngineSubsystem& Subsystem, UObject* Outer)
	{
		return Subsystem.ShouldCreateSubsystem(Outer);
	}

	static void EnsurePrimaryEngineInitialized(UAngelscriptEngineSubsystem& Subsystem)
	{
		Subsystem.EnsurePrimaryEngineInitialized();
	}

	static void ReleasePrimaryEngine(UAngelscriptEngineSubsystem& Subsystem)
	{
		Subsystem.ReleasePrimaryEngine();
	}

	static FAngelscriptEngine* GetPrimaryEngine(const UAngelscriptEngineSubsystem& Subsystem)
	{
		return Subsystem.PrimaryEngine;
	}

	static bool OwnsPrimaryEngine(const UAngelscriptEngineSubsystem& Subsystem)
	{
		return Subsystem.bOwnsPrimaryEngine;
	}

	static bool HasInitializedPrimaryEngine(const UAngelscriptEngineSubsystem& Subsystem)
	{
		return Subsystem.bInitializedPrimaryEngine;
	}
};

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptEngineSubsystemShouldCreateHonorsEditorAndCommandletGatesTest,
	"Angelscript.TestModule.Engine.EngineSubsystem.ShouldCreateHonorsEditorAndCommandletGates",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptEngineSubsystemInitializeOverrideLifecycleTest,
	"Angelscript.TestModule.Engine.EngineSubsystem.InitializeOverrideIsIdempotentAndRestorable",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptEngineSubsystemShouldCreateHonorsEditorAndCommandletGatesTest::RunTest(const FString& Parameters)
{
	using namespace AngelscriptTest_Core_AngelscriptEngineSubsystemTests_Private;
	ON_SCOPE_EXIT
	{
		FAngelscriptEngineSubsystemTestAccess::ClearStartupEnvironmentOverride();
	};

	const UAngelscriptEngineSubsystem* SubsystemCdo = GetDefault<UAngelscriptEngineSubsystem>();
	if (!TestNotNull(TEXT("EngineSubsystem should expose a native CDO"), SubsystemCdo))
	{
		return false;
	}

	UObject* Outer = GEngine != nullptr ? static_cast<UObject*>(GEngine) : GetTransientPackage();

	struct FStartupTestCase
	{
		const TCHAR* Label;
		bool bIsEditor = false;
		bool bIsRunningCommandlet = false;
		bool bShouldCreate = false;
	};

	const TArray<FStartupTestCase> TestCases = {
		{ TEXT("EditorStartup"), true, false, true },
		{ TEXT("CommandletStartup"), false, true, true },
		{ TEXT("PlainRuntimeStartup"), false, false, false },
	};

	bool bPassed = true;
	for (const FStartupTestCase& TestCase : TestCases)
	{
		FAngelscriptEngineSubsystemTestAccess::SetStartupEnvironmentOverride(TestCase.bIsEditor, TestCase.bIsRunningCommandlet);
		bPassed &= TestEqual(
			FString::Printf(TEXT("%s should match the expected EngineSubsystem creation gate"), TestCase.Label),
			FAngelscriptEngineSubsystemTestAccess::ShouldCreateSubsystem(*SubsystemCdo, Outer),
			TestCase.bShouldCreate);
	}

	return bPassed;
}

bool FAngelscriptEngineSubsystemInitializeOverrideLifecycleTest::RunTest(const FString& Parameters)
{
	using namespace AngelscriptTest_Core_AngelscriptEngineSubsystemTests_Private;
	FEngineSubsystemContextStackGuard ContextGuard;
	AngelscriptTestSupport::DestroySharedTestEngine();
	if (FAngelscriptEngine::IsInitialized())
	{
		AngelscriptTestSupport::FAngelscriptTestEngineScopeAccess::DestroyGlobalEngine();
	}
	ContextGuard.DiscardSavedStack();

	TStrongObjectPtr<UAngelscriptEngineSubsystem> Subsystem(NewObject<UAngelscriptEngineSubsystem>(GetTransientPackage()));
	if (!TestNotNull(TEXT("EngineSubsystem initialize-override test should create a native subsystem object"), Subsystem.Get()))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		FAngelscriptEngineSubsystemTestAccess::ReleasePrimaryEngine(*Subsystem);
		FAngelscriptEngineSubsystemTestAccess::ResetInitializeState();
		FAngelscriptEngineContextStack::SnapshotAndClear();
		if (FAngelscriptEngine::IsInitialized())
		{
			AngelscriptTestSupport::FAngelscriptTestEngineScopeAccess::DestroyGlobalEngine();
		}
		AngelscriptTestSupport::DestroySharedTestEngine();
	};

	FAngelscriptEngineSubsystemTestAccess::ResetInitializeState();
	if (!TestNull(TEXT("EngineSubsystem initialize-override test should start without a current engine"), FAngelscriptEngine::TryGetCurrentEngine()))
	{
		return false;
	}

	TUniquePtr<FAngelscriptEngine> OverrideEngine = AngelscriptTestSupport::CreateFullTestEngine();
	if (!TestNotNull(TEXT("EngineSubsystem initialize-override test should create an isolated override engine"), OverrideEngine.Get()))
	{
		return false;
	}

	FAngelscriptEngineSubsystemTestAccess::SetInitializeOverride([&OverrideEngine]()
	{
		return OverrideEngine.Get();
	});

	FAngelscriptEngineSubsystemTestAccess::EnsurePrimaryEngineInitialized(*Subsystem);
	bool bPassed = true;
	bPassed &= TestTrue(
		TEXT("EngineSubsystem initialize-override test should make the override engine current after first initialize"),
		FAngelscriptEngine::TryGetCurrentEngine() == OverrideEngine.Get());
	bPassed &= TestTrue(
		TEXT("EngineSubsystem initialize-override test should mark the primary engine initialized"),
		FAngelscriptEngineSubsystemTestAccess::HasInitializedPrimaryEngine(*Subsystem));
	bPassed &= TestTrue(
		TEXT("EngineSubsystem initialize-override test should expose the override engine as primary"),
		FAngelscriptEngineSubsystemTestAccess::GetPrimaryEngine(*Subsystem) == OverrideEngine.Get());
	bPassed &= TestFalse(
		TEXT("EngineSubsystem initialize-override test should not take ownership of an override engine"),
		FAngelscriptEngineSubsystemTestAccess::OwnsPrimaryEngine(*Subsystem));

	FAngelscriptEngineSubsystemTestAccess::EnsurePrimaryEngineInitialized(*Subsystem);

	TArray<FAngelscriptEngine*> StackAfterSecondInitialize = FAngelscriptEngineContextStack::SnapshotAndClear();
	bPassed &= TestEqual(
		TEXT("EngineSubsystem initialize-override test should keep exactly one engine on the context stack after repeated initialize"),
		StackAfterSecondInitialize.Num(),
		1);
	bPassed &= TestTrue(
		TEXT("EngineSubsystem initialize-override test should keep the override engine as the only stack entry"),
		StackAfterSecondInitialize.Num() == 1 && StackAfterSecondInitialize[0] == OverrideEngine.Get());
	FAngelscriptEngineContextStack::RestoreSnapshot(MoveTemp(StackAfterSecondInitialize));

	FAngelscriptEngineSubsystemTestAccess::ReleasePrimaryEngine(*Subsystem);
	bPassed &= TestFalse(
		TEXT("EngineSubsystem initialize-override test should clear initialized state after release"),
		FAngelscriptEngineSubsystemTestAccess::HasInitializedPrimaryEngine(*Subsystem));
	bPassed &= TestNull(
		TEXT("EngineSubsystem initialize-override test should clear the current engine after release"),
		FAngelscriptEngine::TryGetCurrentEngine());

	const TArray<FAngelscriptEngine*> StackAfterRelease = FAngelscriptEngineContextStack::SnapshotAndClear();
	bPassed &= TestEqual(
		TEXT("EngineSubsystem initialize-override test should leave the context stack empty after release"),
		StackAfterRelease.Num(),
		0);
	return bPassed;
}

#endif
