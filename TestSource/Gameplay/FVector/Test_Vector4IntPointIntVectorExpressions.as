// Theme: Gameplay.FVector. Positive FVector4/FIntPoint/FIntVector oracles.
// C++: AngelscriptCoverageMathGeometricStructs.cpp::Vector4IntPointIntVectorExpressions
// Oracle: FVector4 (1,2,3,4); from FVector (5,6,7,8); members+index 13.0;
// arithmetic (2,3,4,5); FIntPoint (3,4); members 30; arithmetic (4,8);
// FIntVector (1,2,3); members 42; arithmetic (-4,-8,-12); IsZero true.
// Extra: empty FIntVector IsZero true; copy independence of Vector4 arithmetic.
// DefaultSafe.

FVector4 TestVector4Construction()
{
	return FVector4(1, 2, 3, 4);
}

FVector4 TestVector4FromVector()
{
	return FVector4(FVector(5, 6, 7), 8);
}

float64 TestVector4MembersAndIndex()
{
	FVector4 Value = FVector4(1, 2, 3, 4);
	return Value.X + Value.Y + Value.Z + Value.W + Value[2];
}

FVector4 TestVector4Arithmetic()
{
	FVector4 Value = FVector4(1, 2, 3, 4);
	Value = (Value + FVector4(1, 1, 1, 1)) * 2.0;
	return Value / 2.0;
}

FIntPoint TestIntPointConstruction()
{
	return FIntPoint(3, 4);
}

int TestIntPointMembersIndexAndMethods()
{
	FIntPoint Point = FIntPoint(3, 7);
	return Point.X + Point.Y + Point[0] + Point.GetMax() + Point.GetMin() + Point.Size();
}

FIntPoint TestIntPointArithmetic()
{
	FIntPoint Point = FIntPoint(2, 4);
	Point += FIntPoint(3, 5);
	Point *= 2;
	Point /= 2;
	return Point - FIntPoint(1, 1);
}

FIntVector TestIntVectorConstruction()
{
	return FIntVector(1, 2, 3);
}

int TestIntVectorMembersIndexAndMethods()
{
	FIntVector Value = FIntVector(2, 5, 8);
	return Value.X + Value.Y + Value.Z + Value[2] + Value.GetMax() + Value.GetMin() + Value.Size();
}

FIntVector TestIntVectorArithmetic()
{
	FIntVector Value = FIntVector(2, 4, 6);
	Value += FIntVector(3, 5, 7);
	Value -= FIntVector(1, 1, 1);
	Value *= 2;
	Value /= 2;
	return -Value;
}

bool TestIntVectorIsZero()
{
	return FIntVector().IsZero() && !FIntVector(1, 0, 0).IsZero();
}

bool Observe_TestVector4Construction()
{
	FVector4 Result = TestVector4Construction();
	return Result.X == 1.0 && Result.Y == 2.0 && Result.Z == 3.0 && Result.W == 4.0;
}

bool Observe_TestVector4FromVector()
{
	FVector4 Result = TestVector4FromVector();
	return Result.X == 5.0 && Result.Y == 6.0 && Result.Z == 7.0 && Result.W == 8.0;
}

bool Observe_TestVector4MembersAndIndex()
{
	return Math::IsNearlyEqual(TestVector4MembersAndIndex(), 13.0);
}

bool Observe_TestVector4Arithmetic()
{
	FVector4 Result = TestVector4Arithmetic();
	return Result.X == 2.0 && Result.Y == 3.0 && Result.Z == 4.0 && Result.W == 5.0;
}

bool Observe_TestIntPointConstruction()
{
	FIntPoint Result = TestIntPointConstruction();
	return Result.X == 3 && Result.Y == 4;
}

bool Observe_TestIntPointMembersIndexAndMethods()
{
	return TestIntPointMembersIndexAndMethods() == 30;
}

bool Observe_TestIntPointArithmetic()
{
	FIntPoint Result = TestIntPointArithmetic();
	return Result.X == 4 && Result.Y == 8;
}

bool Observe_TestIntVectorConstruction()
{
	FIntVector Result = TestIntVectorConstruction();
	return Result.X == 1 && Result.Y == 2 && Result.Z == 3;
}

bool Observe_TestIntVectorMembersIndexAndMethods()
{
	return TestIntVectorMembersIndexAndMethods() == 42;
}

bool Observe_TestIntVectorArithmetic()
{
	FIntVector Result = TestIntVectorArithmetic();
	return Result.X == -4 && Result.Y == -8 && Result.Z == -12;
}

bool Observe_TestIntVectorIsZero()
{
	return TestIntVectorIsZero() == true;
}

bool Observe_TestIntVectorIsZero_DefaultEmpty()
{
	FIntVector Empty = FIntVector();
	return Empty.IsZero() == true;
}

bool Observe_TestVector4Arithmetic_CopyIndependence()
{
	FVector4 Original = FVector4(1, 2, 3, 4);
	FVector4 Mutated = Original;
	Mutated = (Mutated + FVector4(1, 1, 1, 1)) * 2.0;
	return Original.X == 1.0 && Original.W == 4.0 && Mutated.X == 4.0;
}
