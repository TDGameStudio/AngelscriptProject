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

namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorPropertyMacroErrorTests_Private
{
	struct FInvalidPropertySpecifierScenario
	{
		const TCHAR* Label;
		const TCHAR* RelativeScriptPath;
		const TCHAR* ScriptSource;
		const TCHAR* ExpectedMessage;
		int32 ExpectedRow;
	};

	FString GetPropertyMacroFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("PreprocessorPropertyMacroFixtures"));
	}

	FString WritePropertyMacroFixture(const FString& RelativeScriptPath, const FString& Contents)
	{
		const FString AbsolutePath = FPaths::Combine(GetPropertyMacroFixtureRoot(), RelativeScriptPath);
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

	FString GetFixtureModuleName(const FString& RelativeScriptPath)
	{
		return FPaths::ChangeExtension(RelativeScriptPath, TEXT(""))
			.Replace(TEXT("/"), TEXT("."))
			.Replace(TEXT("\\"), TEXT("."));
	}

	const FAngelscriptModuleDesc* FindModuleByName(
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

	const FAngelscriptClassDesc* FindClassDescriptor(
		const FAngelscriptModuleDesc* Module,
		const FString& ClassName)
	{
		if (Module == nullptr)
		{
			return nullptr;
		}

		for (const TSharedRef<FAngelscriptClassDesc>& ClassDesc : Module->Classes)
		{
			if (ClassDesc->ClassName == ClassName)
			{
				return &ClassDesc.Get();
			}
		}

		return nullptr;
	}

	const FAngelscriptPropertyDesc* FindPropertyDescriptor(
		const TArray<TSharedRef<FAngelscriptModuleDesc>>& Modules,
		const FString& ClassName,
		const FString& PropertyName)
	{
		for (const TSharedRef<FAngelscriptModuleDesc>& Module : Modules)
		{
			const TSharedPtr<FAngelscriptClassDesc> ClassDesc = Module->GetClass(ClassName);
			if (!ClassDesc.IsValid())
			{
				continue;
			}

			const TSharedPtr<FAngelscriptPropertyDesc> PropertyDesc = ClassDesc->GetProperty(PropertyName);
			if (PropertyDesc.IsValid())
			{
				return PropertyDesc.Get();
			}
		}

		return nullptr;
	}

	bool RunInvalidPropertySpecifierScenario(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		const FInvalidPropertySpecifierScenario& Scenario)
	{
		Engine.ResetDiagnostics();
		Engine.LastEmittedDiagnostics.Empty();

		const FString AbsoluteScriptPath = WritePropertyMacroFixture(
			Scenario.RelativeScriptPath,
			Scenario.ScriptSource);
		ON_SCOPE_EXIT
		{
			IFileManager::Get().Delete(*AbsoluteScriptPath, false, true);
		};

		FAngelscriptPreprocessor Preprocessor;
		Preprocessor.AddFile(Scenario.RelativeScriptPath, AbsoluteScriptPath);

		const bool bPreprocessSucceeded = Preprocessor.Preprocess();
		const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();
		const FAngelscriptEngine::FDiagnostics* Diagnostics = Engine.Diagnostics.Find(AbsoluteScriptPath);
		const FString ModuleName = GetFixtureModuleName(Scenario.RelativeScriptPath);
		const FAngelscriptModuleDesc* ModuleDesc = FindModuleByName(Modules, ModuleName);
		const FAngelscriptClassDesc* ClassDesc = FindClassDescriptor(ModuleDesc, TEXT("UBadPropertyCarrier"));
		const FAngelscriptPropertyDesc* PropertyDesc =
			FindPropertyDescriptor(Modules, TEXT("UBadPropertyCarrier"), TEXT("TrackedValue"));

		if (!Test.TestFalse(
				FString::Printf(TEXT("%s should fail preprocessing when property callback specifiers are invalid"), Scenario.Label),
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
				FString::Printf(TEXT("%s should keep the property-specifier error text stable"), Scenario.Label),
				FirstDiagnostic.Message,
				FString(Scenario.ExpectedMessage))
			&& Test.TestEqual(
				FString::Printf(TEXT("%s should pin the error row to the UPROPERTY line"), Scenario.Label),
				FirstDiagnostic.Row,
				Scenario.ExpectedRow)
			&& Test.TestEqual(
				FString::Printf(TEXT("%s should keep the error column at the macro start"), Scenario.Label),
				FirstDiagnostic.Column,
				1)
			&& Test.TestNotNull(
				FString::Printf(TEXT("%s should preserve the owning module descriptor for inspection"), Scenario.Label),
				ModuleDesc)
			&& Test.TestNotNull(
				FString::Printf(TEXT("%s should preserve the owning class descriptor even when the property macro fails"), Scenario.Label),
				ClassDesc)
			&& Test.TestFalse(
				FString::Printf(TEXT("%s should not leave behind any compilable code after preprocessing fails"), Scenario.Label),
				ContainsCompilableCode(Modules))
			&& Test.TestNull(
				FString::Printf(TEXT("%s should not leave behind a half-valid reflected property descriptor"), Scenario.Label),
				PropertyDesc);
	}
}

using namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorPropertyMacroErrorTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorPropertyInvalidSpecifiersReportDiagnosticsTest,
	"Angelscript.TestModule.Preprocessor.PropertyMacros.InvalidCallbackSpecifiersReportDiagnostics",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorUnknownReplicationConditionReportsDiagnosticTest,
	"Angelscript.TestModule.Preprocessor.Properties.UnknownReplicationConditionReportsDiagnostic",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorPropertyInvalidSpecifiersReportDiagnosticsTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	AddExpectedErrorPlain(
		TEXT("No function specified for ReplicatedUsing on property UBadPropertyCarrier::TrackedValue."),
		EAutomationExpectedErrorFlags::Contains,
		1);
	AddExpectedErrorPlain(
		TEXT("No function specified for BlueprintSetter on property UBadPropertyCarrier::TrackedValue."),
		EAutomationExpectedErrorFlags::Contains,
		1);
	AddExpectedErrorPlain(
		TEXT("No function specified for BlueprintGetter on property UBadPropertyCarrier::TrackedValue."),
		EAutomationExpectedErrorFlags::Contains,
		1);
	AddExpectedErrorPlain(
		TEXT("Unknown property specifier DefinitelyUnknownSpecifier on property UBadPropertyCarrier::TrackedValue."),
		EAutomationExpectedErrorFlags::Contains,
		1);

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	const TArray<FInvalidPropertySpecifierScenario> Scenarios = {
		{
			TEXT("ReplicatedUsing without callback"),
			TEXT("Tests/Preprocessor/PropertyMacros/InvalidReplicatedUsingSpecifier.as"),
			TEXT(
				"UCLASS()\n"
				"class UBadPropertyCarrier : UObject\n"
				"{\n"
				"    UPROPERTY(ReplicatedUsing)\n"
				"    int TrackedValue;\n"
				"}\n"),
			TEXT("No function specified for ReplicatedUsing on property UBadPropertyCarrier::TrackedValue."),
			4
		},
		{
			TEXT("BlueprintSetter without callback"),
			TEXT("Tests/Preprocessor/PropertyMacros/InvalidBlueprintSetterSpecifier.as"),
			TEXT(
				"UCLASS()\n"
				"class UBadPropertyCarrier : UObject\n"
				"{\n"
				"    UPROPERTY(BlueprintSetter)\n"
				"    int TrackedValue;\n"
				"}\n"),
			TEXT("No function specified for BlueprintSetter on property UBadPropertyCarrier::TrackedValue."),
			4
		},
		{
			TEXT("BlueprintGetter without callback"),
			TEXT("Tests/Preprocessor/PropertyMacros/InvalidBlueprintGetterSpecifier.as"),
			TEXT(
				"UCLASS()\n"
				"class UBadPropertyCarrier : UObject\n"
				"{\n"
				"    UPROPERTY(BlueprintGetter)\n"
				"    int TrackedValue;\n"
				"}\n"),
			TEXT("No function specified for BlueprintGetter on property UBadPropertyCarrier::TrackedValue."),
			4
		},
		{
			TEXT("Unknown property specifier"),
			TEXT("Tests/Preprocessor/PropertyMacros/InvalidUnknownPropertySpecifier.as"),
			TEXT(
				"UCLASS()\n"
				"class UBadPropertyCarrier : UObject\n"
				"{\n"
				"    UPROPERTY(DefinitelyUnknownSpecifier)\n"
				"    int TrackedValue;\n"
				"}\n"),
			TEXT("Unknown property specifier DefinitelyUnknownSpecifier on property UBadPropertyCarrier::TrackedValue."),
			4
		}
	};

	for (const FInvalidPropertySpecifierScenario& Scenario : Scenarios)
	{
		bPassed &= RunInvalidPropertySpecifierScenario(*this, Engine, Scenario);
	}

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

bool FAngelscriptPreprocessorUnknownReplicationConditionReportsDiagnosticTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	AddExpectedErrorPlain(
		TEXT("Unknown ReplicationCondition DefinitelyUnknown on property UBadPropertyCarrier::TrackedValue."),
		EAutomationExpectedErrorFlags::Contains,
		1);

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	const FInvalidPropertySpecifierScenario Scenario = {
		TEXT("Unknown ReplicationCondition"),
		TEXT("Tests/Preprocessor/PropertyMacros/InvalidUnknownReplicationConditionSpecifier.as"),
		TEXT(
			"UCLASS()\n"
			"class UBadPropertyCarrier : UObject\n"
			"{\n"
			"    UPROPERTY(Replicated, ReplicationCondition=DefinitelyUnknown)\n"
			"    int TrackedValue;\n"
			"}\n"),
		TEXT("Unknown ReplicationCondition DefinitelyUnknown on property UBadPropertyCarrier::TrackedValue."),
		4
	};

	bPassed = RunInvalidPropertySpecifierScenario(*this, Engine, Scenario);

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
