// Theme: Language.ControlFlow.Switch. Positive value oracle from SwitchBasic.
// C++: AngelscriptCoverageConditionalTests.cpp::SwitchBasic
// sha256=a6daf18169863d68e6497d49743a2f87563f0534ce5040dc310ef06b4860d14f; lines 410-478.
// Oracle: BasicSwitch(1) 10; SwitchWithBreak(2) 20; SwitchNoDefault(1) 1; MultipleCase(2) 123.
// Extra: unmatched default 0; MultipleCase 4/5 -> 45; SwitchNoDefault unmatched stays 0.
// DefaultSafe. Source owns locals.

int BasicSwitch(int Value)
{
	switch (Value)
	{
		case 1:
			return 10;
		case 2:
			return 20;
		case 3:
			return 30;
		default:
			return 0;
	}
}

int SwitchWithBreak(int Value)
{
	int Result = 0;
	switch (Value)
	{
		case 1:
			Result = 10;
			break;
		case 2:
			Result = 20;
			break;
		default:
			Result = 99;
			break;
	}
	return Result;
}

int SwitchNoDefault(int Value)
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
	}
	return Result;
}

int MultipleCase(int Value)
{
	switch (Value)
	{
		case 1:
		case 2:
		case 3:
			return 123;
		case 4:
		case 5:
			return 45;
		default:
			return 0;
	}
}

bool Observe_SwitchBasic_Nominal()
{
	return BasicSwitch(1) == 10
		&& SwitchWithBreak(2) == 20
		&& SwitchNoDefault(1) == 1
		&& MultipleCase(2) == 123;
}

bool Observe_SwitchBasic_DefaultEmpty()
{
	return BasicSwitch(99) == 0
		&& SwitchNoDefault(0) == 0
		&& MultipleCase(0) == 0;
}

bool Observe_SwitchBasic_RemainingCases()
{
	return BasicSwitch(2) == 20
		&& BasicSwitch(3) == 30
		&& SwitchWithBreak(1) == 10
		&& SwitchWithBreak(8) == 99
		&& SwitchNoDefault(2) == 2
		&& MultipleCase(1) == 123
		&& MultipleCase(4) == 45
		&& MultipleCase(5) == 45;
}
