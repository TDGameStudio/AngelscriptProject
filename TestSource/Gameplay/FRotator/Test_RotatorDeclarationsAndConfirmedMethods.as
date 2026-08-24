// Theme: Gameplay.FRotator. Positive declaration and confirmed-method oracles.
// C++: AngelscriptCoverageFRotatorExpressionTests.cpp::RotatorDeclarationsAndConfirmedMethods
// Oracle: LocalDefault 0; scalar ctor 21; copy ctor 6; local const 60; global const 0;
// NormalizeMutates (0,90,0); Inverse Equals native GetInverse; AxisHelpers 360;
// WindingAndRemainder true; Manhattan 45; RightVector; UpVector; Delta/Relative true.
// PlainClassMemberValueRaisesBoundary remains the Null pointer access exception path.
// Extra: default GlobalConst 0; Manhattan of Zero is 0. DefaultSafe.

const FRotator GlobalConstRotator = FRotator::ZeroRotator;

float LocalDefaultIsZero()
{
	FRotator r;
	return r.Pitch + r.Yaw + r.Roll;
}

float LocalScalarConstructorSum()
{
	FRotator r = FRotator(7);
	return r.Pitch + r.Yaw + r.Roll;
}

float LocalCopyConstructorSum()
{
	FRotator Source = FRotator(1, 2, 3);
	FRotator Copy = FRotator(Source);
	return Copy.Pitch + Copy.Yaw + Copy.Roll;
}

float LocalConstValue()
{
	const FRotator r = FRotator(10, 20, 30);
	return r.Pitch + r.Yaw + r.Roll;
}

float GlobalConstValue()
{
	return GlobalConstRotator.Pitch + GlobalConstRotator.Yaw + GlobalConstRotator.Roll;
}

FRotator NormalizeMutates()
{
	FRotator r = FRotator(0, 450, 0);
	r.Normalize();
	return r;
}

FRotator InverseRotator()
{
	return FRotator(0, 90, 0).GetInverse();
}

float AxisHelpers()
{
	return FRotator::NormalizeAxis(450) + FRotator::ClampAxis(-90);
}

bool WindingAndRemainder()
{
	FRotator Winding;
	FRotator Remainder;
	FRotator(0, 450, 0).GetWindingAndRemainder(Winding, Remainder);
	return Winding.Equals(FRotator(0, 360, 0), 0.001) && Remainder.Equals(FRotator(0, 90, 0), 0.001);
}

float ManhattanDistance()
{
	return FRotator(10, 20, 30).GetManhattanDistance(FRotator(5, 5, 5));
}

FVector RightVector()
{
	return FRotator(0, 0, 0).GetRightVector();
}

FVector UpVector()
{
	return FRotator(0, 0, 0).GetUpVector();
}

bool DeltaRoundTrip()
{
	FRotator Origin = FRotator::ZeroRotator;
	FRotator Target = FRotator(0, 90, 0);
	FRotator Delta = FRotator::GetDelta(Origin, Target);
	return FRotator::ApplyDelta(Origin, Delta).Equals(Target, 0.05);
}

bool RelativeRoundTrip()
{
	FRotator Parent = FRotator(0, 30, 0);
	FRotator Child = FRotator(0, 75, 0);
	FRotator Relative = FRotator::GetRelative(Parent, Child);
	return FRotator::ApplyRelative(Parent, Relative).Equals(Child, 0.05);
}

class FPlainRotatorHolder
{
	FRotator Value;

	FPlainRotatorHolder()
	{
		Value = FRotator(2, 4, 6);
	}
}

int PlainClassMemberValueRaisesBoundary()
{
	FPlainRotatorHolder Holder;
	return Holder.Value.Pitch + Holder.Value.Yaw + Holder.Value.Roll;
}

bool Observe_LocalDefaultIsZero()
{
	return LocalDefaultIsZero() == 0.0;
}

bool Observe_LocalScalarConstructorSum()
{
	return LocalScalarConstructorSum() == 21.0;
}

bool Observe_LocalCopyConstructorSum()
{
	return LocalCopyConstructorSum() == 6.0;
}

bool Observe_LocalConstValue()
{
	return LocalConstValue() == 60.0;
}

bool Observe_GlobalConstValue()
{
	return GlobalConstValue() == 0.0;
}

bool Observe_NormalizeMutates()
{
	return NormalizeMutates().Equals(FRotator(0, 90, 0), 0.001);
}

bool Observe_InverseRotator()
{
	return InverseRotator().Equals(FRotator(0, 90, 0).GetInverse(), 0.001);
}

bool Observe_AxisHelpers()
{
	return AxisHelpers() == 360.0;
}

bool Observe_WindingAndRemainder()
{
	return WindingAndRemainder() == true;
}

bool Observe_ManhattanDistance()
{
	return ManhattanDistance() == 45.0;
}

bool Observe_RightVector()
{
	return RightVector().Equals(FVector::RightVector, 0.001);
}

bool Observe_UpVector()
{
	return UpVector().Equals(FVector::UpVector, 0.001);
}

bool Observe_DeltaRoundTrip()
{
	return DeltaRoundTrip() == true;
}

bool Observe_RelativeRoundTrip()
{
	return RelativeRoundTrip() == true;
}

bool Observe_ManhattanDistance_DefaultZero()
{
	return FRotator::ZeroRotator.GetManhattanDistance(FRotator::ZeroRotator) == 0.0;
}
