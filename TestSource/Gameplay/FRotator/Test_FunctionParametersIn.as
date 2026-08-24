// Theme: Gameplay.FRotator. Positive &in parameter oracle.
// C++: AngelscriptCoverageFRotatorFunctionTests.cpp::FunctionParametersIn
// Oracle: AcceptRotatorIn(0,90,0) Equals native Vector().
// Extra: default Zero Vector is Forward. DefaultSafe.

FVector AcceptRotatorIn(FRotator&in r)
{
	return r.Vector();
}

bool Observe_AcceptRotatorIn_Nominal()
{
	FRotator Input = FRotator(0, 90, 0);
	return AcceptRotatorIn(Input).Equals(FRotator(0, 90, 0).Vector(), 0.001);
}

bool Observe_AcceptRotatorIn_DefaultEmpty()
{
	FRotator Empty = FRotator();
	return AcceptRotatorIn(Empty).Equals(FVector::ForwardVector, 0.001);
}

bool Observe_AcceptRotatorIn_CopyIndependence()
{
	FRotator Input = FRotator(0, 90, 0);
	FVector Result = AcceptRotatorIn(Input);
	Result.X = 0.0;
	return Input == FRotator(0, 90, 0);
}
