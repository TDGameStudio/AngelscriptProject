// =============================================================================
// AngelscriptBox3fBindingsTests.cpp
//
// CQTest coverage for FBox, FBox3f, FBoxSphereBounds, FBoxSphereBounds3f bindings.
// Automation IDs: Angelscript.TestModule.Bindings.Box3f.*
// =============================================================================

#include "CQTest.h"
#include "Shared/AngelscriptTestMacros.h"
#include "Shared/AngelscriptBindingsCoverage.h"
#include "Shared/AngelscriptBindingsModuleBuilder.h"
#include "Shared/AngelscriptBindingsAssertions.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptTestBindings;

static const FBindingsCoverageProfile GBox3fProfile{
	TEXT("Box3f"),
	TEXT(""),
	TEXT("ASBox3f"),
	TEXT("Box3f"),
	TEXT("Box3fBindings"),
};

TEST_CLASS_WITH_FLAGS(FAngelscriptBox3fBindingsTest,
	"Angelscript.TestModule.Bindings.Box3f",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	BEFORE_ALL()
	{
		ASTEST_CREATE_ENGINE();
	}

	AFTER_ALL()
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		AngelscriptTestSupport::ResetSharedCloneEngine(Engine);
	}

	TEST_METHOD(FBoxConstruction)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);

		FCoverageModuleScope Mod(*TestRunner, Engine, GBox3fProfile, TEXT("FBoxCtor"), TEXT(R"(
int FBox_DefaultIsValid()
{
	FBox B;
	return B.IsValid ? 0 : 1;
}
int FBox_InitIsValid()
{
	FBox B = FBox(FVector(0,0,0), FVector(1,1,1));
	return B.IsValid ? 1 : 0;
}
int FBox_GetCenter()
{
	FBox B = FBox(FVector(0,0,0), FVector(10,10,10));
	FVector C = B.GetCenter();
	return (C.X == 5.0 && C.Y == 5.0 && C.Z == 5.0) ? 1 : 0;
}
int FBox_GetSize()
{
	FBox B = FBox(FVector(0,0,0), FVector(4,6,8));
	FVector S = B.GetSize();
	return (S.X == 4.0 && S.Y == 6.0 && S.Z == 8.0) ? 1 : 0;
}
)"));
		if (!Mod.IsValid()) return;
		auto& M = Mod.GetModule();

		const FExpectedGlobalInt Cases[] = {
			{ TEXT("int FBox_DefaultIsValid()"), TEXT("Default FBox is invalid"), 1 },
			{ TEXT("int FBox_InitIsValid()"),    TEXT("Initialized FBox is valid"), 1 },
			{ TEXT("int FBox_GetCenter()"),      TEXT("GetCenter returns midpoint"), 1 },
			{ TEXT("int FBox_GetSize()"),        TEXT("GetSize returns extent"), 1 },
		};
		ExpectGlobalInts(*TestRunner, Engine, M, GBox3fProfile, Cases);
	}

	TEST_METHOD(FBoxSphereBoundsConstruction)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);

		FCoverageModuleScope Mod(*TestRunner, Engine, GBox3fProfile, TEXT("BSBCtor"), TEXT(R"(
int BSB_Origin()
{
	FBoxSphereBounds B = FBoxSphereBounds(FVector(1,2,3), FVector(4,5,6), 10.0);
	return (B.Origin.X == 1.0 && B.Origin.Y == 2.0 && B.Origin.Z == 3.0) ? 1 : 0;
}
int BSB_SphereRadius()
{
	FBoxSphereBounds B = FBoxSphereBounds(FVector(0,0,0), FVector(1,1,1), 7.5);
	return (B.SphereRadius == 7.5) ? 1 : 0;
}
)"));
		if (!Mod.IsValid()) return;
		auto& M = Mod.GetModule();

		const FExpectedGlobalInt Cases[] = {
			{ TEXT("int BSB_Origin()"),       TEXT("BoxSphereBounds origin preserved"), 1 },
			{ TEXT("int BSB_SphereRadius()"), TEXT("BoxSphereBounds radius preserved"), 1 },
		};
		ExpectGlobalInts(*TestRunner, Engine, M, GBox3fProfile, Cases);
	}
};

#endif // WITH_DEV_AUTOMATION_TESTS
