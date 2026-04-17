#include "Shared/AngelscriptTestMacros.h"
#include "Shared/AngelscriptTestEngineHelper.h"

#include "Preprocessor/AngelscriptPreprocessor.h"

#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorStressTests_Private
{
	const FName ModuleName(TEXT("Tests.Preprocessor.Stress.LongSourceRemainsDeterministic"));
	const FString RelativeScriptPath = TEXT("Tests/Preprocessor/Stress/LongSourceRemainsDeterministic.as");
	const int32 FunctionCount = 320;
	const int32 BaseReturnValue = 17;
	const int32 MinimumPreprocessedCodeLength = 30000;
	const int32 ExpectedEntryResult = 336;

	struct FPreprocessorModuleSnapshot
	{
		FString ModuleName;
		FString RelativeFilename;
		FString AbsoluteFilename;
		FString Code;
		int64 ModuleCodeHash = 0;
		int64 SectionCodeHash = 0;
	};

	FString BuildLongSourceScript()
	{
		FString Source;
		Source.Reserve(FunctionCount * 160);
		Source += TEXT("// Long-source preprocessor stress fixture\n");
		Source += TEXT("/* The repeated padding comments below are intentional. */\n\n");

		for (int32 FunctionIndex = 0; FunctionIndex < FunctionCount; ++FunctionIndex)
		{
			Source += FString::Printf(
				TEXT("// StressPadding_%03d_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_repeat_repeat_repeat\n"),
				FunctionIndex);
			Source += FString::Printf(TEXT("int Value_%03d()\n"), FunctionIndex);
			Source += TEXT("{\n");
			if (FunctionIndex == 0)
			{
				Source += FString::Printf(TEXT("    return %d;\n"), BaseReturnValue);
			}
			else
			{
				Source += FString::Printf(TEXT("    return Value_%03d() + 1;\n"), FunctionIndex - 1);
			}
			Source += TEXT("}\n\n");

			if ((FunctionIndex % 16) == 15)
			{
				Source += TEXT("// SpacerBlock\n\n");
			}
		}

		Source += TEXT("int Entry()\n");
		Source += TEXT("{\n");
		Source += FString::Printf(TEXT("    return Value_%03d();\n"), FunctionCount - 1);
		Source += TEXT("}\n");
		return Source;
	}

	FString WritePreprocessorStressFixture(const FString& RelativePath, const FString& Contents)
	{
		const FString AbsolutePath = FPaths::Combine(FPaths::ProjectSavedDir(), TEXT("Automation"), RelativePath);
		IFileManager::Get().MakeDirectory(*FPaths::GetPath(AbsolutePath), true);
		FFileHelper::SaveStringToFile(Contents, *AbsolutePath);
		return AbsolutePath;
	}

	bool CaptureSingleModuleSnapshot(
		FAutomationTestBase& Test,
		const TCHAR* Context,
		const TArray<TSharedRef<FAngelscriptModuleDesc>>& Modules,
		FPreprocessorModuleSnapshot& OutSnapshot)
	{
		if (!Test.TestEqual(
				*FString::Printf(TEXT("%s should emit exactly one module"), Context),
				Modules.Num(),
				1))
		{
			return false;
		}

		const FAngelscriptModuleDesc& Module = Modules[0].Get();
		if (!Test.TestEqual(
				*FString::Printf(TEXT("%s should emit exactly one code section"), Context),
				Module.Code.Num(),
				1))
		{
			return false;
		}

		const FAngelscriptModuleDesc::FCodeSection& Section = Module.Code[0];
		OutSnapshot.ModuleName = Module.ModuleName;
		OutSnapshot.RelativeFilename = Section.RelativeFilename;
		OutSnapshot.AbsoluteFilename = Section.AbsoluteFilename;
		OutSnapshot.Code = Section.Code;
		OutSnapshot.ModuleCodeHash = Module.CodeHash;
		OutSnapshot.SectionCodeHash = Section.CodeHash;
		return true;
	}

	bool RunPreprocessAndCapture(
		FAutomationTestBase& Test,
		const FString& RelativePath,
		const FString& AbsolutePath,
		FPreprocessorModuleSnapshot& OutSnapshot)
	{
		FAngelscriptPreprocessor Preprocessor;
		Preprocessor.AddFile(RelativePath, AbsolutePath);

		if (!Test.TestTrue(TEXT("Long-source stress test should preprocess successfully"), Preprocessor.Preprocess()))
		{
			return false;
		}

		return CaptureSingleModuleSnapshot(
			Test,
			TEXT("Long-source direct preprocess"),
			Preprocessor.GetModulesToCompile(),
			OutSnapshot);
	}
}

using namespace AngelscriptTest_Preprocessor_AngelscriptPreprocessorStressTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptPreprocessorLongSourceRemainsDeterministicTest,
	"Angelscript.TestModule.Preprocessor.Stress.LongSourceRemainsDeterministic",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptPreprocessorLongSourceRemainsDeterministicTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	const FString ScriptSource = BuildLongSourceScript();
	const FString AbsoluteScriptPath = WritePreprocessorStressFixture(RelativeScriptPath, ScriptSource);
	ON_SCOPE_EXIT
	{
		IFileManager::Get().Delete(*AbsoluteScriptPath, false, true, true);
	};

	TestTrue(
		TEXT("Long-source stress fixture should start above the minimum source length threshold"),
		ScriptSource.Len() > MinimumPreprocessedCodeLength);

	FPreprocessorModuleSnapshot FirstSnapshot;
	if (!RunPreprocessAndCapture(*this, RelativeScriptPath, AbsoluteScriptPath, FirstSnapshot))
	{
		return false;
	}

	FPreprocessorModuleSnapshot SecondSnapshot;
	if (!RunPreprocessAndCapture(*this, RelativeScriptPath, AbsoluteScriptPath, SecondSnapshot))
	{
		return false;
	}

	TestEqual(
		TEXT("Long-source direct preprocess should normalize the module name from the relative filename"),
		FirstSnapshot.ModuleName,
		ModuleName.ToString());
	TestEqual(
		TEXT("Long-source direct preprocess should preserve the relative filename"),
		FirstSnapshot.RelativeFilename,
		RelativeScriptPath);
	TestEqual(
		TEXT("Long-source direct preprocess should preserve the absolute filename"),
		FirstSnapshot.AbsoluteFilename,
		AbsoluteScriptPath);
	TestTrue(
		TEXT("Long-source direct preprocess should keep the condensed code non-empty"),
		!FirstSnapshot.Code.IsEmpty());
	TestTrue(
		TEXT("Long-source direct preprocess should keep the condensed code above the configured threshold"),
		FirstSnapshot.Code.Len() > MinimumPreprocessedCodeLength);
	TestTrue(
		TEXT("Long-source direct preprocess should preserve the generated entry function body"),
		FirstSnapshot.Code.Contains(FString::Printf(TEXT("return Value_%03d();"), FunctionCount - 1)));

	TestEqual(
		TEXT("Long-source repeated preprocess should keep the same module name"),
		SecondSnapshot.ModuleName,
		FirstSnapshot.ModuleName);
	TestEqual(
		TEXT("Long-source repeated preprocess should keep the same aggregate code hash"),
		SecondSnapshot.ModuleCodeHash,
		FirstSnapshot.ModuleCodeHash);
	TestEqual(
		TEXT("Long-source repeated preprocess should keep the same section code hash"),
		SecondSnapshot.SectionCodeHash,
		FirstSnapshot.SectionCodeHash);
	TestEqual(
		TEXT("Long-source repeated preprocess should keep the same condensed code"),
		SecondSnapshot.Code,
		FirstSnapshot.Code);

	AngelscriptTestSupport::FAngelscriptCompileTraceSummary Summary;
	const bool bCompiled = AngelscriptTestSupport::CompileModuleWithSummary(
		&Engine,
		ECompileType::SoftReloadOnly,
		ModuleName,
		RelativeScriptPath,
		ScriptSource,
		true,
		Summary);

	if (!TestTrue(
			TEXT("Long-source stress test should compile successfully after preprocess"),
			bCompiled))
	{
		return false;
	}

	TestEqual(
		TEXT("Long-source compile should prepare exactly one module description"),
		Summary.ModuleDescCount,
		1);
	TestEqual(
		TEXT("Long-source compile should produce exactly one compiled module"),
		Summary.CompiledModuleCount,
		1);
	TestEqual(
		TEXT("Long-source compile should report exactly one module name"),
		Summary.ModuleNames.Num(),
		1);
	if (!Summary.ModuleNames.IsEmpty())
	{
		TestEqual(
			TEXT("Long-source compile should preserve the normalized module name"),
			Summary.ModuleNames[0],
			ModuleName.ToString());
	}
	TestEqual(
		TEXT("Long-source compile should not emit diagnostics"),
		Summary.Diagnostics.Num(),
		0);

	int32 EntryResult = 0;
	const bool bExecuted = AngelscriptTestSupport::ExecuteIntFunction(
		&Engine,
		RelativeScriptPath,
		ModuleName,
		TEXT("int Entry()"),
		EntryResult);

	if (!TestTrue(
			TEXT("Long-source stress test should execute Entry() successfully after compile"),
			bExecuted))
	{
		return false;
	}

	TestEqual(
		TEXT("Long-source stress test should preserve the tail function result after preprocess and compile"),
		EntryResult,
		ExpectedEntryResult);

	ASTEST_END_SHARE_CLEAN
	return true;
}

#endif
