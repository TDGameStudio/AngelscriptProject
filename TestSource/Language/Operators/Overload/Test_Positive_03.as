// Theme: Language.Operators.Overload. Positive opMul compile plus value oracle.
// C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Positive
// sha256=b181cf048aa7a93f7189a76157435910d9d8c29141aec9b96c4547415f00f26e; lines 85-99.
// C++ AssertCompiles; observations execute opMul.
// Oracle: (2,3)*4=(8,12). Extra: default *0 is (0,0); *1 is identity; result copy is independent.
// DefaultSafe. Source owns locals.

struct FVecMul
{
	int X = 0;
	int Y = 0;

	FVecMul opMul(int Scalar) const
	{
		FVecMul Result;
		Result.X = X * Scalar;
		Result.Y = Y * Scalar;
		return Result;
	}
}

bool Observe_FVecMul_Nominal()
{
	FVecMul A;
	A.X = 2;
	A.Y = 3;
	FVecMul Product = A * 4;
	return Product.X == 8 && Product.Y == 12;
}

bool Observe_FVecMul_EmptyDefault()
{
	FVecMul A;
	FVecMul Zero = A * 0;
	FVecMul Scaled = A * 5;
	return Zero.X == 0 && Zero.Y == 0 && Scaled.X == 0 && Scaled.Y == 0;
}

bool Observe_FVecMul_IdentityAndCopyIndependence()
{
	FVecMul A;
	A.X = 6;
	A.Y = 7;
	FVecMul Identity = A * 1;
	FVecMul Product = A * 2;
	Product.X = 0;
	Product.Y = 0;
	return Identity.X == 6 && Identity.Y == 7 && A.X == 6 && A.Y == 7;
}
