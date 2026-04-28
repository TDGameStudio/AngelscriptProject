#pragma once
#include "MatrixTypes.h"
#include "AngelscriptEngine.h"
#include "AngelscriptMathLibrary.generated.h"

// FunctionLibraries cleanup note (mixin parity):
//
// The //UCLASS(Meta = (ScriptMixin = "...")) lines below the top-level UAngelscriptMathLibrary
// are kept commented out as Hazelight-parity anchors. Hazelight binds these helpers via the
// dedicated mixin-injection path in Helper_FunctionSignature.h; this fork currently routes
// them through UFUNCTION(BlueprintCallable) + BlueprintCallableReflectiveFallback instead,
// which reaches scripts with equivalent method-syntax but also exposes the helpers in the
// Blueprint node palette.
//
// To restore upstream parity: uncomment the //UCLASS(...) line and (optionally) switch the
// UFUNCTIONs back to ScriptCallable. See Documents/Knowledges/ZH/Syntax_Mixin.md section 6
// for the full background.

UCLASS(Meta = (ScriptName = "Math"))
class UAngelscriptMathLibrary : public UObject
{
	GENERATED_BODY()

public:
	
	UFUNCTION(BlueprintCallable, Meta = (ScriptName = "SinCos"))
	static void SinCos_32(float& ScalarSin, float& ScalarCos, float Value)
	{
		FMath::SinCos(&ScalarSin, &ScalarCos, Value);
	}

	UFUNCTION(BlueprintCallable, Meta = (ScriptName = "SinCos"))
	static void SinCos_64(double& ScalarSin, double& ScalarCos, double Value)
	{
		FMath::SinCos(&ScalarSin, &ScalarCos, Value);
	}

	// Lerp between two rotators along the shortest path between them. Uses a quaternion slerp internally. 
	UFUNCTION(BlueprintCallable, Meta = (ScriptTrivial, ScriptNoDiscard))
	static FRotator LerpShortestPath(const FRotator& A, const FRotator& B, double Alpha)
	{
		FQuat AQuat(A);
		FQuat BQuat(B);
		FQuat Result = FQuat::Slerp(AQuat, BQuat, Alpha);
		Result.Normalize();
		return Result.Rotator();
	}

	// Interp between two rotators along the shortest path between them. Uses a quaternion interp internally.
	UFUNCTION(BlueprintCallable, Meta = (ScriptTrivial, ScriptNoDiscard))
	static FRotator RInterpShortestPathTo(const FRotator& Current, const FRotator& Target, float DeltaTime, float InterpSpeed)
	{
		FQuat AQuat(Current);
		FQuat BQuat(Target);
		FQuat Result = FMath::QInterpTo(AQuat, BQuat, DeltaTime, InterpSpeed);
		Result.Normalize();
		return Result.Rotator();
	}

	// Interp with constant speed between two rotators along the shortest path between them. Uses a quaternion interp internally.
	UFUNCTION(BlueprintCallable, Meta = (ScriptTrivial, ScriptNoDiscard))
	static FRotator RInterpConstantShortestPathTo(const FRotator& Current, const FRotator& Target, float DeltaTime, float InterpSpeedDegrees)
	{
		FQuat AQuat(Current);
		FQuat BQuat(Target);
		FQuat Result = FMath::QInterpConstantTo(AQuat, BQuat, DeltaTime, FMath::DegreesToRadians(InterpSpeedDegrees));
		Result.Normalize();
		return Result.Rotator();
	}

	UFUNCTION(BlueprintCallable, Meta = (ScriptTrivial, ScriptNoDiscard))
	static FTransform TInterpTo(const FTransform& Current, const FTransform& Target, float DeltaTime, float InterpSpeed)
	{
		if (InterpSpeed <= 0.f)
		{
			return Target;
		}

		const float Alpha = FMath::Clamp(DeltaTime * InterpSpeed, 0.f, 1.f);

		FTransform Result;

		FTransform NCurrent = Current;
		FTransform NTarget = Target;
		NCurrent.NormalizeRotation();
		NTarget.NormalizeRotation();

		Result.Blend(NCurrent, NTarget, Alpha);
		return Result;
	}

	UFUNCTION(BlueprintCallable)
	static bool LineBoxIntersection(const FBox& Box, const FVector& Start, const FVector& End)
	{
		return FMath::LineBoxIntersection(Box, Start, End, End - Start);
	}

	UFUNCTION(BlueprintCallable, Meta = (ScriptTrivial, ScriptName = "Modf", ScriptNoDiscard))
	static float Modf_32(float InValue, float& OutIntPart)
	{
		return FMath::Modf(InValue, &OutIntPart);
	}

	UFUNCTION(BlueprintCallable, Meta = (ScriptTrivial, ScriptName = "Modf", ScriptNoDiscard))
	static double Modf_64(double InValue, double& OutIntPart)
	{
		return FMath::Modf(InValue, &OutIntPart);
	}

	/**
	 * Wraps X to be between Min and Max, inclusive.
	 * When X can wrap to both Min and Max, it will wrap to Min if it lies below the range and wrap to Max if it is above the range. 
	 **/
	UFUNCTION(BlueprintCallable, Meta = (ScriptTrivial, ScriptName = "Wrap", ScriptNoDiscard))
	static double WrapDouble(double X, double Min, double Max)
	{
		// This is not implemented with FMath::Wrap, because that uses while loops for some reason,
		// and can be slow on large numbers.
		double Range = FMath::Abs(Max - Min);
		if (X < Min)
		{
			if (Range < UE_DOUBLE_SMALL_NUMBER)
				return Min;

			double Remainder = FMath::Fmod(Min - X, Range);

			// Need to special case remainder 0, because unreal Wrap returns Min in that case, not Max,
			// and we want to be compatible
			if (Remainder == 0.0)
				return Min;
			else
				return Max - Remainder;
		}
		else if (X > Max)
		{
			if (Range < UE_DOUBLE_SMALL_NUMBER)
				return Max;

			double Remainder = FMath::Fmod(X - Max, Range);

			// Need to special case remainder 0, because unreal Wrap returns Max in that case, not Min
			// and we want to be compatible
			if (Remainder == 0.0)
				return Max;
			else
				return Min + Remainder;
		}
		else
		{
			return X;
		}
	}

	/**
	 * Wraps X to be between Min and Max, inclusive.
	 * When X can wrap to both Min and Max, it will wrap to Min if it lies below the range and wrap to Max if it is above the range. 
	 **/
	UFUNCTION(BlueprintCallable, Meta = (ScriptTrivial, ScriptName = "Wrap", ScriptNoDiscard))
	static float WrapFloat(float X, float Min, float Max)
	{
		// This is not implemented with FMath::Wrap, because that uses while loops for some reason,
		// and can be slow on large numbers.
		float Range = FMath::Abs(Max - Min);
		if (X < Min)
		{
			if (Range < UE_DOUBLE_SMALL_NUMBER)
				return Min;

			float Remainder = FMath::Fmod(Min - X, Range);

			// Need to special case remainder 0, because unreal Wrap returns Min in that case, not Max,
			// and we want to be compatible
			if (Remainder == 0.f)
				return Min;
			else
				return Max - Remainder;
		}
		else if (X > Max)
		{
			if (Range < UE_DOUBLE_SMALL_NUMBER)
				return Max;

			float Remainder = FMath::Fmod(X - Max, Range);

			// Need to special case remainder 0, because unreal Wrap returns Max in that case, not Min
			// and we want to be compatible
			if (Remainder == 0.f)
				return Max;
			else
				return Min + Remainder;
		}
		else
		{
			return X;
		}
	}

	/**
	 * Wraps X to be between Min and Max, inclusive.
	 * When X can wrap to both Min and Max, it will wrap to Min if it lies below the range and wrap to Max if it is above the range. 
	 **/
	UFUNCTION(BlueprintCallable, Meta = (ScriptTrivial, ScriptName = "Wrap", ScriptNoDiscard, DeprecatedFunction, DeprecationMessage = "Wrapping integers is inclusive, and returns unintuitive values. Use Math::WrapIndex for the natural behavior."))
	static int32 WrapInt(int32 X, int32 Min, int32 Max)
	{
		// This is not implemented with FMath::Wrap, because that uses while loops for some reason,
		// and can be slow on large numbers.
		int32 Range = FMath::Abs(Max - Min);
		if (X < Min)
		{
			if (Range == 0)
				return Min;

			int32 Remainder = (Min - X) % Range;

			// Need to special case remainder 0, because unreal Wrap returns Min in that case, not Max,
			// and we want to be compatible
			if (Remainder == 0)
				return Min;
			else
				return Max - Remainder;
		}
		else if (X > Max)
		{
			if (Range == 0)
				return Max;

			int32 Remainder = (X - Max) % Range;

			// Need to special case remainder 0, because unreal Wrap returns Max in that case, not Min
			// and we want to be compatible
			if (Remainder == 0)
				return Max;
			else
				return Min + Remainder;
		}
		else
		{
			return X;
		}
	}

	/**
	 * Wraps X to be between Min and Max, inclusive.
	 * When X can wrap to both Min and Max, it will wrap to Min if it lies below the range and wrap to Max if it is above the range. 
	 **/
	//UFUNCTION(BlueprintCallable, Meta = (ScriptName = "Wrap", DeprecatedFunction, DeprecationMessage = "Wrapping integers is inclusive, and returns unintuitive values. Use Math::WrapIndex for the natural behavior."))
	//static uint32 WrapUInt(uint32 X, uint32 Min, uint32 Max)
	//{
	//	// This is not implemented with FMath::Wrap, because that uses while loops for some reason,
	//	// and can be slow on large numbers.
	//	uint32 Range = (Max - Min);
	//	if (X < Min)
	//	{
	//		if (Range == 0)
	//			return Min;
	//
	//		uint32 Remainder = (Min - X) % Range;
	//
	//		// Need to special case remainder 0, because unreal Wrap returns Min in that case, not Max,
	//		// and we want to be compatible
	//		if (Remainder == 0)
	//			return Min;
	//		else
	//			return Max - Remainder;
	//	}
	//	else if (X > Max)
	//	{
	//		if (Range == 0)
	//			return Max;
	//
	//		uint32 Remainder = (X - Max) % Range;
	//
	//		// Need to special case remainder 0, because unreal Wrap returns Max in that case, not Min
	//		// and we want to be compatible
	//		if (Remainder == 0)
	//			return Max;
	//		else
	//			return Min + Remainder;
	//	}
	//	else
	//	{
	//		return X;
	//	}
	//}

	/**
	 * Wrap the index so it is always [>= Min, < Max)
	 * Values lower than Min are wrapped below Max.
	 * Values Max or higher are wrapped to Min.
	 *
	 * This differs from Math::Wrap() in that the Max boundary is exclusive,
	 * rather than inclusive.
	 */
	UFUNCTION(BlueprintCallable, Meta = (ScriptTrivial, ScriptNoDiscard))	
	static int32 WrapIndex(int32 Value, int32 Min, int32 Max)
	{
		if (Min == Max)
			return Min;
		else if (Min > Max)
			Swap(Min, Max);

		int32 Range = Max - Min;
		int32 ModValue = (Value - Min) % Range;
		if (ModValue >= 0)
			return Min + ModValue;
		else
			return Max + ModValue;
	}

	/**
	 * Wrap the index so it is always [>= Min, < Max)
	 * Values lower than Min are wrapped below Max.
	 * Values Max or higher are wrapped to Min.
	 *
	 * This differs from Math::Wrap() in that the Max boundary is exclusive,
	 * rather than inclusive.
	 */
	UFUNCTION(Meta = (ScriptName = "WrapIndex"))
	static uint32 WrapIndexUInt(uint32 Value, uint32 Min, uint32 Max)
	{
		if (Min == Max)
			return Min;
		else if (Min > Max)
			Swap(Min, Max);

		uint32 Range = Max - Min;
		uint32 ModValue = (Value - Min) % Range;
		if (ModValue >= 0)
			return Min + ModValue;
		else
			return Max + ModValue;
	}
};

//UCLASS(Meta = (ScriptMixin = "FVector"))
UCLASS()
class UAngelscriptFVectorMixinLibrary : public UObject
{
	GENERATED_BODY()

public:

	UFUNCTION(BlueprintCallable)
	static double Size2D(const FVector& Vector, const FVector& UpDirection)
	{
		return FVector::VectorPlaneProject(Vector, UpDirection).Size();
	}

	UFUNCTION(BlueprintCallable)
	static double SizeSquared2D(const FVector& Vector, const FVector& UpDirection)
	{
		return FVector::VectorPlaneProject(Vector, UpDirection).SizeSquared();
	}

	UFUNCTION(BlueprintCallable)
	static FVector PointPlaneProject(const FVector& Vector, const FVector& PlaneBase, const FVector& PlaneNormal)
	{
		return FVector::PointPlaneProject(Vector, PlaneBase, PlaneNormal);
	}

	UFUNCTION(BlueprintCallable)
	static double Dist2D(const FVector& Vector, const FVector& Other, const FVector& UpDirection)
	{
		return FMath::Sqrt(FVector::DistSquared(FVector::VectorPlaneProject(Vector, UpDirection), FVector::VectorPlaneProject(Other, UpDirection)));
	}

	UFUNCTION(BlueprintCallable)
	static double DistSquared2D(const FVector& Vector, const FVector& Other, const FVector& UpDirection)
	{
		return FVector::DistSquared(FVector::VectorPlaneProject(Vector, UpDirection), FVector::VectorPlaneProject(Other, UpDirection));
	}

	// Get the angle in radians between two vectors. Vectors are not assumed to be normalized.
	UFUNCTION(BlueprintCallable)
	static double AngularDistance(const FVector& A, const FVector& B)
	{
		return FMath::Acos(FVector::DotProduct(A, B) / FMath::Sqrt(A.SizeSquared() * B.SizeSquared()));
	}

	// Get the angle in radians between two normal vectors. Both vectors are assumed to be unit length, or a wrong value will be returned.
	UFUNCTION(BlueprintCallable)
	static double AngularDistanceForNormals(const FVector& A, const FVector& B)
	{
		return FMath::Acos(FVector::DotProduct(A, B));
	}

	UFUNCTION(BlueprintCallable)
	static FVector ConstrainToPlane(const FVector& Vector, const FVector& PlaneUp)
	{
		return FVector::VectorPlaneProject(Vector, PlaneUp);
	}

	UFUNCTION(BlueprintCallable)
	static FVector ConstrainToDirection(const FVector& Vector, const FVector& Direction)
	{
		return Direction * FVector::DotProduct(Vector, Direction);
	}

	UFUNCTION(BlueprintCallable)
	static FString ToColorString(const FVector& Vector)
	{
		FString XString = FString::Printf(TEXT("<Red>X=%3.3f </>"), Vector.X);
		FString YString = FString::Printf(TEXT("<Green>Y=%3.3f </>"), Vector.Y);
		FString ZString = FString::Printf(TEXT("<Blue>Z=%3.3f </>"), Vector.Z);
		return XString + YString + ZString;
	}

	UFUNCTION(BlueprintCallable)
	static FVector MoveTowards(const FVector& Vector, const FVector& Target, double StepSize)
	{
		return FMath::VInterpConstantTo(Vector, Target, StepSize, 1.0f);
	}
};

//UCLASS(Meta = (ScriptMixin = "FVector3f"))
UCLASS()
class UAngelscriptFVector3fMixinLibrary : public UObject
{
	GENERATED_BODY()

public:

	UFUNCTION(BlueprintCallable)
	static float Size2D(const FVector3f& Vector, const FVector3f& UpDirection)
	{
		return FVector3f::VectorPlaneProject(Vector, UpDirection).Size();
	}

	UFUNCTION(BlueprintCallable)
	static float SizeSquared2D(const FVector3f& Vector, const FVector3f& UpDirection)
	{
		return FVector3f::VectorPlaneProject(Vector, UpDirection).SizeSquared();
	}

	UFUNCTION(BlueprintCallable)
	static FVector3f PointPlaneProject(const FVector3f& Vector, const FVector3f& PlaneBase, const FVector3f& PlaneNormal)
	{
		return FVector3f::PointPlaneProject(Vector, PlaneBase, PlaneNormal);
	}

	UFUNCTION(BlueprintCallable)
	static float Dist2D(const FVector3f& Vector, const FVector3f& Other, const FVector3f& UpDirection)
	{
		return FMath::Sqrt(FVector3f::DistSquaredXY(FVector3f::VectorPlaneProject(Vector, UpDirection), FVector3f::VectorPlaneProject(Other, UpDirection)));
	}

	UFUNCTION(BlueprintCallable)
	static float DistSquared2D(const FVector3f& Vector, const FVector3f& Other, const FVector3f& UpDirection)
	{
		return FVector3f::DistSquaredXY(FVector3f::VectorPlaneProject(Vector, UpDirection), FVector3f::VectorPlaneProject(Other, UpDirection));
	}

	// Get the angle in radians between two vectors. Vectors are not assumed to be normalized.
	UFUNCTION(BlueprintCallable)
	static float AngularDistance(const FVector3f& A, const FVector3f& B)
	{
		return FMath::Acos(FVector3f::DotProduct(A, B) / FMath::Sqrt(A.SizeSquared() * B.SizeSquared()));
	}

	// Get the angle in radians between two normal vectors. Both vectors are assumed to be unit length, or a wrong value will be returned.
	UFUNCTION(BlueprintCallable)
	static float AngularDistanceForNormals(const FVector3f& A, const FVector3f& B)
	{
		return FMath::Acos(FVector3f::DotProduct(A, B));
	}

	UFUNCTION(BlueprintCallable)
	static FVector3f ConstrainToPlane(const FVector3f& Vector, const FVector3f& PlaneUp)
	{
		return FVector3f::VectorPlaneProject(Vector, PlaneUp);
	}

	UFUNCTION(BlueprintCallable)
	static FVector3f ConstrainToDirection(const FVector3f& Vector, const FVector3f& Direction)
	{
		return Direction * FVector3f::DotProduct(Vector, Direction);
	}

	UFUNCTION(BlueprintCallable)
	static FString ToColorString(const FVector3f& Vector)
	{
		FString XString = FString::Printf(TEXT("<Red>X=%3.3f </>"), Vector.X);
		FString YString = FString::Printf(TEXT("<Green>Y=%3.3f </>"), Vector.Y);
		FString ZString = FString::Printf(TEXT("<Blue>Z=%3.3f </>"), Vector.Z);
		return XString + YString + ZString;
	}
};

//UCLASS(Meta = (ScriptMixin = "FRotator", ScriptName = "FRotator"))
UCLASS(Meta = (ScriptName = "FRotator"))
class UAngelscriptFRotatorLibrary : public UObject
{
	GENERATED_BODY()

public:

	UFUNCTION(BlueprintCallable)
	static FRotator MakeFromAxes(const FVector& Forward, const FVector& Right, const FVector& Up)
	{
		return FMatrix(Forward.GetSafeNormal(), Right.GetSafeNormal(), Up.GetSafeNormal(), FVector::ZeroVector).Rotator();
	}

	UFUNCTION(BlueprintCallable)
	static FVector GetForwardVector(const FRotator& Rotator)
	{
		return Rotator.Vector();
	}

	UFUNCTION(BlueprintCallable)
	static FVector GetRightVector(const FRotator& Rotator)
	{
		return FRotationMatrix(Rotator).GetScaledAxis(EAxis::Y);
	}

	UFUNCTION(BlueprintCallable)
	static FVector GetUpVector(const FRotator& Rotator)
	{
		return FRotationMatrix(Rotator).GetScaledAxis(EAxis::Z);
	}

	UFUNCTION(BlueprintCallable)
	static FRotator Compose(const FRotator& A, const FRotator& B)
	{
		const FQuat AQuat(A);
		const FQuat BQuat(B);

		return FRotator(BQuat*AQuat);
	}

	// Get the angle in degrees between two rotators
	UFUNCTION(BlueprintCallable)
	static double AngularDistance(const FRotator& A, const FRotator& B)
	{
		return FMath::RadiansToDegrees(A.Quaternion().AngularDistance(B.Quaternion()));
	}
};

//UCLASS(Meta = (ScriptMixin = "FRotator3f", ScriptName = "FRotator3f"))
UCLASS(Meta = (ScriptName = "FRotator3f"))
class UAngelscriptFRotator3fLibrary : public UObject
{
	GENERATED_BODY()

public:

	UFUNCTION(BlueprintCallable)
	static FRotator3f MakeFromAxes(const FVector3f& Forward, const FVector3f& Right, const FVector3f& Up)
	{
		return FMatrix44f(Forward.GetSafeNormal(), Right.GetSafeNormal(), Up.GetSafeNormal(), FVector3f::ZeroVector).Rotator();
	}

	UFUNCTION(BlueprintCallable)
	static FVector3f GetForwardVector(const FRotator3f& Rotator)
	{
		return Rotator.Vector();
	}

	UFUNCTION(BlueprintCallable)
	static FVector3f GetRightVector(const FRotator3f& Rotator)
	{
		return FRotationMatrix44f(Rotator).GetScaledAxis(EAxis::Y);
	}

	UFUNCTION(BlueprintCallable)
	static FVector3f GetUpVector(const FRotator3f& Rotator)
	{
		return FRotationMatrix44f(Rotator).GetScaledAxis(EAxis::Z);
	}

	UFUNCTION(BlueprintCallable)
	static FRotator3f Compose(const FRotator3f& A, const FRotator3f& B)
	{
		const FQuat4f AQuat(A);
		const FQuat4f BQuat(B);

		return FRotator3f(BQuat*AQuat);
	}

	// Get the angle in degrees between two rotators
	UFUNCTION(BlueprintCallable)
	static float AngularDistance(const FRotator3f& A, const FRotator3f& B)
	{
		return FMath::RadiansToDegrees(FQuat4f(A).AngularDistance(FQuat4f(B)));
	}

};

//UCLASS(Meta = (ScriptMixin = "FQuat", ScriptName = "FQuat"))
UCLASS(Meta = (ScriptName = "FQuat"))
class UAngelscriptFQuatLibrary : public UObject
{
	GENERATED_BODY()

public:

	UFUNCTION(BlueprintCallable)
	static FQuat MakeFromX(const FVector& XAxis)
	{
		return FRotationMatrix::MakeFromX(XAxis).ToQuat();
	}

	UFUNCTION(BlueprintCallable)
	static FQuat MakeFromY(const FVector& YAxis)
	{
		return FRotationMatrix::MakeFromY(YAxis).ToQuat();
	}

	UFUNCTION(BlueprintCallable)
	static FQuat MakeFromZ(const FVector& ZAxis)
	{
		return FRotationMatrix::MakeFromZ(ZAxis).ToQuat();
	}

	UFUNCTION(BlueprintCallable)
	static FQuat MakeFromXY(const FVector& XAxis, const FVector& YAxis)
	{
		return FRotationMatrix::MakeFromXY(XAxis, YAxis).ToQuat();
	}

	UFUNCTION(BlueprintCallable)
	static FQuat MakeFromXZ(const FVector& XAxis, const FVector& ZAxis)
	{
		return FRotationMatrix::MakeFromXZ(XAxis, ZAxis).ToQuat();
	}

	UFUNCTION(BlueprintCallable)
	static FQuat MakeFromYX(const FVector& YAxis, const FVector& XAxis)
	{
		return FRotationMatrix::MakeFromYX(YAxis, XAxis).ToQuat();
	}

	UFUNCTION(BlueprintCallable)
	static FQuat MakeFromYZ(const FVector& YAxis, const FVector& ZAxis)
	{
		return FRotationMatrix::MakeFromYZ(YAxis, ZAxis).ToQuat();
	}

	UFUNCTION(BlueprintCallable)
	static FQuat MakeFromZX(const FVector& ZAxis, const FVector& XAxis)
	{
		return FRotationMatrix::MakeFromZX(ZAxis, XAxis).ToQuat();
	}

	UFUNCTION(BlueprintCallable)
	static FQuat MakeFromZY(const FVector& ZAxis, const FVector& YAxis)
	{
		return FRotationMatrix::MakeFromZY(ZAxis, YAxis).ToQuat();
	}

	UFUNCTION(BlueprintCallable)
	static FQuat MakeFromAxes(const FVector& Forward, const FVector& Right, const FVector& Up)
	{
		return FMatrix(Forward.GetSafeNormal(), Right.GetSafeNormal(), Up.GetSafeNormal(), FVector::ZeroVector).ToQuat();
	}
};

//UCLASS(Meta = (ScriptMixin = "FQuat4f", ScriptName = "FQuat4f"))
UCLASS(Meta = (ScriptName = "FQuat4f"))
class UAngelscriptFQuat4fLibrary : public UObject
{
	GENERATED_BODY()

public:

	UFUNCTION(BlueprintCallable)
	static FQuat4f MakeFromX(const FVector3f& XAxis)
	{
		return FRotationMatrix44f::MakeFromX(XAxis).ToQuat();
	}

	UFUNCTION(BlueprintCallable)
	static FQuat4f MakeFromY(const FVector3f& YAxis)
	{
		return FRotationMatrix44f::MakeFromY(YAxis).ToQuat();
	}

	UFUNCTION(BlueprintCallable)
	static FQuat4f MakeFromZ(const FVector3f& ZAxis)
	{
		return FRotationMatrix44f::MakeFromZ(ZAxis).ToQuat();
	}

	UFUNCTION(BlueprintCallable)
	static FQuat4f MakeFromXY(const FVector3f& XAxis, const FVector3f& YAxis)
	{
		return FRotationMatrix44f::MakeFromXY(XAxis, YAxis).ToQuat();
	}

	UFUNCTION(BlueprintCallable)
	static FQuat4f MakeFromXZ(const FVector3f& XAxis, const FVector3f& ZAxis)
	{
		return FRotationMatrix44f::MakeFromXZ(XAxis, ZAxis).ToQuat();
	}

	UFUNCTION(BlueprintCallable)
	static FQuat4f MakeFromYX(const FVector3f& YAxis, const FVector3f& XAxis)
	{
		return FRotationMatrix44f::MakeFromYX(YAxis, XAxis).ToQuat();
	}

	UFUNCTION(BlueprintCallable)
	static FQuat4f MakeFromYZ(const FVector3f& YAxis, const FVector3f& ZAxis)
	{
		return FRotationMatrix44f::MakeFromYZ(YAxis, ZAxis).ToQuat();
	}

	UFUNCTION(BlueprintCallable)
	static FQuat4f MakeFromZX(const FVector3f& ZAxis, const FVector3f& XAxis)
	{
		return FRotationMatrix44f::MakeFromZX(ZAxis, XAxis).ToQuat();
	}

	UFUNCTION(BlueprintCallable)
	static FQuat4f MakeFromZY(const FVector3f& ZAxis, const FVector3f& YAxis)
	{
		return FRotationMatrix44f::MakeFromZY(ZAxis, YAxis).ToQuat();
	}

	UFUNCTION(BlueprintCallable)
	static FQuat4f MakeFromAxes(const FVector3f& Forward, const FVector3f& Right, const FVector3f& Up)
	{
		return FMatrix44f(Forward.GetSafeNormal(), Right.GetSafeNormal(), Up.GetSafeNormal(), FVector3f::ZeroVector).ToQuat();
	}
};

//UCLASS(Meta = (ScriptMixin = "FTransform", ScriptName = "FTransform"))
UCLASS(Meta = (ScriptName = "FTransform"))
class UAngelscriptFTransformLibrary : public UObject
{
	GENERATED_BODY()

public:

	UFUNCTION(BlueprintCallable)
	static void Blend(FTransform& Transform, const FTransform& Atom1, const FTransform& Atom2, double Alpha)
	{
		Transform.Blend(Atom1, Atom2, (float)Alpha);
	}

	UFUNCTION(BlueprintCallable)
	static void BlendWith(FTransform& Transform, const FTransform& OtherAtom, double Alpha)
	{
		return Transform.BlendWith(OtherAtom, (float)Alpha);
	}

	UFUNCTION(BlueprintCallable)
	static FRotator TransformRotation(const FTransform& Transform, const FRotator& R)
	{
		return Transform.TransformRotation(R.Quaternion()).Rotator();
	}

	UFUNCTION(BlueprintCallable)
	static FRotator InverseTransformRotation(const FTransform& Transform, const FRotator& R)
	{
		return Transform.InverseTransformRotation(R.Quaternion()).Rotator();
	}

	UFUNCTION(BlueprintCallable)
	static void SetRotation(FTransform& Transform, const FRotator& NewRotation)
	{
		Transform.SetRotation(NewRotation.Quaternion());
	}

	UFUNCTION(BlueprintCallable)
	static FTransform MakeFromXY(const FVector& XAxis, const FVector& YAxis)
	{
		return FTransform(FRotationMatrix::MakeFromXY(XAxis, YAxis));
	}

	UFUNCTION(BlueprintCallable)
	static FTransform MakeFromXZ(const FVector& XAxis, const FVector& ZAxis)
	{
		return FTransform(FRotationMatrix::MakeFromXZ(XAxis, ZAxis));
	}

	UFUNCTION(BlueprintCallable)
	static FTransform MakeFromYX(const FVector& YAxis, const FVector& XAxis)
	{
		return FTransform(FRotationMatrix::MakeFromYX(YAxis, XAxis));
	}

	UFUNCTION(BlueprintCallable)
	static FTransform MakeFromYZ(const FVector& YAxis, const FVector& ZAxis)
	{
		return FTransform(FRotationMatrix::MakeFromYZ(YAxis, ZAxis));
	}

	UFUNCTION(BlueprintCallable)
	static FTransform MakeFromZX(const FVector& ZAxis, const FVector& XAxis)
	{
		return FTransform(FRotationMatrix::MakeFromZX(ZAxis, XAxis));
	}

	UFUNCTION(BlueprintCallable)
	static FTransform MakeFromZY(const FVector& ZAxis, const FVector& YAxis)
	{
		return FTransform(FRotationMatrix::MakeFromZY(ZAxis, YAxis));
	}
};

//UCLASS(Meta = (ScriptMixin = "FTransform3f", ScriptName = "FTransform3f"))
UCLASS(Meta = (ScriptName = "FTransform3f"))
class UAngelscriptFTransform3fLibrary : public UObject
{
	GENERATED_BODY()

public:

	UFUNCTION(BlueprintCallable)
	static FRotator3f TransformRotation(const FTransform3f& Transform, const FRotator3f& R)
	{
		return Transform.TransformRotation(R.Quaternion()).Rotator();
	}

	UFUNCTION(BlueprintCallable)
	static FRotator3f InverseTransformRotation(const FTransform3f& Transform, const FRotator3f& R)
	{
		return Transform.InverseTransformRotation(R.Quaternion()).Rotator();
	}

	UFUNCTION(BlueprintCallable)
	static void SetRotation(FTransform3f& Transform, const FRotator3f& NewRotation)
	{
		Transform.SetRotation(NewRotation.Quaternion());
	}

	UFUNCTION(BlueprintCallable)
	static FTransform3f MakeFromXY(const FVector3f& XAxis, const FVector3f& YAxis)
	{
		return FTransform3f(FRotationMatrix44f::MakeFromXY(XAxis, YAxis));
	}

	UFUNCTION(BlueprintCallable)
	static FTransform3f MakeFromXZ(const FVector3f& XAxis, const FVector3f& ZAxis)
	{
		return FTransform3f(FRotationMatrix44f::MakeFromXZ(XAxis, ZAxis));
	}

	UFUNCTION(BlueprintCallable)
	static FTransform3f MakeFromYX(const FVector3f& YAxis, const FVector3f& XAxis)
	{
		return FTransform3f(FRotationMatrix44f::MakeFromYX(YAxis, XAxis));
	}

	UFUNCTION(BlueprintCallable)
	static FTransform3f MakeFromYZ(const FVector3f& YAxis, const FVector3f& ZAxis)
	{
		return FTransform3f(FRotationMatrix44f::MakeFromYZ(YAxis, ZAxis));
	}

	UFUNCTION(BlueprintCallable)
	static FTransform3f MakeFromZX(const FVector3f& ZAxis, const FVector3f& XAxis)
	{
		return FTransform3f(FRotationMatrix44f::MakeFromZX(ZAxis, XAxis));
	}

	UFUNCTION(BlueprintCallable)
	static FTransform3f MakeFromZY(const FVector3f& ZAxis, const FVector3f& YAxis)
	{
		return FTransform3f(FRotationMatrix44f::MakeFromZY(ZAxis, YAxis));
	}
};
