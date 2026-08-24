// Theme: Language.Syntax.EdgeCases. Positive && / || skip the unused operand.
// C++: AngelscriptCoverageSpecialControlFlowTests.cpp::ShortCircuitSkipsRightHandSide
// sha256=539379a5c13ea106bef1a8311f927b577ce160ca71020a34327e043d38e21cbc; lines 61-103.
// Oracle: AndSkipsRightSide()==0; OrSkipsRightSide()==0; RightSideEvaluatesWhenNeeded()==1.
// Extra: RecordTrue on its own increments; RecordFalse increments independently.
// DefaultSafe. &inout Calls is the evaluation counter.

bool RecordTrue(int&inout Calls)
{
	Calls += 1;
	return true;
}

bool RecordFalse(int&inout Calls)
{
	Calls += 1;
	return false;
}

int AndSkipsRightSide()
{
	int Calls = 0;
	if (false && RecordTrue(Calls))
	{
		return -1;
	}
	return Calls;
}

int OrSkipsRightSide()
{
	int Calls = 0;
	if (true || RecordFalse(Calls))
	{
		return Calls;
	}
	return -1;
}

int RightSideEvaluatesWhenNeeded()
{
	int Calls = 0;
	if (true && RecordTrue(Calls))
	{
		return Calls;
	}
	return -1;
}

bool Observe_ShortCircuit_Nominal()
{
	return AndSkipsRightSide() == 0 && OrSkipsRightSide() == 0 && RightSideEvaluatesWhenNeeded() == 1;
}

int Observe_ShortCircuit_RecordTrueDirect()
{
	int Calls = 0;
	RecordTrue(Calls);
	return Calls;
}

int Observe_ShortCircuit_RecordFalseDirect()
{
	int Calls = 0;
	RecordFalse(Calls);
	return Calls;
}
