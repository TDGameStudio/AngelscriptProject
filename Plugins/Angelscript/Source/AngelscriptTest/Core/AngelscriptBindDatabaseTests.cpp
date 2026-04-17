#include "AngelscriptBindDatabase.h"
#include "AngelscriptEngine.h"
#include "../Shared/AngelscriptTestUtilities.h"

#include "Engine/EngineTypes.h"
#include "GameFramework/Actor.h"
#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/Guid.h"
#include "Misc/Paths.h"
#include "Misc/ScopeExit.h"
#include "UObject/UnrealType.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace AngelscriptTest_Core_AngelscriptBindDatabaseTests_Private
{
	struct FBindDatabaseContextStackGuard
	{
		TArray<FAngelscriptEngine*> SavedStack;

		FBindDatabaseContextStackGuard()
		{
			SavedStack = FAngelscriptEngineContextStack::SnapshotAndClear();
		}

		~FBindDatabaseContextStackGuard()
		{
			FAngelscriptEngineContextStack::RestoreSnapshot(MoveTemp(SavedStack));
		}

		void DiscardSavedStack()
		{
			SavedStack.Reset();
		}
	};

	FString MakeBindDatabaseAutomationDirectory()
	{
		return FPaths::Combine(
			FPaths::ProjectSavedDir(),
			TEXT("Automation"),
			TEXT("BindDatabase"),
			FGuid::NewGuid().ToString(EGuidFormats::Digits));
	}

	FAngelscriptPropertyBind MakeSamplePropertyBind(const FString& Declaration, const FString& UnrealPath, const FString& GeneratedName)
	{
		FAngelscriptPropertyBind Bind;
		Bind.Declaration = Declaration;
		Bind.UnrealPath = UnrealPath;
		Bind.GeneratedName = GeneratedName;
		Bind.bCanWrite = true;
		Bind.bCanRead = true;
		Bind.bCanEdit = false;
		Bind.bGeneratedGetter = true;
		Bind.bGeneratedSetter = false;
		Bind.bGeneratedHandle = true;
		Bind.bGeneratedUnresolvedObject = false;
		return Bind;
	}

	FAngelscriptMethodBind MakeSampleMethodBind()
	{
		FAngelscriptMethodBind Bind;
		Bind.Declaration = TEXT("void DestroyActor()");
		Bind.UnrealPath = TEXT("/Script/Engine.Actor:K2_DestroyActor");
		Bind.ClassName = TEXT("AActor");
		Bind.ScriptName = TEXT("DestroyActor");
		Bind.WorldContextArgument = 1;
		Bind.DeterminesOutputTypeArgument = -1;
		Bind.bStaticInUnreal = false;
		Bind.bStaticInScript = true;
		Bind.bGlobalScope = false;
		Bind.bNotAngelscriptProperty = true;
		Bind.bTrivial = true;
		return Bind;
	}

	FAngelscriptClassBind MakeSampleClassBind(UClass* Class)
	{
		FAngelscriptClassBind Bind;
		Bind.TypeName = TEXT("AActor");
		Bind.UnrealPath = Class->GetPathName();
		Bind.Methods.Add(MakeSampleMethodBind());
		Bind.Properties.Add(MakeSamplePropertyBind(
			TEXT("float InitialLifeSpan"),
			TEXT("/Script/Engine.Actor:InitialLifeSpan"),
			TEXT("InitialLifeSpan")));
		return Bind;
	}

	FAngelscriptClassBind MakeNamedSampleClassBind(UClass* Class, const FString& TypeName)
	{
		FAngelscriptClassBind Bind = MakeSampleClassBind(Class);
		Bind.TypeName = TypeName;
		return Bind;
	}

	FAngelscriptStructBind MakeSampleStructBind(UScriptStruct* Struct)
	{
		FAngelscriptStructBind Bind;
		Bind.TypeName = TEXT("FHitResult");
		Bind.UnrealPath = Struct->GetPathName();
		Bind.Properties.Add(MakeSamplePropertyBind(
			TEXT("bool bBlockingHit"),
			TEXT("/Script/Engine.HitResult:bBlockingHit"),
			TEXT("BlockingHit")));
		return Bind;
	}

	bool ExpectPropertyBindEquals(FAutomationTestBase& Test, const TCHAR* Context, const FAngelscriptPropertyBind& Actual, const FAngelscriptPropertyBind& Expected)
	{
		bool bOk = true;
		bOk &= Test.TestEqual(*FString::Printf(TEXT("%s should round-trip property declaration"), Context), Actual.Declaration, Expected.Declaration);
		bOk &= Test.TestEqual(*FString::Printf(TEXT("%s should round-trip property UnrealPath"), Context), Actual.UnrealPath, Expected.UnrealPath);
		bOk &= Test.TestEqual(*FString::Printf(TEXT("%s should round-trip property GeneratedName"), Context), Actual.GeneratedName, Expected.GeneratedName);
		bOk &= Test.TestEqual(*FString::Printf(TEXT("%s should round-trip property bCanWrite"), Context), Actual.bCanWrite, Expected.bCanWrite);
		bOk &= Test.TestEqual(*FString::Printf(TEXT("%s should round-trip property bCanRead"), Context), Actual.bCanRead, Expected.bCanRead);
		bOk &= Test.TestEqual(*FString::Printf(TEXT("%s should round-trip property bCanEdit"), Context), Actual.bCanEdit, Expected.bCanEdit);
		bOk &= Test.TestEqual(*FString::Printf(TEXT("%s should round-trip property bGeneratedGetter"), Context), Actual.bGeneratedGetter, Expected.bGeneratedGetter);
		bOk &= Test.TestEqual(*FString::Printf(TEXT("%s should round-trip property bGeneratedSetter"), Context), Actual.bGeneratedSetter, Expected.bGeneratedSetter);
		bOk &= Test.TestEqual(*FString::Printf(TEXT("%s should round-trip property bGeneratedHandle"), Context), Actual.bGeneratedHandle, Expected.bGeneratedHandle);
		bOk &= Test.TestEqual(*FString::Printf(TEXT("%s should round-trip property bGeneratedUnresolvedObject"), Context), Actual.bGeneratedUnresolvedObject, Expected.bGeneratedUnresolvedObject);
		return bOk;
	}

	bool ExpectMethodBindEquals(FAutomationTestBase& Test, const FAngelscriptMethodBind& Actual, const FAngelscriptMethodBind& Expected)
	{
		bool bOk = true;
		bOk &= Test.TestEqual(TEXT("BindDatabase round-trip should preserve method declaration"), Actual.Declaration, Expected.Declaration);
		bOk &= Test.TestEqual(TEXT("BindDatabase round-trip should preserve method UnrealPath"), Actual.UnrealPath, Expected.UnrealPath);
		bOk &= Test.TestEqual(TEXT("BindDatabase round-trip should preserve method ClassName"), Actual.ClassName, Expected.ClassName);
		bOk &= Test.TestEqual(TEXT("BindDatabase round-trip should preserve method ScriptName"), Actual.ScriptName, Expected.ScriptName);
		bOk &= Test.TestEqual(TEXT("BindDatabase round-trip should preserve method WorldContextArgument"), static_cast<int32>(Actual.WorldContextArgument), static_cast<int32>(Expected.WorldContextArgument));
		bOk &= Test.TestEqual(TEXT("BindDatabase round-trip should preserve method DeterminesOutputTypeArgument"), static_cast<int32>(Actual.DeterminesOutputTypeArgument), static_cast<int32>(Expected.DeterminesOutputTypeArgument));
		bOk &= Test.TestEqual(TEXT("BindDatabase round-trip should preserve method bStaticInUnreal"), Actual.bStaticInUnreal, Expected.bStaticInUnreal);
		bOk &= Test.TestEqual(TEXT("BindDatabase round-trip should preserve method bStaticInScript"), Actual.bStaticInScript, Expected.bStaticInScript);
		bOk &= Test.TestEqual(TEXT("BindDatabase round-trip should preserve method bGlobalScope"), Actual.bGlobalScope, Expected.bGlobalScope);
		bOk &= Test.TestEqual(TEXT("BindDatabase round-trip should preserve method bNotAngelscriptProperty"), Actual.bNotAngelscriptProperty, Expected.bNotAngelscriptProperty);
		bOk &= Test.TestEqual(TEXT("BindDatabase round-trip should preserve method bTrivial"), Actual.bTrivial, Expected.bTrivial);
		return bOk;
	}

	bool DatabaseContainsClassBindNamed(const FAngelscriptBindDatabase& Database, const FString& TypeName)
	{
		return Database.Classes.ContainsByPredicate(
			[&TypeName](const FAngelscriptClassBind& Bind)
			{
				return Bind.TypeName == TypeName;
			});
	}

	UDelegateFunction* GetSampleDelegateFunction()
	{
		const FMulticastDelegateProperty* DelegateProperty = FindFProperty<FMulticastDelegateProperty>(
			AActor::StaticClass(),
			GET_MEMBER_NAME_CHECKED(AActor, OnActorBeginOverlap));
		return DelegateProperty != nullptr ? Cast<UDelegateFunction>(DelegateProperty->SignatureFunction) : nullptr;
	}
}

using namespace AngelscriptTest_Core_AngelscriptBindDatabaseTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBindDatabaseSaveLoadRoundTripTest,
	"Angelscript.TestModule.Engine.BindDatabase.SaveLoadRoundTripsClassesAndHeaders",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBindDatabaseGetCurrentEnginePriorityTest,
	"Angelscript.TestModule.Engine.BindDatabase.GetPrefersCurrentEngineSharedDatabaseAndFallsBackToLegacySingleton",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBindDatabaseLoadWithoutHeadersSidecarTest,
	"Angelscript.TestModule.Engine.BindDatabase.LoadWithoutHeadersSidecarLeavesHeaderLinksEmptyButRestoresBinds",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBindDatabaseClearPurgesEnumsDelegatesAndHeaderLinksTest,
	"Angelscript.TestModule.Engine.BindDatabase.ClearPurgesEnumsDelegatesAndHeaderLinks",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptBindDatabaseSaveLoadRoundTripTest::RunTest(const FString& Parameters)
{
	FAngelscriptTestFixture Fixture(*this, ETestEngineMode::IsolatedFull);
	if (!TestTrue(TEXT("BindDatabase.SaveLoadRoundTripsClassesAndHeaders should acquire an isolated full engine"), Fixture.IsValid()))
	{
		return false;
	}

	FAngelscriptEngine& Engine = Fixture.GetEngine();
	FAngelscriptBindDatabase* LocalDatabase = Engine.GetBindDatabase();
	if (!TestNotNull(TEXT("BindDatabase.SaveLoadRoundTripsClassesAndHeaders should expose an engine-local bind database"), LocalDatabase))
	{
		return false;
	}

	FAngelscriptBindDatabase& Database = Engine.GetBindDatabaseForTesting();
	if (!TestTrue(TEXT("BindDatabase.SaveLoadRoundTripsClassesAndHeaders should resolve GetBindDatabaseForTesting through the scoped engine"), &Database == LocalDatabase))
	{
		return false;
	}

	UClass* ActorClass = AActor::StaticClass();
	UScriptStruct* HitResultStruct = TBaseStructure<FHitResult>::Get();
	if (!TestNotNull(TEXT("BindDatabase.SaveLoadRoundTripsClassesAndHeaders should resolve AActor"), ActorClass) ||
		!TestNotNull(TEXT("BindDatabase.SaveLoadRoundTripsClassesAndHeaders should resolve FHitResult"), HitResultStruct))
	{
		return false;
	}

	const FAngelscriptClassBind ExpectedClassBind = MakeSampleClassBind(ActorClass);
	const FAngelscriptStructBind ExpectedStructBind = MakeSampleStructBind(HitResultStruct);

	const FString CacheDirectory = MakeBindDatabaseAutomationDirectory();
	const FString CachePath = FPaths::Combine(CacheDirectory, TEXT("Binds.Cache"));
	const FString HeadersPath = CachePath + TEXT(".Headers");
	IFileManager::Get().MakeDirectory(*CacheDirectory, true);

	ON_SCOPE_EXIT
	{
		Database.Clear();
		IFileManager::Get().DeleteDirectory(*CacheDirectory, false, true);
	};

	Database.Clear();
	Database.Classes.Add(ExpectedClassBind);
	Database.Structs.Add(ExpectedStructBind);
	Database.HeaderLinks.Add(ActorClass, TEXT("Dummy/ActorHeader.h"));
	Database.HeaderLinks.Add(HitResultStruct, TEXT("Dummy/HitResultHeader.h"));

	Database.Save(CachePath);

	if (!TestTrue(TEXT("BindDatabase.SaveLoadRoundTripsClassesAndHeaders should write Binds.Cache"), IFileManager::Get().FileExists(*CachePath)) ||
		!TestTrue(TEXT("BindDatabase.SaveLoadRoundTripsClassesAndHeaders should write Binds.Cache.Headers"), IFileManager::Get().FileExists(*HeadersPath)))
	{
		return false;
	}

	Database.Clear();
	if (!TestEqual(TEXT("BindDatabase.SaveLoadRoundTripsClassesAndHeaders should clear class binds"), Database.Classes.Num(), 0) ||
		!TestEqual(TEXT("BindDatabase.SaveLoadRoundTripsClassesAndHeaders should clear struct binds"), Database.Structs.Num(), 0) ||
		!TestEqual(TEXT("BindDatabase.SaveLoadRoundTripsClassesAndHeaders should clear header links"), Database.HeaderLinks.Num(), 0))
	{
		return false;
	}

	Database.Load(CachePath, false);

	if (!TestEqual(TEXT("BindDatabase.SaveLoadRoundTripsClassesAndHeaders should restore exactly one class bind"), Database.Classes.Num(), 1) ||
		!TestEqual(TEXT("BindDatabase.SaveLoadRoundTripsClassesAndHeaders should restore exactly one struct bind"), Database.Structs.Num(), 1) ||
		!TestEqual(TEXT("BindDatabase.SaveLoadRoundTripsClassesAndHeaders should keep header links empty when loading without precompiled data"), Database.HeaderLinks.Num(), 0))
	{
		return false;
	}

	const FAngelscriptClassBind& LoadedClassBind = Database.Classes[0];
	const FAngelscriptStructBind& LoadedStructBind = Database.Structs[0];

	bool bOk = true;
	bOk &= TestEqual(TEXT("BindDatabase.SaveLoadRoundTripsClassesAndHeaders should round-trip class TypeName"), LoadedClassBind.TypeName, ExpectedClassBind.TypeName);
	bOk &= TestEqual(TEXT("BindDatabase.SaveLoadRoundTripsClassesAndHeaders should round-trip class UnrealPath"), LoadedClassBind.UnrealPath, ExpectedClassBind.UnrealPath);
	bOk &= TestEqual(TEXT("BindDatabase.SaveLoadRoundTripsClassesAndHeaders should round-trip class method count"), LoadedClassBind.Methods.Num(), ExpectedClassBind.Methods.Num());
	bOk &= TestEqual(TEXT("BindDatabase.SaveLoadRoundTripsClassesAndHeaders should round-trip class property count"), LoadedClassBind.Properties.Num(), ExpectedClassBind.Properties.Num());
	bOk &= TestEqual(TEXT("BindDatabase.SaveLoadRoundTripsClassesAndHeaders should round-trip struct TypeName"), LoadedStructBind.TypeName, ExpectedStructBind.TypeName);
	bOk &= TestEqual(TEXT("BindDatabase.SaveLoadRoundTripsClassesAndHeaders should round-trip struct UnrealPath"), LoadedStructBind.UnrealPath, ExpectedStructBind.UnrealPath);
	bOk &= TestEqual(TEXT("BindDatabase.SaveLoadRoundTripsClassesAndHeaders should round-trip struct property count"), LoadedStructBind.Properties.Num(), ExpectedStructBind.Properties.Num());

	if (!bOk)
	{
		return false;
	}

	if (!ExpectMethodBindEquals(*this, LoadedClassBind.Methods[0], ExpectedClassBind.Methods[0]) ||
		!ExpectPropertyBindEquals(*this, TEXT("BindDatabase class bind"), LoadedClassBind.Properties[0], ExpectedClassBind.Properties[0]) ||
		!ExpectPropertyBindEquals(*this, TEXT("BindDatabase struct bind"), LoadedStructBind.Properties[0], ExpectedStructBind.Properties[0]))
	{
		return false;
	}

	Database.Clear();
	Database.Load(CachePath, true);

	if (!TestTrue(TEXT("BindDatabase.SaveLoadRoundTripsClassesAndHeaders should populate class header links when generating precompiled data"), Database.HeaderLinks.Contains(ActorClass)) ||
		!TestTrue(TEXT("BindDatabase.SaveLoadRoundTripsClassesAndHeaders should populate struct header links when generating precompiled data"), Database.HeaderLinks.Contains(HitResultStruct)))
	{
		return false;
	}

	const FString ActorHeader = Database.HeaderLinks.FindRef(ActorClass);
	const FString StructHeader = Database.HeaderLinks.FindRef(HitResultStruct);
	bOk = true;
	bOk &= TestFalse(TEXT("BindDatabase.SaveLoadRoundTripsClassesAndHeaders should load a non-empty header for AActor"), ActorHeader.IsEmpty());
	bOk &= TestFalse(TEXT("BindDatabase.SaveLoadRoundTripsClassesAndHeaders should load a non-empty header for FHitResult"), StructHeader.IsEmpty());
	bOk &= TestTrue(TEXT("BindDatabase.SaveLoadRoundTripsClassesAndHeaders should load an existing header path for AActor"), IFileManager::Get().FileExists(*ActorHeader));
	bOk &= TestTrue(TEXT("BindDatabase.SaveLoadRoundTripsClassesAndHeaders should load an existing header path for FHitResult"), IFileManager::Get().FileExists(*StructHeader));
	return bOk;
}

bool FAngelscriptBindDatabaseGetCurrentEnginePriorityTest::RunTest(const FString& Parameters)
{
	FBindDatabaseContextStackGuard ContextGuard;
	AngelscriptTestSupport::DestroySharedTestEngine();
	if (FAngelscriptEngine::IsInitialized())
	{
		AngelscriptTestSupport::FAngelscriptTestEngineScopeAccess::DestroyGlobalEngine();
	}
	ContextGuard.DiscardSavedStack();

	static const FString LegacySentinelTypeName(TEXT("BindDatabaseLegacySentinel"));
	static const FString EngineASentinelTypeName(TEXT("BindDatabaseEngineASentinel"));

	FAngelscriptBindDatabase* LegacyDatabase = &FAngelscriptBindDatabase::Get();
	if (!TestNotNull(TEXT("BindDatabase.GetPrefersCurrentEngineSharedDatabaseAndFallsBackToLegacySingleton should expose a legacy database without a current engine"), LegacyDatabase))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		LegacyDatabase->Clear();
		if (FAngelscriptEngine::IsInitialized())
		{
			AngelscriptTestSupport::FAngelscriptTestEngineScopeAccess::DestroyGlobalEngine();
		}
		AngelscriptTestSupport::DestroySharedTestEngine();
	};

	LegacyDatabase->Clear();
	LegacyDatabase->Classes.Add(MakeNamedSampleClassBind(AActor::StaticClass(), LegacySentinelTypeName));
	FAngelscriptBindDatabase* LegacyDatabaseSecondRead = &FAngelscriptBindDatabase::Get();

	bool bOk = true;
	bOk &= TestNull(
		TEXT("BindDatabase.GetPrefersCurrentEngineSharedDatabaseAndFallsBackToLegacySingleton should start without a current engine"),
		FAngelscriptTestEngineScopeAccess::GetCurrentEngine());
	bOk &= TestTrue(
		TEXT("BindDatabase.GetPrefersCurrentEngineSharedDatabaseAndFallsBackToLegacySingleton should reuse the same legacy singleton when no current engine exists"),
		LegacyDatabaseSecondRead == LegacyDatabase);
	bOk &= TestTrue(
		TEXT("BindDatabase.GetPrefersCurrentEngineSharedDatabaseAndFallsBackToLegacySingleton should preserve legacy sentinel data across baseline reads"),
		DatabaseContainsClassBindNamed(*LegacyDatabase, LegacySentinelTypeName));

	TUniquePtr<FAngelscriptEngine> EngineA = AngelscriptTestSupport::CreateFullTestEngine();
	if (!TestNotNull(TEXT("BindDatabase.GetPrefersCurrentEngineSharedDatabaseAndFallsBackToLegacySingleton should create engine A"), EngineA.Get()))
	{
		return false;
	}

	FAngelscriptBindDatabase* EngineADatabaseFromGet = nullptr;
	FAngelscriptBindDatabase* EngineADirectDatabase = nullptr;

	{
		FAngelscriptEngineScope ScopeA(*EngineA);
		EngineADirectDatabase = EngineA->GetBindDatabase();
		EngineADatabaseFromGet = &FAngelscriptBindDatabase::Get();
		FAngelscriptBindDatabase& EngineADatabaseFromTesting = EngineA->GetBindDatabaseForTesting();

		bOk &= TestNotNull(
			TEXT("BindDatabase.GetPrefersCurrentEngineSharedDatabaseAndFallsBackToLegacySingleton should expose an engine-owned bind database"),
			EngineADirectDatabase);
		bOk &= TestTrue(
			TEXT("BindDatabase.GetPrefersCurrentEngineSharedDatabaseAndFallsBackToLegacySingleton should prefer the current engine bind database over the legacy singleton"),
			EngineADatabaseFromGet == EngineADirectDatabase);
		bOk &= TestTrue(
			TEXT("BindDatabase.GetPrefersCurrentEngineSharedDatabaseAndFallsBackToLegacySingleton should align GetBindDatabaseForTesting with the scoped engine database"),
			&EngineADatabaseFromTesting == EngineADirectDatabase);
		bOk &= TestTrue(
			TEXT("BindDatabase.GetPrefersCurrentEngineSharedDatabaseAndFallsBackToLegacySingleton should not alias the legacy singleton while engine A is current"),
			EngineADirectDatabase != LegacyDatabase);

		EngineADirectDatabase->Clear();
		EngineADirectDatabase->Classes.Add(MakeNamedSampleClassBind(AActor::StaticClass(), EngineASentinelTypeName));
		bOk &= TestTrue(
			TEXT("BindDatabase.GetPrefersCurrentEngineSharedDatabaseAndFallsBackToLegacySingleton should keep engine A sentinel data in the engine-owned database"),
			DatabaseContainsClassBindNamed(*EngineADirectDatabase, EngineASentinelTypeName));
		bOk &= TestFalse(
			TEXT("BindDatabase.GetPrefersCurrentEngineSharedDatabaseAndFallsBackToLegacySingleton should keep engine A sentinel out of the legacy singleton"),
			DatabaseContainsClassBindNamed(*LegacyDatabase, EngineASentinelTypeName));

		TUniquePtr<FAngelscriptEngine> EngineB = AngelscriptTestSupport::CreateIsolatedCloneEngine();
		if (!TestNotNull(TEXT("BindDatabase.GetPrefersCurrentEngineSharedDatabaseAndFallsBackToLegacySingleton should create clone engine B"), EngineB.Get()))
		{
			return false;
		}

		{
			FAngelscriptEngineScope ScopeB(*EngineB);
			FAngelscriptBindDatabase* EngineBDirectDatabase = EngineB->GetBindDatabase();
			FAngelscriptBindDatabase* EngineBDatabaseFromGet = &FAngelscriptBindDatabase::Get();

			bOk &= TestNotNull(
				TEXT("BindDatabase.GetPrefersCurrentEngineSharedDatabaseAndFallsBackToLegacySingleton should expose a bind database for clone engine B"),
				EngineBDirectDatabase);
			bOk &= TestTrue(
				TEXT("BindDatabase.GetPrefersCurrentEngineSharedDatabaseAndFallsBackToLegacySingleton should keep clone engine B on engine A's shared bind database"),
				EngineBDirectDatabase == EngineADirectDatabase);
			bOk &= TestTrue(
				TEXT("BindDatabase.GetPrefersCurrentEngineSharedDatabaseAndFallsBackToLegacySingleton should resolve Get() to the shared bind database while clone engine B is current"),
				EngineBDatabaseFromGet == EngineADirectDatabase);
			bOk &= TestTrue(
				TEXT("BindDatabase.GetPrefersCurrentEngineSharedDatabaseAndFallsBackToLegacySingleton should preserve engine A sentinel through clone engine B"),
				DatabaseContainsClassBindNamed(*EngineBDirectDatabase, EngineASentinelTypeName));
		}

		bOk &= TestTrue(
			TEXT("BindDatabase.GetPrefersCurrentEngineSharedDatabaseAndFallsBackToLegacySingleton should restore engine A as the current engine after leaving clone scope"),
			&FAngelscriptBindDatabase::Get() == EngineADirectDatabase);
	}

	EngineA.Reset();
	bOk &= TestNull(
		TEXT("BindDatabase.GetPrefersCurrentEngineSharedDatabaseAndFallsBackToLegacySingleton should restore the no-current-engine baseline after destroying engine A"),
		FAngelscriptTestEngineScopeAccess::GetCurrentEngine());

	TUniquePtr<FAngelscriptEngine> EngineC = AngelscriptTestSupport::CreateFullTestEngine();
	if (!TestNotNull(TEXT("BindDatabase.GetPrefersCurrentEngineSharedDatabaseAndFallsBackToLegacySingleton should create engine C"), EngineC.Get()))
	{
		return false;
	}

	{
		FAngelscriptEngineScope ScopeC(*EngineC);
		FAngelscriptBindDatabase* EngineCDirectDatabase = EngineC->GetBindDatabase();
		FAngelscriptBindDatabase* EngineCDatabaseFromGet = &FAngelscriptBindDatabase::Get();

		bOk &= TestNotNull(
			TEXT("BindDatabase.GetPrefersCurrentEngineSharedDatabaseAndFallsBackToLegacySingleton should expose a bind database for engine C"),
			EngineCDirectDatabase);
		bOk &= TestTrue(
			TEXT("BindDatabase.GetPrefersCurrentEngineSharedDatabaseAndFallsBackToLegacySingleton should still route Get() through the current engine C database"),
			EngineCDatabaseFromGet == EngineCDirectDatabase);
		bOk &= TestTrue(
			TEXT("BindDatabase.GetPrefersCurrentEngineSharedDatabaseAndFallsBackToLegacySingleton should allocate a fresh bind database for a recreated full engine"),
			EngineCDirectDatabase != EngineADatabaseFromGet);
		bOk &= TestFalse(
			TEXT("BindDatabase.GetPrefersCurrentEngineSharedDatabaseAndFallsBackToLegacySingleton should not leak engine A sentinel data into recreated engine C"),
			DatabaseContainsClassBindNamed(*EngineCDirectDatabase, EngineASentinelTypeName));
	}

	EngineC.Reset();

	bOk &= TestNull(
		TEXT("BindDatabase.GetPrefersCurrentEngineSharedDatabaseAndFallsBackToLegacySingleton should end without a current engine"),
		FAngelscriptTestEngineScopeAccess::GetCurrentEngine());
	bOk &= TestTrue(
		TEXT("BindDatabase.GetPrefersCurrentEngineSharedDatabaseAndFallsBackToLegacySingleton should fall back to the original legacy singleton after all scoped engines are gone"),
		&FAngelscriptBindDatabase::Get() == LegacyDatabase);
	bOk &= TestTrue(
		TEXT("BindDatabase.GetPrefersCurrentEngineSharedDatabaseAndFallsBackToLegacySingleton should preserve the legacy sentinel after scoped engine lifetimes end"),
		DatabaseContainsClassBindNamed(*LegacyDatabase, LegacySentinelTypeName));
	return bOk;
}

bool FAngelscriptBindDatabaseLoadWithoutHeadersSidecarTest::RunTest(const FString& Parameters)
{
	FAngelscriptTestFixture Fixture(*this, ETestEngineMode::IsolatedFull);
	if (!TestTrue(TEXT("BindDatabase.LoadWithoutHeadersSidecarLeavesHeaderLinksEmptyButRestoresBinds should acquire an isolated full engine"), Fixture.IsValid()))
	{
		return false;
	}

	FAngelscriptEngine& Engine = Fixture.GetEngine();
	FAngelscriptBindDatabase& Database = Engine.GetBindDatabaseForTesting();

	UClass* ActorClass = AActor::StaticClass();
	UScriptStruct* HitResultStruct = TBaseStructure<FHitResult>::Get();
	if (!TestNotNull(TEXT("BindDatabase.LoadWithoutHeadersSidecarLeavesHeaderLinksEmptyButRestoresBinds should resolve AActor"), ActorClass) ||
		!TestNotNull(TEXT("BindDatabase.LoadWithoutHeadersSidecarLeavesHeaderLinksEmptyButRestoresBinds should resolve FHitResult"), HitResultStruct))
	{
		return false;
	}

	const FAngelscriptClassBind ExpectedClassBind = MakeSampleClassBind(ActorClass);
	const FAngelscriptStructBind ExpectedStructBind = MakeSampleStructBind(HitResultStruct);

	const FString CacheDirectory = MakeBindDatabaseAutomationDirectory();
	const FString CachePath = FPaths::Combine(CacheDirectory, TEXT("Binds.Cache"));
	const FString HeadersPath = CachePath + TEXT(".Headers");
	const FString SentinelHeaderPath = TEXT("Sentinel/ShouldBeCleared.h");
	IFileManager::Get().MakeDirectory(*CacheDirectory, true);

	ON_SCOPE_EXIT
	{
		Database.Clear();
		IFileManager::Get().DeleteDirectory(*CacheDirectory, false, true);
	};

	Database.Clear();
	Database.Classes.Add(ExpectedClassBind);
	Database.Structs.Add(ExpectedStructBind);
	Database.HeaderLinks.Add(ActorClass, TEXT("Dummy/ActorHeader.h"));
	Database.HeaderLinks.Add(HitResultStruct, TEXT("Dummy/HitResultHeader.h"));

	Database.Save(CachePath);

	if (!TestTrue(TEXT("BindDatabase.LoadWithoutHeadersSidecarLeavesHeaderLinksEmptyButRestoresBinds should write Binds.Cache"), IFileManager::Get().FileExists(*CachePath)) ||
		!TestTrue(TEXT("BindDatabase.LoadWithoutHeadersSidecarLeavesHeaderLinksEmptyButRestoresBinds should write Binds.Cache.Headers"), IFileManager::Get().FileExists(*HeadersPath)))
	{
		return false;
	}

	Database.Clear();
	Database.HeaderLinks.Add(ActorClass, SentinelHeaderPath);

	if (!TestEqual(TEXT("BindDatabase.LoadWithoutHeadersSidecarLeavesHeaderLinksEmptyButRestoresBinds should stage exactly one sentinel header link before the load"), Database.HeaderLinks.Num(), 1) ||
		!TestEqual(TEXT("BindDatabase.LoadWithoutHeadersSidecarLeavesHeaderLinksEmptyButRestoresBinds should preserve the staged sentinel header path before the load"), Database.HeaderLinks.FindRef(ActorClass), SentinelHeaderPath))
	{
		return false;
	}

	if (!TestTrue(TEXT("BindDatabase.LoadWithoutHeadersSidecarLeavesHeaderLinksEmptyButRestoresBinds should delete the .Headers sidecar before loading"), IFileManager::Get().Delete(*HeadersPath, false, true)) ||
		!TestFalse(TEXT("BindDatabase.LoadWithoutHeadersSidecarLeavesHeaderLinksEmptyButRestoresBinds should confirm the .Headers sidecar is missing"), IFileManager::Get().FileExists(*HeadersPath)))
	{
		return false;
	}

	Database.Load(CachePath, true);

	if (!TestEqual(TEXT("BindDatabase.LoadWithoutHeadersSidecarLeavesHeaderLinksEmptyButRestoresBinds should restore exactly one class bind"), Database.Classes.Num(), 1) ||
		!TestEqual(TEXT("BindDatabase.LoadWithoutHeadersSidecarLeavesHeaderLinksEmptyButRestoresBinds should restore exactly one struct bind"), Database.Structs.Num(), 1))
	{
		return false;
	}

	const FAngelscriptClassBind& LoadedClassBind = Database.Classes[0];
	const FAngelscriptStructBind& LoadedStructBind = Database.Structs[0];

	bool bOk = true;
	bOk &= TestEqual(TEXT("BindDatabase.LoadWithoutHeadersSidecarLeavesHeaderLinksEmptyButRestoresBinds should round-trip class TypeName"), LoadedClassBind.TypeName, ExpectedClassBind.TypeName);
	bOk &= TestEqual(TEXT("BindDatabase.LoadWithoutHeadersSidecarLeavesHeaderLinksEmptyButRestoresBinds should round-trip class UnrealPath"), LoadedClassBind.UnrealPath, ExpectedClassBind.UnrealPath);
	bOk &= TestEqual(TEXT("BindDatabase.LoadWithoutHeadersSidecarLeavesHeaderLinksEmptyButRestoresBinds should round-trip class method count"), LoadedClassBind.Methods.Num(), ExpectedClassBind.Methods.Num());
	bOk &= TestEqual(TEXT("BindDatabase.LoadWithoutHeadersSidecarLeavesHeaderLinksEmptyButRestoresBinds should round-trip class property count"), LoadedClassBind.Properties.Num(), ExpectedClassBind.Properties.Num());
	bOk &= TestEqual(TEXT("BindDatabase.LoadWithoutHeadersSidecarLeavesHeaderLinksEmptyButRestoresBinds should round-trip struct TypeName"), LoadedStructBind.TypeName, ExpectedStructBind.TypeName);
	bOk &= TestEqual(TEXT("BindDatabase.LoadWithoutHeadersSidecarLeavesHeaderLinksEmptyButRestoresBinds should round-trip struct UnrealPath"), LoadedStructBind.UnrealPath, ExpectedStructBind.UnrealPath);
	bOk &= TestEqual(TEXT("BindDatabase.LoadWithoutHeadersSidecarLeavesHeaderLinksEmptyButRestoresBinds should round-trip struct property count"), LoadedStructBind.Properties.Num(), ExpectedStructBind.Properties.Num());
	bOk &= TestEqual(TEXT("BindDatabase.LoadWithoutHeadersSidecarLeavesHeaderLinksEmptyButRestoresBinds should clear stale header links when the sidecar is missing"), Database.HeaderLinks.Num(), 0);
	bOk &= TestFalse(TEXT("BindDatabase.LoadWithoutHeadersSidecarLeavesHeaderLinksEmptyButRestoresBinds should remove the sentinel actor header link when the sidecar is missing"), Database.HeaderLinks.Contains(ActorClass));

	if (!bOk)
	{
		return false;
	}

	if (!ExpectMethodBindEquals(*this, LoadedClassBind.Methods[0], ExpectedClassBind.Methods[0]) ||
		!ExpectPropertyBindEquals(*this, TEXT("BindDatabase missing-sidecar class bind"), LoadedClassBind.Properties[0], ExpectedClassBind.Properties[0]) ||
		!ExpectPropertyBindEquals(*this, TEXT("BindDatabase missing-sidecar struct bind"), LoadedStructBind.Properties[0], ExpectedStructBind.Properties[0]))
	{
		return false;
	}

	return true;
}

bool FAngelscriptBindDatabaseClearPurgesEnumsDelegatesAndHeaderLinksTest::RunTest(const FString& Parameters)
{
	FAngelscriptTestFixture Fixture(*this, ETestEngineMode::IsolatedFull);
	if (!TestTrue(TEXT("BindDatabase.ClearPurgesEnumsDelegatesAndHeaderLinks should acquire an isolated full engine"), Fixture.IsValid()))
	{
		return false;
	}

	FAngelscriptEngine& Engine = Fixture.GetEngine();
	FAngelscriptBindDatabase& Database = Engine.GetBindDatabaseForTesting();

	UClass* ActorClass = AActor::StaticClass();
	UScriptStruct* HitResultStruct = TBaseStructure<FHitResult>::Get();
	UEnum* CollisionEnum = StaticEnum<ECollisionChannel>();
	UDelegateFunction* DelegateFunction = GetSampleDelegateFunction();
	if (!TestNotNull(TEXT("BindDatabase.ClearPurgesEnumsDelegatesAndHeaderLinks should resolve AActor"), ActorClass) ||
		!TestNotNull(TEXT("BindDatabase.ClearPurgesEnumsDelegatesAndHeaderLinks should resolve FHitResult"), HitResultStruct) ||
		!TestNotNull(TEXT("BindDatabase.ClearPurgesEnumsDelegatesAndHeaderLinks should resolve ECollisionChannel"), CollisionEnum) ||
		!TestNotNull(TEXT("BindDatabase.ClearPurgesEnumsDelegatesAndHeaderLinks should resolve a sample delegate signature"), DelegateFunction))
	{
		return false;
	}

	ON_SCOPE_EXIT
	{
		Database.Clear();
	};

	Database.Clear();
	Database.Classes.Add(MakeSampleClassBind(ActorClass));
	Database.Structs.Add(MakeSampleStructBind(HitResultStruct));
	Database.HeaderLinks.Add(ActorClass, TEXT("Dummy/ActorHeader.h"));
	Database.BoundEnums.Add(CollisionEnum);
	Database.BoundDelegateFunctions.Add(DelegateFunction);

	if (!TestEqual(TEXT("BindDatabase.ClearPurgesEnumsDelegatesAndHeaderLinks should stage one class bind before Clear"), Database.Classes.Num(), 1) ||
		!TestEqual(TEXT("BindDatabase.ClearPurgesEnumsDelegatesAndHeaderLinks should stage one struct bind before Clear"), Database.Structs.Num(), 1) ||
		!TestEqual(TEXT("BindDatabase.ClearPurgesEnumsDelegatesAndHeaderLinks should stage one header link before Clear"), Database.HeaderLinks.Num(), 1) ||
		!TestEqual(TEXT("BindDatabase.ClearPurgesEnumsDelegatesAndHeaderLinks should stage one enum before Clear"), Database.BoundEnums.Num(), 1) ||
		!TestEqual(TEXT("BindDatabase.ClearPurgesEnumsDelegatesAndHeaderLinks should stage one delegate before Clear"), Database.BoundDelegateFunctions.Num(), 1))
	{
		return false;
	}

	Database.Clear();

	bool bOk = true;
	bOk &= TestEqual(TEXT("BindDatabase.ClearPurgesEnumsDelegatesAndHeaderLinks should clear class binds"), Database.Classes.Num(), 0);
	bOk &= TestEqual(TEXT("BindDatabase.ClearPurgesEnumsDelegatesAndHeaderLinks should clear struct binds"), Database.Structs.Num(), 0);
	bOk &= TestEqual(TEXT("BindDatabase.ClearPurgesEnumsDelegatesAndHeaderLinks should clear header links"), Database.HeaderLinks.Num(), 0);
	bOk &= TestEqual(TEXT("BindDatabase.ClearPurgesEnumsDelegatesAndHeaderLinks should clear bound enums"), Database.BoundEnums.Num(), 0);
	bOk &= TestEqual(TEXT("BindDatabase.ClearPurgesEnumsDelegatesAndHeaderLinks should clear bound delegate functions"), Database.BoundDelegateFunctions.Num(), 0);
	return bOk;
}

#endif
