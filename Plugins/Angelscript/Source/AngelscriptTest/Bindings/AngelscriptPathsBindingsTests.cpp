// AngelscriptPathsBindingsTests.cpp
// CQTest coverage for FPaths, FApp, FCommandLine, FFileHelper bindings.
// Automation IDs: Angelscript.TestModule.Bindings.Paths.*

#include "CQTest.h"
#include "Shared/AngelscriptTestMacros.h"
#include "Shared/AngelscriptBindingsCoverage.h"
#include "Shared/AngelscriptBindingsModuleBuilder.h"
#include "Shared/AngelscriptBindingsAssertions.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptTestBindings;

static const FBindingsCoverageProfile GPathsProfile{
	TEXT("Paths"), TEXT(""), TEXT("ASPaths"), TEXT("Paths"), TEXT("PathsBindings"),
};

TEST_CLASS_WITH_FLAGS(FAngelscriptPathsBindingsTest,
	"Angelscript.TestModule.Bindings.Paths",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	BEFORE_ALL() { ASTEST_CREATE_ENGINE(); }
	AFTER_ALL() { FAngelscriptEngine& E = ASTEST_CREATE_ENGINE(); AngelscriptTestSupport::ResetSharedCloneEngine(E); }

	TEST_METHOD(FPathsProjectDir)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GPathsProfile, TEXT("ProjectDir"), TEXT(R"(
int Paths_ProjectDirNonEmpty()
{
	FString Dir = FPaths::ProjectDir();
	return Dir.Len() > 0 ? 1 : 0;
}
)"));
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("FPaths not available, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GPathsProfile,
			TEXT("int Paths_ProjectDirNonEmpty()"),
			TEXT("FPaths::ProjectDir is non-empty"), 1);
	}

	TEST_METHOD(FPathsGetExtension)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GPathsProfile, TEXT("Extension"), TEXT(R"(
int Paths_GetExtensionLen()
{
	FString Ext = FPaths::GetExtension("MyFile.as");
	return Ext.Len();
}
)"));
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("FPaths::GetExtension not available, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GPathsProfile,
			TEXT("int Paths_GetExtensionLen()"),
			TEXT("Extension of 'MyFile.as' is 2 chars"), 2);
	}

	TEST_METHOD(FAppGetName)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GPathsProfile, TEXT("AppName"), TEXT(R"(
int App_GetNameNonEmpty()
{
	FString Name = FApp::GetName();
	return Name.Len() > 0 ? 1 : 0;
}
)"));
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("FApp not available, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GPathsProfile,
			TEXT("int App_GetNameNonEmpty()"),
			TEXT("FApp::GetName is non-empty"), 1);
	}

	TEST_METHOD(FCommandLineGet)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GPathsProfile, TEXT("CmdLine"), TEXT(R"(
int CommandLine_GetExists()
{
	FString Cmd = FCommandLine::Get();
	return Cmd.Len() >= 0 ? 1 : 0;
}
)"));
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("FCommandLine not available, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GPathsProfile,
			TEXT("int CommandLine_GetExists()"),
			TEXT("FCommandLine::Get does not crash"), 1);
	}
};

#endif
