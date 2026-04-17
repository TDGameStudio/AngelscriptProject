#include "../Shared/AngelscriptTestUtilities.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Components/BoxComponent.h"
#include "Engine/OverlapResult.h"
#include "GameFramework/Actor.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBindingsCollisionShapeCompatTest,
	"Angelscript.TestModule.Bindings.CollisionShapeCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBindingsCollisionResultAccessorsCompatTest,
	"Angelscript.TestModule.Bindings.CollisionResultAccessorsCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Bindings_AngelscriptCollisionValueBindingsTests_Private
{
	static constexpr ANSICHAR CollisionResultAccessorsModuleName[] = "ASCollisionResultAccessorsCompat";

	bool SetArgAddressChecked(
		FAutomationTestBase& Test,
		asIScriptContext& Context,
		asUINT ArgumentIndex,
		void* Address,
		const TCHAR* ContextLabel)
	{
		return Test.TestEqual(
			*FString::Printf(TEXT("%s should bind address argument %u"), ContextLabel, static_cast<uint32>(ArgumentIndex)),
			Context.SetArgAddress(ArgumentIndex, Address),
			static_cast<int32>(asSUCCESS));
	}

	bool SetArgObjectChecked(
		FAutomationTestBase& Test,
		asIScriptContext& Context,
		asUINT ArgumentIndex,
		void* Object,
		const TCHAR* ContextLabel)
	{
		return Test.TestEqual(
			*FString::Printf(TEXT("%s should bind object argument %u"), ContextLabel, static_cast<uint32>(ArgumentIndex)),
			Context.SetArgObject(ArgumentIndex, Object),
			static_cast<int32>(asSUCCESS));
	}

	bool ExecuteIntFunction(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		asIScriptModule& Module,
		const TCHAR* FunctionDecl,
		TFunctionRef<bool(asIScriptContext&)> BindArguments,
		const TCHAR* ContextLabel,
		int32& OutResult)
	{
		asIScriptFunction* Function = GetFunctionByDecl(Test, Module, FunctionDecl);
		if (Function == nullptr)
		{
			return false;
		}

		FAngelscriptEngineScope EngineScope(Engine);
		asIScriptContext* Context = Engine.CreateContext();
		if (!Test.TestNotNull(*FString::Printf(TEXT("%s should create an execution context"), ContextLabel), Context))
		{
			return false;
		}

		ON_SCOPE_EXIT
		{
			Context->Release();
		};

		const int PrepareResult = Context->Prepare(Function);
		if (!Test.TestEqual(
			*FString::Printf(TEXT("%s should prepare successfully"), ContextLabel),
			PrepareResult,
			static_cast<int32>(asSUCCESS)))
		{
			return false;
		}

		if (!BindArguments(*Context))
		{
			return false;
		}

		const int ExecuteResult = Context->Execute();
		if (!Test.TestEqual(
			*FString::Printf(TEXT("%s should execute successfully"), ContextLabel),
			ExecuteResult,
			static_cast<int32>(asEXECUTION_FINISHED)))
		{
			return false;
		}

		OutResult = static_cast<int32>(Context->GetReturnDWord());
		return true;
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptCollisionValueBindingsTests_Private;

bool FAngelscriptBindingsCollisionShapeCompatTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	int32 FailureMask = 0;
	ASTEST_COMPILE_RUN_INT(
		Engine,
		"ASCollisionShapeCompat",
		TEXT(R"AS(
bool MatchesVector(const FVector InValue, const float X, const float Y, const float Z)
{
	return InValue.X == X && InValue.Y == Y && InValue.Z == Z;
}

int Run()
{
	int Failures = 0;

	FCollisionShape Shape;
	if (!Shape.IsLine())
		Failures |= 1;
	if (!Shape.IsNearlyZero())
		Failures |= 2;
	if (!MatchesVector(Shape.GetExtent(), 0.0f, 0.0f, 0.0f))
		Failures |= 4;

	Shape.SetBox(FVector(10.0f, 20.0f, 30.0f));
	if (!Shape.IsBox())
		Failures |= 8;
	if (!MatchesVector(Shape.GetBox(), 10.0f, 20.0f, 30.0f))
		Failures |= 16;
	if (!MatchesVector(Shape.GetExtent(), 10.0f, 20.0f, 30.0f))
		Failures |= 32;

	Shape.SetSphere(15.0f);
	if (!Shape.IsSphere())
		Failures |= 64;
	if (Shape.GetSphereRadius() != 15.0f)
		Failures |= 128;

	Shape.SetCapsule(7.0f, 12.0f);
	if (!Shape.IsCapsule())
		Failures |= 256;
	if (Shape.GetCapsuleRadius() != 7.0f)
		Failures |= 512;
	if (Shape.GetCapsuleHalfHeight() != 12.0f)
		Failures |= 1024;

	FCollisionShape BoxFactory = FCollisionShape::MakeBox(FVector(10.0f, 20.0f, 30.0f));
	if (!BoxFactory.IsBox())
		Failures |= 2048;
	if (!MatchesVector(BoxFactory.GetBox(), 10.0f, 20.0f, 30.0f))
		Failures |= 4096;

	FCollisionShape SphereFactory = FCollisionShape::MakeSphere(15.0f);
	if (!SphereFactory.IsSphere() || SphereFactory.GetSphereRadius() != 15.0f)
		Failures |= 8192;

	FCollisionShape CapsuleFactory = FCollisionShape::MakeCapsule(7.0f, 12.0f);
	if (!CapsuleFactory.IsCapsule())
		Failures |= 16384;
	if (CapsuleFactory.GetCapsuleRadius() != 7.0f || CapsuleFactory.GetCapsuleHalfHeight() != 12.0f)
		Failures |= 32768;

	if (FCollisionShape::MinBoxExtent() <= 0.0f)
		Failures |= 65536;
	if (FCollisionShape::MinSphereRadius() <= 0.0f)
		Failures |= 131072;
	if (FCollisionShape::MinCapsuleRadius() <= 0.0f)
		Failures |= 262144;
	if (FCollisionShape::MinCapsuleAxisHalfHeight() <= 0.0f)
		Failures |= 524288;

	return Failures;
}
)AS"),
		TEXT("int Run()"),
		FailureMask);

	TestEqual(TEXT("CollisionShapeCompat should preserve all collision-shape mutator and factory semantics"), FailureMask, 0);

	ASTEST_END_SHARE_CLEAN
	return true;
}

bool FAngelscriptBindingsCollisionResultAccessorsCompatTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		CollisionResultAccessorsModuleName,
		TEXT(R"AS(
bool MatchesVector(const FVector InValue, const float X, const float Y, const float Z)
{
	return InValue.X == X && InValue.Y == Y && InValue.Z == Z;
}

int PopulateCollisionResults(FHitResult& OutHit, FOverlapResult& OutOverlap, AActor ExpectedActor, UPrimitiveComponent ExpectedComponent)
{
	int MismatchMask = 0;

	OutHit = FHitResult(FVector(-1.0f, 0.0f, 0.0f), FVector(1.0f, 0.0f, 0.0f));
	OutHit.FaceIndex = 1;
	OutHit.ElementIndex = 2;
	OutHit.Item = 3;
	OutHit.MyItem = 4;
	OutHit.TraceStart = FVector(-2.0f, 1.0f, 0.0f);
	OutHit.TraceEnd = FVector(3.0f, 4.0f, 5.0f);
	OutHit.ImpactPoint = FVector(6.0f, 7.0f, 8.0f);
	OutHit.ImpactNormal = FVector(0.0f, 0.0f, 1.0f);
	OutHit.BoneName = n"Bone";
	OutHit.MyBoneName = n"MyBone";

	if (OutHit.FaceIndex != 1)
		MismatchMask |= 1;
	if (OutHit.ElementIndex != 2)
		MismatchMask |= 2;
	if (OutHit.Item != 3)
		MismatchMask |= 4;
	if (OutHit.MyItem != 4)
		MismatchMask |= 8;
	if (!MatchesVector(OutHit.TraceStart, -2.0f, 1.0f, 0.0f))
		MismatchMask |= 16;
	if (!MatchesVector(OutHit.TraceEnd, 3.0f, 4.0f, 5.0f))
		MismatchMask |= 32;
	if (!MatchesVector(OutHit.ImpactPoint, 6.0f, 7.0f, 8.0f))
		MismatchMask |= 64;
	if (!MatchesVector(OutHit.ImpactNormal, 0.0f, 0.0f, 1.0f))
		MismatchMask |= 128;
	if (OutHit.BoneName != n"Bone")
		MismatchMask |= 256;
	if (OutHit.MyBoneName != n"MyBone")
		MismatchMask |= 512;

	OutOverlap.ItemIndex = 9;
	OutOverlap.SetActor(ExpectedActor);
	OutOverlap.SetComponent(ExpectedComponent);
	OutOverlap.SetBlockingHit(true);

	if (OutOverlap.GetActor() != ExpectedActor)
		MismatchMask |= 1024;
	if (OutOverlap.GetComponent() != ExpectedComponent)
		MismatchMask |= 2048;
	if (!OutOverlap.GetbBlockingHit())
		MismatchMask |= 4096;
	if (OutOverlap.ItemIndex != 9)
		MismatchMask |= 8192;

	OutOverlap.SetBlockingHit(false);
	if (OutOverlap.GetbBlockingHit())
		MismatchMask |= 16384;

	return MismatchMask;
}
)AS"));
	if (Module == nullptr)
	{
		return false;
	}

	AActor* TestActor = NewObject<AActor>(GetTransientPackage(), NAME_None, RF_Transient);
	UBoxComponent* TestComponent = NewObject<UBoxComponent>(TestActor, NAME_None, RF_Transient);
	if (!TestNotNull(TEXT("CollisionResultAccessorsCompat should create a transient actor"), TestActor) ||
		!TestNotNull(TEXT("CollisionResultAccessorsCompat should create a transient primitive component"), TestComponent))
	{
		return false;
	}

	FHitResult ScriptHit(FVector::ZeroVector, FVector::ZeroVector);
	FOverlapResult ScriptOverlap;

	int32 ResultMask = INDEX_NONE;
	if (!ExecuteIntFunction(
		*this,
		Engine,
		*Module,
		TEXT("int PopulateCollisionResults(FHitResult&, FOverlapResult&, AActor, UPrimitiveComponent)"),
		[this, &ScriptHit, &ScriptOverlap, TestActor, TestComponent](asIScriptContext& Context)
		{
			return SetArgAddressChecked(*this, Context, 0, &ScriptHit, TEXT("PopulateCollisionResults"))
				&& SetArgAddressChecked(*this, Context, 1, &ScriptOverlap, TEXT("PopulateCollisionResults"))
				&& SetArgObjectChecked(*this, Context, 2, TestActor, TEXT("PopulateCollisionResults"))
				&& SetArgObjectChecked(*this, Context, 3, TestComponent, TEXT("PopulateCollisionResults"));
		},
		TEXT("PopulateCollisionResults"),
		ResultMask))
	{
		return false;
	}

	TestEqual(TEXT("CollisionResultAccessorsCompat should preserve script-side round-trip checks"), ResultMask, 0);
	TestEqual(TEXT("CollisionResultAccessorsCompat should write FaceIndex into native FHitResult state"), ScriptHit.FaceIndex, 1);
	TestEqual(TEXT("CollisionResultAccessorsCompat should write ElementIndex into native FHitResult state"), ScriptHit.ElementIndex, static_cast<uint8>(2));
	TestEqual(TEXT("CollisionResultAccessorsCompat should write Item into native FHitResult state"), ScriptHit.Item, 3);
	TestEqual(TEXT("CollisionResultAccessorsCompat should write MyItem into native FHitResult state"), ScriptHit.MyItem, 4);
	TestTrue(TEXT("CollisionResultAccessorsCompat should write TraceStart into native FHitResult state"), ScriptHit.TraceStart.Equals(FVector(-2.0f, 1.0f, 0.0f)));
	TestTrue(TEXT("CollisionResultAccessorsCompat should write TraceEnd into native FHitResult state"), ScriptHit.TraceEnd.Equals(FVector(3.0f, 4.0f, 5.0f)));
	TestTrue(TEXT("CollisionResultAccessorsCompat should write ImpactPoint into native FHitResult state"), ScriptHit.ImpactPoint.Equals(FVector(6.0f, 7.0f, 8.0f)));
	TestTrue(TEXT("CollisionResultAccessorsCompat should write ImpactNormal into native FHitResult state"), ScriptHit.ImpactNormal.Equals(FVector(0.0f, 0.0f, 1.0f)));
	TestEqual(TEXT("CollisionResultAccessorsCompat should write BoneName into native FHitResult state"), ScriptHit.BoneName, FName(TEXT("Bone")));
	TestEqual(TEXT("CollisionResultAccessorsCompat should write MyBoneName into native FHitResult state"), ScriptHit.MyBoneName, FName(TEXT("MyBone")));
	TestEqual(TEXT("CollisionResultAccessorsCompat should write ItemIndex into native FOverlapResult state"), ScriptOverlap.ItemIndex, 9);
	TestEqual(TEXT("CollisionResultAccessorsCompat should round-trip the actor handle through native FOverlapResult state"), ScriptOverlap.GetActor(), TestActor);
	TestEqual(TEXT("CollisionResultAccessorsCompat should round-trip the component handle through native FOverlapResult state"), ScriptOverlap.GetComponent(), static_cast<UPrimitiveComponent*>(TestComponent));
	TestFalse(TEXT("CollisionResultAccessorsCompat should leave bBlockingHit cleared after the final SetBlockingHit(false)"), ScriptOverlap.bBlockingHit);

	ASTEST_END_SHARE_CLEAN
	return true;
}

#endif
