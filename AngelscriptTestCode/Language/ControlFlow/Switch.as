/**
 * @version v1
 * @summary Integer and enum switch forms with break.
 * @topic Language
 * @topic ControlFlow
 */
/**
 * @version root
 * @summary A defaulted integer switch, an explicit-break switch, and an enum switch.
 * @topic Baseline
 */
enum EKind
{
	Alpha,
	Beta,
	Gamma
}

int SwitchBasic(int Value)
{
	switch (Value)
	{
		case 0:
			return 10;
		case 1:
			return 20;
		default:
			return 0;
	}
}

int SwitchBreak(int Value)
{
	int Result = 0;
	switch (Value)
	{
		case 1:
			Result = 1;
			break;
		case 2:
			Result = 2;
			break;
		default:
			Result = 3;
			break;
	}
	return Result;
}

int SwitchEnum(EKind Kind)
{
	switch (Kind)
	{
		case EKind::Alpha:
			return 1;
		case EKind::Beta:
			return 2;
		case EKind::Gamma:
			return 3;
	}
	return 0;
}
/** @end */
/**
 * @version invalid-switch-on-float
 * @parent root
 * @summary A float cannot be the switch selector.
 * @topic Negative
 */
void Test()
{
	float Value = 1.0f;
	switch (Value)
	{
		case 1.0f:
			return;
	}
}
/** @end */
/**
 * @version invalid-duplicate-case
 * @parent root
 * @summary Duplicate case labels are invalid.
 * @topic Negative
 */
void Test(int Value)
{
	switch (Value)
	{
		case 1:
			return;
		case 1:
			return;
	}
}
/** @end */
/**
 * @version valid-switch-enum
 * @parent root
 * @summary Positive language form retained from legacy switch enum.
 * @topic ControlFlow
 */
enum ECoverageSwitchState
{
	Idle = 0,
	Running = 1,
	Done = 2
}
/** @end */
/**
 * @version invalid-case-outside-switch
 * @parent root
 * @summary Compile-rejection form retained from legacy case outside switch.
 * @topic Negative
 */
void Test()
{
	case 1:
		int X = 0;
}
/** @end */
/**
 * @version invalid-switch-duplicate-case
 * @parent root
 * @summary Compile-rejection form retained from legacy switch duplicate case.
 * @topic Negative
 */
void Test()
{
	int X = 1;
	switch (X)
	{
		case 1:
			break;
		case 1:
			break;
	}
}
/** @end */
/**
 * @version invalid-switch-duplicate-default
 * @parent root
 * @summary Compile-rejection form retained from legacy switch duplicate default.
 * @topic Negative
 */
void Test()
{
	int X = 1;
	switch (X)
	{
		default:
			break;
		default:
			break;
	}
}
/** @end */
/**
 * @version invalid-switch-float-case-label
 * @parent root
 * @summary Compile-rejection form retained from legacy switch float case label.
 * @topic Negative
 */
void Test()
{
	int X = 1;
	switch (X)
	{
		case 1.5f:
			break;
	}
}
/** @end */
/**
 * @version invalid-switch-over-bool
 * @parent root
 * @summary Compile-rejection form retained from legacy switch over bool.
 * @topic Negative
 */
int SwitchBool(bool Value)
{
	switch (Value)
	{
		case true:
			return 1;
		case false:
			return 0;
	}
	return -1;
}
/** @end */
/**
 * @version invalid-switch-string-case-label
 * @parent root
 * @summary Compile-rejection form retained from legacy switch string case label.
 * @topic Negative
 */
void Test()
{
	int X = 1;
	switch (X)
	{
		case "hello":
			break;
	}
}
/** @end */
/**
 * @version invalid-switch-variable-case-label
 * @parent root
 * @summary Compile-rejection form retained from legacy switch variable case label.
 * @topic Negative
 */
void Test()
{
	int X = 1;
	int Y = 2;
	switch (X)
	{
		case Y:
			break;
	}
}
/** @end */
/**
 * @version invalid-switch-without-braces
 * @parent root
 * @summary Compile-rejection form retained from legacy switch without braces.
 * @topic Negative
 */
void Test()
{
	int X = 1;
	switch (X) case 0: break;
}
/** @end */
/**
 * @version valid-switch-basic
 * @parent root
 * @summary Authored language form for switch basic.
 * @topic ControlFlow
 */
int SwitchBasic(int Value)
{
	switch (Value)
	{
		case 1:
			return 10;
		case 2:
			return 20;
		default:
			return 0;
	}
}
/** @end */
/**
 * @version valid-switch-break
 * @parent root
 * @summary Authored language form for switch break.
 * @topic ControlFlow
 */
int SwitchBreak(int Value)
{
	int Result = 0;
	switch (Value)
	{
		case 1:
			Result = 1;
			break;
		case 2:
			Result = 2;
			break;
		default:
			Result = 3;
			break;
	}
	return Result;
}
/** @end */
/**
 * @version valid-switch-integer-types
 * @parent root
 * @summary Authored language form for switch integer types.
 * @topic ControlFlow
 */
int SwitchInt8(int8 Value)
{
	switch (Value)
	{
		case 1:
			return 1;
		default:
			return 0;
	}
}

int SwitchInt64(int64 Value)
{
	switch (Value)
	{
		case 10:
			return 10;
		default:
			return 0;
	}
}
/** @end */
/**
 * @version valid-switch-fallthrough-to-default
 * @parent root
 * @summary A case without break falls into default.
 * @topic ControlFlow
 */
int Fall(int Value)
{
	int Result = 0;
	switch (Value)
	{
		case 1:
			Result = 1;
		default:
			Result += 10;
			break;
	}
	return Result;
}
/** @end */
