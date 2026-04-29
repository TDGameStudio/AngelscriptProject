#include "CQTest.h"
#include "Core/AngelscriptEngine.h"
#include "Interface/AngelscriptInterfaceTestAccess.h"
#include "Shared/AngelscriptTestMacros.h"
#include "Shared/AngelscriptBindingsCoverage.h"
#include "Shared/AngelscriptBindingsModuleBuilder.h"
#include "Shared/AngelscriptBindingsAssertions.h"

#include "Misc/ScopeExit.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;
using namespace AngelscriptTestBindings;
using namespace AngelscriptReflectiveAccess;

static const FBindingsCoverageProfile GInterfaceBindingProfile{TEXT("InterfaceBinding"),TEXT(""),TEXT("ASIntfBinding"),TEXT("IntfBinding"),TEXT("InterfaceBindingTests")};

TEST_CLASS_WITH_FLAGS(FAngelscriptInterfaceNativeBindingTests, "Angelscript.TestModule.Interface.NativeBinding", EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	BEFORE_ALL()
	{
		ASTEST_CREATE_ENGINE_SHARE_FRESH();
	}

	AFTER_ALL()
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		AngelscriptTestSupport::ResetSharedCloneEngine(Engine);
	}

	TEST_METHOD(SignatureRegistrationLifecycle)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
		FAngelscriptEngineScope Scope(Engine);
		ON_SCOPE_EXIT
		{
			ResetSharedCloneEngine(Engine);
		};

		const int32 BaselineSignatureCount = FAngelscriptInterfaceSignatureTestAccess::GetSignatureCount(Engine);

		FInterfaceMethodSignature* NativeValueSignature =
			Engine.RegisterInterfaceMethodSignature(FName(TEXT("GetNativeValue")));
		FInterfaceMethodSignature* NativeMarkerSignature =
			Engine.RegisterInterfaceMethodSignature(FName(TEXT("SetNativeMarker")));

		TestNotNull(
			TEXT("Interface signature lifecycle test should allocate a signature record for GetNativeValue"),
			NativeValueSignature);
		TestNotNull(
			TEXT("Interface signature lifecycle test should allocate a signature record for SetNativeMarker"),
			NativeMarkerSignature);
		if (NativeValueSignature != nullptr)
		{
			TestEqual(
				TEXT("Interface signature lifecycle test should preserve the registered function name for GetNativeValue"),
				NativeValueSignature->FunctionName,
				FName(TEXT("GetNativeValue")));
		}
		if (NativeMarkerSignature != nullptr)
		{
			TestEqual(
				TEXT("Interface signature lifecycle test should preserve the registered function name for SetNativeMarker"),
				NativeMarkerSignature->FunctionName,
				FName(TEXT("SetNativeMarker")));
		}
		TestTrue(
			TEXT("Interface signature lifecycle test should return distinct records for separate registrations"),
			NativeValueSignature != nullptr && NativeMarkerSignature != nullptr && NativeValueSignature != NativeMarkerSignature);
		TestEqual(
			TEXT("Interface signature lifecycle test should increase the signature count by two after two registrations"),
			FAngelscriptInterfaceSignatureTestAccess::GetSignatureCount(Engine),
			BaselineSignatureCount + 2);

		Engine.ReleaseInterfaceMethodSignature(NativeValueSignature);
		TestEqual(
			TEXT("Interface signature lifecycle test should decrease the signature count by one after releasing the first signature"),
			FAngelscriptInterfaceSignatureTestAccess::GetSignatureCount(Engine),
			BaselineSignatureCount + 1);

		Engine.ReleaseInterfaceMethodSignature(nullptr);
		TestEqual(
			TEXT("Interface signature lifecycle test should treat nullptr release as a no-op"),
			FAngelscriptInterfaceSignatureTestAccess::GetSignatureCount(Engine),
			BaselineSignatureCount + 1);

		Engine.ReleaseInterfaceMethodSignature(NativeMarkerSignature);
		TestEqual(
			TEXT("Interface signature lifecycle test should restore the baseline count after releasing the second signature"),
			FAngelscriptInterfaceSignatureTestAccess::GetSignatureCount(Engine),
			BaselineSignatureCount);
	}
};

#endif
