/**
 * @version v1
 * @summary Auto infers a local type from a literal or other non-call initializer.
 * @topic Language
 * @topic Auto
 *
 * infer-from-bool               // auto Flag = true infers bool and returns that value.
 * infer-from-false              // auto Flag = false infers bool and returns that value.
 * infer-from-int                // auto Value = 3 infers int from a decimal literal.
 * infer-from-int-hex            // A hex literal infers unsigned; auto Value = 0x2A is uint.
 * infer-from-uint               // A based binary literal infers unsigned without a u suffix.
 * infer-from-float              // auto Value = 1.5f infers float and returns that value.
 * infer-from-double             // A fractional literal without f infers double.
 * infer-from-string             // auto Text = "hello" infers the string literal type.
 * infer-from-name               // auto Name = n"Ready" infers the name literal type.
 * infer-from-enum               // auto Color = EColor::Green infers the enum type.
 * infer-from-handle             // auto Copy = Object infers the handle type of the initializer.
 * infer-multiple-declarators    // One auto declaration can introduce two initialized locals.
 * reassign-same-type-bool       // An auto bool local can be reassigned another bool.
 * reassign-same-type-int        // An auto int local can be reassigned another int.
 * reassign-same-type-float      // An auto float local can be reassigned another float.
 * auto-int-in-expression        // An inferred int participates in arithmetic.
 * auto-as-argument              // An inferred local can be passed as a function argument.
 * auto-as-return                // An inferred local can be returned from the function that owns it.
 */
/**
 * @begin infer-from-bool
 * @summary auto Flag = true infers bool and returns that value.
 * @topic Auto
 */
bool InferredTrue()
{
	auto Flag = true;
	return Flag;
}
/** @end */
/**
 * @begin infer-from-false
 * @summary auto Flag = false infers bool and returns that value.
 * @topic Auto
 */
bool InferredFalse()
{
	auto Flag = false;
	return Flag;
}
/** @end */
/**
 * @begin infer-from-int
 * @summary auto Value = 3 infers int from a decimal literal.
 * @topic Auto
 */
int InferredInt()
{
	auto Value = 3;
	return Value;
}
/** @end */
/**
 * @begin infer-from-int-hex
 * @summary A hex literal infers unsigned; auto Value = 0x2A is uint.
 * @topic Auto
 */
uint InferredHex()
{
	auto Value = 0x2A;
	return Value;
}
/** @end */
/**
 * @begin infer-from-uint
 * @summary A based binary literal infers unsigned without a u suffix.
 * @topic Auto
 */
uint InferredUint()
{
	auto Value = 0b1111;
	return Value;
}
/** @end */
/**
 * @begin infer-from-float
 * @summary auto Value = 1.5f infers float and returns that value.
 * @topic Auto
 */
float InferredFloat()
{
	auto Value = 1.5f;
	return Value;
}
/** @end */
/**
 * @begin infer-from-double
 * @summary A fractional literal without f infers double.
 * @topic Auto
 */
double InferredDouble()
{
	auto Value = 1.5;
	return Value;
}
/** @end */
/**
 * @begin infer-from-string
 * @summary auto Text = "hello" infers the string literal type.
 * @topic Auto
 */
string InferredString()
{
	auto Text = "hello";
	return Text;
}
/** @end */
/**
 * @begin infer-from-name
 * @summary auto Name = n"Ready" infers the name literal type.
 * @topic Auto
 */
FName InferredName()
{
	auto Name = n"Ready";
	return Name;
}
/** @end */
/**
 * @begin infer-from-enum
 * @summary auto Color = EColor::Green infers the enum type.
 * @topic Auto
 */
enum EColor
{
	Red,
	Green,
	Blue
}

int InferredEnum()
{
	auto Color = EColor::Green;
	if (Color == EColor::Green)
	{
		return 1;
	}
	return 0;
}
/** @end */
/**
 * @begin infer-from-handle
 * @summary auto Copy = Object infers the handle type of the initializer.
 * @topic Auto
 */
class AHost
{
	int Score;
}

int InferredHandle(AHost@ Object)
{
	auto Copy = Object;
	return Copy.Score;
}
/** @end */
/**
 * @begin infer-multiple-declarators
 * @summary One auto declaration can introduce two initialized locals.
 * @topic Auto
 */
int MultipleDeclarators()
{
	auto Left = 3, Right = 4;
	return Left + Right;
}
/** @end */
/**
 * @begin reassign-same-type-bool
 * @summary An auto bool local can be reassigned another bool.
 * @topic Auto
 */
bool ReassignedBool()
{
	auto Flag = true;
	Flag = false;
	return Flag;
}
/** @end */
/**
 * @begin reassign-same-type-int
 * @summary An auto int local can be reassigned another int.
 * @topic Auto
 */
int ReassignedInt()
{
	auto Value = 3;
	Value = 4;
	return Value;
}
/** @end */
/**
 * @begin reassign-same-type-float
 * @summary An auto float local can be reassigned another float.
 * @topic Auto
 */
float ReassignedFloat()
{
	auto Value = 1.5f;
	Value = 2.5f;
	return Value;
}
/** @end */
/**
 * @begin auto-int-in-expression
 * @summary An inferred int participates in arithmetic.
 * @topic Auto
 */
int Added()
{
	auto Value = 3;
	return Value + 1;
}
/** @end */
/**
 * @begin auto-as-argument
 * @summary An inferred local can be passed as a function argument.
 * @topic Auto
 */
int Add(int Left, int Right)
{
	return Left + Right;
}

int AsArgument()
{
	auto Value = 3;
	return Add(Value, 1);
}
/** @end */
/**
 * @begin auto-as-return
 * @summary An inferred local can be returned from the function that owns it.
 * @topic Auto
 */
int AsReturn()
{
	auto Value = 3;
	return Value;
}
/** @end */
