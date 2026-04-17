#include "../Shared/AngelscriptTestUtilities.h"
#include "../Shared/AngelscriptTestMacros.h"
#include "../Shared/AngelscriptTestEngineHelper.h"
#include "../Shared/AngelscriptNativeScriptTestObject.h"

#include "HAL/FileManager.h"
#include "Misc/AutomationTest.h"
#include "Misc/FileHelper.h"
#include "Misc/Paths.h"
#include "Misc/ScopeExit.h"
#include "UObject/SoftObjectPath.h"

#if WITH_DEV_AUTOMATION_TESTS

using namespace AngelscriptTestSupport;

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScriptDelegateBindingsTest,
	"Angelscript.TestModule.Bindings.ScriptDelegateCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptScriptDelegateExecuteBindingsTest,
	"Angelscript.TestModule.Bindings.ScriptDelegateExecuteCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptSoftPathBindingsTest,
	"Angelscript.TestModule.Bindings.SoftPathCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptSoftPathResolveBindingsTest,
	"Angelscript.TestModule.Bindings.SoftPathResolveCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptSourceMetadataBindingsTest,
	"Angelscript.TestModule.Bindings.SourceMetadataCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptFileHelperBindingsTest,
	"Angelscript.TestModule.Bindings.FileHelperCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FAngelscriptDelegateWithPayloadBindingsTest,
	"Angelscript.TestModule.Bindings.DelegateWithPayloadCompat",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

namespace AngelscriptTest_Bindings_AngelscriptFileAndDelegateBindingsTests_Private
{
	static constexpr ANSICHAR DelegateWithPayloadCompatModuleName[] = "ASDelegateWithPayloadCompat";

	bool ExecuteFunctionExpectingException(
		FAutomationTestBase& Test,
		FAngelscriptEngine& Engine,
		asIScriptModule& Module,
		const TCHAR* FunctionDecl,
		const TCHAR* ContextLabel,
		FString& OutExceptionString,
		int32& OutExceptionLine)
	{
		asIScriptFunction* Function = GetFunctionByDecl(Test, Module, FunctionDecl);
		if (Function == nullptr)
		{
			return false;
		}

		FAngelscriptEngineScope EngineScope(Engine);
		asIScriptContext* Context = Engine.CreateContext();
		if (!Test.TestNotNull(*FString::Printf(TEXT("%s should create an execution context"), ContextLabel), Context))
		{
			return false;
		}

		ON_SCOPE_EXIT
		{
			Context->Release();
		};

		const int PrepareResult = Context->Prepare(Function);
		if (!Test.TestEqual(
				*FString::Printf(TEXT("%s should prepare successfully"), ContextLabel),
				PrepareResult,
				static_cast<int32>(asSUCCESS)))
		{
			return false;
		}

		const int ExecuteResult = Context->Execute();
		if (!Test.TestEqual(
				*FString::Printf(TEXT("%s should fail with a script exception"), ContextLabel),
				ExecuteResult,
				static_cast<int32>(asEXECUTION_EXCEPTION)))
		{
			return false;
		}

		OutExceptionString = Context->GetExceptionString() != nullptr ? UTF8_TO_TCHAR(Context->GetExceptionString()) : TEXT("");
		OutExceptionLine = Context->GetExceptionLineNumber();
		const bool bHasExceptionString = Test.TestFalse(
			*FString::Printf(TEXT("%s should report a non-empty exception string"), ContextLabel),
			OutExceptionString.IsEmpty());
		const bool bHasExceptionLine = Test.TestTrue(
			*FString::Printf(TEXT("%s should report a positive exception line"), ContextLabel),
			OutExceptionLine > 0);
		return bHasExceptionString && bHasExceptionLine;
	}
}

using namespace AngelscriptTest_Bindings_AngelscriptFileAndDelegateBindingsTests_Private;

bool FAngelscriptScriptDelegateBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASScriptDelegateCompat"));
	};

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASScriptDelegateCompat",
		TEXT(R"(
delegate int FNativeCallback(int Value, const FString& Label);
event void FNativeEvent(int Value, const FString& Label);

int Entry()
{
	UObject TestObject = FindClass("UAngelscriptNativeScriptTestObject").GetDefaultObject();

	FNativeCallback Single;
	if (Single.IsBound())
		return 5;

	Single.BindUFunction(TestObject, n"NativeIntStringEvent");
	if (!Single.IsBound())
		return 10;
	if (!Single.GetFunctionName().IsEqual(n"NativeIntStringEvent"))
		return 15;

	FNativeEvent Multi;
	if (Multi.IsBound())
		return 20;

	Multi.AddUFunction(TestObject, n"SetIntStringFromDelegate");
	if (!Multi.IsBound())
		return 25;

	Multi.Unbind(TestObject, n"SetIntStringFromDelegate");
	if (Multi.IsBound())
		return 30;

	Single.Clear();
	if (Single.IsBound())
		return 35;

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

	TestEqual(TEXT("Script delegate compat operations should behave as expected"), Result, 1);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptScriptDelegateExecuteBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASScriptDelegateExecuteCompat"));
	};

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASScriptDelegateExecuteCompat",
		TEXT(R"(
delegate int FNativeCallback(int Value, const FString& Label);
event void FNativeEvent(int Value, const FString& Label);

int Entry()
{
	UObject TestObject = FindClass("UAngelscriptNativeScriptTestObject").GetDefaultObject();
	if (TestObject == nullptr)
		return 10;

	FNativeCallback Single;
	Single.BindUFunction(TestObject, n"NativeIntStringEvent");
	if (!Single.IsBound())
		return 20;
	if (Single.Execute(7, "Alpha") != 12)
		return 30;

	FNativeEvent Multi;
	Multi.AddUFunction(TestObject, n"SetIntStringFromDelegate");
	if (!Multi.IsBound())
		return 40;

	Multi.Broadcast(7, "Alpha");
	Multi.Unbind(TestObject, n"SetIntStringFromDelegate");
	if (Multi.IsBound())
		return 50;

	Multi.Broadcast(11, "Beta");
	Single.Clear();
	if (Single.IsBound())
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

	UAngelscriptNativeScriptTestObject* NativeTestObject = GetMutableDefault<UAngelscriptNativeScriptTestObject>();
	if (!TestNotNull(TEXT("Script delegate execute compat test should resolve the native test object default instance"), NativeTestObject))
	{
		return false;
	}

	NativeTestObject->NameCounts.Reset();
	ON_SCOPE_EXIT
	{
		NativeTestObject->NameCounts.Reset();
	};

	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *Function, Result))
	{
		return false;
	}

	const int32* AlphaCount = NativeTestObject->NameCounts.Find(TEXT("Alpha"));
	TestEqual(TEXT("Script delegate execute compat operations should behave as expected"), Result, 1);
	TestNotNull(TEXT("Multicast delegate broadcast should write the expected label key"), AlphaCount);
	if (AlphaCount != nullptr)
	{
		TestEqual(TEXT("Multicast delegate broadcast should forward the expected value"), *AlphaCount, 7);
	}
	TestFalse(TEXT("Unbound multicast delegate should not write additional label entries"), NativeTestObject->NameCounts.Contains(TEXT("Beta")));
	bPassed = Result == 1 && AlphaCount != nullptr && *AlphaCount == 7 && !NativeTestObject->NameCounts.Contains(TEXT("Beta"));
	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

bool FAngelscriptSoftPathBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASSoftPathCompat"));
	};

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASSoftPathCompat",
		TEXT(R"(
int Entry()
{
	FSoftObjectPath EmptyPath;
	if (!EmptyPath.IsNull())
		return 10;

	FSoftObjectPath ObjectPath(AActor::StaticClass().GetPathName());
	if (!ObjectPath.IsValid())
		return 20;
	if (ObjectPath.GetAssetName().IsEmpty())
		return 30;
	if (ObjectPath.GetLongPackageName().IsEmpty())
		return 40;
	if (ObjectPath.IsSubobject())
		return 50;
	if (!(ObjectPath == FSoftObjectPath(AActor::StaticClass().GetPathName())))
		return 60;

	FSoftClassPath ClassPath(AActor::StaticClass().GetPathName());
	if (!ClassPath.IsValid())
		return 70;
	if (ClassPath.GetAssetName().IsEmpty())
		return 80;
	if (ClassPath.GetLongPackageName().IsEmpty())
		return 90;
	if (ClassPath.IsSubobject())
		return 100;

	FSoftClassPath Copy = ClassPath;
	if (!(Copy.ToString() == ClassPath.ToString()))
		return 110;
	if (Copy.ToString().IsEmpty())
		return 120;

	FSoftClassPath FromString(ClassPath.ToString());
	if (!(FromString.ToString() == ClassPath.ToString()))
		return 130;

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

	TestEqual(TEXT("SoftPath compat operations should behave as expected"), Result, 1);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptSoftPathResolveBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASSoftPathResolveCompat"));
	};

	UClass* NativeActorClass = AActor::StaticClass();
	if (!TestNotNull(TEXT("SoftPath resolve compat test should resolve the native actor class baseline"), NativeActorClass))
	{
		return false;
	}

	const FSoftObjectPath NativeObjectPath(NativeActorClass);
	const FSoftClassPath NativeClassPath(NativeActorClass);
	const FString ExpectedObjectPathString = NativeObjectPath.ToString();
	const FString ExpectedClassPathString = NativeClassPath.ToString();
	const FString ExpectedAssetName = NativeObjectPath.GetAssetName();
	const FString ExpectedLongPackageName = NativeObjectPath.GetLongPackageName();
	const FString ExpectedObjectAssetPathString = NativeObjectPath.GetAssetPath().ToString();
	const FString ExpectedClassAssetPathString = NativeClassPath.GetAssetPath().ToString();

	if (!TestTrue(TEXT("Native soft object path baseline should be valid"), NativeObjectPath.IsValid())
		|| !TestTrue(TEXT("Native soft class path baseline should be valid"), NativeClassPath.IsValid())
		|| !TestEqual(TEXT("Native soft object path should resolve the actor class"), NativeObjectPath.ResolveObject(), static_cast<UObject*>(NativeActorClass))
		|| !TestEqual(TEXT("Native soft class path should resolve the actor class"), NativeClassPath.ResolveClass(), NativeActorClass))
	{
		return false;
	}

	FString Script = TEXT(R"(
int Entry()
{
	FSoftObjectPath ObjectPath("__OBJECT_PATH__");
	if (!ObjectPath.IsValid())
		return 10;
	if (!(ObjectPath.ToString() == "__OBJECT_PATH__"))
		return 20;
	if (!(ObjectPath.GetAssetName() == "__ASSET_NAME__"))
		return 30;
	if (!(ObjectPath.GetLongPackageName() == "__PACKAGE_NAME__"))
		return 40;
	if (!(ObjectPath.GetAssetPath() == FTopLevelAssetPath("__OBJECT_ASSET_PATH__")))
		return 50;
	if (!(ObjectPath.ResolveObject() == AActor::StaticClass()))
		return 60;
	if (!(ObjectPath.TryLoad() == AActor::StaticClass()))
		return 70;

	FSoftClassPath ClassPath("__CLASS_PATH__");
	if (!ClassPath.IsValid())
		return 80;
	if (!(ClassPath.ToString() == "__CLASS_PATH__"))
		return 90;
	if (!(ClassPath.GetAssetName() == "__ASSET_NAME__"))
		return 100;
	if (!(ClassPath.GetLongPackageName() == "__PACKAGE_NAME__"))
		return 110;
	if (!(ClassPath.GetAssetPath() == FTopLevelAssetPath("__CLASS_ASSET_PATH__")))
		return 120;
	if (!(ClassPath.ResolveClass() == AActor::StaticClass()))
		return 130;
	if (!(ClassPath.TryLoadClass() == AActor::StaticClass()))
		return 140;

	return 1;
}
)");

	Script.ReplaceInline(TEXT("__OBJECT_PATH__"), *ExpectedObjectPathString.ReplaceCharWithEscapedChar());
	Script.ReplaceInline(TEXT("__CLASS_PATH__"), *ExpectedClassPathString.ReplaceCharWithEscapedChar());
	Script.ReplaceInline(TEXT("__ASSET_NAME__"), *ExpectedAssetName.ReplaceCharWithEscapedChar());
	Script.ReplaceInline(TEXT("__PACKAGE_NAME__"), *ExpectedLongPackageName.ReplaceCharWithEscapedChar());
	Script.ReplaceInline(TEXT("__OBJECT_ASSET_PATH__"), *ExpectedObjectAssetPathString.ReplaceCharWithEscapedChar());
	Script.ReplaceInline(TEXT("__CLASS_ASSET_PATH__"), *ExpectedClassAssetPathString.ReplaceCharWithEscapedChar());

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASSoftPathResolveCompat",
		Script);
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

	bPassed = TestEqual(TEXT("SoftPath resolve compat operations should behave as expected"), Result, 1);
	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

bool FAngelscriptSourceMetadataBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN

	const FString Script = TEXT(R"AS(
UCLASS()
class UBindingSourceMetadataCarrier : UObject
{
	UFUNCTION()
	int ComputeValue()
	{
		return 7;
	}
}
)AS");
	const FString ScriptDirectory = FPaths::ConvertRelativePathToFull(FPaths::ProjectDir() / TEXT("Script/Automation"));
	IFileManager::Get().MakeDirectory(*ScriptDirectory, true);
	const FString ScriptPath = ScriptDirectory / TEXT("RuntimeSourceMetadataBindingsTest.as");
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASSourceMetadataQuery"));
		Engine.DiscardModule(TEXT("RuntimeSourceMetadataBindingsTest"));
		IFileManager::Get().Delete(*ScriptPath, false, true, true);
	};

	if (!TestTrue(TEXT("Write source metadata script file should succeed"), FFileHelper::SaveStringToFile(Script, *ScriptPath)))
	{
		return false;
	}

	const bool bAnnotatedCompiled = CompileAnnotatedModuleFromMemory(&Engine, TEXT("RuntimeSourceMetadataBindingsTest"), ScriptPath, Script);
	if (!TestTrue(TEXT("Compile annotated source metadata module should succeed"), bAnnotatedCompiled))
	{
		return false;
	}

	FString RuntimeScript = TEXT(R"AS(
int Entry()
{
	UClass Type = FindClass("UBindingSourceMetadataCarrier");
	if (Type == null)
		return 10;
	if (!(Type.GetSourceFilePath() == "__SCRIPT_PATH__"))
		return 20;
	if (!Type.GetScriptModuleName().Contains("RuntimeSourceMetadataBindingsTest"))
		return 30;
	if (Type.GetScriptTypeDeclaration().IsEmpty())
		return 35;
	if (!Type.IsFunctionImplementedInScript(n"ComputeValue"))
		return 37;

	UFunction Func = Type.FindFunctionByName(n"ComputeValue");
	if (Func == null)
		return 40;
	if (!(Func.GetSourceFilePath() == "__SCRIPT_PATH__"))
		return 50;
	if (Func.GetSourceLineNumber() != 6)
		return 60;
	if (!(Func.GetScriptFunctionDeclaration() == "int ComputeValue()"))
		return 70;

	return 1;
}
)AS");
	RuntimeScript.ReplaceInline(TEXT("__SCRIPT_PATH__"), *ScriptPath.ReplaceCharWithEscapedChar());

	asIScriptModule* Module = BuildModule(*this, Engine, "ASSourceMetadataQuery", RuntimeScript);
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
	const bool bExecuted = ExecuteIntFunction(*this, Engine, *Function, Result);
	if (!TestTrue(TEXT("Execute source metadata accessor function should succeed"), bExecuted))
	{
		return false;
	}

	TestEqual(TEXT("Source metadata accessors should behave as expected"), Result, 1);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptFileHelperBindingsTest::RunTest(const FString& Parameters)
{
	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASFileHelperCompat"));
	};

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		"ASFileHelperCompat",
		TEXT(R"(
int Entry()
{
	FString Filename = FPaths::CombinePaths(FPaths::ProjectSavedDir(), "AngelscriptFileHelperCompat.txt");
	if (!FFileHelper::SaveStringToFile("HelloFileHelper", Filename))
		return 10;

	FString Loaded;
	if (!FFileHelper::LoadFileToString(Loaded, Filename))
		return 20;
	if (!(Loaded == "HelloFileHelper"))
		return 30;

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

	TestEqual(TEXT("FileHelper compat operations should behave as expected"), Result, 1);
	ASTEST_END_SHARE_CLEAN

	return true;
}

bool FAngelscriptDelegateWithPayloadBindingsTest::RunTest(const FString& Parameters)
{
	bool bPassed = false;
	AddExpectedError(TEXT("Invalid payload type"), EAutomationExpectedErrorFlags::Contains, 1);
	AddExpectedError(TEXT("Invalid object passed to BindUFunction."), EAutomationExpectedErrorFlags::Contains, 1);
	AddExpectedError(TEXT("Specified function is not compatible with delegate function."), EAutomationExpectedErrorFlags::Contains, 1);
	AddExpectedError(TEXT("ASDelegateWithPayloadCompat"), EAutomationExpectedErrorFlags::Contains, 0);
	AddExpectedError(TEXT("void TriggerInvalidPayloadType()"), EAutomationExpectedErrorFlags::Contains, 0, false);
	AddExpectedError(TEXT("void TriggerInvalidObject()"), EAutomationExpectedErrorFlags::Contains, 0, false);
	AddExpectedError(TEXT("void TriggerSignatureMismatch()"), EAutomationExpectedErrorFlags::Contains, 0, false);

	FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
	ASTEST_BEGIN_SHARE_CLEAN
	ON_SCOPE_EXIT
	{
		Engine.DiscardModule(TEXT("ASDelegateWithPayloadCompat"));
	};

	asIScriptModule* Module = BuildModule(
		*this,
		Engine,
		DelegateWithPayloadCompatModuleName,
		TEXT(R"(
int Entry()
{
	UObject TestObject = FindClass("UAngelscriptNativeScriptTestObject").GetDefaultObject();
	if (TestObject == nullptr)
		return 10;

	FAngelscriptDelegateWithPayload NoPayloadDelegate;
	if (NoPayloadDelegate.IsBound())
		return 20;

	NoPayloadDelegate.ExecuteIfBound();
	NoPayloadDelegate.BindUFunction(TestObject, n"MarkNativeFlagFromDelegate");
	if (!NoPayloadDelegate.IsBound())
		return 30;

	NoPayloadDelegate.ExecuteIfBound();

	int PayloadValue = 123;
	FAngelscriptDelegateWithPayload PayloadDelegate;
	PayloadDelegate.BindWithPayload(TestObject, n"SetLargeCountFromDelegate", PayloadValue);
	if (!PayloadDelegate.IsBound())
		return 40;

	PayloadDelegate.ExecuteIfBound();

	return 1;
}

void TriggerInvalidPayloadType()
{
	UObject TestObject = FindClass("UAngelscriptNativeScriptTestObject").GetDefaultObject();
	UObject PayloadObject = TestObject;

	FAngelscriptDelegateWithPayload Delegate;
	Delegate.BindWithPayload(TestObject, n"SetLargeCountFromDelegate", PayloadObject);
}

void TriggerInvalidObject()
{
	FAngelscriptDelegateWithPayload Delegate;
	Delegate.BindUFunction(nullptr, n"MarkNativeFlagFromDelegate");
}

void TriggerSignatureMismatch()
{
	UObject TestObject = FindClass("UAngelscriptNativeScriptTestObject").GetDefaultObject();

	FAngelscriptDelegateWithPayload Delegate;
	Delegate.BindWithPayload(TestObject, n"MarkNativeFlagFromDelegate", 7);
}
)"));
	if (Module == nullptr)
	{
		return false;
	}

	asIScriptFunction* EntryFunction = GetFunctionByDecl(*this, *Module, TEXT("int Entry()"));
	if (EntryFunction == nullptr)
	{
		return false;
	}

	UAngelscriptNativeScriptTestObject* NativeTestObject = GetMutableDefault<UAngelscriptNativeScriptTestObject>();
	if (!TestNotNull(TEXT("DelegateWithPayload compat test should resolve the native test object default instance"), NativeTestObject))
	{
		return false;
	}

	NativeTestObject->bNativeFlag = false;
	NativeTestObject->LargeCount = 0;

	int32 Result = 0;
	if (!ExecuteIntFunction(*this, Engine, *EntryFunction, Result))
	{
		return false;
	}

	const bool bHappyPath =
		TestEqual(TEXT("DelegateWithPayload compat happy path should execute both no-payload and payload bindings"), Result, 1)
		&& TestTrue(TEXT("DelegateWithPayload compat happy path should execute the bound no-payload native function"), NativeTestObject->bNativeFlag)
		&& TestEqual(TEXT("DelegateWithPayload compat happy path should forward the boxed int payload to the native function"), NativeTestObject->LargeCount, static_cast<int64>(123));

	FString InvalidPayloadException;
	int32 InvalidPayloadLine = 0;
	const bool bInvalidPayload = ExecuteFunctionExpectingException(
			*this,
			Engine,
			*Module,
			TEXT("void TriggerInvalidPayloadType()"),
			TEXT("DelegateWithPayload invalid payload type"),
			InvalidPayloadException,
			InvalidPayloadLine)
		&& TestTrue(TEXT("DelegateWithPayload invalid payload type should mention the payload contract"), InvalidPayloadException.Contains(TEXT("Invalid payload type")))
		&& TestTrue(TEXT("DelegateWithPayload invalid payload type should report a positive exception line"), InvalidPayloadLine > 0);

	FString InvalidObjectException;
	int32 InvalidObjectLine = 0;
	const bool bInvalidObject = ExecuteFunctionExpectingException(
			*this,
			Engine,
			*Module,
			TEXT("void TriggerInvalidObject()"),
			TEXT("DelegateWithPayload invalid object"),
			InvalidObjectException,
			InvalidObjectLine)
		&& TestTrue(TEXT("DelegateWithPayload invalid object should mention the invalid object contract"), InvalidObjectException.Contains(TEXT("Invalid object passed to BindUFunction.")))
		&& TestTrue(TEXT("DelegateWithPayload invalid object should report a positive exception line"), InvalidObjectLine > 0);

	FString SignatureMismatchException;
	int32 SignatureMismatchLine = 0;
	const bool bSignatureMismatch = ExecuteFunctionExpectingException(
			*this,
			Engine,
			*Module,
			TEXT("void TriggerSignatureMismatch()"),
			TEXT("DelegateWithPayload signature mismatch"),
			SignatureMismatchException,
			SignatureMismatchLine)
		&& TestTrue(TEXT("DelegateWithPayload signature mismatch should mention the compatibility contract"), SignatureMismatchException.Contains(TEXT("Specified function is not compatible with delegate function.")))
		&& TestTrue(TEXT("DelegateWithPayload signature mismatch should report a positive exception line"), SignatureMismatchLine > 0);

	bPassed = bHappyPath && bInvalidPayload && bInvalidObject && bSignatureMismatch;
	ASTEST_END_SHARE_CLEAN

	return bPassed;
}

#endif
