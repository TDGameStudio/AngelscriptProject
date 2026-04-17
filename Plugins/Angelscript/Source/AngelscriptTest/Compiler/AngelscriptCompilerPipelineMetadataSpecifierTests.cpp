#include "../Shared/AngelscriptTestEngineHelper.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Core/AngelscriptEngine.h"
#include "Preprocessor/AngelscriptPreprocessor.h"

#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"
#include "Misc/ScopeExit.h"
#include "UObject/Class.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace CompilerPipelineMetadataSpecifierTest
{
	static const FName ModuleName(TEXT("Tests.Compiler.MacroMetadataStringsWithClosingParen"));
	static const FString RelativeScriptPath(TEXT("Tests/Compiler/MacroMetadataStringsWithClosingParen.as"));
	static const FString ClassName(TEXT("UCompilerMetadataParenCarrier"));
	static const FString FunctionName(TEXT("GetClosingParenText"));
	static const FString EnumName(TEXT("ECompilerMetadataParenState"));

	static const FString ExpectedClassDisplayName(TEXT("Do (Test)"));
	static const FString ExpectedClassToolTip(TEXT("Class accepts ) text"));
	static const FString ExpectedFunctionDisplayName(TEXT("Run ) Now"));
	static const FString ExpectedFunctionToolTip(TEXT("Accepts ) in text"));
	static const FString ExpectedEnumToolTip(TEXT("Enum ) ToolTip"));
	static const FString ExpectedEnumValueDisplayName(TEXT("Alpha ) Value"));
	static const FString ExpectedEnumValueToolTip(TEXT("Alpha ) ToolTip"));

	FString GetFixtureRoot()
	{
		return FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), TEXT("CompilerMetadataSpecifierFixtures"));
	}

	FString WriteFixture(const FString& RelativePath, const FString& Contents)
	{
		const FString AbsolutePath = FPaths::Combine(GetFixtureRoot(), RelativePath);
		IFileManager::Get().MakeDirectory(*FPaths::GetPath(AbsolutePath), true);
		FFileHelper::SaveStringToFile(Contents, *AbsolutePath);
		return AbsolutePath;
	}

	TArray<FString> CollectDiagnosticMessages(
		const FAngelscriptEngine& Engine,
		const FString& AbsoluteFilename,
		int32& OutErrorCount)
	{
		OutErrorCount = 0;

		const FAngelscriptEngine::FDiagnostics* Diagnostics = Engine.Diagnostics.Find(AbsoluteFilename);
		if (Diagnostics == nullptr)
		{
			return {};
		}

		TArray<FString> Messages;
		for (const FAngelscriptEngine::FDiagnostic& Diagnostic : Diagnostics->Diagnostics)
		{
			Messages.Add(Diagnostic.Message);
			if (Diagnostic.bIsError)
			{
				++OutErrorCount;
			}
		}

		return Messages;
	}

	FString GetClassMeta(const TSharedPtr<FAngelscriptClassDesc>& ClassDesc, const TCHAR* Key)
	{
		if (!ClassDesc.IsValid())
		{
			return FString();
		}

		const FString* Value = ClassDesc->Meta.Find(FName(Key));
		return Value != nullptr ? *Value : FString();
	}

	FString GetFunctionMeta(const TSharedPtr<FAngelscriptFunctionDesc>& FunctionDesc, const TCHAR* Key)
	{
		if (!FunctionDesc.IsValid())
		{
			return FString();
		}

		const FString* Value = FunctionDesc->Meta.Find(FName(Key));
		return Value != nullptr ? *Value : FString();
	}

	FString GetEnumMeta(const TSharedPtr<FAngelscriptEnumDesc>& EnumDesc, const TCHAR* Key, int32 ValueIndex)
	{
		if (!EnumDesc.IsValid())
		{
			return FString();
		}

		const FString* Value = EnumDesc->Meta.Find(TPair<FName, int32>(FName(Key), ValueIndex));
		return Value != nullptr ? *Value : FString();
	}
}

using namespace CompilerPipelineMetadataSpecifierTest;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCompilerMacroMetadataStringsWithClosingParenTest,
	"Angelscript.TestModule.Compiler.EndToEnd.MacroMetadataStringsWithClosingParen",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptCompilerMacroMetadataStringsWithClosingParenTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	const FString ScriptSource = TEXT(R"AS(
UCLASS(meta=(DisplayName="Do (Test)", ToolTip="Class accepts ) text"))
class UCompilerMetadataParenCarrier : UObject
{
	UFUNCTION(meta=(DisplayName="Run ) Now", ToolTip="Accepts ) in text"))
	int GetClosingParenText()
	{
		return 7;
	}
}

UENUM(meta=(ToolTip="Enum ) ToolTip"))
enum class ECompilerMetadataParenState : uint8
{
	Alpha UMETA(DisplayName="Alpha ) Value", ToolTip="Alpha ) ToolTip"),
	Beta
}
)AS");

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	const FString AbsoluteScriptPath = CompilerPipelineMetadataSpecifierTest::WriteFixture(
		CompilerPipelineMetadataSpecifierTest::RelativeScriptPath,
		ScriptSource);
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*CompilerPipelineMetadataSpecifierTest::ModuleName.ToString());
		IFileManager::Get().Delete(*AbsoluteScriptPath, false, true);
	};

	Engine.ResetDiagnostics();

	FAngelscriptPreprocessor Preprocessor;
	Preprocessor.AddFile(CompilerPipelineMetadataSpecifierTest::RelativeScriptPath, AbsoluteScriptPath);

	const bool bPreprocessSucceeded = Preprocessor.Preprocess();
	const TArray<TSharedRef<FAngelscriptModuleDesc>> Modules = Preprocessor.GetModulesToCompile();

	int32 PreprocessErrorCount = 0;
	const TArray<FString> PreprocessMessages = CompilerPipelineMetadataSpecifierTest::CollectDiagnosticMessages(
		Engine,
		AbsoluteScriptPath,
		PreprocessErrorCount);

	bPassed &= TestTrue(
		TEXT("Metadata specifier scenario should preprocess successfully"),
		bPreprocessSucceeded);
	bPassed &= TestEqual(
		TEXT("Metadata specifier scenario should not emit preprocessing errors"),
		PreprocessErrorCount,
		0);
	bPassed &= TestEqual(
		TEXT("Metadata specifier scenario should keep preprocessing diagnostics empty"),
		PreprocessMessages.Num(),
		0);
	bPassed &= TestEqual(
		TEXT("Metadata specifier scenario should produce exactly one module descriptor"),
		Modules.Num(),
		1);
	if (!bPreprocessSucceeded || Modules.Num() != 1)
	{
		return false;
	}

	const TSharedRef<FAngelscriptModuleDesc> ModuleDesc = Modules[0];
	bPassed &= TestEqual(
		TEXT("Metadata specifier scenario should preserve the expected module name"),
		ModuleDesc->ModuleName,
		CompilerPipelineMetadataSpecifierTest::ModuleName.ToString());

	const TSharedPtr<FAngelscriptClassDesc> ClassDesc = ModuleDesc->GetClass(CompilerPipelineMetadataSpecifierTest::ClassName);
	if (!TestTrue(TEXT("Metadata specifier scenario should parse the annotated class descriptor"), ClassDesc.IsValid()))
	{
		return false;
	}

	const TSharedPtr<FAngelscriptFunctionDesc> FunctionDesc = ClassDesc->GetMethod(CompilerPipelineMetadataSpecifierTest::FunctionName);
	if (!TestTrue(TEXT("Metadata specifier scenario should parse the annotated function descriptor"), FunctionDesc.IsValid()))
	{
		return false;
	}

	const TSharedPtr<FAngelscriptEnumDesc> EnumDesc = ModuleDesc->GetEnum(CompilerPipelineMetadataSpecifierTest::EnumName);
	if (!TestTrue(TEXT("Metadata specifier scenario should parse the annotated enum descriptor"), EnumDesc.IsValid()))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("Preprocessor should preserve the class DisplayName metadata that contains balanced parentheses"),
		CompilerPipelineMetadataSpecifierTest::GetClassMeta(ClassDesc, TEXT("DisplayName")),
		CompilerPipelineMetadataSpecifierTest::ExpectedClassDisplayName);
	bPassed &= TestEqual(
		TEXT("Preprocessor should preserve the class ToolTip metadata that contains a closing parenthesis"),
		CompilerPipelineMetadataSpecifierTest::GetClassMeta(ClassDesc, TEXT("ToolTip")),
		CompilerPipelineMetadataSpecifierTest::ExpectedClassToolTip);
	bPassed &= TestEqual(
		TEXT("Preprocessor should preserve the function DisplayName metadata that contains a closing parenthesis"),
		CompilerPipelineMetadataSpecifierTest::GetFunctionMeta(FunctionDesc, TEXT("DisplayName")),
		CompilerPipelineMetadataSpecifierTest::ExpectedFunctionDisplayName);
	bPassed &= TestEqual(
		TEXT("Preprocessor should preserve the function ToolTip metadata that contains a closing parenthesis"),
		CompilerPipelineMetadataSpecifierTest::GetFunctionMeta(FunctionDesc, TEXT("ToolTip")),
		CompilerPipelineMetadataSpecifierTest::ExpectedFunctionToolTip);
	bPassed &= TestEqual(
		TEXT("Preprocessor should preserve the enum ToolTip metadata that contains a closing parenthesis"),
		CompilerPipelineMetadataSpecifierTest::GetEnumMeta(EnumDesc, TEXT("ToolTip"), INDEX_NONE),
		CompilerPipelineMetadataSpecifierTest::ExpectedEnumToolTip);
	bPassed &= TestEqual(
		TEXT("Preprocessor should preserve the enum value DisplayName metadata that contains a closing parenthesis"),
		CompilerPipelineMetadataSpecifierTest::GetEnumMeta(EnumDesc, TEXT("DisplayName"), 0),
		CompilerPipelineMetadataSpecifierTest::ExpectedEnumValueDisplayName);
	bPassed &= TestEqual(
		TEXT("Preprocessor should preserve the enum value ToolTip metadata that contains a closing parenthesis"),
		CompilerPipelineMetadataSpecifierTest::GetEnumMeta(EnumDesc, TEXT("ToolTip"), 0),
		CompilerPipelineMetadataSpecifierTest::ExpectedEnumValueToolTip);

	Engine.ResetDiagnostics();

	FAngelscriptCompileTraceSummary Summary;
	const bool bCompiled = CompileModuleWithSummary(
		&Engine,
		ECompileType::FullReload,
		CompilerPipelineMetadataSpecifierTest::ModuleName,
		CompilerPipelineMetadataSpecifierTest::RelativeScriptPath,
		ScriptSource,
		true,
		Summary,
		true);

	bPassed &= TestTrue(
		TEXT("Metadata specifier scenario should compile through the normal preprocessor pipeline"),
		bCompiled);
	bPassed &= TestTrue(
		TEXT("Metadata specifier scenario should report that it used the preprocessor"),
		Summary.bUsedPreprocessor);
	bPassed &= TestTrue(
		TEXT("Metadata specifier scenario should mark compile succeeded in the summary"),
		Summary.bCompileSucceeded);
	if (Summary.Diagnostics.Num() > 0)
	{
		TArray<FString> DiagnosticMessages;
		for (const FAngelscriptCompileTraceDiagnosticSummary& Diagnostic : Summary.Diagnostics)
		{
			DiagnosticMessages.Add(FString::Printf(
				TEXT("[%s] %s"),
				Diagnostic.bIsError ? TEXT("Error") : TEXT("Warning"),
				*Diagnostic.Message));
		}

		AddInfo(FString::Printf(
			TEXT("Compile diagnostics: %s"),
			*FString::Join(DiagnosticMessages, TEXT(" | "))));
	}
	bPassed &= TestEqual(
		TEXT("Metadata specifier scenario should keep compile diagnostics empty"),
		Summary.Diagnostics.Num(),
		0);
	if (!bCompiled)
	{
		return false;
	}

	UClass* GeneratedClass = FindGeneratedClass(&Engine, *CompilerPipelineMetadataSpecifierTest::ClassName);
	if (!TestNotNull(TEXT("Metadata specifier scenario should materialize the generated class"), GeneratedClass))
	{
		return false;
	}

	UFunction* GeneratedFunction = FindGeneratedFunction(GeneratedClass, *CompilerPipelineMetadataSpecifierTest::FunctionName);
	if (!TestNotNull(TEXT("Metadata specifier scenario should materialize the generated function"), GeneratedFunction))
	{
		return false;
	}

	const TSharedPtr<FAngelscriptEnumDesc> GeneratedEnumDesc = Engine.GetEnum(CompilerPipelineMetadataSpecifierTest::EnumName);
	if (!TestTrue(TEXT("Metadata specifier scenario should register the generated enum descriptor"), GeneratedEnumDesc.IsValid()))
	{
		return false;
	}
	if (!TestNotNull(TEXT("Metadata specifier scenario should materialize the generated UEnum"), GeneratedEnumDesc->Enum))
	{
		return false;
	}

	UEnum* GeneratedEnum = GeneratedEnumDesc->Enum;
	bPassed &= TestEqual(
		TEXT("Generated class should preserve DisplayName metadata with balanced parentheses"),
		GeneratedClass->GetMetaData(TEXT("DisplayName")),
		CompilerPipelineMetadataSpecifierTest::ExpectedClassDisplayName);
	bPassed &= TestEqual(
		TEXT("Generated class should preserve ToolTip metadata with a closing parenthesis"),
		GeneratedClass->GetMetaData(TEXT("ToolTip")),
		CompilerPipelineMetadataSpecifierTest::ExpectedClassToolTip);
	bPassed &= TestEqual(
		TEXT("Generated function should preserve DisplayName metadata with a closing parenthesis"),
		GeneratedFunction->GetMetaData(TEXT("DisplayName")),
		CompilerPipelineMetadataSpecifierTest::ExpectedFunctionDisplayName);
	bPassed &= TestEqual(
		TEXT("Generated function should preserve ToolTip metadata with a closing parenthesis"),
		GeneratedFunction->GetMetaData(TEXT("ToolTip")),
		CompilerPipelineMetadataSpecifierTest::ExpectedFunctionToolTip);
	bPassed &= TestEqual(
		TEXT("Generated enum should preserve ToolTip metadata with a closing parenthesis"),
		GeneratedEnum->GetMetaData(TEXT("ToolTip")),
		CompilerPipelineMetadataSpecifierTest::ExpectedEnumToolTip);
	bPassed &= TestEqual(
		TEXT("Generated enum value should preserve DisplayName metadata with a closing parenthesis"),
		GeneratedEnum->GetMetaData(TEXT("DisplayName"), 0),
		CompilerPipelineMetadataSpecifierTest::ExpectedEnumValueDisplayName);
	bPassed &= TestEqual(
		TEXT("Generated enum value should preserve ToolTip metadata with a closing parenthesis"),
		GeneratedEnum->GetMetaData(TEXT("ToolTip"), 0),
		CompilerPipelineMetadataSpecifierTest::ExpectedEnumValueToolTip);
	bPassed &= TestEqual(
		TEXT("Generated enum display text should preserve the full DisplayName metadata"),
		GeneratedEnum->GetDisplayNameTextByIndex(0).ToString(),
		CompilerPipelineMetadataSpecifierTest::ExpectedEnumValueDisplayName);

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
