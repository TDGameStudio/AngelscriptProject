#include "AngelscriptBindString.h"

#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Core_AngelscriptBindStringTests_Private
{
	bool ExpectBindStringState(
		FAutomationTestBase& Test,
		const TCHAR* Context,
		const FBindString& BindString,
		const bool bExpectedEmpty,
		const TCHAR* ExpectedUnreal,
		const ANSICHAR* ExpectedAnsi)
	{
		bool bOk = true;
		bOk &= Test.TestEqual(
			*FString::Printf(TEXT("%s should report the expected empty state"), Context),
			BindString.IsEmpty(),
			bExpectedEmpty);
		bOk &= Test.TestEqual(
			*FString::Printf(TEXT("%s should round-trip to FString"), Context),
			BindString.ToFString(),
			FString(ExpectedUnreal));
		bOk &= Test.TestEqual(
			*FString::Printf(TEXT("%s should round-trip to ANSI text"), Context),
			FString(ANSI_TO_TCHAR(BindString.ToCString())),
			FString(ExpectedUnreal));
		bOk &= Test.TestEqual(
			*FString::Printf(TEXT("%s should preserve the expected ANSI payload"), Context),
			FCStringAnsi::Strcmp(BindString.ToCString(), ExpectedAnsi),
			0);
		return bOk;
	}
}

using namespace AngelscriptTest_Core_AngelscriptBindStringTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptBindStringRoundTripTest,
	"Angelscript.TestModule.Engine.BindString.EmptyAndRoundTripAcrossConstantDynamicAndUnrealSources",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptBindStringRoundTripTest::RunTest(const FString& Parameters)
{
	FBindString ConstantEmpty("");
	if (!ExpectBindStringState(*this, TEXT("BindString constant empty"), ConstantEmpty, true, TEXT(""), ""))
	{
		return false;
	}

	if (!TestEqual(
			TEXT("BindString constant empty should expose the same constant ANSI pointer content"),
			FCStringAnsi::Strcmp(ConstantEmpty.ToCString_EnsureConstant(), ""),
			0))
	{
		return false;
	}

	FBindString ConstantValue("Constant::Value");
	if (!ExpectBindStringState(*this, TEXT("BindString constant value"), ConstantValue, false, TEXT("Constant::Value"), "Constant::Value"))
	{
		return false;
	}

	if (!TestEqual(
			TEXT("BindString constant value should keep the constant ANSI source available"),
			FCStringAnsi::Strcmp(ConstantValue.ToCString_EnsureConstant(), "Constant::Value"),
			0))
	{
		return false;
	}

	FBindString UnrealEmpty{ FString() };
	if (!ExpectBindStringState(*this, TEXT("BindString FString empty"), UnrealEmpty, true, TEXT(""), ""))
	{
		return false;
	}

	FBindString UnrealValue{ FString(TEXT("UnrealValue")) };
	if (!ExpectBindStringState(*this, TEXT("BindString FString value"), UnrealValue, false, TEXT("UnrealValue"), "UnrealValue"))
	{
		return false;
	}

	FBindString DynamicValue;
	DynamicValue.SetDynamic("");
	if (!ExpectBindStringState(*this, TEXT("BindString dynamic empty"), DynamicValue, true, TEXT(""), ""))
	{
		return false;
	}

	DynamicValue.SetDynamic("Namespace::Value");
	if (!ExpectBindStringState(*this, TEXT("BindString dynamic value"), DynamicValue, false, TEXT("Namespace::Value"), "Namespace::Value"))
	{
		return false;
	}

	FBindString SwappedValue("Before");
	if (!ExpectBindStringState(*this, TEXT("BindString swapped initial constant"), SwappedValue, false, TEXT("Before"), "Before"))
	{
		return false;
	}

	SwappedValue.SetDynamic("DynamicAfterConstant");
	if (!ExpectBindStringState(*this, TEXT("BindString swapped dynamic"), SwappedValue, false, TEXT("DynamicAfterConstant"), "DynamicAfterConstant"))
	{
		return false;
	}

	SwappedValue = FString(TEXT("FinalUnreal"));
	return ExpectBindStringState(*this, TEXT("BindString swapped FString"), SwappedValue, false, TEXT("FinalUnreal"), "FinalUnreal");
}

#endif
