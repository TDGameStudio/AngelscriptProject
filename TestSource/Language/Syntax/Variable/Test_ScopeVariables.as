// Theme: Language.Syntax.Variable. Positive function/block/loop/namespace scopes.
// C++: AngelscriptCoverageNamespaceTests.cpp::ScopeVariables ExpectGlobalReturn.
// sha256=a4e8fc6cd453088d29148cf7dbc8dc7ea2ec1b70286a341232d56d44123fcb1f; lines 367-478.
// Oracle: FunctionScope==30; BlockScope==30; ForLoopScope==10; MultipleBlockScopes==30;
// NestedBlockScopes==60; IfStatementScope(true)==100; WhileLoopScope==20;
// GlobalAndNamespaceScope==18; ReadNamespacedScope==11.
// Extra: IfStatementScope(false)==200. DefaultSafe. Source owns locals.

const int GlobalScopeValue = 7;

namespace ScopeNS
{
	const int NamespacedScopeValue = 11;

	int ReadNamespacedScope()
	{
		return NamespacedScopeValue;
	}
}

// Function scope
int FunctionScope()
{
	int X = 10;
	int Y = 20;
	return X + Y;
}

// Block scope
int BlockScope()
{
	int X = 10;
	{
		int Y = 20;
		X = X + Y;
	}
	// Y is not accessible here
	return X;
}

// For loop scope
int ForLoopScope()
{
	int Sum = 0;
	for (int i = 0; i < 5; i++)
	{
		// i is only accessible in loop
		Sum += i;
	}
	// i is not accessible here
	return Sum;
}

// Multiple block scopes
int MultipleBlockScopes()
{
	int Result = 0;
	{
		int X = 10;
		Result += X;
	}
	{
		int X = 20;  // Different X
		Result += X;
	}
	return Result;
}

// Nested block scopes
int NestedBlockScopes()
{
	int X = 10;
	{
		int Y = 20;
		{
			int Z = 30;
			X = X + Y + Z;
		}
	}
	return X;
}

// If statement scope
int IfStatementScope(bool Condition)
{
	int Result = 0;
	if (Condition)
	{
		int X = 100;
		Result = X;
	}
	else
	{
		int X = 200;  // Different X
		Result = X;
	}
	return Result;
}

// While loop scope
int WhileLoopScope()
{
	int Sum = 0;
	int i = 0;
	while (i < 5)
	{
		int Temp = i * 2;
		Sum += Temp;
		i++;
	}
	// Temp is not accessible here
	return Sum;
}

int GlobalAndNamespaceScope()
{
	return GlobalScopeValue + ScopeNS::ReadNamespacedScope();
}

bool Observe_ScopeVariables_Nominal()
{
	return FunctionScope() == 30
		&& BlockScope() == 30
		&& ForLoopScope() == 10
		&& MultipleBlockScopes() == 30
		&& NestedBlockScopes() == 60
		&& IfStatementScope(true) == 100
		&& WhileLoopScope() == 20
		&& GlobalAndNamespaceScope() == 18
		&& ScopeNS::ReadNamespacedScope() == 11;
}

int Observe_IfStatementScope_FalseBoundary()
{
	return IfStatementScope(false);
}
