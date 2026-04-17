#include "Core/AngelscriptDelegateWithPayload.h"
#include "Core/AngelscriptEngine.h"
#include "Shared/AngelscriptNativeScriptTestObject.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Math/UnrealMathUtility.h"
#include "Misc/AutomationTest.h"
#include "UObject/StrongObjectPtr.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Core_AngelscriptDelegateWithPayloadTests_Private
{
	TStrongObjectPtr<UAngelscriptNativeScriptTestObject> CreateDelegateWithPayloadReceiver(FAutomationTestBase& Test)
	{
		TStrongObjectPtr<UAngelscriptNativeScriptTestObject> Receiver(
			NewObject<UAngelscriptNativeScriptTestObject>(GetTransientPackage(), TEXT("DelegateWithPayloadRuntimeReceiver")));
		if (!Test.TestNotNull(TEXT("DelegateWithPayload runtime test should create a transient receiver object"), Receiver.Get()))
		{
			return nullptr;
		}

		Receiver->bNativeFlag = false;
		Receiver->PreciseValue = -1.0;
		Receiver->LargeCount = 0;
		return Receiver;
	}

	bool ExpectClearedDelegateState(FAutomationTestBase& Test, const FAngelscriptDelegateWithPayload& Delegate)
	{
		const bool bPayloadCleared = Test.TestFalse(
			TEXT("DelegateWithPayload Reset should clear the instanced payload"),
			Delegate.Payload.IsValid());
		const bool bObjectCleared = Test.TestFalse(
			TEXT("DelegateWithPayload Reset should clear the target object weak pointer"),
			Delegate.Object.IsValid());
		const bool bFunctionCleared = Test.TestTrue(
			TEXT("DelegateWithPayload Reset should clear the bound function name"),
			Delegate.FunctionName.IsNone());
		return bPayloadCleared && bObjectCleared && bFunctionCleared;
	}

	bool ExpectBoxedFloatPayload(
		FAutomationTestBase& Test,
		const FAngelscriptDelegateWithPayload& Delegate,
		const float ExpectedValue)
	{
		if (!Test.TestTrue(
				TEXT("DelegateWithPayload float bind should store an instanced payload"),
				Delegate.Payload.IsValid()))
		{
			return false;
		}

		if (!Test.TestTrue(
				TEXT("DelegateWithPayload float bind should use the boxed-float helper struct"),
				Delegate.Payload.GetScriptStruct() == FAngelscriptBoxedFloat::StaticStruct()))
		{
			return false;
		}

		const FAngelscriptBoxedFloat* BoxedFloat = reinterpret_cast<const FAngelscriptBoxedFloat*>(Delegate.Payload.GetMemory());
		if (!Test.TestNotNull(TEXT("DelegateWithPayload float bind should expose boxed payload memory"), BoxedFloat))
		{
			return false;
		}

		return Test.TestTrue(
			TEXT("DelegateWithPayload float bind should preserve the boxed primitive value"),
			FMath::IsNearlyEqual(BoxedFloat->Value, ExpectedValue, KINDA_SMALL_NUMBER));
	}
}

using namespace AngelscriptTest_Core_AngelscriptDelegateWithPayloadTests_Private;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDelegateWithPayloadBindExecuteResetTest,
	"Angelscript.TestModule.Engine.DelegateWithPayload.BindExecuteAndResetPrimitivePayloads",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptDelegateWithPayloadBindExecuteResetTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	TStrongObjectPtr<UAngelscriptNativeScriptTestObject> Receiver = CreateDelegateWithPayloadReceiver(*this);
	if (!Receiver.IsValid())
	{
		return false;
	}

	FAngelscriptDelegateWithPayload Delegate;
	if (!TestFalse(TEXT("DelegateWithPayload should begin unbound"), Delegate.IsBound()))
	{
		return false;
	}

	Delegate.ExecuteIfBound();
	if (!TestFalse(TEXT("Unbound DelegateWithPayload ExecuteIfBound should not toggle the receiver flag"), Receiver->bNativeFlag))
	{
		return false;
	}

	const FName NoPayloadFunctionName = GET_FUNCTION_NAME_CHECKED(UAngelscriptNativeScriptTestObject, MarkNativeFlagFromDelegate);
	Delegate.BindUFunction(Receiver.Get(), NoPayloadFunctionName);
	if (!TestTrue(TEXT("BindUFunction should mark DelegateWithPayload as bound"), Delegate.IsBound()))
	{
		return false;
	}

	if (!TestTrue(TEXT("BindUFunction should store the receiver object"), Delegate.Object.Get() == Receiver.Get()))
	{
		return false;
	}

	if (!TestEqual(TEXT("BindUFunction should store the receiver function name"), Delegate.FunctionName, NoPayloadFunctionName))
	{
		return false;
	}

	if (!TestFalse(TEXT("BindUFunction should not retain a payload"), Delegate.Payload.IsValid()))
	{
		return false;
	}

	Delegate.ExecuteIfBound();
	if (!TestTrue(TEXT("BindUFunction ExecuteIfBound should invoke the no-payload receiver function"), Receiver->bNativeFlag))
	{
		return false;
	}

	const int32 FloatTypeId = asTYPEID_FLOAT32;

	if (!TestTrue(
			TEXT("GetBoxedPrimitiveStructFromTypeId should map float to the boxed-float helper"),
			FAngelscriptDelegateWithPayload::GetBoxedPrimitiveStructFromTypeId(FloatTypeId) == FAngelscriptBoxedFloat::StaticStruct()))
	{
		return false;
	}

	const float PayloadValue = 3.25f;
	const FName PayloadFunctionName = GET_FUNCTION_NAME_CHECKED(UAngelscriptNativeScriptTestObject, SetPreciseValueFromDelegate);
	Delegate.BindUFunctionWithPayload(Receiver.Get(), PayloadFunctionName, (void*)&PayloadValue, FloatTypeId);
	if (!TestTrue(TEXT("BindUFunctionWithPayload should keep DelegateWithPayload bound"), Delegate.IsBound()))
	{
		return false;
	}

	if (!TestEqual(TEXT("BindUFunctionWithPayload should replace the stored function name"), Delegate.FunctionName, PayloadFunctionName))
	{
		return false;
	}

	if (!ExpectBoxedFloatPayload(*this, Delegate, PayloadValue))
	{
		return false;
	}

	Delegate.ExecuteIfBound();
	if (!TestTrue(
			TEXT("BindUFunctionWithPayload ExecuteIfBound should forward the boxed float to the receiver"),
			FMath::IsNearlyEqual(static_cast<float>(Receiver->PreciseValue), PayloadValue, KINDA_SMALL_NUMBER)))
	{
		return false;
	}

	Receiver->bNativeFlag = false;
	Delegate.BindUFunction(Receiver.Get(), NoPayloadFunctionName);
	if (!TestFalse(
			TEXT("BindUFunction should clear any previously boxed payload"),
			Delegate.Payload.IsValid()))
	{
		return false;
	}

	Delegate.ExecuteIfBound();
	if (!TestTrue(
			TEXT("BindUFunction should still execute correctly after rebinding from a payload delegate"),
			Receiver->bNativeFlag))
	{
		return false;
	}

	Receiver->bNativeFlag = false;
	Receiver->PreciseValue = 9.5;
	Delegate.Reset();
	if (!TestFalse(TEXT("Reset should leave DelegateWithPayload unbound"), Delegate.IsBound()))
	{
		return false;
	}

	if (!ExpectClearedDelegateState(*this, Delegate))
	{
		return false;
	}

	Delegate.ExecuteIfBound();
	const bool bNoOpAfterReset =
		TestFalse(TEXT("Reset delegate should no longer call the no-payload receiver function"), Receiver->bNativeFlag)
		&& TestTrue(
			TEXT("Reset delegate should become a no-op for payload execution"),
			FMath::IsNearlyEqual(static_cast<float>(Receiver->PreciseValue), 9.5f, KINDA_SMALL_NUMBER));

	bPassed = bNoOpAfterReset;
	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

#endif
