// AngelscriptFNameBindingsTests.cpp
// CQTest coverage for FName binding.
// Automation IDs: Angelscript.TestModule.Bindings.FName.*

#include "CQTest.h"
#include "Shared/AngelscriptTestMacros.h"
#include "Bindings/Shared/AngelscriptBindingsCoverage.h"
#include "Bindings/Shared/AngelscriptBindingsModuleBuilder.h"
#include "Bindings/Shared/AngelscriptBindingsAssertions.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptTestBindings;

static const FBindingsCoverageProfile GFNameProfile{
	TEXT("FName"), TEXT(""), TEXT("ASFName"), TEXT("FName"), TEXT("FNameBindings"),
};

TEST_CLASS_WITH_FLAGS(FAngelscriptFNameBindingsTest,
	"Angelscript.TestModule.Bindings.FName",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	BEFORE_ALL() { ASTEST_CREATE_ENGINE_SHARE_CLEAN(); }
	AFTER_ALL() { FAngelscriptEngine& E = ASTEST_CREATE_ENGINE_SHARE(); AngelscriptTestSupport::ResetSharedCloneEngine(E); }

	TEST_METHOD(FNameConstruction)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GFNameProfile, TEXT("Ctor"), TEXT(R"(
int FName_ConstructAndIsNone()
{
	FName N = n"TestName";
	return N.IsNone() ? 0 : 1;
}
)"));
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("FName not available, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GFNameProfile,
			TEXT("int FName_ConstructAndIsNone()"),
			TEXT("Constructed FName is not None"), 1);
	}

	TEST_METHOD(FNameNone)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GFNameProfile, TEXT("None"), TEXT(R"(
int FName_NoneIsNone()
{
	FName N;
	return N.IsNone() ? 1 : 0;
}
)"));
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("FName not available, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GFNameProfile,
			TEXT("int FName_NoneIsNone()"),
			TEXT("Default FName is None"), 1);
	}

	TEST_METHOD(FNameEquality)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GFNameProfile, TEXT("Equal"), TEXT(R"(
int FName_EqualityCheck()
{
	FName A = n"Hello";
	FName B = n"Hello";
	return (A == B) ? 1 : 0;
}
)"));
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("FName equality not available, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GFNameProfile,
			TEXT("int FName_EqualityCheck()"),
			TEXT("Same FName values are equal"), 1);
	}

	TEST_METHOD(FNameToString)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GFNameProfile, TEXT("ToString"), TEXT(R"(
int FName_ToStringLen()
{
	FName N = n"TestName";
	FString S = N.ToString();
	return S.Len();
}
)"));
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("FName.ToString not available, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GFNameProfile,
			TEXT("int FName_ToStringLen()"),
			TEXT("FName ToString length is 8"), 8);
	}
};

#endif
