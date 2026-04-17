#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"
#include "../../AngelscriptRuntime/Core/AngelscriptSettings.h"
#include "../../AngelscriptRuntime/Core/AngelscriptType.h"
#include "ClassGenerator/ASClass.h"

#include "Containers/StringConv.h"
#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/GarbageCollection.h"
#include "UObject/UObjectGlobals.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace AngelscriptTest_Internals_AngelscriptDebuggerValueTests_Private
{
	asITypeInfo* FindScriptTypeInfoForClass(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		UClass* ScriptClass)
	{
		const FString BoundTypeName = FAngelscriptType::GetBoundClassName(ScriptClass);
		asITypeInfo* ScriptType = nullptr;
		if (const UASClass* ScriptASClass = Cast<UASClass>(ScriptClass))
		{
			ScriptType = static_cast<asITypeInfo*>(ScriptASClass->ScriptTypePtr);
		}

		if (ScriptType == nullptr)
		{
			const FTCHARToUTF8 BoundTypeNameUtf8(*BoundTypeName);
			ScriptType = Engine.GetScriptEngine()->GetTypeInfoByName(BoundTypeNameUtf8.Get());
		}

		Test.TestNotNull(
			*FString::Printf(TEXT("Debugger value getter tracking should resolve script type '%s'"), *BoundTypeName),
			ScriptType);
		return ScriptType;
	}

	asIScriptFunction* FindMethodByDecl(
		FAutomationTestBase& Test,
		asITypeInfo& ScriptType,
		const FString& Declaration)
	{
		const FTCHARToUTF8 DeclarationUtf8(*Declaration);
		asIScriptFunction* Function = ScriptType.GetMethodByDecl(DeclarationUtf8.Get());
		if (Function == nullptr)
		{
			FString FunctionName;
			int32 OpenParenIndex = INDEX_NONE;
			if (Declaration.FindChar(TEXT('('), OpenParenIndex))
			{
				const FString Prefix = Declaration.Left(OpenParenIndex).TrimStartAndEnd();
				int32 NameSeparatorIndex = INDEX_NONE;
				if (Prefix.FindLastChar(TEXT(' '), NameSeparatorIndex))
				{
					FunctionName = Prefix.Mid(NameSeparatorIndex + 1).TrimStartAndEnd();
				}
			}

			if (!FunctionName.IsEmpty())
			{
				const FTCHARToUTF8 FunctionNameUtf8(*FunctionName);
				Function = ScriptType.GetMethodByName(FunctionNameUtf8.Get());
			}
		}

		Test.TestNotNull(
			*FString::Printf(TEXT("Debugger value getter tracking should resolve method '%s'"), *Declaration),
			Function);
		return Function;
	}

	bool ExpectTrackedDebuggerValue(
		FAutomationTestBase& Test,
		const TCHAR* Context,
		const FDebuggerValue& DebugValue,
		const FString& ExpectedValue,
		void* ExpectedAddress)
	{
		bool bOk = true;
		bOk &= Test.TestEqual(
			*FString::Printf(TEXT("%s should stringify the getter result"), Context),
			DebugValue.Value,
			ExpectedValue);
		bOk &= Test.TestTrue(
			*FString::Printf(TEXT("%s should mark debugger output as a temporary value"), Context),
			DebugValue.bTemporaryValue);
		bOk &= Test.TestTrue(
			*FString::Printf(TEXT("%s should bind the monitored address back to the Health property"), Context),
			DebugValue.GetAddressToMonitor() == ExpectedAddress);
		bOk &= Test.TestTrue(
			*FString::Printf(TEXT("%s should preserve a concrete non-temporary or monitor address"), Context),
			DebugValue.NonTemporaryAddress == ExpectedAddress || DebugValue.AddressToMonitor == ExpectedAddress);
		bOk &= Test.TestEqual(
			*FString::Printf(TEXT("%s should report the expected monitor value size"), Context),
			DebugValue.GetAddressToMonitorValueSize(),
			static_cast<int32>(sizeof(int32)));
		return bOk;
	}

	FString BuildDebuggerFunctionPath(const asIScriptFunction& ScriptFunction)
	{
		FString FunctionPath;
		if (ScriptFunction.GetObjectType() != nullptr)
		{
			FunctionPath = ANSI_TO_TCHAR(ScriptFunction.GetObjectType()->GetName());
			FunctionPath += TEXT(".");
		}

		FunctionPath += ANSI_TO_TCHAR(ScriptFunction.GetName());
		return FunctionPath;
	}
}

using namespace AngelscriptTest_Internals_AngelscriptDebuggerValueTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerValueGetterPropertyTrackingTest,
	"Angelscript.TestModule.Internals.DebuggerValue.GetterPropertyTracking",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDebuggerValueGetterPropertyTrackingTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	static const FName ModuleName(TEXT("InternalsDebuggerValueGetterTracking"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
		CollectGarbage(RF_NoFlags, true);
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("InternalsDebuggerValueGetterTracking.as"),
		TEXT(R"AS(
UCLASS()
class ADebuggerValueGetterProbe : AActor
{
	UPROPERTY()
	int Health = 42;

	UFUNCTION()
	int GetHealth() const
	{
		return Health;
	}
}
)AS"),
		TEXT("ADebuggerValueGetterProbe"));

	if (ScriptClass == nullptr)
	{
		bPassed = false;
	}
	else
	{
		FActorTestSpawner Spawner;
		Spawner.InitializeGameSubsystems();

		AActor* Actor = SpawnScriptActor(*this, Spawner, ScriptClass);
		asITypeInfo* ScriptType = FindScriptTypeInfoForClass(*this, Engine, ScriptClass);
		asIScriptFunction* GetterFunction = ScriptType != nullptr
			? FindMethodByDecl(*this, *ScriptType, TEXT("int GetHealth() const"))
			: nullptr;
		FIntProperty* HealthProperty = FindFProperty<FIntProperty>(ScriptClass, TEXT("Health"));

		if (!TestNotNull(TEXT("Debugger value getter tracking should spawn the script actor"), Actor) ||
			!TestNotNull(TEXT("Debugger value getter tracking should expose the native Health property"), HealthProperty) ||
			!TestNotNull(TEXT("Debugger value getter tracking should keep the spawned actor inside a world"), Actor != nullptr ? Actor->GetWorld() : nullptr) ||
			!TestNotNull(TEXT("Debugger value getter tracking should resolve the script getter method"), GetterFunction))
		{
			bPassed = false;
		}
		else
		{
			void* const HealthAddress = HealthProperty->ContainerPtrToValuePtr<void>(Actor);
			int32* const HealthValue = static_cast<int32*>(HealthAddress);
			if (!TestNotNull(TEXT("Debugger value getter tracking should expose reflected Health storage"), HealthValue))
			{
				bPassed = false;
			}
			else
			{
				TestEqual(TEXT("Debugger value getter tracking should start from the default Health value"), *HealthValue, 42);

				FDebuggerValue FirstValue;
				const bool bFirstResolved = FAngelscriptType::GetDebuggerValueFromFunction(
					GetterFunction,
					Actor,
					FirstValue,
					ScriptType,
					ScriptClass,
					TEXT("Health"));
				bPassed &= TestTrue(
					TEXT("Debugger value getter tracking should evaluate the getter once before mutation"),
					bFirstResolved);
				if (bFirstResolved)
				{
					bPassed &= ExpectTrackedDebuggerValue(
						*this,
						TEXT("Debugger value getter tracking first evaluation"),
						FirstValue,
						TEXT("42"),
						HealthAddress);
				}

				*HealthValue = 99;
				TestEqual(TEXT("Debugger value getter tracking should mutate the reflected Health storage in place"), *HealthValue, 99);

				FDebuggerValue SecondValue;
				const bool bSecondResolved = FAngelscriptType::GetDebuggerValueFromFunction(
					GetterFunction,
					Actor,
					SecondValue,
					ScriptType,
					ScriptClass,
					TEXT("Health"));
				bPassed &= TestTrue(
					TEXT("Debugger value getter tracking should evaluate the getter again after mutation"),
					bSecondResolved);
				if (bSecondResolved)
				{
					bPassed &= ExpectTrackedDebuggerValue(
						*this,
						TEXT("Debugger value getter tracking second evaluation"),
						SecondValue,
						TEXT("99"),
						HealthAddress);
				}
			}
		}
	}

	ASTEST_END_SHARE_FRESH
	return bPassed;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerValueFunctionEvaluationGuardsTest,
	"Angelscript.TestModule.Internals.DebuggerValue.FunctionEvaluationGuards",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDebuggerValueFunctionEvaluationGuardsTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	static const FName ModuleName(TEXT("InternalsDebuggerValueFunctionEvaluationGuards"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
		CollectGarbage(RF_NoFlags, true);
	};

	UAngelscriptSettings& Settings = UAngelscriptSettings::Get();
	const TSet<FString> SavedBlacklist = Settings.DebuggerBlacklistAutomaticFunctionEvaluation;
	const TSet<FString> SavedWithoutWorldBlacklist = Settings.DebuggerBlacklistAutomaticFunctionEvaluationWithoutWorldContext;
	ON_SCOPE_EXIT
	{
		Settings.DebuggerBlacklistAutomaticFunctionEvaluation = SavedBlacklist;
		Settings.DebuggerBlacklistAutomaticFunctionEvaluationWithoutWorldContext = SavedWithoutWorldBlacklist;
	};

	UClass* ScriptClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("InternalsDebuggerValueFunctionEvaluationGuards.as"),
		TEXT(R"AS(
UCLASS()
class UDebuggerValueGuardProbe : UObject
{
	UPROPERTY()
	int EvalCount = 0;

	UFUNCTION()
	int GetValue()
	{
		EvalCount += 1;
		return 42;
	}

	UFUNCTION()
	int NeedsArg(int Value)
	{
		EvalCount += 100;
		return Value;
	}
}
)AS"),
		TEXT("UDebuggerValueGuardProbe"));

	if (ScriptClass == nullptr)
	{
		bPassed = false;
	}
	else
	{
		asITypeInfo* ScriptType = FindScriptTypeInfoForClass(*this, Engine, ScriptClass);
		asIScriptFunction* GetterFunction = ScriptType != nullptr
			? FindMethodByDecl(*this, *ScriptType, TEXT("int GetValue()"))
			: nullptr;
		asIScriptFunction* NeedsArgFunction = ScriptType != nullptr
			? FindMethodByDecl(*this, *ScriptType, TEXT("int NeedsArg(int)"))
			: nullptr;
		FIntProperty* EvalCountProperty = FindFProperty<FIntProperty>(ScriptClass, TEXT("EvalCount"));
		UObject* Target = NewObject<UObject>(GetTransientPackage(), ScriptClass, TEXT("DebuggerValueGuardTarget"));

		if (!TestNotNull(TEXT("Debugger value guard test should expose the EvalCount property"), EvalCountProperty) ||
			!TestNotNull(TEXT("Debugger value guard test should instantiate the generated UObject"), Target) ||
			!TestNotNull(TEXT("Debugger value guard test should resolve the generated getter method"), GetterFunction) ||
			!TestNotNull(TEXT("Debugger value guard test should resolve the generated NeedsArg method"), NeedsArgFunction))
		{
			bPassed = false;
		}
		else
		{
			bPassed &= TestTrue(
				TEXT("Debugger value guard test should keep the generated UObject worldless so the without-world blacklist path is reachable"),
				Target->GetWorld() == nullptr);

			int32* const EvalCountPtr = EvalCountProperty->ContainerPtrToValuePtr<int32>(Target);
			if (!TestNotNull(TEXT("Debugger value guard test should expose reflected EvalCount storage"), EvalCountPtr))
			{
				bPassed = false;
			}
			else
			{
				Settings.DebuggerBlacklistAutomaticFunctionEvaluation.Reset();
				Settings.DebuggerBlacklistAutomaticFunctionEvaluationWithoutWorldContext.Reset();
				Settings.DebuggerBlacklistAutomaticFunctionEvaluationWithoutWorldContext.Add(
					BuildDebuggerFunctionPath(*GetterFunction));

				FDebuggerValue WithoutWorldValue;
				bPassed &= TestFalse(
					TEXT("Debugger value guard test should reject a getter blacklisted for objects without world context"),
					FAngelscriptType::GetDebuggerValueFromFunction(
						GetterFunction,
						Target,
						WithoutWorldValue,
						ScriptType,
						ScriptClass));
				bPassed &= TestEqual(
					TEXT("Debugger value guard test should not execute the getter when the without-world blacklist matches"),
					*EvalCountPtr,
					0);

				Settings.DebuggerBlacklistAutomaticFunctionEvaluationWithoutWorldContext.Reset();
				Settings.DebuggerBlacklistAutomaticFunctionEvaluation.Add(
					BuildDebuggerFunctionPath(*GetterFunction));

				FDebuggerValue UnconditionalValue;
				bPassed &= TestFalse(
					TEXT("Debugger value guard test should reject a getter blacklisted for all debugger evaluation"),
					FAngelscriptType::GetDebuggerValueFromFunction(
						GetterFunction,
						Target,
						UnconditionalValue,
						ScriptType,
						ScriptClass));
				bPassed &= TestEqual(
					TEXT("Debugger value guard test should still leave EvalCount untouched after the unconditional blacklist guard"),
					*EvalCountPtr,
					0);

				Settings.DebuggerBlacklistAutomaticFunctionEvaluation.Reset();

				FDebuggerValue NeedsArgValue;
				bPassed &= TestFalse(
					TEXT("Debugger value guard test should reject methods whose signature still requires parameters"),
					FAngelscriptType::GetDebuggerValueFromFunction(
						NeedsArgFunction,
						Target,
						NeedsArgValue,
						ScriptType,
						ScriptClass));
				bPassed &= TestEqual(
					TEXT("Debugger value guard test should not execute the parameterized method when the signature guard rejects it"),
					*EvalCountPtr,
					0);

				FDebuggerValue GetterValue;
				const bool bGetterResolved = FAngelscriptType::GetDebuggerValueFromFunction(
					GetterFunction,
					Target,
					GetterValue,
					ScriptType,
					ScriptClass);
				bPassed &= TestTrue(
					TEXT("Debugger value guard test should evaluate the getter once all guards are removed"),
					bGetterResolved);
				if (bGetterResolved)
				{
					bPassed &= TestEqual(
						TEXT("Debugger value guard test should stringify the getter return value once evaluation is allowed"),
						GetterValue.Value,
						FString(TEXT("42")));
					bPassed &= TestTrue(
						TEXT("Debugger value guard test should report the getter result as a temporary debugger value"),
						GetterValue.bTemporaryValue);
				}

				bPassed &= TestEqual(
					TEXT("Debugger value guard test should increment EvalCount exactly once after the successful evaluation"),
					*EvalCountPtr,
					1);
			}
		}
	}

	ASTEST_END_SHARE_FRESH
	return bPassed;
}

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebuggerValueInheritedGetterTracksBasePropertyAddressTest,
	"Angelscript.TestModule.Internals.DebuggerValue.InheritedGetterTracksBasePropertyAddress",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDebuggerValueInheritedGetterTracksBasePropertyAddressTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	static const FName ModuleName(TEXT("InternalsDebuggerValueInheritedGetterTracking"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
		CollectGarbage(RF_NoFlags, true);
	};

	UClass* DerivedClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("InternalsDebuggerValueInheritedGetterTracking.as"),
		TEXT(R"AS(
UCLASS()
class ADebuggerValueBaseProbe : AActor
{
	UPROPERTY()
	int Health = 42;
}

UCLASS()
class ADebuggerValueDerivedProbe : ADebuggerValueBaseProbe
{
	UFUNCTION()
	int GetHealth() const
	{
		return Health;
	}
}
)AS"),
		TEXT("ADebuggerValueDerivedProbe"));

	if (DerivedClass == nullptr)
	{
		bPassed = false;
	}
	else
	{
		FActorTestSpawner Spawner;
		Spawner.InitializeGameSubsystems();

		AActor* Actor = SpawnScriptActor(*this, Spawner, DerivedClass);
		asITypeInfo* ScriptType = FindScriptTypeInfoForClass(*this, Engine, DerivedClass);
		asIScriptFunction* GetterFunction = ScriptType != nullptr
			? FindMethodByDecl(*this, *ScriptType, TEXT("int GetHealth() const"))
			: nullptr;
		FIntProperty* HealthProperty = FindFProperty<FIntProperty>(DerivedClass, TEXT("Health"));

		if (!TestNotNull(TEXT("Debugger value inherited getter tracking should spawn the derived script actor"), Actor) ||
			!TestNotNull(TEXT("Debugger value inherited getter tracking should expose the inherited Health property"), HealthProperty) ||
			!TestNotNull(TEXT("Debugger value inherited getter tracking should keep the spawned actor inside a world"), Actor != nullptr ? Actor->GetWorld() : nullptr) ||
			!TestNotNull(TEXT("Debugger value inherited getter tracking should resolve the derived getter method"), GetterFunction))
		{
			bPassed = false;
		}
		else
		{
			void* const HealthAddress = HealthProperty->ContainerPtrToValuePtr<void>(Actor);
			int32* const HealthValue = static_cast<int32*>(HealthAddress);
			if (!TestNotNull(TEXT("Debugger value inherited getter tracking should expose reflected Health storage"), HealthValue))
			{
				bPassed = false;
			}
			else
			{
				bPassed &= TestEqual(
					TEXT("Debugger value inherited getter tracking should start from the base-class default Health value"),
					*HealthValue,
					42);

				FDebuggerValue FirstValue;
				const bool bFirstResolved = FAngelscriptType::GetDebuggerValueFromFunction(
					GetterFunction,
					Actor,
					FirstValue,
					ScriptType,
					DerivedClass,
					TEXT("Health"));
				bPassed &= TestTrue(
					TEXT("Debugger value inherited getter tracking should evaluate the derived getter before mutation"),
					bFirstResolved);
				if (bFirstResolved)
				{
					bPassed &= ExpectTrackedDebuggerValue(
						*this,
						TEXT("Debugger value inherited getter tracking first evaluation"),
						FirstValue,
						TEXT("42"),
						HealthAddress);
				}

				*HealthValue = 99;
				bPassed &= TestEqual(
					TEXT("Debugger value inherited getter tracking should mutate the inherited Health storage in place"),
					*HealthValue,
					99);

				FDebuggerValue SecondValue;
				const bool bSecondResolved = FAngelscriptType::GetDebuggerValueFromFunction(
					GetterFunction,
					Actor,
					SecondValue,
					ScriptType,
					DerivedClass,
					TEXT("Health"));
				bPassed &= TestTrue(
					TEXT("Debugger value inherited getter tracking should evaluate the derived getter again after mutation"),
					bSecondResolved);
				if (bSecondResolved)
				{
					bPassed &= ExpectTrackedDebuggerValue(
						*this,
						TEXT("Debugger value inherited getter tracking second evaluation"),
						SecondValue,
						TEXT("99"),
						HealthAddress);
				}
			}
		}
	}

	ASTEST_END_SHARE_FRESH
	return bPassed;
}

#endif
