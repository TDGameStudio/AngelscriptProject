/**
 * The neighbouring integral and four-component vector structs: FVector4, FIntPoint and
 * FIntVector, each exercised through construction, member and index access, arithmetic and
 * the measurement methods. C++ executes each entrypoint and checks the value it produces,
 * so those names are part of the contract and are kept verbatim. The observers cover the
 * empty FIntVector and the independence of a FVector4 operand.
 *
 * @Theme Gameplay.FVector
 * @Subject FVector.Vector4IntPointIntVectorExpressions
 * @Harness Function
 * @Tag Gameplay.FVector.Vector4IntPointIntVectorExpressions
 * @Namespace FVectorTest
 * @Provenance Theme: Gameplay.FVector. Positive FVector4/FIntPoint/FIntVector oracles.
 * @Provenance C++: AngelscriptCoverageMathGeometricStructs.cpp::Vector4IntPointIntVectorExpressions
 * @Provenance Oracle: FVector4 (1,2,3,4); from FVector (5,6,7,8); members+index 13.0;
 * @Provenance arithmetic (2,3,4,5); FIntPoint (3,4); members 30; arithmetic (4,8);
 * @Provenance FIntVector (1,2,3); members 42; arithmetic (-4,-8,-12); IsZero true.
 * @Provenance Extra: empty FIntVector IsZero true; copy independence of Vector4 arithmetic.
 * @Provenance DefaultSafe.
 */

namespace FVectorTest
{
	/**
	 * Construct a four-component vector from four values.
	 *
	 * @Kind Observe
	 * @Covers FVector.Vector4IntPointIntVectorExpressions
	 * @Inputs none
	 * @Return FVector4(1, 2, 3, 4)
	 */
	UFUNCTION()
	FVector4 TestVector4Construction()
	{
		return FVector4(1, 2, 3, 4);
	}

	/**
	 * Construct a four-component vector from a three-component one and a W.
	 *
	 * @Kind Observe
	 * @Covers FVector.Vector4IntPointIntVectorExpressions
	 * @Inputs none
	 * @Return FVector4(5, 6, 7, 8)
	 */
	UFUNCTION()
	FVector4 TestVector4FromVector()
	{
		return FVector4(FVector(5, 6, 7), 8);
	}

	/**
	 * Sum every member plus one indexed access of a four-component vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.Vector4IntPointIntVectorExpressions
	 * @Inputs none
	 * @Return 13
	 */
	UFUNCTION()
	float64 TestVector4MembersAndIndex()
	{
		FVector4 Value = FVector4(1, 2, 3, 4);
		return Value.X + Value.Y + Value.Z + Value.W + Value[2];
	}

	/**
	 * Add to and scale a four-component vector, then halve it back.
	 *
	 * @Kind Observe
	 * @Covers FVector.Vector4IntPointIntVectorExpressions
	 * @Inputs none
	 * @Return FVector4(2, 3, 4, 5)
	 */
	UFUNCTION()
	FVector4 TestVector4Arithmetic()
	{
		FVector4 Value = FVector4(1, 2, 3, 4);
		Value = (Value + FVector4(1, 1, 1, 1)) * 2.0;
		return Value / 2.0;
	}

	/**
	 * Construct an integer point from two values.
	 *
	 * @Kind Observe
	 * @Covers FVector.Vector4IntPointIntVectorExpressions
	 * @Inputs none
	 * @Return FIntPoint(3, 4)
	 */
	UFUNCTION()
	FIntPoint TestIntPointConstruction()
	{
		return FIntPoint(3, 4);
	}

	/**
	 * Sum the members, an indexed access and the measurement methods of an integer point.
	 *
	 * @Kind Observe
	 * @Covers FVector.Vector4IntPointIntVectorExpressions
	 * @Inputs none
	 * @Return 30
	 */
	UFUNCTION()
	int TestIntPointMembersIndexAndMethods()
	{
		FIntPoint Point = FIntPoint(3, 7);
		return Point.X + Point.Y + Point[0] + Point.GetMax() + Point.GetMin() + Point.Size();
	}

	/**
	 * Apply compound addition, scaling and subtraction to an integer point.
	 *
	 * @Kind Observe
	 * @Covers FVector.Vector4IntPointIntVectorExpressions
	 * @Inputs none
	 * @Return FIntPoint(4, 8)
	 */
	UFUNCTION()
	FIntPoint TestIntPointArithmetic()
	{
		FIntPoint Point = FIntPoint(2, 4);
		Point += FIntPoint(3, 5);
		Point *= 2;
		Point /= 2;
		return Point - FIntPoint(1, 1);
	}

	/**
	 * Construct an integer vector from three values.
	 *
	 * @Kind Observe
	 * @Covers FVector.Vector4IntPointIntVectorExpressions
	 * @Inputs none
	 * @Return FIntVector(1, 2, 3)
	 */
	UFUNCTION()
	FIntVector TestIntVectorConstruction()
	{
		return FIntVector(1, 2, 3);
	}

	/**
	 * Sum the members, an indexed access and the measurement methods of an integer vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.Vector4IntPointIntVectorExpressions
	 * @Inputs none
	 * @Return 42
	 */
	UFUNCTION()
	int TestIntVectorMembersIndexAndMethods()
	{
		FIntVector Value = FIntVector(2, 5, 8);
		return Value.X + Value.Y + Value.Z + Value[2] + Value.GetMax() + Value.GetMin() + Value.Size();
	}

	/**
	 * Apply compound operations and negation to an integer vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.Vector4IntPointIntVectorExpressions
	 * @Inputs none
	 * @Return FIntVector(-4, -8, -12)
	 */
	UFUNCTION()
	FIntVector TestIntVectorArithmetic()
	{
		FIntVector Value = FIntVector(2, 4, 6);
		Value += FIntVector(3, 5, 7);
		Value -= FIntVector(1, 1, 1);
		Value *= 2;
		Value /= 2;
		return -Value;
	}

	/**
	 * Ask whether an empty integer vector is zero and a populated one is not.
	 *
	 * @Kind Observe
	 * @Covers FVector.Vector4IntPointIntVectorExpressions
	 * @Inputs none
	 * @Return true when the empty one reports zero and the populated one does not
	 */
	UFUNCTION()
	bool TestIntVectorIsZero()
	{
		if (!FIntVector().IsZero())
		{
			return false;
		}
		return !FIntVector(1, 0, 0).IsZero();
	}

	/**
	 * Observe that the four-component construction keeps all four values.
	 *
	 * @Kind Observe
	 * @Covers FVector.Vector4IntPointIntVectorExpressions
	 * @Inputs none
	 * @Return true when the result reads (1, 2, 3, 4)
	 */
	UFUNCTION()
	bool Vector4ConstructionNominal()
	{
		FVector4 Result = TestVector4Construction();

		if (Result.X != 1.0)
		{
			return false;
		}
		if (Result.Y != 2.0)
		{
			return false;
		}
		if (Result.Z != 3.0)
		{
			return false;
		}
		return Result.W == 4.0;
	}

	/**
	 * Observe that the from-vector construction keeps all four values.
	 *
	 * @Kind Observe
	 * @Covers FVector.Vector4IntPointIntVectorExpressions
	 * @Inputs none
	 * @Return true when the result reads (5, 6, 7, 8)
	 */
	UFUNCTION()
	bool Vector4FromVectorNominal()
	{
		FVector4 Result = TestVector4FromVector();

		if (Result.X != 5.0)
		{
			return false;
		}
		if (Result.Y != 6.0)
		{
			return false;
		}
		if (Result.Z != 7.0)
		{
			return false;
		}
		return Result.W == 8.0;
	}

	/**
	 * Observe that the member and index sum matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector.Vector4IntPointIntVectorExpressions
	 * @Inputs none
	 * @Return true when the sum is 13
	 */
	UFUNCTION()
	bool Vector4MembersAndIndexNominal()
	{
		return Math::IsNearlyEqual(TestVector4MembersAndIndex(), 13.0);
	}

	/**
	 * Observe that the four-component arithmetic matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector.Vector4IntPointIntVectorExpressions
	 * @Inputs none
	 * @Return true when the result reads (2, 3, 4, 5)
	 */
	UFUNCTION()
	bool Vector4ArithmeticNominal()
	{
		FVector4 Result = TestVector4Arithmetic();

		if (Result.X != 2.0)
		{
			return false;
		}
		if (Result.Y != 3.0)
		{
			return false;
		}
		if (Result.Z != 4.0)
		{
			return false;
		}
		return Result.W == 5.0;
	}

	/**
	 * Observe that the integer point construction keeps both values.
	 *
	 * @Kind Observe
	 * @Covers FVector.Vector4IntPointIntVectorExpressions
	 * @Inputs none
	 * @Return true when the result reads (3, 4)
	 */
	UFUNCTION()
	bool IntPointConstructionNominal()
	{
		FIntPoint Result = TestIntPointConstruction();

		if (Result.X != 3)
		{
			return false;
		}
		return Result.Y == 4;
	}

	/**
	 * Observe that the integer point member and index sum matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector.Vector4IntPointIntVectorExpressions
	 * @Inputs none
	 * @Return true when the sum is 30
	 */
	UFUNCTION()
	bool IntPointMembersIndexAndMethodsNominal()
	{
		return TestIntPointMembersIndexAndMethods() == 30;
	}

	/**
	 * Observe that the integer point arithmetic matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector.Vector4IntPointIntVectorExpressions
	 * @Inputs none
	 * @Return true when the result reads (4, 8)
	 */
	UFUNCTION()
	bool IntPointArithmeticNominal()
	{
		FIntPoint Result = TestIntPointArithmetic();

		if (Result.X != 4)
		{
			return false;
		}
		return Result.Y == 8;
	}

	/**
	 * Observe that the integer vector construction keeps all three values.
	 *
	 * @Kind Observe
	 * @Covers FVector.Vector4IntPointIntVectorExpressions
	 * @Inputs none
	 * @Return true when the result reads (1, 2, 3)
	 */
	UFUNCTION()
	bool IntVectorConstructionNominal()
	{
		FIntVector Result = TestIntVectorConstruction();

		if (Result.X != 1)
		{
			return false;
		}
		if (Result.Y != 2)
		{
			return false;
		}
		return Result.Z == 3;
	}

	/**
	 * Observe that the integer vector member and index sum matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector.Vector4IntPointIntVectorExpressions
	 * @Inputs none
	 * @Return true when the sum is 42
	 */
	UFUNCTION()
	bool IntVectorMembersIndexAndMethodsNominal()
	{
		return TestIntVectorMembersIndexAndMethods() == 42;
	}

	/**
	 * Observe that the integer vector arithmetic matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector.Vector4IntPointIntVectorExpressions
	 * @Inputs none
	 * @Return true when the result reads (-4, -8, -12)
	 */
	UFUNCTION()
	bool IntVectorArithmeticNominal()
	{
		FIntVector Result = TestIntVectorArithmetic();

		if (Result.X != -4)
		{
			return false;
		}
		if (Result.Y != -8)
		{
			return false;
		}
		return Result.Z == -12;
	}

	/**
	 * Observe that the integer vector zero checks agree.
	 *
	 * @Kind Observe
	 * @Covers FVector.Vector4IntPointIntVectorExpressions
	 * @Inputs none
	 * @Return TestIntVectorIsZero(), expected true
	 */
	UFUNCTION()
	bool IntVectorIsZeroNominal()
	{
		return TestIntVectorIsZero();
	}

	/**
	 * Observe that an empty integer vector reports itself as zero.
	 *
	 * @Kind Observe
	 * @Covers FVector.Vector4IntPointIntVectorExpressions
	 * @Inputs a default-constructed integer vector
	 * @Return true when the flag is set
	 * @Boundary default value
	 */
	UFUNCTION()
	bool IntVectorIsZeroDefaultEmpty()
	{
		FIntVector Empty = FIntVector();
		return Empty.IsZero();
	}

	/**
	 * Observe that mutating a four-component sum leaves the operand untouched.
	 *
	 * @Kind Observe
	 * @Covers FVector.Vector4IntPointIntVectorExpressions
	 * @Inputs a four-component vector and a mutated sum built from it
	 * @Return true when the operand still reads (1, 2, 3, 4) and the sum reads 4 on X
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool Vector4ArithmeticCopyIndependence()
	{
		FVector4 Original = FVector4(1, 2, 3, 4);
		FVector4 Mutated = Original;
		Mutated = (Mutated + FVector4(1, 1, 1, 1)) * 2.0;

		if (Original.X != 1.0)
		{
			return false;
		}
		if (Original.W != 4.0)
		{
			return false;
		}
		return Mutated.X == 4.0;
	}
}
