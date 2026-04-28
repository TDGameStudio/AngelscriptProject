#include "Misc/DefaultValueHelper.h"

#include "AngelscriptBinds.h"
#include "AngelscriptEngine.h"

#include "Helper_StructType.h"

struct FGetSphere
{
	static UScriptStruct* Get();
};

UScriptStruct* FGetSphere::Get()
{
	static UScriptStruct* ScriptStruct = FindObject<UScriptStruct>(nullptr, TEXT("/Script/CoreUObject.Sphere"));
	return ScriptStruct;
}

struct FSphereType : TAngelscriptCoreStructType<FSphere, FGetSphere, false>
{
	FString GetAngelscriptTypeName() const override
	{
		return TEXT("FSphere");
	}

	bool GetCppForm(const FAngelscriptTypeUsage& Usage, FCppForm& OutCppForm) const override
	{
		OutCppForm.CppType = GetAngelscriptTypeName();
		return true;
	}
};

AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_FSphere(FAngelscriptBinds::EOrder::Early, []
{
	FBindFlags Flags;
	Flags.bPOD = true;
	Flags.ExtraFlags |= asOBJ_BASICMATHTYPE;

	auto FSphere_ = FAngelscriptBinds::ValueClass<FSphere>("FSphere", Flags);
	FAngelscriptType::Register(MakeShared<FSphereType>());

	FSphere_.Constructor("void f()", [](FSphere* Address)
	{
		new(Address) FSphere(ForceInit);
	});
	FAngelscriptBinds::SetPreviousBindNoDiscard(true);
	SCRIPT_TRIVIAL_NATIVE_CONSTRUCTOR_CUSTOMFORM(FSphere_, "FSphere", "ForceInit");

	FSphere_.Property("float64 W", &FSphere::W);
	FSphere_.Method("FSphere opAdd(const FSphere& Other) const", METHODPR_TRIVIAL(FSphere, FSphere, operator+, (const FSphere&) const));
	FSphere_.Method("FSphere& opAddAssign(const FSphere& Other)", METHODPR_TRIVIAL(FSphere&, FSphere, operator+=, (const FSphere&)));
});

AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_FSphere_Late(FAngelscriptBinds::EOrder::Late, []
{
	auto FSphere_ = FAngelscriptBinds::ExistingClass("FSphere");

	FSphere_.Constructor("void f(FVector InV, float32 InW)", [](FSphere* Address, FVector InV, float InW)
	{
		new(Address) FSphere(InV, InW);
	});
	FAngelscriptBinds::SetPreviousBindNoDiscard(true);
	SCRIPT_TRIVIAL_NATIVE_CONSTRUCTOR(FSphere_, "FSphere");

	FSphere_.Constructor("void f(const FSphere& Sphere)", [](FSphere* Address, const FSphere& Sphere)
	{
		new(Address) FSphere(Sphere);
	});
	FAngelscriptBinds::SetPreviousBindNoDiscard(true);
	SCRIPT_TRIVIAL_NATIVE_CONSTRUCTOR(FSphere_, "FSphere");

	FSphere_.Constructor("void f(const FSphere3f& Sphere)", [](FSphere* Address, const FSphere3f& Sphere)
	{
		new(Address) FSphere(Sphere);
	});
	FAngelscriptBinds::SetPreviousBindNoDiscard(true);
	SCRIPT_TRIVIAL_NATIVE_CONSTRUCTOR(FSphere_, "FSphere");

	FSphere_.Constructor("void f(const TArray<FVector>& Points)", [](FSphere* Address, TArray<FVector>& Points)
	{
		new(Address) FSphere(Points.GetData(), Points.Num());
	});
	FAngelscriptBinds::SetPreviousBindNoDiscard(true);

	FSphere_.Property("FVector Center", &FSphere::Center);
	FSphere_.Method("bool Equals(const FSphere& Sphere, float64 Tolerance = KINDA_SMALL_NUMBER) const", METHODPR_TRIVIAL(bool, FSphere, Equals, (const FSphere&, double) const));
	FSphere_.Method("bool IsInside(const FSphere& Other, float64 Tolerance = KINDA_SMALL_NUMBER) const", METHODPR_TRIVIAL(bool, FSphere, IsInside, (const FSphere&, double) const));
	FSphere_.Method("bool IsInside(const FVector& In, float64 Tolerance = KINDA_SMALL_NUMBER) const", METHODPR_TRIVIAL(bool, FSphere, IsInside, (const FVector&, double) const));
	FSphere_.Method("bool Intersects(const FSphere& Other, float64 Tolerance = KINDA_SMALL_NUMBER) const", METHODPR_TRIVIAL(bool, FSphere, Intersects, (const FSphere&, double) const));
	FSphere_.Method("FSphere TransformBy( const FTransform& M ) const", METHODPR_TRIVIAL(FSphere, FSphere, TransformBy, (const FTransform&) const));
	FSphere_.Method("float64 GetVolume() const", METHOD_TRIVIAL(FSphere, GetVolume));
});
