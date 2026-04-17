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

namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorPropertyDefaultSpecifierTests_Private
{
	FString GetPreprocessorPropertyFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("PreprocessorPropertyFixtures"));
	}

	FString WritePreprocessorPropertyFixture(const FString& RelativeScriptPath, const FString& Contents)
	{
		const FString AbsolutePath = FPaths::Combine(GetPreprocessorPropertyFixtureRoot(), RelativeScriptPath);
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

using namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorPropertyDefaultSpecifierTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorPropertyDefaultBlueprintAccessTest,
	"Angelscript.TestModule.Preprocessor.Properties.DefaultBlueprintAccessUsesSettings",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorPropertyDefaultBlueprintAccessTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	Engine.ResetDiagnostics();

	UAngelscriptSettings* Settings = GetMutableDefault<UAngelscriptSettings>();
	if (!TestNotNull(TEXT("Default blueprint access property test should access mutable angelscript settings"), Settings))
	{
		return false;
	}

	const EAngelscriptPropertyBlueprintSpecifier PreviousBlueprintSpecifier =
		Settings->DefaultPropertyBlueprintSpecifier;
	ON_SCOPE_EXIT
	{
		Settings->DefaultPropertyBlueprintSpecifier = PreviousBlueprintSpecifier;
	};

	Settings->DefaultPropertyBlueprintSpecifier = EAngelscriptPropertyBlueprintSpecifier::BlueprintReadOnly;

	const FString RelativeScriptPath = TEXT("Tests/Preprocessor/Properties/DefaultBlueprintAccessUsesSettings.as");
	const FString AbsoluteScriptPath = WritePreprocessorPropertyFixture(
		RelativeScriptPath,
		TEXT(R"AS(
UCLASS()
class UBlueprintAccessDefaultSpecifierCarrier : UObject
{
    UPROPERTY() int ImplicitAccess;
    UPROPERTY(BlueprintReadWrite) int ExplicitAccess;
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
		TEXT("Default blueprint access property test should preprocess successfully"),
		bPreprocessSucceeded);
	bPassed &= TestEqual(
		TEXT("Default blueprint access property test should not emit preprocessing errors"),
		ErrorCount,
		0);
	bPassed &= TestEqual(
		TEXT("Default blueprint access property test should keep diagnostics empty"),
		DiagnosticMessages.Num(),
		0);
	bPassed &= TestEqual(
		TEXT("Default blueprint access property test should produce exactly one module descriptor"),
		Modules.Num(),
		1);
	if (!bPassed)
	{
		return false;
	}

	const FAngelscriptModuleDesc* Module = FindModuleByName(
		Modules,
		TEXT("Tests.Preprocessor.Properties.DefaultBlueprintAccessUsesSettings"));
	if (!TestNotNull(TEXT("Default blueprint access property test should resolve the generated module descriptor"), Module))
	{
		return false;
	}

	const FAngelscriptClassDesc* ClassDesc =
		FindClassByName(Module, TEXT("UBlueprintAccessDefaultSpecifierCarrier"));
	if (!TestNotNull(TEXT("Default blueprint access property test should parse the annotated class descriptor"), ClassDesc))
	{
		return false;
	}

	const FAngelscriptPropertyDesc* ImplicitProperty = FindPropertyByName(ClassDesc, TEXT("ImplicitAccess"));
	const FAngelscriptPropertyDesc* ExplicitProperty = FindPropertyByName(ClassDesc, TEXT("ExplicitAccess"));
	if (!TestNotNull(TEXT("Default blueprint access property test should keep the implicit property descriptor"), ImplicitProperty) ||
		!TestNotNull(TEXT("Default blueprint access property test should keep the explicit property descriptor"), ExplicitProperty))
	{
		return false;
	}

	bPassed &= TestFalse(
		TEXT("Default blueprint access property test should keep the carrier marked as a class"),
		ClassDesc->bIsStruct);
	bPassed &= TestEqual(
		TEXT("Default blueprint access property test should preserve the implicit property name"),
		ImplicitProperty->PropertyName,
		FString(TEXT("ImplicitAccess")));
	bPassed &= TestEqual(
		TEXT("Default blueprint access property test should preserve the explicit property name"),
		ExplicitProperty->PropertyName,
		FString(TEXT("ExplicitAccess")));
	bPassed &= TestTrue(
		TEXT("Default blueprint access property test should make implicit properties blueprint-readable when settings default to BlueprintReadOnly"),
		ImplicitProperty->bBlueprintReadable);
	bPassed &= TestFalse(
		TEXT("Default blueprint access property test should keep implicit properties non-blueprint-writable when settings default to BlueprintReadOnly"),
		ImplicitProperty->bBlueprintWritable);
	bPassed &= TestTrue(
		TEXT("Default blueprint access property test should keep explicit BlueprintReadWrite properties blueprint-readable"),
		ExplicitProperty->bBlueprintReadable);
	bPassed &= TestTrue(
		TEXT("Default blueprint access property test should keep explicit BlueprintReadWrite properties blueprint-writable"),
		ExplicitProperty->bBlueprintWritable);

	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

#endif
