#include "Shared/AngelscriptTestEngineHelper.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Core/AngelscriptEngine.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_ClassGenerator_DefaultStatementSafetyTests_Private
{
	bool SummaryContainsDiagnosticMessage(const FAngelscriptCompileTraceSummary& Summary, const FString& ExpectedMessage)
	{
		for (const FAngelscriptCompileTraceDiagnosticSummary& Diagnostic : Summary.Diagnostics)
		{
			if (Diagnostic.Message.Contains(ExpectedMessage))
			{
				return true;
			}
		}

		return false;
	}

	bool CompileSafetyScript(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		const FName ModuleName,
		const FString& ClassName,
		const FString& Script,
		const bool bExpectedCompile,
		FAngelscriptCompileTraceSummary& OutSummary)
	{
		const bool bCompiled = CompileModuleWithSummary(
			&Engine,
			ECompileType::FullReload,
			ModuleName,
			FString::Printf(TEXT("%s.as"), *ModuleName.ToString()),
			Script,
			true,
			OutSummary,
			!bExpectedCompile);

		if (bExpectedCompile)
		{
			if (!Test.TestTrue(*FString::Printf(TEXT("%s should compile"), *ClassName), bCompiled))
			{
				return false;
			}

			return Test.TestNotNull(*FString::Printf(TEXT("%s should publish a generated class"), *ClassName), FindGeneratedClass(&Engine, *ClassName));
		}

		return Test.TestFalse(*FString::Printf(TEXT("%s should fail compilation"), *ClassName), bCompiled);
	}
}


IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDefaultStatementUnsafeDuringConstructionRejectsDefaultAndConstructorTest,
	"Angelscript.TestModule.ClassGenerator.DefaultStatementSafety.UnsafeDuringConstructionRejectsDefaultAndConstructor",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDefaultStatementDefaultsOnlyAccessTest,
	"Angelscript.TestModule.ClassGenerator.DefaultStatementSafety.DefaultsOnlyAccess",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDefaultStatementUnsafeDuringConstructionRejectsDefaultAndConstructorTest::RunTest(const FString& Parameters)
{
	using namespace AngelscriptTest_ClassGenerator_DefaultStatementSafetyTests_Private;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASUnsafeDefault"));
		Engine.DiscardModule(TEXT("ASUnsafeConstructor"));
		Engine.DiscardModule(TEXT("ASUnsafeOrdinary"));
		ResetSharedCloneEngine(Engine);
	};

	const FString UnsafeDefaultScript = TEXT(R"AS(
UCLASS()
class UUnsafeDefaultTarget : UObject
{
	UPROPERTY()
	int Value = 0;

	int UnsafeValue() unsafe_during_construction
	{
		return 7;
	}

	default Value = UnsafeValue();
}
)AS");

	FAngelscriptCompileTraceSummary UnsafeDefaultSummary;
	if (!CompileSafetyScript(*this, Engine, TEXT("ASUnsafeDefault"), TEXT("UUnsafeDefaultTarget"), UnsafeDefaultScript, false, UnsafeDefaultSummary))
	{
		return false;
	}
	TestTrue(TEXT("Unsafe default call should report unsafe construction diagnostics"), SummaryContainsDiagnosticMessage(UnsafeDefaultSummary, TEXT("unsafe during construction")));

	const FString UnsafeConstructorScript = TEXT(R"AS(
class UnsafeConstructorCarrier
{
	int Value = 0;

	int UnsafeValue() unsafe_during_construction
	{
		return 7;
	}

	UnsafeConstructorCarrier()
	{
		Value = UnsafeValue();
	}
}

int Entry()
{
	UnsafeConstructorCarrier@ Carrier = UnsafeConstructorCarrier();
	return Carrier.Value;
}
)AS");

	FAngelscriptCompileTraceSummary UnsafeConstructorSummary;
	if (!CompileSafetyScript(*this, Engine, TEXT("ASUnsafeConstructor"), TEXT("UnsafeConstructorCarrier"), UnsafeConstructorScript, false, UnsafeConstructorSummary))
	{
		return false;
	}
	TestTrue(TEXT("Unsafe constructor call should report unsafe construction diagnostics"), SummaryContainsDiagnosticMessage(UnsafeConstructorSummary, TEXT("unsafe during construction")));

	const FString UnsafeOrdinaryScript = TEXT(R"AS(
UCLASS()
class UUnsafeOrdinaryTarget : UObject
{
	UPROPERTY()
	int Value = 0;

	int UnsafeValue() unsafe_during_construction
	{
		return 7;
	}

	UFUNCTION()
	int Entry()
	{
		return UnsafeValue();
	}
}
)AS");

	FAngelscriptCompileTraceSummary UnsafeOrdinarySummary;
	if (!CompileSafetyScript(*this, Engine, TEXT("ASUnsafeOrdinary"), TEXT("UUnsafeOrdinaryTarget"), UnsafeOrdinaryScript, true, UnsafeOrdinarySummary))
	{
		return false;
	}

	ASTEST_END_SHARE_CLEAN
	return true;
}

bool FAngelscriptDefaultStatementDefaultsOnlyAccessTest::RunTest(const FString& Parameters)
{
	using namespace AngelscriptTest_ClassGenerator_DefaultStatementSafetyTests_Private;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASDefaultsOnlyOk"));
		Engine.DiscardModule(TEXT("ASDefaultsOnlyReject"));
		ResetSharedCloneEngine(Engine);
	};

	const FString DefaultsOnlyOkScript = TEXT(R"AS(
UCLASS()
class UDefaultsOnlyOkTarget : UObject
{
	UPROPERTY()
	int Value = 0;

	int BuildDefaultValue() defaults
	{
		Value = 7;
		return Value;
	}

	default Value = BuildDefaultValue();
}
)AS");

	FAngelscriptCompileTraceSummary DefaultsOnlyOkSummary;
	if (!CompileSafetyScript(*this, Engine, TEXT("ASDefaultsOnlyOk"), TEXT("UDefaultsOnlyOkTarget"), DefaultsOnlyOkScript, true, DefaultsOnlyOkSummary))
	{
		return false;
	}

	const FString DefaultsOnlyRejectScript = TEXT(R"AS(
UCLASS()
class UDefaultsOnlyRejectTarget : UObject
{
	UPROPERTY()
	int Value = 0;

	int BuildDefaultValue() defaults
	{
		Value = 7;
		return Value;
	}

	UFUNCTION()
	int Entry()
	{
		return BuildDefaultValue();
	}
}
)AS");

	FAngelscriptCompileTraceSummary DefaultsOnlyRejectSummary;
	if (!CompileSafetyScript(*this, Engine, TEXT("ASDefaultsOnlyReject"), TEXT("UDefaultsOnlyRejectTarget"), DefaultsOnlyRejectScript, false, DefaultsOnlyRejectSummary))
	{
		return false;
	}
	TestTrue(TEXT("Defaults-only ordinary call should report an access diagnostic"), SummaryContainsDiagnosticMessage(DefaultsOnlyRejectSummary, TEXT("only accessible from default statements")));

	ASTEST_END_SHARE_CLEAN
	return true;
}

#endif
