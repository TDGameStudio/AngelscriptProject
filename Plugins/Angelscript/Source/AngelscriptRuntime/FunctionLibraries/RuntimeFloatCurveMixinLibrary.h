
#pragma once

#include "CoreMinimal.h"
#include "Curves/CurveFloat.h"
#include "RuntimeFloatCurveMixinLibrary.generated.h"

USTRUCT(BlueprintType)
struct FCurveKeyHandle
{
	GENERATED_BODY()

	FKeyHandle KeyHandle;
};

UCLASS(meta = (ScriptMixin = "FRuntimeFloatCurve UCurveFloat"))
class ANGELSCRIPTRUNTIME_API URuntimeFloatCurveMixinLibrary  : public UObject
{
	GENERATED_BODY()
	
public:

	/** Evaluate this float curve at the specified time */
	UFUNCTION(BlueprintCallable, Category = "Math|Curves")
    static float GetFloatValue(const FRuntimeFloatCurve& Target, const float InTime, const float DefaultValue = 0)
	{
		return Target.GetRichCurveConst()->Eval(InTime, DefaultValue);
	}

	UFUNCTION(BlueprintCallable, Category = "Math|Curves", Meta = (NotInAngelscript = "true"))
    static void GetTimeRange(const FRuntimeFloatCurve& Target, float& MinTime, float& MaxTime)
	{
		Target.GetRichCurveConst()->GetTimeRange(MinTime, MaxTime);
	}

	UFUNCTION(BlueprintCallable, Category = "Math|Curves")
    static void GetValueRange(const FRuntimeFloatCurve& Target, float& MinValue, float& MaxValue)
	{
		Target.GetRichCurveConst()->GetValueRange(MinValue, MaxValue);
	}

	UFUNCTION(BlueprintCallable, Category = "Math|Curves", Meta = (ScriptName = "GetTimeRange"))
    static void GetTimeRange_Double(const FRuntimeFloatCurve& Target, double& MinTime, double& MaxTime)
	{
		float MinTimeFlt, MaxTimeFlt;
		Target.GetRichCurveConst()->GetTimeRange(MinTimeFlt, MaxTimeFlt);
		MinTime = MinTimeFlt;
		MaxTime = MaxTimeFlt;
	}

	UFUNCTION(BlueprintCallable, Category = "Math|Curves", Meta = (ScriptName = "GetValueRange"))
    static void GetValueRange_Double(const FRuntimeFloatCurve& Target, double& MinValue, double& MaxValue)
	{
		float MinValueFlt, MaxValueFlt;
		Target.GetRichCurveConst()->GetValueRange(MinValueFlt, MaxValueFlt);
		MinValue = MinValueFlt;
		MaxValue = MaxValueFlt;
	}

	UFUNCTION(BlueprintCallable, Category = "Math|Curves")
    static int32 GetNumKeys(const FRuntimeFloatCurve& Target)
	{
		return Target.GetRichCurveConst()->GetNumKeys();
	}

	UFUNCTION(BlueprintCallable, Category = "Math|Curves")
    static bool Equals(const FRuntimeFloatCurve& Target, const FRuntimeFloatCurve& Other)
	{
		const FRichCurve* TargetCurve = Target.GetRichCurveConst();
		const FRichCurve* OtherCurve = Other.GetRichCurveConst();
		if (!TargetCurve || !OtherCurve)
			return (!TargetCurve && !OtherCurve); // Equal only if both are nullptr
			
		return (*TargetCurve) == (*OtherCurve);
	}

	UFUNCTION(BlueprintCallable, Category = "Math|Curves")
	static void AddDefaultKey(FRuntimeFloatCurve& Target, float InTime, float InValue)
	{
		Target.EditorCurveData.AddKey(InTime, InValue);
	}

	UFUNCTION(BlueprintCallable, Category = "Math|Curves")
	static FCurveKeyHandle AddCurveKey(UCurveFloat* Curve, float InTime, float InValue)
	{
		FKeyHandle Handle = Curve->FloatCurve.AddKey(InTime, InValue);
		return FCurveKeyHandle{Handle};
	}

	UFUNCTION(BlueprintCallable, Category = "Math|Curves")
	static void AutoSetTangents(UCurveFloat* Curve)
	{
		Curve->FloatCurve.AutoSetTangents();
	}

	UFUNCTION(BlueprintCallable, Category = "Math|Curves")
	static void SetDefaultValue(UCurveFloat* Curve, float DefaultValue)
	{
		Curve->FloatCurve.SetDefaultValue(DefaultValue);
	}

	UFUNCTION(BlueprintCallable, Category = "Math|Curves")
	static void SetPreInfinityExtrap(UCurveFloat* Curve, ERichCurveExtrapolation Extrapolation)
	{
		Curve->FloatCurve.PreInfinityExtrap = Extrapolation;
	}

	UFUNCTION(BlueprintCallable, Category = "Math|Curves")
	static void SetPostInfinityExtrap(UCurveFloat* Curve, ERichCurveExtrapolation Extrapolation)
	{
		Curve->FloatCurve.PostInfinityExtrap = Extrapolation;
	}

	UFUNCTION(BlueprintCallable, Category = "Math|Curves")
	static void SetKeyInterpMode(UCurveFloat* Curve, FCurveKeyHandle KeyHandle, ERichCurveInterpMode NewInterpMode, bool bAutoSetTangents)
	{
		Curve->FloatCurve.SetKeyInterpMode(KeyHandle.KeyHandle, NewInterpMode, bAutoSetTangents);
	}

	UFUNCTION(BlueprintCallable, Category = "Math|Curves")
	static void SetKeyTangentMode(UCurveFloat* Curve, FCurveKeyHandle KeyHandle, ERichCurveTangentMode NewTangentMode, bool bAutoSetTangents = true)
	{
		Curve->FloatCurve.SetKeyTangentMode(KeyHandle.KeyHandle, NewTangentMode, bAutoSetTangents);
	}

	UFUNCTION(BlueprintCallable, Category = "Math|Curves")
	static void SetKeyTangentWeightMode(UCurveFloat* Curve, FCurveKeyHandle KeyHandle, ERichCurveTangentWeightMode NewTangentWeightMode, bool bAutoSetTangents = true)
	{
		Curve->FloatCurve.SetKeyTangentWeightMode(KeyHandle.KeyHandle, NewTangentWeightMode, bAutoSetTangents);
	}

	UFUNCTION(BlueprintCallable, Category = "Math|Curves")
	static void SetKeyUserTangents(UCurveFloat* Curve, FCurveKeyHandle KeyHandle, float ArriveTangent, float LeaveTangent)
	{
		if (!Curve->FloatCurve.IsKeyHandleValid(KeyHandle.KeyHandle))
			return;
		FRichCurveKey& Key = Curve->FloatCurve.GetKey(KeyHandle.KeyHandle);
		Key.ArriveTangent = ArriveTangent;
		Key.LeaveTangent = LeaveTangent;
	}

	UFUNCTION(BlueprintCallable, Category = "Math|Curves")
	static void SetKeyUserTangentWeights(UCurveFloat* Curve, FCurveKeyHandle KeyHandle, float ArriveTangentWeight, float LeaveTangentWeight)
	{
		if (!Curve->FloatCurve.IsKeyHandleValid(KeyHandle.KeyHandle))
			return;
		FRichCurveKey& Key = Curve->FloatCurve.GetKey(KeyHandle.KeyHandle);
		Key.ArriveTangentWeight = ArriveTangentWeight;
		Key.LeaveTangentWeight = LeaveTangentWeight;
	}

	UFUNCTION(BlueprintCallable, Category = "Math|Curves")
	static FCurveKeyHandle AddConstantCurveKey(UCurveFloat* Curve, float InTime, float InValue)
	{
		FKeyHandle Handle = Curve->FloatCurve.AddKey(InTime, InValue);
		Curve->FloatCurve.SetKeyInterpMode(Handle, ERichCurveInterpMode::RCIM_Constant, false);
		return FCurveKeyHandle{Handle};
	}

	UFUNCTION(BlueprintCallable, Category = "Math|Curves")
	static FCurveKeyHandle AddLinearCurveKey(UCurveFloat* Curve, float InTime, float InValue)
	{
		FKeyHandle Handle = Curve->FloatCurve.AddKey(InTime, InValue);
		return FCurveKeyHandle{Handle};
	}

	UFUNCTION(BlueprintCallable, Category = "Math|Curves")
	static FCurveKeyHandle AddAutoCurveKey(UCurveFloat* Curve, float InTime, float InValue)
	{
		FKeyHandle Handle = Curve->FloatCurve.AddKey(InTime, InValue);
		Curve->FloatCurve.SetKeyInterpMode(Handle, ERichCurveInterpMode::RCIM_Cubic, false);
		Curve->FloatCurve.SetKeyTangentMode(Handle, ERichCurveTangentMode::RCTM_Auto, false);
		return FCurveKeyHandle{Handle};
	}

	UFUNCTION(BlueprintCallable, Category = "Math|Curves")
	static FCurveKeyHandle AddSmartAutoCurveKey(UCurveFloat* Curve, float InTime, float InValue)
	{
		FKeyHandle Handle = Curve->FloatCurve.AddKey(InTime, InValue);
		Curve->FloatCurve.SetKeyInterpMode(Handle, ERichCurveInterpMode::RCIM_Cubic, false);
		Curve->FloatCurve.SetKeyTangentMode(Handle, ERichCurveTangentMode::RCTM_Auto, false);
		return FCurveKeyHandle{Handle};
	}

	UFUNCTION(BlueprintCallable, Category = "Math|Curves")
	static FCurveKeyHandle AddCurveKeyTangent(UCurveFloat* Curve, float InTime, float InValue, float Tangent)
	{
		FKeyHandle Handle = Curve->FloatCurve.AddKey(InTime, InValue);
		Curve->FloatCurve.SetKeyInterpMode(Handle, ERichCurveInterpMode::RCIM_Cubic, false);
		Curve->FloatCurve.SetKeyTangentMode(Handle, ERichCurveTangentMode::RCTM_User, false);

		FRichCurveKey& Key = Curve->FloatCurve.GetKey(Handle);
		Key.ArriveTangent = Tangent;
		Key.LeaveTangent = Tangent;

		return FCurveKeyHandle{Handle};
	}

	UFUNCTION(BlueprintCallable, Category = "Math|Curves")
	static FCurveKeyHandle AddCurveKeyBrokenTangent(UCurveFloat* Curve, float InTime, float InValue, float ArriveTangent, float LeaveTangent)
	{
		FKeyHandle Handle = Curve->FloatCurve.AddKey(InTime, InValue);
		Curve->FloatCurve.SetKeyInterpMode(Handle, ERichCurveInterpMode::RCIM_Cubic, false);
		Curve->FloatCurve.SetKeyTangentMode(Handle, ERichCurveTangentMode::RCTM_Break, false);

		FRichCurveKey& Key = Curve->FloatCurve.GetKey(Handle);
		Key.ArriveTangent = ArriveTangent;
		Key.LeaveTangent = LeaveTangent;

		return FCurveKeyHandle{Handle};
	}

	UFUNCTION(BlueprintCallable, Category = "Math|Curves")
	static FCurveKeyHandle AddCurveKeyWeightedArriveTangent(UCurveFloat* Curve, float InTime, float InValue, bool bBrokenTangent, float ArriveTangent, float LeaveTangent, float ArriveTangentWeight, float LeaveTangentWeight)
	{
		FKeyHandle Handle = Curve->FloatCurve.AddKey(InTime, InValue);
		Curve->FloatCurve.SetKeyInterpMode(Handle, ERichCurveInterpMode::RCIM_Cubic, false);
		if (bBrokenTangent)
			Curve->FloatCurve.SetKeyTangentMode(Handle, ERichCurveTangentMode::RCTM_Break, false);
		else
			Curve->FloatCurve.SetKeyTangentMode(Handle, ERichCurveTangentMode::RCTM_User, false);

		FRichCurveKey& Key = Curve->FloatCurve.GetKey(Handle);
		Key.ArriveTangent = ArriveTangent;
		Key.ArriveTangentWeight = ArriveTangentWeight;
		Key.LeaveTangent = LeaveTangent;
		Key.LeaveTangentWeight = LeaveTangentWeight;
		Key.TangentWeightMode = ERichCurveTangentWeightMode::RCTWM_WeightedArrive;

		return FCurveKeyHandle{Handle};
	}

	UFUNCTION(BlueprintCallable, Category = "Math|Curves")
	static FCurveKeyHandle AddCurveKeyWeightedLeaveTangent(UCurveFloat* Curve, float InTime, float InValue, bool bBrokenTangent, float ArriveTangent, float LeaveTangent, float ArriveTangentWeight, float LeaveTangentWeight)
	{
		FKeyHandle Handle = Curve->FloatCurve.AddKey(InTime, InValue);
		Curve->FloatCurve.SetKeyInterpMode(Handle, ERichCurveInterpMode::RCIM_Cubic, false);
		if (bBrokenTangent)
			Curve->FloatCurve.SetKeyTangentMode(Handle, ERichCurveTangentMode::RCTM_Break, false);
		else
			Curve->FloatCurve.SetKeyTangentMode(Handle, ERichCurveTangentMode::RCTM_User, false);

		FRichCurveKey& Key = Curve->FloatCurve.GetKey(Handle);
		Key.ArriveTangent = ArriveTangent;
		Key.ArriveTangentWeight = ArriveTangentWeight;
		Key.LeaveTangent = LeaveTangent;
		Key.LeaveTangentWeight = LeaveTangentWeight;
		Key.TangentWeightMode = ERichCurveTangentWeightMode::RCTWM_WeightedLeave;

		return FCurveKeyHandle{Handle};
	}

	UFUNCTION(BlueprintCallable, Category = "Math|Curves")
	static FCurveKeyHandle AddCurveKeyWeightedBothTangent(UCurveFloat* Curve, float InTime, float InValue, bool bBrokenTangent, float ArriveTangent, float LeaveTangent, float ArriveTangentWeight, float LeaveTangentWeight)
	{
		FKeyHandle Handle = Curve->FloatCurve.AddKey(InTime, InValue);
		Curve->FloatCurve.SetKeyInterpMode(Handle, ERichCurveInterpMode::RCIM_Cubic, false);
		if (bBrokenTangent)
			Curve->FloatCurve.SetKeyTangentMode(Handle, ERichCurveTangentMode::RCTM_Break, false);
		else
			Curve->FloatCurve.SetKeyTangentMode(Handle, ERichCurveTangentMode::RCTM_User, false);

		FRichCurveKey& Key = Curve->FloatCurve.GetKey(Handle);
		Key.ArriveTangent = ArriveTangent;
		Key.ArriveTangentWeight = ArriveTangentWeight;
		Key.LeaveTangent = LeaveTangent;
		Key.LeaveTangentWeight = LeaveTangentWeight;
		Key.TangentWeightMode = ERichCurveTangentWeightMode::RCTWM_WeightedBoth;

		return FCurveKeyHandle{Handle};
	}
};
