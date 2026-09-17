/**
 * @version v1
 * @summary Value, reference, in, and inout parameter combinations.
 * @topic Language
 * @topic Syntax
 */
/**
 * @version root
 * @summary By-value, const-in, out, and inout integer parameters.
 * @topic Baseline
 */
int ValueParam(int Amount)
{
	return Amount + 1;
}

int ConstInParam(const int& In Amount)
{
	return Amount;
}

void OutParam(int& Out Amount)
{
	Amount = 4;
}

void InOutParam(int& InOut Amount)
{
	Amount += 1;
}

int UseDirections()
{
	int Value = ValueParam(1);
	int Read = ConstInParam(Value);
	int Written = 0;
	OutParam(Written);
	InOutParam(Written);
	return Read + Written;
}
/** @end */
/**
 * @version invalid-void-parameter
 * @parent root
 * @summary Void is not a legal parameter type.
 * @topic Negative
 */
void Bad(void Amount)
{
}
/** @end */
/**
 * @version valid-bool-in-out-parameter
 * @parent root
 * @summary Positive language form retained from legacy bool in out parameter.
 * @topic Syntax
 */
void Toggle(bool&inout b)
	{
		b = !b;
	}
/** @end */
/**
 * @version valid-bool-out-parameter
 * @parent root
 * @summary Positive language form retained from legacy bool out parameter.
 * @topic Syntax
 */
void SetTrue(bool&out b)
	{
		b = true;
	}
/** @end */
/**
 * @version valid-bool-reference-in-parameter
 * @parent root
 * @summary Positive language form retained from legacy bool reference in parameter.
 * @topic Syntax
 */
bool PassThrough(const bool&in b)
	{
		return b;
	}
/** @end */
/**
 * @version valid-bool-value-parameters
 * @parent root
 * @summary Positive language form retained from legacy bool value parameters.
 * @topic Syntax
 */
bool Negate(bool b)
	{
		return !b;
	}
/** @end */
/**
 * @version valid-float-in-out-parameters
 * @parent root
 * @summary Positive language form retained from legacy float in out parameters.
 * @topic Syntax
 */
void SquareFloat(float&inout X)
	{
		X = X * X;
	}

	void SquareDouble(double&inout X)
	{
		X = X * X;
	}
/** @end */
/**
 * @version valid-float-out-parameters
 * @parent root
 * @summary Positive language form retained from legacy float out parameters.
 * @topic Syntax
 */
void WriteFloat(float&out X)
	{
		X = 3.14159f;
	}

	void WriteDouble(double&out X)
	{
		X = 2.71828;
	}

	void WriteFloatPair(float Seed, float&out A, float&out B)
	{
		A = Seed + 1.0f;
		B = Seed + 2.0f;
	}

	void WriteDoublePair(double Seed, double&out A, double&out B)
	{
		A = Seed + 1.0;
		B = Seed + 2.0;
	}
/** @end */
/**
 * @version valid-float-reference-in-parameters
 * @parent root
 * @summary Positive language form retained from legacy float reference in parameters.
 * @topic Syntax
 */
float AcceptFloatIn(const float&in X)
	{
		return X * 2.0f;
	}

	double AcceptDoubleIn(const double&in X)
	{
		return X * 3.0;
	}
/** @end */
/**
 * @version valid-float-value-parameters
 * @parent root
 * @summary Positive language form retained from legacy float value parameters.
 * @topic Syntax
 */
float AcceptFloat(float X)
	{
		return X + 1.5f;
	}

	double AcceptDouble(double X)
	{
		return X + 2.5;
	}
/** @end */
/**
 * @version valid-function-parameters-multiple-out
 * @parent root
 * @summary Positive language form retained from legacy function parameters multiple out.
 * @topic Syntax
 */
void SetPair(bool&out First, bool&out Second)
	{
		First = true;
		Second = false;
	}
/** @end */
/**
 * @version valid-int-family-in-out-parameters
 * @parent root
 * @summary Positive language form retained from legacy int family in out parameters.
 * @topic Syntax
 */
void DoubleInt8(int8&inout x)
	{
		x *= 2;
	}

	void DoubleInt16(int16&inout x)
	{
		x *= 2;
	}

	void DoubleInt(int&inout x)
	{
		x *= 2;
	}

	void IncrementInt64(int64&inout x)
	{
		x += 1000;
	}

	void DoubleUInt8(uint8&inout x)
	{
		x *= 2;
	}

	void DoubleUInt16(uint16&inout x)
	{
		x *= 2;
	}

	void DecrementUInt(uint&inout x)
	{
		x -= 50;
	}

	void IncrementUInt64(uint64&inout x)
	{
		x += 1000;
	}
/** @end */
/**
 * @version valid-int-family-out-parameters
 * @parent root
 * @summary Positive language form retained from legacy int family out parameters.
 * @topic Syntax
 */
void WriteInt8(int8&out x)
	{
		x = 127;
	}

	void WriteInt16(int16&out x)
	{
		x = 30000;
	}

	void WriteInt(int&out x)
	{
		x = 42;
	}

	void WriteInt64(int64&out x)
	{
		x = 10000000000;
	}

	void WriteUInt8(uint8&out x)
	{
		x = 255;
	}

	void WriteUInt16(uint16&out x)
	{
		x = 60000;
	}

	void WriteUInt(uint&out x)
	{
		x = 3000000000;
	}

	void WriteUInt64(uint64&out x)
	{
		x = 18000000000000000000;
	}

	void MultipleOut(int&out a, int&out b)
	{
		a = 10;
		b = 20;
	}
/** @end */
/**
 * @version valid-int-family-reference-in-parameters
 * @parent root
 * @summary Positive language form retained from legacy int family reference in parameters.
 * @topic Syntax
 */
int8 AcceptInt8In(int8&in x)
	{
		return x + 10;
	}

	int16 AcceptInt16In(int16&in x)
	{
		return x + 100;
	}

	int AcceptIntIn(int&in x)
	{
		return x * 3;
	}

	int64 AcceptInt64In(int64&in x)
	{
		return x + 1;
	}

	uint8 AcceptUInt8In(uint8&in x)
	{
		return x + 5;
	}

	uint16 AcceptUInt16In(uint16&in x)
	{
		return x + 50;
	}

	uint AcceptUIntIn(uint&in x)
	{
		return x - 100;
	}

	uint64 AcceptUInt64In(uint64&in x)
	{
		return x + 1000;
	}
/** @end */
/**
 * @version valid-int-family-value-parameters
 * @parent root
 * @summary Positive language form retained from legacy int family value parameters.
 * @topic Syntax
 */
int8 AcceptInt8(int8 x)
	{
		return x + 1;
	}

	int16 AcceptInt16(int16 x)
	{
		return x + 100;
	}

	int AcceptInt(int x)
	{
		return x * 2;
	}

	int64 AcceptInt64(int64 x)
	{
		return x + 1000000;
	}

	uint8 AcceptUInt8(uint8 x)
	{
		return x + 1;
	}

	uint16 AcceptUInt16(uint16 x)
	{
		return x + 1000;
	}

	uint AcceptUInt(uint x)
	{
		return x + 100;
	}

	uint64 AcceptUInt64(uint64 x)
	{
		return x + 1000000000000;
	}
/** @end */
/**
 * @version valid-reference-write-parameter
 * @parent root
 * @summary Positive language form retained from legacy reference write parameter.
 * @topic Syntax
 */
void Foo(int&out Out)
	{
		Out = 42;
	}
/** @end */
/**
 * @version invalid-function-unknown-parameter-type
 * @parent root
 * @summary Compile-rejection form retained from legacy function unknown parameter type.
 * @topic Negative
 */
void Foo(NonExistentType X)
{
}
/** @end */
/**
 * @version invalid-void-parameter-type
 * @parent root
 * @summary Compile-rejection form retained from legacy void parameter type.
 * @topic Negative
 */
void Foo(void X)
{
}
/** @end */
/**
 * @version valid-script-quat-value-parameters
 * @parent root
 * @summary Authored language form for script quat value parameters.
 * @topic Syntax
 */
struct FScriptQuat
{
	float X;
	float Y;
	float Z;
	float W;
}

FScriptQuat ScaleQuat(FScriptQuat Value)
{
	Value.X *= 2.0f;
	Value.Y *= 2.0f;
	Value.Z *= 2.0f;
	Value.W *= 2.0f;
	return Value;
}
/** @end */
/**
 * @version valid-script-quat-out-parameters
 * @parent root
 * @summary Authored language form for script quat out parameters.
 * @topic Syntax
 */
struct FScriptQuat
{
	float X;
	float Y;
	float Z;
	float W;
}

void Identity(FScriptQuat& Out Value)
{
	Value.X = 0.0f;
	Value.Y = 0.0f;
	Value.Z = 0.0f;
	Value.W = 1.0f;
}
/** @end */
/**
 * @version valid-string-value-parameters
 * @parent root
 * @summary A string received by value.
 * @topic Syntax
 */
string Prefix(string Text)
{
	return "[" + Text + "]";
}
/** @end */
/**
 * @version valid-string-in-parameter
 * @parent root
 * @summary A const-in string parameter.
 * @topic Syntax
 */
int LengthOf(const string& In Text)
{
	return Text.length();
}
/** @end */
/**
 * @version valid-string-out-parameter
 * @parent root
 * @summary A string written through an out parameter.
 * @topic Syntax
 */
void WriteHello(string& Out Text)
{
	Text = "Hello";
}
/** @end */
/**
 * @version valid-string-inout-parameter
 * @parent root
 * @summary A string updated through an inout parameter.
 * @topic Syntax
 */
void AppendMark(string& InOut Text)
{
	Text += "!";
}
/** @end */
