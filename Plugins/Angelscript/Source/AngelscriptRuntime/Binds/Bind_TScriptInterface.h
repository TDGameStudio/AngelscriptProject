
#pragma once
#include "CoreMinimal.h"
#include "UObject/ScriptInterface.h"
#include "ClassGenerator/ASClass.h"

#include "StartAngelscriptHeaders.h"
#include "source/as_context.h"
#include "source/as_scriptfunction.h"
#include "source/as_objecttype.h"
#include "EndAngelscriptHeaders.h"

#include "Binds/Bind_Helpers.h"

// Helpers backing the `TScriptInterface<T>` Angelscript template. The template
// maps 1:1 to `FScriptInterface` (a 16-byte POD struct holding
// `{ TObjectPtr<UObject> ObjectPointer, void* InterfacePointer }`), so all
// operations delegate to the struct's own setters while enforcing interface
// implementation and computing the correct pointer offset via
// `FAngelscriptBindHelpers::GetInterfacePointerForCast`.
struct ANGELSCRIPTRUNTIME_API FAngelscriptScriptInterfaceHelpers
{
	static void Construct(FScriptInterface* Ptr)
	{
		new (Ptr) FScriptInterface();
	}

	static void CopyConstruct(FScriptInterface* Ptr, const FScriptInterface& Other)
	{
		new (Ptr) FScriptInterface(Other);
	}

	static FScriptInterface& Assign(FScriptInterface* Ptr, const FScriptInterface& Other)
	{
		*Ptr = Other;
		return *Ptr;
	}

	// Implicit construction from a UObject handle: validates the object
	// implements the templated interface before storing it, then computes
	// the correct `InterfacePointer` for C++ native implementations.
	static void ImplicitConstruct(FScriptInterface* Ptr, asCObjectType* TemplateType, UObject* InObject)
	{
		new (Ptr) FScriptInterface();
		AssignFromObject(Ptr, TemplateType, InObject);
	}

	// Used by `opAssign(UObject)` — same validation path as ImplicitConstruct
	// but on an already-constructed FScriptInterface.
	static void SetObject(FScriptInterface* Ptr, asCObjectType* TemplateType, UObject* InObject)
	{
		AssignFromObject(Ptr, TemplateType, InObject);
	}

	static UObject* GetObject(FScriptInterface* Ptr)
	{
		return Ptr->GetObject();
	}

	static bool IsValid(FScriptInterface* Ptr)
	{
		return Ptr->GetObject() != nullptr;
	}

	static bool OpEquals(FScriptInterface* Ptr, const FScriptInterface& Other)
	{
		return Ptr->GetObject() == Other.GetObject();
	}

	static bool OpEqualsObject(FScriptInterface* Ptr, UObject* Other)
	{
		return Ptr->GetObject() == Other;
	}

private:
	// Shared validation + assignment path used by ImplicitConstruct / SetObject.
	// The TemplateType's subtype UserData points to the interface UClass, which
	// we need to call `GetInterfacePointerForCast` correctly.
	static void AssignFromObject(FScriptInterface* Ptr, asCObjectType* TemplateType, UObject* InObject)
	{
		if (InObject == nullptr)
		{
			Ptr->SetObject(nullptr);
			Ptr->SetInterface(nullptr);
			return;
		}

		auto* SubType = TemplateType->GetSubType(0);
		if (SubType == nullptr || (SubType->GetFlags() & asOBJ_VALUE))
		{
			// Template parameter is invalid — nothing we can validate against.
			Ptr->SetObject(nullptr);
			Ptr->SetInterface(nullptr);
			return;
		}

		UClass* InterfaceClass = (UClass*)SubType->GetUserData();
		if (InterfaceClass == nullptr || !InterfaceClass->HasAnyClassFlags(CLASS_Interface))
		{
			FAngelscriptEngine::Throw("TScriptInterface<> template parameter is not an interface class.");
			Ptr->SetObject(nullptr);
			Ptr->SetInterface(nullptr);
			return;
		}

		if (!InObject->GetClass()->ImplementsInterface(InterfaceClass))
		{
			FAngelscriptEngine::Throw("Object assigned to TScriptInterface<> does not implement the templated interface.");
			Ptr->SetObject(nullptr);
			Ptr->SetInterface(nullptr);
			return;
		}

		Ptr->SetObject(InObject);
		Ptr->SetInterface(FAngelscriptBindHelpers::GetInterfacePointerForCast(InObject, InterfaceClass));
	}
};
