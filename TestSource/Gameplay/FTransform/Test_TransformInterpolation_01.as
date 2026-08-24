// Theme: Gameplay.FTransform. Positive Blend interpolation oracles.
// C++: AngelscriptCoverageFTransformExpressionTests.cpp::TransformInterpolation (compiling block)
// CSV Positive; C++ compiles Blend. Math::Lerp is a separate CompileAndExpectFailure file (_02).
// Oracle: Blend 0.5 of (0,0,0)/(100,100,100); BlendAtZero (100,200,300);
// BlendAtOne (400,500,600); BlendWithScale native Blend at 0.5.
// Extra: Blend of Identity with itself; copy independence of A. DefaultSafe.

FTransform BlendTransforms()
{
	FTransform A = FTransform(FVector(0, 0, 0));
	FTransform B = FTransform(FVector(100, 100, 100));
	FTransform Result;
	Result.Blend(A, B, 0.5f);
	return Result;
}

FTransform BlendAtZero()
{
	FTransform A = FTransform(FVector(100, 200, 300));
	FTransform B = FTransform(FVector(400, 500, 600));
	FTransform Result;
	Result.Blend(A, B, 0.0f);
	return Result;
}

FTransform BlendAtOne()
{
	FTransform A = FTransform(FVector(100, 200, 300));
	FTransform B = FTransform(FVector(400, 500, 600));
	FTransform Result;
	Result.Blend(A, B, 1.0f);
	return Result;
}

FTransform BlendWithScale()
{
	FTransform A = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(1, 1, 1));
	FTransform B = FTransform(FQuat::Identity, FVector(100, 0, 0), FVector(3, 3, 3));
	FTransform Result;
	Result.Blend(A, B, 0.5f);
	return Result;
}

bool Observe_BlendTransforms()
{
	FTransform A = FTransform(FVector(0, 0, 0));
	FTransform B = FTransform(FVector(100, 100, 100));
	FTransform Expected;
	Expected.Blend(A, B, 0.5f);
	return BlendTransforms().Equals(Expected, 0.01);
}

bool Observe_BlendAtZero()
{
	return BlendAtZero().Equals(FTransform(FVector(100, 200, 300)), 0.01);
}

bool Observe_BlendAtOne()
{
	return BlendAtOne().Equals(FTransform(FVector(400, 500, 600)), 0.01);
}

bool Observe_BlendWithScale()
{
	FTransform A = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(1, 1, 1));
	FTransform B = FTransform(FQuat::Identity, FVector(100, 0, 0), FVector(3, 3, 3));
	FTransform Expected;
	Expected.Blend(A, B, 0.5f);
	return BlendWithScale().Equals(Expected, 0.01);
}

bool Observe_BlendTransforms_DefaultIdentity()
{
	FTransform A = FTransform();
	FTransform B = FTransform::Identity;
	FTransform Result;
	Result.Blend(A, B, 0.5f);
	return Result.Equals(FTransform::Identity, 0.01);
}

bool Observe_BlendTransforms_CopyIndependence()
{
	FTransform A = FTransform(FVector(0, 0, 0));
	FTransform B = FTransform(FVector(100, 100, 100));
	FTransform Result;
	Result.Blend(A, B, 0.5f);
	Result.SetLocation(FVector::ZeroVector);
	return A.GetLocation().Equals(FVector(0, 0, 0), 0.001)
		&& B.GetLocation().Equals(FVector(100, 100, 100), 0.001);
}
