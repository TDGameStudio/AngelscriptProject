#include "../Shared/AngelscriptTestUtilities.h"

#include "Preprocessor/AngelscriptPreprocessor.h"

#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorComponentSpecifierTests_Private
{
	struct FShowOnActorInvalidScenario
	{
		const TCHAR* RelativeScriptPath;
		const TCHAR* ScriptSource;
		const TCHAR* ExpectedMessage;
		int32 ExpectedRow = 0;
	};

	FString GetPreprocessorComponentSpecifierFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("PreprocessorComponentSpecifierFixtures"));
	}

	FString WritePreprocessorComponentSpecifierFixture(const FString& RelativeScriptPath, const FString& Contents)
	{
		const FString AbsolutePath = FPaths::Combine(GetPreprocessorComponentSpecifierFixtureRoot(), RelativeScriptPath);
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

	TArray<FString> CollectDiagnosticMessages(
		const FAngelscriptEngine& Engine,
		const TArray<FString>& AbsoluteFilenames,
		int32& OutErrorCount)
	{
		TArray<FString> Messages;
		OutErrorCount = 0;

		for (const FString& AbsoluteFilename : AbsoluteFilenames)
		{
			const FAngelscriptEngine::FDiagnostics* Diagnostics = Engine.Diagnostics.Find(AbsoluteFilename);
			if (Diagnostics == nullptr)
			{
				continue;
			}

			for (const FAngelscriptEngine::FDiagnostic& Diagnostic : Diagnostics->Diagnostics)
			{
				Messages.Add(Diagnostic.Message);
				if (Diagnostic.bIsError)
				{
					++OutErrorCount;
				}
			}
		}

		return Messages;
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
		const FAngelscriptClassDesc* ClassDesc,
		const FString& PropertyName)
	{
		if (ClassDesc == nullptr)
		{
			return nullptr;
		}

		for (const TSharedRef<FAngelscriptPropertyDesc>& PropertyDesc : ClassDesc->Properties)
		{
			if (PropertyDesc->PropertyName == PropertyName)
			{
				return &PropertyDesc.Get();
			}
		}

		return nullptr;
	}

	bool HasMetaFlag(const TMap<FName, FString>& Meta, const TCHAR* Key)
	{
		return Meta.Contains(FName(Key));
	}

	bool HasMetaValue(const TMap<FName, FString>& Meta, const TCHAR* Key, const TCHAR* ExpectedValue)
	{
		const FString* FoundValue = Meta.Find(FName(Key));
		return FoundValue != nullptr && *FoundValue == ExpectedValue;
	}

	bool RunInvalidShowOnActorScenario(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		const FShowOnActorInvalidScenario& Scenario)
	{
		Engine.ResetDiagnostics();
		Engine.LastEmittedDiagnostics.Empty();

		const FString AbsoluteScriptPath = WritePreprocessorComponentSpecifierFixture(
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
		const FAngelscriptClassDesc* ClassDesc = FindClassDescriptor(ModuleDesc, TEXT("AShowOnActorInvalidCarrier"));
		const FAngelscriptPropertyDesc* PropertyDesc = FindPropertyDescriptor(ClassDesc, TEXT("PlainValue"));
		int32 ErrorCount = 0;
		const TArray<FString> DiagnosticMessages = CollectDiagnosticMessages(Engine, {AbsoluteScriptPath}, ErrorCount);

		bool bPassed = true;
		bPassed &= Test.TestFalse(
			TEXT("ShowOnActor invalid scenario should fail preprocessing"),
			bPreprocessSucceeded);
		bPassed &= Test.TestNotNull(
			TEXT("ShowOnActor invalid scenario should emit diagnostics for the failing file"),
			Diagnostics);
		bPassed &= Test.TestEqual(
			TEXT("ShowOnActor invalid scenario should emit exactly one preprocessing error"),
			ErrorCount,
			1);
		bPassed &= Test.TestTrue(
			TEXT("ShowOnActor invalid scenario should preserve at least one diagnostic message"),
			DiagnosticMessages.Num() > 0);
		if (!bPassed || Diagnostics == nullptr || Diagnostics->Diagnostics.Num() == 0)
		{
			return false;
		}

		const FAngelscriptEngine::FDiagnostic& FirstDiagnostic = Diagnostics->Diagnostics[0];
		bPassed &= Test.TestEqual(
			TEXT("ShowOnActor invalid scenario should keep the error text stable"),
			FirstDiagnostic.Message,
			FString(Scenario.ExpectedMessage));
		bPassed &= Test.TestEqual(
			TEXT("ShowOnActor invalid scenario should pin the diagnostic row to the UPROPERTY line"),
			FirstDiagnostic.Row,
			Scenario.ExpectedRow);
		bPassed &= Test.TestEqual(
			TEXT("ShowOnActor invalid scenario should keep the error column at the macro start"),
			FirstDiagnostic.Column,
			1);
		bPassed &= Test.TestEqual(
			TEXT("ShowOnActor invalid scenario should still produce one module descriptor for inspection"),
			Modules.Num(),
			1);
		bPassed &= Test.TestNotNull(
			TEXT("ShowOnActor invalid scenario should preserve the owning module descriptor"),
			ModuleDesc);
		bPassed &= Test.TestNotNull(
			TEXT("ShowOnActor invalid scenario should preserve the owning actor class descriptor"),
			ClassDesc);
		bPassed &= Test.TestNull(
			TEXT("ShowOnActor invalid scenario should not leave behind a half-valid property descriptor"),
			PropertyDesc);
		return bPassed;
	}

	bool RunValidShowOnActorScenario(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine)
	{
		Engine.ResetDiagnostics();
		Engine.LastEmittedDiagnostics.Empty();

		const FString RelativeScriptPath = TEXT("Tests/Preprocessor/Components/ShowOnActorRequiresDefaultComponent_Valid.as");
		const FString AbsoluteScriptPath = WritePreprocessorComponentSpecifierFixture(
			RelativeScriptPath,
			TEXT(
				"UCLASS()\n"
				"class AShowOnActorValidCarrier : AActor\n"
				"{\n"
				"    UPROPERTY(DefaultComponent, ShowOnActor, RootComponent)\n"
				"    USceneComponent RootScene;\n"
				"}\n"));
		ON_SCOPE_EXIT
		{
			IFileManager::Get().Delete(*AbsoluteScriptPath, false, true);
		};

		FAngelscriptPreprocessor Preprocessor;
		Preprocessor.AddFile(RelativeScriptPath, AbsoluteScriptPath);

		const bool bPreprocessSucceeded = Preprocessor.Preprocess();
		const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();
		int32 ErrorCount = 0;
		const TArray<FString> DiagnosticMessages = CollectDiagnosticMessages(Engine, {AbsoluteScriptPath}, ErrorCount);
		const FString ModuleName = GetFixtureModuleName(RelativeScriptPath);
		const FAngelscriptModuleDesc* ModuleDesc = FindModuleByName(Modules, ModuleName);
		const FAngelscriptClassDesc* ClassDesc = FindClassDescriptor(ModuleDesc, TEXT("AShowOnActorValidCarrier"));
		const FAngelscriptPropertyDesc* PropertyDesc = FindPropertyDescriptor(ClassDesc, TEXT("RootScene"));

		bool bPassed = true;
		bPassed &= Test.TestTrue(
			TEXT("ShowOnActor valid scenario should preprocess successfully"),
			bPreprocessSucceeded);
		bPassed &= Test.TestEqual(
			TEXT("ShowOnActor valid scenario should not emit preprocessing errors"),
			ErrorCount,
			0);
		bPassed &= Test.TestEqual(
			TEXT("ShowOnActor valid scenario should keep diagnostics empty"),
			DiagnosticMessages.Num(),
			0);
		bPassed &= Test.TestEqual(
			TEXT("ShowOnActor valid scenario should produce exactly one module descriptor"),
			Modules.Num(),
			1);
		bPassed &= Test.TestNotNull(
			TEXT("ShowOnActor valid scenario should resolve the generated module descriptor"),
			ModuleDesc);
		bPassed &= Test.TestNotNull(
			TEXT("ShowOnActor valid scenario should parse the actor class descriptor"),
			ClassDesc);
		bPassed &= Test.TestNotNull(
			TEXT("ShowOnActor valid scenario should keep the default-component property descriptor"),
			PropertyDesc);
		if (!bPassed || PropertyDesc == nullptr)
		{
			return false;
		}

		bPassed &= Test.TestTrue(
			TEXT("ShowOnActor valid scenario should mark the property as an instanced reference"),
			PropertyDesc->bInstancedReference);
		bPassed &= Test.TestTrue(
			TEXT("ShowOnActor valid scenario should keep the component editable on defaults"),
			PropertyDesc->bEditableOnDefaults);
		bPassed &= Test.TestTrue(
			TEXT("ShowOnActor valid scenario should keep the component editable on instances"),
			PropertyDesc->bEditableOnInstance);
		bPassed &= Test.TestTrue(
			TEXT("ShowOnActor valid scenario should keep the component blueprint-readable"),
			PropertyDesc->bBlueprintReadable);
		bPassed &= Test.TestFalse(
			TEXT("ShowOnActor valid scenario should keep the component blueprint-writable disabled"),
			PropertyDesc->bBlueprintWritable);
		bPassed &= Test.TestTrue(
			TEXT("ShowOnActor valid scenario should add DefaultComponent=True metadata"),
			HasMetaValue(PropertyDesc->Meta, TEXT("DefaultComponent"), TEXT("True")));
		bPassed &= Test.TestTrue(
			TEXT("ShowOnActor valid scenario should preserve RootComponent metadata"),
			HasMetaFlag(PropertyDesc->Meta, TEXT("RootComponent")));
		bPassed &= Test.TestTrue(
			TEXT("ShowOnActor valid scenario should add EditInline=true metadata"),
			HasMetaValue(PropertyDesc->Meta, TEXT("EditInline"), TEXT("true")));
		return bPassed;
	}
}

using namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorComponentSpecifierTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorShowOnActorRequiresDefaultComponentTest,
	"Angelscript.TestModule.Preprocessor.Properties.ShowOnActorRequiresDefaultComponent",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorShowOnActorRequiresDefaultComponentTest::RunTest(const FString& Parameters)
{
	AddExpectedErrorPlain(
		TEXT("ShowOnActor can only be used on default components in actors"),
		EAutomationExpectedErrorFlags::Contains,
		1);

	FAngelscriptTestFixture Fixture(*this);
	if (!TestTrue(TEXT("ShowOnActor preprocessor test should acquire a clean engine fixture"), Fixture.IsValid()))
	{
		return false;
	}

	FAngelscriptEngine& Engine = Fixture.GetEngine();
	const FShowOnActorInvalidScenario InvalidScenario = {
		TEXT("Tests/Preprocessor/Components/ShowOnActorRequiresDefaultComponent_Invalid.as"),
		TEXT(
			"UCLASS()\n"
			"class AShowOnActorInvalidCarrier : AActor\n"
			"{\n"
			"    UPROPERTY(ShowOnActor)\n"
			"    int PlainValue;\n"
			"}\n"),
		TEXT("ShowOnActor can only be used on default components in actors"),
		4
	};

	bool bPassed = true;
	bPassed &= RunInvalidShowOnActorScenario(*this, Engine, InvalidScenario);
	if (!bPassed)
	{
		return false;
	}

	bPassed &= RunValidShowOnActorScenario(*this, Engine);
	return bPassed;
}

#endif
