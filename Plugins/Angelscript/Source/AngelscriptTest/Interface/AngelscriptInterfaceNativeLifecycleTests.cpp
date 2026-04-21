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
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter | EAutomationTestFlags::Disabled) // TODO(#ue57-state): Shared test engine starts with non-empty interface signature list on UE 5.7; test isolation issue

bool FAngelscriptInterfaceNativeSignatureRegistrationReleaseTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
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
		if (!TestEqual(
				TEXT("Interface.Native.SignatureRegistrationRelease should start from an empty interface signature list in a clean shared engine"),
				FAngelscriptInterfaceSignatureTestAccess::GetSignatureCount(Engine),
				0))
		{
			break;
		}

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
				TEXT("Interface.Native.SignatureRegistrationRelease should grow from 0 to 2 entries after two registrations"),
				FAngelscriptInterfaceSignatureTestAccess::GetSignatureCount(Engine),
				2))
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
				TEXT("Interface.Native.SignatureRegistrationRelease should shrink from 2 to 1 entry after releasing the first signature"),
				FAngelscriptInterfaceSignatureTestAccess::GetSignatureCount(Engine),
				1))
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
				1))
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
				TEXT("Interface.Native.SignatureRegistrationRelease should shrink from 1 to 0 entries after releasing the final signature"),
				FAngelscriptInterfaceSignatureTestAccess::GetSignatureCount(Engine),
				0))
		{
			break;
		}

		bPassed = true;
	}
	while (false);

	ASTEST_END_SHARE_CLEAN
	return bPassed;
}

#endif
