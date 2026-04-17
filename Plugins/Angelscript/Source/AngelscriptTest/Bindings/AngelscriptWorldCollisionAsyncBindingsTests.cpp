#include "../Shared/AngelscriptScenarioTestUtils.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Components/ActorTestSpawner.h"
#include "Components/BoxComponent.h"
#include "Engine/OverlapResult.h"
#include "Engine/World.h"
#include "GameFramework/Actor.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Bindings_AngelscriptWorldCollisionAsyncBindingsTests_Private
{
	using namespace AngelscriptScenarioTestUtils;

	static const FName WorldCollisionAsyncModuleName(TEXT("ASWorldCollisionAsyncTraceCallbacks"));
	static const FString WorldCollisionAsyncFilename(TEXT("WorldCollisionAsyncTraceCallbacks.as"));
	static const FName WorldCollisionAsyncClassName(TEXT("AScenarioWorldCollisionAsyncCallbacks"));
	static const FVector AsyncCollisionTargetLocation(0.0f, 0.0f, 0.0f);
	static const FVector AsyncLineTraceStart(-200.0f, 0.0f, 0.0f);
	static const FVector AsyncLineTraceEnd(200.0f, 0.0f, 0.0f);
	static const FVector AsyncTargetExtent(50.0f, 50.0f, 50.0f);
	static const FVector AsyncQueryExtent(30.0f, 30.0f, 30.0f);
	static constexpr float AsyncTickDeltaTime = 1.0f / 60.0f;
	static constexpr int32 AsyncMaxTickCount = 90;

	UBoxComponent* AddCollisionBox(
		AActor& Owner,
		const FName ComponentName,
		const FVector& BoxExtent,
		const FVector& WorldLocation)
	{
		UBoxComponent* BoxComponent = NewObject<UBoxComponent>(&Owner, ComponentName);
		check(BoxComponent != nullptr);

		Owner.AddInstanceComponent(BoxComponent);
		Owner.SetRootComponent(BoxComponent);
		BoxComponent->RegisterComponent();
		BoxComponent->SetCollisionEnabled(ECollisionEnabled::QueryOnly);
		BoxComponent->SetCollisionObjectType(ECC_WorldDynamic);
		BoxComponent->SetCollisionResponseToAllChannels(ECR_Block);
		BoxComponent->SetGenerateOverlapEvents(true);
		BoxComponent->SetBoxExtent(BoxExtent);
		BoxComponent->SetWorldLocation(WorldLocation);
		return BoxComponent;
	}

	bool ExecuteGeneratedIntMethod(
		FAutomationTestBase& Test,
		UObject* Object,
		UClass* OwnerClass,
		FName FunctionName,
		int32& OutResult)
	{
		UFunction* Function = FindGeneratedFunction(OwnerClass, FunctionName);
		if (!Test.TestNotNull(
			*FString::Printf(TEXT("World collision async method '%s' should exist"), *FunctionName.ToString()),
			Function))
		{
			return false;
		}

		return Test.TestTrue(
			*FString::Printf(TEXT("World collision async method '%s' should execute"), *FunctionName.ToString()),
			ExecuteGeneratedIntEventOnGameThread(Object, Function, OutResult));
	}

	bool ReadIntPropertyChecked(
		FAutomationTestBase& Test,
		UObject* Object,
		FName PropertyName,
		int32& OutValue)
	{
		return ReadPropertyValue<FIntProperty>(Test, Object, PropertyName, OutValue);
	}

	bool ReadUInt64PropertyChecked(
		FAutomationTestBase& Test,
		UObject* Object,
		FName PropertyName,
		uint64& OutValue)
	{
		if (!Test.TestNotNull(TEXT("World collision async object should be valid for uint64 property reads"), Object))
		{
			return false;
		}

		FUInt64Property* Property = FindFProperty<FUInt64Property>(Object->GetClass(), PropertyName);
		if (!Test.TestNotNull(
			*FString::Printf(TEXT("World collision async property '%s' should exist"), *PropertyName.ToString()),
			Property))
		{
			return false;
		}

		OutValue = Property->GetPropertyValue_InContainer(Object);
		return true;
	}

	bool WaitForAsyncCallbacks(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		UWorld& World,
		AActor& ScriptActor)
	{
		FIntProperty* LineCallbackCountProperty = FindFProperty<FIntProperty>(ScriptActor.GetClass(), TEXT("LineCallbackCount"));
		FIntProperty* OverlapCallbackCountProperty = FindFProperty<FIntProperty>(ScriptActor.GetClass(), TEXT("OverlapCallbackCount"));
		if (!Test.TestNotNull(TEXT("World collision async actor should expose LineCallbackCount"), LineCallbackCountProperty)
			|| !Test.TestNotNull(TEXT("World collision async actor should expose OverlapCallbackCount"), OverlapCallbackCountProperty))
		{
			return false;
		}

		for (int32 TickIndex = 0; TickIndex < AsyncMaxTickCount; ++TickIndex)
		{
			const int32 LineCallbackCount = LineCallbackCountProperty->GetPropertyValue_InContainer(&ScriptActor);
			const int32 OverlapCallbackCount = OverlapCallbackCountProperty->GetPropertyValue_InContainer(&ScriptActor);
			if (LineCallbackCount >= 1 && OverlapCallbackCount >= 1)
			{
				return true;
			}

			TickWorld(Engine, World, AsyncTickDeltaTime, 1);
		}

		const int32 FinalLineCallbackCount = LineCallbackCountProperty->GetPropertyValue_InContainer(&ScriptActor);
		const int32 FinalOverlapCallbackCount = OverlapCallbackCountProperty->GetPropertyValue_InContainer(&ScriptActor);
		Test.AddError(FString::Printf(
			TEXT("Async world-collision callbacks did not complete within %d ticks (line=%d overlap=%d)."),
			AsyncMaxTickCount,
			FinalLineCallbackCount,
			FinalOverlapCallbackCount));
		return false;
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptWorldCollisionAsyncBindingsTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptWorldCollisionAsyncTraceCallbacksBindingsTest,
	"Angelscript.TestModule.Bindings.WorldCollision.AsyncTraceCallbacks",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptWorldCollisionAsyncTraceCallbacksBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_FULL();
	ASTEST_BEGIN_FULL
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*WorldCollisionAsyncModuleName.ToString());
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		WorldCollisionAsyncModuleName,
		WorldCollisionAsyncFilename,
		TEXT(R"AS(
UCLASS()
class AScenarioWorldCollisionAsyncCallbacks : AActor
{
	UPROPERTY()
	int LineCallbackCount = 0;
	UPROPERTY()
	int LineUserData = 0;
	UPROPERTY()
	int LineHitCount = 0;
	UPROPERTY()
	int LineQuerySucceeded = 0;
	UPROPERTY()
	int LineQueryHitCount = 0;
	UPROPERTY()
	int LineHandleValidInitially = 0;
	UPROPERTY()
	uint64 LineHandleRaw = 0;
	UPROPERTY()
	uint64 LastLineCallbackHandle = 0;

	UPROPERTY()
	int OverlapCallbackCount = 0;
	UPROPERTY()
	int OverlapUserData = 0;
	UPROPERTY()
	int OverlapHitCount = 0;
	UPROPERTY()
	int OverlapQuerySucceeded = 0;
	UPROPERTY()
	int OverlapQueryHitCount = 0;
	UPROPERTY()
	int OverlapHandleValidInitially = 0;
	UPROPERTY()
	uint64 OverlapHandleRaw = 0;
	UPROPERTY()
	uint64 LastOverlapCallbackHandle = 0;

	FTraceHandle LineHandle;
	FTraceHandle OverlapHandle;

	UFUNCTION()
	int StartAsyncQueries()
	{
		FScriptTraceDelegate LineDelegate;
		LineDelegate.BindUFunction(this, n"HandleLineTrace");
		LineHandle = System::AsyncLineTraceByChannel(
			EAsyncTraceType::Single,
			FVector(-200.0f, 0.0f, 0.0f),
			FVector(200.0f, 0.0f, 0.0f),
			ECollisionChannel::ECC_Visibility,
			FCollisionQueryParams::DefaultQueryParam,
			FCollisionResponseParams::DefaultResponseParam,
			LineDelegate,
			77);
		LineHandleRaw = LineHandle._Handle;
		LineHandleValidInitially = System::IsTraceHandleValid(LineHandle, false) ? 1 : 0;

		FCollisionShape Shape = FCollisionShape::MakeBox(FVector(30.0f, 30.0f, 30.0f));
		FScriptOverlapDelegate OverlapDelegate;
		OverlapDelegate.BindUFunction(this, n"HandleOverlapTrace");
		OverlapHandle = System::AsyncOverlapByChannel(
			FVector::ZeroVector,
			FQuat::Identity,
			ECollisionChannel::ECC_Visibility,
			Shape,
			FCollisionQueryParams::DefaultQueryParam,
			FCollisionResponseParams::DefaultResponseParam,
			OverlapDelegate,
			88);
		OverlapHandleRaw = OverlapHandle._Handle;
		OverlapHandleValidInitially = System::IsTraceHandleValid(OverlapHandle, true) ? 1 : 0;
		return 1;
	}

	UFUNCTION()
	void HandleLineTrace(uint64 TraceHandleValue, const TArray<FHitResult>& OutHits, uint32 UserData)
	{
		LineCallbackCount += 1;
		LastLineCallbackHandle = TraceHandleValue;
		LineUserData = int(UserData);
		LineHitCount = OutHits.Num();

		FTraceDatum Datum;
		LineQuerySucceeded = System::QueryTraceData(LineHandle, Datum) ? 1 : 0;
		LineQueryHitCount = Datum.OutHits.Num();
	}

	UFUNCTION()
	void HandleOverlapTrace(uint64 TraceHandleValue, const TArray<FOverlapResult>& OutOverlaps, uint32 UserData)
	{
		OverlapCallbackCount += 1;
		LastOverlapCallbackHandle = TraceHandleValue;
		OverlapUserData = int(UserData);
		OverlapHitCount = OutOverlaps.Num();

		FOverlapDatum Datum;
		OverlapQuerySucceeded = System::QueryOverlapData(OverlapHandle, Datum) ? 1 : 0;
		OverlapQueryHitCount = Datum.OutOverlaps.Num();
	}

	UFUNCTION()
	int GetLineHandleValidNow()
	{
		return System::IsTraceHandleValid(LineHandle, false) ? 1 : 0;
	}

	UFUNCTION()
	int GetOverlapHandleValidNow()
	{
		return System::IsTraceHandleValid(OverlapHandle, true) ? 1 : 0;
	}
}
)AS"),
		WorldCollisionAsyncClassName);
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AActor& TargetActor = Spawner.SpawnActor<AActor>();
	UBoxComponent* TargetBox = AddCollisionBox(TargetActor, TEXT("AsyncCollisionTarget"), AsyncTargetExtent, AsyncCollisionTargetLocation);
	if (!TestNotNull(TEXT("World collision async target box should be created"), TargetBox))
	{
		return false;
	}

	AActor* ScriptActor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("World collision async script actor should spawn"), ScriptActor))
	{
		return false;
	}

	BeginPlayActor(Engine, *ScriptActor);

	UWorld* World = TargetActor.GetWorld();
	if (!TestNotNull(TEXT("World collision async test should access the spawned test world"), World))
	{
		return false;
	}

	int32 StartResult = 0;
	if (!ExecuteGeneratedIntMethod(*this, ScriptActor, ScriptClass, TEXT("StartAsyncQueries"), StartResult))
	{
		return false;
	}
	TestEqual(TEXT("Async world collision start method should acknowledge launch"), StartResult, 1);

	if (!WaitForAsyncCallbacks(*this, Engine, *World, *ScriptActor))
	{
		return false;
	}

	int32 LineCallbackCount = 0;
	int32 LineUserData = 0;
	int32 LineHitCount = 0;
	int32 LineQuerySucceeded = 0;
	int32 LineQueryHitCount = 0;
	int32 LineHandleValidInitially = 0;
	int32 OverlapCallbackCount = 0;
	int32 OverlapUserData = 0;
	int32 OverlapHitCount = 0;
	int32 OverlapQuerySucceeded = 0;
	int32 OverlapQueryHitCount = 0;
	int32 OverlapHandleValidInitially = 0;
	uint64 LineHandleRaw = 0;
	uint64 LastLineCallbackHandle = 0;
	uint64 OverlapHandleRaw = 0;
	uint64 LastOverlapCallbackHandle = 0;
	if (!ReadIntPropertyChecked(*this, ScriptActor, TEXT("LineCallbackCount"), LineCallbackCount)
		|| !ReadIntPropertyChecked(*this, ScriptActor, TEXT("LineUserData"), LineUserData)
		|| !ReadIntPropertyChecked(*this, ScriptActor, TEXT("LineHitCount"), LineHitCount)
		|| !ReadIntPropertyChecked(*this, ScriptActor, TEXT("LineQuerySucceeded"), LineQuerySucceeded)
		|| !ReadIntPropertyChecked(*this, ScriptActor, TEXT("LineQueryHitCount"), LineQueryHitCount)
		|| !ReadIntPropertyChecked(*this, ScriptActor, TEXT("LineHandleValidInitially"), LineHandleValidInitially)
		|| !ReadIntPropertyChecked(*this, ScriptActor, TEXT("OverlapCallbackCount"), OverlapCallbackCount)
		|| !ReadIntPropertyChecked(*this, ScriptActor, TEXT("OverlapUserData"), OverlapUserData)
		|| !ReadIntPropertyChecked(*this, ScriptActor, TEXT("OverlapHitCount"), OverlapHitCount)
		|| !ReadIntPropertyChecked(*this, ScriptActor, TEXT("OverlapQuerySucceeded"), OverlapQuerySucceeded)
		|| !ReadIntPropertyChecked(*this, ScriptActor, TEXT("OverlapQueryHitCount"), OverlapQueryHitCount)
		|| !ReadIntPropertyChecked(*this, ScriptActor, TEXT("OverlapHandleValidInitially"), OverlapHandleValidInitially)
		|| !ReadUInt64PropertyChecked(*this, ScriptActor, TEXT("LineHandleRaw"), LineHandleRaw)
		|| !ReadUInt64PropertyChecked(*this, ScriptActor, TEXT("LastLineCallbackHandle"), LastLineCallbackHandle)
		|| !ReadUInt64PropertyChecked(*this, ScriptActor, TEXT("OverlapHandleRaw"), OverlapHandleRaw)
		|| !ReadUInt64PropertyChecked(*this, ScriptActor, TEXT("LastOverlapCallbackHandle"), LastOverlapCallbackHandle))
	{
		return false;
	}

	TestEqual(TEXT("Async line trace should invoke its callback exactly once"), LineCallbackCount, 1);
	TestEqual(TEXT("Async overlap should invoke its callback exactly once"), OverlapCallbackCount, 1);
	TestEqual(TEXT("Async line trace should preserve UserData through the delegate bridge"), LineUserData, 77);
	TestEqual(TEXT("Async overlap should preserve UserData through the delegate bridge"), OverlapUserData, 88);
	TestTrue(TEXT("Async line trace should report at least one hit to the callback"), LineHitCount > 0);
	TestTrue(TEXT("Async overlap should report at least one overlap to the callback"), OverlapHitCount > 0);
	TestEqual(TEXT("Async line trace should return an initially valid trace handle"), LineHandleValidInitially, 1);
	TestEqual(TEXT("Async overlap should return an initially valid trace handle"), OverlapHandleValidInitially, 1);
	TestEqual(TEXT("Async line trace callback should observe the same handle that StartAsyncQueries stored"), LastLineCallbackHandle, LineHandleRaw);
	TestEqual(TEXT("Async overlap callback should observe the same handle that StartAsyncQueries stored"), LastOverlapCallbackHandle, OverlapHandleRaw);
	TestEqual(TEXT("Async line trace callback should report successful QueryTraceData"), LineQuerySucceeded, 1);
	TestEqual(TEXT("Async overlap callback should report successful QueryOverlapData"), OverlapQuerySucceeded, 1);
	TestTrue(TEXT("Async line trace callback should observe non-empty queried hit data"), LineQueryHitCount > 0);
	TestTrue(TEXT("Async overlap callback should observe non-empty queried overlap data"), OverlapQueryHitCount > 0);
	TestEqual(TEXT("Async line trace query hit count should match the callback payload"), LineQueryHitCount, LineHitCount);
	TestEqual(TEXT("Async overlap query hit count should match the callback payload"), OverlapQueryHitCount, OverlapHitCount);

	FTraceHandle NativeLineHandle;
	NativeLineHandle._Handle = LineHandleRaw;
	FTraceHandle NativeOverlapHandle;
	NativeOverlapHandle._Handle = OverlapHandleRaw;

	int32 ScriptLineHandleValidNow = 0;
	int32 ScriptOverlapHandleValidNow = 0;
	if (!ExecuteGeneratedIntMethod(*this, ScriptActor, ScriptClass, TEXT("GetLineHandleValidNow"), ScriptLineHandleValidNow)
		|| !ExecuteGeneratedIntMethod(*this, ScriptActor, ScriptClass, TEXT("GetOverlapHandleValidNow"), ScriptOverlapHandleValidNow))
	{
		return false;
	}

	const bool bNativeLineHandleValidNow = World->IsTraceHandleValid(NativeLineHandle, false);
	const bool bNativeOverlapHandleValidNow = World->IsTraceHandleValid(NativeOverlapHandle, true);
	TestEqual(TEXT("Script line handle validity should match native world semantics after completion"), ScriptLineHandleValidNow, bNativeLineHandleValidNow ? 1 : 0);
	TestEqual(TEXT("Script overlap handle validity should match native world semantics after completion"), ScriptOverlapHandleValidNow, bNativeOverlapHandleValidNow ? 1 : 0);

	ASTEST_END_FULL
	return true;
}

#endif
