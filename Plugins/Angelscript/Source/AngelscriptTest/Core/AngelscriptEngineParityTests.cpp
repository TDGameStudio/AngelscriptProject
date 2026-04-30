#include "AngelscriptEngine.h"
#include "AngelscriptBinds.h"
#include "AngelscriptType.h"
#include "Shared/AngelscriptTestUtilities.h"
#include "Engine/CollisionProfile.h"
#include "Engine/Texture2D.h"
#include "GameFramework/Actor.h"
#include "CQTest.h"

#include "StartAngelscriptHeaders.h"
#include "source/as_module.h"
#include "source/as_scriptengine.h"
#include "EndAngelscriptHeaders.h"

#if WITH_DEV_AUTOMATION_TESTS

namespace AngelscriptTest_Core_AngelscriptEngineParityTests_Private
{
	FAngelscriptEngine* GetProductionEngineForParity(FAutomationTestBase* Test)
	{
		if (!FAngelscriptEngine::IsInitialized())
		{
			Test->AddError(TEXT("Production Angelscript engine should already be initialized before parity tests run."));
			return nullptr;
		}

		return &FAngelscriptEngine::Get();
	}

	FString SanitizeCollisionProfileIdentifier(const FName& ProfileName)
	{
		FString Identifier = ProfileName.ToString();
		for (int32 Index = Identifier.Len() - 1; Index >= 0; --Index)
		{
			if (!FAngelscriptEngine::IsValidIdentifierCharacter(Identifier[Index]))
			{
				Identifier[Index] = '_';
			}
		}

		if (!Identifier.IsEmpty() && Identifier[0] >= '0' && Identifier[0] <= '9')
		{
			Identifier = TEXT("_") + Identifier;
		}

		return Identifier;
	}

	FAngelscriptTypeUsage MakeTemplateTypeUsage(const TCHAR* BaseTypeName, UClass* SubTypeClass)
	{
		FAngelscriptTypeUsage Usage(FAngelscriptType::GetByAngelscriptTypeName(BaseTypeName));
		Usage.SubTypes.Add(FAngelscriptTypeUsage(FAngelscriptType::GetByClass(SubTypeClass)));
		return Usage;
	}
}


TEST_CLASS_WITH_FLAGS(FAngelscriptEngineParityTests,
	"Angelscript.TestModule.Parity",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	TEST_METHOD(SkinnedMeshCompile)
{
	using namespace AngelscriptTest_Core_AngelscriptEngineParityTests_Private;
	FAngelscriptEngine* Engine = GetProductionEngineForParity(TestRunner);
	if (!TestRunner->TestNotNull(TEXT("Skinned mesh test should access the production angelscript engine"), Engine))
	{
		return;
	}

	asITypeInfo* TypeInfo = Engine->GetScriptEngine()->GetTypeInfoByName("USkinnedMeshComponent");
	if (!TestRunner->TestNotNull(TEXT("USkinnedMeshComponent should exist in the script type system"), TypeInfo))
	{
		return;
	}

	const bool bHasUpdateLODStatus = TestRunner->TestNotNull(TEXT("USkinnedMeshComponent should expose UpdateLODStatus()"), TypeInfo->GetMethodByDecl("void UpdateLODStatus()"));
	const bool bHasInvalidateCachedBounds = TestRunner->TestNotNull(TEXT("USkinnedMeshComponent should expose InvalidateCachedBounds()"), TypeInfo->GetMethodByDecl("void InvalidateCachedBounds()"));
	}


	TEST_METHOD(DelegateWithPayloadCompile)
{
	using namespace AngelscriptTest_Core_AngelscriptEngineParityTests_Private;
	FAngelscriptEngine* Engine = GetProductionEngineForParity(TestRunner);
	if (!TestRunner->TestNotNull(TEXT("DelegateWithPayload test should access the production angelscript engine"), Engine))
	{
		return;
	}

	asITypeInfo* TypeInfo = Engine->GetScriptEngine()->GetTypeInfoByName("FAngelscriptDelegateWithPayload");
	if (!TestRunner->TestNotNull(TEXT("FAngelscriptDelegateWithPayload should exist in the script type system"), TypeInfo))
	{
		return;
	}

	const bool bHasIsBound = TestRunner->TestNotNull(TEXT("FAngelscriptDelegateWithPayload should expose IsBound()"), TypeInfo->GetMethodByDecl("bool IsBound() const"));
	const bool bHasExecuteIfBound = TestRunner->TestNotNull(TEXT("FAngelscriptDelegateWithPayload should expose ExecuteIfBound()"), TypeInfo->GetMethodByDecl("void ExecuteIfBound() const"));
	}


	TEST_METHOD(CollisionProfileCompile)
{
	using namespace AngelscriptTest_Core_AngelscriptEngineParityTests_Private;
	FAngelscriptEngine* Engine = GetProductionEngineForParity(TestRunner);
	if (!TestRunner->TestNotNull(TEXT("CollisionProfile test should access the production angelscript engine"), Engine))
	{
		return;
	}

	TArray<TSharedPtr<FName>> CollisionProfiles;
	UCollisionProfile::GetProfileNames(CollisionProfiles);
	if (!TestRunner->TestTrue(TEXT("CollisionProfile test requires at least one collision profile name"), CollisionProfiles.Num() > 0))
	{
		return;
	}

	const FName ProfileName = *CollisionProfiles[0].Get();
	const FString SanitizedIdentifier = SanitizeCollisionProfileIdentifier(ProfileName);
	if (!TestRunner->TestFalse(TEXT("CollisionProfile identifier should not be empty after sanitization"), SanitizedIdentifier.IsEmpty()))
	{
		return;
	}

	asIScriptModule* Module = Engine->GetScriptEngine()->GetModule("CollisionProfileParity", asGM_ALWAYS_CREATE);
	if (!TestRunner->TestNotNull(TEXT("CollisionProfile test should create a script module"), Module))
	{
		return;
	}

	const FString Source = FString::Printf(TEXT("int CheckCollisionProfileConstant() { return CollisionProfile::%s.Compare(FName(\"%s\")); }"), *SanitizedIdentifier, *ProfileName.ToString());

	asIScriptFunction* Function = nullptr;
	const int CompileResult = Module->CompileFunction("CollisionProfileParity", TCHAR_TO_ANSI(*Source), 0, 0, &Function);
	if (!TestRunner->TestEqual(TEXT("CollisionProfile parity snippet should compile successfully"), CompileResult, asSUCCESS))
	{
		return;
	}

	if (!TestRunner->TestNotNull(TEXT("CollisionProfile parity snippet should produce a function"), Function))
	{
		return;
	}

	asIScriptContext* Context = Engine->CreateContext();
	if (!TestRunner->TestNotNull(TEXT("CollisionProfile parity test should create a script context"), Context))
	{
		Function->Release();
		return;
	}

	const int PrepareResult = Context->Prepare(Function);
	const int ExecuteResult = PrepareResult == asSUCCESS ? Context->Execute() : PrepareResult;
	TestRunner->TestEqual(TEXT("CollisionProfile parity snippet should prepare successfully"), PrepareResult, asSUCCESS);
	TestRunner->TestEqual(TEXT("CollisionProfile parity snippet should finish successfully"), ExecuteResult, asEXECUTION_FINISHED);
	TestRunner->TestEqual(TEXT("CollisionProfile parity snippet should compare equal to the underlying FName"), static_cast<int>(Context->GetReturnDWord()), 0);

	Context->Release();
	Function->Release();
	}


	TEST_METHOD(CollisionQueryParamsCompile)
{
	using namespace AngelscriptTest_Core_AngelscriptEngineParityTests_Private;
	FAngelscriptEngine* Engine = GetProductionEngineForParity(TestRunner);
	if (!TestRunner->TestNotNull(TEXT("CollisionQueryParams test should access the production angelscript engine"), Engine))
	{
		return;
	}

	const bool bHasMaskType = TestRunner->TestNotNull(TEXT("FCollisionEnabledMask should exist in the script type system"), Engine->GetScriptEngine()->GetTypeInfoByName("FCollisionEnabledMask"));
	const bool bHasComponentQueryType = TestRunner->TestNotNull(TEXT("FComponentQueryParams should exist in the script type system"), Engine->GetScriptEngine()->GetTypeInfoByName("FComponentQueryParams"));
	if (!bHasMaskType || !bHasComponentQueryType)
	{
		return;
	}

	asIScriptModule* Module = Engine->GetScriptEngine()->GetModule("CollisionQueryParamsParity", asGM_ALWAYS_CREATE);
	if (!TestRunner->TestNotNull(TEXT("CollisionQueryParams test should create a script module"), Module))
	{
		return;
	}

	const char* Source = "int CheckCollisionQueryParams() { FCollisionEnabledMask Mask(ECollisionEnabled::QueryOnly); FComponentQueryParams Params; Params.ShapeCollisionMask = Mask; return Params.ShapeCollisionMask.Bits; }";
	asIScriptFunction* Function = nullptr;
	const int CompileResult = Module->CompileFunction("CollisionQueryParamsParity", Source, 0, 0, &Function);
	const bool bCompiled = TestRunner->TestEqual(TEXT("CollisionQueryParams parity snippet should compile successfully"), CompileResult, asSUCCESS);
	const bool bHasFunction = TestRunner->TestNotNull(TEXT("CollisionQueryParams parity snippet should produce a function"), Function);
	if (Function != nullptr)
	{
		Function->Release();
	}

	}


	TEST_METHOD(WorldCollisionCompile)
{
	using namespace AngelscriptTest_Core_AngelscriptEngineParityTests_Private;
	FAngelscriptEngine* Engine = GetProductionEngineForParity(TestRunner);
	if (!TestRunner->TestNotNull(TEXT("WorldCollision test should access the production angelscript engine"), Engine))
	{
		return;
	}

	asIScriptModule* Module = Engine->GetScriptEngine()->GetModule("WorldCollisionParity", asGM_ALWAYS_CREATE);
	if (!TestRunner->TestNotNull(TEXT("WorldCollision test should create a script module"), Module))
	{
		return;
	}

	const char* Source =
		"void CheckWorldCollision(UPrimitiveComponent PrimitiveComponent)\n"
		"{\n"
		"    FCollisionQueryParams QueryParams;\n"
		"    FCollisionResponseParams ResponseParams;\n"
		"    FCollisionObjectQueryParams ObjectQueryParams;\n"
		"    FComponentQueryParams ComponentQueryParams;\n"
		"    FCollisionShape Shape = FCollisionShape::MakeSphere(10.0f);\n"
		"    FHitResult Hit;\n"
		"    TArray<FHitResult> Hits;\n"
		"    TArray<FOverlapResult> Overlaps;\n"
		"    System::LineTraceTestByChannel(FVector::ZeroVector, FVector(100.0f, 0.0f, 0.0f), ECollisionChannel::ECC_Visibility, QueryParams, ResponseParams);\n"
		"    System::SweepSingleByObjectType(Hit, FVector::ZeroVector, FVector(100.0f, 0.0f, 0.0f), FQuat::Identity, ObjectQueryParams, Shape, QueryParams);\n"
		"    System::OverlapMultiByProfile(Overlaps, FVector::ZeroVector, FQuat::Identity, CollisionProfile::BlockAllDynamic, Shape, QueryParams);\n"
		"    System::ComponentSweepMulti(Hits, PrimitiveComponent, FVector::ZeroVector, FVector(10.0f, 0.0f, 0.0f), FQuat::Identity, ComponentQueryParams);\n"
		"    System::ComponentOverlapMulti(Overlaps, PrimitiveComponent, FVector::ZeroVector, FQuat::Identity, ComponentQueryParams, ObjectQueryParams);\n"
		"    System::AsyncOverlapByProfile(FVector::ZeroVector, FQuat::Identity, CollisionProfile::BlockAllDynamic, Shape, QueryParams);\n"
		"}";

	asIScriptFunction* Function = nullptr;
	const int CompileResult = Module->CompileFunction("WorldCollisionParity", Source, 0, 0, &Function);
	const bool bCompiled = TestRunner->TestEqual(TEXT("WorldCollision parity snippet should compile successfully"), CompileResult, asSUCCESS);
	const bool bHasFunction = TestRunner->TestNotNull(TEXT("WorldCollision parity snippet should produce a function"), Function);
	if (Function != nullptr)
	{
		Function->Release();
	}

	}


	TEST_METHOD(FIntPointCompile)
{
	using namespace AngelscriptTest_Core_AngelscriptEngineParityTests_Private;
	FAngelscriptEngine* Engine = GetProductionEngineForParity(TestRunner);
	if (!TestRunner->TestNotNull(TEXT("FIntPoint test should access the production angelscript engine"), Engine))
	{
		return;
	}

	if (!TestRunner->TestNotNull(TEXT("FIntPoint should exist in the script type system"), Engine->GetScriptEngine()->GetTypeInfoByName("FIntPoint")))
	{
		return;
	}

	asIScriptModule* Module = Engine->GetScriptEngine()->GetModule("FIntPointParity", asGM_ALWAYS_CREATE);
	if (!TestRunner->TestNotNull(TEXT("FIntPoint test should create a script module"), Module))
	{
		return;
	}

	const char* Source = "int CheckFIntPoint() { FIntPoint A(1, 2); FIntPoint B(3); FIntPoint C = A + B; return C.X + C.Y + C[0]; }";
	asIScriptFunction* Function = nullptr;
	const int CompileResult = Module->CompileFunction("FIntPointParity", Source, 0, 0, &Function);
	if (!TestRunner->TestEqual(TEXT("FIntPoint parity snippet should compile successfully"), CompileResult, asSUCCESS))
	{
		return;
	}

	if (!TestRunner->TestNotNull(TEXT("FIntPoint parity snippet should produce a function"), Function))
	{
		return;
	}

	asIScriptContext* Context = Engine->CreateContext();
	if (!TestRunner->TestNotNull(TEXT("FIntPoint test should create a script context"), Context))
	{
		Function->Release();
		return;
	}

	const int PrepareResult = Context->Prepare(Function);
	const int ExecuteResult = PrepareResult == asSUCCESS ? Context->Execute() : PrepareResult;
	TestRunner->TestEqual(TEXT("FIntPoint parity snippet should prepare successfully"), PrepareResult, asSUCCESS);
	TestRunner->TestEqual(TEXT("FIntPoint parity snippet should finish successfully"), ExecuteResult, asEXECUTION_FINISHED);
	TestRunner->TestEqual(TEXT("FIntPoint parity snippet should return the expected sum"), static_cast<int>(Context->GetReturnDWord()), 13);

	Context->Release();
	Function->Release();
	}


	TEST_METHOD(FVector2fCompile)
{
	using namespace AngelscriptTest_Core_AngelscriptEngineParityTests_Private;
	FAngelscriptEngine* Engine = GetProductionEngineForParity(TestRunner);
	if (!TestRunner->TestNotNull(TEXT("FVector2f test should access the production angelscript engine"), Engine))
	{
		return;
	}

	if (!TestRunner->TestNotNull(TEXT("FVector2f should exist in the script type system"), Engine->GetScriptEngine()->GetTypeInfoByName("FVector2f")))
	{
		return;
	}

	asIScriptModule* Module = Engine->GetScriptEngine()->GetModule("FVector2fParity", asGM_ALWAYS_CREATE);
	if (!TestRunner->TestNotNull(TEXT("FVector2f test should create a script module"), Module))
	{
		return;
	}

	const char* Source = "float CheckFVector2f() { FVector2f A(1.0f, 2.0f); FVector2f B(1.0f, 1.0f); FVector2f C = A + B; return C.X + C.Y; }";
	asIScriptFunction* Function = nullptr;
	const int CompileResult = Module->CompileFunction("FVector2fParity", Source, 0, 0, &Function);
	if (!TestRunner->TestEqual(TEXT("FVector2f parity snippet should compile successfully"), CompileResult, asSUCCESS))
	{
		return;
	}

	if (!TestRunner->TestNotNull(TEXT("FVector2f parity snippet should produce a function"), Function))
	{
		return;
	}

	asIScriptContext* Context = Engine->CreateContext();
	if (!TestRunner->TestNotNull(TEXT("FVector2f test should create a script context"), Context))
	{
		Function->Release();
		return;
	}

	const int PrepareResult = Context->Prepare(Function);
	const int ExecuteResult = PrepareResult == asSUCCESS ? Context->Execute() : PrepareResult;
	const float ReturnValue = Context->GetReturnFloat();
	TestRunner->TestEqual(TEXT("FVector2f parity snippet should prepare successfully"), PrepareResult, asSUCCESS);
	TestRunner->TestEqual(TEXT("FVector2f parity snippet should finish successfully"), ExecuteResult, asEXECUTION_FINISHED);
	static_cast<void>(ReturnValue);

	Context->Release();
	Function->Release();
	}


	TEST_METHOD(SoftReferenceCppForm)
{
	using namespace AngelscriptTest_Core_AngelscriptEngineParityTests_Private;
	if (!TestRunner->TestNotNull(TEXT("Soft reference C++ form test should access the production angelscript engine"), GetProductionEngineForParity(TestRunner)))
	{
		return;
	}

	const FAngelscriptTypeUsage SoftObjectUsage = MakeTemplateTypeUsage(TEXT("TSoftObjectPtr"), UTexture2D::StaticClass());
	const FAngelscriptTypeUsage SoftClassUsage = MakeTemplateTypeUsage(TEXT("TSoftClassPtr"), AActor::StaticClass());
	if (!TestRunner->TestTrue(TEXT("TSoftObjectPtr usage should include a resolved subtype"), SoftObjectUsage.IsValid() && SoftObjectUsage.SubTypes.Num() == 1 && SoftObjectUsage.SubTypes[0].IsValid()))
	{
		return;
	}
	if (!TestRunner->TestTrue(TEXT("TSoftClassPtr usage should include a resolved subtype"), SoftClassUsage.IsValid() && SoftClassUsage.SubTypes.Num() == 1 && SoftClassUsage.SubTypes[0].IsValid()))
	{
		return;
	}

	FAngelscriptType::FCppForm SoftObjectForm;
	FAngelscriptType::FCppForm SoftClassForm;
	if (!TestRunner->TestTrue(TEXT("TSoftObjectPtr should produce a C++ form for static JIT"), SoftObjectUsage.GetCppForm(SoftObjectForm)))
	{
		return;
	}
	if (!TestRunner->TestTrue(TEXT("TSoftClassPtr should produce a C++ form for static JIT"), SoftClassUsage.GetCppForm(SoftClassForm)))
	{
		return;
	}

	const bool bSoftObjectMatches =
		TestRunner->TestEqual(TEXT("TSoftObjectPtr should map to the resolved native template type"), SoftObjectForm.CppType, TEXT("TSoftObjectPtr<UTexture2D>")) &&
		TestRunner->TestEqual(TEXT("TSoftObjectPtr should expose the expected generic native template"), SoftObjectForm.CppGenericType, TEXT("TSoftObjectPtr<UObject>")) &&
		TestRunner->TestEqual(TEXT("TSoftObjectPtr should expose the expected template object form"), SoftObjectForm.TemplateObjectForm, TEXT("TSoftObjectPtr<UObject>")) &&
		TestRunner->TestFalse(TEXT("TSoftObjectPtr should emit an include for the resolved subtype"), SoftObjectForm.CppHeader.IsEmpty());

	const bool bSoftClassMatches =
		TestRunner->TestEqual(TEXT("TSoftClassPtr should map to the resolved native template type"), SoftClassForm.CppType, TEXT("TSoftClassPtr<AActor>")) &&
		TestRunner->TestEqual(TEXT("TSoftClassPtr should expose the expected generic native template"), SoftClassForm.CppGenericType, TEXT("TSoftClassPtr<UObject>")) &&
		TestRunner->TestEqual(TEXT("TSoftClassPtr should expose the expected template object form"), SoftClassForm.TemplateObjectForm, TEXT("TSoftClassPtr<UObject>")) &&
		TestRunner->TestFalse(TEXT("TSoftClassPtr should emit an include for the resolved subtype"), SoftClassForm.CppHeader.IsEmpty());

	}


	TEST_METHOD(SoftReferenceCompile)
{
	using namespace AngelscriptTest_Core_AngelscriptEngineParityTests_Private;
	FAngelscriptEngine* Engine = GetProductionEngineForParity(TestRunner);
	if (!TestRunner->TestNotNull(TEXT("Soft reference compile test should access the production angelscript engine"), Engine))
	{
		return;
	}

	const FString Source =
		TEXT("UObject CheckSoftObjectGet(TSoftObjectPtr<UObject> Ptr)\n")
		TEXT("{\n")
		TEXT("    return Ptr.Get();\n")
		TEXT("}\n")
		TEXT("UTexture2D CheckSoftObjectEditorLoad(TSoftObjectPtr<UTexture2D> Ptr)\n")
		TEXT("{\n")
		TEXT("    return Ptr.EditorOnlyLoadSynchronous();\n")
		TEXT("}\n")
		TEXT("TSubclassOf<AActor> CheckSoftClassGet(TSoftClassPtr<AActor> Ptr)\n")
		TEXT("{\n")
		TEXT("    return Ptr.Get();\n")
		TEXT("}\n");

	asIScriptModule* Module = AngelscriptTestSupport::BuildModule(*TestRunner, *Engine, "Editor.SoftReferenceParity", Source);
	if (!TestRunner->TestNotNull(TEXT("Soft reference parity module should compile successfully"), Module))
	{
		return;
	}

	const bool bHasSoftObjectFunction = TestRunner->TestNotNull(TEXT("Soft reference parity module should expose the TSoftObjectPtr Get() smoke test"), AngelscriptTestSupport::GetFunctionByDecl(*TestRunner, *Module, TEXT("UObject CheckSoftObjectGet(TSoftObjectPtr<UObject> Ptr)")));
	const bool bHasEditorOnlyFunction = TestRunner->TestNotNull(TEXT("Soft reference parity module should expose the editor-only soft load smoke test"), AngelscriptTestSupport::GetFunctionByDecl(*TestRunner, *Module, TEXT("UTexture2D CheckSoftObjectEditorLoad(TSoftObjectPtr<UTexture2D> Ptr)")));
	const bool bHasSoftClassFunction = TestRunner->TestNotNull(TEXT("Soft reference parity module should expose the TSoftClassPtr Get() smoke test"), AngelscriptTestSupport::GetFunctionByDecl(*TestRunner, *Module, TEXT("TSubclassOf<AActor> CheckSoftClassGet(TSoftClassPtr<AActor> Ptr)")));
}

	TEST_METHOD(UserWidgetPaintCompile)
{
	using namespace AngelscriptTest_Core_AngelscriptEngineParityTests_Private;
	FAngelscriptEngine* Engine = GetProductionEngineForParity(TestRunner);
	if (!TestRunner->TestNotNull(TEXT("UserWidget paint compile test should access the production angelscript engine"), Engine))
	{
		return;
	}

	const FString Source =
		TEXT("void CheckWidgetPaint(FPaintContext& Context, const FGeometry& Geometry, UTexture2D Texture, UMaterialInterface Material)\n")
		TEXT("{\n")
		TEXT("    FSlateBrush StyleBrush(FName(\"WhiteBrush\"));\n")
		TEXT("    FSlateBrush ColorBrush(FLinearColor(1.0f, 0.0f, 0.0f, 1.0f));\n")
		TEXT("    FSlateBrush TextureBrush(Texture, FVector2D(16.0f, 16.0f));\n")
		TEXT("    FSlateBrush MaterialBrush(Material, FVector2D(16.0f, 16.0f));\n")
		TEXT("    Context.DrawBox(Geometry, StyleBrush);\n")
		TEXT("    Context.DrawRotatedBox(FVector2D::ZeroVector, FVector2D(8.0f, 8.0f), 0.0f, ColorBrush);\n")
		TEXT("    Context.DrawBox(FVector2D::ZeroVector, FVector2D(8.0f, 8.0f), TextureBrush);\n")
		TEXT("    Context.DrawBox(FVector2D::ZeroVector, FVector2D(8.0f, 8.0f), MaterialBrush);\n")
		TEXT("}\n");

	asIScriptModule* Module = AngelscriptTestSupport::BuildModule(*TestRunner, *Engine, "UserWidgetPaintParity", Source);
	TestRunner->TestNotNull(TEXT("UserWidget paint parity module should compile successfully"), Module);
}

	TEST_METHOD(LevelStreamingCompile)
{
	using namespace AngelscriptTest_Core_AngelscriptEngineParityTests_Private;
	FAngelscriptEngine* Engine = GetProductionEngineForParity(TestRunner);
	if (!TestRunner->TestNotNull(TEXT("LevelStreaming test should access the production angelscript engine"), Engine))
	{
		return;
	}

	asITypeInfo* TypeInfo = Engine->GetScriptEngine()->GetTypeInfoByName("ULevelStreaming");
	if (!TestRunner->TestNotNull(TEXT("ULevelStreaming should exist in the script type system"), TypeInfo))
	{
		return;
	}

	asITypeInfo* HelperTypeInfo = Engine->GetScriptEngine()->GetTypeInfoByName("UAngelscriptLevelStreamingLibrary");
	TestRunner->TestNotNull(TEXT("UAngelscriptLevelStreamingLibrary should be visible in the script type system for debugging"), HelperTypeInfo);

	const bool bHasMethod = TestRunner->TestNotNull(TEXT("ULevelStreaming should expose GetShouldBeVisibleInEditor()"), TypeInfo->GetMethodByDecl("bool GetShouldBeVisibleInEditor() const"));
}

	TEST_METHOD(RuntimeCurveLinearColorCompile)
{
	using namespace AngelscriptTest_Core_AngelscriptEngineParityTests_Private;
	FAngelscriptEngine* Engine = GetProductionEngineForParity(TestRunner);
	if (!TestRunner->TestNotNull(TEXT("RuntimeCurveLinearColor test should access the production angelscript engine"), Engine))
	{
		return;
	}

	asITypeInfo* TypeInfo = Engine->GetScriptEngine()->GetTypeInfoByName("FRuntimeCurveLinearColor");
	if (!TestRunner->TestNotNull(TEXT("FRuntimeCurveLinearColor should exist in the script type system"), TypeInfo))
	{
		return;
	}

	const bool bHasMethod = TestRunner->TestNotNull(TEXT("FRuntimeCurveLinearColor should expose AddDefaultKey()"), TypeInfo->GetMethodByName("AddDefaultKey"));
	if (!bHasMethod)
	{
		return;
	}

	asIScriptModule* Module = Engine->GetScriptEngine()->GetModule("RuntimeCurveLinearColorParity", asGM_ALWAYS_CREATE);
	if (!TestRunner->TestNotNull(TEXT("RuntimeCurveLinearColor test should create a script module"), Module))
	{
		return;
	}

	const char* Source = "void CheckRuntimeCurve() { FRuntimeCurveLinearColor Curve; URuntimeCurveLinearColorMixinLibrary::AddDefaultKey(Curve, 0.0f, FLinearColor::Red); Curve.AddDefaultKey(0.0f, FLinearColor::Red); }";
	asIScriptFunction* Function = nullptr;
	const int CompileResult = Module->CompileFunction("RuntimeCurveLinearColorParity", Source, 0, 0, &Function);
	const bool bCompiled = TestRunner->TestEqual(TEXT("RuntimeCurveLinearColor parity snippet should compile successfully"), CompileResult, asSUCCESS);
	const bool bHasFunction = TestRunner->TestNotNull(TEXT("RuntimeCurveLinearColor parity snippet should produce a function"), Function);
	if (Function != nullptr)
	{
		Function->Release();
	}

	}


	TEST_METHOD(HitResultCompile)
{
	using namespace AngelscriptTest_Core_AngelscriptEngineParityTests_Private;
	FAngelscriptEngine* Engine = GetProductionEngineForParity(TestRunner);
	if (!TestRunner->TestNotNull(TEXT("FHitResult test should access the production angelscript engine"), Engine))
	{
		return;
	}

	asIScriptModule* Module = Engine->GetScriptEngine()->GetModule("HitResultParity", asGM_ALWAYS_CREATE);
	if (!TestRunner->TestNotNull(TEXT("FHitResult test should create a script module"), Module))
	{
		return;
	}

	const char* Source =
		"int CheckHitResult() {\n"
		"    FHitResult Hit(FVector::ZeroVector, FVector::ForwardVector);\n"
		"    Hit.FaceIndex = 1;\n"
		"    Hit.ElementIndex = 2;\n"
		"    Hit.Item = 3;\n"
		"    Hit.MyItem = 4;\n"
		"    Hit.BoneName = FName(\"Bone\");\n"
		"    Hit.MyBoneName = FName(\"MyBone\");\n"
		"    return Hit.FaceIndex + Hit.ElementIndex + Hit.Item + Hit.MyItem;\n"
		"}";

	asIScriptFunction* Function = nullptr;
	const int CompileResult = Module->CompileFunction("HitResultParity", Source, 0, 0, &Function);
	if (!TestRunner->TestEqual(TEXT("FHitResult parity snippet should compile successfully"), CompileResult, asSUCCESS))
	{
		return;
	}

	if (!TestRunner->TestNotNull(TEXT("FHitResult parity snippet should produce a function"), Function))
	{
		return;
	}

	asIScriptContext* Context = Engine->CreateContext();
	if (!TestRunner->TestNotNull(TEXT("FHitResult parity test should create a script context"), Context))
	{
		Function->Release();
		return;
	}

	const int PrepareResult = Context->Prepare(Function);
	const int ExecuteResult = PrepareResult == asSUCCESS ? Context->Execute() : PrepareResult;
	TestRunner->TestEqual(TEXT("FHitResult parity snippet should prepare successfully"), PrepareResult, asSUCCESS);
	TestRunner->TestEqual(TEXT("FHitResult parity snippet should finish successfully"), ExecuteResult, asEXECUTION_FINISHED);
	TestRunner->TestEqual(TEXT("FHitResult parity snippet should read/write the restored fields"), static_cast<int>(Context->GetReturnDWord()), 10);

	Context->Release();
	Function->Release();
	}


	TEST_METHOD(DeprecationsMetadata)
{
	using namespace AngelscriptTest_Core_AngelscriptEngineParityTests_Private;
	static const FName NAME_META_DeprecatedFunction(TEXT("DeprecatedFunction"));
	static const FName NAME_META_DeprecationMessage(TEXT("DeprecationMessage"));

	UFunction* Function = FindObject<UFunction>(nullptr, TEXT("/Script/Niagara.NiagaraComponent:SetNiagaraVariableLinearColor"));
	if (!TestRunner->TestNotNull(TEXT("Niagara linear color setter should exist for deprecation metadata test"), Function))
	{
		return;
	}

	const bool bDeprecated = TestRunner->TestTrue(TEXT("Niagara linear color setter should be marked deprecated for Angelscript binding parity"), Function->HasMetaData(NAME_META_DeprecatedFunction));
	const bool bHasMessage = TestRunner->TestEqual(TEXT("Niagara linear color setter should expose the expected deprecation message"), Function->GetMetaData(NAME_META_DeprecationMessage), TEXT("Use the SetVariable variant that takes FName instead"));

	}


	TEST_METHOD(StartupBindRegistrySmoke)
{
	using namespace AngelscriptTest_Core_AngelscriptEngineParityTests_Private;
	FAngelscriptEngine* Engine = GetProductionEngineForParity(TestRunner);
	if (!TestRunner->TestNotNull(TEXT("Startup bind registry smoke should access the production angelscript engine"), Engine))
	{
		return;
	}

	const TArray<FName> RegisteredBindNames = FAngelscriptBinds::GetAllRegisteredBindNames();
	const TArray<FAngelscriptBinds::FBindInfo> BindInfos = FAngelscriptBinds::GetBindInfoList();
	if (!TestRunner->TestTrue(TEXT("Startup bind registry smoke should expose registered bind names after production startup"), RegisteredBindNames.Num() > 0)
		|| !TestRunner->TestEqual(TEXT("Startup bind registry smoke should expose one bind info entry per registered bind name"), BindInfos.Num(), RegisteredBindNames.Num()))
	{
		return;
	}

	for (int32 BindIndex = 1; BindIndex < BindInfos.Num(); ++BindIndex)
	{
		if (!TestRunner->TestTrue(TEXT("Startup bind registry smoke should keep bind info sorted by bind order"), BindInfos[BindIndex - 1].BindOrder <= BindInfos[BindIndex].BindOrder))
		{
			return;
		}
	}

	asIScriptModule* Module = Engine->GetScriptEngine()->GetModule("StartupBindRegistryParity", asGM_ALWAYS_CREATE);
	if (!TestRunner->TestNotNull(TEXT("Startup bind registry smoke should create a script module"), Module))
	{
		return;
	}

	const char* Source =
		"int CheckStartupBindSurface() {\n"
		"    USkinnedMeshComponent Component;\n"
		"    FIntPoint Point(3, 4);\n"
		"    FAngelscriptDelegateWithPayload Delegate;\n"
		"    FHitResult Hit(FVector::ZeroVector, FVector::ForwardVector);\n"
		"    return Point.X + Point.Y + (Delegate.IsBound() ? 1 : 0) + Hit.FaceIndex;\n"
		"}";

	asIScriptFunction* Function = nullptr;
	const int CompileResult = Module->CompileFunction("StartupBindRegistryParity", Source, 0, 0, &Function);
	const bool bCompiled = TestRunner->TestEqual(TEXT("Startup bind registry smoke should compile a representative multi-family startup bind snippet"), CompileResult, asSUCCESS);
	const bool bHasFunction = TestRunner->TestNotNull(TEXT("Startup bind registry smoke should produce a function for the multi-family snippet"), Function);
	if (Function != nullptr)
	{
		Function->Release();
	}

	}


};

#endif
