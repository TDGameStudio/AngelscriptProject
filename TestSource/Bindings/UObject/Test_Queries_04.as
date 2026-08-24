// Purpose: Observe global package getters, script-name class lookup, global
// GetAllClasses, and FindObject overloads.
// Runner owns the created object used for FindObject identity.
// AS-facing API: UPackage GetTransientPackage(); UPackage GetAngelscriptPackage();
// UClass FindClass(const FString& Name); void GetAllClasses(TArray<UClass>& OutClasses);
// UObject FindObject(const FString& Name);
// UObject FindObject(UObject Outer, const FString& Name);
// Inputs: Script names "UObject" and "Texture2D", runner-owned UObject path
// and short name, empty string, and a missing name.
// Expected observations: GetTransientPackage is non-null. GetAngelscriptPackage
// differs from the transient package. FindClass("Texture2D") matches
// UTexture2D::StaticClass(). Global GetAllClasses writes a non-empty list
// containing UTexture2D. FindObject by path and by outer+name finds the
// created object. Missing names return null.
// Boundary/ownership: Returned packages/classes/objects are borrowed engine
// handles. OutClasses is a caller-owned writeback.

namespace TS_UObject_Queries_04
{
	bool Observe_GetTransientPackage_Nominal()
	{
		UPackage Transient = GetTransientPackage();
		return Transient != nullptr;
	}

	bool Observe_GetAngelscriptPackage_Nominal()
	{
		UPackage ScriptPackage = GetAngelscriptPackage();
		return ScriptPackage != nullptr && ScriptPackage != GetTransientPackage();
	}

	bool Observe_FindClass_Nominal()
	{
		UClass TextureClass = FindClass("Texture2D");
		UClass ObjectClass = FindClass("UObject");
		UClass Missing = FindClass("DefinitelyMissingClass");
		UClass Empty = FindClass("");
		return TextureClass == UTexture2D::StaticClass() && ObjectClass == UObject::StaticClass() && Missing is null && Empty is null;
	}

	bool Observe_GetAllClasses_Nominal()
	{
		TArray<UClass> OutClasses;
		int32 Before = OutClasses.Num();
		GetAllClasses(OutClasses);
		int32 After = OutClasses.Num();
		bool bContainsTexture = false;
		for (int32 Index = 0; Index < OutClasses.Num(); ++Index)
		{
			if (OutClasses[Index] == UTexture2D::StaticClass())
			{
				bContainsTexture = true;
				break;
			}
		}
		return Before == 0 && After > 0 && bContainsTexture;
	}

	bool Observe_FindObject_Nominal(UObject Object)
	{
		if (Object is null)
		{
			throw("TS_UObject_Queries_04 setup: required Object is null");
		}
		UObject Outer = Object.GetOuter();
		FString PathName = Object.GetPathName();
		FString ShortName = Object.GetName().GetPlainNameString();
		UObject ByPath = FindObject(PathName);
		UObject ByOuterAndName = FindObject(Outer, ShortName);
		UObject Missing = FindObject("DefinitelyMissingObject");
		UObject MissingInOuter = FindObject(Outer, "DefinitelyMissingObject");
		UObject Empty = FindObject("");
		return ByPath == Object && ByOuterAndName == Object && Missing is null && MissingInOuter is null && Empty is null;
	}
}
