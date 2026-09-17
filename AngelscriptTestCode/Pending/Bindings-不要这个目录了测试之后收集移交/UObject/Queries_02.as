/**
 * @version v1
 * @summary Observe UObject name/path/IsA/IsValid queries and UClass script declaration helpers.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe UObject name/path/IsA/IsValid queries and UClass script declaration helpers.
 * @topic Baseline
 */
// Runner owns the Object fixture. Script-class helpers use the in-file carrier.
// AS-facing API: FName UObject.GetName() const;
// FString UObject.GetFullName(const UObject StopOuter = nullptr) const;
// FString UObject.GetPathName(const UObject StopOuter = nullptr) const;
// bool UObject.IsA(const UClass Class) const; bool IsValid(const UObject Object);
// UObject UClass.GetDefaultObject() const;
// FString UClass.GetSourceFilePath() const;
// FString UClass.GetScriptModuleName() const;
// FString UClass.GetScriptTypeDeclaration() const;
// bool UClass.IsFunctionImplementedInScript(FName InFunctionName) const;
// Inputs: Runner-owned UObject, StopOuter, Matching/NonMatching classes, and
// n"ReadStoredValue" vs n"MissingFunction" on the script carrier.
// Expected observations: returned bool is the exact comparison.
// Boundary/ownership: Name/path strings are copies. GetDefaultObject returns
// the CDO without transferring ownership. Calling GetDefaultObject on a null
// UClass is the invalid-class diagnostic path.

UCLASS()
class UTSObjectQueries02Carrier : UObject
{
	UPROPERTY()
	int StoredValue = 7;

	UFUNCTION()
	int ReadStoredValue()
	{
		return StoredValue;
	}
}

namespace TS_UObject_Queries_02
{
	bool Observe_GetName_Nominal(UObject Object, const FName& Expected)
	{
		if (Object is null)
		{
			throw("TS_UObject_Queries_02 setup: required Object is null");
		}
		return Object.GetName() == Expected;
	}

	bool Observe_GetFullName_Nominal(UObject Object, UObject StopOuter, const FString& ExpectedName)
	{
		if (Object is null)
		{
			throw("TS_UObject_Queries_02 setup: required Object is null");
		}
		FString Full = Object.GetFullName();
		FString Stopped = Object.GetFullName(StopOuter);
		FString WithNullStop = Object.GetFullName(nullptr);
		return Full.Contains(ExpectedName) && Stopped.Len() > 0 && WithNullStop.Len() > 0;
	}

	bool Observe_GetPathName_Nominal(UObject Object, UObject StopOuter, const FString& ExpectedName)
	{
		if (Object is null)
		{
			throw("TS_UObject_Queries_02 setup: required Object is null");
		}
		FString Path = Object.GetPathName();
		FString Stopped = Object.GetPathName(StopOuter);
		FString WithNullStop = Object.GetPathName(nullptr);
		return Path.Contains(ExpectedName) && Stopped.Len() > 0 && WithNullStop.Len() > 0;
	}

	bool Observe_IsA_Nominal(UObject Object, UClass Matching, UClass NonMatching)
	{
		if (Object is null)
		{
			throw("TS_UObject_Queries_02 setup: required Object is null");
		}
		if (Matching is null)
		{
			throw("TS_UObject_Queries_02 setup: required Matching class is null");
		}
		if (NonMatching is null)
		{
			throw("TS_UObject_Queries_02 setup: required NonMatching class is null");
		}
		return Object.IsA(Matching) && Object.IsA(UObject::StaticClass()) && !Object.IsA(NonMatching);
	}

	bool Observe_IsValid_Nominal(UObject Object)
	{
		if (Object is null)
		{
			throw("TS_UObject_Queries_02 setup: required Object is null");
		}
		UObject NullObject = nullptr;
		return IsValid(Object) && !IsValid(NullObject) && !IsValid(null);
	}

	bool Observe_GetDefaultObject_Nominal(UClass Class)
	{
		if (Class is null)
		{
			throw("TS_UObject_Queries_02 setup: required Class is null");
		}
		UObject Cdo = Class.GetDefaultObject();
		UClass ScriptClass = UTSObjectQueries02Carrier::StaticClass();
		if (ScriptClass is null)
		{
			throw("TS_UObject_Queries_02 setup: required ScriptClass is null");
		}
		UObject ScriptCdo = ScriptClass.GetDefaultObject();
		return Cdo != nullptr && Cdo.IsA(Class) && ScriptCdo != nullptr;
	}

	bool Observe_GetSourceFilePath_Nominal()
	{
		UClass NativeClass = UTexture2D::StaticClass();
		if (NativeClass is null)
		{
			throw("TS_UObject_Queries_02 setup: required NativeClass is null");
		}
		FString NativePath = NativeClass.GetSourceFilePath();
		UClass ScriptClass = UTSObjectQueries02Carrier::StaticClass();
		if (ScriptClass is null)
		{
			throw("TS_UObject_Queries_02 setup: required ScriptClass is null");
		}
		FString ScriptPath = ScriptClass.GetSourceFilePath();
		return NativePath.Len() == 0 && ScriptPath.Len() > 0;
	}

	bool Observe_GetScriptModuleName_Nominal()
	{
		UClass NativeClass = UTexture2D::StaticClass();
		if (NativeClass is null)
		{
			throw("TS_UObject_Queries_02 setup: required NativeClass is null");
		}
		FString NativeModule = NativeClass.GetScriptModuleName();
		UClass ScriptClass = UTSObjectQueries02Carrier::StaticClass();
		if (ScriptClass is null)
		{
			throw("TS_UObject_Queries_02 setup: required ScriptClass is null");
		}
		FString ScriptModule = ScriptClass.GetScriptModuleName();
		return NativeModule.Len() == 0 && ScriptModule.Len() > 0;
	}

	bool Observe_GetScriptTypeDeclaration_Nominal()
	{
		UClass NativeClass = UTexture2D::StaticClass();
		if (NativeClass is null)
		{
			throw("TS_UObject_Queries_02 setup: required NativeClass is null");
		}
		FString NativeDecl = NativeClass.GetScriptTypeDeclaration();
		UClass ScriptClass = UTSObjectQueries02Carrier::StaticClass();
		if (ScriptClass is null)
		{
			throw("TS_UObject_Queries_02 setup: required ScriptClass is null");
		}
		FString ScriptDecl = ScriptClass.GetScriptTypeDeclaration();
		return NativeDecl.Len() == 0 && ScriptDecl.Len() > 0 && ScriptDecl.Contains("UTSObjectQueries02Carrier");
	}

	bool Observe_IsFunctionImplementedInScript_Nominal()
	{
		UClass NativeClass = UTexture2D::StaticClass();
		if (NativeClass is null)
		{
			throw("TS_UObject_Queries_02 setup: required NativeClass is null");
		}
		bool bNativeImplemented = NativeClass.IsFunctionImplementedInScript(n"ReadStoredValue");
		UClass ScriptClass = UTSObjectQueries02Carrier::StaticClass();
		if (ScriptClass is null)
		{
			throw("TS_UObject_Queries_02 setup: required ScriptClass is null");
		}
		bool bScriptImplemented = ScriptClass.IsFunctionImplementedInScript(n"ReadStoredValue");
		bool bMissingImplemented = ScriptClass.IsFunctionImplementedInScript(n"MissingFunction");
		bool bNoneImplemented = ScriptClass.IsFunctionImplementedInScript(NAME_None);
		return !bNativeImplemented && bScriptImplemented && !bMissingImplemented && !bNoneImplemented;
	}

	void ExerciseExpectedFailure()
	{
		UClass NullClass;
		UObject Cdo = NullClass.GetDefaultObject();
	}
}
/** @end */
