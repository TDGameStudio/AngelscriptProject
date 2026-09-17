/**
 * @version v1
 * @summary Function overload sets resolved by arity and numeric type.
 * @topic Language
 * @topic Syntax
 */
/**
 * @version root
 * @summary Overloads distinguished by arity and by int versus float.
 * @topic Baseline
 */
int Combine(int Value)
{
	return Value;
}

int Combine(int Left, int Right)
{
	return Left + Right;
}

int Combine(float Value)
{
	return int(Value);
}

int PickArity()
{
	return Combine(1) + Combine(2, 3);
}

int PickNumeric()
{
	return Combine(1.5f);
}
/** @end */
/**
 * @version invalid-duplicate-signature
 * @parent root
 * @summary Two functions cannot share the same signature.
 * @topic Negative
 */
int Combine(int Value)
{
	return Value;
}

int Combine(int Value)
{
	return Value + 1;
}
/** @end */
/**
 * @version valid-bool-int-overload-resolution
 * @parent root
 * @summary Positive language form retained from legacy bool int overload resolution.
 * @topic Syntax
 */
int Pick(bool b)
	{
		return b ? 10 : 20;
	}

	int Pick(int Value)
	{
		return Value + 100;
	}

	int CallBoolOverload()
	{
		return Pick(true);
	}

	int CallIntOverload()
	{
		return Pick(5);
	}
/** @end */
/**
 * @version valid-float-double-overload-resolution
 * @parent root
 * @summary Positive language form retained from legacy float double overload resolution.
 * @topic Syntax
 */
int ProcessFloat(float X, bool bUseFloatPath)
	{
		return bUseFloatPath ? int(X * 10.0f) + 1 : -1;
	}

	int ProcessDouble(double X, int Bias)
	{
		return int(X * 10.0) + Bias;
	}

	float ReturnFloatByPrecision(float X, bool bUseFloatPath)
	{
		return bUseFloatPath ? X + 1.0f : -1.0f;
	}

	double ReturnDoubleByPrecision(double X, int Bias)
	{
		return X + double(Bias);
	}
/** @end */
/**
 * @version valid-function-overload-arity-and-numeric-resolution
 * @parent root
 * @summary Positive language form retained from legacy function overload arity and numeric resolution.
 * @topic Syntax
 */
int Choose(int A)
	{
		return A + 1;
	}

	int Choose(int A, int B)
	{
		return A + B + 2;
	}

	int Choose(int A, int B, int C)
	{
		return A + B + C + 3;
	}

	int Numeric(int Value)
	{
		return Value + 10;
	}

	int Numeric(double Value)
	{
		return int(Value) + 20;
	}

	int CallChooseOne()
	{
		return Choose(41);
	}

	int CallChooseTwo()
	{
		return Choose(10, 30);
	}

	int CallChooseThree()
	{
		return Choose(10, 20, 9);
	}

	int CallNumericInt()
	{
		return Numeric(32);
	}

	int CallNumericDouble()
	{
		return Numeric(22.5);
	}
/** @end */
/**
 * @version valid-int-width-overload-resolution
 * @parent root
 * @summary Positive language form retained from legacy int width overload resolution.
 * @topic Syntax
 */
int Process(int x)
	{
		return x + 100;
	}

	int64 Process(int64 x)
	{
		return x + 1000000;
	}

	uint Process(uint x)
	{
		return x + 200;
	}

	int CallProcessInt()
	{
		return Process(42);
	}

	int64 CallProcessInt64()
	{
		return Process(int64(9000000000));
	}

	uint CallProcessUInt()
	{
		return Process(uint(3000000000));
	}
/** @end */
/**
 * @version valid-void-overload-set
 * @parent root
 * @summary Positive language form retained from legacy void overload set.
 * @topic Syntax
 */
void Foo(int X)
	{
	}

	void Foo(float X)
	{
	}

	void Foo(int X, int Y)
	{
	}
/** @end */
/**
 * @version invalid-duplicate-function-signature
 * @parent root
 * @summary Compile-rejection form retained from legacy duplicate function signature.
 * @topic Negative
 */
void Foo(int X)
{
}

void Foo(int X)
{
}
/** @end */
/**
 * @version valid-string-function-overloading
 * @parent root
 * @summary Overloads distinguished by string versus int.
 * @topic Syntax
 */
int Describe(string Text)
{
	return Text.length();
}

int Describe(int Value)
{
	return Value;
}
/** @end */
