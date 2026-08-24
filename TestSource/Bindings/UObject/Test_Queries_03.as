// Purpose: Observe UClass hierarchy/function lookup, UClass namespace
// class listing, and UFunction script-source helpers.
// AS-facing API: UFunction UClass.FindFunctionByName(FName InFunctionName) const;
// bool UClass.IsChildOf(UClass Other) const; bool UClass.IsAbstract() const;
// UClass UClass.GetSuperClass() const;
// UClass UClass::FindClass(const FString& Name);
// void UClass::GetAllClasses(TArray<UClass>& OutClasses);
// TArray<UClass> UClass::GetAllSubclassesOf(UClass Class, bool bIncludeAbstractClasses = false);
// FString UFunction.GetSourceFilePath() const;
// int UFunction.GetSourceLineNumber() const;
// FString UFunction.GetScriptFunctionDeclaration() const;
// Inputs: UTSObjectQueries03Carrier::StaticClass(), n"ReadStoredValue" vs
// n"MissingFunction", AActor/APawn/UObject, FindClass("Actor"), empty OutClasses,
// bIncludeAbstractClasses false/true, and runner-supplied abstract expectation.
// Expected observations: returned bool is the exact comparison.
// Boundary/ownership: OutClasses is a caller-owned writeback of borrowed
// UClass handles. Function source helpers return copies.

UCLASS()
class UTSObjectQueries03Carrier : UObject
{
	UFUNCTION()
	int ReadStoredValue()
	{
		return 7;
	}
}

namespace TS_UObject_Queries_03
{
	bool Observe_FindFunctionByName_Nominal()
	{
		UClass ScriptClass = UTSObjectQueries03Carrier::StaticClass();
		if (ScriptClass is null)
		{
			throw("TS_UObject_Queries_03 setup: required ScriptClass is null");
		}
		UFunction Found = ScriptClass.FindFunctionByName(n"ReadStoredValue");
		UFunction Missing = ScriptClass.FindFunctionByName(n"MissingFunction");
		UFunction NoneFunction = ScriptClass.FindFunctionByName(NAME_None);
		return Found != nullptr && Missing is null && NoneFunction is null;
	}

	bool Observe_IsChildOf_Nominal()
	{
		UClass PawnClass = APawn::StaticClass();
		UClass ActorClass = AActor::StaticClass();
		UClass ObjectClass = UObject::StaticClass();
		UClass TextureClass = UTexture2D::StaticClass();
		if (PawnClass is null)
		{
			throw("TS_UObject_Queries_03 setup: required PawnClass is null");
		}
		if (ActorClass is null)
		{
			throw("TS_UObject_Queries_03 setup: required ActorClass is null");
		}
		if (ObjectClass is null)
		{
			throw("TS_UObject_Queries_03 setup: required ObjectClass is null");
		}
		if (TextureClass is null)
		{
			throw("TS_UObject_Queries_03 setup: required TextureClass is null");
		}
		return PawnClass.IsChildOf(ActorClass) && PawnClass.IsChildOf(PawnClass) && PawnClass.IsChildOf(ObjectClass) && !PawnClass.IsChildOf(TextureClass);
	}

	bool Observe_IsAbstract_Nominal(UClass Class, bool bExpectAbstract)
	{
		if (Class is null)
		{
			throw("TS_UObject_Queries_03 setup: required Class is null");
		}
		UClass TextureClass = UTexture2D::StaticClass();
		UClass ScriptClass = UTSObjectQueries03Carrier::StaticClass();
		if (TextureClass is null)
		{
			throw("TS_UObject_Queries_03 setup: required TextureClass is null");
		}
		if (ScriptClass is null)
		{
			throw("TS_UObject_Queries_03 setup: required ScriptClass is null");
		}
		return Class.IsAbstract() == bExpectAbstract && !TextureClass.IsAbstract() && !ScriptClass.IsAbstract();
	}

	bool Observe_GetSuperClass_Nominal()
	{
		UClass ScriptClass = UTSObjectQueries03Carrier::StaticClass();
		if (ScriptClass is null)
		{
			throw("TS_UObject_Queries_03 setup: required ScriptClass is null");
		}
		UClass ScriptSuper = ScriptClass.GetSuperClass();
		UClass PawnClass = APawn::StaticClass();
		if (PawnClass is null)
		{
			throw("TS_UObject_Queries_03 setup: required PawnClass is null");
		}
		UClass PawnSuper = PawnClass.GetSuperClass();
		UClass ObjectClass = UObject::StaticClass();
		if (ObjectClass is null)
		{
			throw("TS_UObject_Queries_03 setup: required ObjectClass is null");
		}
		UClass ObjectSuper = ObjectClass.GetSuperClass();
		return ScriptSuper == UObject::StaticClass() && PawnSuper != nullptr && ObjectSuper is null;
	}

	bool Observe_FindClass_Nominal()
	{
		UClass ActorClass = UClass::FindClass("Actor");
		UClass TextureClass = UClass::FindClass("Texture2D");
		UClass Missing = UClass::FindClass("DefinitelyMissingClass");
		UClass Empty = UClass::FindClass("");
		return ActorClass != nullptr && TextureClass != nullptr && Missing is null && Empty is null;
	}

	bool Observe_GetAllClasses_Nominal()
	{
		TArray<UClass> OutClasses;
		int32 Before = OutClasses.Num();
		UClass::GetAllClasses(OutClasses);
		int32 After = OutClasses.Num();
		bool bContainsObject = false;
		for (int32 Index = 0; Index < OutClasses.Num(); ++Index)
		{
			if (OutClasses[Index] == UObject::StaticClass())
			{
				bContainsObject = true;
				break;
			}
		}
		return Before == 0 && After > 0 && bContainsObject;
	}

	bool Observe_GetAllSubclassesOf_Nominal()
	{
		UClass ActorClass = AActor::StaticClass();
		if (ActorClass is null)
		{
			throw("TS_UObject_Queries_03 setup: required ActorClass is null");
		}
		TArray<UClass> Concrete = UClass::GetAllSubclassesOf(ActorClass);
		TArray<UClass> WithAbstract = UClass::GetAllSubclassesOf(ActorClass, true);
		TArray<UClass> WithoutAbstract = UClass::GetAllSubclassesOf(ActorClass, false);
		return Concrete.Num() > 0 && WithAbstract.Num() >= WithoutAbstract.Num();
	}

	bool Observe_GetSourceFilePath_Nominal()
	{
		UClass ScriptClass = UTSObjectQueries03Carrier::StaticClass();
		if (ScriptClass is null)
		{
			throw("TS_UObject_Queries_03 setup: required ScriptClass is null");
		}
		UFunction ScriptFunction = ScriptClass.FindFunctionByName(n"ReadStoredValue");
		if (ScriptFunction is null)
		{
			throw("TS_UObject_Queries_03 setup: required ScriptFunction is null");
		}
		FString ScriptPath = ScriptFunction.GetSourceFilePath();
		return ScriptPath.Len() > 0;
	}

	bool Observe_GetSourceLineNumber_Nominal()
	{
		UClass ScriptClass = UTSObjectQueries03Carrier::StaticClass();
		if (ScriptClass is null)
		{
			throw("TS_UObject_Queries_03 setup: required ScriptClass is null");
		}
		UFunction ScriptFunction = ScriptClass.FindFunctionByName(n"ReadStoredValue");
		if (ScriptFunction is null)
		{
			throw("TS_UObject_Queries_03 setup: required ScriptFunction is null");
		}
		int ScriptLine = ScriptFunction.GetSourceLineNumber();
		return ScriptLine > 0;
	}

	bool Observe_GetScriptFunctionDeclaration_Nominal()
	{
		UClass ScriptClass = UTSObjectQueries03Carrier::StaticClass();
		if (ScriptClass is null)
		{
			throw("TS_UObject_Queries_03 setup: required ScriptClass is null");
		}
		UFunction ScriptFunction = ScriptClass.FindFunctionByName(n"ReadStoredValue");
		if (ScriptFunction is null)
		{
			throw("TS_UObject_Queries_03 setup: required ScriptFunction is null");
		}
		FString ScriptDecl = ScriptFunction.GetScriptFunctionDeclaration();
		return ScriptDecl.Len() > 0 && ScriptDecl.Contains("ReadStoredValue");
	}
}
