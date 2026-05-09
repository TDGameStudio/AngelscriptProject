#include "Misc/DefaultValueHelper.h"
#include "Kismet/KismetMathLibrary.h"

#include "AngelscriptBinds.h"
#include "AngelscriptEngine.h"

#include "Helper_StructType.h"
#include "Helper_ToString.h"

struct FRotatorType : TAngelscriptBaseStructType<FRotator>
{
	FString GetAngelscriptTypeName() const override
	{
		return TEXT("FRotator");
	}

	void ConstructValue(const FAngelscriptTypeUsage& Usage, void* DestinationPtr) const override
	{
		new(DestinationPtr) FRotator(0.f);
	}

	bool NeedConstruct(const FAngelscriptTypeUsage& Usage) const override { return false; }
	bool NeedDestruct(const FAngelscriptTypeUsage& Usage) const override { return false; }

	bool DefaultValue_UnrealToAngelscript(const FAngelscriptTypeUsage& Usage, const FString& InValue, FString& OutValue) const override
	{
		if (InValue.IsEmpty())
		{
			OutValue = TEXT("FRotator()");
			return true;
		}
		FRotator Value;
		if (FDefaultValueHelper::ParseRotator(InValue, Value))
		{
			OutValue = FString::Printf(TEXT("FRotator(%f,%f,%f)"), Value.Pitch, Value.Yaw, Value.Roll);
			return true;
		}
		return false;
	}

	bool DefaultValue_AngelscriptToUnreal(const FAngelscriptTypeUsage& Usage, const FString& CppForm, FString& OutForm) const override
	{
		if (FDefaultValueHelper::Is( CppForm, TEXT("FRotator :: ZeroRotator") ))
		{
			return true;
		}
		FString Parameters;
		if( FDefaultValueHelper::GetParameters(CppForm, TEXT("FRotator"), Parameters) )
		{
			FRotator Rotator;
			if(FDefaultValueHelper::ParseRotator(Parameters, Rotator))
			{
				OutForm = FString::Printf(TEXT("%f,%f,%f"),
					Rotator.Pitch, Rotator.Yaw, Rotator.Roll);
			}
		}

		return !OutForm.IsEmpty();
	}

	bool GetCppForm(const FAngelscriptTypeUsage& Usage, FCppForm& OutCppForm) const override
	{
		OutCppForm.CppType = GetAngelscriptTypeName();
		return true;
	}
};

AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_FRotator(FAngelscriptBinds::EOrder::Early, []
{
	FBindFlags Flags;
	Flags.bPOD = true;
	Flags.ExtraFlags |= asOBJ_BASICMATHTYPE;

	auto FRotator_ = FAngelscriptBinds::ValueClass<FRotator>("FRotator", Flags);
	FAngelscriptType::Register(MakeShared<FRotatorType>());

	FRotator_.Constructor("void f(float64 Pitch, float64 Yaw, float64 Roll)", [](FRotator* Address, double Pitch, double Yaw, double Roll)
	{
		new(Address) FRotator(Pitch, Yaw, Roll);
	});
	FAngelscriptBinds::SetPreviousBindNoDiscard(true);
	SCRIPT_TRIVIAL_NATIVE_CONSTRUCTOR(FRotator_, "FRotator");

	FRotator_.Constructor("void f()", [](FRotator* Address)
	{
		new(Address) FRotator(0.f);
	});
	FAngelscriptBinds::SetPreviousBindNoDiscard(true);
	SCRIPT_TRIVIAL_NATIVE_CONSTRUCTOR_CUSTOMFORM(FRotator_, "FRotator", "0.f");

	FRotator_.Constructor("void f(float64 F)", [](FRotator* Address, double F)
	{
		new(Address) FRotator(F);
	});
	FAngelscriptBinds::SetPreviousBindNoDiscard(true);
	SCRIPT_TRIVIAL_NATIVE_CONSTRUCTOR(FRotator_, "FRotator");

	FRotator_.Constructor("void f(const FRotator& Other)", [](FRotator* Address, const FRotator& Other)
	{
		new(Address) FRotator(Other);
	});
	FAngelscriptBinds::SetPreviousBindNoDiscard(true);
	SCRIPT_TRIVIAL_NATIVE_CONSTRUCTOR(FRotator_, "FRotator");

	FRotator_.Property("float64 Pitch", &FRotator::Pitch);
	FRotator_.Property("float64 Yaw", &FRotator::Yaw);
	FRotator_.Property("float64 Roll", &FRotator::Roll);

	FRotator_.Method("FRotator& opAssign(const FRotator& Other)", [](FRotator* Rotator, const FRotator& Other) -> FRotator*
	{
		*Rotator = Other;
		return Rotator;
	});
	SCRIPT_TRIVIAL_NATIVE_ASSIGNMENT(FRotator_, "FRotator");

	FRotator_.Method("FRotator opAdd(const FRotator& R) const", METHOD_TRIVIAL(FRotator, operator+));
	FRotator_.Method("FRotator opAddAssign(const FRotator& R)", METHOD_TRIVIAL(FRotator, operator+=));

	FRotator_.Method("FRotator opSub(const FRotator& R) const", METHOD_TRIVIAL(FRotator, operator-));
	FRotator_.Method("FRotator opSubAssign(const FRotator& R)", METHOD_TRIVIAL(FRotator, operator-=));

	FRotator_.Method("FRotator opMul(float64 Scale) const", METHODPR_TRIVIAL(FRotator, FRotator, operator*, (double) const));
	FRotator_.Method("FRotator opMulAssign(float64 Scale)", METHODPR_TRIVIAL(FRotator, FRotator, operator*=, (double)));

	FRotator_.Method("bool opEquals(const FRotator& R) const", METHOD_TRIVIAL(FRotator, operator==));

	FRotator_.Method("bool IsNearlyZero(float64 Tolerance = KINDA_SMALL_NUMBER) const", METHOD_TRIVIAL(FRotator, IsNearlyZero));
	FRotator_.Method("bool IsZero() const", METHOD_TRIVIAL(FRotator, IsZero));

	FRotator_.Method("bool Equals(const FRotator& R, float64 Tolerance=KINDA_SMALL_NUMBER) const", METHOD_TRIVIAL(FRotator, Equals));
	FRotator_.Method("FRotator GetInverse() const", METHOD_TRIVIAL(FRotator, GetInverse));

	FRotator_.Method("FRotator Clamp() const", METHOD_TRIVIAL(FRotator, Clamp));
	FRotator_.Method("FRotator GetNormalized() const", METHOD_TRIVIAL(FRotator, GetNormalized));
	FRotator_.Method("FRotator GetDenormalized() const", METHOD_TRIVIAL(FRotator, GetDenormalized));
	FRotator_.Method("void GetWindingAndRemainder(FRotator& Winding, FRotator& Remainder) const", METHOD_TRIVIAL(FRotator, GetWindingAndRemainder));
	FRotator_.Method("float64 GetManhattanDistance(const FRotator& Rotator) const", METHOD_TRIVIAL(FRotator, GetManhattanDistance));

	FRotator_.Method("void Normalize()", METHOD_TRIVIAL(FRotator, Normalize));
	FRotator_.Method("bool ContainsNaN()", METHOD_TRIVIAL(FRotator, ContainsNaN));

	{
		FAngelscriptBinds::FNamespace ns("FRotator");
		FAngelscriptBinds::BindGlobalVariable("const FRotator ZeroRotator", &FRotator::ZeroRotator);
		FAngelscriptBinds::BindGlobalFunction("float64 NormalizeAxis(float64 Angle) no_discard", FUNC_TRIVIAL(FRotator::NormalizeAxis));
		FAngelscriptBinds::BindGlobalFunction("float64 ClampAxis(float64 Angle) no_discard", FUNC_TRIVIAL(FRotator::ClampAxis));
	}

	FToStringHelper::Register(TEXT("FRotator"), [](void* Ptr, FString& Str)
	{
		Str += ((FRotator*)Ptr)->ToString();
	});
});

AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_FRotator_Interaction(FAngelscriptBinds::EOrder::Late, []
{
	auto FRotator_ = FAngelscriptBinds::ExistingClass("FRotator");

	{
		FAngelscriptBinds::FNamespace ns("FRotator");
		FAngelscriptBinds::BindGlobalFunction("FRotator MakeFromEuler(const FVector& Euler) no_discard", FUNCPR_TRIVIAL(FRotator, FRotator::MakeFromEuler, (const FVector&)));

		FAngelscriptBinds::BindGlobalFunction("FRotator MakeFromX(const FVector& XAxis) no_discard", FUNCPR_TRIVIAL(FRotator, UKismetMathLibrary::MakeRotFromX, (const FVector&)));
		FAngelscriptBinds::BindGlobalFunction("FRotator MakeFromY(const FVector& YAxis) no_discard", FUNCPR_TRIVIAL(FRotator, UKismetMathLibrary::MakeRotFromY, (const FVector&)));
		FAngelscriptBinds::BindGlobalFunction("FRotator MakeFromZ(const FVector& ZAxis) no_discard", FUNCPR_TRIVIAL(FRotator, UKismetMathLibrary::MakeRotFromZ, (const FVector&)));

		FAngelscriptBinds::BindGlobalFunction("FRotator MakeFromXY(const FVector& XAxis, const FVector& YAxis) no_discard", FUNCPR_TRIVIAL(FRotator, UKismetMathLibrary::MakeRotFromXY, (const FVector& ,const FVector&)));
		FAngelscriptBinds::BindGlobalFunction("FRotator MakeFromXZ(const FVector& XAxis, const FVector& ZAxis) no_discard", FUNCPR_TRIVIAL(FRotator, UKismetMathLibrary::MakeRotFromXZ, (const FVector& ,const FVector&)));
		FAngelscriptBinds::BindGlobalFunction("FRotator MakeFromYX(const FVector& YAxis, const FVector& XAxis) no_discard", FUNCPR_TRIVIAL(FRotator, UKismetMathLibrary::MakeRotFromYX, (const FVector& ,const FVector&)));
		FAngelscriptBinds::BindGlobalFunction("FRotator MakeFromYZ(const FVector& YAxis, const FVector& ZAxis) no_discard", FUNCPR_TRIVIAL(FRotator, UKismetMathLibrary::MakeRotFromYZ, (const FVector& ,const FVector&)));
		FAngelscriptBinds::BindGlobalFunction("FRotator MakeFromZX(const FVector& ZAxis, const FVector& XAxis) no_discard", FUNCPR_TRIVIAL(FRotator, UKismetMathLibrary::MakeRotFromZX, (const FVector& ,const FVector&)));
		FAngelscriptBinds::BindGlobalFunction("FRotator MakeFromZY(const FVector& ZAxis, const FVector& YAxis) no_discard", FUNCPR_TRIVIAL(FRotator, UKismetMathLibrary::MakeRotFromZY, (const FVector& ,const FVector&)));
	}

	FRotator_.Method("FVector Vector() const", METHOD_TRIVIAL(FRotator, Vector));
	FRotator_.Method("FQuat Quaternion() const", METHOD_TRIVIAL(FRotator, Quaternion));
	FRotator_.Method("FVector Euler() const", METHOD_TRIVIAL(FRotator, Euler));
	FRotator_.Method("FVector GetForwardVector() const", METHOD_TRIVIAL(FRotator, Vector));
	FRotator_.Method("FVector GetRightVector() const", [](const FRotator& Rotator) -> FVector
	{
		return FRotationMatrix(Rotator).GetScaledAxis(EAxis::Y);
	});
	FRotator_.Method("FVector GetUpVector() const", [](const FRotator& Rotator) -> FVector
	{
		return FRotationMatrix(Rotator).GetScaledAxis(EAxis::Z);
	});

	FRotator_.Method("FVector RotateVector(const FVector& V) const", METHOD_TRIVIAL(FRotator, RotateVector));
	FRotator_.Method("FVector UnrotateVector(const FVector& V) const", METHOD_TRIVIAL(FRotator, UnrotateVector));

	FRotator_.Constructor("void f(const FQuat& Quat)", [](FRotator* Address, const FQuat& Quat)
	{
		new(Address) FRotator(Quat);
	});
	SCRIPT_TRIVIAL_NATIVE_CONSTRUCTOR(FRotator_, "FRotator");

	FRotator_.Constructor("void f(const FRotator3f& Rotator)", [](FRotator* Address, const FRotator3f& Rotator)
	{
		new(Address) FRotator(Rotator);
	});
	SCRIPT_TRIVIAL_NATIVE_CONSTRUCTOR(FRotator_, "FRotator");
});

FRotator FixupRotation(FRotator Original)
{
	if (FMath::Abs(Original.Pitch - SMALL_NUMBER) < KINDA_SMALL_NUMBER)
		Original.Pitch = 0.f;

	if (FMath::Abs(Original.Yaw - SMALL_NUMBER) < KINDA_SMALL_NUMBER)
		Original.Yaw = 0.f;

	if (FMath::Abs(Original.Roll - SMALL_NUMBER) < KINDA_SMALL_NUMBER)
		Original.Roll = 0.f;

	return Original;
}

AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_FRotator_Conversion(FAngelscriptBinds::EOrder::Late, []
{
	auto FRotator_ = FAngelscriptBinds::ExistingClass("FRotator");

	FRotator_.Method("FString ToColorString() const",
	[](const FRotator& Rotator)
	{
		const FRotator FixedRotation = FixupRotation(Rotator);
		FString PitchString = FString::Printf(TEXT("<Green>P=%3.3f </>"), FixedRotation.Pitch);
		FString YawString = FString::Printf(TEXT("<Blue>Y=%3.3f </>"), FixedRotation.Yaw);
		FString RollString = FString::Printf(TEXT("<Red>R=%3.3f </>"), FixedRotation.Roll);
		return YawString + PitchString + RollString;
	});

	FRotator_.Method("bool InitFromString(const FString& SourceString)", METHOD_TRIVIAL(FRotator, InitFromString));
});
