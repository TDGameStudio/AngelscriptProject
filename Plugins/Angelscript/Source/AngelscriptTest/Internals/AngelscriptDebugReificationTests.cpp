#include "../../AngelscriptRuntime/Core/Helper_Reification.h"

#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Internals_AngelscriptDebugReificationTests_Private
{
	bool ExpectReifyType(
		FAutomationTestBase& Test,
		const TCHAR* Context,
		const int32 ActualType,
		const EReifiedType ExpectedType)
	{
		return Test.TestEqual(
			Context,
			ActualType,
			static_cast<int32>(ExpectedType));
	}
}

using namespace AngelscriptTest_Internals_AngelscriptDebugReificationTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDebugReificationTypeMapAndFallbackTest,
	"Angelscript.TestModule.Internals.DebugReification.TypeMapAndFallback",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDebugReificationTypeMapAndFallbackTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;

	const int32 Int32Type = GetReifyType<int32>();
	const int32 DoubleType = GetReifyType<double>();
	const int32 NameType = GetReifyType<FName>();
	const int32 ObjectType = GetReifyType<UObject*>();
	const int32 UnknownType = GetReifyType<FIntPoint>();

	bPassed &= ExpectReifyType(
		*this,
		TEXT("Debug reification should keep an unregistered type in the Unknown bucket"),
		UnknownType,
		EReifiedType::Unknown);

#if WITH_AS_DEBUGVALUES
	bPassed &= ExpectReifyType(
		*this,
		TEXT("Debug reification should map int32 to the int32 debugger type"),
		Int32Type,
		EReifiedType::_Enum_int32);
	bPassed &= ExpectReifyType(
		*this,
		TEXT("Debug reification should map double to the double debugger type"),
		DoubleType,
		EReifiedType::_Enum_double);
	bPassed &= ExpectReifyType(
		*this,
		TEXT("Debug reification should map FName to the FName debugger type"),
		NameType,
		EReifiedType::_Enum_FName);
	bPassed &= ExpectReifyType(
		*this,
		TEXT("Debug reification should map UObject* to the UObject debugger type"),
		ObjectType,
		EReifiedType::_Enum_UObject);
	bPassed &= TestNotEqual(
		TEXT("Debug reification should keep int32 and double on distinct debugger types"),
		Int32Type,
		DoubleType);
	bPassed &= TestNotEqual(
		TEXT("Debug reification should keep FName and UObject* on distinct debugger types"),
		NameType,
		ObjectType);
#else
	bPassed &= ExpectReifyType(
		*this,
		TEXT("Debug reification fallback should collapse int32 to Unknown"),
		Int32Type,
		EReifiedType::Unknown);
	bPassed &= ExpectReifyType(
		*this,
		TEXT("Debug reification fallback should collapse double to Unknown"),
		DoubleType,
		EReifiedType::Unknown);
	bPassed &= ExpectReifyType(
		*this,
		TEXT("Debug reification fallback should collapse FName to Unknown"),
		NameType,
		EReifiedType::Unknown);
	bPassed &= ExpectReifyType(
		*this,
		TEXT("Debug reification fallback should collapse UObject* to Unknown"),
		ObjectType,
		EReifiedType::Unknown);
#endif

	return bPassed;
}

#endif
