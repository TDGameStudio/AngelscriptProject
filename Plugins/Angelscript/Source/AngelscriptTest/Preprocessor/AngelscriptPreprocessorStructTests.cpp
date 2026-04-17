#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Core/AngelscriptSettings.h"
#include "Preprocessor/AngelscriptPreprocessor.h"

#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorStructTests_Private
{
	FString GetPreprocessorStructFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("PreprocessorStructFixtures"));
	}

	FString WritePreprocessorStructFixture(const FString& RelativeScriptPath, const FString& Contents)
	{
		const FString AbsolutePath = FPaths::Combine(GetPreprocessorStructFixtureRoot(), RelativeScriptPath);
		IFileManager::Get().MakeDirectory(*FPaths::GetPath(AbsolutePath), true);
		FFileHelper::SaveStringToFile(Contents, *AbsolutePath);
		return AbsolutePath;
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

	const FAngelscriptPropertyDesc* FindPropertyByName(
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
}

using namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorStructTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorStructInheritanceRejectedTest,
	"Angelscript.TestModule.Preprocessor.Structs.InheritanceRejected",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorStructDefaultPropertySpecifierTest,
	"Angelscript.TestModule.Preprocessor.Structs.DefaultPropertySpecifierUsesStructSettings",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorStructInheritanceRejectedTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	Engine.ResetDiagnostics();

	const FString RelativeScriptPath = TEXT("Tests/Preprocessor/Structs/InvalidInheritance.as");
	const FString AbsoluteScriptPath = WritePreprocessorStructFixture(
		RelativeScriptPath,
		TEXT("USTRUCT() struct FDerivedStruct : FBaseStruct\n")
		TEXT("{\n")
		TEXT("    UPROPERTY() int Value;\n")
		TEXT("}\n"));
	static const FString ExpectedModuleName = TEXT("Tests.Preprocessor.Structs.InvalidInheritance");
	static const FString ExpectedDiagnosticMessage = TEXT("Error parsing script struct FDerivedStruct. Structs may not inherit from anything.");

	AddExpectedError(ExpectedDiagnosticMessage, EAutomationExpectedErrorFlags::Contains, 1);

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(RelativeScriptPath, AbsoluteScriptPath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();
	const FAngelscriptModuleDesc* StructModule = FindModuleByName(Modules, ExpectedModuleName);
	const FAngelscriptEngine::FDiagnostics* StructDiagnostics = Engine.Diagnostics.Find(AbsoluteScriptPath);

	int32 ErrorCount = 0;
	const TArray<FString> DiagnosticMessages = CollectDiagnosticMessages(
		Engine,
		{AbsoluteScriptPath},
		ErrorCount);
	const FString DiagnosticSummary = FString::Join(DiagnosticMessages, TEXT("\n"));

	const FAngelscriptClassDesc* StructDesc = nullptr;
	if (StructModule != nullptr)
	{
		for (const TSharedRef<FAngelscriptClassDesc>& ClassDesc : StructModule->Classes)
		{
			if (ClassDesc->ClassName == TEXT("FDerivedStruct"))
			{
				StructDesc = &ClassDesc.Get();
				break;
			}
		}
	}

	const bool bFailedAsExpected = TestFalse(
		TEXT("Annotated USTRUCT inheritance should fail during preprocessing"),
		bPreprocessSucceeded);
	const bool bKeptSingleModuleDescriptor = TestEqual(
		TEXT("Annotated USTRUCT inheritance diagnostics should keep exactly one module descriptor for inspection"),
		Modules.Num(),
		1);
	const bool bHasExpectedModule = TestNotNull(
		TEXT("Annotated USTRUCT inheritance diagnostics should preserve the invalid module descriptor"),
		StructModule);
	const bool bHasDiagnostics = TestNotNull(
		TEXT("Annotated USTRUCT inheritance should emit diagnostics for the invalid file"),
		StructDiagnostics);
	const bool bHasSingleError = TestEqual(
		TEXT("Annotated USTRUCT inheritance should emit exactly one preprocessing error"),
		ErrorCount,
		1);
	const bool bMentionsInheritanceRule = TestTrue(
		TEXT("Annotated USTRUCT inheritance should report the dedicated struct-inheritance diagnostic"),
		DiagnosticSummary.Contains(ExpectedDiagnosticMessage));
	const bool bHasDiagnosticEntry = StructDiagnostics != nullptr
		&& TestTrue(
			TEXT("Annotated USTRUCT inheritance should record at least one diagnostic entry"),
			StructDiagnostics->Diagnostics.Num() > 0);
	const bool bPointsAtStructDeclarationLine = bHasDiagnosticEntry
		&& TestEqual(
			TEXT("Annotated USTRUCT inheritance diagnostic should point at the struct declaration line"),
			StructDiagnostics->Diagnostics[0].Row,
			1);
	const bool bDoesNotLeaveValidStructDescriptor = TestTrue(
		TEXT("Annotated USTRUCT inheritance should not leave a struct descriptor with a resolved super type"),
		StructDesc == nullptr
			|| (StructDesc->bIsStruct
				&& StructDesc->CodeSuperClass == nullptr
				&& StructDesc->Struct == nullptr));

	bPassed =
		bFailedAsExpected &&
		bKeptSingleModuleDescriptor &&
		bHasExpectedModule &&
		bHasDiagnostics &&
		bHasSingleError &&
		bMentionsInheritanceRule &&
		bHasDiagnosticEntry &&
		bPointsAtStructDeclarationLine &&
		bDoesNotLeaveValidStructDescriptor;

	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

bool FAngelscriptPreprocessorStructDefaultPropertySpecifierTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	Engine.ResetDiagnostics();

	UAngelscriptSettings* Settings = GetMutableDefault<UAngelscriptSettings>();
	if (!TestNotNull(TEXT("Struct default property specifier test should access mutable angelscript settings"), Settings))
	{
		return false;
	}

	const EAngelscriptPropertyEditSpecifier PreviousClassSpecifier = Settings->DefaultPropertyEditSpecifier;
	const EAngelscriptPropertyEditSpecifier PreviousStructSpecifier = Settings->DefaultPropertyEditSpecifierForStructs;
	ON_SCOPE_EXIT
	{
		Settings->DefaultPropertyEditSpecifier = PreviousClassSpecifier;
		Settings->DefaultPropertyEditSpecifierForStructs = PreviousStructSpecifier;
	};

	Settings->DefaultPropertyEditSpecifier = EAngelscriptPropertyEditSpecifier::NotEditable;
	Settings->DefaultPropertyEditSpecifierForStructs = EAngelscriptPropertyEditSpecifier::EditDefaultsOnly;

	const FString RelativeScriptPath = TEXT("Tests/Preprocessor/Structs/DefaultPropertySpecifierUsesStructSettings.as");
	const FString AbsoluteScriptPath = WritePreprocessorStructFixture(
		RelativeScriptPath,
		TEXT(R"AS(
USTRUCT()
struct FStructDefaultSpecifierCarrier
{
    UPROPERTY() int StructValue;
}

UCLASS()
class UClassDefaultSpecifierCarrier : UObject
{
    UPROPERTY() int ClassValue;
}
)AS"));
	ON_SCOPE_EXIT
	{
		IFileManager::Get().Delete(*AbsoluteScriptPath, false, true);
	};

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(RelativeScriptPath, AbsoluteScriptPath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();

	int32 ErrorCount = 0;
	const TArray<FString> DiagnosticMessages = CollectDiagnosticMessages(
		Engine,
		{AbsoluteScriptPath},
		ErrorCount);

	bPassed &= TestTrue(
		TEXT("Struct default property specifier test should preprocess successfully"),
		bPreprocessSucceeded);
	bPassed &= TestEqual(
		TEXT("Struct default property specifier test should not emit preprocessing errors"),
		ErrorCount,
		0);
	bPassed &= TestEqual(
		TEXT("Struct default property specifier test should keep preprocessing diagnostics empty"),
		DiagnosticMessages.Num(),
		0);
	bPassed &= TestEqual(
		TEXT("Struct default property specifier test should produce exactly one module descriptor"),
		Modules.Num(),
		1);
	if (!bPassed)
	{
		return false;
	}

	const FAngelscriptModuleDesc* Module = FindModuleByName(
		Modules,
		TEXT("Tests.Preprocessor.Structs.DefaultPropertySpecifierUsesStructSettings"));
	if (!TestNotNull(TEXT("Struct default property specifier test should resolve the generated module descriptor"), Module))
	{
		return false;
	}

	const FAngelscriptClassDesc* StructDesc = FindClassByName(Module, TEXT("FStructDefaultSpecifierCarrier"));
	const FAngelscriptClassDesc* ClassDesc = FindClassByName(Module, TEXT("UClassDefaultSpecifierCarrier"));
	if (!TestNotNull(TEXT("Struct default property specifier test should parse the annotated struct descriptor"), StructDesc) ||
		!TestNotNull(TEXT("Struct default property specifier test should parse the annotated class descriptor"), ClassDesc))
	{
		return false;
	}

	const FAngelscriptPropertyDesc* StructProperty = FindPropertyByName(StructDesc, TEXT("StructValue"));
	const FAngelscriptPropertyDesc* ClassProperty = FindPropertyByName(ClassDesc, TEXT("ClassValue"));
	if (!TestNotNull(TEXT("Struct default property specifier test should keep the struct property descriptor"), StructProperty) ||
		!TestNotNull(TEXT("Struct default property specifier test should keep the class property descriptor"), ClassProperty))
	{
		return false;
	}

	bPassed &= TestTrue(
		TEXT("Struct default property specifier test should keep the struct descriptor marked as a struct"),
		StructDesc->bIsStruct);
	bPassed &= TestFalse(
		TEXT("Struct default property specifier test should keep the class descriptor marked as a class"),
		ClassDesc->bIsStruct);
	bPassed &= TestEqual(
		TEXT("Struct default property specifier test should preserve the struct property name"),
		StructProperty->PropertyName,
		FString(TEXT("StructValue")));
	bPassed &= TestEqual(
		TEXT("Struct default property specifier test should preserve the class property name"),
		ClassProperty->PropertyName,
		FString(TEXT("ClassValue")));
	bPassed &= TestTrue(
		TEXT("Struct default property specifier test should apply EditDefaultsOnly to struct properties when no edit specifier is present"),
		StructProperty->bEditableOnDefaults);
	bPassed &= TestFalse(
		TEXT("Struct default property specifier test should keep struct properties non-instance-editable under EditDefaultsOnly"),
		StructProperty->bEditableOnInstance);
	bPassed &= TestFalse(
		TEXT("Struct default property specifier test should keep class properties non-default-editable when class defaults are NotEditable"),
		ClassProperty->bEditableOnDefaults);
	bPassed &= TestFalse(
		TEXT("Struct default property specifier test should keep class properties non-instance-editable when class defaults are NotEditable"),
		ClassProperty->bEditableOnInstance);

	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

#endif
