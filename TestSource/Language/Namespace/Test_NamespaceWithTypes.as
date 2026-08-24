// Theme: Language.Namespace. Value oracle: namespaced enum compiles; namespaced script-class local is a runtime exception.
// CSV SourceShape is NegativeDiagnostic; C++ BuildModule + ExpectGlobalReturn UseNamespacedEnum == 2,
// then ExecuteFunctionExpectingScriptException on UseNamespacedClass (not AssertFailsToCompile).
// C++: AngelscriptCoverageNamespaceTests.cpp::NamespaceWithTypes
// sha256=a7147b327fb84f4eb918ab0055eb9079d651728b5aa169a1bb4391997b0d1f5a; lines 783-828.
// Oracle: UseNamespacedEnum() == 2. UseNamespacedClass remains the runtime null-pointer boundary.
// Extra: UseEnum First == 1, Third == 3. Do not call UseNamespacedClass from Observe_*.

namespace Types
{
	class MyClass
	{
		int Value;

		int GetValue()
		{
			return Value;
		}
	}

	enum MyEnum
	{
		First,
		Second,
		Third
	}

	int UseEnum(MyEnum E)
	{
		switch (E)
		{
			case MyEnum::First:
				return 1;
			case MyEnum::Second:
				return 2;
			case MyEnum::Third:
				return 3;
		}
	}
}

int UseNamespacedClass()
{
	Types::MyClass Obj;
	Obj.Value = 42;
	return Obj.GetValue();
}

int UseNamespacedEnum()
{
	return Types::UseEnum(Types::MyEnum::Second);
}

int Observe_UseNamespacedEnum_Nominal()
{
	return UseNamespacedEnum();
}

int Observe_UseEnum_FirstBoundary()
{
	return Types::UseEnum(Types::MyEnum::First);
}

int Observe_UseEnum_ThirdBoundary()
{
	return Types::UseEnum(Types::MyEnum::Third);
}
