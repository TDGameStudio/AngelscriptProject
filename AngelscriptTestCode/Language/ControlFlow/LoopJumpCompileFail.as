/**
 * @version v1
 * @summary Compile-fail cases for LoopJump.
 * @topic Language
 * @topic ControlFlow
 *
 * invalid-break-outside-loop
 * invalid-continue-outside-loop
 * invalid-break-in-function-called-from-loop
 * invalid-break-inside-if-without-loop
 * invalid-continue-inside-if-without-loop
 */
/**
 * @begin invalid-break-outside-loop
 * @summary Break is invalid outside a loop or switch.
 * @topic Negative
 */
void Test()
{
	break;
}
/** @end */
/**
 * @begin invalid-continue-outside-loop
 * @summary Continue is invalid outside a loop.
 * @topic Negative
 */
void Test()
{
	continue;
}
/** @end */
/**
 * @begin invalid-break-in-function-called-from-loop
 * @summary Compile-rejection form retained from legacy break in function called from loop.
 * @topic Negative
 */
void Foo()
{
	break;
}

void Test()
{
	for (int I = 0; I < 5; ++I)
	{
		Foo();
	}
}
/** @end */
/**
 * @begin invalid-break-inside-if-without-loop
 * @summary Compile-rejection form retained from legacy break inside if without loop.
 * @topic Negative
 */
void Test()
{
	if (true)
	{
		break;
	}
}
/** @end */
/**
 * @begin invalid-continue-inside-if-without-loop
 * @summary Compile-rejection form retained from legacy continue inside if without loop.
 * @topic Negative
 */
void Test()
{
	if (true)
	{
		continue;
	}
}
/** @end */
