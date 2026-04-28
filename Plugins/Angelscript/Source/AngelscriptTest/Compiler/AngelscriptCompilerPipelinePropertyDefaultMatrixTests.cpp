#include "../Shared/AngelscriptTestEngineHelper.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "GameFramework/Actor.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/UnrealType.h"
#include "GameplayTagContainer.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

namespace DefaultMatrixTest
{
	static const FName FNameModule(TEXT("Tests.Compiler.DefaultFNameProperty"));
	static const FName EnumModule(TEXT("Tests.Compiler.DefaultEnumProperty"));
	static const FName FloatBoolModule(TEXT("Tests.Compiler.DefaultFloatBoolProperty"));
	static const FName VectorModule(TEXT("Tests.Compiler.DefaultFVectorProperty"));
	static const FName StringModule(TEXT("Tests.Compiler.DefaultFStringProperty"));
	static const FName TagsAddModule(TEXT("Tests.Compiler.DefaultTagsAddExecuted"));
	static const FName SubobjectModule(TEXT("Tests.Compiler.DefaultSubobjectPath"));
	static const FName PriorityModule(TEXT("Tests.Compiler.DefaultOverridesPriority"));
	static const FName NonExistentModule(TEXT("Tests.Compiler.DefaultNonExistentProperty"));
	static const FName OutsideScopeModule(TEXT("Tests.Compiler.DefaultOutsideClassScope"));
	static const FName TypeMismatchModule(TEXT("Tests.Compiler.DefaultTypeMismatch"));
}

// ============================================================================
// Positive: FName default
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDefaultFNamePropertyTest,
	"Angelscript.TestModule.Compiler.EndToEnd.DefaultFNamePropertyApplied",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDefaultFNamePropertyTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*DefaultMatrixTest::FNameModule.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::Error;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		DefaultMatrixTest::FNameModule,
		TEXT("Tests/Compiler/DefaultFNameProperty.as"),
		TEXT(R"AS(
UCLASS()
class UDefaultFNameCarrier : UObject
{
	UPROPERTY()
	FName MyName;

	default MyName = n"TestName";
}
)AS"),
		CompileResult);

	if (!TestTrue(TEXT("FName default should compile successfully"), bCompiled))
		return false;

	UClass* GeneratedClass = FindGeneratedClass(&Engine, TEXT("UDefaultFNameCarrier"));
	if (!TestNotNull(TEXT("FName default class should be materialized"), GeneratedClass))
		return false;

	UObject* CDO = GeneratedClass->GetDefaultObject();
	FNameProperty* Prop = FindFProperty<FNameProperty>(GeneratedClass, TEXT("MyName"));
	if (!TestNotNull(TEXT("CDO should exist"), CDO) || !TestNotNull(TEXT("MyName property should exist"), Prop))
		return false;

	FName Value = Prop->GetPropertyValue_InContainer(CDO);
	TestEqual(TEXT("CDO MyName should be TestName"), Value, FName(TEXT("TestName")));

	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// Positive: Enum default
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDefaultEnumPropertyTest,
	"Angelscript.TestModule.Compiler.EndToEnd.DefaultEnumPropertyApplied",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDefaultEnumPropertyTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*DefaultMatrixTest::EnumModule.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::Error;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		DefaultMatrixTest::EnumModule,
		TEXT("Tests/Compiler/DefaultEnumProperty.as"),
		TEXT(R"AS(
enum ETestDirection
{
	Up,
	Down,
	Left,
	Right
}

UCLASS()
class UDefaultEnumCarrier : UObject
{
	UPROPERTY()
	ETestDirection Direction;

	default Direction = ETestDirection::Right;

	UFUNCTION()
	int GetDirectionValue()
	{
		return int(Direction);
	}
}
)AS"),
		CompileResult);

	if (!TestTrue(TEXT("Enum default should compile successfully"), bCompiled))
		return false;

	UClass* GeneratedClass = FindGeneratedClass(&Engine, TEXT("UDefaultEnumCarrier"));
	if (!TestNotNull(TEXT("Enum default class should be materialized"), GeneratedClass))
		return false;

	UObject* Instance = NewObject<UObject>(GetTransientPackage(), GeneratedClass);
	UFunction* GetFunc = GeneratedClass->FindFunctionByName(TEXT("GetDirectionValue"));
	if (!TestNotNull(TEXT("Instance should exist"), Instance) || !TestNotNull(TEXT("GetDirectionValue should exist"), GetFunc))
		return false;

	int32 Result = INDEX_NONE;
	const bool bExecuted = ExecuteGeneratedIntEventOnGameThread(&Engine, Instance, GetFunc, Result);
	TestTrue(TEXT("GetDirectionValue should execute"), bExecuted);
	TestEqual(TEXT("Direction should be Right (3)"), Result, 3);

	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// Positive: Float + Bool default
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDefaultFloatBoolPropertyTest,
	"Angelscript.TestModule.Compiler.EndToEnd.DefaultFloatAndBoolPropertyApplied",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDefaultFloatBoolPropertyTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*DefaultMatrixTest::FloatBoolModule.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::Error;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		DefaultMatrixTest::FloatBoolModule,
		TEXT("Tests/Compiler/DefaultFloatBoolProperty.as"),
		TEXT(R"AS(
UCLASS()
class UDefaultFloatBoolCarrier : UObject
{
	UPROPERTY()
	float MyFloat;

	UPROPERTY()
	bool bEnabled;

	default MyFloat = 3.14f;
	default bEnabled = true;

	UFUNCTION()
	int VerifyDefaults()
	{
		if (MyFloat < 3.13f || MyFloat > 3.15f)
			return 1;
		if (!bEnabled)
			return 2;
		return 42;
	}
}
)AS"),
		CompileResult);

	if (!TestTrue(TEXT("Float+Bool default should compile"), bCompiled))
		return false;

	UClass* GeneratedClass = FindGeneratedClass(&Engine, TEXT("UDefaultFloatBoolCarrier"));
	if (!TestNotNull(TEXT("Class should be materialized"), GeneratedClass))
		return false;

	UObject* Instance = NewObject<UObject>(GetTransientPackage(), GeneratedClass);
	UFunction* VerifyFunc = GeneratedClass->FindFunctionByName(TEXT("VerifyDefaults"));
	if (!TestNotNull(TEXT("Instance should exist"), Instance) || !TestNotNull(TEXT("VerifyDefaults should exist"), VerifyFunc))
		return false;

	int32 Result = INDEX_NONE;
	const bool bExecuted = ExecuteGeneratedIntEventOnGameThread(&Engine, Instance, VerifyFunc, Result);
	TestTrue(TEXT("VerifyDefaults should execute"), bExecuted);
	TestEqual(TEXT("Float+Bool defaults should apply correctly"), Result, 42);

	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// Positive: FVector default
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDefaultFVectorPropertyTest,
	"Angelscript.TestModule.Compiler.EndToEnd.DefaultFVectorPropertyApplied",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDefaultFVectorPropertyTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*DefaultMatrixTest::VectorModule.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::Error;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		DefaultMatrixTest::VectorModule,
		TEXT("Tests/Compiler/DefaultFVectorProperty.as"),
		TEXT(R"AS(
UCLASS()
class UDefaultVectorCarrier : UObject
{
	UPROPERTY()
	FVector MyVector;

	default MyVector = FVector(1.0f, 2.0f, 3.0f);

	UFUNCTION()
	int VerifyVector()
	{
		if (MyVector.X < 0.9f || MyVector.X > 1.1f)
			return 1;
		if (MyVector.Y < 1.9f || MyVector.Y > 2.1f)
			return 2;
		if (MyVector.Z < 2.9f || MyVector.Z > 3.1f)
			return 3;
		return 42;
	}
}
)AS"),
		CompileResult);

	if (!TestTrue(TEXT("FVector default should compile"), bCompiled))
		return false;

	UClass* GeneratedClass = FindGeneratedClass(&Engine, TEXT("UDefaultVectorCarrier"));
	if (!TestNotNull(TEXT("Class should be materialized"), GeneratedClass))
		return false;

	UObject* Instance = NewObject<UObject>(GetTransientPackage(), GeneratedClass);
	UFunction* VerifyFunc = GeneratedClass->FindFunctionByName(TEXT("VerifyVector"));
	if (!TestNotNull(TEXT("Instance should exist"), Instance) || !TestNotNull(TEXT("VerifyVector should exist"), VerifyFunc))
		return false;

	int32 Result = INDEX_NONE;
	const bool bExecuted = ExecuteGeneratedIntEventOnGameThread(&Engine, Instance, VerifyFunc, Result);
	TestTrue(TEXT("VerifyVector should execute"), bExecuted);
	TestEqual(TEXT("FVector default should apply correctly"), Result, 42);

	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// Positive: FString default
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDefaultFStringPropertyTest,
	"Angelscript.TestModule.Compiler.EndToEnd.DefaultFStringPropertyApplied",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDefaultFStringPropertyTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*DefaultMatrixTest::StringModule.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::Error;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		DefaultMatrixTest::StringModule,
		TEXT("Tests/Compiler/DefaultFStringProperty.as"),
		TEXT(R"AS(
UCLASS()
class UDefaultStringCarrier : UObject
{
	UPROPERTY()
	FString MyString;

	default MyString = "Hello World";

	UFUNCTION()
	int VerifyString()
	{
		if (MyString != "Hello World")
			return 1;
		return 42;
	}
}
)AS"),
		CompileResult);

	if (!TestTrue(TEXT("FString default should compile"), bCompiled))
		return false;

	UClass* GeneratedClass = FindGeneratedClass(&Engine, TEXT("UDefaultStringCarrier"));
	if (!TestNotNull(TEXT("Class should be materialized"), GeneratedClass))
		return false;

	UObject* Instance = NewObject<UObject>(GetTransientPackage(), GeneratedClass);
	UFunction* VerifyFunc = GeneratedClass->FindFunctionByName(TEXT("VerifyString"));
	if (!TestNotNull(TEXT("Instance should exist"), Instance) || !TestNotNull(TEXT("VerifyString should exist"), VerifyFunc))
		return false;

	int32 Result = INDEX_NONE;
	const bool bExecuted = ExecuteGeneratedIntEventOnGameThread(&Engine, Instance, VerifyFunc, Result);
	TestTrue(TEXT("VerifyString should execute"), bExecuted);
	TestEqual(TEXT("FString default should apply correctly"), Result, 42);

	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// Positive: Tags.Add on CDO with assertion
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDefaultTagsAddExecutedTest,
	"Angelscript.TestModule.Compiler.EndToEnd.DefaultTagsAddExecutedOnCDO",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDefaultTagsAddExecutedTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*DefaultMatrixTest::TagsAddModule.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::Error;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		DefaultMatrixTest::TagsAddModule,
		TEXT("Tests/Compiler/DefaultTagsAddExecuted.as"),
		TEXT(R"AS(
UCLASS()
class ADefaultTagsActor : AActor
{
	default Tags.Add(n"Alpha");
	default Tags.Add(n"Beta");

	UFUNCTION()
	int VerifyTags()
	{
		if (!Tags.Contains(n"Alpha"))
			return 1;
		if (!Tags.Contains(n"Beta"))
			return 2;
		if (Tags.Num() < 2)
			return 3;
		return 42;
	}
}
)AS"),
		CompileResult);

	if (!TestTrue(TEXT("Tags.Add default should compile"), bCompiled))
		return false;

	UClass* GeneratedClass = FindGeneratedClass(&Engine, TEXT("ADefaultTagsActor"));
	if (!TestNotNull(TEXT("Class should be materialized"), GeneratedClass))
		return false;

	UObject* Instance = NewObject<UObject>(GetTransientPackage(), GeneratedClass);
	UFunction* VerifyFunc = GeneratedClass->FindFunctionByName(TEXT("VerifyTags"));
	if (!TestNotNull(TEXT("Instance should exist"), Instance) || !TestNotNull(TEXT("VerifyTags should exist"), VerifyFunc))
		return false;

	int32 Result = INDEX_NONE;
	const bool bExecuted = ExecuteGeneratedIntEventOnGameThread(&Engine, Instance, VerifyFunc, Result);
	TestTrue(TEXT("VerifyTags should execute"), bExecuted);
	TestEqual(TEXT("Tags.Add should actually add tags to CDO and instances"), Result, 42);

	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// Positive: Subobject path default
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDefaultSubobjectPathTest,
	"Angelscript.TestModule.Compiler.EndToEnd.DefaultSubobjectPathApplied",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDefaultSubobjectPathTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*DefaultMatrixTest::SubobjectModule.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::Error;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		DefaultMatrixTest::SubobjectModule,
		TEXT("Tests/Compiler/DefaultSubobjectPath.as"),
		TEXT(R"AS(
UCLASS()
class ADefaultSubobjectActor : AActor
{
	default PrimaryActorTick.bStartWithTickEnabled = true;
}
)AS"),
		CompileResult);

	if (!TestTrue(TEXT("Subobject path default should compile"), bCompiled))
		return false;

	UClass* GeneratedClass = FindGeneratedClass(&Engine, TEXT("ADefaultSubobjectActor"));
	if (!TestNotNull(TEXT("Class should be materialized"), GeneratedClass))
		return false;

	AActor* CDO = Cast<AActor>(GeneratedClass->GetDefaultObject());
	if (!TestNotNull(TEXT("CDO should be a valid AActor"), CDO))
		return false;

	TestTrue(TEXT("PrimaryActorTick.bStartWithTickEnabled should be true via default statement"), CDO->PrimaryActorTick.bStartWithTickEnabled);

	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// Positive: default overrides inline UPROPERTY initializer
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDefaultOverridesPriorityTest,
	"Angelscript.TestModule.Compiler.EndToEnd.DefaultOverridesInlineInitializerPriority",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDefaultOverridesPriorityTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*DefaultMatrixTest::PriorityModule.ToString());
		ResetSharedCloneEngine(Engine);
	};

	ECompileResult CompileResult = ECompileResult::Error;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		DefaultMatrixTest::PriorityModule,
		TEXT("Tests/Compiler/DefaultOverridesPriority.as"),
		TEXT(R"AS(
UCLASS()
class UDefaultPriorityCarrier : UObject
{
	UPROPERTY()
	int Score = 10;

	default Score = 20;

	UFUNCTION()
	int GetScore()
	{
		return Score;
	}
}
)AS"),
		CompileResult);

	if (!TestTrue(TEXT("Priority default should compile"), bCompiled))
		return false;

	UClass* GeneratedClass = FindGeneratedClass(&Engine, TEXT("UDefaultPriorityCarrier"));
	if (!TestNotNull(TEXT("Class should be materialized"), GeneratedClass))
		return false;

	UObject* Instance = NewObject<UObject>(GetTransientPackage(), GeneratedClass);
	UFunction* GetFunc = GeneratedClass->FindFunctionByName(TEXT("GetScore"));
	if (!TestNotNull(TEXT("Instance should exist"), Instance) || !TestNotNull(TEXT("GetScore should exist"), GetFunc))
		return false;

	int32 Result = INDEX_NONE;
	const bool bExecuted = ExecuteGeneratedIntEventOnGameThread(&Engine, Instance, GetFunc, Result);
	TestTrue(TEXT("GetScore should execute"), bExecuted);
	TestEqual(TEXT("default should override inline initializer (20 > 10)"), Result, 20);

	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// Negative: Non-existent property
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDefaultNonExistentPropertyTest,
	"Angelscript.TestModule.Compiler.EndToEnd.DefaultNonExistentPropertyFails",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDefaultNonExistentPropertyTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*DefaultMatrixTest::NonExistentModule.ToString());
		ResetSharedCloneEngine(Engine);
	};

	AddExpectedError(TEXT(""), EAutomationExpectedErrorFlags::Contains, 0);

	ECompileResult CompileResult = ECompileResult::Error;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		DefaultMatrixTest::NonExistentModule,
		TEXT("Tests/Compiler/DefaultNonExistentProperty.as"),
		TEXT(R"AS(
UCLASS()
class UDefaultNonExistentCarrier : UObject
{
	default NoSuchProperty = 1;
}
)AS"),
		CompileResult);

	TestFalse(TEXT("Non-existent property default should fail to compile"), bCompiled);

	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// Negative: default outside class scope
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDefaultOutsideClassScopeTest,
	"Angelscript.TestModule.Compiler.EndToEnd.DefaultOutsideClassScopeFails",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDefaultOutsideClassScopeTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*DefaultMatrixTest::OutsideScopeModule.ToString());
		ResetSharedCloneEngine(Engine);
	};

	AddExpectedError(TEXT(""), EAutomationExpectedErrorFlags::Contains, 0);

	ECompileResult CompileResult = ECompileResult::Error;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		DefaultMatrixTest::OutsideScopeModule,
		TEXT("Tests/Compiler/DefaultOutsideClassScope.as"),
		TEXT(R"AS(
int GlobalValue = 5;
default GlobalValue = 10;
)AS"),
		CompileResult);

	TestFalse(TEXT("default outside class scope should fail"), bCompiled);

	ASTEST_END_SHARE_CLEAN
	return true;
}

// ============================================================================
// Negative: Type mismatch
// ============================================================================

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDefaultTypeMismatchTest,
	"Angelscript.TestModule.Compiler.EndToEnd.DefaultTypeMismatchFails",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDefaultTypeMismatchTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*DefaultMatrixTest::TypeMismatchModule.ToString());
		ResetSharedCloneEngine(Engine);
	};

	AddExpectedError(TEXT(""), EAutomationExpectedErrorFlags::Contains, 0);

	ECompileResult CompileResult = ECompileResult::Error;
	const bool bCompiled = CompileModuleWithResult(
		&Engine,
		ECompileType::FullReload,
		DefaultMatrixTest::TypeMismatchModule,
		TEXT("Tests/Compiler/DefaultTypeMismatch.as"),
		TEXT(R"AS(
UCLASS()
class UDefaultTypeMismatchCarrier : UObject
{
	UPROPERTY()
	int MyInt;

	default MyInt = "not an int";
}
)AS"),
		CompileResult);

	TestFalse(TEXT("Type mismatch default should fail to compile"), bCompiled);

	ASTEST_END_SHARE_CLEAN
	return true;
}

#endif
