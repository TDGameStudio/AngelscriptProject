/**
 * @version v1
 * @summary Compile-fail cases for Switch.
 * @topic Language
 * @topic ControlFlow
 *
 * invalid-switch-on-float               // A float cannot be the switch selector.
 * invalid-duplicate-case                // Duplicate case labels are invalid.
 * invalid-case-outside-switch           // Compile-rejection form retained from legacy case outside switch.
 * invalid-switch-duplicate-case         // Compile-rejection form retained from legacy switch duplicate case.
 * invalid-switch-duplicate-default      // Compile-rejection form retained from legacy switch duplicate default.
 * invalid-switch-float-case-label       // Compile-rejection form retained from legacy switch float case label.
 * invalid-switch-over-bool              // Compile-rejection form retained from legacy switch over bool.
 * invalid-switch-string-case-label      // Compile-rejection form retained from legacy switch string case label.
 * invalid-switch-variable-case-label    // Compile-rejection form retained from legacy switch variable case label.
 * invalid-switch-without-braces         // Compile-rejection form retained from legacy switch without braces.
 * invalid-fallthrough-outside-switch    // fallthrough is only valid inside a switch clause.
 */
/**
 * @begin invalid-switch-on-float
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
 * @begin invalid-duplicate-case
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
 * @begin invalid-case-outside-switch
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
 * @begin invalid-switch-duplicate-case
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
 * @begin invalid-switch-duplicate-default
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
 * @begin invalid-switch-float-case-label
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
 * @begin invalid-switch-over-bool
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
 * @begin invalid-switch-string-case-label
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
 * @begin invalid-switch-variable-case-label
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
 * @begin invalid-switch-without-braces
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
 * @begin invalid-fallthrough-outside-switch
 * @summary fallthrough is only valid inside a switch clause.
 * @topic Negative
 */
void Test()
{
	fallthrough;
}
/** @end */
