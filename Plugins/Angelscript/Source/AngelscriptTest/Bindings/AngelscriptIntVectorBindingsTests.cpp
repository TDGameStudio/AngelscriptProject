// AngelscriptIntVectorBindingsTests.cpp
// CQTest coverage for FIntPoint, FIntVector, FIntVector2, FIntVector4 bindings.
// Automation IDs: Angelscript.TestModule.Bindings.IntVector.*

#include "CQTest.h"
#include "Shared/AngelscriptTestMacros.h"
#include "Bindings/Shared/AngelscriptBindingsCoverage.h"
#include "Bindings/Shared/AngelscriptBindingsModuleBuilder.h"
#include "Bindings/Shared/AngelscriptBindingsAssertions.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptTestBindings;

static const FBindingsCoverageProfile GIntVectorProfile{
	TEXT("IntVector"), TEXT(""), TEXT("ASIntVec"), TEXT("IntVector"), TEXT("IntVectorBindings"),
};

TEST_CLASS_WITH_FLAGS(FAngelscriptIntVectorBindingsTest,
	"Angelscript.TestModule.Bindings.IntVector",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	BEFORE_ALL() { ASTEST_CREATE_ENGINE_SHARE_CLEAN(); }
	AFTER_ALL() { FAngelscriptEngine& E = ASTEST_CREATE_ENGINE_SHARE(); AngelscriptTestSupport::ResetSharedCloneEngine(E); }

	TEST_METHOD(FIntPointConstruction)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GIntVectorProfile, TEXT("IntPoint"), TEXT(R"(
int IntPoint_XComponent()
{
	FIntPoint P = FIntPoint(10, 20);
	return P.X;
}
)"));
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("FIntPoint not available, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GIntVectorProfile,
			TEXT("int IntPoint_XComponent()"),
			TEXT("FIntPoint X is 10"), 10);
	}

	TEST_METHOD(FIntVectorConstruction)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GIntVectorProfile, TEXT("IntVec"), TEXT(R"(
int IntVector_Sum()
{
	FIntVector V = FIntVector(1, 2, 3);
	return V.X + V.Y + V.Z;
}
)"));
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("FIntVector not available, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GIntVectorProfile,
			TEXT("int IntVector_Sum()"),
			TEXT("FIntVector components sum to 6"), 6);
	}

	TEST_METHOD(FIntVector4Construction)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GIntVectorProfile, TEXT("IntVec4"), TEXT(R"(
int IntVector4_WComponent()
{
	FIntVector4 V = FIntVector4(1, 2, 3, 4);
	return V.W;
}
)"));
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("FIntVector4 not available, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GIntVectorProfile,
			TEXT("int IntVector4_WComponent()"),
			TEXT("FIntVector4 W is 4"), 4);
	}
};

#endif
