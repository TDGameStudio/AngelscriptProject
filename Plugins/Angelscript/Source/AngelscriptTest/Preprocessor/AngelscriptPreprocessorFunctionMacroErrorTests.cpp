#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Preprocessor/AngelscriptPreprocessor.h"

#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorFunctionMacroErrorTests_Private
{
	struct FInvalidFunctionMacroScenario
	{
		const TCHAR* Label;
		const TCHAR* RelativeScriptPath;
		const TCHAR* ScriptSource;
		int32 ExpectedRow;
	};

	struct FInvalidFunctionSpecifierScenario
	{
		const TCHAR* Label;
		const TCHAR* RelativeScriptPath;
		const TCHAR* ScriptSource;
		const TCHAR* ExpectedMessage;
		int32 ExpectedRow;
	};

	FString GetFunctionMacroFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("PreprocessorFunctionMacroFixtures"));
	}

	FString WriteFunctionMacroFixture(const FString& RelativeScriptPath, const FString& Contents)
	{
		const FString AbsolutePath = FPaths::Combine(GetFunctionMacroFixtureRoot(), RelativeScriptPath);
		IFileManager::Get().MakeDirectory(*FPaths::GetPath(AbsolutePath), true);
		FFileHelper::SaveStringToFile(Contents, *AbsolutePath);
		return AbsolutePath;
	}

	int32 CountErrorDiagnostics(const FAngelscriptEngine::FDiagnostics* Diagnostics)
	{
		if (Diagnostics == nullptr)
		{
			return 0;
		}

		int32 ErrorCount = 0;
		for (const FAngelscriptEngine::FDiagnostic& Diagnostic : Diagnostics->Diagnostics)
		{
			if (Diagnostic.bIsError)
			{
				++ErrorCount;
			}
		}

		return ErrorCount;
	}

	bool ContainsCompilableCode(const TArray<TSharedRef<FAngelscriptModuleDesc>>& Modules)
	{
		for (const TSharedRef<FAngelscriptModuleDesc>& Module : Modules)
		{
			for (const FAngelscriptModuleDesc::FCodeSection& Section : Module->Code)
			{
				if (!Section.Code.IsEmpty())
				{
					return true;
				}
			}
		}

		return false;
	}

	FAngelscriptModuleDesc* FindModuleByName(
		const TArray<TSharedRef<FAngelscriptModuleDesc>>& Modules,
		const FString& ModuleName)
	{
		for (const TSharedRef<FAngelscriptModuleDesc>& Module : Modules)
		{
			if (Module->ModuleName == ModuleName)
			{
				return &Module.Get();
			}
		}

		return nullptr;
	}

	bool HasMetaFlag(const TMap<FName, FString>& Meta, const TCHAR* Key)
	{
		return Meta.Contains(FName(Key));
	}

	bool RunInvalidConditionalPlacementScenario(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		const FInvalidFunctionMacroScenario& Scenario)
	{
		static const FString ExpectedMessage = TEXT("Cannot put a UPROPERTY or UFUNCTION inside preprocessor conditions other than EDITOR or flags declared in configuration.");

		Engine.ResetDiagnostics();
		Engine.LastEmittedDiagnostics.Empty();

		const FString AbsoluteScriptPath = WriteFunctionMacroFixture(Scenario.RelativeScriptPath, Scenario.ScriptSource);

		FAngelscriptPreprocessor Preprocessor;
		Preprocessor.AddFile(Scenario.RelativeScriptPath, AbsoluteScriptPath);

		const bool bPreprocessSucceeded = Preprocessor.Preprocess();
		const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();
		const FAngelscriptEngine::FDiagnostics* Diagnostics = Engine.Diagnostics.Find(AbsoluteScriptPath);

		if (!Test.TestFalse(
				FString::Printf(TEXT("%s should fail preprocessing when a reflected member is placed under an unsupported condition"), Scenario.Label),
				bPreprocessSucceeded))
		{
			return false;
		}

		if (!Test.TestNotNull(
				FString::Printf(TEXT("%s should emit diagnostics for the failing file"), Scenario.Label),
				Diagnostics))
		{
			return false;
		}

		if (!Test.TestTrue(
				FString::Printf(TEXT("%s should emit at least one diagnostic entry"), Scenario.Label),
				Diagnostics->Diagnostics.Num() > 0))
		{
			return false;
		}

		const FAngelscriptEngine::FDiagnostic& FirstDiagnostic = Diagnostics->Diagnostics[0];
		return Test.TestEqual(
				FString::Printf(TEXT("%s should emit exactly one error diagnostic"), Scenario.Label),
				CountErrorDiagnostics(Diagnostics),
				1)
			&& Test.TestEqual(
				FString::Printf(TEXT("%s should keep the unsupported-conditional error text stable"), Scenario.Label),
				FirstDiagnostic.Message,
				ExpectedMessage)
			&& Test.TestEqual(
				FString::Printf(TEXT("%s should pin the error row to the reflected macro line"), Scenario.Label),
				FirstDiagnostic.Row,
				Scenario.ExpectedRow)
			&& Test.TestEqual(
				FString::Printf(TEXT("%s should keep the error column at the macro start"), Scenario.Label),
				FirstDiagnostic.Column,
				1)
			&& Test.TestFalse(
				FString::Printf(TEXT("%s should not leave behind any compilable code after preprocessing fails"), Scenario.Label),
				ContainsCompilableCode(Modules));
	}

	bool RunInvalidFunctionSpecifierScenario(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		const FInvalidFunctionSpecifierScenario& Scenario)
	{
		Engine.ResetDiagnostics();
		Engine.LastEmittedDiagnostics.Empty();

		const FString AbsoluteScriptPath = WriteFunctionMacroFixture(Scenario.RelativeScriptPath, Scenario.ScriptSource);

		FAngelscriptPreprocessor Preprocessor;
		Preprocessor.AddFile(Scenario.RelativeScriptPath, AbsoluteScriptPath);

		const bool bPreprocessSucceeded = Preprocessor.Preprocess();
		const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();
		const FAngelscriptEngine::FDiagnostics* Diagnostics = Engine.Diagnostics.Find(AbsoluteScriptPath);

		if (!Test.TestFalse(
				FString::Printf(TEXT("%s should fail preprocessing when UFUNCTION specifiers are invalid"), Scenario.Label),
				bPreprocessSucceeded))
		{
			return false;
		}

		if (!Test.TestNotNull(
				FString::Printf(TEXT("%s should emit diagnostics for the failing file"), Scenario.Label),
				Diagnostics))
		{
			return false;
		}

		if (!Test.TestTrue(
				FString::Printf(TEXT("%s should emit at least one diagnostic entry"), Scenario.Label),
				Diagnostics->Diagnostics.Num() > 0))
		{
			return false;
		}

		const FAngelscriptEngine::FDiagnostic& FirstDiagnostic = Diagnostics->Diagnostics[0];
		return Test.TestEqual(
				FString::Printf(TEXT("%s should emit exactly one error diagnostic"), Scenario.Label),
				CountErrorDiagnostics(Diagnostics),
				1)
			&& Test.TestEqual(
				FString::Printf(TEXT("%s should keep the function-specifier error text stable"), Scenario.Label),
				FirstDiagnostic.Message,
				FString(Scenario.ExpectedMessage))
			&& Test.TestEqual(
				FString::Printf(TEXT("%s should pin the error row to the UFUNCTION line"), Scenario.Label),
				FirstDiagnostic.Row,
				Scenario.ExpectedRow)
			&& Test.TestEqual(
				FString::Printf(TEXT("%s should keep the error column at the macro start"), Scenario.Label),
				FirstDiagnostic.Column,
				1)
			&& Test.TestFalse(
				FString::Printf(TEXT("%s should not leave behind any compilable code after preprocessing fails"), Scenario.Label),
				ContainsCompilableCode(Modules));
	}
}

using namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorFunctionMacroErrorTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorRejectUnsupportedConditionalPlacementTest,
	"Angelscript.TestModule.Preprocessor.FunctionMacros.RejectUnsupportedConditionalPlacement",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorRejectUnsupportedConditionalPlacementTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	AddExpectedError(
		TEXT("Cannot put a UPROPERTY or UFUNCTION inside preprocessor conditions other than EDITOR or flags declared in configuration."),
		EAutomationExpectedErrorFlags::Contains,
		2);
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	const TArray<FInvalidFunctionMacroScenario> InvalidScenarios = {
		{
			TEXT("Unsupported function conditional"),
			TEXT("Tests/Preprocessor/FunctionMacros/InvalidConditionalFunction.as"),
			TEXT(
				"UCLASS()\n"
				"class UBadFunctionConditionalCarrier : UObject\n"
				"{\n"
				"#ifndef UNKNOWN_FLAG\n"
				"    UFUNCTION()\n"
				"    int BadFunction()\n"
				"    {\n"
				"        return 1;\n"
				"    }\n"
				"#endif\n"
				"}\n"),
			5
		},
		{
			TEXT("Unsupported property conditional"),
			TEXT("Tests/Preprocessor/FunctionMacros/InvalidConditionalProperty.as"),
			TEXT(
				"UCLASS()\n"
				"class UBadPropertyConditionalCarrier : UObject\n"
				"{\n"
				"#ifndef UNKNOWN_FLAG\n"
				"    UPROPERTY()\n"
				"    int BadValue;\n"
				"#endif\n"
				"}\n"),
			5
		}
	};

	for (const FInvalidFunctionMacroScenario& Scenario : InvalidScenarios)
	{
		bPassed &= RunInvalidConditionalPlacementScenario(*this, Engine, Scenario);
	}

	Engine.ResetDiagnostics();
	Engine.LastEmittedDiagnostics.Empty();
	const bool bOriginalUseEditorScripts = Engine.ShouldUseEditorScripts();
	Engine.SetUseEditorScriptsForTesting(true);
	ON_SCOPE_EXIT
	{
		Engine.SetUseEditorScriptsForTesting(bOriginalUseEditorScripts);
	};

	const FString EditorAbsolutePath = WriteFunctionMacroFixture(
		TEXT("Tests/Preprocessor/FunctionMacros/EditorConditionalMembers.as"),
		TEXT(
			"UCLASS()\n"
			"class UEditorConditionalCarrier : UObject\n"
			"{\n"
			"#if EDITOR\n"
			"    UPROPERTY()\n"
			"    int EditorValue;\n"
			"\n"
			"    UFUNCTION()\n"
			"    int ReadEditorValue()\n"
			"    {\n"
			"        return 7;\n"
			"    }\n"
			"#endif\n"
			"}\n"));

	FAngelscriptPreprocessor EditorPreprocessor;
	EditorPreprocessor.AddFile(TEXT("Tests/Preprocessor/FunctionMacros/EditorConditionalMembers.as"), EditorAbsolutePath);

	if (!TestTrue(TEXT("EDITOR conditional members should preprocess successfully"), EditorPreprocessor.Preprocess()))
	{
		return false;
	}

	const TArray<TSharedRef<FAngelscriptModuleDesc>> EditorModules = EditorPreprocessor.GetModulesToCompile();
	FAngelscriptModuleDesc* EditorModule = FindModuleByName(EditorModules, TEXT("Tests.Preprocessor.FunctionMacros.EditorConditionalMembers"));

	const FAngelscriptEngine::FDiagnostics* EditorDiagnostics = Engine.Diagnostics.Find(EditorAbsolutePath);
	if (EditorDiagnostics != nullptr)
	{
		bPassed &= TestEqual(TEXT("EDITOR conditional members should not emit error diagnostics"), CountErrorDiagnostics(EditorDiagnostics), 0);
	}

	const TSharedPtr<FAngelscriptClassDesc> EditorClassDesc =
		EditorModule != nullptr ? EditorModule->GetClass(TEXT("UEditorConditionalCarrier")) : nullptr;
	const TSharedPtr<FAngelscriptPropertyDesc> EditorPropertyDesc =
		EditorClassDesc.IsValid() ? EditorClassDesc->GetProperty(TEXT("EditorValue")) : nullptr;
	const TSharedPtr<FAngelscriptFunctionDesc> EditorFunctionDesc =
		EditorClassDesc.IsValid() ? EditorClassDesc->GetMethod(TEXT("ReadEditorValue")) : nullptr;

	bPassed &= TestNotNull(TEXT("EDITOR conditional members should preserve the module descriptor"), EditorModule);
	bPassed &= TestTrue(TEXT("EDITOR conditional members should preserve the class descriptor"), EditorClassDesc.IsValid());
	bPassed &= TestTrue(TEXT("EDITOR conditional members should keep the reflected property descriptor"), EditorPropertyDesc.IsValid());
	bPassed &= TestTrue(TEXT("EDITOR conditional members should keep the reflected function descriptor"), EditorFunctionDesc.IsValid());
	if (EditorPropertyDesc.IsValid())
	{
		bPassed &= TestTrue(
			TEXT("EDITOR conditional property descriptor should carry EditorOnly metadata"),
			HasMetaFlag(EditorPropertyDesc->Meta, TEXT("EditorOnly")));
	}
	if (EditorFunctionDesc.IsValid())
	{
		bPassed &= TestTrue(
			TEXT("EDITOR conditional function descriptor should carry EditorOnly metadata"),
			HasMetaFlag(EditorFunctionDesc->Meta, TEXT("EditorOnly")));
	}

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorInvalidSpecifiersReportDiagnosticsTest,
	"Angelscript.TestModule.Preprocessor.FunctionMacros.InvalidSpecifiersReportDiagnostics",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorInvalidSpecifiersReportDiagnosticsTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	AddExpectedErrorPlain(
		TEXT("Global UFUNCTION() BadGlobalEvent may not be marked BlueprintEvent."),
		EAutomationExpectedErrorFlags::Contains,
		1);
	AddExpectedErrorPlain(
		TEXT("UFUNCTION() Conflict cannot be both BlueprintEvent and BlueprintOverride."),
		EAutomationExpectedErrorFlags::Contains,
		1);
	AddExpectedErrorPlain(
		TEXT("Unknown function specifier DefinitelyUnknownSpecifier on method UBadCarrier::Unknown."),
		EAutomationExpectedErrorFlags::Contains,
		1);

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	const TArray<FInvalidFunctionSpecifierScenario> Scenarios = {
		{
			TEXT("Global BlueprintEvent specifier"),
			TEXT("Tests/Preprocessor/FunctionMacros/InvalidSpecifierGlobalBlueprintEvent.as"),
			TEXT(
				"UFUNCTION(BlueprintEvent)\n"
				"int BadGlobalEvent()\n"
				"{\n"
				"    return 1;\n"
				"}\n"),
			TEXT("Global UFUNCTION() BadGlobalEvent may not be marked BlueprintEvent."),
			1
		},
		{
			TEXT("Conflicting BlueprintEvent and BlueprintOverride"),
			TEXT("Tests/Preprocessor/FunctionMacros/InvalidSpecifierBlueprintConflict.as"),
			TEXT(
				"UCLASS()\n"
				"class UBadCarrier : UObject\n"
				"{\n"
				"    UFUNCTION(BlueprintEvent, BlueprintOverride)\n"
				"    int Conflict()\n"
				"    {\n"
				"        return 1;\n"
				"    }\n"
				"}\n"),
			TEXT("UFUNCTION() Conflict cannot be both BlueprintEvent and BlueprintOverride."),
			4
		},
		{
			TEXT("Unknown function specifier"),
			TEXT("Tests/Preprocessor/FunctionMacros/InvalidSpecifierUnknown.as"),
			TEXT(
				"UCLASS()\n"
				"class UBadCarrier : UObject\n"
				"{\n"
				"    UFUNCTION(DefinitelyUnknownSpecifier)\n"
				"    void Unknown()\n"
				"    {\n"
				"    }\n"
				"}\n"),
			TEXT("Unknown function specifier DefinitelyUnknownSpecifier on method UBadCarrier::Unknown."),
			4
		}
	};

	for (const FInvalidFunctionSpecifierScenario& Scenario : Scenarios)
	{
		bPassed &= RunInvalidFunctionSpecifierScenario(*this, Engine, Scenario);
	}

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
