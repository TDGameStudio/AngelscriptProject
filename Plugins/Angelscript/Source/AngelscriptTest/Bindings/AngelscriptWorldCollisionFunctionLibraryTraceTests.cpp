#include "../Shared/AngelscriptTestMacros.h"
#include "../Shared/AngelscriptTestUtilities.h"

#include "Components/ActorTestSpawner.h"
#include "Components/BoxComponent.h"
#include "Engine/CollisionProfile.h"
#include "Engine/OverlapResult.h"
#include "Engine/World.h"
#include "GameFramework/Actor.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Bindings_AngelscriptWorldCollisionFunctionLibraryTraceTests_Private
{
	static constexpr ANSICHAR ModuleName[] = "ASWorldCollisionFunctionLibraryTraceQueries";
	static const FVector BlockingTargetLocation(0.0f, 0.0f, 0.0f);
	static const FVector OverlapTargetLocation(0.0f, 150.0f, 0.0f);
	static const FVector LineTraceHitStart(-200.0f, 0.0f, 0.0f);
	static const FVector LineTraceHitEnd(200.0f, 0.0f, 0.0f);
	static const FVector LineTraceMissStart(-200.0f, -200.0f, 0.0f);
	static const FVector LineTraceMissEnd(200.0f, -200.0f, 0.0f);
	static const FVector TargetExtent(50.0f, 50.0f, 50.0f);
	static const FVector OverlapExtent(40.0f, 40.0f, 40.0f);
	static const FVector SweepExtent(30.0f, 30.0f, 30.0f);
	static const FVector OverlapShapeExtent(45.0f, 45.0f, 45.0f);
	static const FVector ProfileMissLocation(0.0f, -150.0f, 0.0f);
	static const FQuat IdentityRotation = FQuat::Identity;

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

	bool ExecuteBoolFunction(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		asIScriptModule& Module,
		const FString& FunctionDecl,
		TFunctionRef<bool(asIScriptContext&)> BindArguments,
		const TCHAR* ContextLabel,
		bool& OutResult)
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
		if (!Test.TestEqual(*FString::Printf(TEXT("%s should prepare successfully"), ContextLabel), PrepareResult, static_cast<int32>(asSUCCESS)))
		{
			return false;
		}

		if (!BindArguments(*Context))
		{
			return false;
		}

		const int ExecuteResult = Context->Execute();
		if (!Test.TestEqual(*FString::Printf(TEXT("%s should execute successfully"), ContextLabel), ExecuteResult, static_cast<int32>(asEXECUTION_FINISHED)))
		{
			return false;
		}

		OutResult = Context->GetReturnByte() != 0;
		return true;
	}

	template <typename TValue>
	bool ExecuteAddressBoolFunction(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		asIScriptModule& Module,
		const TCHAR* FunctionDecl,
		const TCHAR* ContextLabel,
		TValue& OutValue,
		bool& OutResult)
	{
		return ExecuteBoolFunction(
			Test,
			Engine,
			Module,
			FunctionDecl,
			[&](asIScriptContext& Context)
			{
				return SetArgAddressChecked(Test, Context, 0, &OutValue, ContextLabel);
			},
			ContextLabel,
			OutResult);
	}

	UBoxComponent* AddCollisionBox(AActor& Owner, FName ComponentName, const FVector& BoxExtent, const FVector& WorldLocation)
	{
		UBoxComponent* BoxComponent = NewObject<UBoxComponent>(&Owner, ComponentName);
		check(BoxComponent != nullptr);
		Owner.AddInstanceComponent(BoxComponent);
		Owner.SetRootComponent(BoxComponent);
		BoxComponent->RegisterComponent();
		BoxComponent->SetCollisionProfileName(UCollisionProfile::BlockAllDynamic_ProfileName);
		BoxComponent->SetGenerateOverlapEvents(true);
		BoxComponent->SetBoxExtent(BoxExtent);
		BoxComponent->SetWorldLocation(WorldLocation);
		return BoxComponent;
	}

	bool ExpectHitResultParity(FAutomationTestBase& Test, const TCHAR* Label, bool bScriptReturnValue, bool bNativeReturnValue, const FHitResult& ScriptHit, const FHitResult& NativeHit)
	{
		bool bPassed = true;
		bPassed &= Test.TestEqual(*FString::Printf(TEXT("%s should preserve the bool return value"), Label), bScriptReturnValue, bNativeReturnValue);
		bPassed &= Test.TestEqual(*FString::Printf(TEXT("%s should preserve the hit actor"), Label), ScriptHit.GetActor(), NativeHit.GetActor());
		bPassed &= Test.TestEqual(*FString::Printf(TEXT("%s should preserve the hit component"), Label), ScriptHit.GetComponent(), NativeHit.GetComponent());
		bPassed &= Test.TestEqual(*FString::Printf(TEXT("%s should preserve the blocking-hit flag"), Label), ScriptHit.bBlockingHit, NativeHit.bBlockingHit);
		bPassed &= Test.TestTrue(*FString::Printf(TEXT("%s should preserve the hit location"), Label), ScriptHit.Location.Equals(NativeHit.Location, 0.05f));
		bPassed &= Test.TestTrue(*FString::Printf(TEXT("%s should preserve the impact point"), Label), ScriptHit.ImpactPoint.Equals(NativeHit.ImpactPoint, 0.05f));
		return bPassed;
	}

	template <typename TResult>
	bool ExpectArrayParity(FAutomationTestBase& Test, const TCHAR* Label, bool bScriptReturnValue, bool bNativeReturnValue, const TArray<TResult>& ScriptResults, const TArray<TResult>& NativeResults)
	{
		bool bPassed = true;
		bPassed &= Test.TestEqual(*FString::Printf(TEXT("%s should preserve the bool return value"), Label), bScriptReturnValue, bNativeReturnValue);
		bPassed &= Test.TestEqual(*FString::Printf(TEXT("%s should preserve the result count"), Label), ScriptResults.Num(), NativeResults.Num());
		if (ScriptResults.Num() > 0 && NativeResults.Num() > 0)
		{
			bPassed &= Test.TestEqual(*FString::Printf(TEXT("%s should preserve the first result actor"), Label), ScriptResults[0].GetActor(), NativeResults[0].GetActor());
			bPassed &= Test.TestEqual(*FString::Printf(TEXT("%s should preserve the first result component"), Label), ScriptResults[0].GetComponent(), NativeResults[0].GetComponent());
		}
		return bPassed;
	}

	bool OverlapsContainComponent(const TArray<FOverlapResult>& Overlaps, const UPrimitiveComponent* Component)
	{
		return Overlaps.ContainsByPredicate([Component](const FOverlapResult& Overlap)
		{
			return Overlap.GetComponent() == Component;
		});
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptWorldCollisionFunctionLibraryTraceTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptWorldCollisionFunctionLibraryTraceQueriesTest,
	"Angelscript.TestModule.FunctionLibraries.WorldCollisionSyncQueries.TraceAndOverlap",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptWorldCollisionFunctionLibraryTraceQueriesTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_FULL();
	ASTEST_BEGIN_FULL

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		ModuleName,
		TEXT(R"(
bool RunLineTraceSingleByChannelHit(FHitResult& OutHit)
{
	return System::LineTraceSingleByChannel(OutHit, FVector(-200.0f, 0.0f, 0.0f), FVector(200.0f, 0.0f, 0.0f), ECollisionChannel::ECC_Visibility);
}

bool RunLineTraceMultiByChannelHit(TArray<FHitResult>& OutHits)
{
	return System::LineTraceMultiByChannel(OutHits, FVector(-200.0f, 0.0f, 0.0f), FVector(200.0f, 0.0f, 0.0f), ECollisionChannel::ECC_Visibility);
}

bool RunLineTraceMultiByChannelMiss(TArray<FHitResult>& OutHits)
{
	return System::LineTraceMultiByChannel(OutHits, FVector(-200.0f, -200.0f, 0.0f), FVector(200.0f, -200.0f, 0.0f), ECollisionChannel::ECC_Visibility);
}

bool RunSweepSingleByObjectTypeHit(FHitResult& OutHit)
{
	FCollisionObjectQueryParams ObjectQueryParams;
	ObjectQueryParams.AddObjectTypesToQuery(ECollisionChannel::ECC_WorldDynamic);
	const FCollisionShape Shape = FCollisionShape::MakeBox(FVector(30.0f, 30.0f, 30.0f));
	return System::SweepSingleByObjectType(OutHit, FVector(-200.0f, 0.0f, 0.0f), FVector(200.0f, 0.0f, 0.0f), FQuat::Identity, ObjectQueryParams, Shape);
}

bool RunOverlapMultiByProfileHit(TArray<FOverlapResult>& OutOverlaps)
{
	const FCollisionShape Shape = FCollisionShape::MakeBox(FVector(45.0f, 45.0f, 45.0f));
	return System::OverlapMultiByProfile(OutOverlaps, FVector(0.0f, 150.0f, 0.0f), FQuat::Identity, CollisionProfile::BlockAllDynamic, Shape);
}

bool RunOverlapMultiByProfileMiss(TArray<FOverlapResult>& OutOverlaps)
{
	const FCollisionShape Shape = FCollisionShape::MakeBox(FVector(45.0f, 45.0f, 45.0f));
	return System::OverlapMultiByProfile(OutOverlaps, FVector(0.0f, -150.0f, 0.0f), FQuat::Identity, CollisionProfile::BlockAllDynamic, Shape);
}
)"));
	if (Module == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AActor& BlockingActor = Spawner.SpawnActor<AActor>();
	UBoxComponent* BlockingBox = AddCollisionBox(BlockingActor, TEXT("BlockingTarget"), TargetExtent, BlockingTargetLocation);
	AActor& OverlapActor = Spawner.SpawnActor<AActor>();
	UBoxComponent* OverlapBox = AddCollisionBox(OverlapActor, TEXT("OverlapTarget"), OverlapExtent, OverlapTargetLocation);
	if (!TestNotNull(TEXT("World collision trace blocker should be created"), BlockingBox)
		|| !TestNotNull(TEXT("World collision trace overlap target should be created"), OverlapBox))
	{
		return false;
	}

	UWorld* World = BlockingActor.GetWorld();
	if (!TestNotNull(TEXT("World collision trace test should access the spawned world"), World))
	{
		return false;
	}

	FScopedTestWorldContextScope WorldContextScope(&BlockingActor);

	const FCollisionShape SweepShape = FCollisionShape::MakeBox(SweepExtent);
	const FCollisionShape ProfileOverlapShape = FCollisionShape::MakeBox(OverlapShapeExtent);
	FCollisionObjectQueryParams ObjectQueryParams;
	ObjectQueryParams.AddObjectTypesToQuery(ECC_WorldDynamic);

	FHitResult NativeLineHit;
	const bool bNativeLineHit = World->LineTraceSingleByChannel(NativeLineHit, LineTraceHitStart, LineTraceHitEnd, ECC_Visibility);
	FHitResult ScriptLineHit;
	bool bScriptLineHit = false;
	if (!ExecuteAddressBoolFunction(*this, Engine, *Module, TEXT("bool RunLineTraceSingleByChannelHit(FHitResult& OutHit)"), TEXT("RunLineTraceSingleByChannelHit"), ScriptLineHit, bScriptLineHit))
	{
		return false;
	}
	bPassed &= ExpectHitResultParity(*this, TEXT("LineTraceSingleByChannel hit"), bScriptLineHit, bNativeLineHit, ScriptLineHit, NativeLineHit);
	bPassed &= TestEqual(TEXT("LineTraceSingleByChannel hit should identify the blocker actor"), ScriptLineHit.GetActor(), &BlockingActor);
	bPassed &= TestEqual(TEXT("LineTraceSingleByChannel hit should identify the blocker component"), ScriptLineHit.GetComponent(), static_cast<UPrimitiveComponent*>(BlockingBox));

	TArray<FHitResult> NativeLineHits;
	const bool bNativeLineMultiHit = World->LineTraceMultiByChannel(NativeLineHits, LineTraceHitStart, LineTraceHitEnd, ECC_Visibility);
	TArray<FHitResult> ScriptLineHits;
	bool bScriptLineMultiHit = false;
	if (!ExecuteAddressBoolFunction(*this, Engine, *Module, TEXT("bool RunLineTraceMultiByChannelHit(TArray<FHitResult>& OutHits)"), TEXT("RunLineTraceMultiByChannelHit"), ScriptLineHits, bScriptLineMultiHit))
	{
		return false;
	}
	bPassed &= ExpectArrayParity(*this, TEXT("LineTraceMultiByChannel hit"), bScriptLineMultiHit, bNativeLineMultiHit, ScriptLineHits, NativeLineHits);
	bPassed &= TestTrue(TEXT("LineTraceMultiByChannel hit should produce at least one hit"), ScriptLineHits.Num() >= 1);

	TArray<FHitResult> NativeLineMissHits;
	NativeLineMissHits.AddDefaulted();
	const bool bNativeLineMultiMiss = World->LineTraceMultiByChannel(NativeLineMissHits, LineTraceMissStart, LineTraceMissEnd, ECC_Visibility);
	TArray<FHitResult> ScriptLineMissHits;
	ScriptLineMissHits.AddDefaulted();
	bool bScriptLineMultiMiss = false;
	if (!ExecuteAddressBoolFunction(*this, Engine, *Module, TEXT("bool RunLineTraceMultiByChannelMiss(TArray<FHitResult>& OutHits)"), TEXT("RunLineTraceMultiByChannelMiss"), ScriptLineMissHits, bScriptLineMultiMiss))
	{
		return false;
	}
	bPassed &= ExpectArrayParity(*this, TEXT("LineTraceMultiByChannel miss"), bScriptLineMultiMiss, bNativeLineMultiMiss, ScriptLineMissHits, NativeLineMissHits);
	bPassed &= TestEqual(TEXT("LineTraceMultiByChannel miss should clear stale output hits"), ScriptLineMissHits.Num(), 0);

	FHitResult NativeObjectSweepHit;
	const bool bNativeObjectSweepHit = World->SweepSingleByObjectType(NativeObjectSweepHit, LineTraceHitStart, LineTraceHitEnd, IdentityRotation, ObjectQueryParams, SweepShape);
	FHitResult ScriptObjectSweepHit;
	bool bScriptObjectSweepHit = false;
	if (!ExecuteAddressBoolFunction(*this, Engine, *Module, TEXT("bool RunSweepSingleByObjectTypeHit(FHitResult& OutHit)"), TEXT("RunSweepSingleByObjectTypeHit"), ScriptObjectSweepHit, bScriptObjectSweepHit))
	{
		return false;
	}
	bPassed &= ExpectHitResultParity(*this, TEXT("SweepSingleByObjectType hit"), bScriptObjectSweepHit, bNativeObjectSweepHit, ScriptObjectSweepHit, NativeObjectSweepHit);
	bPassed &= TestEqual(TEXT("SweepSingleByObjectType hit should identify the blocker actor"), ScriptObjectSweepHit.GetActor(), &BlockingActor);
	bPassed &= TestEqual(TEXT("SweepSingleByObjectType hit should identify the blocker component"), ScriptObjectSweepHit.GetComponent(), static_cast<UPrimitiveComponent*>(BlockingBox));

	TArray<FOverlapResult> NativeProfileOverlaps;
	const bool bNativeProfileOverlapHit = World->OverlapMultiByProfile(NativeProfileOverlaps, OverlapTargetLocation, IdentityRotation, UCollisionProfile::BlockAllDynamic_ProfileName, ProfileOverlapShape);
	TArray<FOverlapResult> ScriptProfileOverlaps;
	bool bScriptProfileOverlapHit = false;
	if (!ExecuteAddressBoolFunction(*this, Engine, *Module, TEXT("bool RunOverlapMultiByProfileHit(TArray<FOverlapResult>& OutOverlaps)"), TEXT("RunOverlapMultiByProfileHit"), ScriptProfileOverlaps, bScriptProfileOverlapHit))
	{
		return false;
	}
	bPassed &= ExpectArrayParity(*this, TEXT("OverlapMultiByProfile hit"), bScriptProfileOverlapHit, bNativeProfileOverlapHit, ScriptProfileOverlaps, NativeProfileOverlaps);
	bPassed &= TestTrue(TEXT("OverlapMultiByProfile hit should include the overlap target component"), OverlapsContainComponent(ScriptProfileOverlaps, OverlapBox));

	TArray<FOverlapResult> NativeProfileMissOverlaps;
	NativeProfileMissOverlaps.AddDefaulted();
	const bool bNativeProfileOverlapMiss = World->OverlapMultiByProfile(NativeProfileMissOverlaps, ProfileMissLocation, IdentityRotation, UCollisionProfile::BlockAllDynamic_ProfileName, ProfileOverlapShape);
	TArray<FOverlapResult> ScriptProfileMissOverlaps;
	ScriptProfileMissOverlaps.AddDefaulted();
	bool bScriptProfileOverlapMiss = false;
	if (!ExecuteAddressBoolFunction(*this, Engine, *Module, TEXT("bool RunOverlapMultiByProfileMiss(TArray<FOverlapResult>& OutOverlaps)"), TEXT("RunOverlapMultiByProfileMiss"), ScriptProfileMissOverlaps, bScriptProfileOverlapMiss))
	{
		return false;
	}
	bPassed &= ExpectArrayParity(*this, TEXT("OverlapMultiByProfile miss"), bScriptProfileOverlapMiss, bNativeProfileOverlapMiss, ScriptProfileMissOverlaps, NativeProfileMissOverlaps);

	ASTEST_END_FULL
	return bPassed;
}

#endif
