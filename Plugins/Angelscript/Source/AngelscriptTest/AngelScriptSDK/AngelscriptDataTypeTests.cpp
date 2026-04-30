#include "Shared/AngelscriptTestUtilities.h"
#include "Shared/AngelscriptTestMacros.h"
#include "CQTest.h"

#include "StartAngelscriptHeaders.h"
#include "source/as_datatype.h"
#include "source/as_scriptengine.h"
#include "EndAngelscriptHeaders.h"

#if WITH_DEV_AUTOMATION_TESTS

TEST_CLASS_WITH_FLAGS(FAngelscriptDataTypeTests,
	"Angelscript.TestModule.AngelScriptSDK.DataType",
	EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)
{
	TEST_METHOD(Primitives)
	{
		asCDataType IntType = asCDataType::CreatePrimitive(ttInt, false);
		asCDataType FloatType = asCDataType::CreatePrimitive(ttFloat32, false);
		asCDataType BoolType = asCDataType::CreatePrimitive(ttBool, false);
		asCDataType VoidType = asCDataType::CreatePrimitive(ttVoid, false);
		asCDataType NullHandleType = asCDataType::CreateNullHandle();

		TestTrue(TEXT("int data type should be valid and primitive"), IntType.IsValid() && IntType.IsPrimitive() && IntType.IsIntegerType());
		TestTrue(TEXT("float32 data type should report float semantics"), FloatType.IsPrimitive() && FloatType.IsFloat32Type() && FloatType.IsMathType());
		TestTrue(TEXT("bool data type should report boolean semantics"), BoolType.IsPrimitive() && BoolType.IsBooleanType());
		TestFalse(TEXT("void data type should not be instantiable"), VoidType.CanBeInstantiated());
		TestTrue(TEXT("null handle data type should report object-handle semantics"), NullHandleType.IsNullHandle() && NullHandleType.IsObjectHandle());
	}

	TEST_METHOD(Comparisons)
	{
		asCDataType MutableInt = asCDataType::CreatePrimitive(ttInt, false);
		asCDataType ConstInt = asCDataType::CreatePrimitive(ttInt, true);
		asCDataType RefInt = asCDataType::CreatePrimitive(ttInt, false);
		RefInt.MakeReference(true);

		TestTrue(TEXT("Constness should be ignored by IsEqualExceptConst"), MutableInt.IsEqualExceptConst(ConstInt));
		TestFalse(TEXT("Constness should still matter for exact equality"), MutableInt == ConstInt);
		TestTrue(TEXT("Reference-ness should be ignored by IsEqualExceptRef"), MutableInt.IsEqualExceptRef(RefInt));
		TestFalse(TEXT("Reference-ness should still matter for exact equality"), MutableInt == RefInt);
	}

	TEST_METHOD(HandleQualifierMatrix)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
		ASTEST_BEGIN_SHARE_CLEAN
		asCScriptEngine* ScriptEngine = static_cast<asCScriptEngine*>(Engine.GetScriptEngine());
		asCTypeInfo* ActorType = static_cast<asCTypeInfo*>(ScriptEngine->GetTypeInfoByName("AActor"));
		if (!TestNotNull(TEXT("AActor should exist in the script type system for handle qualifier comparisons"), ActorType))
		{
			return;
		}

		asCDataType ActorValueType = asCDataType::CreateType(ActorType, false);
		asCDataType ActorHandleType = asCDataType::CreateObjectHandle(ActorType, false);
		asCDataType ConstActorHandleType = asCDataType::CreateObjectHandle(ActorType, true);
		asCDataType RefConstActorHandleType = ConstActorHandleType;
		RefConstActorHandleType.MakeReference(true);
		asCDataType NullHandleType = asCDataType::CreateNullHandle();

		if (!TestTrue(TEXT("Object handle matrix should preserve the target type info"), ActorHandleType.GetTypeInfo() == ActorType))
		{
			return;
		}
		if (!TestFalse(TEXT("Exact equality should distinguish mutable and const handles"), ActorHandleType == ConstActorHandleType))
		{
			return;
		}
		if (!TestTrue(TEXT("IsEqualExceptConst should ignore handle constness"), ActorHandleType.IsEqualExceptConst(ConstActorHandleType)))
		{
			return;
		}
		if (!TestTrue(TEXT("IsEqualExceptRefAndConst should ignore both reference and const on handles"), ActorHandleType.IsEqualExceptRefAndConst(RefConstActorHandleType)))
		{
			return;
		}
		if (!TestFalse(TEXT("Null handle should not be exactly equal to a typed object handle"), NullHandleType == ActorHandleType))
		{
			return;
		}
		if (!TestTrue(TEXT("Null handle should still report object-handle semantics"), NullHandleType.IsObjectHandle() && NullHandleType.IsNullHandle()))
		{
			return;
		}
		if (!TestTrue(TEXT("Value type and object handle should keep different kind semantics"), ActorValueType.IsObject() && ActorHandleType.IsObjectHandle()))
		{
			return;
		}

		ASTEST_END_SHARE_CLEAN
	}

	TEST_METHOD(ObjectHandles)
	{
		FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
		ASTEST_BEGIN_SHARE_CLEAN
		asCScriptEngine* ScriptEngine = static_cast<asCScriptEngine*>(Engine.GetScriptEngine());
		asCTypeInfo* ActorType = static_cast<asCTypeInfo*>(ScriptEngine->GetTypeInfoByName("AActor"));
		if (!TestNotNull(TEXT("AActor should exist in the script type system for data-type handle tests"), ActorType))
		{
			return;
		}

		asCDataType ActorValueType = asCDataType::CreateType(ActorType, false);
		TestTrue(TEXT("AActor value type should be recognized as an object type"), ActorValueType.IsObject());
		TestTrue(TEXT("AActor value type should support handles"), ActorValueType.SupportHandles());

		asCDataType ActorHandleType = asCDataType::CreateObjectHandle(ActorType, false);
		TestTrue(TEXT("CreateObjectHandle should mark the type as an object handle"), ActorHandleType.IsObjectHandle());
		TestTrue(TEXT("Object handle should still be considered instantiable as a handle slot"), ActorHandleType.CanBeInstantiated());
		ASTEST_END_SHARE_CLEAN
	}

	TEST_METHOD(SizeAndAlignment)
	{
		asCDataType IntType = asCDataType::CreatePrimitive(ttInt, false);
		asCDataType Float64Type = asCDataType::CreatePrimitive(ttFloat64, false);
		asCDataType BoolType = asCDataType::CreatePrimitive(ttBool, false);

		TestEqual(TEXT("int should occupy one dword in memory"), IntType.GetSizeInMemoryDWords(), 1);
		TestEqual(TEXT("float64 should occupy eight bytes in memory"), Float64Type.GetSizeInMemoryBytes(), 8);
		TestEqual(TEXT("bool alignment should stay byte-sized"), BoolType.GetAlignment(), 1);
	}
};

#endif
