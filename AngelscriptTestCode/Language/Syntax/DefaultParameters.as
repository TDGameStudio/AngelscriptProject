/**
 * @version v1
 * @summary Defaulted function parameters for bool, int, and float.
 * @topic Language
 * @topic Syntax
 */
/**
 * @version root
 * @summary Trailing defaults on mixed primitive parameters.
 * @topic Baseline
 */
int WithDefaults(int Count = 1, bool Flag = true, float Scale = 1.0f)
{
	int Added = Flag ? Count : 0;
	return Added + int(Scale);
}

int CallAllDefaults()
{
	return WithDefaults();
}

int CallPartialDefaults()
{
	return WithDefaults(3);
}
/** @end */
/**
 * @version invalid-default-before-required
 * @parent root
 * @summary A required parameter cannot follow a defaulted one.
 * @topic Negative
 */
int Bad(int Count = 1, int Extra)
{
	return Count + Extra;
}
/** @end */
/**
 * @version invalid-default-type-mismatch
 * @parent root
 * @summary A default expression must match the parameter type.
 * @topic Negative
 */
int Bad(int Count = true)
{
	return Count;
}
/** @end */
/**
 * @version valid-bool-default-parameters
 * @parent root
 * @summary Positive language form retained from legacy bool default parameters.
 * @topic Syntax
 */
bool EchoDefaultTrue(bool b = true)
	{
		return b;
	}

	bool EchoDefaultFalse(bool b = false)
	{
		return b;
	}

	bool CallDefaultTrue()
	{
		return EchoDefaultTrue();
	}

	bool CallDefaultFalse()
	{
		return EchoDefaultFalse();
	}
/** @end */
/**
 * @version valid-default-parameter-function
 * @parent root
 * @summary Positive language form retained from legacy default parameter function.
 * @topic Syntax
 */
int Foo(int X = 5, float Y = 1.0f)
	{
		return X;
	}
/** @end */
/**
 * @version valid-float-default-parameters
 * @parent root
 * @summary Positive language form retained from legacy float default parameters.
 * @topic Syntax
 */
float AddFloatDefault(float X, float Y = 1.5f)
	{
		return X + Y;
	}

	double AddDoubleDefault(double X, double Y = 2.5)
	{
		return X + Y;
	}

	float AddFloatDefaultImplicit(float X)
	{
		return AddFloatDefault(X);
	}

	double AddDoubleDefaultImplicit(double X)
	{
		return AddDoubleDefault(X);
	}
/** @end */
/**
 * @version valid-function-default-parameter-edges
 * @parent root
 * @summary Positive language form retained from legacy function default parameter edges.
 * @topic Syntax
 */
int MultipleDefaults(int A, int B = 10, int C = 20)
	{
		return A + B + C;
	}

	int MultipleDefaultsUsingBoth(int A)
	{
		return MultipleDefaults(A);
	}

	int MultipleDefaultsUsingFinal(int A, int B)
	{
		return MultipleDefaults(A, B);
	}

	int NegativeDefault(int Value = -7)
	{
		return Value;
	}

	int NegativeDefaultUsingDefault()
	{
		return NegativeDefault();
	}

	int BoundaryDefault(int Value = 2147483647)
	{
		return Value;
	}

	int BoundaryDefaultUsingDefault()
	{
		return BoundaryDefault();
	}
/** @end */
/**
 * @version valid-int-family-default-parameters
 * @parent root
 * @summary Positive language form retained from legacy int family default parameters.
 * @topic Syntax
 */
int AddWithDefault(int a, int b = 10)
	{
		return a + b;
	}

	int AddUsingDefault(int a)
	{
		return AddWithDefault(a);
	}

	int64 MultiplyWithDefault(int64 x, int64 y = 2)
	{
		return x * y;
	}

	int64 MultiplyUsingDefault(int64 x)
	{
		return MultiplyWithDefault(x);
	}

	uint ChainDefaults(uint a = 5, uint b = 10, uint c = 15)
	{
		return a + b + c;
	}

	uint ChainUsingDefaults()
	{
		return ChainDefaults();
	}
/** @end */
/**
 * @version invalid-default-outside-class-scope
 * @parent root
 * @summary Compile-rejection form retained from legacy default outside class scope.
 * @topic Negative
 */
int GlobalValue = 5;
default GlobalValue = 10;
/** @end */
/**
 * @version invalid-non-default-parameter-after-default
 * @parent root
 * @summary Compile-rejection form retained from legacy non default parameter after default.
 * @topic Negative
 */
void Foo(int X = 5, int Y)
{
}
/** @end */
/**
 * @version valid-string-default-parameter
 * @parent root
 * @summary A trailing string parameter with a default literal.
 * @topic Syntax
 */
string Label(string Text = "none")
{
	return Text;
}
/** @end */
