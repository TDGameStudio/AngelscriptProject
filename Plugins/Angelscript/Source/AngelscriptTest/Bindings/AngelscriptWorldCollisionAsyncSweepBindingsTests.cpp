#include "../Shared/AngelscriptScenarioTestUtils.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Components/ActorTestSpawner.h"
#include "Components/BoxComponent.h"
#include "Engine/World.h"
#include "GameFramework/Actor.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/UnrealType.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Bindings_AngelscriptWorldCollisionAsyncSweepBindingsTests_Private
{
	using namespace AngelscriptScenarioTestUtils;

	static const FName WorldCollisionAsyncSweepModuleName(TEXT("ASWorldCollisionAsyncSweepCallbacks"));
	static const FString WorldCollisionAsyncSweepFilename(TEXT("WorldCollisionAsyncSweepCallbacks.as"));
	static const FName WorldCollisionAsyncSweepClassName(TEXT("AScenarioWorldCollisionAsyncSweepCallbacks"));
	static const FVector AsyncSweepStart(-200.0f, 0.0f, 0.0f);
	static const FVector AsyncSweepEnd(200.0f, 0.0f, 0.0f);
	static const FVector AsyncSweepTargetLocation(0.0f, 0.0f, 0.0f);
	static const FVector AsyncSweepTargetExtent(50.0f, 50.0f, 50.0f);
	static const FVector AsyncSweepQueryExtent(30.0f, 30.0f, 30.0f);
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
				*FString::Printf(TEXT("World collision async sweep method '%s' should exist"), *FunctionName.ToString()),
				Function))
		{
			return false;
		}

		return Test.TestTrue(
			*FString::Printf(TEXT("World collision async sweep method '%s' should execute"), *FunctionName.ToString()),
			ExecuteGeneratedIntEventOnGameThread(Object, Function, OutResult));
	}

	template<typename ValueType>
	bool WriteObjectPropertyChecked(
		FAutomationTestBase& Test,
		UObject* Object,
		FName PropertyName,
		ValueType* Value)
	{
		if (!Test.TestNotNull(TEXT("World collision async sweep object should be valid for reflected writes"), Object))
		{
			return false;
		}

		FObjectProperty* Property = FindFProperty<FObjectProperty>(Object->GetClass(), PropertyName);
		if (!Test.TestNotNull(
				*FString::Printf(TEXT("World collision async sweep property '%s' should exist"), *PropertyName.ToString()),
				Property))
		{
			return false;
		}

		Property->SetObjectPropertyValue_InContainer(Object, Value);
		return true;
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
		if (!Test.TestNotNull(TEXT("World collision async sweep object should be valid for uint64 property reads"), Object))
		{
			return false;
		}

		FUInt64Property* Property = FindFProperty<FUInt64Property>(Object->GetClass(), PropertyName);
		if (!Test.TestNotNull(
				*FString::Printf(TEXT("World collision async sweep property '%s' should exist"), *PropertyName.ToString()),
				Property))
		{
			return false;
		}

		OutValue = Property->GetPropertyValue_InContainer(Object);
		return true;
	}

	bool ReadBoolPropertyChecked(
		FAutomationTestBase& Test,
		UObject* Object,
		FName PropertyName,
		bool& OutValue)
	{
		return ReadPropertyValue<FBoolProperty>(Test, Object, PropertyName, OutValue);
	}

	bool WaitForAsyncSweepCallbacks(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		UWorld& World,
		AActor& ScriptActor)
	{
		FIntProperty* ChannelCallbackCountProperty = FindFProperty<FIntProperty>(ScriptActor.GetClass(), TEXT("ChannelCallbackCount"));
		FIntProperty* ObjectCallbackCountProperty = FindFProperty<FIntProperty>(ScriptActor.GetClass(), TEXT("ObjectCallbackCount"));
		FIntProperty* ProfileCallbackCountProperty = FindFProperty<FIntProperty>(ScriptActor.GetClass(), TEXT("ProfileCallbackCount"));
		if (!Test.TestNotNull(TEXT("Async sweep actor should expose ChannelCallbackCount"), ChannelCallbackCountProperty)
			|| !Test.TestNotNull(TEXT("Async sweep actor should expose ObjectCallbackCount"), ObjectCallbackCountProperty)
			|| !Test.TestNotNull(TEXT("Async sweep actor should expose ProfileCallbackCount"), ProfileCallbackCountProperty))
		{
			return false;
		}

		for (int32 TickIndex = 0; TickIndex < AsyncMaxTickCount; ++TickIndex)
		{
			const int32 ChannelCallbackCount = ChannelCallbackCountProperty->GetPropertyValue_InContainer(&ScriptActor);
			const int32 ObjectCallbackCount = ObjectCallbackCountProperty->GetPropertyValue_InContainer(&ScriptActor);
			const int32 ProfileCallbackCount = ProfileCallbackCountProperty->GetPropertyValue_InContainer(&ScriptActor);
			if (ChannelCallbackCount >= 1 && ObjectCallbackCount >= 1 && ProfileCallbackCount >= 1)
			{
				return true;
			}

			TickWorld(Engine, World, AsyncTickDeltaTime, 1);
		}

		Test.AddError(FString::Printf(
			TEXT("Async sweep callbacks did not complete within %d ticks."),
			AsyncMaxTickCount));
		return false;
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptWorldCollisionAsyncSweepBindingsTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptWorldCollisionAsyncSweepBindingsTest,
	"Angelscript.TestModule.FunctionLibraries.WorldCollisionAsyncSweepCallbacks",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptWorldCollisionAsyncSweepBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_FULL();
	ASTEST_BEGIN_FULL
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*WorldCollisionAsyncSweepModuleName.ToString());
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		WorldCollisionAsyncSweepModuleName,
		WorldCollisionAsyncSweepFilename,
		TEXT(R"AS(
UCLASS()
class AScenarioWorldCollisionAsyncSweepCallbacks : AActor
{
	UPROPERTY()
	AActor ExpectedActor;

	UPROPERTY()
	UPrimitiveComponent ExpectedComponent;

	UPROPERTY()
	int ChannelCallbackCount = 0;
	UPROPERTY()
	int ChannelUserData = 0;
	UPROPERTY()
	int ChannelHitCount = 0;
	UPROPERTY()
	int ChannelQuerySucceeded = 0;
	UPROPERTY()
	int ChannelQueryHitCount = 0;
	UPROPERTY()
	int ChannelHandleValidInitially = 0;
	UPROPERTY()
	uint64 ChannelHandleRaw = 0;
	UPROPERTY()
	uint64 LastChannelCallbackHandle = 0;
	UPROPERTY()
	bool bChannelHitActorMatched = false;
	UPROPERTY()
	bool bChannelHitComponentMatched = false;

	UPROPERTY()
	int ObjectCallbackCount = 0;
	UPROPERTY()
	int ObjectUserData = 0;
	UPROPERTY()
	int ObjectHitCount = 0;
	UPROPERTY()
	int ObjectQuerySucceeded = 0;
	UPROPERTY()
	int ObjectQueryHitCount = 0;
	UPROPERTY()
	int ObjectHandleValidInitially = 0;
	UPROPERTY()
	uint64 ObjectHandleRaw = 0;
	UPROPERTY()
	uint64 LastObjectCallbackHandle = 0;
	UPROPERTY()
	bool bObjectHitActorMatched = false;
	UPROPERTY()
	bool bObjectHitComponentMatched = false;

	UPROPERTY()
	int ProfileCallbackCount = 0;
	UPROPERTY()
	int ProfileUserData = 0;
	UPROPERTY()
	int ProfileHitCount = 0;
	UPROPERTY()
	int ProfileQuerySucceeded = 0;
	UPROPERTY()
	int ProfileQueryHitCount = 0;
	UPROPERTY()
	int ProfileHandleValidInitially = 0;
	UPROPERTY()
	uint64 ProfileHandleRaw = 0;
	UPROPERTY()
	uint64 LastProfileCallbackHandle = 0;
	UPROPERTY()
	bool bProfileHitActorMatched = false;
	UPROPERTY()
	bool bProfileHitComponentMatched = false;

	FTraceHandle ChannelHandle;
	FTraceHandle ObjectHandle;
	FTraceHandle ProfileHandle;

	UFUNCTION()
	int StartAsyncSweeps()
	{
		if (ExpectedActor == nullptr || ExpectedComponent == nullptr)
			return 5;

		const FCollisionShape Shape = FCollisionShape::MakeBox(FVector(30.0f, 30.0f, 30.0f));

		FScriptTraceDelegate ChannelDelegate;
		ChannelDelegate.BindUFunction(this, n"HandleChannelSweep");
		ChannelHandle = System::AsyncSweepByChannel(
			EAsyncTraceType::Single,
			FVector(-200.0f, 0.0f, 0.0f),
			FVector(200.0f, 0.0f, 0.0f),
			FQuat::Identity,
			ECollisionChannel::ECC_Visibility,
			Shape,
			FCollisionQueryParams::DefaultQueryParam,
			FCollisionResponseParams::DefaultResponseParam,
			ChannelDelegate,
			101);
		ChannelHandleRaw = ChannelHandle._Handle;
		if (!System::IsTraceHandleValid(ChannelHandle, false))
			return 10;
		ChannelHandleValidInitially = 1;

		FCollisionObjectQueryParams ObjectQueryParams;
		ObjectQueryParams.AddObjectTypesToQuery(ECollisionChannel::ECC_WorldDynamic);
		FScriptTraceDelegate ObjectDelegate;
		ObjectDelegate.BindUFunction(this, n"HandleObjectSweep");
		ObjectHandle = System::AsyncSweepByObjectType(
			EAsyncTraceType::Single,
			FVector(-200.0f, 0.0f, 0.0f),
			FVector(200.0f, 0.0f, 0.0f),
			FQuat::Identity,
			ObjectQueryParams,
			Shape,
			FCollisionQueryParams::DefaultQueryParam,
			ObjectDelegate,
			202);
		ObjectHandleRaw = ObjectHandle._Handle;
		if (!System::IsTraceHandleValid(ObjectHandle, false))
			return 20;
		ObjectHandleValidInitially = 1;

		FScriptTraceDelegate ProfileDelegate;
		ProfileDelegate.BindUFunction(this, n"HandleProfileSweep");
		ProfileHandle = System::AsyncSweepByProfile(
			EAsyncTraceType::Single,
			FVector(-200.0f, 0.0f, 0.0f),
			FVector(200.0f, 0.0f, 0.0f),
			FQuat::Identity,
			CollisionProfile::BlockAllDynamic,
			Shape,
			FCollisionQueryParams::DefaultQueryParam,
			ProfileDelegate,
			303);
		ProfileHandleRaw = ProfileHandle._Handle;
		if (!System::IsTraceHandleValid(ProfileHandle, false))
			return 30;
		ProfileHandleValidInitially = 1;

		return 1;
	}

	UFUNCTION()
	void HandleChannelSweep(uint64 TraceHandleValue, const TArray<FHitResult>& OutHits, uint32 UserData)
	{
		ChannelCallbackCount += 1;
		LastChannelCallbackHandle = TraceHandleValue;
		ChannelUserData = int(UserData);
		ChannelHitCount = OutHits.Num();
		if (OutHits.Num() > 0)
		{
			bChannelHitActorMatched = OutHits[0].GetActor() == ExpectedActor;
			bChannelHitComponentMatched = OutHits[0].GetComponent() == ExpectedComponent;
		}

		FTraceDatum Datum;
		ChannelQuerySucceeded = System::QueryTraceData(ChannelHandle, Datum) ? 1 : 0;
		ChannelQueryHitCount = Datum.OutHits.Num();
	}

	UFUNCTION()
	void HandleObjectSweep(uint64 TraceHandleValue, const TArray<FHitResult>& OutHits, uint32 UserData)
	{
		ObjectCallbackCount += 1;
		LastObjectCallbackHandle = TraceHandleValue;
		ObjectUserData = int(UserData);
		ObjectHitCount = OutHits.Num();
		if (OutHits.Num() > 0)
		{
			bObjectHitActorMatched = OutHits[0].GetActor() == ExpectedActor;
			bObjectHitComponentMatched = OutHits[0].GetComponent() == ExpectedComponent;
		}

		FTraceDatum Datum;
		ObjectQuerySucceeded = System::QueryTraceData(ObjectHandle, Datum) ? 1 : 0;
		ObjectQueryHitCount = Datum.OutHits.Num();
	}

	UFUNCTION()
	void HandleProfileSweep(uint64 TraceHandleValue, const TArray<FHitResult>& OutHits, uint32 UserData)
	{
		ProfileCallbackCount += 1;
		LastProfileCallbackHandle = TraceHandleValue;
		ProfileUserData = int(UserData);
		ProfileHitCount = OutHits.Num();
		if (OutHits.Num() > 0)
		{
			bProfileHitActorMatched = OutHits[0].GetActor() == ExpectedActor;
			bProfileHitComponentMatched = OutHits[0].GetComponent() == ExpectedComponent;
		}

		FTraceDatum Datum;
		ProfileQuerySucceeded = System::QueryTraceData(ProfileHandle, Datum) ? 1 : 0;
		ProfileQueryHitCount = Datum.OutHits.Num();
	}
}
)AS"),
		WorldCollisionAsyncSweepClassName);
	if (ScriptClass == nullptr)
	{
		return false;
	}

	FActorTestSpawner Spawner;
	Spawner.InitializeGameSubsystems();

	AActor& BlockingActor = Spawner.SpawnActor<AActor>();
	UBoxComponent* BlockingBox = AddCollisionBox(
		BlockingActor,
		TEXT("AsyncSweepBlockingTarget"),
		AsyncSweepTargetExtent,
		AsyncSweepTargetLocation);
	if (!TestNotNull(TEXT("Async sweep blocking box should be created"), BlockingBox))
	{
		return false;
	}

	AActor* ScriptActor = SpawnScriptActor(*this, Spawner, ScriptClass);
	if (!TestNotNull(TEXT("Async sweep script actor should spawn"), ScriptActor))
	{
		return false;
	}

	if (!WriteObjectPropertyChecked(*this, ScriptActor, TEXT("ExpectedActor"), &BlockingActor)
		|| !WriteObjectPropertyChecked(*this, ScriptActor, TEXT("ExpectedComponent"), BlockingBox))
	{
		return false;
	}

	BeginPlayActor(Engine, *ScriptActor);

	UWorld* World = BlockingActor.GetWorld();
	if (!TestNotNull(TEXT("Async sweep test should access the spawned world"), World))
	{
		return false;
	}

	int32 StartResult = 0;
	if (!ExecuteGeneratedIntMethod(*this, ScriptActor, ScriptClass, TEXT("StartAsyncSweeps"), StartResult))
	{
		return false;
	}
	TestEqual(TEXT("Async sweep start method should acknowledge launch"), StartResult, 1);

	if (!WaitForAsyncSweepCallbacks(*this, Engine, *World, *ScriptActor))
	{
		return false;
	}

	int32 ChannelCallbackCount = 0;
	int32 ChannelUserData = 0;
	int32 ChannelHitCount = 0;
	int32 ChannelQuerySucceeded = 0;
	int32 ChannelQueryHitCount = 0;
	int32 ChannelHandleValidInitially = 0;
	int32 ObjectCallbackCount = 0;
	int32 ObjectUserData = 0;
	int32 ObjectHitCount = 0;
	int32 ObjectQuerySucceeded = 0;
	int32 ObjectQueryHitCount = 0;
	int32 ObjectHandleValidInitially = 0;
	int32 ProfileCallbackCount = 0;
	int32 ProfileUserData = 0;
	int32 ProfileHitCount = 0;
	int32 ProfileQuerySucceeded = 0;
	int32 ProfileQueryHitCount = 0;
	int32 ProfileHandleValidInitially = 0;
	uint64 ChannelHandleRaw = 0;
	uint64 LastChannelCallbackHandle = 0;
	uint64 ObjectHandleRaw = 0;
	uint64 LastObjectCallbackHandle = 0;
	uint64 ProfileHandleRaw = 0;
	uint64 LastProfileCallbackHandle = 0;
	bool bChannelHitActorMatched = false;
	bool bChannelHitComponentMatched = false;
	bool bObjectHitActorMatched = false;
	bool bObjectHitComponentMatched = false;
	bool bProfileHitActorMatched = false;
	bool bProfileHitComponentMatched = false;
	if (!ReadIntPropertyChecked(*this, ScriptActor, TEXT("ChannelCallbackCount"), ChannelCallbackCount)
		|| !ReadIntPropertyChecked(*this, ScriptActor, TEXT("ChannelUserData"), ChannelUserData)
		|| !ReadIntPropertyChecked(*this, ScriptActor, TEXT("ChannelHitCount"), ChannelHitCount)
		|| !ReadIntPropertyChecked(*this, ScriptActor, TEXT("ChannelQuerySucceeded"), ChannelQuerySucceeded)
		|| !ReadIntPropertyChecked(*this, ScriptActor, TEXT("ChannelQueryHitCount"), ChannelQueryHitCount)
		|| !ReadIntPropertyChecked(*this, ScriptActor, TEXT("ChannelHandleValidInitially"), ChannelHandleValidInitially)
		|| !ReadIntPropertyChecked(*this, ScriptActor, TEXT("ObjectCallbackCount"), ObjectCallbackCount)
		|| !ReadIntPropertyChecked(*this, ScriptActor, TEXT("ObjectUserData"), ObjectUserData)
		|| !ReadIntPropertyChecked(*this, ScriptActor, TEXT("ObjectHitCount"), ObjectHitCount)
		|| !ReadIntPropertyChecked(*this, ScriptActor, TEXT("ObjectQuerySucceeded"), ObjectQuerySucceeded)
		|| !ReadIntPropertyChecked(*this, ScriptActor, TEXT("ObjectQueryHitCount"), ObjectQueryHitCount)
		|| !ReadIntPropertyChecked(*this, ScriptActor, TEXT("ObjectHandleValidInitially"), ObjectHandleValidInitially)
		|| !ReadIntPropertyChecked(*this, ScriptActor, TEXT("ProfileCallbackCount"), ProfileCallbackCount)
		|| !ReadIntPropertyChecked(*this, ScriptActor, TEXT("ProfileUserData"), ProfileUserData)
		|| !ReadIntPropertyChecked(*this, ScriptActor, TEXT("ProfileHitCount"), ProfileHitCount)
		|| !ReadIntPropertyChecked(*this, ScriptActor, TEXT("ProfileQuerySucceeded"), ProfileQuerySucceeded)
		|| !ReadIntPropertyChecked(*this, ScriptActor, TEXT("ProfileQueryHitCount"), ProfileQueryHitCount)
		|| !ReadIntPropertyChecked(*this, ScriptActor, TEXT("ProfileHandleValidInitially"), ProfileHandleValidInitially)
		|| !ReadUInt64PropertyChecked(*this, ScriptActor, TEXT("ChannelHandleRaw"), ChannelHandleRaw)
		|| !ReadUInt64PropertyChecked(*this, ScriptActor, TEXT("LastChannelCallbackHandle"), LastChannelCallbackHandle)
		|| !ReadUInt64PropertyChecked(*this, ScriptActor, TEXT("ObjectHandleRaw"), ObjectHandleRaw)
		|| !ReadUInt64PropertyChecked(*this, ScriptActor, TEXT("LastObjectCallbackHandle"), LastObjectCallbackHandle)
		|| !ReadUInt64PropertyChecked(*this, ScriptActor, TEXT("ProfileHandleRaw"), ProfileHandleRaw)
		|| !ReadUInt64PropertyChecked(*this, ScriptActor, TEXT("LastProfileCallbackHandle"), LastProfileCallbackHandle)
		|| !ReadBoolPropertyChecked(*this, ScriptActor, TEXT("bChannelHitActorMatched"), bChannelHitActorMatched)
		|| !ReadBoolPropertyChecked(*this, ScriptActor, TEXT("bChannelHitComponentMatched"), bChannelHitComponentMatched)
		|| !ReadBoolPropertyChecked(*this, ScriptActor, TEXT("bObjectHitActorMatched"), bObjectHitActorMatched)
		|| !ReadBoolPropertyChecked(*this, ScriptActor, TEXT("bObjectHitComponentMatched"), bObjectHitComponentMatched)
		|| !ReadBoolPropertyChecked(*this, ScriptActor, TEXT("bProfileHitActorMatched"), bProfileHitActorMatched)
		|| !ReadBoolPropertyChecked(*this, ScriptActor, TEXT("bProfileHitComponentMatched"), bProfileHitComponentMatched))
	{
		return false;
	}

	TestEqual(TEXT("AsyncSweepByChannel should invoke its callback exactly once"), ChannelCallbackCount, 1);
	TestEqual(TEXT("AsyncSweepByObjectType should invoke its callback exactly once"), ObjectCallbackCount, 1);
	TestEqual(TEXT("AsyncSweepByProfile should invoke its callback exactly once"), ProfileCallbackCount, 1);
	TestEqual(TEXT("AsyncSweepByChannel should preserve UserData through the delegate bridge"), ChannelUserData, 101);
	TestEqual(TEXT("AsyncSweepByObjectType should preserve UserData through the delegate bridge"), ObjectUserData, 202);
	TestEqual(TEXT("AsyncSweepByProfile should preserve UserData through the delegate bridge"), ProfileUserData, 303);
	TestTrue(TEXT("AsyncSweepByChannel should report at least one hit"), ChannelHitCount > 0);
	TestTrue(TEXT("AsyncSweepByObjectType should report at least one hit"), ObjectHitCount > 0);
	TestTrue(TEXT("AsyncSweepByProfile should report at least one hit"), ProfileHitCount > 0);
	TestEqual(TEXT("AsyncSweepByChannel should return an initially valid trace handle"), ChannelHandleValidInitially, 1);
	TestEqual(TEXT("AsyncSweepByObjectType should return an initially valid trace handle"), ObjectHandleValidInitially, 1);
	TestEqual(TEXT("AsyncSweepByProfile should return an initially valid trace handle"), ProfileHandleValidInitially, 1);
	TestEqual(TEXT("AsyncSweepByChannel callback should observe the same handle that StartAsyncSweeps stored"), LastChannelCallbackHandle, ChannelHandleRaw);
	TestEqual(TEXT("AsyncSweepByObjectType callback should observe the same handle that StartAsyncSweeps stored"), LastObjectCallbackHandle, ObjectHandleRaw);
	TestEqual(TEXT("AsyncSweepByProfile callback should observe the same handle that StartAsyncSweeps stored"), LastProfileCallbackHandle, ProfileHandleRaw);
	TestEqual(TEXT("AsyncSweepByChannel callback should report successful QueryTraceData"), ChannelQuerySucceeded, 1);
	TestEqual(TEXT("AsyncSweepByObjectType callback should report successful QueryTraceData"), ObjectQuerySucceeded, 1);
	TestEqual(TEXT("AsyncSweepByProfile callback should report successful QueryTraceData"), ProfileQuerySucceeded, 1);
	TestEqual(TEXT("AsyncSweepByChannel query hit count should match callback payload"), ChannelQueryHitCount, ChannelHitCount);
	TestEqual(TEXT("AsyncSweepByObjectType query hit count should match callback payload"), ObjectQueryHitCount, ObjectHitCount);
	TestEqual(TEXT("AsyncSweepByProfile query hit count should match callback payload"), ProfileQueryHitCount, ProfileHitCount);
	TestTrue(TEXT("AsyncSweepByChannel should identify the expected blocker actor"), bChannelHitActorMatched);
	TestTrue(TEXT("AsyncSweepByChannel should identify the expected blocker component"), bChannelHitComponentMatched);
	TestTrue(TEXT("AsyncSweepByObjectType should identify the expected blocker actor"), bObjectHitActorMatched);
	TestTrue(TEXT("AsyncSweepByObjectType should identify the expected blocker component"), bObjectHitComponentMatched);
	TestTrue(TEXT("AsyncSweepByProfile should identify the expected blocker actor"), bProfileHitActorMatched);
	TestTrue(TEXT("AsyncSweepByProfile should identify the expected blocker component"), bProfileHitComponentMatched);

	ASTEST_END_FULL
	return true;
}

#endif
