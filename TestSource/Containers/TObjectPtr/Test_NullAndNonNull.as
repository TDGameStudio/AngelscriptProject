// Theme: Containers.TObjectPtr. Positive native UObject argument null vs non-null.
// C++ ExecuteNativeObjectArgumentCase: Test(instance)==1, Test(nullptr)==0.
// Extra: empty/null returns 0; live handle returns 1; alias of the same handle stays 1.
// DefaultSafe.

int Test(UObject Value)
{
	return Value != nullptr ? 1 : 0;
}

int Observe_NullAndNonNull_NonNull(UObject Value)
{
	return Test(Value);
}

int Observe_NullAndNonNull_NullBoundary()
{
	UObject Empty = nullptr;
	return Test(Empty);
}

int Observe_NullAndNonNull_CopyAlias(UObject Value)
{
	UObject Alias = Value;
	return Test(Alias);
}
