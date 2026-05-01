#include "AngelscriptEngine.h"
#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

struct FAngelscriptDependencyInjectionTestAccess
{
	static void ResetToIsolatedEngineState()
	{
		if (FAngelscriptEngine::IsInitialized())
		{
			FAngelscriptEngine::DestroyGlobal();
		}
	}
};

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptInjectedScriptRootDiscoveryTest,
	"Angelscript.TestModule.CppTests.Engine.DependencyInjection.ScriptRoots",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptInjectedProjectOnlyScriptRootDiscoveryTest,
	"Angelscript.TestModule.CppTests.Engine.DependencyInjection.ProjectOnlyScriptRoots",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptInjectedMissingPluginScriptRootSkipTest,
	"Angelscript.TestModule.CppTests.Engine.DependencyInjection.SkipMissingPluginRoots",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptInjectedEditorCreatesProjectScriptRootTest,
	"Angelscript.TestModule.CppTests.Engine.DependencyInjection.EditorCreatesProjectRoot",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCreateLegacyAliasSkipsProductionDirectorySetupTest,
	"Angelscript.TestModule.CppTests.Engine.DependencyInjection.Create.LegacyAliasSkipsProductionDirectorySetup",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCreateTestingFullEngineSkipsProductionDirectorySetupTest,
	"Angelscript.TestModule.CppTests.Engine.DependencyInjection.CreateTestingFullEngine.SkipsProductionDirectorySetup",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptInjectedScriptRootDiscoveryTest::RunTest(const FString& Parameters)
{
	FAngelscriptDependencyInjectionTestAccess::ResetToIsolatedEngineState();

	FAngelscriptEngineConfig Config;
	FAngelscriptEngineDependencies Dependencies;

	Dependencies.GetProjectDir = []()
	{
		return FString(TEXT("C:/InjectedProject"));
	};

	Dependencies.ConvertRelativePathToFull = [](const FString& Path)
	{
		return Path;
	};

	Dependencies.DirectoryExists = [](const FString& Path)
	{
		return Path == TEXT("C:/InjectedProject/Script")
			|| Path == TEXT("C:/Plugins/Beta/Script")
			|| Path == TEXT("C:/Plugins/Alpha/Script");
	};

	Dependencies.MakeDirectory = [](const FString& Path, bool bTree)
	{
		return true;
	};

	Dependencies.GetEnabledPluginScriptRoots = []()
	{
		return TArray<FString>
		{
			TEXT("C:/Plugins/Beta/Script"),
			TEXT("C:/Plugins/Alpha/Script"),
		};
	};

	TUniquePtr<FAngelscriptEngine> Engine = FAngelscriptEngine::CreateUncompiledWithMode(Config, Dependencies);
	TArray<FString> Roots = Engine->DiscoverScriptRoots(false);

	TestEqual(TEXT("Injected project root should be first"), Roots[0], FString(TEXT("C:/InjectedProject/Script")));
	TestEqual(TEXT("Injected plugin roots should be sorted deterministically"), Roots[1], FString(TEXT("C:/Plugins/Alpha/Script")));
	TestEqual(TEXT("Injected plugin roots should keep all entries"), Roots[2], FString(TEXT("C:/Plugins/Beta/Script")));

	return true;
}

bool FAngelscriptInjectedProjectOnlyScriptRootDiscoveryTest::RunTest(const FString& Parameters)
{
	FAngelscriptDependencyInjectionTestAccess::ResetToIsolatedEngineState();

	FAngelscriptEngineConfig Config;
	FAngelscriptEngineDependencies Dependencies;

	Dependencies.GetProjectDir = []()
	{
		return FString(TEXT("C:/InjectedProjectOnly"));
	};

	Dependencies.ConvertRelativePathToFull = [](const FString& Path)
	{
		return Path;
	};

	Dependencies.DirectoryExists = [](const FString& Path)
	{
		return Path == TEXT("C:/InjectedProjectOnly/Script")
			|| Path == TEXT("C:/Plugins/ShouldNotAppear/Script");
	};

	Dependencies.MakeDirectory = [](const FString& Path, bool bTree)
	{
		return true;
	};

	Dependencies.GetEnabledPluginScriptRoots = []()
	{
		return TArray<FString>
		{
			TEXT("C:/Plugins/ShouldNotAppear/Script"),
		};
	};

	TUniquePtr<FAngelscriptEngine> Engine = FAngelscriptEngine::CreateUncompiledWithMode(Config, Dependencies);
	TArray<FString> Roots = Engine->DiscoverScriptRoots(true);

	TestEqual(TEXT("Project-only discovery should return exactly one root"), Roots.Num(), 1);
	if (Roots.Num() == 1)
	{
		TestEqual(TEXT("Project-only discovery should keep only the project root"), Roots[0], FString(TEXT("C:/InjectedProjectOnly/Script")));
	}

	return true;
}

bool FAngelscriptInjectedMissingPluginScriptRootSkipTest::RunTest(const FString& Parameters)
{
	FAngelscriptDependencyInjectionTestAccess::ResetToIsolatedEngineState();

	FAngelscriptEngineConfig Config;
	FAngelscriptEngineDependencies Dependencies;

	Dependencies.GetProjectDir = []()
	{
		return FString(TEXT("C:/InjectedSkipProject"));
	};

	Dependencies.ConvertRelativePathToFull = [](const FString& Path)
	{
		return Path;
	};

	Dependencies.DirectoryExists = [](const FString& Path)
	{
		return Path == TEXT("C:/InjectedSkipProject/Script")
			|| Path == TEXT("C:/Plugins/Alpha/Script");
	};

	Dependencies.MakeDirectory = [](const FString& Path, bool bTree)
	{
		return true;
	};

	Dependencies.GetEnabledPluginScriptRoots = []()
	{
		return TArray<FString>
		{
			TEXT("C:/Plugins/Missing/Script"),
			TEXT("C:/Plugins/Alpha/Script"),
			TEXT("C:/InjectedSkipProject/Script"),
		};
	};

	TUniquePtr<FAngelscriptEngine> Engine = FAngelscriptEngine::CreateUncompiledWithMode(Config, Dependencies);
	TArray<FString> Roots = Engine->DiscoverScriptRoots(false);

	TestEqual(TEXT("Missing plugin roots should be skipped and project root should not be duplicated"), Roots.Num(), 2);
	if (Roots.Num() == 2)
	{
		TestEqual(TEXT("Project root should remain first when skipping missing plugin roots"), Roots[0], FString(TEXT("C:/InjectedSkipProject/Script")));
		TestEqual(TEXT("Only existing plugin root should remain after skipping missing roots"), Roots[1], FString(TEXT("C:/Plugins/Alpha/Script")));
	}

	return true;
}

bool FAngelscriptInjectedEditorCreatesProjectScriptRootTest::RunTest(const FString& Parameters)
{
	FAngelscriptDependencyInjectionTestAccess::ResetToIsolatedEngineState();

	FAngelscriptEngineConfig Config;
	Config.bIsEditor = true;

	bool bMakeDirectoryCalled = false;
	FString CreatedPath;

	FAngelscriptEngineDependencies Dependencies;
	Dependencies.GetProjectDir = []()
	{
		return FString(TEXT("C:/InjectedEditorProject"));
	};

	Dependencies.ConvertRelativePathToFull = [](const FString& Path)
	{
		return Path;
	};

	Dependencies.DirectoryExists = [](const FString& Path)
	{
		return false;
	};

	Dependencies.MakeDirectory = [&bMakeDirectoryCalled, &CreatedPath](const FString& Path, bool bTree)
	{
		bMakeDirectoryCalled = true;
		CreatedPath = Path;
		return true;
	};

	Dependencies.GetEnabledPluginScriptRoots = []()
	{
		return TArray<FString>();
	};

	TUniquePtr<FAngelscriptEngine> Engine = FAngelscriptEngine::CreateUncompiledWithMode(Config, Dependencies);
	TArray<FString> Roots = Engine->DiscoverScriptRoots(false);

	TestTrue(TEXT("Editor discovery should create the missing project script root"), bMakeDirectoryCalled);
	TestEqual(TEXT("Editor discovery should create the expected project script root path"), CreatedPath, FString(TEXT("C:/InjectedEditorProject/Script")));
	TestEqual(TEXT("Editor discovery should still return the project root after creation"), Roots.Num(), 1);
	if (Roots.Num() == 1)
	{
		TestEqual(TEXT("Created project root should be returned by discovery"), Roots[0], FString(TEXT("C:/InjectedEditorProject/Script")));
	}

	return true;
}

bool FAngelscriptCreateLegacyAliasSkipsProductionDirectorySetupTest::RunTest(const FString& Parameters)
{
	FAngelscriptDependencyInjectionTestAccess::ResetToIsolatedEngineState();

	FAngelscriptEngineConfig Config;
	Config.bIsEditor = true;

	bool bMakeDirectoryCalled = false;
	FString CreatedPath;

	FAngelscriptEngineDependencies Dependencies;
	Dependencies.GetProjectDir = []()
	{
		return FString(TEXT("C:/CreateFactoryProject"));
	};
	Dependencies.ConvertRelativePathToFull = [](const FString& Path)
	{
		return Path;
	};
	Dependencies.DirectoryExists = [](const FString& Path)
	{
		return false;
	};
	Dependencies.MakeDirectory = [&bMakeDirectoryCalled, &CreatedPath](const FString& Path, bool bTree)
	{
		bMakeDirectoryCalled = true;
		CreatedPath = Path;
		return true;
	};
	Dependencies.GetEnabledPluginScriptRoots = []()
	{
		return TArray<FString>();
	};

	TUniquePtr<FAngelscriptEngine> Engine = FAngelscriptEngine::Create(Config, Dependencies);
	if (!TestNotNull(TEXT("Create.LegacyAliasSkipsProductionDirectorySetup should create a testing full engine wrapper"), Engine.Get()))
	{
		return false;
	}

	TestFalse(TEXT("Create.LegacyAliasSkipsProductionDirectorySetup should not run the production script-root setup path"), bMakeDirectoryCalled);
	return TestEqual(TEXT("Create.LegacyAliasSkipsProductionDirectorySetup should keep the production setup path untouched"), CreatedPath, FString());
}

bool FAngelscriptCreateTestingFullEngineSkipsProductionDirectorySetupTest::RunTest(const FString& Parameters)
{
	FAngelscriptDependencyInjectionTestAccess::ResetToIsolatedEngineState();

	FAngelscriptEngineConfig Config;
	Config.bIsEditor = true;

	bool bMakeDirectoryCalled = false;

	FAngelscriptEngineDependencies Dependencies;
	Dependencies.GetProjectDir = []()
	{
		return FString(TEXT("C:/CreateTestingFullProject"));
	};
	Dependencies.ConvertRelativePathToFull = [](const FString& Path)
	{
		return Path;
	};
	Dependencies.DirectoryExists = [](const FString& Path)
	{
		return false;
	};
	Dependencies.MakeDirectory = [&bMakeDirectoryCalled](const FString& Path, bool bTree)
	{
		bMakeDirectoryCalled = true;
		return true;
	};
	Dependencies.GetEnabledPluginScriptRoots = []()
	{
		return TArray<FString>();
	};

	TUniquePtr<FAngelscriptEngine> Engine = FAngelscriptEngine::CreateUncompiled(Config, Dependencies);
	if (!TestNotNull(TEXT("CreateTestingFullEngine.SkipsProductionDirectorySetup should create a testing full engine"), Engine.Get()))
	{
		return false;
	}

	return TestFalse(TEXT("CreateTestingFullEngine.SkipsProductionDirectorySetup should not run the production script-root setup path"), bMakeDirectoryCalled);
}

#endif
