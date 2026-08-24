// Theme: Gameplay.FQuat. Positive X/Y/Z/W getter and setter oracles.
// C++: AngelscriptCoverageFQuatExpressionTests.cpp::QuatMemberAccess
// Oracle: GetX 0.1; GetY 0.2; GetZ 0.3; GetW 0.9; SetX/Y/Z/W each 0.5.
// Extra: default Identity W 1 X 0; copy independence of SetX. DefaultSafe.

float GetX()
{
	FQuat q = FQuat(0.1, 0.2, 0.3, 0.9);
	return q.X;
}

float GetY()
{
	FQuat q = FQuat(0.1, 0.2, 0.3, 0.9);
	return q.Y;
}

float GetZ()
{
	FQuat q = FQuat(0.1, 0.2, 0.3, 0.9);
	return q.Z;
}

float GetW()
{
	FQuat q = FQuat(0.1, 0.2, 0.3, 0.9);
	return q.W;
}

FQuat SetX()
{
	FQuat q = FQuat::Identity;
	q.X = 0.5;
	return q;
}

FQuat SetY()
{
	FQuat q = FQuat::Identity;
	q.Y = 0.5;
	return q;
}

FQuat SetZ()
{
	FQuat q = FQuat::Identity;
	q.Z = 0.5;
	return q;
}

FQuat SetW()
{
	FQuat q = FQuat::Identity;
	q.W = 0.5;
	return q;
}

bool Observe_Getters_Nominal()
{
	return GetX() == 0.1 && GetY() == 0.2 && GetZ() == 0.3 && GetW() == 0.9;
}

bool Observe_SetX()
{
	return SetX().X == 0.5;
}

bool Observe_SetY()
{
	return SetY().Y == 0.5;
}

bool Observe_SetZ()
{
	return SetZ().Z == 0.5;
}

bool Observe_SetW()
{
	return SetW().W == 0.5;
}

bool Observe_MemberAccess_DefaultIdentity()
{
	FQuat Empty = FQuat();
	return Empty.X == 0.0 && Empty.Y == 0.0 && Empty.Z == 0.0 && Empty.W == 1.0;
}

bool Observe_SetX_CopyIndependence()
{
	FQuat Source = FQuat::Identity;
	FQuat Mutated = Source;
	Mutated.X = 0.5;
	return Source.Equals(FQuat::Identity, 0.001) && Mutated.X == 0.5;
}
