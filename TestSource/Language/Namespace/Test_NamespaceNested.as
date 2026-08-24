// Theme: Language.Namespace. Positive: nested namespace qualified access.
// C++: AngelscriptCoverageNamespaceTests.cpp::NamespaceNested ExpectGlobalReturn.
// sha256=8b3704e73ff92f1c65fd592e796ed01e69bd890a14fb8cf87d455f4ee9274dc9; lines 150-209.
// Oracle: AccessNested() == 300; AccessDeepNested() == 999.
// Extra: Inner::AccessOuter() == 100; Outer::AccessInner() == 200.
// DefaultSafe.

namespace Outer
{
	const int OuterValue = 10;

	int OuterFunction()
	{
		return 100;
	}

	namespace Inner
	{
		const int InnerValue = 20;

		int InnerFunction()
		{
			return 200;
		}

		int AccessOuter()
		{
			return Outer::OuterFunction();
		}
	}

	int AccessInner()
	{
		return Inner::InnerFunction();
	}
}

int AccessNested()
{
	return Outer::Inner::InnerFunction() + Outer::OuterFunction();
}

namespace Level1
{
	namespace Level2
	{
		namespace Level3
		{
			int DeepFunction()
			{
				return 999;
			}
		}
	}
}

int AccessDeepNested()
{
	return Level1::Level2::Level3::DeepFunction();
}

bool Observe_AccessNested_Nominal()
{
	return AccessNested() == 300 && AccessDeepNested() == 999;
}

bool Observe_InnerOuter_CrossAccess()
{
	return Outer::Inner::AccessOuter() == 100 && Outer::AccessInner() == 200;
}

int Observe_NestedConstants_Default()
{
	return Outer::OuterValue + Outer::Inner::InnerValue;
}
