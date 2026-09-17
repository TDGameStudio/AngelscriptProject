/**
 * @version v1
 * @summary FString, FName, and FText properties on UCLASS types.
 * @topic Unreal
 * @topic Strings
 *
 * string-name-text-conversion-round-trips
 * default-f-string-property-applied
 * f-string-interpolation-and-f-name-literal-runtime-values
 * string-container-properties
 * string-family-declaration-defaults
 * string-family-replicated-properties
 * string-family-script-special-text-values
 * string-family-write-round-trip
 * string-property-script-read-write-api-surface
 * string-special-values
 * string-default-preserves-comment-markers
 * name
 * const-fname-name-none
 * static-name
 * assignment
 * add-assign
 * set-number
 * equality
 * compare
 * is-none
 * get-number
 * get-plain-name-string
 * is-equal
 * get-hash
 * no-fixture
 * text
 * ordering
 * reverse
 * left
 * left-chop
 * right
 * right-chop
 * mid
 * replace-char-with-escaped-char
 * replace-escaped-char-with-char
 * left-pad
 * right-pad
 * trim-quotes
 * trim-start-and-end
 * trim-start
 * trim-end
 * trim-char
 * FString-Behavior_02-text
 * literal-equals-literal-isempty
 * assignment-host
 * add-assign-host
 * convert-tabs-to-spaces
 * to-upper
 * to-lower
 * to-bool
 * to-display-name
 * to-string
 * from-int
 * format-as-number
 * format
 * FString-ConversionAndFormatting_02-format
 * apply-format
 * FString-ConversionAndFormatting_03-apply-format
 * parse-into-array
 * parse-into-array-lines
 * parse-into-array-ws
 * is-valid-index
 * append
 * append-char
 * append-int
 * insert-at
 * empty
 * reset
 * reserve
 * shrink
 * remove-at
 * remove-spaces-inline
 * remove-from-start
 * remove-from-end
 * FString-MutationAndLifecycle_02-append
 * split
 * replace
 * replace-inline
 * join
 * sanitize-float
 * chr
 * chr-n
 * equality-host
 * addition
 * index
 * is-empty
 * len
 * is-numeric
 * find
 * contains
 * find-char
 * find-last-char
 * starts-with
 * ends-with
 * matches-wildcard
 * equals
 * compare-host
 * get-hash-host
 * loctable-fromfile-engine
 * loctable-fromfile-game
 * loctable-setstring
 * loctable-setmeta
 * loctable
 * findorload-fully-distinct
 * find-never-loads
 * or-not-string-table
 * lookup-empty-or-not
 * text-host
 * nsloctext
 * assigned-copy-deep
 * surface-002
 * assignment-host-x
 * from-string-table
 * from-name
 * from-string
 * as-culture-invariant
 * as-date
 * as-date-time
 * as-time
 * as-timespan
 * as-number
 * FText-ConversionAndFormatting_02-as-number
 * as-memory
 * format-host
 * FText-ConversionAndFormatting_03-format
 * identical-to
 * join-host
 * is-empty-host
 * is-empty-or-whitespace
 * is-transient
 * is-culture-invariant
 * is-initialized-from-string
 * is-from-string-table
 * get-format-pattern-parameters
 */
/**
 * @begin string-name-text-conversion-round-trips
 * @summary The same FString, FName, and FText round trips as ../Function/StringNameTextConversions, but carried on an actor so C++ can read the results off UPROPERTYs by path after BeginPlay runs. The name and text round trips each.
 * @topic Strings
 */
UCLASS()
class ACoverageStringNameTextActor : AActor
{
	UPROPERTY()
	FString StringFromName;

	UPROPERTY()
	FString StringFromText;

	UPROPERTY()
	FString StringFromInt;

	UPROPERTY()
	FName NameFromString;

	UPROPERTY()
	FText TextFromString;

	UPROPERTY()
	bool NameRoundTrip = false;

	UPROPERTY()
	bool TextRoundTrip = false;

	UPROPERTY()
	bool NumericStringRoundTrip = false;

	/**
	 * Runs the round trips once at play time, so the C++ fixture can read the
	 * resulting property values by path.
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FString Source = "CoverageName";
		NameFromString = FName(Source);
		StringFromName = NameFromString.ToString();

		TextFromString = FText::FromString("CoverageText");
		StringFromText = TextFromString.ToString();

		StringFromInt = FString::FromInt(314);
		NumericStringRoundTrip = StringFromInt == "314" && FString::FromInt(-12) == "-12";
		NameRoundTrip = StringFromName == Source && NameFromString == n"CoverageName";
		TextRoundTrip = StringFromText == "CoverageText";
	}
}

namespace CastingTest
{
	/**
	 * Observe the empty default: an empty string produces the None name.
	 *
	 * @Kind Observe
	 * @Covers Casting.FStringConversion
	 * @Inputs FName("")
	 * @Return true when the name reports IsNone
	 * @Boundary empty string
	 */
	UFUNCTION()
	bool EmptyStringGivesNoneName()
	{
		FString Empty;
		FName NoneName = FName(Empty);
		return NoneName.IsNone();
	}

	/**
	 * Observe the zero boundary: FromInt(0) formats to "0".
	 *
	 * @Kind Observe
	 * @Covers Casting.FStringConversion
	 * @Inputs FString::FromInt(0)
	 * @Return "0"
	 * @Boundary zero
	 */
	UFUNCTION()
	FString FromIntZeroFormatsToString()
	{
		return FString::FromInt(0);
	}
}
/** @end */
/**
 * @begin default-f-string-property-applied
 * @summary A UObject carrier declares a default FString UPROPERTY through the `default` initialiser. The member reads back the applied default, stays non-empty, and copies independently of the original. The UPROPERTY name MyString.
 * @topic Strings
 */
UCLASS()
class UDefaultStringCarrier : UObject
{
	UPROPERTY()
	FString MyString;

	default MyString = "Hello World";

	/**
	 * Report the verification result: 42 when MyString holds the applied
	 * default, otherwise 1.
	 *
	 * @Covers Literals.FString
	 * @Inputs The carrier's default MyString
	 * @Return 42 on success, 1 on mismatch
	 */
	UFUNCTION()
	int VerifyString()
	{
		if (MyString != "Hello World")
		{
			return 1;
		}
		return 42;
	}

	/**
	 * Confirm the applied default reads back through VerifyString.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs VerifyString over the carrier
	 * @Return true when VerifyString reports 42
	 */
	UFUNCTION()
	bool VerifyStringReturnsSuccess()
	{
		return VerifyString() == 42;
	}

	/**
	 * Confirm MyString is non-empty at the empty boundary.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs The carrier's default MyString
	 * @Return true when MyString is not the empty string
	 * @Boundary empty-string sentinel
	 */
	UFUNCTION()
	bool VerifyMyStringNotEmptyAtBoundary()
	{
		return MyString != "";
	}

	/**
	 * Confirm copying MyString and mutating the copy leaves the member
	 * unchanged.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs A copy of MyString changed to "Other"
	 * @Return true when MyString stays "Hello World" and the copy is "Other"
	 */
	UFUNCTION()
	bool VerifyMyStringCopyIsIndependent()
	{
		FString Copy = MyString;
		Copy = "Other";
		if (MyString != "Hello World")
		{
			return false;
		}
		return Copy == "Other";
	}
}
/** @end */
/**
 * @begin f-string-interpolation-and-f-name-literal-runtime-values
 * @summary An actor builds strings through f-string interpolation and compares n"" FName literals against constructor-built names. The observers confirm the interpolated greeting and composite, the empty-name interpolation, and the.
 * @topic Strings
 */
UCLASS()
class AFunctionalStringInterpolationActor : AActor
{
	UPROPERTY()
	FString Greeting;

	UPROPERTY()
	FString Composite;

	UPROPERTY()
	bool bFNameLiteralEqualsConstructor = false;

	UPROPERTY()
	bool bFNameLiteralIsCaseInsensitive = false;

	/**
	 * Build the interpolated strings and evaluate the FName literal comparisons.
	 *
	 * @Covers Literals.FString
	 * @Inputs An interpolated greeting and composite, and n"" FName literals
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FString WhoName = "World";
		Greeting = f"Hello {WhoName}!";

		int32 A = 1;
		int32 B = 2;
		int32 C = 3;
		Composite = f"{A} {B} in {C}s";

		bFNameLiteralEqualsConstructor = (n"Tag" == FName("Tag"));
		bFNameLiteralIsCaseInsensitive = (n"tag" == FName("TAG"));
	}

	/**
	 * Confirm the interpolated values and the FName literal comparisons hold.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs Greeting, Composite, and the two FName literal flags
	 * @Return true when all four interpolated/literal expectations hold
	 */
	UFUNCTION()
	bool VerifyInterpolation()
	{
		if (Greeting != "Hello World!")
		{
			return false;
		}
		if (Composite != "1 2 in 3s")
		{
			return false;
		}
		if (!bFNameLiteralEqualsConstructor)
		{
			return false;
		}
		return bFNameLiteralIsCaseInsensitive;
	}

	/**
	 * Interpolate an empty name and return the result.
	 *
	 * @Covers Literals.FString
	 * @Inputs An empty WhoName
	 * @Return "Hello !" with the empty name in place
	 * @Boundary empty interpolation value
	 */
	UFUNCTION()
	FString InterpolateEmptyWhoName()
	{
		FString WhoName = "";
		return f"Hello {WhoName}!";
	}

	/**
	 * Confirm an n"" tag literal is not NAME_None.
	 *
	 * @Kind Observe
	 * @Covers Literals.FName
	 * @Inputs n"Tag" compared to NAME_None
	 * @Return true when n"Tag" differs from NAME_None
	 * @Boundary NAME_None sentinel
	 */
	UFUNCTION()
	bool VerifyFNameNoneNotTag()
	{
		return n"Tag" != NAME_None;
	}
}
/** @end */
/**
 * @begin string-container-properties
 * @summary String-family members inside UE containers on an actor: TArray of FString, FName, and FText; TMap with string-family keys and values; and TSet of FString and FName. The observers confirm array order, empty text elements.
 * @topic Strings
 */
UCLASS()
class ACoverageFStringContainerActor : AActor
{
	UPROPERTY()
	TArray<FString> StringArray;

	UPROPERTY()
	TArray<FName> NameArray;

	UPROPERTY()
	TArray<FText> TextArray;

	UPROPERTY()
	TMap<FString, int> StringToIntMap;

	UPROPERTY()
	TMap<int, FString> IntToStringMap;

	UPROPERTY()
	TMap<int, FName> IntToNameMap;

	UPROPERTY()
	TMap<int, FText> IntToTextMap;

	UPROPERTY()
	TMap<FName, int> NameToIntMap;

	UPROPERTY()
	TSet<FString> StringSet;

	UPROPERTY()
	TSet<FName> NameSet;

	/**
	 * Populate the string-family containers during actor begin.
	 *
	 * @Covers Literals.FString
	 * @Inputs Arrays, maps, and sets seeded with string-family values
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		StringArray.Add("First");
		StringArray.Add("Second");
		StringArray.Add("Third");

		NameArray.Add(n"Alpha");
		NameArray.Add(n"Beta");
		NameArray.Add(NAME_None);

		TextArray.Add(FText::FromString("Text1"));
		TextArray.Add(FText::FromString("Text2"));
		TextArray.Add(FText::FromString(""));

		StringToIntMap.Add("One", 1);
		StringToIntMap.Add("Two", 2);

		IntToStringMap.Add(10, "Ten");
		IntToStringMap.Add(20, "Twenty");

		IntToNameMap.Add(10, n"TenName");
		IntToNameMap.Add(20, n"TwentyName");

		IntToTextMap.Add(10, FText::FromString("TenText"));
		IntToTextMap.Add(20, FText::FromString("TwentyText"));

		NameToIntMap.Add(n"First", 100);
		NameToIntMap.Add(n"Second", 200);
		NameToIntMap.Add(NAME_None, 300);

		StringSet.Add("Apple");
		StringSet.Add("Banana");
		StringSet.Add("Apple");  // Duplicate

		NameSet.Add(n"Tag1");
		NameSet.Add(n"Tag2");
	}

	/**
	 * Confirm the populated containers read back their expected contents.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs The containers built by BeginPlay
	 * @Return true when all array, map, and set expectations hold
	 */
	UFUNCTION()
	bool VerifyStringContainers()
	{
		if (StringArray.Num() != 3)
		{
			return false;
		}
		if (StringArray[0] != "First")
		{
			return false;
		}
		if (NameArray.Num() != 3)
		{
			return false;
		}
		if (NameArray[2] != NAME_None)
		{
			return false;
		}
		if (TextArray.Num() != 3)
		{
			return false;
		}
		if (!TextArray[2].IsEmpty())
		{
			return false;
		}
		if (StringToIntMap.Num() != 2)
		{
			return false;
		}
		if (IntToStringMap.Num() != 2)
		{
			return false;
		}
		if (NameToIntMap.Num() != 3)
		{
			return false;
		}
		if (StringSet.Num() != 2)
		{
			return false;
		}
		return NameSet.Num() == 2;
	}
}

UCLASS()
class ACoverageFStringContainerActorEmpty : AActor
{
	UPROPERTY()
	TArray<FString> StringArray;

	UPROPERTY()
	TSet<FString> StringSet;

	UPROPERTY()
	TMap<FString, int> StringToIntMap;

	/**
	 * Confirm the sibling actor's string-family containers default to empty.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs The default array, set, and map
	 * @Return true when all three have zero elements
	 * @Boundary empty container defaults
	 */
	UFUNCTION()
	bool VerifyEmptyContainersDefault()
	{
		if (StringArray.Num() != 0)
		{
			return false;
		}
		if (StringSet.Num() != 0)
		{
			return false;
		}
		return StringToIntMap.Num() == 0;
	}
}
/** @end */
/**
 * @begin string-family-declaration-defaults
 * @summary String-family members on a script actor keep the defaults declared in the UPROPERTY initialisers. The actor exposes FString, FName, and FText members with and without explicit defaults, and the observers confirm the.
 * @topic Strings
 */
UCLASS()
class ACoverageFStringDefaultsActor : AActor
{
	UPROPERTY()
	FString StringValue = "Hello";

	UPROPERTY()
	FString EmptyString = "";

	UPROPERTY()
	FString NoDefaultString;

	UPROPERTY()
	FName NameValue = n"MyName";

	UPROPERTY()
	FName EmptyName = n"";

	UPROPERTY()
	FText TextValue;

	/**
	 * Confirm every declared string-family default matches its initialiser.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs The actor's declared defaults
	 * @Return true when all six members read back their declared values
	 */
	UFUNCTION()
	bool VerifyDefaultsMatchDeclaration()
	{
		if (StringValue != "Hello")
		{
			return false;
		}
		if (EmptyString != "")
		{
			return false;
		}
		if (NoDefaultString != "")
		{
			return false;
		}
		if (NameValue != n"MyName")
		{
			return false;
		}
		if (EmptyName != n"")
		{
			return false;
		}
		return TextValue.IsEmpty();
	}

	/**
	 * Confirm the empty-boundary members stay empty at declaration time.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs The actor's empty FString and FName members
	 * @Return true when the empty fields have zero length or NAME_None
	 * @Boundary empty defaults
	 */
	UFUNCTION()
	bool VerifyEmptyFieldsStayEmpty()
	{
		if (EmptyString.Len() != 0)
		{
			return false;
		}
		if (NoDefaultString != "")
		{
			return false;
		}
		return EmptyName == n"";
	}

	/**
	 * Confirm copying StringValue and mutating the copy leaves the member
	 * unchanged.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs A copy of StringValue changed to "Other"
	 * @Return true when StringValue is still "Hello" and the copy is "Other"
	 */
	UFUNCTION()
	bool VerifyStringValueCopyIsIndependent()
	{
		FString Copy = StringValue;
		Copy = "Other";
		if (StringValue != "Hello")
		{
			return false;
		}
		return Copy == "Other";
	}
}
/** @end */
/**
 * @begin string-family-replicated-properties
 * @summary String-family members on a replicating actor carry the net-property flags declared on their UPROPERTY. The replicated FString and FName hold non-empty initials, the FText is replicated with a RepNotify callback, and the.
 * @topic Strings
 */
UCLASS()
class ACoverageFStringReplicationActor : AActor
{
	default SetReplicates(true);

	UPROPERTY(Replicated)
	FString ReplicatedString = "Initial";

	UPROPERTY(Replicated)
	FName ReplicatedName = n"InitialName";

	UPROPERTY(ReplicatedUsing=OnRep_DisplayText)
	FText DisplayText;

	/**
	 * RepNotify callback wired to DisplayText by ReplicatedUsing.
	 *
	 * @Covers Literals.FText
	 * @Inputs The replicated DisplayText update
	 */
	UFUNCTION()
	void OnRep_DisplayText()
	{
	}

	/**
	 * Confirm the replicated initials and the empty RepNotify text read back.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs The actor's replicated members
	 * @Return true when String and Name hold their initials and DisplayText is empty
	 */
	UFUNCTION()
	bool VerifyReplicatedInitials()
	{
		if (ReplicatedString != "Initial")
		{
			return false;
		}
		if (ReplicatedName != n"InitialName")
		{
			return false;
		}
		return DisplayText.IsEmpty();
	}
}

UCLASS()
class ACoverageFStringReplicationActorUnreplicated : AActor
{
	default SetReplicates(false);

	UPROPERTY()
	FString ReplicatedString = "";

	UPROPERTY()
	FName ReplicatedName = NAME_None;

	UPROPERTY()
	FText DisplayText;
}
/** @end */
/**
 * @begin string-family-script-special-text-values
 * @summary A text member stores an escaped string built from newlines, tabs, quotes, and backslashes; a source member is grown to 1050 characters and converted to text. Both read back losslessly. The UPROPERTY names EscapedText.
 * @topic Strings
 */
UCLASS()
class ACoverageFStringSpecialTextActor : AActor
{
	UPROPERTY()
	FText EscapedText;

	UPROPERTY()
	FText LongText;

	UPROPERTY()
	FString LongTextSource;

	/**
	 * Build the escaped text and the 1050-character source during actor begin.
	 *
	 * @Covers Literals.FText
	 * @Inputs A 1050-character "t" source and an escaped FText
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		EscapedText = FText::FromString("LineOne\nLineTwo\t\"Quote\"\\Slash");

		for (int i = 0; i < 1050; ++i)
		{
			LongTextSource += "t";
		}

		LongText = FText::FromString(LongTextSource);
	}

	/**
	 * Confirm the 1050-character source and its text conversion both hold.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs LongTextSource and LongText built by BeginPlay
	 * @Return true when both lengths are 1050
	 * @Boundary 1050-character length
	 */
	UFUNCTION()
	bool VerifyLongTextLengthBoundary()
	{
		if (LongTextSource.Len() != 1050)
		{
			return false;
		}
		return LongText.ToString().Len() == 1050;
	}

	/**
	 * Confirm the escaped text reads back with all escape sequences preserved.
	 *
	 * @Kind Observe
	 * @Covers Literals.FText
	 * @Inputs EscapedText built by BeginPlay
	 * @Return true when ToString preserves newline, tab, quote, and backslash
	 */
	UFUNCTION()
	bool VerifyEscapedTextRoundTrip()
	{
		return EscapedText.ToString() == "LineOne\nLineTwo\t\"Quote\"\\Slash";
	}
}
/** @end */
/**
 * @begin string-family-write-round-trip
 * @summary String-family members on an actor round-trip writes through the reflected UPROPERTY: a script write is read back, then overwritten to empty. The name member starts as NAME_None and copies independently, and the text.
 * @topic Strings
 */
UCLASS()
class ACoverageFStringWriteActor : AActor
{
	UPROPERTY()
	FString StringValue;

	UPROPERTY()
	FName NameValue;

	UPROPERTY()
	FText TextValue;

	/**
	 * Write StringValue, read it back, then clear it to confirm both states.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs StringValue assigned "Hello World" then cleared
	 * @Return true when it read back "Hello World" and then became empty
	 */
	UFUNCTION()
	bool VerifyStringValueWriteRoundTrip()
	{
		StringValue = "Hello World";
		bool bHello = StringValue == "Hello World";
		StringValue = "";
		if (!bHello)
		{
			return false;
		}
		return StringValue.Len() == 0;
	}

	/**
	 * Confirm NameValue defaults to NAME_None and copies independently.
	 *
	 * @Kind Observe
	 * @Covers Literals.FName
	 * @Inputs NameValue written to n"TestName", then a copy cleared to NAME_None
	 * @Return true when the default, the write, and the independent copy all hold
	 * @Boundary empty name default
	 */
	UFUNCTION()
	bool VerifyNameValueDefaultAndBoundary()
	{
		bool bDefaultNone = NameValue == NAME_None;
		NameValue = n"TestName";
		FName Copy = NameValue;
		Copy = NAME_None;
		if (!bDefaultNone)
		{
			return false;
		}
		if (NameValue != n"TestName")
		{
			return false;
		}
		return Copy == NAME_None;
	}

	/**
	 * Confirm TextValue defaults to empty.
	 *
	 * @Kind Observe
	 * @Covers Literals.FText
	 * @Inputs The actor's default TextValue
	 * @Return true when TextValue is empty
	 * @Boundary empty text default
	 */
	UFUNCTION()
	bool VerifyTextValueEmptyDefault()
	{
		return TextValue.IsEmpty();
	}
}
/** @end */
/**
 * @begin string-property-script-read-write-api-surface
 * @summary A script reads the initial string-family UPROPERTY values, then rewrites them in place and reads the rewritten values back. Each read reports a mask whose bits track the string, name, and text members, so the observers.
 * @topic Strings
 */
UCLASS()
class ACoverageFStringScriptApiSurfaceActor : AActor
{
	UPROPERTY()
	FString StoredString = "InitialString";

	UPROPERTY()
	FName StoredName = n"InitialName";

	UPROPERTY()
	FText StoredText;

	/**
	 * Read the initial string, name, and text members into a bitmask.
	 *
	 * @Covers Literals.FString
	 * @Inputs The actor's initial string-family members
	 * @Return 7 when all three members match their initial values
	 */
	UFUNCTION()
	int ReadInitialState()
	{
		int Mask = 0;
		if (StoredString == "InitialString")
		{
			Mask |= 1;
		}
		if (StoredName == n"InitialName")
		{
			Mask |= 2;
		}
		if (StoredText.IsEmpty())
		{
			Mask |= 4;
		}
		return Mask;
	}

	/**
	 * Rewrite the string, name, and text members in place, then read them back
	 * into a bitmask.
	 *
	 * @Covers Literals.FString
	 * @Inputs The actor's members rewritten to script values
	 * @Return 7 when all three members match the rewritten values
	 */
	UFUNCTION()
	int RewriteAndReadState()
	{
		StoredString = "ScriptString";
		StoredName = n"ScriptName";
		StoredText = FText::FromString("Script Text");

		int Mask = 0;
		if (StoredString == "ScriptString")
		{
			Mask |= 1;
		}
		if (StoredName == n"ScriptName")
		{
			Mask |= 2;
		}
		if (StoredText.ToString() == "Script Text")
		{
			Mask |= 4;
		}
		return Mask;
	}

	/**
	 * Confirm the initial state reads back as 7.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs ReadInitialState over the actor
	 * @Return true when the initial state mask is 7
	 */
	UFUNCTION()
	bool VerifyReadInitialState()
	{
		return ReadInitialState() == 7;
	}

	/**
	 * Confirm the rewritten state reads back as 7.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs RewriteAndReadState over the actor
	 * @Return true when the rewritten state mask is 7
	 */
	UFUNCTION()
	bool VerifyRewriteAndReadState()
	{
		return RewriteAndReadState() == 7;
	}

	/**
	 * Confirm a local empty FText reports empty.
	 *
	 * @Kind Observe
	 * @Covers Literals.FText
	 * @Inputs A default-constructed local FText
	 * @Return true when the local text is empty
	 * @Boundary empty text default
	 */
	UFUNCTION()
	bool VerifyLocalTextEmptyDefault()
	{
		FText Empty;
		return Empty.IsEmpty();
	}
}
/** @end */
/**
 * @begin string-special-values
 * @summary A script actor seeds string-family members with special values: an empty string, a 1024-character long string, escaped characters, unicode text, an empty name, a dotted name, and unicode text. The observer confirms the.
 * @topic Strings
 */
UCLASS()
class ACoverageFStringSpecialActor : AActor
{
	UPROPERTY()
	FString EmptyString;

	UPROPERTY()
	FString LongString;

	UPROPERTY()
	FString SpecialChars;

	UPROPERTY()
	FString UnicodeString;

	UPROPERTY()
	FName EmptyName;

	UPROPERTY()
	FName SpecialName;

	UPROPERTY()
	FText EmptyText;

	UPROPERTY()
	FText UnicodeText;

	/**
	 * Seed the special string-family members during actor begin.
	 *
	 * @Covers Literals.FString
	 * @Inputs Empty, long, escaped, unicode, and name/text values
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		EmptyString = "";

		for (int i = 0; i < 1024; ++i)
		{
			LongString += "x";
		}

		SpecialChars = "Hello\nWorld\tTab\"Quote\"\\Backslash";

		UnicodeString = "Hello 世界 🌍";
		EmptyName = NAME_None;
		SpecialName = FName("Name.With.Dots-123");
		EmptyText = FText::FromString("");
		UnicodeText = FText::FromString("Text 世界");
	}

	/**
	 * Confirm the empty string, the 1024-character string, the empty name, and
	 * the empty text boundaries hold.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs The members seeded by BeginPlay
	 * @Return true when the empty/long/name/text boundaries match
	 * @Boundary empty and 1024-length values
	 */
	UFUNCTION()
	bool VerifyEmptyAndLongBoundary()
	{
		if (EmptyString.Len() != 0)
		{
			return false;
		}
		if (LongString.Len() != 1024)
		{
			return false;
		}
		if (EmptyName != NAME_None)
		{
			return false;
		}
		return EmptyText.IsEmpty();
	}
}
/** @end */
/**
 * @begin string-default-preserves-comment-markers
 * @summary Comment markers appearing inside default string literals. The lexer must treat them as data rather than as the start of a comment, so both properties keep their full literal text.
 * @topic Strings
 */
UCLASS()
class UCompilerStringDefaultCarrier : UObject
{
	UPROPERTY()
	FString Message;

	UPROPERTY()
	FString BlockText;

	default Message = "He said \"//not a comment\"";
	default BlockText = "/*literal*/";

	/**
	 * Verifies that both defaults survived the lexer intact.
	 *
	 * @Covers Syntax.Comments
	 * @Inputs the two default string UPROPERTYs
	 * @Return 42 on success, 10 or 20 naming the mismatched property
	 */
	UFUNCTION()
	int VerifyDefaults()
	{
		if (!(Message == "He said \"//not a comment\""))
		{
			return 10;
		}

		if (!(BlockText == "/*literal*/"))
		{
			return 20;
		}

		return 42;
	}

	/**
	 * Observe that both defaults read back unchanged.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Comments
	 * @Inputs VerifyDefaults and the two properties
	 * @Return true when the verification passes and both literals match
	 */
	UFUNCTION()
	bool CommentMarkersSurviveInsideLiterals()
	{
		if (VerifyDefaults() != 42)
		{
			return false;
		}

		if (Message != "He said \"//not a comment\"")
		{
			return false;
		}

		return BlockText == "/*literal*/";
	}

	/**
	 * Observe that an empty string differs from both literals.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Comments
	 * @Inputs a default-constructed FString
	 * @Return true when it is empty and matches neither literal
	 * @Boundary empty string
	 */
	UFUNCTION()
	bool EmptyStringDiffersFromCommentLiterals()
	{
		FString Empty;

		if (Empty.Len() != 0)
		{
			return false;
		}

		if (Empty == "He said \"//not a comment\"")
		{
			return false;
		}

		return Empty != "/*literal*/";
	}
}
/** @end */
/**
 * @begin name
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveNameNominal
 * @summary Observe the container API.
 * @covers FName.name
 * @inputs FName values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FName Name(const FString& Other); const FName NAME_None;
// const FName& Name = __STATIC_NAME(int Id);
// Inputs: Default construction, copy of n"Alpha", string "Alpha_1", and
// NAME_None as the empty interned name.
// Expected observations: Default Name() is NAME_None. Copy preserves
// identity. String constructor interns the text. NAME_None.IsNone is true.
// Boundary/ownership: FName construction interns text in the name table.
// __STATIC_NAME returns a reference to a compiler-assigned interned name.
// FName(); FName(const FName&); FName(const FString&); default is NAME_None,
// copy keeps identity, "Alpha_1" interns with plain Alpha and number 1.
bool ObserveNameNominal()
{
	FName DefaultName;
	FName Source = n"Alpha";
	FName Copied(Source);
	FName FromString("Alpha_1");
	return DefaultName.IsNone() && Copied == Source && FromString.GetPlainNameString() == "Alpha" && FromString.GetNumber() == 1;
}
/** @end */
/**
 * @begin const-fname-name-none
 * @summary const FName NAME_None is the canonical empty interned name.
 * @topic Unreal
 */
/**
 * @function ObserveSurface016Nominal
 * @summary const FName NAME_None is the canonical empty interned name.
 * @covers FName.const-fname-name-none
 * @inputs FName values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface016Nominal()
{
	FName None = NAME_None;
	return None.IsNone() && None == NAME_None;
}
/** @end */
/**
 * @begin static-name
 * @summary are interned identities the runner can compare.
 * @topic Unreal
 */
/**
 * @function ObserveSTATICNAMENominal
 * @summary are interned identities the runner can compare.
 * @covers FName.static-name
 * @inputs FName values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSTATICNAMENominal()
{
	FName Literal = n"Alpha";
	const FName NoneRef = NAME_None;
	return NoneRef.IsNone() && Literal != NAME_None && Literal == n"Alpha";
}
/** @end */
/**
 * @begin assignment
 * @summary string buffer.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary string buffer.
 * @covers FName.assignment
 * @inputs FName values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAssignmentNominal()
{
	FName Left = NAME_None;
	FName Right = n"Alpha";
	Left = Right;
	FString Formatted = f"{Left}";
	return Left == Right && Left != NAME_None && Formatted.Len() > 0;
}
/** @end */
/**
 * @begin add-assign
 * @summary string buffer.
 * @topic Unreal
 */
/**
 * @function ObserveAddAssignNominal
 * @summary string buffer.
 * @covers FName.add-assign
 * @inputs FName values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddAssignNominal()
{
	FName Name = n"Alpha";
	FString Combined = Name + "_Tail";
	FString Operand = "_Tail";
	Name += Operand;
	FString Empty = "";
	FString EmptyCombined = Name + Empty;
	return Combined == "Alpha_Tail" && Operand == "Alpha_Tail" && EmptyCombined == "Alpha";
}
/** @end */
/**
 * @begin set-number
 * @summary FName value.
 * @topic Unreal
 */
/**
 * @function ObserveSetNumberNominal
 * @summary FName value.
 * @covers FName.set-number
 * @inputs FName values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetNumberNominal()
{
	FName Name = n"Alpha";
	int32 Before = Name.GetNumber();
	Name.SetNumber(1);
	int32 AfterFirst = Name.GetNumber();
	FString PlainAfter = Name.GetPlainNameString();
	Name.SetNumber(1);
	int32 AfterRepeat = Name.GetNumber();
	Name.SetNumber(0);
	int32 Restored = Name.GetNumber();
	return AfterFirst == 1 && AfterRepeat == 1 && Restored == 0 && PlainAfter == "Alpha" && Before == 0;
}
/** @end */
/**
 * @begin equality
 * @summary that the test relies on.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary that the test relies on.
 * @covers FName.equality
 * @inputs FName values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualityNominal()
{
	FName Left = n"Alpha";
	FName Right = n"Alpha";
	FName Other = n"Beta";
	bool bSame = Left == Right;
	bool bDifferent = Left == Other;
	bool bVsNone = Left == NAME_None;
	bool bNameEqualsString = Left == "Alpha";
	bool bNameNotEqualsOtherString = Left == "Beta";
	return bSame && !bDifferent && !bVsNone && bNameEqualsString && !bNameNotEqualsOtherString;
}
/** @end */
/**
 * @begin compare
 * @summary numeric suffix.
 * @topic Unreal
 */
/**
 * @function ObserveCompareNominal
 * @summary numeric suffix.
 * @covers FName.compare
 * @inputs FName values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveCompareNominal()
{
	FName Alpha = n"Alpha";
	FName Beta = n"Beta";
	int32 Self = Alpha.Compare(Alpha);
	int32 Ordered = Alpha.Compare(Beta);
	return Self == 0 && Ordered != 0;
}
/** @end */
/**
 * @begin is-none
 * @summary numeric suffix.
 * @topic Unreal
 */
/**
 * @function ObserveIsNoneNominal
 * @summary numeric suffix.
 * @covers FName.is-none
 * @inputs FName values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsNoneNominal()
{
	bool bNoneIsNone = NAME_None.IsNone();
	bool bAlphaIsNone = n"Alpha".IsNone();
	return bNoneIsNone && !bAlphaIsNone;
}
/** @end */
/**
 * @begin get-number
 * @summary numeric suffix.
 * @topic Unreal
 */
/**
 * @function ObserveGetNumberNominal
 * @summary numeric suffix.
 * @covers FName.get-number
 * @inputs FName values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetNumberNominal()
{
	FName Plain = n"Alpha";
	int32 PlainNumber = Plain.GetNumber();
	FName Numbered = n"Alpha_1";
	int32 NumberedValue = Numbered.GetNumber();
	return PlainNumber == 0 && NumberedValue == 1 && Numbered.GetPlainNameString() == "Alpha";
}
/** @end */
/**
 * @begin get-plain-name-string
 * @summary numeric suffix.
 * @topic Unreal
 */
/**
 * @function ObserveGetPlainNameStringNominal
 * @summary numeric suffix.
 * @covers FName.get-plain-name-string
 * @inputs FName values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetPlainNameStringNominal()
{
	FName Numbered = n"Alpha_1";
	FString Plain = Numbered.GetPlainNameString();
	FString NonePlain = NAME_None.GetPlainNameString();
	return Plain == "Alpha" && NonePlain == "None";
}
/** @end */
/**
 * @begin is-equal
 * @summary numeric suffix.
 * @topic Unreal
 */
/**
 * @function ObserveIsEqualNominal
 * @summary numeric suffix.
 * @covers FName.is-equal
 * @inputs FName values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsEqualNominal()
{
	FName Alpha = n"Alpha";
	FName Lower = n"alpha";
	bool bIgnoreCase = Alpha.IsEqual(Lower);
	bool bDefaultEqualsSelf = Alpha.IsEqual(Alpha);
	bool bHonorSelf = Alpha.IsEqual(Alpha, false, true);
	bool bHonorBeta = Alpha.IsEqual(n"Beta", false, true);
	return bIgnoreCase && bDefaultEqualsSelf && bHonorSelf && !bHonorBeta;
}
/** @end */
/**
 * @begin get-hash
 * @summary numeric suffix.
 * @topic Unreal
 */
/**
 * @function ObserveGetHashNominal
 * @summary numeric suffix.
 * @covers FName.get-hash
 * @inputs FName values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetHashNominal()
{
	FName Alpha = n"Alpha";
	FName Same = n"Alpha";
	FName Other = n"Beta";
	uint AlphaHash = Alpha.GetHash();
	uint SameHash = Same.GetHash();
	uint OtherHash = Other.GetHash();
	return AlphaHash == SameHash && OtherHash != AlphaHash;
}
/** @end */
/**
 * @begin no-fixture
 * @summary no fixture.
 * @topic Unreal
 */
/**
 * @function ObserveSurface003Nominal
 * @summary no fixture.
 * @covers FString.no-fixture
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface003Nominal()
{
	FString Text;
	return Text.IsEmpty();
}
/** @end */
/**
 * @begin text
 * @summary Copy stays "alpha"; source becomes "alphax".
 * @topic Unreal
 */
/**
 * @function ObserveTextNominal
 * @summary Copy stays "alpha"; source becomes "alphax".
 * @covers FString.text
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveTextNominal()
{
	FString Source = "alpha";
	FString Copied(Source);
	Source += "x";
	return Copied == "alpha" && Source == "alphax";
}
/** @end */
/**
 * @begin ordering
 * @summary beta > alpha, beta >= "beta".
 * @topic Unreal
 */
/**
 * @function ObserveOrderingNominal
 * @summary beta > alpha, beta >= "beta".
 * @covers FString.ordering
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveOrderingNominal()
{
	FString Alpha = "alpha";
	FString Beta = "beta";
	return (Alpha < Beta) && (Alpha <= FString("alpha")) && (Beta > Alpha) && (Beta >= FString("beta"));
}
/** @end */
/**
 * @begin reverse
 * @summary Returns a copy.
 * @topic Unreal
 */
/**
 * @function ObserveReverseNominal
 * @summary Returns a copy.
 * @covers FString.reverse
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveReverseNominal()
{
	FString Reversed = FString("abc").Reverse();
	FString Empty = FString("").Reverse();
	return Reversed == "cba" && Empty.IsEmpty();
}
/** @end */
/**
 * @begin left
 * @summary Returns a copy.
 * @topic Unreal
 */
/**
 * @function ObserveLeftNominal
 * @summary Returns a copy.
 * @covers FString.left
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveLeftNominal()
{
	FString Text = "abc";
	return Text.Left(2) == "ab" && Text.Left(0).IsEmpty();
}
/** @end */
/**
 * @begin left-chop
 * @summary LeftChop(0) is "abc".
 * @topic Unreal
 */
/**
 * @function ObserveLeftChopNominal
 * @summary LeftChop(0) is "abc".
 * @covers FString.left-chop
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveLeftChopNominal()
{
	FString Text = "abc";
	return Text.LeftChop(1) == "ab" && Text.LeftChop(0) == "abc";
}
/** @end */
/**
 * @begin right
 * @summary empty.
 * @topic Unreal
 */
/**
 * @function ObserveRightNominal
 * @summary empty.
 * @covers FString.right
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveRightNominal()
{
	FString Text = "abc";
	return Text.Right(2) == "bc" && Text.Right(0).IsEmpty();
}
/** @end */
/**
 * @begin right-chop
 * @summary RightChop(0) is "abc".
 * @topic Unreal
 */
/**
 * @function ObserveRightChopNominal
 * @summary RightChop(0) is "abc".
 * @covers FString.right-chop
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveRightChopNominal()
{
	FString Text = "abc";
	return Text.RightChop(1) == "bc" && Text.RightChop(0) == "abc";
}
/** @end */
/**
 * @begin mid
 * @summary Results "bc", "bc", and empty.
 * @topic Unreal
 */
/**
 * @function ObserveMidNominal
 * @summary Results "bc", "bc", and empty.
 * @covers FString.mid
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMidNominal()
{
	FString Text = "abc";
	return Text.Mid(1) == "bc" && Text.Mid(1, 2) == "bc" && Text.Mid(3).IsEmpty();
}
/** @end */
/**
 * @begin replace-char-with-escaped-char
 * @summary source stays "a\nb".
 * @topic Unreal
 */
/**
 * @function ObserveReplaceCharWithEscapedCharNominal
 * @summary source stays "a\nb".
 * @covers FString.replace-char-with-escaped-char
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveReplaceCharWithEscapedCharNominal()
{
	FString Text = "a\nb";
	FString Escaped = Text.ReplaceCharWithEscapedChar();
	return Escaped.Len() > Text.Len() && Text == "a\nb";
}
/** @end */
/**
 * @begin replace-escaped-char-with-char
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveReplaceEscapedCharWithCharNominal
 * @summary Observe the container API.
 * @covers FString.replace-escaped-char-with-char
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FString Text(ImplicitContributedValue);
// Inputs: "a\\nb", "ab" padded to 4, quoted "\"ab\"", "  ab  ", TrimChar 46
// ('.'), integer 7 as implicit construction.
// Expected observations: Unescape shrinks or restores control characters.
// LeftPad/RightPad reach Count. TrimQuotes writes OutQuotesRemoved true for
// quoted text and false for unquoted. Trims do not mutate the source.
// Boundary/ownership: All trim/pad helpers return copies. OutQuotesRemoved is
// a writeback bool.
bool ObserveReplaceEscapedCharWithCharNominal()
{
	FString Escaped = "a\\nb";
	FString Unescaped = Escaped.ReplaceEscapedCharWithChar();
	return Unescaped != Escaped && Unescaped.Len() > 0 && Escaped == "a\\nb";
}
/** @end */
/**
 * @begin left-pad
 * @summary a writeback bool.
 * @topic Unreal
 */
/**
 * @function ObserveLeftPadNominal
 * @summary a writeback bool.
 * @covers FString.left-pad
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveLeftPadNominal()
{
	FString Padded = FString("ab").LeftPad(4);
	FString NoPad = FString("abcd").LeftPad(2);
	return Padded.Len() == 4 && Padded.EndsWith("ab") && NoPad == "abcd";
}
/** @end */
/**
 * @begin right-pad
 * @summary a writeback bool.
 * @topic Unreal
 */
/**
 * @function ObserveRightPadNominal
 * @summary a writeback bool.
 * @covers FString.right-pad
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveRightPadNominal()
{
	FString Padded = FString("ab").RightPad(4);
	return Padded.Len() == 4 && Padded.StartsWith("ab");
}
/** @end */
/**
 * @begin trim-quotes
 * @summary a writeback bool.
 * @topic Unreal
 */
/**
 * @function ObserveTrimQuotesNominal
 * @summary a writeback bool.
 * @covers FString.trim-quotes
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveTrimQuotesNominal()
{
	bool bRemoved = false;
	FString Quoted = FString("\"ab\"").TrimQuotes(bRemoved);
	bool bUnquotedRemoved = true;
	FString Unquoted = FString("ab").TrimQuotes(bUnquotedRemoved);
	return Quoted == "ab" && bRemoved && Unquoted == "ab" && !bUnquotedRemoved;
}
/** @end */
/**
 * @begin trim-start-and-end
 * @summary a writeback bool.
 * @topic Unreal
 */
/**
 * @function ObserveTrimStartAndEndNominal
 * @summary a writeback bool.
 * @covers FString.trim-start-and-end
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveTrimStartAndEndNominal()
{
	FString Trimmed = FString("  ab  ").TrimStartAndEnd();
	return Trimmed == "ab";
}
/** @end */
/**
 * @begin trim-start
 * @summary a writeback bool.
 * @topic Unreal
 */
/**
 * @function ObserveTrimStartNominal
 * @summary a writeback bool.
 * @covers FString.trim-start
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveTrimStartNominal()
{
	FString Trimmed = FString("  ab  ").TrimStart();
	return Trimmed == "ab  ";
}
/** @end */
/**
 * @begin trim-end
 * @summary a writeback bool.
 * @topic Unreal
 */
/**
 * @function ObserveTrimEndNominal
 * @summary a writeback bool.
 * @covers FString.trim-end
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveTrimEndNominal()
{
	FString Trimmed = FString("  ab  ").TrimEnd();
	return Trimmed == "  ab";
}
/** @end */
/**
 * @begin trim-char
 * @summary a writeback bool.
 * @topic Unreal
 */
/**
 * @function ObserveTrimCharNominal
 * @summary a writeback bool.
 * @covers FString.trim-char
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveTrimCharNominal()
{
	FString Trimmed = FString("..ab..").TrimChar(46);
	FString Empty = FString("").TrimChar(46);
	return Trimmed == "ab" && Empty.IsEmpty();
}
/** @end */
/**
 * @begin FString-Behavior_02-text
 * @summary a writeback bool.
 * @topic Unreal
 */
/**
 * @function ObserveTextNominal
 * @summary a writeback bool.
 * @covers FString.text
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveTextNominal()
{
	FString FromInt(7);
	FName ImplicitName = n"Alpha";
	FString FromName = f"{ImplicitName}";
	return FromInt.Contains("7") && FromName.Contains("Alpha");
}
/** @end */
/**
 * @begin literal-equals-literal-isempty
 * @summary Literal equals "literal"; default IsEmpty.
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary Literal equals "literal"; default IsEmpty.
 * @covers FString.literal-equals-literal-isempty
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface001Nominal()
{
	FString Text = "literal";
	FString Empty;
	return Text == "literal" && Empty.IsEmpty();
}
/** @end */
/**
 * @begin assignment-host
 * @summary Text becomes "beta" and stays "beta" after Other changes.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary Text becomes "beta" and stays "beta" after Other changes.
 * @covers FString.assignment
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAssignmentNominal()
{
	FString Text = "alpha";
	FString Other = "beta";
	Text = Other;
	Other = "gamma";
	return Text == "beta" && Other == "gamma";
}
/** @end */
/**
 * @begin add-assign-host
 * @summary the destination.
 * @topic Unreal
 */
/**
 * @function ObserveAddAssignNominal
 * @summary the destination.
 * @covers FString.add-assign
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddAssignNominal()
{
	FString Text = "alpha";
	Text += "beta";
	Text += 7;
	int32 Value = 8;
	Text += Value;
	FString Empty = "";
	Empty += "x";
	return Text.StartsWith("alphabeta") && Text.Contains("7") && Text.Contains("8") && Empty == "x";
}
/** @end */
/**
 * @begin convert-tabs-to-spaces
 * @summary unchanged.
 * @topic Unreal
 */
/**
 * @function ObserveConvertTabsToSpacesNominal
 * @summary unchanged.
 * @covers FString.convert-tabs-to-spaces
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveConvertTabsToSpacesNominal()
{
	FString Text = "a\tb";
	FString Expanded = Text.ConvertTabsToSpaces(4);
	FString Empty = "".ConvertTabsToSpaces(4);
	return Expanded.Len() > Text.Len() && Expanded.Contains(" ") && Empty.IsEmpty();
}
/** @end */
/**
 * @begin to-upper
 * @summary unchanged.
 * @topic Unreal
 */
/**
 * @function ObserveToUpperNominal
 * @summary unchanged.
 * @covers FString.to-upper
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveToUpperNominal()
{
	return FString("Alpha").ToUpper() == "ALPHA";
}
/** @end */
/**
 * @begin to-lower
 * @summary unchanged.
 * @topic Unreal
 */
/**
 * @function ObserveToLowerNominal
 * @summary unchanged.
 * @covers FString.to-lower
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveToLowerNominal()
{
	return FString("Alpha").ToLower() == "alpha";
}
/** @end */
/**
 * @begin to-bool
 * @summary unchanged.
 * @topic Unreal
 */
/**
 * @function ObserveToBoolNominal
 * @summary unchanged.
 * @covers FString.to-bool
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveToBoolNominal()
{
	return FString("True").ToBool() && !FString("0").ToBool();
}
/** @end */
/**
 * @begin to-display-name
 * @summary unchanged.
 * @topic Unreal
 */
/**
 * @function ObserveToDisplayNameNominal
 * @summary unchanged.
 * @covers FString.to-display-name
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveToDisplayNameNominal()
{
	FString Display = FString("bHiddenFlag").ToDisplayName();
	FString BoolDisplay = FString("bHiddenFlag").ToDisplayName(true);
	return Display.Len() > 0 && BoolDisplay.Len() > 0 && Display != "bHiddenFlag";
}
/** @end */
/**
 * @begin to-string
 * @summary unchanged.
 * @topic Unreal
 */
/**
 * @function ObserveToStringNominal
 * @summary unchanged.
 * @covers FString.to-string
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveToStringNominal()
{
	FVector Vector(1.0, 2.0, 3.0);
	FString Text = Vector.ToString();
	return Text.Len() > 0;
}
/** @end */
/**
 * @begin from-int
 * @summary unchanged.
 * @topic Unreal
 */
/**
 * @function ObserveFromIntNominal
 * @summary unchanged.
 * @covers FString.from-int
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveFromIntNominal()
{
	return FString::FromInt(7) == "7" && FString::FromInt(0) == "0";
}
/** @end */
/**
 * @begin format-as-number
 * @summary unchanged.
 * @topic Unreal
 */
/**
 * @function ObserveFormatAsNumberNominal
 * @summary unchanged.
 * @covers FString.format-as-number
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveFormatAsNumberNominal()
{
	FString Number = FString::FormatAsNumber(1000);
	FString Zero = FString::FormatAsNumber(0);
	return Number.Len() > 0 && Number.Contains("1") && Zero.Contains("0");
}
/** @end */
/**
 * @begin format
 * @summary unchanged.
 * @topic Unreal
 */
/**
 * @function ObserveFormatNominal
 * @summary unchanged.
 * @covers FString.format
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveFormatNominal()
{
	FString One = FString::Format("{0}", 7);
	FString Two = FString::Format("{0}-{1}", "a", 2);
	return One.Contains("7") && Two.Contains("a") && Two.Contains("2");
}
/** @end */
/**
 * @begin FString-ConversionAndFormatting_02-format
 * @summary copied and not retained.
 * @topic Unreal
 */
/**
 * @function ObserveFormatNominal
 * @summary copied and not retained.
 * @covers FString.format
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveFormatNominal()
{
	FString Three = FString::Format("{0},{1},{2}", 1, 2, 3);
	FString Four = FString::Format("{0},{1},{2},{3}", 1, 2, 3, 4);
	FString Five = FString::Format("{0},{1},{2},{3},{4}", 1, 2, 3, 4, 5);
	return Three.Contains("1") && Three.Contains("3") && Four.Contains("4") && Five.Contains("5");
}
/** @end */
/**
 * @begin apply-format
 * @summary copied and not retained.
 * @topic Unreal
 */
/**
 * @function ObserveApplyFormatNominal
 * @summary copied and not retained.
 * @covers FString.apply-format
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveApplyFormatNominal()
{
	FString FromInt32 = FString::ApplyFormat(int32(255), "x");
	FString FromUint32 = FString::ApplyFormat(uint32(255), "x");
	FString FromInt64 = FString::ApplyFormat(int64(255), "x");
	FString FromUint64 = FString::ApplyFormat(uint64(255), "x");
	FString FromInt16 = FString::ApplyFormat(int16(255), "x");
	FString FromUint16 = FString::ApplyFormat(uint16(255), "x");
	FString FromInt8 = FString::ApplyFormat(int8(7), "x");
	FString FromZero = FString::ApplyFormat(int32(0), "x");
	return FromInt32.Len() > 0 && FromUint32.Len() > 0 && FromInt64.Len() > 0 && FromUint64.Len() > 0 && FromInt16.Len() > 0 && FromUint16.Len() > 0 && FromInt8.Len() > 0 && FromZero.Len() > 0;
}
/** @end */
/**
 * @begin FString-ConversionAndFormatting_03-apply-format
 * @summary be replaced depending on implementation, so this source starts from empty.
 * @topic Unreal
 */
/**
 * @function ObserveApplyFormatNominal
 * @summary be replaced depending on implementation, so this source starts from empty.
 * @covers FString.apply-format
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveApplyFormatNominal()
{
	FString FromUint8 = FString::ApplyFormat(uint8(7), "x");
	FString FromBool = FString::ApplyFormat(true, "x");
	FString FromFloat32 = FString::ApplyFormat(float32(1.5), "x");
	FString FromFloat64 = FString::ApplyFormat(float64(1.5), "x");
	FString FromString = FString::ApplyFormat(FString("ab"), "x");
	int32 Erased = 9;
	FString FromErased = FString::ApplyFormat(Erased, "x");
	return FromUint8.Len() > 0 && FromBool.Len() > 0 && FromFloat32.Len() > 0 && FromFloat64.Len() > 0 && FromString.Len() > 0 && FromErased.Len() > 0;
}
/** @end */
/**
 * @begin parse-into-array
 * @summary be replaced depending on implementation, so this source starts from empty.
 * @topic Unreal
 */
/**
 * @function ObserveParseIntoArrayNominal
 * @summary be replaced depending on implementation, so this source starts from empty.
 * @covers FString.parse-into-array
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveParseIntoArrayNominal()
{
	FString Text = "a,b,,c";
	TArray<FString> Culled;
	int CulledCount = Text.ParseIntoArray(Culled, ",");
	TArray<FString> Kept;
	int KeptCount = Text.ParseIntoArray(Kept, ",", false);
	TArray<FString> Delimiters;
	Delimiters.Add(",");
	Delimiters.Add(";");
	FString Multi = "a;b,c";
	TArray<FString> MultiOut;
	int MultiCount = Multi.ParseIntoArray(MultiOut, Delimiters);
	return CulledCount == 3 && Culled.Num() == 3 && Culled[0] == "a" && Culled[2] == "c" && KeptCount >= CulledCount && MultiCount == 3 && MultiOut[1] == "b";
}
/** @end */
/**
 * @begin parse-into-array-lines
 * @summary be replaced depending on implementation, so this source starts from empty.
 * @topic Unreal
 */
/**
 * @function ObserveParseIntoArrayLinesNominal
 * @summary be replaced depending on implementation, so this source starts from empty.
 * @covers FString.parse-into-array-lines
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveParseIntoArrayLinesNominal()
{
	FString Text = "a\nb\n\nc";
	TArray<FString> Lines;
	int Count = Text.ParseIntoArrayLines(Lines);
	TArray<FString> Kept;
	int KeptCount = Text.ParseIntoArrayLines(Kept, false);
	return Count >= 2 && Lines[0] == "a" && KeptCount >= Count;
}
/** @end */
/**
 * @begin parse-into-array-ws
 * @summary be replaced depending on implementation, so this source starts from empty.
 * @topic Unreal
 */
/**
 * @function ObserveParseIntoArrayWSNominal
 * @summary be replaced depending on implementation, so this source starts from empty.
 * @covers FString.parse-into-array-ws
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveParseIntoArrayWSNominal()
{
	FString Text = "a b  c";
	TArray<FString> Tokens;
	int Count = Text.ParseIntoArrayWS(Tokens);
	TArray<FString> EmptySource;
	int EmptyCount = FString("").ParseIntoArrayWS(EmptySource);
	return Count == 3 && Tokens[2] == "c" && EmptyCount == 0;
}
/** @end */
/**
 * @begin is-valid-index
 * @summary on "ab".
 * @topic Unreal
 */
/**
 * @function ObserveIsValidIndexNominal
 * @summary on "ab".
 * @covers FString.is-valid-index
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
// on "ab". -1

 and Len() are false.
// Boundary/ownership: Index addresses a UTF-16 code unit, not a glyph. The
// query does not mutate the string.
bool ObserveIsValidIndexNominal()
{
	FString Empty;
	FString Text = "ab";
	return !Empty.IsValidIndex(0) && Text.IsValidIndex(0) && Text.IsValidIndex(1) && !Text.IsValidIndex(2) && !Text.IsValidIndex(-1);
}
/** @end */
/**
 * @begin append
 * @summary Inputs: Seeded "ab", Other "c",
 * @topic Unreal
 */
/**
 * @function ObserveAppendNominal
 * @summary Inputs: Seeded "ab", Other "c",
 * @covers FString.append
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Seeded "ab", Other "c",

 char 100 ('d'), int 7, insert at 1, Empty
// then restore via Append, Reserve(16), Shrink.
// Expected observations: Append returns this and the later read sees the
// suffix. InsertAt shifts characters. Empty yields length 0. Reset also
// yields length 0 while remaining usable.
// Boundary/ownership: Append returns an alias to this string. Empty releases
// storage; Reset may retain capacity.
bool ObserveAppendNominal()
{
	FString Text = "ab";
	FString& Alias = Text.Append("c");
	Alias.Append("d");
	return Text == "abcd";
}
/** @end */
/**
 * @begin append-char
 * @summary storage.
 * @topic Unreal
 */
/**
 * @function ObserveAppendCharNominal
 * @summary storage.
 * @covers FString.append-char
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Seeded "ab", Other "c",

bool ObserveAppendCharNominal()
{
	FString Text = "ab";
	Text.AppendChar(99);
	return Text == "abc";
}
/** @end */
/**
 * @begin append-int
 * @summary storage.
 * @topic Unreal
 */
/**
 * @function ObserveAppendIntNominal
 * @summary storage.
 * @covers FString.append-int
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Seeded "ab", Other "c",

bool ObserveAppendIntNominal()
{
	FString Text = "n";
	Text.AppendInt(7);
	Text.AppendInt(0);
	return Text.Contains("7") && Text.Contains("0");
}
/** @end */
/**
 * @begin insert-at
 * @summary storage.
 * @topic Unreal
 */
/**
 * @function ObserveInsertAtNominal
 * @summary storage.
 * @covers FString.insert-at
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Seeded "ab", Other "c",

bool ObserveInsertAtNominal()
{
	FString Text = "ac";
	Text.InsertAt(1, 98);
	Text.InsertAt(1, "XY");
	return Text == "aXYbc";
}
/** @end */
/**
 * @begin empty
 * @summary storage.
 * @topic Unreal
 */
/**
 * @function ObserveEmptyNominal
 * @summary storage.
 * @covers FString.empty
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Seeded "ab", Other "c",

bool ObserveEmptyNominal()
{
	FString Text = "abc";
	Text.Empty();
	bool bEmptyNoSlack = Text.IsEmpty();
	Text = "abc";
	Text.Empty(8);
	return bEmptyNoSlack && Text.IsEmpty();
}
/** @end */
/**
 * @begin reset
 * @summary storage.
 * @topic Unreal
 */
/**
 * @function ObserveResetNominal
 * @summary storage.
 * @covers FString.reset
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Seeded "ab", Other "c",

bool ObserveResetNominal()
{
	FString Text = "abc";
	Text.Reset();
	bool bDefaultResetEmpty = Text.IsEmpty();
	Text = "abc";
	Text.Reset(4);
	return bDefaultResetEmpty && Text.IsEmpty();
}
/** @end */
/**
 * @begin reserve
 * @summary storage.
 * @topic Unreal
 */
/**
 * @function ObserveReserveNominal
 * @summary storage.
 * @covers FString.reserve
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Seeded "ab", Other "c",

bool ObserveReserveNominal()
{
	FString Text = "ab";
	int Before = Text.Len();
	Text.Reserve(16);
	return Before == 2 && Text.Len() == 2 && Text == "ab";
}
/** @end */
/**
 * @begin shrink
 * @summary storage.
 * @topic Unreal
 */
/**
 * @function ObserveShrinkNominal
 * @summary storage.
 * @covers FString.shrink
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Seeded "ab", Other "c",

bool ObserveShrinkNominal()
{
	FString Text = "ab";
	Text.Reserve(32);
	Text.Shrink();
	return Text == "ab";
}
/** @end */
/**
 * @begin remove-at
 * @summary Expected
 * @topic Unreal
 */
/**
 * @function ObserveRemoveAtNominal
 * @summary Expected
 * @covers FString.remove-at
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

 observations: RemoveAt(2,1) drops one code unit. RemoveSpacesInline
// yields "abc". Matching RemoveFromStart/End return true and mutate; missing
// prefixes return false.
// Boundary/ownership: RemoveAt past Len is the diagnostic path. Append of a
// type-erased value copies formatted text.
bool ObserveRemoveAtNominal()
{
	FString Text = "abcd";
	Text.RemoveAt(1, 2);
	Text.RemoveAt(0, 0);
	return Text == "ad";
}
/** @end */
/**
 * @begin remove-spaces-inline
 * @summary type-erased value copies formatted text.
 * @topic Unreal
 */
/**
 * @function ObserveRemoveSpacesInlineNominal
 * @summary type-erased value copies formatted text.
 * @covers FString.remove-spaces-inline
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveRemoveSpacesInlineNominal()
{
	FString Text = "a b c";
	Text.RemoveSpacesInline();
	Text.RemoveSpacesInline();
	return Text == "abc";
}
/** @end */
/**
 * @begin remove-from-start
 * @summary type-erased value copies formatted text.
 * @topic Unreal
 */
/**
 * @function ObserveRemoveFromStartNominal
 * @summary type-erased value copies formatted text.
 * @covers FString.remove-from-start
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveRemoveFromStartNominal()
{
	FString Text = "AlphaBeta";
	bool bRemoved = Text.RemoveFromStart("alpha");
	bool bMissing = Text.RemoveFromStart("zzz");
	return bRemoved && Text.StartsWith("Beta") && !bMissing;
}
/** @end */
/**
 * @begin remove-from-end
 * @summary type-erased value copies formatted text.
 * @topic Unreal
 */
/**
 * @function ObserveRemoveFromEndNominal
 * @summary type-erased value copies formatted text.
 * @covers FString.remove-from-end
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveRemoveFromEndNominal()
{
	FString Text = "AlphaBeta";
	bool bRemoved = Text.RemoveFromEnd("beta");
	bool bMissing = Text.RemoveFromEnd("zzz");
	return bRemoved && Text.EndsWith("Alpha") && !bMissing;
}
/** @end */
/**
 * @begin FString-MutationAndLifecycle_02-append
 * @summary type-erased value copies formatted text.
 * @topic Unreal
 */
/**
 * @function ObserveAppendNominal
 * @summary type-erased value copies formatted text.
 * @covers FString.append
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveAppendNominal()
{
	FString Text = "n";
	int32 Value = 7;
	Text.Append(Value);
	FString& Alias = Text.Append(8);
	Alias.Append("x");
	return Text.Contains("7") && Text.Contains("8") && Text.EndsWith("x");
}
/** @end */
/**
 * @begin split
 * @summary copy.
 * @topic Unreal
 */
/**
 * @function ObserveSplitNominal
 * @summary copy.
 * @covers FString.split
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSplitNominal()
{
	FString Text = "left-mid-right";
	FString OutLeft;
	FString OutRight;
	bool bSplit = Text.Split("-", OutLeft, OutRight);
	FString MissingLeft;
	FString MissingRight;
	bool bMissing = Text.Split("zzz", MissingLeft, MissingRight);
	return bSplit && OutLeft == "left" && OutRight == "mid-right" && !bMissing;
}
/** @end */
/**
 * @begin replace
 * @summary copy.
 * @topic Unreal
 */
/**
 * @function ObserveReplaceNominal
 * @summary copy.
 * @covers FString.replace
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveReplaceNominal()
{
	FString Text = "mid-mid";
	FString Replaced = Text.Replace("mid", "MID");
	FString EmptyReplaced = Text.Replace("zzz", "Q");
	return Replaced == "MID-MID" && Text == "mid-mid" && EmptyReplaced == "mid-mid";
}
/** @end */
/**
 * @begin replace-inline
 * @summary copy.
 * @topic Unreal
 */
/**
 * @function ObserveReplaceInlineNominal
 * @summary copy.
 * @covers FString.replace-inline
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveReplaceInlineNominal()
{
	FString Text = "mid-mid";
	int Count = Text.ReplaceInline("mid", "MID");
	int Missing = Text.ReplaceInline("zzz", "Q");
	return Count == 2 && Text == "MID-MID" && Missing == 0;
}
/** @end */
/**
 * @begin join
 * @summary copy.
 * @topic Unreal
 */
/**
 * @function ObserveJoinNominal
 * @summary copy.
 * @covers FString.join
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveJoinNominal()
{
	TArray<FString> Parts;
	Parts.Add("a");
	Parts.Add("b");
	FString Joined = FString::Join(Parts, ",");
	TArray<FString> Empty;
	FString EmptyJoined = FString::Join(Empty, ",");
	return Joined == "a,b" && EmptyJoined.IsEmpty();
}
/** @end */
/**
 * @begin sanitize-float
 * @summary copy.
 * @topic Unreal
 */
/**
 * @function ObserveSanitizeFloatNominal
 * @summary copy.
 * @covers FString.sanitize-float
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSanitizeFloatNominal()
{
	FString DefaultDigits = FString::SanitizeFloat(2.5);
	FString TwoDigits = FString::SanitizeFloat(2.5, 2);
	FString Zero = FString::SanitizeFloat(0.0);
	return DefaultDigits.Contains("2") && TwoDigits.Len() > 0 && Zero.Contains("0");
}
/** @end */
/**
 * @begin chr
 * @summary copy.
 * @topic Unreal
 */
/**
 * @function ObserveChrNominal
 * @summary copy.
 * @covers FString.chr
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveChrNominal()
{
	FString A = FString::Chr(65);
	return A == "A" && A.Len() == 1;
}
/** @end */
/**
 * @begin chr-n
 * @summary copy.
 * @topic Unreal
 */
/**
 * @function ObserveChrNNominal
 * @summary copy.
 * @covers FString.chr-n
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveChrNNominal()
{
	FString Dots = FString::ChrN(3, 46);
	FString Empty = FString::ChrN(0, 46);
	return Dots == "..." && Empty.IsEmpty();
}
/** @end */
/**
 * @begin equality-host
 * @summary access is the expected failure.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary access is the expected failure.
 * @covers FString.equality
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualityNominal()
{
	FString Text = "alpha";
	FString Other = "alpha";
	FString Mixed = "Alpha";
	FString Empty = "";
	return (Text == Other) && !(Text == Mixed) && !(Text == Empty);
}
/** @end */
/**
 * @begin addition
 * @summary access is the expected failure.
 * @topic Unreal
 */
/**
 * @function ObserveAdditionNominal
 * @summary access is the expected failure.
 * @covers FString.addition
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAdditionNominal()
{
	FString Left = "alpha";
	FString Right = "beta";
	FString Combined = Left + Right;
	FString WithInt = Left + 7;
	int32 Value = 8;
	FString WithValue = Left + Value;
	return Combined == "alphabeta" && Left == "alpha" && WithInt.Contains("alpha") && WithInt.Contains("7") && WithValue.Contains("8");
}
/** @end */
/**
 * @begin index
 * @summary access is the expected failure.
 * @topic Unreal
 */
/**
 * @function ObserveIndexNominal
 * @summary access is the expected failure.
 * @covers FString.index
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIndexNominal()
{
	FString Text = "ab";
	int16 First = Text[0];
	int16 Last = Text[1];
	Text[0] = 99;
	const FString ConstText = "ab";
	int16 ConstFirst = ConstText[0];
	return First == 97 && Last == 98 && Text[0] == 99 && Text.StartsWith("c") && ConstFirst == 97;
}
/** @end */
/**
 * @begin is-empty
 * @summary Inputs: "", "7", "AlphaBetaAlpha", needle "Alpha",
 * @topic Unreal
 */
/**
 * @function ObserveIsEmptyNominal
 * @summary Inputs: "", "7", "AlphaBetaAlpha", needle "Alpha",
 * @covers FString.is-empty
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: "", "7", "AlphaBetaAlpha", needle "Alpha",

 char 65 ('A'), wildcard
// "A*a", and INDEX_NONE as the missing-match sentinel.
// Expected observations: Empty is empty and length 0. "7" is numeric. Find
// returns 0 then a later index from the end. Missing needles return
// INDEX_NONE. FindChar writes Index on success.
// Boundary/ownership: Find does not mutate. Out Index is written only on
// successful FindChar/FindLastChar.
bool ObserveIsEmptyNominal()
{
	FString Empty;
	FString Text = "x";
	return Empty.IsEmpty() && !Text.IsEmpty();
}
/** @end */
/**
 * @begin len
 * @summary successful FindChar/FindLastChar.
 * @topic Unreal
 */
/**
 * @function ObserveLenNominal
 * @summary successful FindChar/FindLastChar.
 * @covers FString.len
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: "", "7", "AlphaBetaAlpha", needle "Alpha",

bool ObserveLenNominal()
{
	FString Empty;
	FString Text = "ab";
	return Empty.Len() == 0 && Text.Len() == 2;
}
/** @end */
/**
 * @begin is-numeric
 * @summary successful FindChar/FindLastChar.
 * @topic Unreal
 */
/**
 * @function ObserveIsNumericNominal
 * @summary successful FindChar/FindLastChar.
 * @covers FString.is-numeric
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: "", "7", "AlphaBetaAlpha", needle "Alpha",

bool ObserveIsNumericNominal()
{
	return FString("7").IsNumeric() && !FString("a7").IsNumeric() && !FString("").IsNumeric();
}
/** @end */
/**
 * @begin find
 * @summary successful FindChar/FindLastChar.
 * @topic Unreal
 */
/**
 * @function ObserveFindNominal
 * @summary successful FindChar/FindLastChar.
 * @covers FString.find
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: "", "7", "AlphaBetaAlpha", needle "Alpha",

bool ObserveFindNominal()
{
	FString Text = "AlphaBetaAlpha";
	int First = Text.Find("Alpha");
	int FromEnd = Text.Find("Alpha", ESearchCase::IgnoreCase, ESearchDir::FromEnd);
	int Missing = Text.Find("zzz");
	return First == 0 && FromEnd > First && Missing == INDEX_NONE;
}
/** @end */
/**
 * @begin contains
 * @summary successful FindChar/FindLastChar.
 * @topic Unreal
 */
/**
 * @function ObserveContainsNominal
 * @summary successful FindChar/FindLastChar.
 * @covers FString.contains
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: "", "7", "AlphaBetaAlpha", needle "Alpha",

bool ObserveContainsNominal()
{
	FString Text = "AlphaBeta";
	return Text.Contains("beta") && !Text.Contains("zzz");
}
/** @end */
/**
 * @begin find-char
 * @summary successful FindChar/FindLastChar.
 * @topic Unreal
 */
/**
 * @function ObserveFindCharNominal
 * @summary successful FindChar/FindLastChar.
 * @covers FString.find-char
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: "", "7", "AlphaBetaAlpha", needle "Alpha",

bool ObserveFindCharNominal()
{
	FString Text = "ABA";
	int Index = -2;
	bool bFound = Text.FindChar(65, Index);
	int MissingIndex = -2;
	bool bMissing = Text.FindChar(90, MissingIndex);
	return bFound && Index == 0 && !bMissing;
}
/** @end */
/**
 * @begin find-last-char
 * @summary successful FindChar/FindLastChar.
 * @topic Unreal
 */
/**
 * @function ObserveFindLastCharNominal
 * @summary successful FindChar/FindLastChar.
 * @covers FString.find-last-char
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: "", "7", "AlphaBetaAlpha", needle "Alpha",

bool ObserveFindLastCharNominal()
{
	FString Text = "ABA";
	int Index = -2;
	bool bFound = Text.FindLastChar(65, Index);
	return bFound && Index == 2;
}
/** @end */
/**
 * @begin starts-with
 * @summary successful FindChar/FindLastChar.
 * @topic Unreal
 */
/**
 * @function ObserveStartsWithNominal
 * @summary successful FindChar/FindLastChar.
 * @covers FString.starts-with
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: "", "7", "AlphaBetaAlpha", needle "Alpha",

bool ObserveStartsWithNominal()
{
	FString Text = "AlphaBeta";
	return Text.StartsWith("alpha") && !Text.StartsWith("Beta");
}
/** @end */
/**
 * @begin ends-with
 * @summary successful FindChar/FindLastChar.
 * @topic Unreal
 */
/**
 * @function ObserveEndsWithNominal
 * @summary successful FindChar/FindLastChar.
 * @covers FString.ends-with
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: "", "7", "AlphaBetaAlpha", needle "Alpha",

bool ObserveEndsWithNominal()
{
	FString Text = "AlphaBeta";
	return Text.EndsWith("beta") && !Text.EndsWith("Alpha");
}
/** @end */
/**
 * @begin matches-wildcard
 * @summary successful FindChar/FindLastChar.
 * @topic Unreal
 */
/**
 * @function ObserveMatchesWildcardNominal
 * @summary successful FindChar/FindLastChar.
 * @covers FString.matches-wildcard
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: "", "7", "AlphaBetaAlpha", needle "Alpha",

bool ObserveMatchesWildcardNominal()
{
	FString Text = "AlphaBeta";
	return Text.MatchesWildcard("A*a") && !Text.MatchesWildcard("Z*");
}
/** @end */
/**
 * @begin equals
 * @summary Boundary/ownership: These queries do not intern or mutate either operand.
 * @topic Unreal
 */
/**
 * @function ObserveEqualsNominal
 * @summary Boundary/ownership: These queries do not intern or mutate either operand.
 * @covers FString.equals
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualsNominal()
{
	FString Alpha = "Alpha";
	FString Lower = "alpha";
	FString Same = "Alpha";
	return !Alpha.Equals(Lower) && Alpha.Equals(Lower, ESearchCase::IgnoreCase) && Alpha.Equals(Same);
}
/** @end */
/**
 * @begin compare-host
 * @summary Boundary/ownership: These queries do not intern or mutate either operand.
 * @topic Unreal
 */
/**
 * @function ObserveCompareNominal
 * @summary Boundary/ownership: These queries do not intern or mutate either operand.
 * @covers FString.compare
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveCompareNominal()
{
	FString Alpha = "Alpha";
	FString Beta = "Beta";
	FString Same = "Alpha";
	return Alpha.Compare(Same) == 0 && Alpha.Compare(Beta) != 0 && Alpha.Compare("alpha", ESearchCase::IgnoreCase) == 0;
}
/** @end */
/**
 * @begin get-hash-host
 * @summary Boundary/ownership: These queries do not intern or mutate either operand.
 * @topic Unreal
 */
/**
 * @function ObserveGetHashNominal
 * @summary Boundary/ownership: These queries do not intern or mutate either operand.
 * @covers FString.get-hash
 * @inputs FString values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetHashNominal()
{
	FString Alpha = "Alpha";
	FString Same = "Alpha";
	FString Empty = "";
	uint AlphaHash = Alpha.GetHash();
	uint SameHash = Same.GetHash();
	uint EmptyHash = Empty.GetHash();
	return AlphaHash == SameHash && EmptyHash != AlphaHash;
}
/** @end */
/**
 * @begin loctable-fromfile-engine
 * @summary by value and does not transfer table ownership.
 * @topic Unreal
 */
/**
 * @function ObserveLOCTABLEFROMFILEENGINENominal
 * @summary by value and does not transfer table ownership.
 * @covers FStringTableRegistry.loctable-fromfile-engine
 * @inputs FStringTableRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveLOCTABLEFROMFILEENGINENominal()
{
	LOCTABLE_FROMFILE_ENGINE(n"TestSource.EngineLocTable", "TestSource", "Missing/EngineTable.csv");
	FText Missing = LOCTABLE(n"TestSource.EngineLocTable", "MissingKey");
	return Missing.IsEmpty() || !Missing.IsFromStringTable();
}
/** @end */
/**
 * @begin loctable-fromfile-game
 * @summary by value and does not transfer table ownership.
 * @topic Unreal
 */
/**
 * @function ObserveLOCTABLEFROMFILEGAMENominal
 * @summary by value and does not transfer table ownership.
 * @covers FStringTableRegistry.loctable-fromfile-game
 * @inputs FStringTableRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveLOCTABLEFROMFILEGAMENominal()
{
	LOCTABLE_FROMFILE_GAME(n"TestSource.GameLocTable", "TestSource", "Missing/GameTable.csv");
	FText Missing = LOCTABLE(n"TestSource.GameLocTable", "MissingKey");
	return Missing.IsEmpty() || !Missing.IsFromStringTable();
}
/** @end */
/**
 * @begin loctable-setstring
 * @summary by value and does not transfer table ownership.
 * @topic Unreal
 */
/**
 * @function ObserveLOCTABLESETSTRINGNominal
 * @summary by value and does not transfer table ownership.
 * @covers FStringTableRegistry.loctable-setstring
 * @inputs FStringTableRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveLOCTABLESETSTRINGNominal()
{
	LOCTABLE_NEW(n"TestSource.LocTable.SetString", "TestSource");
	LOCTABLE_SETSTRING(n"TestSource.LocTable.SetString", "Greeting", "Hello");
	LOCTABLE_SETSTRING(n"TestSource.LocTable.SetString", "Greeting", "Hello");
	FText Found = LOCTABLE(n"TestSource.LocTable.SetString", "Greeting");
	return Found.ToString().Contains("Hello");
}
/** @end */
/**
 * @begin loctable-setmeta
 * @summary by value and does not transfer table ownership.
 * @topic Unreal
 */
/**
 * @function ObserveLOCTABLESETMETANominal
 * @summary by value and does not transfer table ownership.
 * @covers FStringTableRegistry.loctable-setmeta
 * @inputs FStringTableRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveLOCTABLESETMETANominal()
{
	LOCTABLE_NEW(n"TestSource.LocTable.SetMeta", "TestSource");
	LOCTABLE_SETSTRING(n"TestSource.LocTable.SetMeta", "Greeting", "Hello");
	LOCTABLE_SETMETA(n"TestSource.LocTable.SetMeta", "Greeting", n"Comment", "nominal");
	FText Found = LOCTABLE(n"TestSource.LocTable.SetMeta", "Greeting");
	return Found.ToString().Contains("Hello");
}
/** @end */
/**
 * @begin loctable
 * @summary by value and does not transfer table ownership.
 * @topic Unreal
 */
/**
 * @function ObserveLOCTABLENominal
 * @summary by value and does not transfer table ownership.
 * @covers FStringTableRegistry.loctable
 * @inputs FStringTableRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveLOCTABLENominal()
{
	LOCTABLE_NEW(n"TestSource.LocTable.Lookup", "TestSource");
	LOCTABLE_SETSTRING(n"TestSource.LocTable.Lookup", "Greeting", "Hello");
	FText Found = LOCTABLE(n"TestSource.LocTable.Lookup", "Greeting");
	FText Missing = LOCTABLE(n"TestSource.LocTable.Lookup", "");
	return Found.ToString().Contains("Hello") && Missing.ToString() != Found.ToString();
}
/** @end */
/**
 * @begin findorload-fully-distinct
 * @summary is FindOrLoad; Fully is distinct.
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary is FindOrLoad; Fully is distinct.
 * @covers FStringTableRegistry.findorload-fully-distinct
 * @inputs FStringTableRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface001Nominal()
{
	EStringTableLoadingPolicy Policy = EStringTableLoadingPolicy::Find;
	EStringTableLoadingPolicy Copied = Policy;
	Copied = EStringTableLoadingPolicy::FindOrLoad;
	EStringTableLoadingPolicy Fully = EStringTableLoadingPolicy::FindOrFullyLoad;
	return Policy == EStringTableLoadingPolicy::Find && Copied == EStringTableLoadingPolicy::FindOrLoad && Fully != Policy && Fully != Copied;
}
/** @end */
/**
 * @begin find-never-loads
 * @summary Find never loads.
 * @topic Unreal
 */
/**
 * @function ObserveSurface002Nominal
 * @summary Find never loads.
 * @covers FStringTableRegistry.find-never-loads
 * @inputs FStringTableRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface002Nominal()
{
	EStringTableLoadingPolicy Policy = EStringTableLoadingPolicy::Find;
	FText Missing = FText::FromStringTable(n"TestSource.MissingTable", "MissingKey", Policy);
	return Missing.IsEmpty() || !Missing.IsFromStringTable();
}
/** @end */
/**
 * @begin or-not-string-table
 * @summary or not from a string table.
 * @topic Unreal
 */
/**
 * @function ObserveSurface003Nominal
 * @summary or not from a string table.
 * @covers FStringTableRegistry.or-not-string-table
 * @inputs FStringTableRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface003Nominal()
{
	EStringTableLoadingPolicy Policy = EStringTableLoadingPolicy::FindOrLoad;
	FText Lookup = FText::FromStringTable(n"TestSource.MissingTable", "MissingKey", Policy);
	return Policy != EStringTableLoadingPolicy::Find && (Lookup.IsEmpty() || !Lookup.IsFromStringTable());
}
/** @end */
/**
 * @begin lookup-empty-or-not
 * @summary lookup is empty or not from a string table.
 * @topic Unreal
 */
/**
 * @function ObserveSurface004Nominal
 * @summary lookup is empty or not from a string table.
 * @covers FStringTableRegistry.lookup-empty-or-not
 * @inputs FStringTableRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface004Nominal()
{
	EStringTableLoadingPolicy Policy = EStringTableLoadingPolicy::FindOrFullyLoad;
	FText Lookup = FText::FromStringTable(n"TestSource.MissingTable", "MissingKey", Policy);
	return Policy != EStringTableLoadingPolicy::Find && Policy != EStringTableLoadingPolicy::FindOrLoad && (Lookup.IsEmpty() || !Lookup.IsFromStringTable());
}
/** @end */
/**
 * @begin text-host
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveTextNominal
 * @summary Observe the container API.
 * @covers FText.text
 * @inputs FText values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FText NSLOCTEXT(const FString& Namespace, const FString& Key, const FString& Text);
// Inputs: Empty construction, copy of FromString("Hello"), and NSLOCTEXT
// literals "TestSource", "Greeting", "Hello".
// Expected observations: Default FText is empty. Copy is independent after
// later assignment of the source. NSLOCTEXT display string contains Hello.
// Boundary/ownership: NSLOCTEXT requires string literals for all three
// arguments so the gatherer can collect them.
bool ObserveTextNominal()
{
	FText Empty;
	FText Source = FText::FromString("Hello");
	FText Copied(Source);
	Source = FText::FromString("Other");
	return Empty.IsEmpty() && Copied.ToString().Contains("Hello") && Source.ToString().Contains("Other");
}
/** @end */
/**
 * @begin nsloctext
 * @summary arguments so the gatherer can collect them.
 * @topic Unreal
 */
/**
 * @function ObserveNSLOCTEXTNominal
 * @summary arguments so the gatherer can collect them.
 * @covers FText.nsloctext
 * @inputs FText values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveNSLOCTEXTNominal()
{
	FText Localized = NSLOCTEXT("TestSource", "Greeting", "Hello");
	FText EmptyKey = NSLOCTEXT("TestSource", "Empty", "");
	return Localized.ToString().Contains("Hello") && EmptyKey.IsEmpty();
}
/** @end */
/**
 * @begin assigned-copy-deep
 * @summary assigned copy is Deep.
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary assigned copy is Deep.
 * @covers FText.assigned-copy-deep
 * @inputs FText values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface001Nominal()
{
	ETextIdenticalModeFlags NoneFlags = ETextIdenticalModeFlags::None;
	ETextIdenticalModeFlags Deep = ETextIdenticalModeFlags::DeepCompare;
	ETextIdenticalModeFlags Lexical = ETextIdenticalModeFlags::LexicalCompareInvariants;
	ETextIdenticalModeFlags Copied = NoneFlags;
	Copied = Deep;
	return NoneFlags != Deep && Deep != Lexical && Copied == Deep;
}
/** @end */
/**
 * @begin surface-002
 * @summary ownership.
 * @topic Unreal
 */
/**
 * @function ObserveSurface002Nominal
 * @summary ownership.
 * @covers FText.surface-002
 * @inputs FText values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface002Nominal()
{
	EDateTimeStyle DefaultStyle = EDateTimeStyle::Default;
	EDateTimeStyle ShortStyle = EDateTimeStyle::Short;
	EDateTimeStyle MediumStyle = EDateTimeStyle::Medium;
	EDateTimeStyle LongStyle = EDateTimeStyle::Long;
	EDateTimeStyle FullStyle = EDateTimeStyle::Full;
	return DefaultStyle != ShortStyle && MediumStyle != LongStyle && FullStyle != ShortStyle;
}
/** @end */
/**
 * @begin assignment-host-x
 * @summary FText assignment and f"{Text}".
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary FText assignment and f"{Text}".
 * @covers FText.assignment
 * @inputs FText values exercised by this observe
 * @return true when the observe comparison holds
 */
 and FromString("Hello"),
// then reassign Right to "Other". Formatted text contains Hello; Left is
// not empty. Assignment copies history; Right mutation does not clear Left.
bool ObserveAssignmentNominal()
{
	FText Left;
	FText Right = FText::FromString("Hello");
	Left = Right;
	FString Formatted = f"{Left}";
	FText Other = FText::FromString("Other");
	Right = Other;
	return Formatted.Contains("Hello") && !Left.IsEmpty();
}
/** @end */
/**
 * @begin from-string-table
 * @summary Expected
 * @topic Unreal
 */
/**
 * @function ObserveFromStringTableNominal
 * @summary Expected
 * @covers FText.from-string-table
 * @inputs FText values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

 observations: FromString("Hello") is not empty. FromName text
// contains Alpha. Date/time/timespan formatters return non-empty display
// strings. AsNumber of 0 still produces text.
// Boundary/ownership: FromStringTable with Find does not create a table.
// Formatters return new FText values.
bool ObserveFromStringTableNominal()
{
	FText Missing = FText::FromStringTable(n"TestSource.MissingTable", "MissingKey");
	FText WithPolicy = FText::FromStringTable(n"TestSource.MissingTable", "MissingKey", EStringTableLoadingPolicy::Find);
	return (Missing.IsEmpty() || !Missing.IsFromStringTable()) && (WithPolicy.IsEmpty() || !WithPolicy.IsFromStringTable());
}
/** @end */
/**
 * @begin from-name
 * @summary Formatters return new FText values.
 * @topic Unreal
 */
/**
 * @function ObserveFromNameNominal
 * @summary Formatters return new FText values.
 * @covers FText.from-name
 * @inputs FText values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveFromNameNominal()
{
	FText Text = FText::FromName(n"Alpha");
	FText NoneText = FText::FromName(NAME_None);
	return Text.ToString().Contains("Alpha") && NoneText.ToString() != Text.ToString();
}
/** @end */
/**
 * @begin from-string
 * @summary Formatters return new FText values.
 * @topic Unreal
 */
/**
 * @function ObserveFromStringNominal
 * @summary Formatters return new FText values.
 * @covers FText.from-string
 * @inputs FText values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveFromStringNominal()
{
	FText Text = FText::FromString("Hello");
	FText Empty = FText::FromString("");
	return !Text.IsEmpty() && Empty.IsEmpty();
}
/** @end */
/**
 * @begin as-culture-invariant
 * @summary Formatters return new FText values.
 * @topic Unreal
 */
/**
 * @function ObserveAsCultureInvariantNominal
 * @summary Formatters return new FText values.
 * @covers FText.as-culture-invariant
 * @inputs FText values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveAsCultureInvariantNominal()
{
	FText Text = FText::AsCultureInvariant("Hello");
	return Text.IsCultureInvariant() && Text.ToString().Contains("Hello");
}
/** @end */
/**
 * @begin as-date
 * @summary Formatters return new FText values.
 * @topic Unreal
 */
/**
 * @function ObserveAsDateNominal
 * @summary Formatters return new FText values.
 * @covers FText.as-date
 * @inputs FText values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveAsDateNominal()
{
	FDateTime DateTime(2020, 1, 2);
	FText DefaultText = FText::AsDate(DateTime);
	FText ShortText = FText::AsDate(DateTime, EDateTimeStyle::Short);
	return DefaultText.ToString().Len() > 0 && ShortText.ToString().Len() > 0;
}
/** @end */
/**
 * @begin as-date-time
 * @summary Formatters return new FText values.
 * @topic Unreal
 */
/**
 * @function ObserveAsDateTimeNominal
 * @summary Formatters return new FText values.
 * @covers FText.as-date-time
 * @inputs FText values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveAsDateTimeNominal()
{
	FDateTime DateTime(2020, 1, 2, 3, 4, 5);
	FText Text = FText::AsDateTime(DateTime);
	FText Styled = FText::AsDateTime(DateTime, EDateTimeStyle::Short, EDateTimeStyle::Short);
	return Text.ToString().Len() > 0 && Styled.ToString().Len() > 0;
}
/** @end */
/**
 * @begin as-time
 * @summary Formatters return new FText values.
 * @topic Unreal
 */
/**
 * @function ObserveAsTimeNominal
 * @summary Formatters return new FText values.
 * @covers FText.as-time
 * @inputs FText values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveAsTimeNominal()
{
	FDateTime DateTime(2020, 1, 2, 3, 4, 5);
	FText Text = FText::AsTime(DateTime);
	return Text.ToString().Len() > 0;
}
/** @end */
/**
 * @begin as-timespan
 * @summary Formatters return new FText values.
 * @topic Unreal
 */
/**
 * @function ObserveAsTimespanNominal
 * @summary Formatters return new FText values.
 * @covers FText.as-timespan
 * @inputs FText values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveAsTimespanNominal()
{
	FTimespan Span = FTimespan::FromHours(1.0);
	FText Text = FText::AsTimespan(Span);
	FText Zero = FText::AsTimespan(FTimespan::Zero());
	return Text.ToString().Len() > 0 && Zero.ToString().Len() > 0;
}
/** @end */
/**
 * @begin as-number
 * @summary Formatters return new FText values.
 * @topic Unreal
 */
/**
 * @function ObserveAsNumberNominal
 * @summary Formatters return new FText values.
 * @covers FText.as-number
 * @inputs FText values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveAsNumberNominal()
{
	FNumberFormattingOptions Options;
	FText FromFloat32 = FText::AsNumber(float32(1.5), Options);
	FText FromFloat64 = FText::AsNumber(float64(0.0), Options);
	return FromFloat32.ToString().Len() > 0 && FromFloat64.ToString().Len() > 0;
}
/** @end */
/**
 * @begin FText-ConversionAndFormatting_02-as-number
 * @summary new FText and does not mutate the pattern.
 * @topic Unreal
 */
/**
 * @function ObserveAsNumberNominal
 * @summary new FText and does not mutate the pattern.
 * @covers FText.as-number
 * @inputs FText values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAsNumberNominal()
{
	FNumberFormattingOptions Options;
	FText FromInt8 = FText::AsNumber(int8(7), Options);
	FText FromInt16 = FText::AsNumber(int16(7), Options);
	FText FromInt32 = FText::AsNumber(int32(7), Options);
	FText FromInt64 = FText::AsNumber(int64(7), Options);
	FText FromUint8 = FText::AsNumber(uint8(7), Options);
	FText FromUint16 = FText::AsNumber(uint16(7), Options);
	FText FromUint32 = FText::AsNumber(uint32(7), Options);
	FText FromUint64 = FText::AsNumber(uint64(0), Options);
	return FromInt8.ToString().Len() > 0 && FromInt16.ToString().Len() > 0 && FromInt32.ToString().Contains("7") && FromInt64.ToString().Len() > 0 && FromUint8.ToString().Len() > 0 && FromUint16.ToString().Len() > 0 && FromUint32.ToString().Len() > 0 && FromUint64.ToString().Len() > 0;
}
/** @end */
/**
 * @begin as-memory
 * @summary new FText and does not mutate the pattern.
 * @topic Unreal
 */
/**
 * @function ObserveAsMemoryNominal
 * @summary new FText and does not mutate the pattern.
 * @covers FText.as-memory
 * @inputs FText values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAsMemoryNominal()
{
	FText Zero = FText::AsMemory(0);
	FText Kilo = FText::AsMemory(1024);
	return Zero.ToString().Len() > 0 && Kilo.ToString().Len() > 0;
}
/** @end */
/**
 * @begin format-host
 * @summary new FText and does not mutate the pattern.
 * @topic Unreal
 */
/**
 * @function ObserveFormatNominal
 * @summary new FText and does not mutate the pattern.
 * @covers FText.format
 * @inputs FText values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveFormatNominal()
{
	FText Pattern = FText::FromString("{0}");
	FText Formatted = FText::Format(Pattern, 7);
	FText EmptyArg = FText::Format(Pattern, "");
	return Formatted.ToString().Contains("7") && !EmptyArg.ToString().Contains("7");
}
/** @end */
/**
 * @begin FText-ConversionAndFormatting_03-format
 * @summary argument collections leave placeholders unresolved or empty.
 * @topic Unreal
 */
/**
 * @function ObserveFormatNominal
 * @summary argument collections leave placeholders unresolved or empty.
 * @covers FText.format
 * @inputs FText values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveFormatNominal()
{
	FText Two = FText::Format(FText::FromString("{0}-{1}"), "a", 2);
	FText Three = FText::Format(FText::FromString("{0},{1},{2}"), 1, 2, 3);
	FText Four = FText::Format(FText::FromString("{0},{1},{2},{3}"), 1, 2, 3, 4);
	FText Five = FText::Format(FText::FromString("{0},{1},{2},{3},{4}"), 1, 2, 3, 4, 5);

	TMap<FString, FFormatArgumentValue> Named;
	Named.Add("Name", FFormatArgumentValue(FText::FromString("Ada")));
	FText NamedText = FText::Format(FText::FromString("{Name}"), Named);
	TMap<FString, FFormatArgumentValue> EmptyMap;
	FText EmptyNamed = FText::Format(FText::FromString("{Name}"), EmptyMap);

	TArray<FFormatArgumentValue> Ordered;
	Ordered.Add(FFormatArgumentValue(7));
	Ordered.Add(FFormatArgumentValue(8));
	FText OrderedText = FText::Format(FText::FromString("{0}-{1}"), Ordered);

	return Two.ToString().Contains("a") && Three.ToString().Contains("3") && Four.ToString().Contains("4") && Five.ToString().Contains("5") && NamedText.ToString().Contains("Ada") && OrderedText.ToString().Contains("7") && !EmptyNamed.ToString().Contains("Ada");
}
/** @end */
/**
 * @begin identical-to
 * @summary Inputs:
 * @topic Unreal
 */
/**
 * @function ObserveIdenticalToNominal
 * @summary Inputs:
 * @covers FText.identical-to
 * @inputs FText values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs:

 Two FromString("Hello") values, a different "Other", default flags
// and DeepCompare, delimiter ",", argument arrays with two entries and empty.
// Expected observations: Identical copies compare true. Different strings
// compare false. Join of two texts contains both and the delimiter. Empty
// join is empty.
// Boundary/ownership: IdenticalTo compares histories, not just display
// strings, when DeepCompare is requested.
bool ObserveIdenticalToNominal()
{
	FText Left = FText::FromString("Hello");
	FText Right = FText::FromString("Hello");
	FText Copied = Left;
	FText Other = FText::FromString("Other");
	return Copied.IdenticalTo(Left) && Left.ToString() == Right.ToString() && !Left.IdenticalTo(Other) && Copied.IdenticalTo(Left, ETextIdenticalModeFlags::DeepCompare) && !Left.IdenticalTo(Other, ETextIdenticalModeFlags::DeepCompare);
}
/** @end */
/**
 * @begin join-host
 * @summary strings, when DeepCompare is requested.
 * @topic Unreal
 */
/**
 * @function ObserveJoinNominal
 * @summary strings, when DeepCompare is requested.
 * @covers FText.join
 * @inputs FText values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs:

bool ObserveJoinNominal()
{
	FText Delimiter = FText::FromString(",");
	TArray<FText> Texts;
	Texts.Add(FText::FromString("a"));
	Texts.Add(FText::FromString("b"));
	FText JoinedTexts = FText::Join(Delimiter, Texts);
	TArray<FText> EmptyTexts;
	FText EmptyJoined = FText::Join(Delimiter, EmptyTexts);

	TArray<FFormatArgumentValue> Args;
	Args.Add(FFormatArgumentValue(FText::FromString("x")));
	Args.Add(FFormatArgumentValue(7));
	FText JoinedArgs = FText::Join(Delimiter, Args);

	return JoinedTexts.ToString().Contains("a") && JoinedTexts.ToString().Contains(",") && EmptyJoined.IsEmpty() && JoinedArgs.ToString().Len() > 0;
}
/** @end */
/**
 * @begin is-empty-host
 * @summary not mutate the FText.
 * @topic Unreal
 */
/**
 * @function ObserveIsEmptyNominal
 * @summary not mutate the FText.
 * @covers FText.is-empty
 * @inputs FText values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsEmptyNominal()
{
	FText Empty;
	FText Hello = FText::FromString("Hello");
	return Empty.IsEmpty() && !Hello.IsEmpty();
}
/** @end */
/**
 * @begin is-empty-or-whitespace
 * @summary not mutate the FText.
 * @topic Unreal
 */
/**
 * @function ObserveIsEmptyOrWhitespaceNominal
 * @summary not mutate the FText.
 * @covers FText.is-empty-or-whitespace
 * @inputs FText values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsEmptyOrWhitespaceNominal()
{
	FText Empty;
	FText Whitespace = FText::FromString("  ");
	FText Hello = FText::FromString("Hello");
	return Empty.IsEmptyOrWhitespace() && Whitespace.IsEmptyOrWhitespace() && !Hello.IsEmptyOrWhitespace();
}
/** @end */
/**
 * @begin is-transient
 * @summary not mutate the FText.
 * @topic Unreal
 */
/**
 * @function ObserveIsTransientNominal
 * @summary not mutate the FText.
 * @covers FText.is-transient
 * @inputs FText values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsTransientNominal()
{
	FText FromString = FText::FromString("Hello");
	return !FromString.IsTransient();
}
/** @end */
/**
 * @begin is-culture-invariant
 * @summary not mutate the FText.
 * @topic Unreal
 */
/**
 * @function ObserveIsCultureInvariantNominal
 * @summary not mutate the FText.
 * @covers FText.is-culture-invariant
 * @inputs FText values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsCultureInvariantNominal()
{
	FText Invariant = FText::AsCultureInvariant("x");
	FText Localized = NSLOCTEXT("TestSource", "Greeting", "Hello");
	return Invariant.IsCultureInvariant() && !Localized.IsCultureInvariant();
}
/** @end */
/**
 * @begin is-initialized-from-string
 * @summary not mutate the FText.
 * @topic Unreal
 */
/**
 * @function ObserveIsInitializedFromStringNominal
 * @summary not mutate the FText.
 * @covers FText.is-initialized-from-string
 * @inputs FText values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsInitializedFromStringNominal()
{
	FText FromString = FText::FromString("Hello");
	FText Empty;
	return FromString.IsInitializedFromString() && !Empty.IsInitializedFromString();
}
/** @end */
/**
 * @begin is-from-string-table
 * @summary not mutate the FText.
 * @topic Unreal
 */
/**
 * @function ObserveIsFromStringTableNominal
 * @summary not mutate the FText.
 * @covers FText.is-from-string-table
 * @inputs FText values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsFromStringTableNominal()
{
	FText FromString = FText::FromString("Hello");
	return !FromString.IsFromStringTable();
}
/** @end */
/**
 * @begin get-format-pattern-parameters
 * @summary not mutate the FText.
 * @topic Unreal
 */
/**
 * @function ObserveGetFormatPatternParametersNominal
 * @summary not mutate the FText.
 * @covers FText.get-format-pattern-parameters
 * @inputs FText values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetFormatPatternParametersNominal()
{
	FText Pattern = FText::FromString("{Name}");
	TArray<FString> ParameterNames;
	FText::GetFormatPatternParameters(Pattern, ParameterNames);
	TArray<FString> EmptyNames;
	FText::GetFormatPatternParameters(FText::FromString("plain"), EmptyNames);
	return ParameterNames.Num() > 0 && ParameterNames[0] == "Name" && EmptyNames.Num() == 0;
}
/** @end */
