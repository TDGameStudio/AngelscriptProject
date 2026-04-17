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

namespace PreprocessorInterfaceTest
{
	FString GetFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("PreprocessorInterfaceFixtures"));
	}

	FString WriteFixture(const FString& RelativeScriptPath, const FString& Contents)
	{
		const FString AbsolutePath = FPaths::Combine(GetFixtureRoot(), RelativeScriptPath);
		IFileManager::Get().MakeDirectory(*FPaths::GetPath(AbsolutePath), true);
		FFileHelper::SaveStringToFile(Contents, *AbsolutePath);
		return AbsolutePath;
	}

	int32 CountDiagnostics(const FAngelscriptEngine::FDiagnostics* Diagnostics)
	{
		return Diagnostics != nullptr ? Diagnostics->Diagnostics.Num() : 0;
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

	const FAngelscriptClassDesc* FindClassByName(
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
}

using namespace PreprocessorInterfaceTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorInterfaceDescriptorAndMethodNormalizationTest,
	"Angelscript.TestModule.Preprocessor.Interface.DescriptorAndMethodNormalization",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorInterfaceInvalidBaseReportsDiagnosticTest,
	"Angelscript.TestModule.Preprocessor.Interface.InvalidBaseReportsDiagnostic",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorInterfaceDescriptorAndMethodNormalizationTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	Engine.ResetDiagnostics();
	Engine.LastEmittedDiagnostics.Empty();

	const FString RelativeScriptPath = TEXT("Tests/Preprocessor/Interface/DescriptorAndMethodNormalization.as");
	const FString AbsoluteScriptPath = PreprocessorInterfaceTest::WriteFixture(
		RelativeScriptPath,
		TEXT(
			"UINTERFACE()\n"
			"interface UIAuditBase\n"
			"{\n"
			"    void TakeDamage(float Amount);\n"
			"}\n"
			"\n"
			"UINTERFACE()\n"
			"interface UIAuditChild : UIAuditBase\n"
			"{\n"
			"    double QueryValue(double Amount);\n"
			"}\n"));
	ON_SCOPE_EXIT
	{
		IFileManager::Get().Delete(*AbsoluteScriptPath, false, true);
	};

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(RelativeScriptPath, AbsoluteScriptPath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();
	const FAngelscriptEngine::FDiagnostics* Diagnostics = Engine.Diagnostics.Find(AbsoluteScriptPath);
	const FAngelscriptModuleDesc* Module = PreprocessorInterfaceTest::FindModuleByName(
		Modules,
		TEXT("Tests.Preprocessor.Interface.DescriptorAndMethodNormalization"));
	const FAngelscriptClassDesc* BaseInterface = PreprocessorInterfaceTest::FindClassByName(Module, TEXT("UIAuditBase"));
	const FAngelscriptClassDesc* ChildInterface = PreprocessorInterfaceTest::FindClassByName(Module, TEXT("UIAuditChild"));

	bPassed &= TestTrue(
		TEXT("Direct interface preprocessor test should succeed for a valid UINTERFACE-only module"),
		bPreprocessSucceeded);
	bPassed &= TestEqual(
		TEXT("Direct interface preprocessor test should keep diagnostics empty"),
		PreprocessorInterfaceTest::CountDiagnostics(Diagnostics),
		0);
	bPassed &= TestEqual(
		TEXT("Direct interface preprocessor test should produce exactly one module descriptor"),
		Modules.Num(),
		1);
	bPassed &= TestNotNull(
		TEXT("Direct interface preprocessor test should preserve the parsed module descriptor"),
		Module);

	if (Module != nullptr)
	{
		bPassed &= TestEqual(
			TEXT("Direct interface preprocessor test should collect exactly two interface descriptors"),
			Module->Classes.Num(),
			2);
	}

	if (!TestNotNull(TEXT("Direct interface preprocessor test should collect the base interface descriptor"), BaseInterface)
		|| !TestNotNull(TEXT("Direct interface preprocessor test should collect the child interface descriptor"), ChildInterface))
	{
		return false;
	}

	bPassed &= TestTrue(
		TEXT("Direct interface preprocessor test should mark the base interface as an interface"),
		BaseInterface->bIsInterface);
	bPassed &= TestTrue(
		TEXT("Direct interface preprocessor test should keep the base interface abstract"),
		BaseInterface->bAbstract);
	bPassed &= TestEqual(
		TEXT("Direct interface preprocessor test should default the base interface superclass to UInterface"),
		BaseInterface->SuperClass,
		FString(TEXT("UInterface")));
	bPassed &= TestEqual(
		TEXT("Direct interface preprocessor test should not attach implemented-interface entries to a root interface"),
		BaseInterface->ImplementedInterfaces.Num(),
		0);
	bPassed &= TestEqual(
		TEXT("Direct interface preprocessor test should capture exactly one normalized declaration for the base interface"),
		BaseInterface->InterfaceMethodDeclarations.Num(),
		1);
	if (BaseInterface->InterfaceMethodDeclarations.Num() >= 1)
	{
		bPassed &= TestEqual(
			TEXT("Direct interface preprocessor test should normalize float arguments to float32 in the base interface signature"),
			BaseInterface->InterfaceMethodDeclarations[0],
			FString(TEXT("void TakeDamage(float32 Amount)")));
	}

	bPassed &= TestTrue(
		TEXT("Direct interface preprocessor test should mark the child interface as an interface"),
		ChildInterface->bIsInterface);
	bPassed &= TestTrue(
		TEXT("Direct interface preprocessor test should keep the child interface abstract"),
		ChildInterface->bAbstract);
	bPassed &= TestEqual(
		TEXT("Direct interface preprocessor test should preserve script-interface inheritance on the child descriptor"),
		ChildInterface->SuperClass,
		FString(TEXT("UIAuditBase")));
	bPassed &= TestEqual(
		TEXT("Direct interface preprocessor test should not duplicate the direct parent interface in ImplementedInterfaces"),
		ChildInterface->ImplementedInterfaces.Num(),
		0);
	bPassed &= TestEqual(
		TEXT("Direct interface preprocessor test should capture exactly one normalized declaration for the child interface"),
		ChildInterface->InterfaceMethodDeclarations.Num(),
		1);
	if (ChildInterface->InterfaceMethodDeclarations.Num() >= 1)
	{
		bPassed &= TestEqual(
			TEXT("Direct interface preprocessor test should normalize double return and parameter types to float64 on the child interface"),
			ChildInterface->InterfaceMethodDeclarations[0],
			FString(TEXT("float64 QueryValue(float64 Amount)")));
	}

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

bool FAngelscriptPreprocessorInterfaceInvalidBaseReportsDiagnosticTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	struct FInvalidInterfaceBaseCase
	{
		const TCHAR* CaseLabel = TEXT("");
		const TCHAR* RelativeScriptPath = TEXT("");
		const TCHAR* ModuleName = TEXT("");
		const TCHAR* InterfaceName = TEXT("");
		const TCHAR* SuperClassName = TEXT("");
		int32 ExpectedRow = INDEX_NONE;
		const TCHAR* Source = TEXT("");
	};

	const TArray<FInvalidInterfaceBaseCase> Cases = {
		{
			TEXT("Native non-interface base"),
			TEXT("Tests/Preprocessor/Interface/InvalidBaseNative.as"),
			TEXT("Tests.Preprocessor.Interface.InvalidBaseNative"),
			TEXT("UBadNativeInterface"),
			TEXT("UObject"),
			2,
			TEXT(
				"UINTERFACE()\n"
				"interface UBadNativeInterface : UObject\n"
				"{\n"
				"    void Ping();\n"
				"}\n")
		},
		{
			TEXT("Script non-interface base"),
			TEXT("Tests/Preprocessor/Interface/InvalidBaseScript.as"),
			TEXT("Tests.Preprocessor.Interface.InvalidBaseScript"),
			TEXT("UBadScriptInterface"),
			TEXT("UConcreteBase"),
			7,
			TEXT(
				"UCLASS()\n"
				"class UConcreteBase : UObject\n"
				"{\n"
				"}\n"
				"\n"
				"UINTERFACE()\n"
				"interface UBadScriptInterface : UConcreteBase\n"
				"{\n"
				"    void Ping();\n"
				"}\n")
		}
	};

	for (const FInvalidInterfaceBaseCase& TestCase : Cases)
	{
		Engine.ResetDiagnostics();
		Engine.LastEmittedDiagnostics.Empty();

		const FString AbsoluteScriptPath = PreprocessorInterfaceTest::WriteFixture(TestCase.RelativeScriptPath, TestCase.Source);
		ON_SCOPE_EXIT
		{
			IFileManager::Get().Delete(*AbsoluteScriptPath, false, true);
		};

		const FString ExpectedMessage = FString::Printf(
			TEXT("Interface %s cannot inherit from non-interface class %s."),
			TestCase.InterfaceName,
			TestCase.SuperClassName);
		AddExpectedErrorPlain(ExpectedMessage, EAutomationExpectedErrorFlags::Contains, 1);

		FAngelscriptPreprocessor Preprocessor;
		Preprocessor.AddFile(TestCase.RelativeScriptPath, AbsoluteScriptPath);

		const bool bPreprocessSucceeded = Preprocessor.Preprocess();
		const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();
		const FAngelscriptEngine::FDiagnostics* Diagnostics = Engine.Diagnostics.Find(AbsoluteScriptPath);
		const FAngelscriptModuleDesc* Module = PreprocessorInterfaceTest::FindModuleByName(Modules, TestCase.ModuleName);

		bPassed &= TestFalse(
			FString::Printf(TEXT("%s should fail during preprocessing"), TestCase.CaseLabel),
			bPreprocessSucceeded);
		bPassed &= TestEqual(
			FString::Printf(TEXT("%s should preserve exactly one module descriptor for inspection"), TestCase.CaseLabel),
			Modules.Num(),
			1);
		bPassed &= TestNotNull(
			FString::Printf(TEXT("%s should emit diagnostics for the failing file"), TestCase.CaseLabel),
			Diagnostics);
		bPassed &= TestNotNull(
			FString::Printf(TEXT("%s should preserve the failing module descriptor"), TestCase.CaseLabel),
			Module);
		bPassed &= TestFalse(
			FString::Printf(TEXT("%s should not leave behind compilable code"), TestCase.CaseLabel),
			PreprocessorInterfaceTest::ContainsCompilableCode(Modules));

		if (Diagnostics != nullptr && Diagnostics->Diagnostics.Num() > 0)
		{
			const FAngelscriptEngine::FDiagnostic& FirstDiagnostic = Diagnostics->Diagnostics[0];
			bPassed &= TestEqual(
				FString::Printf(TEXT("%s should emit exactly one preprocessing error"), TestCase.CaseLabel),
				PreprocessorInterfaceTest::CountErrorDiagnostics(Diagnostics),
				1);
			bPassed &= TestEqual(
				FString::Printf(TEXT("%s should keep the invalid-base diagnostic text stable"), TestCase.CaseLabel),
				FirstDiagnostic.Message,
				ExpectedMessage);
			bPassed &= TestEqual(
				FString::Printf(TEXT("%s should pin the diagnostic row to the interface declaration"), TestCase.CaseLabel),
				FirstDiagnostic.Row,
				TestCase.ExpectedRow);
			bPassed &= TestEqual(
				FString::Printf(TEXT("%s should keep the diagnostic column at the declaration start"), TestCase.CaseLabel),
				FirstDiagnostic.Column,
				1);
		}

		if (Module != nullptr)
		{
			bPassed &= TestEqual(
				FString::Printf(TEXT("%s should not emit processed code sections"), TestCase.CaseLabel),
				Module->Code.Num(),
				0);
			bPassed &= TestEqual(
				FString::Printf(TEXT("%s should not keep any interface descriptors in the module"), TestCase.CaseLabel),
				Module->Classes.Num(),
				0);
			bPassed &= TestNull(
				FString::Printf(TEXT("%s should not leave a consumable interface descriptor behind"), TestCase.CaseLabel),
				PreprocessorInterfaceTest::FindClassByName(Module, TestCase.InterfaceName));
		}
	}

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
