// ============================================================================
// AngelscriptPreprocessorFunctionMacroTests.cpp
//
// Preprocessor tests for UFUNCTION macro handling: unsupported conditional
// placement, EDITOR conditional acceptance, and invalid function specifiers.
//
// Migrated from:
//   - AngelscriptPreprocessorFunctionMacroErrorTests.cpp
//
// Automation prefix: Angelscript.TestModule.Preprocessor.FunctionMacros.*
// ============================================================================

#include "CQTest.h"
#include "Preprocessor/AngelscriptPreprocessorTestHelpers.h"

#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace PreprocessorTestHelpers;
using namespace AngelscriptTestSupport;

// ============================================================================
// Test class
// ============================================================================

TEST_CLASS_WITH_FLAGS(FAngelscriptPreprocessorFunctionMacroTest,
	"Angelscript.TestModule.Preprocessor.FunctionMacros",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	// ========================================================================
	// RejectUnsupportedConditionalPlacement — UFUNCTION/UPROPERTY inside
	// #ifndef UNKNOWN_FLAG fails; inside #if EDITOR succeeds with EditorOnly meta
	// ========================================================================
	TEST_METHOD(RejectUnsupportedConditionalPlacement)
	{
		TestRunner->AddExpectedError(
			TEXT("Cannot put a UPROPERTY or UFUNCTION inside preprocessor conditions other than EDITOR or flags declared in configuration."),
			EAutomationExpectedErrorFlags::Contains, 2);

		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_MODULE_CLEAN();
		ASTEST_BEGIN_MODULE_CLEAN

		struct FConditionalCase
		{
			const TCHAR* Label;
			const TCHAR* RelativePath;
			const TCHAR* Source;
			int32 ExpectedRow;
		};

		const TArray<FConditionalCase> InvalidCases = {
			{
				TEXT("Function in unsupported conditional"),
				TEXT("Tests/Preprocessor/FunctionMacros/InvalidConditionalFunction.as"),
				TEXT("UCLASS()\nclass UBadFunctionConditionalCarrier : UObject\n{\n#ifndef UNKNOWN_FLAG\n    UFUNCTION()\n    int BadFunction()\n    {\n        return 1;\n    }\n#endif\n}\n"),
				5
			},
			{
				TEXT("Property in unsupported conditional"),
				TEXT("Tests/Preprocessor/FunctionMacros/InvalidConditionalProperty.as"),
				TEXT("UCLASS()\nclass UBadPropertyConditionalCarrier : UObject\n{\n#ifndef UNKNOWN_FLAG\n    UPROPERTY()\n    int BadValue;\n#endif\n}\n"),
				5
			}
		};

		for (const FConditionalCase& Case : InvalidCases)
		{
			Engine.ResetDiagnostics();
			Engine.LastEmittedDiagnostics.Empty();

			FFixtureFile File(Case.RelativePath, Case.Source);
			auto Result = RunPreprocess(Engine, File);

			TestRunner->TestFalse(
				FString::Printf(TEXT("%s should fail"), Case.Label), Result.bSuccess);
			AssertErrorCount(*TestRunner, Result, 1);
			AssertDiagnosticContains(*TestRunner, Result,
				TEXT("Cannot put a UPROPERTY or UFUNCTION inside preprocessor conditions"));
			AssertDiagnosticAt(*TestRunner, Result,
				TEXT("Cannot put a UPROPERTY or UFUNCTION"), Case.ExpectedRow, 1);
			AssertNoCompilableCode(*TestRunner, Result);
		}

		// Positive case: EDITOR conditional should succeed
		Engine.ResetDiagnostics();
		Engine.LastEmittedDiagnostics.Empty();
		const bool bOriginalUseEditorScripts = Engine.ShouldUseEditorScripts();
		Engine.SetUseEditorScriptsForTesting(true);
		ON_SCOPE_EXIT { Engine.SetUseEditorScriptsForTesting(bOriginalUseEditorScripts); };

		FFixtureFile EditorFile(TEXT("Tests/Preprocessor/FunctionMacros/EditorConditionalMembers.as"),
			TEXT("UCLASS()\n")
			TEXT("class UEditorConditionalCarrier : UObject\n")
			TEXT("{\n")
			TEXT("#if EDITOR\n")
			TEXT("    UPROPERTY()\n")
			TEXT("    int EditorValue;\n")
			TEXT("\n")
			TEXT("    UFUNCTION()\n")
			TEXT("    int ReadEditorValue()\n")
			TEXT("    {\n")
			TEXT("        return 7;\n")
			TEXT("    }\n")
			TEXT("#endif\n")
			TEXT("}\n"));

		auto EditorResult = RunPreprocess(Engine, EditorFile);

		AssertPreprocessSucceeded(*TestRunner, EditorResult);

		FAngelscriptModuleDesc* EditorModule = EditorResult.FindModule(
			TEXT("Tests.Preprocessor.FunctionMacros.EditorConditionalMembers"));
		if (TestRunner->TestNotNull(TEXT("Should find editor module"), EditorModule))
		{
			const TSharedPtr<FAngelscriptClassDesc> ClassDesc = EditorModule->GetClass(TEXT("UEditorConditionalCarrier"));
			TestRunner->TestTrue(TEXT("Should have class descriptor"), ClassDesc.IsValid());
			if (ClassDesc.IsValid())
			{
				const TSharedPtr<FAngelscriptPropertyDesc> Prop = ClassDesc->GetProperty(TEXT("EditorValue"));
				const TSharedPtr<FAngelscriptFunctionDesc> Func = ClassDesc->GetMethod(TEXT("ReadEditorValue"));
				TestRunner->TestTrue(TEXT("Should have EditorValue property"), Prop.IsValid());
				TestRunner->TestTrue(TEXT("Should have ReadEditorValue method"), Func.IsValid());
				if (Prop.IsValid())
				{
					TestRunner->TestTrue(TEXT("Property should have EditorOnly meta"),
						Prop->Meta.Contains(FName(TEXT("EditorOnly"))));
				}
				if (Func.IsValid())
				{
					TestRunner->TestTrue(TEXT("Function should have EditorOnly meta"),
						Func->Meta.Contains(FName(TEXT("EditorOnly"))));
				}
			}
		}

		ASTEST_END_MODULE_CLEAN
	}

	// ========================================================================
	// InvalidSpecifiersReportDiagnostics — global BlueprintEvent, conflicting
	// Event+Override, and unknown specifiers all fail with stable messages
	// ========================================================================
	TEST_METHOD(InvalidSpecifiersReportDiagnostics)
	{
		TestRunner->AddExpectedErrorPlain(
			TEXT("Global UFUNCTION() BadGlobalEvent may not be marked BlueprintEvent."),
			EAutomationExpectedErrorFlags::Contains, 1);
		TestRunner->AddExpectedErrorPlain(
			TEXT("UFUNCTION() Conflict cannot be both BlueprintEvent and BlueprintOverride."),
			EAutomationExpectedErrorFlags::Contains, 1);
		TestRunner->AddExpectedErrorPlain(
			TEXT("Unknown function specifier DefinitelyUnknownSpecifier on method UBadCarrier::Unknown."),
			EAutomationExpectedErrorFlags::Contains, 1);

		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_MODULE_CLEAN();
		ASTEST_BEGIN_MODULE_CLEAN

		struct FSpecifierCase
		{
			const TCHAR* Label;
			const TCHAR* RelativePath;
			const TCHAR* Source;
			const TCHAR* ExpectedMessage;
			int32 ExpectedRow;
		};

		const TArray<FSpecifierCase> Cases = {
			{
				TEXT("Global BlueprintEvent"),
				TEXT("Tests/Preprocessor/FunctionMacros/InvalidSpecifierGlobalBlueprintEvent.as"),
				TEXT("UFUNCTION(BlueprintEvent)\nint BadGlobalEvent()\n{\n    return 1;\n}\n"),
				TEXT("Global UFUNCTION() BadGlobalEvent may not be marked BlueprintEvent."),
				1
			},
			{
				TEXT("Conflicting BlueprintEvent+Override"),
				TEXT("Tests/Preprocessor/FunctionMacros/InvalidSpecifierBlueprintConflict.as"),
				TEXT("UCLASS()\nclass UBadCarrier : UObject\n{\n    UFUNCTION(BlueprintEvent, BlueprintOverride)\n    int Conflict()\n    {\n        return 1;\n    }\n}\n"),
				TEXT("UFUNCTION() Conflict cannot be both BlueprintEvent and BlueprintOverride."),
				4
			},
			{
				TEXT("Unknown function specifier"),
				TEXT("Tests/Preprocessor/FunctionMacros/InvalidSpecifierUnknown.as"),
				TEXT("UCLASS()\nclass UBadCarrier : UObject\n{\n    UFUNCTION(DefinitelyUnknownSpecifier)\n    void Unknown()\n    {\n    }\n}\n"),
				TEXT("Unknown function specifier DefinitelyUnknownSpecifier on method UBadCarrier::Unknown."),
				4
			}
		};

		for (const FSpecifierCase& Case : Cases)
		{
			Engine.ResetDiagnostics();
			Engine.LastEmittedDiagnostics.Empty();

			FFixtureFile File(Case.RelativePath, Case.Source);
			auto Result = RunPreprocess(Engine, File);

			TestRunner->TestFalse(
				FString::Printf(TEXT("%s should fail"), Case.Label), Result.bSuccess);
			AssertErrorCount(*TestRunner, Result, 1);
			AssertDiagnosticContains(*TestRunner, Result, Case.ExpectedMessage);
			AssertDiagnosticAt(*TestRunner, Result, Case.ExpectedMessage, Case.ExpectedRow, 1);
			AssertNoCompilableCode(*TestRunner, Result);
		}

		ASTEST_END_MODULE_CLEAN
	}
};

#endif // WITH_DEV_AUTOMATION_TESTS
