/**
 * @version v1
 * @summary Integer and enum switch forms with break.
 * @topic Language
 * @topic ControlFlow
 *
 * switch                           // A defaulted integer switch, an explicit-break switch, and an enum switch.
 * switch-enum                      // Positive language form retained from legacy switch enum.
 * switch-basic                     // Authored language form for switch basic.
 * switch-break                     // Authored language form for switch break.
 * switch-integer-types             // Authored language form for switch integer types.
 * switch-fallthrough-to-default    // A case without break falls into default.
 * switch-default-only              // A switch with only default still selects that clause.
 * switch-no-default                // A switch with only cases leaves unmatched values to the following return.
 * switch-empty-case-fallthrough    // An empty case falls into the next case body.
 * switch-explicit-fallthrough      // Explicit fallthrough continues from one case into the next.
 */
/**
 * @begin switch
 * @summary A defaulted integer switch, an explicit-break switch, and an enum switch.
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
 * @begin switch-enum
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
 * @begin switch-basic
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
 * @begin switch-break
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
 * @begin switch-integer-types
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
 * @begin switch-fallthrough-to-default
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
/**
 * @begin switch-default-only
 * @summary A switch with only default still selects that clause.
 * @topic ControlFlow
 */
int SwitchDefaultOnly(int Value)
{
	switch (Value)
	{
		default:
			return 1;
	}
}
/** @end */
/**
 * @begin switch-no-default
 * @summary A switch with only cases leaves unmatched values to the following return.
 * @topic ControlFlow
 */
int SwitchNoDefault(int Value)
{
	switch (Value)
	{
		case 1:
			return 10;
		case 2:
			return 20;
	}
	return 0;
}
/** @end */
/**
 * @begin switch-empty-case-fallthrough
 * @summary An empty case falls into the next case body.
 * @topic ControlFlow
 */
int SwitchEmptyCaseFallthrough(int Value)
{
	int Result = 0;
	switch (Value)
	{
		case 1:
		case 2:
			Result = 1;
			break;
		default:
			Result = 0;
			break;
	}
	return Result;
}
/** @end */
/**
 * @begin switch-explicit-fallthrough
 * @summary Explicit fallthrough continues from one case into the next.
 * @topic ControlFlow
 */
int SwitchExplicitFallthrough(int Value)
{
	int Result = 0;
	switch (Value)
	{
		case 1:
			Result = 1;
			fallthrough;
		case 2:
			Result += 2;
			break;
		default:
			Result = 4;
			break;
	}
	return Result;
}
/** @end */
