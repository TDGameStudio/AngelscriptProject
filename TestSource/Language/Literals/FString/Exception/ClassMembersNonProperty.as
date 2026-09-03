/**
 * A script class owns plain, non-UPROPERTY members. Accessing those members
 * from script throws "Null pointer access" at run time: the members are not
 * reflected, so the runtime binding cannot resolve their storage. The class
 * still compiles, and its methods remain a working boundary — the fault is
 * only in direct member access.
 *
 * @Theme Language.Literals
 * @Subject Literals.ClassMembersNonProperty
 * @Harness RuntimeException
 * @Tag Language.Literals.ClassMembersNonProperty
 * @Namespace LiteralsTest
 * @Provenance C++: AngelscriptCoverageFStringExpressionTests.cpp::ClassMembersNonProperty
 * @Provenance sha256=667036feb83c3973e54dc05fcf04024083b78ac2ab550aa1e3ee6d497e05b991; lines 797-856.
 * @Provenance Oracle: module compiles; TestClassMemberAccess/Modify/Name/Text throw Null pointer access.
 * @Provenance Extra: default-constructed script class members remain the execution boundary.
 * @Provenance DiagnosticOnly for the expected null-pointer messages; declarations remain runner-readable.
 */

namespace LiteralsTest
{
	class StringHolder
	{
		FString Value;
		FName NameValue;
		FText TextValue;

		/**
		 * Initialise the plain, non-property members.
		 *
		 * @Covers Literals.FString
		 * @Inputs The holder's default member values
		 */
		StringHolder()
		{
			Value = "Initial";
			NameValue = n"Tag";
			TextValue = FText::FromString("TextMember");
		}

		/**
		 * Return the stored string member.
		 *
		 * @Covers Literals.FString
		 * @Inputs The holder's Value member
		 * @Return The stored string
		 */
		FString GetValue() const
		{
			return Value;
		}

		/**
		 * Overwrite the stored string member.
		 *
		 * @Covers Literals.FString
		 * @Inputs The new string value
		 */
		void SetValue(FString v)
		{
			Value = v;
		}

		/**
		 * Return the stored name member.
		 *
		 * @Covers Literals.FName
		 * @Inputs The holder's NameValue member
		 * @Return The stored name
		 */
		FName GetNameValue() const
		{
			return NameValue;
		}

		/**
		 * Return the stored text member as a string.
		 *
		 * @Covers Literals.FText
		 * @Inputs The holder's TextValue member
		 * @Return The stored text converted to string
		 */
		FString GetTextValue() const
		{
			return TextValue.ToString();
		}
	}

	/**
	 * Read a non-property string member directly, which the runtime cannot
	 * resolve.
	 *
	 * @Kind RuntimeException
	 * @Covers Literals.FString
	 * @Inputs StringHolder holder; holder.Value
	 * @Return does not return; throws "Null pointer access"
	 */
	UFUNCTION()
	FString DirectStringMemberRead()
	{
		StringHolder holder;
		return holder.Value;
	}

	/**
	 * Write a non-property string member directly, which the runtime cannot
	 * resolve.
	 *
	 * @Kind RuntimeException
	 * @Covers Literals.FString
	 * @Inputs StringHolder holder; holder.Value = "Modified"
	 * @Return does not return; throws "Null pointer access"
	 */
	UFUNCTION()
	FString DirectStringMemberWrite()
	{
		StringHolder holder;
		holder.Value = "Modified";
		return holder.GetValue();
	}

	/**
	 * Read a non-property name member directly, which the runtime cannot
	 * resolve.
	 *
	 * @Kind RuntimeException
	 * @Covers Literals.FName
	 * @Inputs StringHolder holder; holder.NameValue
	 * @Return does not return; throws "Null pointer access"
	 */
	UFUNCTION()
	FName DirectNameMemberRead()
	{
		StringHolder holder;
		return holder.NameValue;
	}

	/**
	 * Read a text member through a method whose body touches the non-property
	 * member, which still throws at run time.
	 *
	 * @Kind RuntimeException
	 * @Covers Literals.FText
	 * @Inputs StringHolder holder; holder.GetTextValue()
	 * @Return does not return; throws "Null pointer access"
	 */
	UFUNCTION()
	FString TextMemberReadThroughMethod()
	{
		StringHolder holder;
		return holder.GetTextValue();
	}
}
