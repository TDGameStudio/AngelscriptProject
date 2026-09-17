/**
 * @version v1
 * @summary Value-type operator overload declarations without observation wrappers.
 * @topic Language
 * @topic Operators
 *
 * overload                      // A two-axis value type with add, subtract, multiply, negate, and equality overloads.
 * compare-overload              // A comparable value type with a dedicated less-than overload.
 * container-op-index            // Positive language form retained from legacy container op index.
 * f-val-cmp-overload            // Positive language form retained from legacy f val cmp overload.
 * f-vec-add-assign-overload     // Positive language form retained from legacy f vec add assign overload.
 * f-vec-add-overload            // Positive language form retained from legacy f vec add overload.
 * f-vec-equals-overload         // Positive language form retained from legacy f vec equals overload.
 * f-vec-mul-overload            // Positive language form retained from legacy f vec mul overload.
 * f-vec-neg-overload            // Positive language form retained from legacy f vec neg overload.
 * f-vec-sub-overload            // Positive language form retained from legacy f vec sub overload.
 * f-vec-usage-overload          // Positive language form retained from legacy f vec usage overload.
 * score-operator-suite          // Positive language form retained from legacy score operator suite.
 * op-index-read-write           // A value type with opIndex used on both sides of assignment.
 * unary-index-and-conversion    // Positive language form retained from legacy unary index and conversion operators.
 */
/**
 * @begin overload
 * @summary A two-axis value type with add, subtract, multiply, negate, and equality overloads.
 */
struct FVec
{
	int X;
	int Y;

	FVec opAdd(const FVec& Other) const
	{
		FVec Result;
		Result.X = X + Other.X;
		Result.Y = Y + Other.Y;
		return Result;
	}

	FVec opSub(const FVec& Other) const
	{
		FVec Result;
		Result.X = X - Other.X;
		Result.Y = Y - Other.Y;
		return Result;
	}

	FVec opMul(int Scale) const
	{
		FVec Result;
		Result.X = X * Scale;
		Result.Y = Y * Scale;
		return Result;
	}

	FVec opNeg() const
	{
		FVec Result;
		Result.X = -X;
		Result.Y = -Y;
		return Result;
	}

	bool opEquals(const FVec& Other) const
	{
		return X == Other.X && Y == Other.Y;
	}

	FVec& opAddAssign(const FVec& Other)
	{
		X += Other.X;
		Y += Other.Y;
		return this;
	}
}

int UseOverloads()
{
	FVec A;
	A.X = 1;
	A.Y = 2;
	FVec B;
	B.X = 3;
	B.Y = 4;
	FVec Sum = A + B;
	FVec Diff = B - A;
	FVec Scaled = A * 2;
	FVec Negated = -A;
	A += B;
	return (Sum.X + Diff.Y + Scaled.X + Negated.Y + (A == B ? 1 : 0));
}
/** @end */
/**
 * @begin compare-overload
 * @summary A comparable value type with a dedicated less-than overload.
 * @topic Operators
 */
struct FVal
{
	int Score;

	bool opCmp(const FVal& Other) const
	{
		if (Score < Other.Score)
		{
			return true;
		}
		return false;
	}
}
/** @end */
/**
 * @begin container-op-index
 * @summary Positive language form retained from legacy container op index.
 * @topic Operators
 */
struct FMyContainer
	{
		array<int> Data;

		int opIndex(int Index) const
		{
			return Data[Index];
		}
	}
/** @end */
/**
 * @begin f-val-cmp-overload
 * @summary Positive language form retained from legacy f val cmp overload.
 * @topic Operators
 */
struct FValCmp
	{
		int Value = 0;

		int opCmp(const FValCmp&in Other) const
		{
			return Value - Other.Value;
		}
	}
/** @end */
/**
 * @begin f-vec-add-assign-overload
 * @summary Positive language form retained from legacy f vec add assign overload.
 * @topic Operators
 */
struct FVecAddAssign
	{
		int X = 0;
		int Y = 0;

		FVecAddAssign& opAddAssign(const FVecAddAssign&in Other)
		{
			X += Other.X;
			Y += Other.Y;
			return this;
		}
	}
/** @end */
/**
 * @begin f-vec-add-overload
 * @summary Positive language form retained from legacy f vec add overload.
 * @topic Operators
 */
struct FVecAdd
	{
		int X = 0;
		int Y = 0;

		FVecAdd opAdd(const FVecAdd&in Other) const
		{
			FVecAdd Result;
			Result.X = X + Other.X;
			Result.Y = Y + Other.Y;
			return Result;
		}
	}
/** @end */
/**
 * @begin f-vec-equals-overload
 * @summary Positive language form retained from legacy f vec equals overload.
 * @topic Operators
 */
struct FVecEquals
	{
		int X = 0;
		int Y = 0;

		bool opEquals(const FVecEquals&in Other) const
		{
			if (X != Other.X)
			{
				return false;
			}
			return Y == Other.Y;
		}
	}
/** @end */
/**
 * @begin f-vec-mul-overload
 * @summary Positive language form retained from legacy f vec mul overload.
 * @topic Operators
 */
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
/** @end */
/**
 * @begin f-vec-neg-overload
 * @summary Positive language form retained from legacy f vec neg overload.
 * @topic Operators
 */
struct FVecNeg
	{
		int X = 0;
		int Y = 0;

		FVecNeg opNeg() const
		{
			FVecNeg Result;
			Result.X = -X;
			Result.Y = -Y;
			return Result;
		}
	}
/** @end */
/**
 * @begin f-vec-sub-overload
 * @summary Positive language form retained from legacy f vec sub overload.
 * @topic Operators
 */
struct FVecSub
	{
		int X = 0;
		int Y = 0;

		FVecSub opSub(const FVecSub&in Other) const
		{
			FVecSub Result;
			Result.X = X - Other.X;
			Result.Y = Y - Other.Y;
			return Result;
		}
	}
/** @end */
/**
 * @begin f-vec-usage-overload
 * @summary Positive language form retained from legacy f vec usage overload.
 * @topic Operators
 */
struct FVecUsage
	{
		int X = 0;
		int Y = 0;

		FVecUsage opAdd(const FVecUsage&in Other) const
		{
			FVecUsage Result;
			Result.X = X + Other.X;
			Result.Y = Y + Other.Y;
			return Result;
		}

		bool opEquals(const FVecUsage&in Other) const
		{
			if (X != Other.X)
			{
				return false;
			}
			return Y == Other.Y;
		}
	}
/** @end */
/**
 * @begin score-operator-suite
 * @summary Positive language form retained from legacy score operator suite.
 * @topic Operators
 */
struct FScoreValue
	{
		int Value = 0;

		FScoreValue opAdd(const FScoreValue&in Other) const
		{
			FScoreValue Result;
			Result.Value = Value + Other.Value;
			return Result;
		}

		FScoreValue opSub(const FScoreValue&in Other) const
		{
			FScoreValue Result;
			Result.Value = Value - Other.Value;
			return Result;
		}

		FScoreValue opMul(int Scale) const
		{
			FScoreValue Result;
			Result.Value = Value * Scale;
			return Result;
		}

		FScoreValue& opAddAssign(const FScoreValue&in Other)
		{
			Value += Other.Value;
			return this;
		}

		bool opEquals(const FScoreValue&in Other) const
		{
			return Value == Other.Value;
		}

		int opCmp(const FScoreValue&in Other) const
		{
			if (Value < Other.Value)
			{
				return -1;
			}
			if (Value > Other.Value)
			{
				return 1;
			}
			return 0;
		}
	}

	FScoreValue MakeScore(int Value)
	{
		FScoreValue Result;
		Result.Value = Value;
		return Result;
	}

	int ArithmeticOperators()
	{
		FScoreValue A = MakeScore(10);
		FScoreValue B = MakeScore(3);
		FScoreValue Sum = A + B;
		FScoreValue Difference = A - B;
		FScoreValue Product = B * 4;
		return Sum.Value * 100 + Difference.Value * 10 + Product.Value;
	}

	int CompoundAssignmentOperator()
	{
		FScoreValue A = MakeScore(5);
		FScoreValue B = MakeScore(8);
		A += B;
		return A.Value;
	}

	bool EqualityOperator()
	{
		return MakeScore(9) == MakeScore(9);
	}

	bool ComparisonOperators()
	{
		FScoreValue Low = MakeScore(1);
		FScoreValue High = MakeScore(4);

		if (!(Low < High))
		{
			return false;
		}
		if (!(High > Low))
		{
			return false;
		}
		if (!(Low <= MakeScore(1)))
		{
			return false;
		}
		return High >= MakeScore(4);
	}
/** @end */
/**
 * @begin op-index-read-write
 * @summary A value type with opIndex used on both sides of assignment.
 * @topic Operators
 */
struct FCells
{
	int First;
	int Second;

	int& opIndex(int Index)
	{
		if (Index == 0)
		{
			return First;
		}
		return Second;
	}
}

int UseIndex()
{
	FCells Cells;
	Cells[0] = 3;
	Cells[1] = 4;
	return Cells[0] + Cells[1];
}
/** @end */
/**
 * @begin unary-index-and-conversion
 * @summary Positive language form retained from legacy unary index and conversion operators.
 * @topic Operators
 */
struct FIndexedScores
{
	array<int> Values;

	int opIndex(int Index) const
	{
		return Values[Index];
	}
}

struct FUnaryScore
{
	int Value = 0;

	FUnaryScore opNeg() const
	{
		FUnaryScore Result;
		Result.Value = -Value;
		return Result;
	}

	int opImplConv() const
	{
		return Value;
	}
}
/** @end */
