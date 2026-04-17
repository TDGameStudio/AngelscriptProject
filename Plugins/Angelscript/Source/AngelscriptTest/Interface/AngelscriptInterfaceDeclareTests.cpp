#include "Shared/AngelscriptScenarioTestUtils.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"
#include "UObject/FieldIterator.h"

// Test Layer: UE Scenario
#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptScenarioTestUtils;

namespace AngelscriptTest_Interface_AngelscriptInterfaceDeclareTests_Private
{
	int32 CountDeclaredInterfaceFunctions(const UClass* InterfaceClass)
	{
		int32 FunctionCount = 0;
		for (TFieldIterator<UFunction> FuncIt(InterfaceClass, EFieldIteratorFlags::ExcludeSuper); FuncIt; ++FuncIt)
		{
			UFunction* Function = *FuncIt;
			if (Function != nullptr && Function->GetOuter() != UInterface::StaticClass())
			{
				++FunctionCount;
			}
		}

		return FunctionCount;
	}

	UFunction* FindDeclaredInterfaceFunction(UClass* InterfaceClass, FName FunctionName)
	{
		if (InterfaceClass == nullptr)
		{
			return nullptr;
		}

		for (TFieldIterator<UFunction> FuncIt(InterfaceClass, EFieldIteratorFlags::ExcludeSuper); FuncIt; ++FuncIt)
		{
			UFunction* Function = *FuncIt;
			if (Function != nullptr
				&& Function->GetOuter() == InterfaceClass
				&& Function->GetFName() == FunctionName)
			{
				return Function;
			}
		}

		return nullptr;
	}

	TArray<FProperty*> GetOrderedInputParameters(UFunction* Function)
	{
		TArray<FProperty*> Parameters;
		if (Function == nullptr)
		{
			return Parameters;
		}

		for (TFieldIterator<FProperty> It(Function); It; ++It)
		{
			FProperty* Property = *It;
			if (Property != nullptr && Property->HasAnyPropertyFlags(CPF_Parm) && !Property->HasAnyPropertyFlags(CPF_ReturnParm))
			{
				Parameters.Add(Property);
			}
		}

		Parameters.Sort([](const FProperty& Left, const FProperty& Right)
		{
			return Left.GetOffset_ForUFunction() < Right.GetOffset_ForUFunction();
		});

		return Parameters;
	}

	FString DescribeFunctionShape(const UFunction* Function)
	{
		if (Function == nullptr)
		{
			return TEXT("<null>");
		}

		TArray<FString> ChildPropertyDescriptions;
		int32 VisitedFields = 0;
		for (FField* Field = Function->ChildProperties; Field != nullptr; Field = Field->Next)
		{
			if (VisitedFields++ >= 32)
			{
				ChildPropertyDescriptions.Add(TEXT("<truncated>"));
				break;
			}

			if (FProperty* Property = CastField<FProperty>(Field))
			{
				ChildPropertyDescriptions.Add(FString::Printf(
					TEXT("%s:%s:Parm=%d:Return=%d:Out=%d"),
					*Property->GetName(),
					*Property->GetClass()->GetName(),
					Property->HasAnyPropertyFlags(CPF_Parm),
					Property->HasAnyPropertyFlags(CPF_ReturnParm),
					Property->HasAnyPropertyFlags(CPF_OutParm)));
			}
			else
			{
				ChildPropertyDescriptions.Add(FString::Printf(TEXT("<non-property:%s>"), *Field->GetClass()->GetName()));
			}
		}

		return FString::Printf(
			TEXT("Name=%s Outer=%s NumParms=%d ParmsSize=%d ReturnValueOffset=%d ChildProperties=[%s]"),
			*Function->GetName(),
			Function->GetOuter() != nullptr ? *Function->GetOuter()->GetName() : TEXT("<null>"),
			Function->NumParms,
			Function->ParmsSize,
			static_cast<int32>(Function->ReturnValueOffset),
			ChildPropertyDescriptions.Num() > 0 ? *FString::Join(ChildPropertyDescriptions, TEXT(", ")) : TEXT("<empty>"));
	}
}

using namespace AngelscriptTest_Interface_AngelscriptInterfaceDeclareTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioInterfaceDeclareBasicTest,
	"Angelscript.TestModule.Interface.DeclareBasic",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioInterfaceDeclareBasicGeneratedUFunctionShapeTest,
	"Angelscript.TestModule.Interface.DeclareBasic.GeneratedUFunctionShape",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioInterfaceDeclareInheritanceTest,
	"Angelscript.TestModule.Interface.DeclareInheritance",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScenarioInterfaceDeclareInheritanceMetadataVisibilityTest,
	"Angelscript.TestModule.Interface.DeclareInheritance.ParentMetadataVisibility",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptScenarioInterfaceDeclareBasicTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioInterfaceDeclareBasic"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* InterfaceClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioInterfaceDeclareBasic.as"),
		TEXT(R"AS(
UINTERFACE()
interface UIDamageable
{
	void TakeDamage(float Amount);
}
)AS"),
		TEXT("UIDamageable"));

	TestNotNull(TEXT("Interface class UIDamageable should be generated"), InterfaceClass);
	if (InterfaceClass != nullptr)
	{
		TestTrue(TEXT("Interface class should have CLASS_Interface flag"), InterfaceClass->HasAnyClassFlags(CLASS_Interface));
	}
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptScenarioInterfaceDeclareBasicGeneratedUFunctionShapeTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	bool bHasIntReturnProperty = false;
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioInterfaceDeclareBasicGeneratedUFunctionShape"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* InterfaceClass = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioInterfaceDeclareBasicGeneratedUFunctionShape.as"),
		TEXT(R"AS(
UINTERFACE()
interface UIDamageableReflection
{
	void TakeDamage(float Amount);
	int GetPriority() const;
}
)AS"),
		TEXT("UIDamageableReflection"));
	if (InterfaceClass == nullptr)
	{
		return false;
	}

	UFunction* TakeDamageFunction = FindDeclaredInterfaceFunction(InterfaceClass, TEXT("TakeDamage"));
	UFunction* GetPriorityFunction = FindDeclaredInterfaceFunction(InterfaceClass, TEXT("GetPriority"));
	UFunction* MappedTakeDamageFunction = FindGeneratedFunction(InterfaceClass, TEXT("TakeDamage"));
	UFunction* MappedGetPriorityFunction = FindGeneratedFunction(InterfaceClass, TEXT("GetPriority"));

	if (MappedTakeDamageFunction != TakeDamageFunction)
	{
		AddInfo(FString::Printf(
			TEXT("Interface.DeclareBasic.GeneratedUFunctionShape TakeDamage lookup mismatch. Direct=[%s] Mapped=[%s]"),
			*DescribeFunctionShape(TakeDamageFunction),
			*DescribeFunctionShape(MappedTakeDamageFunction)));
	}

	if (MappedGetPriorityFunction != GetPriorityFunction)
	{
		AddInfo(FString::Printf(
			TEXT("Interface.DeclareBasic.GeneratedUFunctionShape GetPriority lookup mismatch. Direct=[%s] Mapped=[%s]"),
			*DescribeFunctionShape(GetPriorityFunction),
			*DescribeFunctionShape(MappedGetPriorityFunction)));
	}
	if (!TestTrue(TEXT("Interface.DeclareBasic.GeneratedUFunctionShape should keep the CLASS_Interface flag"), InterfaceClass->HasAnyClassFlags(CLASS_Interface))
		|| !TestEqual(TEXT("Interface.DeclareBasic.GeneratedUFunctionShape should declare both reflected interface methods"), CountDeclaredInterfaceFunctions(InterfaceClass), 2)
		|| !TestNotNull(TEXT("Interface.DeclareBasic.GeneratedUFunctionShape should materialize the TakeDamage function"), TakeDamageFunction)
		|| !TestNotNull(TEXT("Interface.DeclareBasic.GeneratedUFunctionShape should materialize the GetPriority function"), GetPriorityFunction))
	{
		return false;
	}

	const TArray<FProperty*> TakeDamageParameters = GetOrderedInputParameters(TakeDamageFunction);
	if (!TestEqual(TEXT("Interface.DeclareBasic.GeneratedUFunctionShape should expose one input parameter on TakeDamage"), TakeDamageParameters.Num(), 1))
	{
		AddInfo(FString::Printf(
			TEXT("Interface.DeclareBasic.GeneratedUFunctionShape TakeDamage diagnostics: %s"),
			*DescribeFunctionShape(TakeDamageFunction)));
		return false;
	}
	if (!TestEqual(TEXT("Interface.DeclareBasic.GeneratedUFunctionShape should preserve the TakeDamage parameter name"), TakeDamageParameters[0]->GetFName(), FName(TEXT("Amount")))
		|| !TestNotNull(TEXT("Interface.DeclareBasic.GeneratedUFunctionShape should materialize Amount as FFloatProperty"), CastField<FFloatProperty>(TakeDamageParameters[0]))
		|| !TestNull(TEXT("Interface.DeclareBasic.GeneratedUFunctionShape should not materialize a return property for void TakeDamage"), TakeDamageFunction->GetReturnProperty()))
	{
		return false;
	}

	const TArray<FProperty*> GetPriorityParameters = GetOrderedInputParameters(GetPriorityFunction);
	if (!TestEqual(TEXT("Interface.DeclareBasic.GeneratedUFunctionShape should not expose any input parameters on GetPriority"), GetPriorityParameters.Num(), 0))
	{
		AddInfo(FString::Printf(
			TEXT("Interface.DeclareBasic.GeneratedUFunctionShape GetPriority diagnostics: %s"),
			*DescribeFunctionShape(GetPriorityFunction)));
		return false;
	}

	FProperty* GetPriorityReturnProperty = GetPriorityFunction->GetReturnProperty();
	if (!TestNotNull(TEXT("Interface.DeclareBasic.GeneratedUFunctionShape should materialize a return property for GetPriority"), GetPriorityReturnProperty))
	{
		AddInfo(FString::Printf(
			TEXT("Interface.DeclareBasic.GeneratedUFunctionShape GetPriority return diagnostics: %s"),
			*DescribeFunctionShape(GetPriorityFunction)));
		return false;
	}

	bHasIntReturnProperty = TestNotNull(
		TEXT("Interface.DeclareBasic.GeneratedUFunctionShape should materialize GetPriority return as FIntProperty"),
		CastField<FIntProperty>(GetPriorityReturnProperty));

	ASTEST_END_SHARE_CLEAN
	return bHasIntReturnProperty;
}

bool FAngelscriptScenarioInterfaceDeclareInheritanceTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioInterfaceDeclareInheritance"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ChildInterface = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioInterfaceDeclareInheritance.as"),
		TEXT(R"AS(
UINTERFACE()
interface UIDamageableInh
{
	void TakeDamage(float Amount);
}

UINTERFACE()
interface UIKillableInh : UIDamageableInh
{
	void Kill();
}
)AS"),
		TEXT("UIKillableInh"));

	TestNotNull(TEXT("Child interface class UIKillableInh should be generated"), ChildInterface);
	if (ChildInterface != nullptr)
	{
		TestTrue(TEXT("Child interface should have CLASS_Interface flag"), ChildInterface->HasAnyClassFlags(CLASS_Interface));
	}
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptScenarioInterfaceDeclareInheritanceMetadataVisibilityTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	static const FName ModuleName(TEXT("ScenarioInterfaceDeclareInheritanceMetadataVisibility"));
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(*ModuleName.ToString());
		ResetSharedCloneEngine(Engine);
	};

	UClass* ChildInterface = CompileScriptModule(
		*this,
		Engine,
		ModuleName,
		TEXT("ScenarioInterfaceDeclareInheritanceMetadataVisibility.as"),
		TEXT(R"AS(
UINTERFACE()
interface UIDamageableInh
{
	void TakeDamage(float Amount);
}

UINTERFACE()
interface UIKillableInh : UIDamageableInh
{
	void Kill();
}
)AS"),
		TEXT("UIKillableInh"));
	UClass* ParentInterface = FindGeneratedClass(&Engine, TEXT("UIDamageableInh"));

	if (!TestNotNull(TEXT("Parent interface UIDamageableInh should be generated"), ParentInterface)
		|| !TestNotNull(TEXT("Child interface UIKillableInh should be generated"), ChildInterface))
	{
		return false;
	}

	UFunction* TakeDamageFunction = ChildInterface->FindFunctionByName(TEXT("TakeDamage"));
	UFunction* KillFunction = ChildInterface->FindFunctionByName(TEXT("Kill"));

	TestTrue(TEXT("Child interface should keep the CLASS_Interface flag"), ChildInterface->HasAnyClassFlags(CLASS_Interface));
	TestTrue(TEXT("Child interface should preserve its direct parent interface link"), ChildInterface->GetSuperClass() == ParentInterface);
	TestNotNull(TEXT("Child interface should expose inherited parent methods through reflection"), TakeDamageFunction);
	TestNotNull(TEXT("Child interface should expose its own declared Kill method"), KillFunction);
	if (TakeDamageFunction != nullptr)
	{
		TestTrue(
			TEXT("Inherited TakeDamage metadata should still belong to the parent interface"),
			TakeDamageFunction->GetOuter() == ParentInterface);
	}
	if (KillFunction != nullptr)
	{
		TestTrue(
			TEXT("Direct Kill metadata should continue to belong to the child interface"),
			KillFunction->GetOuter() == ChildInterface);
	}
	TestEqual(
		TEXT("Child interface should still declare exactly one direct method of its own"),
		CountDeclaredInterfaceFunctions(ChildInterface),
		1);

	ASTEST_END_SHARE_CLEAN

	return true;
}

#endif
