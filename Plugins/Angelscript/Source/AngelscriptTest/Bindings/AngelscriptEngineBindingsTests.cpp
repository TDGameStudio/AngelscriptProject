#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"

#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptCoreValueBindingsTest,
	"Angelscript.TestModule.Bindings.ValueTypes",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptFNameArrayCompatBindingsTest,
	"Angelscript.TestModule.Bindings.FNameArrayCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptFNameArrayIndexWriteBackCompatBindingsTest,
	"Angelscript.TestModule.Bindings.FNameArrayIndexWriteBackCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptForeachCompatBindingsTest,
	"Angelscript.TestModule.Bindings.ForeachCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptCoreValueBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
	ASTEST_BEGIN_SHARE
	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASBindingValueTypes",
		TEXT(R"(
int Entry()
{
	int32 Count = 5;
	double Precise = 1.5;
	FString Text = "Alpha";
	FName Name(Text);
	FVector Vector = FVector(1.0, 2.0, 3.0) + FVector::OneVector;
	FRotator FacingRotation = FVector::RightVector.Rotation();
	FTransform Transform = FTransform(FRotator::ZeroRotator, FVector(10.0, 0.0, 0.0), FVector::OneVector);
	FVector Transformed = Transform.TransformPosition(FVector::ForwardVector);
	FText Label = FText::FromString("Alpha");

	if (Count != 5 || Precise < 1.49 || Precise > 1.51)
		return 10;
	if (!(Name == FName("Alpha")))
		return 20;
	if (!Vector.Equals(FVector(2.0, 3.0, 4.0)))
		return 30;
	if (!FacingRotation.Equals(FRotator(0.0, 90.0, 0.0), 0.01))
		return 40;
	if (!Transformed.Equals(FVector(11.0, 0.0, 0.0)))
		return 50;
	if (Label.IsEmpty() || !(Label.ToString() == "Alpha"))
		return 60;

	return 1;
}
)"));
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}

	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}

	TestEqual(TEXT("Bound UE value types should behave as expected in script"), Result, 1);
	ASTEST_END_SHARE

	return true;
}

bool FAngelscriptFNameArrayCompatBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
	ASTEST_BEGIN_SHARE
	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASFNameArrayCompat",
		TEXT(R"(
struct FFNameMemberHolder
{
	UObject NativeSelf;
	FName Value;
}

int Entry()
{
	FName[] AliasValues;
	AliasValues.Add(n"Alpha");
	TArray<FName> ExplicitValues;
	ExplicitValues.Add(n"Beta");
	FName Copy = AliasValues[0];
	FFNameMemberHolder Holder;

	AliasValues.Add(n"Gamma");
	ExplicitValues.Add(Copy);
	Holder.Value = n"Delta";

	if (AliasValues.Num() != 2)
		return 10;
	if (ExplicitValues.Num() != 2)
		return 20;
	if (!(Copy == n"Alpha"))
		return 30;
	if (!(AliasValues[1] == n"Gamma"))
		return 40;
	if (!(ExplicitValues[0] == n"Beta"))
		return 50;
	if (!(ExplicitValues[1] == n"Alpha"))
		return 60;
	if (!(Holder.Value == n"Delta"))
		return 80;

	return AliasValues.Contains(n"Alpha") && ExplicitValues.Contains(n"Alpha") ? 1 : 70;
}
)"));
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}

	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}

	TestEqual(TEXT("FName arrays should support copy, index, alias, and add operations"), Result, 1);
	ASTEST_END_SHARE

	return true;
}

bool FAngelscriptFNameArrayIndexWriteBackCompatBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
	ASTEST_BEGIN_SHARE
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASFNameArrayIndexWriteBackCompat"));
	};

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASFNameArrayIndexWriteBackCompat",
		TEXT(R"(
int Entry()
{
	FName[] AliasValues;
	AliasValues.Add(n"Alpha");
	AliasValues.Add(n"Beta");

	TArray<FName> ExplicitValues;
	ExplicitValues.Add(n"Gamma");

	FName Copy = AliasValues[0];

	AliasValues[0] = n"Omega";
	ExplicitValues[0] = n"Sigma";

	if (!(Copy == n"Alpha"))
		return 10;
	if (AliasValues.Num() != 2)
		return 20;
	if (ExplicitValues.Num() != 1)
		return 30;
	if (!(AliasValues[0] == n"Omega"))
		return 40;
	if (!(AliasValues[1] == n"Beta"))
		return 50;
	if (!(ExplicitValues[0] == n"Sigma"))
		return 60;
	if (!AliasValues.Contains(n"Omega") || AliasValues.Contains(n"Alpha"))
		return 70;
	if (!ExplicitValues.Contains(n"Sigma") || ExplicitValues.Contains(n"Gamma"))
		return 80;

	return 1;
}
)"));
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}

	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}

	TestEqual(TEXT("FName arrays should write back through opIndex without aliasing copied values"), Result, 1);
	ASTEST_END_SHARE

	return true;
}

bool FAngelscriptForeachCompatBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
	ASTEST_BEGIN_SHARE
	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASForeachCompat",
		TEXT(R"(
int Entry()
{
	int[] AliasValues;
	AliasValues.Add(1);
	AliasValues.Add(2);
	AliasValues.Add(3);
	TArray<FName> ExplicitNames;
	ExplicitNames.Add(n"Alpha");
	ExplicitNames.Add(n"Beta");
	TArray<FVector> ExplicitVectors;
	ExplicitVectors.Add(FVector(1.0, 2.0, 3.0));
	ExplicitVectors.Add(FVector(4.0, 5.0, 6.0));
	int SumForeach = 0;
	int SumCompat = 0;
	int NameCount = 0;
	double VectorXSum = 0.0;

	for (int Value : AliasValues)
	{
		SumForeach += Value;
	}

	for (int Value : AliasValues)
	{
		SumCompat += Value;
	}

	for (FName Name : ExplicitNames)
	{
		if (Name == n"Alpha" || Name == n"Beta")
			NameCount += 1;
	}

	for (const FVector& VectorValue : ExplicitVectors)
	{
		VectorXSum += VectorValue.X;
	}

	AliasValues[1] = 5;

	int MutatedTotal = 0;
	for (int Value : AliasValues)
	{
		MutatedTotal += Value;
	}

	if (SumForeach != 6)
		return 10;
	if (SumCompat != 6)
		return 20;
	if (NameCount != 2)
		return 30;
	if (VectorXSum < 4.99 || VectorXSum > 5.01)
		return 35;

	return MutatedTotal == 9 ? 1 : 40;
}
)"));
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* Function = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (Function == nullptr)
	{
		return false;
	}

	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}

	TestEqual(TEXT("TArray should support foreach and range-for compatibility syntax"), Result, 1);
	ASTEST_END_SHARE

	return true;
}

#endif
