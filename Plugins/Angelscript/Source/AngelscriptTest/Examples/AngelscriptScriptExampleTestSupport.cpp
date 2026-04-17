#include "AngelscriptScriptExampleTestSupport.h"

#include "../Shared/AngelscriptTestEngineHelper.h"
#include "../Shared/AngelscriptTestUtilities.h"

#include "Misc/AutomationTest.h"
#include "Misc/Paths.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptScriptExamples
{
	bool RunScriptExampleCompileTest(FAutomationTestBase& Test, const FScriptExampleSource& Example)
	{
		if (!Test.TestNotNull(TEXT("Script example file name should be set"), Example.ExampleFileName))
		{
			return false;
		}

		if (!Test.TestNotNull(TEXT("Script example text should be set"), Example.ScriptText))
		{
			return false;
		}

		const FString ExampleFileName = Example.ExampleFileName;
		const FString ModuleNameString = FPaths::GetBaseFilename(ExampleFileName);
		if (!Test.TestFalse(*FString::Printf(TEXT("Example file '%s' should map to a module name"), *ExampleFileName), ModuleNameString.IsEmpty()))
		{
			return false;
		}

		FAngelscriptEngine& Engine = AcquireCleanSharedCloneEngine();
		const FName ModuleName(*ModuleNameString);
		ON_SCOPE_EXIT
		{
			Engine.DiscardModule(*ModuleName.ToString());
		};

		FString CombinedScriptCode;
		if (Example.DependencyScriptText != nullptr)
		{
			if (!Test.TestNotNull(TEXT("Dependency example file name should be set"), Example.DependencyFileName))
			{
				return false;
			}

			CombinedScriptCode += Example.DependencyScriptText;
			CombinedScriptCode += TEXT("\n\n");
		}

		CombinedScriptCode += Example.ScriptText;

		const FString VirtualFileName = FString::Printf(TEXT("ScriptExamples/%s"), *ExampleFileName);
		const bool bCompiled = CompileAnnotatedModuleFromMemory(&Engine, ModuleName, VirtualFileName, CombinedScriptCode);
		Test.TestTrue(*FString::Printf(TEXT("Compile example '%s' succeeds"), *ExampleFileName), bCompiled);
		return bCompiled;
	}
}

using namespace AngelscriptScriptExamples;

#endif
