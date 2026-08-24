// Theme: Gameplay.FVector. Positive DotProduct/CrossProduct oracles.
// C++: AngelscriptCoverageFVectorExpressionTests.cpp::FVectorDotAndCross
// Oracle: DotProduct orthogonal 0.0; DotProductGeneral 56.0;
// CrossProduct (0,0,1). Extra: empty ZeroVector dot 0; copy independence of
// CrossProduct inputs. DefaultSafe.

float DotProduct()
{
	FVector a = FVector(1, 0, 0);
	FVector b = FVector(0, 1, 0);
	return a.DotProduct(b);
}

float DotProductGeneral()
{
	FVector a = FVector(2, 3, 4);
	FVector b = FVector(5, 6, 7);
	return a.DotProduct(b);
}

FVector CrossProduct()
{
	FVector a = FVector(1, 0, 0);
	FVector b = FVector(0, 1, 0);
	return a.CrossProduct(b);
}

bool Observe_DotProduct()
{
	return Math::IsNearlyEqual(DotProduct(), 0.0);
}

bool Observe_DotProductGeneral()
{
	return Math::IsNearlyEqual(DotProductGeneral(), 56.0);
}

bool Observe_CrossProduct()
{
	return CrossProduct().Equals(FVector(0, 0, 1));
}

bool Observe_DotProduct_DefaultEmpty()
{
	FVector Empty = FVector();
	return Math::IsNearlyEqual(Empty.DotProduct(FVector::ZeroVector), 0.0);
}

bool Observe_CrossProduct_CopyIndependence()
{
	FVector A = FVector(1, 0, 0);
	FVector B = FVector(0, 1, 0);
	FVector Cross = A.CrossProduct(B);
	Cross.Z = 0.0;
	return A.Equals(FVector(1, 0, 0)) && B.Equals(FVector(0, 1, 0));
}
