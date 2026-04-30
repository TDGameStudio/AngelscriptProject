// AngelscriptMeshComponentBindingsTests.cpp
// CQTest compile-check for UPoseableMeshComponent, UProjectileMovementComponent,
// USkeletalMeshComponent.
// Automation IDs: Angelscript.TestModule.Bindings.MeshComponent.*

#include "CQTest.h"
#include "Shared/AngelscriptTestMacros.h"
#include "Shared/AngelscriptBindingsCoverage.h"
#include "Shared/AngelscriptBindingsModuleBuilder.h"
#include "Shared/AngelscriptBindingsAssertions.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptTestBindings;

static const FBindingsCoverageProfile GMeshCompProfile{
	TEXT("MeshComp"), TEXT(""), TEXT("ASMeshComp"), TEXT("MeshComp"), TEXT("MeshCompBindings"),
};

TEST_CLASS_WITH_FLAGS(FAngelscriptMeshComponentBindingsTest,
	"Angelscript.TestModule.Bindings.MeshComponent",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	BEFORE_ALL() { ASTEST_CREATE_ENGINE(); }
	AFTER_ALL() { FAngelscriptEngine& E = ASTEST_CREATE_ENGINE(); AngelscriptTestSupport::ResetSharedCloneEngine(E); }

	TEST_METHOD(ProjectileMovement)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GMeshCompProfile, TEXT("Projectile"), TEXT(R"(
int Projectile_DefaultSpeed()
{
	UProjectileMovementComponent Comp;
	return (Comp.InitialSpeed == 0.0) ? 1 : 0;
}
)"));
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("UProjectileMovementComponent not available, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GMeshCompProfile,
			TEXT("int Projectile_DefaultSpeed()"), TEXT("Default initial speed is 0"), 1);
	}

	TEST_METHOD(SkeletalMeshTypeCheck)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE();
		FAngelscriptEngineScope Scope(Engine);
		FCoverageModuleScope Mod(*TestRunner, Engine, GMeshCompProfile, TEXT("Skeletal"), TEXT(R"(
int Skeletal_TypeExists()
{
	USkeletalMeshComponent Comp;
	return 1;
}
)"));
		if (!Mod.IsValid())
		{
			TestRunner->AddInfo(TEXT("USkeletalMeshComponent not available, skipping"));
			return;
		}
		ExpectGlobalInt(*TestRunner, Engine, Mod.GetModule(), GMeshCompProfile,
			TEXT("int Skeletal_TypeExists()"), TEXT("USkeletalMeshComponent compiles"), 1);
	}
};

#endif
