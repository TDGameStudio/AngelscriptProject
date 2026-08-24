// Theme: Gameplay.FVector2D. Positive DotProduct oracles.
// C++: AngelscriptCoverageFVector2DExpressionTests.cpp::Vector2DDotProduct
// Oracle: orthogonal 0.0; parallel 50.0; general 23.0.
// Extra: empty ZeroVector dot 0; copy independence of inputs. DefaultSafe.

float DotProductOrthogonal()
{
	FVector2D a = FVector2D(1.0, 0.0);
	FVector2D b = FVector2D(0.0, 1.0);
	return a.DotProduct(b);
}

float DotProductParallel()
{
	FVector2D a = FVector2D(3.0, 4.0);
	FVector2D b = FVector2D(6.0, 8.0);
	return a.DotProduct(b);
}

float DotProductGeneral()
{
	FVector2D a = FVector2D(2.0, 3.0);
	FVector2D b = FVector2D(4.0, 5.0);
	return a.DotProduct(b);
}

bool Observe_DotProductOrthogonal()
{
	return Math::IsNearlyEqual(DotProductOrthogonal(), 0.0);
}

bool Observe_DotProductParallel()
{
	return Math::IsNearlyEqual(DotProductParallel(), 50.0);
}

bool Observe_DotProductGeneral()
{
	return Math::IsNearlyEqual(DotProductGeneral(), 23.0);
}

bool Observe_DotProduct_DefaultEmpty()
{
	FVector2D Empty = FVector2D();
	return Math::IsNearlyEqual(Empty.DotProduct(FVector2D::ZeroVector), 0.0);
}

bool Observe_DotProductParallel_CopyIndependence()
{
	FVector2D A = FVector2D(3.0, 4.0);
	FVector2D B = FVector2D(6.0, 8.0);
	float Dot = A.DotProduct(B);
	A.X = 0.0;
	return Math::IsNearlyEqual(Dot, 50.0) && B.Equals(FVector2D(6.0, 8.0));
}
