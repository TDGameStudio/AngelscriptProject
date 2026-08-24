// Theme: Gameplay.Debug. Runtime exception oracles (module compiles).
// C++: AngelscriptCoverageErrorHandlingTests.cpp::NegativeRuntimeAndCompileBoundaries
// CSV NegativeDiagnostic; C++ CompileAndExpectException, not compile-fail.
// Expected exceptions: Array index out of bounds.; Null pointer access;
// Division by zero; Need to insert between 0 and ArraySize; Invalid negative Num;
// Cannot move assign an array into itself.
// Extra: empty TArray before the illegal write. Do not add guards that would
// swallow the exceptions. Math::IntegerDivisionTrunc. DefaultSafe.

void TriggerArrayOutOfBounds()
{
	TArray<int> Values;
	Values.Add(10);
	Values[1] = 20;
}

FVector TriggerNullObjectAccess()
{
	AActor Actor;
	return Actor.GetActorLocation();
}

void TriggerDivideByZero()
{
	int Numerator = 12;
	int Denominator = 0;
	int Result = Math::IntegerDivisionTrunc(Numerator, Denominator);
	ThrowIf(Result != 0, "CoverageUnexpectedDivideResult");
}

void TriggerInsertOutOfBounds()
{
	TArray<int> Values;
	Values.Insert(10, 1);
}

void TriggerNegativeArraySize()
{
	TArray<int> Values;
	Values.SetNum(-1);
}

void TriggerMoveAssignSelf()
{
	TArray<int> Values;
	Values.Add(1);
	Values.MoveAssignFrom(Values);
}
