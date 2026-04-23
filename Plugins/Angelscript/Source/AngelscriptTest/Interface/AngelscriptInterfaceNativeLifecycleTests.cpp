#include "Core/AngelscriptEngine.h"
#include "Interface/AngelscriptInterfaceTestAccess.h"
#include "Shared/AngelscriptTestMacros.h"

#include "Misc/AutomationTest.h"
#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptInterfaceNativeSignatureRegistrationReleaseTest,
	"Angelscript.TestModule.Interface.Native.SignatureRegistrationRelease",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FAngelscriptInterfaceNativeSignatureRegistrationReleaseTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	FInterfaceMethodSignature* FirstSignature = nullptr;
	FInterfaceMethodSignature* SecondSignature = nullptr;
	ON_SCOPE_EXIT
	{
		Engine.ReleaseInterfaceMethodSignature(FirstSignature);
		Engine.ReleaseInterfaceMethodSignature(SecondSignature);
	};

	do
	{
		// Use the current count as baseline instead of assuming zero — prior tests
		// in a batch run may leave interface signatures in the shared engine.
		const int32 BaselineCount = FAngelscriptInterfaceSignatureTestAccess::GetSignatureCount(Engine);

		FirstSignature = Engine.RegisterInterfaceMethodSignature(FName(TEXT("GetNativeValue")));
		SecondSignature = Engine.RegisterInterfaceMethodSignature(FName(TEXT("SetNativeMarker")));

		if (!TestNotNull(
				TEXT("Interface.Native.SignatureRegistrationRelease should allocate the first interface signature"),
				FirstSignature)
			|| !TestNotNull(
				TEXT("Interface.Native.SignatureRegistrationRelease should allocate the second interface signature"),
				SecondSignature))
		{
			break;
		}

		if (!TestTrue(
				TEXT("Interface.Native.SignatureRegistrationRelease should return distinct records for distinct registrations"),
				FirstSignature != SecondSignature))
		{
			break;
		}

		if (!TestEqual(
				TEXT("Interface.Native.SignatureRegistrationRelease should grow by 2 entries after two registrations"),
				FAngelscriptInterfaceSignatureTestAccess::GetSignatureCount(Engine),
				BaselineCount + 2))
		{
			break;
		}

		if (!TestEqual(
				TEXT("Interface.Native.SignatureRegistrationRelease should keep the first registered function name at index 0"),
				FirstSignature->FunctionName,
				FName(TEXT("GetNativeValue"))))
		{
			break;
		}

		if (!TestEqual(
				TEXT("Interface.Native.SignatureRegistrationRelease should preserve the second signature function name"),
				SecondSignature->FunctionName,
				FName(TEXT("SetNativeMarker"))))
		{
			break;
		}

		Engine.ReleaseInterfaceMethodSignature(FirstSignature);
		FirstSignature = nullptr;

		if (!TestEqual(
				TEXT("Interface.Native.SignatureRegistrationRelease should shrink by 1 entry after releasing the first signature"),
				FAngelscriptInterfaceSignatureTestAccess::GetSignatureCount(Engine),
				BaselineCount + 1))
		{
			break;
		}

		if (!TestEqual(
				TEXT("Interface.Native.SignatureRegistrationRelease should keep the second signature function name intact after releasing the first"),
				SecondSignature->FunctionName,
				FName(TEXT("SetNativeMarker"))))
		{
			break;
		}

		Engine.ReleaseInterfaceMethodSignature(nullptr);

		if (!TestEqual(
				TEXT("Interface.Native.SignatureRegistrationRelease should keep the count unchanged when releasing nullptr"),
				FAngelscriptInterfaceSignatureTestAccess::GetSignatureCount(Engine),
				BaselineCount + 1))
		{
			break;
		}

		if (!TestEqual(
				TEXT("Interface.Native.SignatureRegistrationRelease should preserve the remaining signature function name after the nullptr guard path"),
				SecondSignature->FunctionName,
				FName(TEXT("SetNativeMarker"))))
		{
			break;
		}

		Engine.ReleaseInterfaceMethodSignature(SecondSignature);
		SecondSignature = nullptr;

		if (!TestEqual(
				TEXT("Interface.Native.SignatureRegistrationRelease should shrink back to baseline after releasing the final signature"),
				FAngelscriptInterfaceSignatureTestAccess::GetSignatureCount(Engine),
				BaselineCount))
		{
			break;
		}

	}
	while (false);

	ASTEST_END_SHARE_CLEAN
	return !HasAnyErrors();
}

#endif
