#include "Core/AngelscriptEngine.h"
#include "Interface/AngelscriptInterfaceTestAccess.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptInterfaceNativeBindingSignatureRegistrationLifecycleTest,
	"Angelscript.TestModule.Interface.NativeBinding.SignatureRegistrationLifecycle",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptInterfaceNativeBindingSignatureRegistrationLifecycleTest::RunTest(const FString& Parameters)
{
	bool bPassed = true;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
	ASTEST_BEGIN_SHARE_FRESH
	ON_SCOPE_EXIT
	{
		ResetSharedCloneEngine(Engine);
	};

	const int32 BaselineSignatureCount = FAngelscriptInterfaceSignatureTestAccess::GetSignatureCount(Engine);

	FInterfaceMethodSignature* NativeValueSignature =
		Engine.RegisterInterfaceMethodSignature(FName(TEXT("GetNativeValue")));
	FInterfaceMethodSignature* NativeMarkerSignature =
		Engine.RegisterInterfaceMethodSignature(FName(TEXT("SetNativeMarker")));

	bPassed &= TestNotNull(
		TEXT("Interface signature lifecycle test should allocate a signature record for GetNativeValue"),
		NativeValueSignature);
	bPassed &= TestNotNull(
		TEXT("Interface signature lifecycle test should allocate a signature record for SetNativeMarker"),
		NativeMarkerSignature);
	if (NativeValueSignature != nullptr)
	{
		bPassed &= TestEqual(
			TEXT("Interface signature lifecycle test should preserve the registered function name for GetNativeValue"),
			NativeValueSignature->FunctionName,
			FName(TEXT("GetNativeValue")));
	}
	if (NativeMarkerSignature != nullptr)
	{
		bPassed &= TestEqual(
			TEXT("Interface signature lifecycle test should preserve the registered function name for SetNativeMarker"),
			NativeMarkerSignature->FunctionName,
			FName(TEXT("SetNativeMarker")));
	}
	bPassed &= TestTrue(
		TEXT("Interface signature lifecycle test should return distinct records for separate registrations"),
		NativeValueSignature != nullptr && NativeMarkerSignature != nullptr && NativeValueSignature != NativeMarkerSignature);
	bPassed &= TestEqual(
		TEXT("Interface signature lifecycle test should increase the signature count by two after two registrations"),
		FAngelscriptInterfaceSignatureTestAccess::GetSignatureCount(Engine),
		BaselineSignatureCount + 2);

	Engine.ReleaseInterfaceMethodSignature(NativeValueSignature);
	bPassed &= TestEqual(
		TEXT("Interface signature lifecycle test should decrease the signature count by one after releasing the first signature"),
		FAngelscriptInterfaceSignatureTestAccess::GetSignatureCount(Engine),
		BaselineSignatureCount + 1);

	Engine.ReleaseInterfaceMethodSignature(nullptr);
	bPassed &= TestEqual(
		TEXT("Interface signature lifecycle test should treat nullptr release as a no-op"),
		FAngelscriptInterfaceSignatureTestAccess::GetSignatureCount(Engine),
		BaselineSignatureCount + 1);

	Engine.ReleaseInterfaceMethodSignature(NativeMarkerSignature);
	bPassed &= TestEqual(
		TEXT("Interface signature lifecycle test should restore the baseline count after releasing the second signature"),
		FAngelscriptInterfaceSignatureTestAccess::GetSignatureCount(Engine),
		BaselineSignatureCount);

	ASTEST_END_SHARE_FRESH
	return bPassed;
}

#endif
