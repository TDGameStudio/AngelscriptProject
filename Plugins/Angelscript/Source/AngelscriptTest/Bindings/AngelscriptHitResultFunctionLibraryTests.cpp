#include "../Shared/AngelscriptTestMacros.h"
#include "../Shared/AngelscriptTestUtilities.h"

#include "Components/ActorTestSpawner.h"
#include "Components/BoxComponent.h"
#include "Engine/World.h"
#include "GameFramework/Actor.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "Templates/Function.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Bindings_AngelscriptHitResultFunctionLibraryTests_Private
{
	static constexpr ANSICHAR HitResultAccessorsModuleName[] = "ASHitResultAccessorRoundTrip";

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

	UBoxComponent* AddHitResultTestComponent(AActor& Owner, const FName ComponentName)
	{
		UBoxComponent* BoxComponent = NewObject<UBoxComponent>(&Owner, ComponentName);
		check(BoxComponent != nullptr);

		Owner.AddInstanceComponent(BoxComponent);
		Owner.SetRootComponent(BoxComponent);
		BoxComponent->RegisterComponent();
		BoxComponent->SetCollisionEnabled(ECollisionEnabled::NoCollision);
		BoxComponent->SetBoxExtent(FVector(20.0f, 20.0f, 20.0f));
		BoxComponent->SetWorldLocation(FVector(25.0f, 0.0f, 0.0f));
		return BoxComponent;
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptHitResultFunctionLibraryTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptHitResultFunctionLibraryAccessorsTest,
	"Angelscript.TestModule.FunctionLibraries.HitResultAccessors",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptHitResultFunctionLibraryAccessorsTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_FULL();
	ASTEST_BEGIN_FULL

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		HitResultAccessorsModuleName,
		TEXT(R"(
int PopulateHitResult(FHitResult& OutHit, AActor ExpectedActor, UPrimitiveComponent ExpectedComponent)
{
	int MismatchMask = 0;

	if (OutHit.GetbBlockingHit())
		MismatchMask |= 1;
	if (OutHit.GetbStartPenetrating())
		MismatchMask |= 2;

	OutHit.SetActor(ExpectedActor);
	AActor RetrievedActor = OutHit.GetActor();
	if (!IsValid(RetrievedActor))
		MismatchMask |= 4;

	OutHit.SetComponent(ExpectedComponent);
	AActor RetrievedActorAfterComponent = OutHit.GetActor();
	if (!IsValid(RetrievedActorAfterComponent))
		MismatchMask |= 8;

	UPrimitiveComponent RetrievedComponent = OutHit.GetComponent();
	if (!IsValid(RetrievedComponent))
		MismatchMask |= 16;

	OutHit.SetBlockingHit(true);
	if (!OutHit.GetbBlockingHit())
		MismatchMask |= 32;

	OutHit.SetbBlockingHit(false);
	if (OutHit.GetbBlockingHit())
		MismatchMask |= 64;

	OutHit.SetbStartPenetrating(true);
	if (!OutHit.GetbStartPenetrating())
		MismatchMask |= 128;

	return MismatchMask;
}

int ResetHitResult(FHitResult& Hit)
{
	int MismatchMask = 0;

	Hit.Reset();
	if (Hit.GetbBlockingHit())
		MismatchMask |= 1;
	if (Hit.GetbStartPenetrating())
		MismatchMask |= 2;

	return MismatchMask;
}
)"));
	if (Module == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AActor& TestActor = Spawner.SpawnActor<AActor>();
	UBoxComponent* TestComponent = AddHitResultTestComponent(TestActor, TEXT("HitResultTestComponent"));
	if (!TestNotNull(TEXT("HitResult accessor test should create a primitive component"), TestComponent))
	{
		return false;
	}

	if (!TestEqual(
		TEXT("HitResult accessor test component should belong to the spawned actor"),
		TestComponent->GetOwner(),
		&TestActor))
	{
		return false;
	}

	UWorld* TestWorld = TestActor.GetWorld();
	if (!TestNotNull(TEXT("HitResult accessor test should access the spawned world"), TestWorld))
	{
		return false;
	}

	FScopedTestWorldContextScope WorldContextScope(&TestActor);

	FHitResult ScriptHit(FVector::ZeroVector, FVector::ForwardVector);
	bPassed &= TestNull(TEXT("HitResult accessor test should start with no actor handle"), ScriptHit.GetActor());
	bPassed &= TestNull(TEXT("HitResult accessor test should start with no component handle"), ScriptHit.GetComponent());
	bPassed &= TestFalse(TEXT("HitResult accessor test should start with bBlockingHit cleared"), ScriptHit.bBlockingHit);
	bPassed &= TestFalse(TEXT("HitResult accessor test should start with bStartPenetrating cleared"), ScriptHit.bStartPenetrating);

	int32 PopulateResultMask = INDEX_NONE;
	if (!ExecuteIntFunction(
		*this,
		Engine,
		*Module,
		TEXT("int PopulateHitResult(FHitResult&, AActor, UPrimitiveComponent)"),
		[this, &ScriptHit, &TestActor, TestComponent](asIScriptContext& Context)
		{
			return SetArgAddressChecked(*this, Context, 0, &ScriptHit, TEXT("PopulateHitResult"))
				&& SetArgObjectChecked(*this, Context, 1, &TestActor, TEXT("PopulateHitResult"))
				&& SetArgObjectChecked(*this, Context, 2, TestComponent, TEXT("PopulateHitResult"));
		},
		TEXT("PopulateHitResult"),
		PopulateResultMask))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("FHitResult function library accessors should allow script-side helper calls without flag mismatches"),
		PopulateResultMask,
		0);
	bPassed &= TestEqual(TEXT("HitResult accessor test should round-trip the actor handle back into native state"), ScriptHit.GetActor(), &TestActor);
	bPassed &= TestEqual(
		TEXT("HitResult accessor test should round-trip the component handle back into native state"),
		ScriptHit.GetComponent(),
		static_cast<UPrimitiveComponent*>(TestComponent));
	bPassed &= TestFalse(TEXT("HitResult accessor test should leave bBlockingHit cleared after SetbBlockingHit(false)"), ScriptHit.bBlockingHit);
	bPassed &= TestTrue(TEXT("HitResult accessor test should preserve the start penetrating flag set by script"), ScriptHit.bStartPenetrating);

	int32 ResetResultMask = INDEX_NONE;
	if (!ExecuteIntFunction(
		*this,
		Engine,
		*Module,
		TEXT("int ResetHitResult(FHitResult&)"),
		[this, &ScriptHit](asIScriptContext& Context)
		{
			return SetArgAddressChecked(*this, Context, 0, &ScriptHit, TEXT("ResetHitResult"));
		},
		TEXT("ResetHitResult"),
		ResetResultMask))
	{
		return false;
	}

	bPassed &= TestEqual(
		TEXT("FHitResult function library Reset helper should clear script-visible blocking and penetration flags"),
		ResetResultMask,
		0);
	bPassed &= TestNull(TEXT("HitResult accessor test should clear the actor handle after Reset"), ScriptHit.GetActor());
	bPassed &= TestNull(TEXT("HitResult accessor test should clear the component handle after Reset"), ScriptHit.GetComponent());
	bPassed &= TestFalse(TEXT("HitResult accessor test should clear bBlockingHit after Reset"), ScriptHit.bBlockingHit);
	bPassed &= TestFalse(TEXT("HitResult accessor test should clear bStartPenetrating after Reset"), ScriptHit.bStartPenetrating);

	ASTEST_END_FULL
	return bPassed;
}

#endif
