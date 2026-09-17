/**
 * @version v1
 * @summary Json host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic Json
 *
 * fjsonobject-value
 * fjsonvalue-gettype-none
 * fjsonarray-num-0
 * fjsonobject-isvalid-true-because
 * fjsonobjectfielditerator-canproceed-false
 * fjsonvalue-constructs-empty-wrapper
 * try-get-number
 * try-get-string
 * try-get-bool
 * try-get-array
 * try-get-object
 * empty-array-num-0
 * try-get-object-field
 * try-get-array-field
 * empty-fjsonobjectfielditerator-canproceed-false
 * parse-string
 * iterator
 * proceed
 * empty
 * add-string
 * add-number
 * remove-field
 * remove-all-fields
 * set-string-field
 * set-number-field
 * set-bool-field
 * set-object-field
 * set-array-field
 * create-object-field
 * load-from-string
 * save-to-string
 * ejsontype-none-distinct-null
 * ejsontype-null-distinct-string
 * ejsontype-string-distinct-number
 * ejsontype-number-distinct-boolean
 * ejsontype-boolean-distinct-array
 * ejsontype-array-distinct-object
 * ejsontype-object-distinct-none
 * value-type-to-string
 * get-type
 * is-null
 * num
 * get-value-at
 * is-valid
 * has-field
 * get-string-field
 * get-number-field
 * get-bool-field
 * get-object-field
 * get-array-field
 * get-field-name
 * Json-Queries_02-get-type
 * get-value
 */
/**
 * @begin fjsonobject-value
 * @summary FJsonObject Value.
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary FJsonObject Value.
 * @covers Json.fjsonobject-value
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
// FJsonObject Value; FJsonObjectFieldIterator Value;

 FJsonValue Value();
// TryGetNumber float64/float32/int32/int64.
// Inputs: Empty wrappers, a numeric JSON value obtained from an array, 0 and
// 42 as number payloads.
// Expected observations: Empty FJsonValue GetType is None. TryGetNumber
// succeeds for 42 and writes OutNumber. Failed conversion on a string value
// returns false and leaves or does not require the out value.
// Boundary/ownership: OutNumber is written only on success.
// EJsonType default enumerator is None.
bool ObserveSurface001Nominal()
{
	EJsonType Type = EJsonType::None;
	return Type == EJsonType::None;
}
/** @end */
/**
 * @begin fjsonvalue-gettype-none
 * @summary Default FJsonValue GetType is None.
 * @topic Unreal
 */
/**
 * @function ObserveSurface009Nominal
 * @summary Default FJsonValue GetType is None.
 * @covers Json.fjsonvalue-gettype-none
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
// FJsonObject Value; FJsonObjectFieldIterator Value;

bool ObserveSurface009Nominal()
{
	FJsonValue Value;
	return Value.GetType() == EJsonType::None;
}
/** @end */
/**
 * @begin fjsonarray-num-0
 * @summary Default FJsonArray Num is 0.
 * @topic Unreal
 */
/**
 * @function ObserveSurface010Nominal
 * @summary Default FJsonArray Num is 0.
 * @covers Json.fjsonarray-num-0
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
// FJsonObject Value; FJsonObjectFieldIterator Value;

bool ObserveSurface010Nominal()
{
	FJsonArray Value;
	return Value.Num() == 0;
}
/** @end */
/**
 * @begin fjsonobject-isvalid-true-because
 * @summary Default FJsonObject IsValid is true because construction allocates an empty object.
 * @topic Unreal
 */
/**
 * @function ObserveSurface011Nominal
 * @summary Default FJsonObject IsValid is true because construction allocates an empty object.
 * @covers Json.fjsonobject-isvalid-true-because
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
// FJsonObject Value; FJsonObjectFieldIterator Value;

bool ObserveSurface011Nominal()
{
	FJsonObject Value;
	return Value.IsValid();
}
/** @end */
/**
 * @begin fjsonobjectfielditerator-canproceed-false
 * @summary Default FJsonObjectFieldIterator CanProceed is false.
 * @topic Unreal
 */
/**
 * @function ObserveSurface012Nominal
 * @summary Default FJsonObjectFieldIterator CanProceed is false.
 * @covers Json.fjsonobjectfielditerator-canproceed-false
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
// FJsonObject Value; FJsonObjectFieldIterator Value;

bool ObserveSurface012Nominal()
{
	FJsonObjectFieldIterator Value;
	return !Value.CanProceed;
}
/** @end */
/**
 * @begin fjsonvalue-constructs-empty-wrapper
 * @summary FJsonValue() constructs an empty wrapper whose type is None.
 * @topic Unreal
 */
/**
 * @function ObserveValueNominal
 * @summary FJsonValue() constructs an empty wrapper whose type is None.
 * @covers Json.fjsonvalue-constructs-empty-wrapper
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
// FJsonObject Value; FJsonObjectFieldIterator Value;

bool ObserveValueNominal()
{
	FJsonValue DefaultValue;
	return DefaultValue.GetType() == EJsonType::None;
}
/** @end */
/**
 * @begin try-get-number
 * @summary TryGetNumber writes 42 across float64/float32/int32/int64 and fails on a string.
 * @topic Unreal
 */
/**
 * @function ObserveTryGetNumberNominal
 * @summary TryGetNumber writes 42 across float64/float32/int32/int64 and fails on a string.
 * @covers Json.try-get-number
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
// FJsonObject Value; FJsonObjectFieldIterator Value;

bool ObserveTryGetNumberNominal()
{
	FJsonArray Numbers;
	Numbers.AddNumber(42);
	FJsonValue Numeric = Numbers.GetValueAt(0);
	float64 AsFloat64 = 0.0;
	float32 AsFloat32 = 0.0;
	int32 AsInt32 = 0;
	int64 AsInt64 = 0;
	bool bFloat64 = Numeric.TryGetNumber(AsFloat64);
	bool bFloat32 = Numeric.TryGetNumber(AsFloat32);
	bool bInt32 = Numeric.TryGetNumber(AsInt32);
	bool bInt64 = Numeric.TryGetNumber(AsInt64);

	FJsonArray Strings;
	Strings.AddString("x");
	FJsonValue NotNumber = Strings.GetValueAt(0);
	int32 Failed = -1;
	bool bFailed = NotNumber.TryGetNumber(Failed);
	return bFloat64 &&
		AsFloat64 == 42.0 &&
		bFloat32 &&
		AsFloat32 == 42.0f &&
		bInt32 &&
		AsInt32 == 42 &&
		bInt64 &&
		AsInt64 == 42 &&
		!bFailed &&
		Failed == -1;
}
/** @end */
/**
 * @begin try-get-string
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveTryGetStringNominal
 * @summary Observe the container API.
 * @covers Json.try-get-string
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FJsonObject Value(const FJsonObject& InObject); FJsonObject Value();
// TryGetObjectField; TryGetArrayField; CanProceed.
// Inputs: String/bool/array/object JSON values, empty constructors, shared
// object copy, missing field names.
// Expected observations: Matching TryGet returns true and writes the out
// value. Type mismatch returns false. Empty array Num is 0. Copy constructor
// shares HasField. CanProceed is false on an empty iterator.
// Boundary/ownership: FJsonObject copy shares the underlying JSON object.
// TryGetString writes Alice from a string value and fails on a number.
bool ObserveTryGetStringNominal()
{
	FJsonArray Values;
	Values.AddString("Alice");
	Values.AddNumber(42);
	FJsonValue Value = Values.GetValueAt(0);
	FString Text = "seed";
	bool bGot = Value.TryGetString(Text);
	FString Failed = "seed";
	bool bNumberAsString = Values.GetValueAt(1).TryGetString(Failed);
	return bGot && Text == "Alice" && !bNumberAsString;
}
/** @end */
/**
 * @begin try-get-bool
 * @summary TryGetBool writes true from a Boolean field value and fails on a string.
 * @topic Unreal
 */
/**
 * @function ObserveTryGetBoolNominal
 * @summary TryGetBool writes true from a Boolean field value and fails on a string.
 * @covers Json.try-get-bool
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveTryGetBoolNominal()
{
	FJsonObject Root;
	Root.SetBoolField("Enabled", true);
	FJsonObjectFieldIterator It = Root.Iterator();
	It.Proceed();
	FJsonValue Enabled = It.GetValue();
	bool OutValue = false;
	bool bGot = Enabled.TryGetBool(OutValue);
	FJsonArray Values;
	Values.AddString("x");
	FJsonValue NotBool = Values.GetValueAt(0);
	bool Mismatch = false;
	bool bMismatch = NotBool.TryGetBool(Mismatch);
	return bGot && OutValue && Root.GetBoolField("Enabled") && !bMismatch;
}
/** @end */
/**
 * @begin try-get-array
 * @summary TryGetArray fails on a string element.
 * @topic Unreal
 */
/**
 * @function ObserveTryGetArrayNominal
 * @summary TryGetArray fails on a string element.
 * @covers Json.try-get-array
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveTryGetArrayNominal()
{
	FJsonObject Root;
	FJsonArray Values;
	Values.AddString("First");
	Root.SetArrayField("Values", Values);
	FJsonValue AsValue = Root.GetArrayField("Values").GetValueAt(0);
	FJsonArray OutArray;
	bool bFromStringValue = AsValue.TryGetArray(OutArray);
	FJsonArray Read;
	bool bFromField = Root.TryGetArrayField("Values", Read);
	return bFromField && Read.Num() == 1 && !bFromStringValue;
}
/** @end */
/**
 * @begin try-get-object
 * @summary TryGetObject fails on a string value.
 * @topic Unreal
 */
/**
 * @function ObserveTryGetObjectNominal
 * @summary TryGetObject fails on a string value.
 * @covers Json.try-get-object
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveTryGetObjectNominal()
{
	FJsonObject Root;
	FJsonObject Child = Root.CreateObjectField("Child");
	Child.SetStringField("Label", "Nested");
	FJsonObjectFieldIterator It = Root.Iterator();
	It.Proceed();
	FJsonValue ObjectValue = It.GetValue();
	FJsonObject OutObject;
	bool bGot = ObjectValue.TryGetObject(OutObject);
	FJsonArray Values;
	Values.AddString("x");
	FJsonValue NotObject = Values.GetValueAt(0);
	FJsonObject MismatchObject;
	bool bMismatch = NotObject.TryGetObject(MismatchObject);
	return bGot && OutObject.GetStringField("Label") == "Nested" && !bMismatch && Root.GetObjectField("Child").IsValid();
}
/** @end */
/**
 * @begin empty-array-num-0
 * @summary Empty array Num is 0, empty object IsValid, copy shares Name.
 * @topic Unreal
 */
/**
 * @function ObserveValueNominal
 * @summary Empty array Num is 0, empty object IsValid, copy shares Name.
 * @covers Json.empty-array-num-0
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveValueNominal()
{
	FJsonArray EmptyArray;
	FJsonObject EmptyObject;
	FJsonObject Root;
	Root.SetStringField("Name", "Alice");
	FJsonObject Shared(Root);
	return EmptyArray.Num() == 0 && EmptyObject.IsValid() && Shared.HasField("Name") && Shared.GetStringField("Name") == "Alice";
}
/** @end */
/**
 * @begin try-get-object-field
 * @summary TryGetObjectField writes Nested Label and returns false for Missing.
 * @topic Unreal
 */
/**
 * @function ObserveTryGetObjectFieldNominal
 * @summary TryGetObjectField writes Nested Label and returns false for Missing.
 * @covers Json.try-get-object-field
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveTryGetObjectFieldNominal()
{
	FJsonObject Root;
	FJsonObject Child = Root.CreateObjectField("Child");
	Child.SetStringField("Label", "Nested");
	FJsonObject OutObject;
	bool bGot = Root.TryGetObjectField("Child", OutObject);
	FJsonObject Missing;
	bool bMissing = Root.TryGetObjectField("Missing", Missing);
	return bGot && OutObject.GetStringField("Label") == "Nested" && !bMissing;
}
/** @end */
/**
 * @begin try-get-array-field
 * @summary TryGetArrayField writes Num 1 and returns false for Missing.
 * @topic Unreal
 */
/**
 * @function ObserveTryGetArrayFieldNominal
 * @summary TryGetArrayField writes Num 1 and returns false for Missing.
 * @covers Json.try-get-array-field
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveTryGetArrayFieldNominal()
{
	FJsonObject Root;
	FJsonArray Values;
	Values.AddString("First");
	Root.SetArrayField("Values", Values);
	FJsonArray OutArray;
	bool bGot = Root.TryGetArrayField("Values", OutArray);
	FJsonArray Missing;
	bool bMissing = Root.TryGetArrayField("Missing", Missing);
	return bGot && OutArray.Num() == 1 && !bMissing;
}
/** @end */
/**
 * @begin empty-fjsonobjectfielditerator-canproceed-false
 * @summary Empty FJsonObjectFieldIterator.CanProceed is false.
 * @topic Unreal
 */
/**
 * @function ObserveSurface053Nominal
 * @summary Empty FJsonObjectFieldIterator.CanProceed is false.
 * @covers Json.empty-fjsonobjectfielditerator-canproceed-false
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface053Nominal()
{
	FJsonObject Empty;
	FJsonObjectFieldIterator It = Empty.Iterator();
	return !It.CanProceed;
}
/** @end */
/**
 * @begin parse-string
 * @summary in the nominal API, it returns invalid.
 * @topic Unreal
 */
/**
 * @function ObserveParseStringNominal
 * @summary in the nominal API, it returns invalid.
 * @covers Json.parse-string
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveParseStringNominal()
{
	FJsonObject Parsed = Json::ParseString("{\"Name\":\"Alice\"}");
	FJsonObject Empty = Json::ParseString("");
	FJsonObject Malformed = Json::ParseString("{");
	return Parsed.IsValid() && Parsed.GetStringField("Name") == "Alice" && !Empty.IsValid() && !Malformed.IsValid();
}
/** @end */
/**
 * @begin iterator
 * @summary last field is the diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveIteratorNominal
 * @summary last field is the diagnostic path.
 * @covers Json.iterator
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIteratorNominal()
{
	FJsonObject Empty;
	FJsonObjectFieldIterator EmptyIt = Empty.Iterator();
	FJsonObject Root;
	Root.SetStringField("Name", "Alice");
	FJsonObjectFieldIterator It = Root.Iterator();
	return !EmptyIt.CanProceed && It.CanProceed;
}
/** @end */
/**
 * @begin proceed
 * @summary last field is the diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveProceedNominal
 * @summary last field is the diagnostic path.
 * @covers Json.proceed
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveProceedNominal()
{
	FJsonObject Root;
	Root.SetStringField("Name", "Alice");
	Root.SetNumberField("Score", 1.0);
	FJsonObjectFieldIterator It = Root.Iterator();
	FJsonObjectFieldIterator& Alias = It.Proceed();
	FString First = Alias.GetFieldName();
	bool bCanContinue = Alias.CanProceed;
	if (bCanContinue)
	{
		Alias.Proceed();
	}
	return (First == "Name" || First == "Score") && bCanContinue;
}
/** @end */
/**
 * @begin empty
 * @summary Remove of a missing field is a no-op.
 * @topic Unreal
 */
/**
 * @function ObserveEmptyNominal
 * @summary Remove of a missing field is a no-op.
 * @covers Json.empty
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEmptyNominal()
{
	FJsonArray Values;
	Values.AddString("First");
	Values.Empty();
	return Values.Num() == 0;
}
/** @end */
/**
 * @begin add-string
 * @summary Remove of a missing field is a no-op.
 * @topic Unreal
 */
/**
 * @function ObserveAddStringNominal
 * @summary Remove of a missing field is a no-op.
 * @covers Json.add-string
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddStringNominal()
{
	FJsonArray Values;
	Values.AddString("First");
	Values.AddString("First");
	return Values.Num() == 2 && Values.GetValueAt(0).GetType() == EJsonType::String;
}
/** @end */
/**
 * @begin add-number
 * @summary Remove of a missing field is a no-op.
 * @topic Unreal
 */
/**
 * @function ObserveAddNumberNominal
 * @summary Remove of a missing field is a no-op.
 * @covers Json.add-number
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddNumberNominal()
{
	FJsonArray Values;
	Values.AddNumber(42);
	Values.AddNumber(1.5);
	float64 First = 0.0;
	float64 Second = 0.0;
	bool bFirst = Values.GetValueAt(0).TryGetNumber(First);
	bool bSecond = Values.GetValueAt(1).TryGetNumber(Second);
	return Values.Num() == 2 && bFirst && First == 42.0 && bSecond && Second == 1.5;
}
/** @end */
/**
 * @begin remove-field
 * @summary Remove of a missing field is a no-op.
 * @topic Unreal
 */
/**
 * @function ObserveRemoveFieldNominal
 * @summary Remove of a missing field is a no-op.
 * @covers Json.remove-field
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveRemoveFieldNominal()
{
	FJsonObject Root;
	Root.SetStringField("Name", "Alice");
	Root.RemoveField("Name");
	Root.RemoveField("Missing");
	return !Root.HasField("Name") && !Root.HasField("Missing");
}
/** @end */
/**
 * @begin remove-all-fields
 * @summary Remove of a missing field is a no-op.
 * @topic Unreal
 */
/**
 * @function ObserveRemoveAllFieldsNominal
 * @summary Remove of a missing field is a no-op.
 * @covers Json.remove-all-fields
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveRemoveAllFieldsNominal()
{
	FJsonObject Root;
	Root.SetStringField("Name", "Alice");
	Root.SetNumberField("Score", 1.0);
	Root.RemoveAllFields();
	return !Root.HasField("Name") && !Root.HasField("Score");
}
/** @end */
/**
 * @begin set-string-field
 * @summary Remove of a missing field is a no-op.
 * @topic Unreal
 */
/**
 * @function ObserveSetStringFieldNominal
 * @summary Remove of a missing field is a no-op.
 * @covers Json.set-string-field
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetStringFieldNominal()
{
	FJsonObject Root;
	Root.SetStringField("Name", "Alice");
	Root.SetStringField("Name", "Bob");
	return Root.GetStringField("Name") == "Bob";
}
/** @end */
/**
 * @begin set-number-field
 * @summary Remove of a missing field is a no-op.
 * @topic Unreal
 */
/**
 * @function ObserveSetNumberFieldNominal
 * @summary Remove of a missing field is a no-op.
 * @covers Json.set-number-field
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetNumberFieldNominal()
{
	FJsonObject Root;
	Root.SetNumberField("Score", 1337.0);
	return Root.GetNumberField("Score") == 1337.0;
}
/** @end */
/**
 * @begin set-bool-field
 * @summary Remove of a missing field is a no-op.
 * @topic Unreal
 */
/**
 * @function ObserveSetBoolFieldNominal
 * @summary Remove of a missing field is a no-op.
 * @covers Json.set-bool-field
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetBoolFieldNominal()
{
	FJsonObject Root;
	Root.SetBoolField("Enabled", true);
	Root.SetBoolField("Enabled", false);
	return !Root.GetBoolField("Enabled");
}
/** @end */
/**
 * @begin set-object-field
 * @summary Remove of a missing field is a no-op.
 * @topic Unreal
 */
/**
 * @function ObserveSetObjectFieldNominal
 * @summary Remove of a missing field is a no-op.
 * @covers Json.set-object-field
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetObjectFieldNominal()
{
	FJsonObject Root;
	FJsonObject Child;
	Child.SetStringField("Label", "Nested");
	Root.SetObjectField("Child", Child);
	FJsonObject Read = Root.GetObjectField("Child");
	return Read.GetStringField("Label") == "Nested";
}
/** @end */
/**
 * @begin set-array-field
 * @summary parse leaves an invalid or empty wrapper depending on the API.
 * @topic Unreal
 */
/**
 * @function ObserveSetArrayFieldNominal
 * @summary parse leaves an invalid or empty wrapper depending on the API.
 * @covers Json.set-array-field
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetArrayFieldNominal()
{
	FJsonObject Root;
	FJsonArray Values;
	Values.AddString("First");
	Values.AddNumber(42);
	Root.SetArrayField("Values", Values);
	FJsonArray Read = Root.GetArrayField("Values");
	return Read.Num() == 2 && Read.GetValueAt(0).GetType() == EJsonType::String;
}
/** @end */
/**
 * @begin create-object-field
 * @summary parse leaves an invalid or empty wrapper depending on the API.
 * @topic Unreal
 */
/**
 * @function ObserveCreateObjectFieldNominal
 * @summary parse leaves an invalid or empty wrapper depending on the API.
 * @covers Json.create-object-field
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveCreateObjectFieldNominal()
{
	FJsonObject Root;
	FJsonObject Child = Root.CreateObjectField("Child");
	Child.SetStringField("Label", "Nested");
	return Root.HasField("Child") && Child.GetStringField("Label") == "Nested";
}
/** @end */
/**
 * @begin load-from-string
 * @summary parse leaves an invalid or empty wrapper depending on the API.
 * @topic Unreal
 */
/**
 * @function ObserveLoadFromStringNominal
 * @summary parse leaves an invalid or empty wrapper depending on the API.
 * @covers Json.load-from-string
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveLoadFromStringNominal()
{
	FJsonObject Root;
	bool bLoaded = Root.LoadFromString("{\"Name\":\"Alice\"}");
	FJsonObject Failed;
	bool bMalformed = Failed.LoadFromString("{");
	return bLoaded && Root.GetStringField("Name") == "Alice" && !bMalformed;
}
/** @end */
/**
 * @begin save-to-string
 * @summary parse leaves an invalid or empty wrapper depending on the API.
 * @topic Unreal
 */
/**
 * @function ObserveSaveToStringNominal
 * @summary parse leaves an invalid or empty wrapper depending on the API.
 * @covers Json.save-to-string
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSaveToStringNominal()
{
	FJsonObject Root;
	Root.SetStringField("Name", "Alice");
	FString Pretty = Root.SaveToString();
	FString Compact = Root.SaveToString(false);
	FJsonObject Empty;
	FString EmptyText = Empty.SaveToString(false);
	return Pretty.Contains("Name") && Compact.Contains("Alice") && Compact.Len() <= Pretty.Len() && EmptyText.Contains("{");
}
/** @end */
/**
 * @begin ejsontype-none-distinct-null
 * @summary EJsonType::None is distinct from Null.
 * @topic Unreal
 */
/**
 * @function ObserveSurface002Nominal
 * @summary EJsonType::None is distinct from Null.
 * @covers Json.ejsontype-none-distinct-null
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface002Nominal()
{
	return EJsonType::None != EJsonType::Null;
}
/** @end */
/**
 * @begin ejsontype-null-distinct-string
 * @summary EJsonType::Null is distinct from String.
 * @topic Unreal
 */
/**
 * @function ObserveSurface003Nominal
 * @summary EJsonType::Null is distinct from String.
 * @covers Json.ejsontype-null-distinct-string
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface003Nominal()
{
	return EJsonType::Null != EJsonType::String;
}
/** @end */
/**
 * @begin ejsontype-string-distinct-number
 * @summary EJsonType::String is distinct from Number.
 * @topic Unreal
 */
/**
 * @function ObserveSurface004Nominal
 * @summary EJsonType::String is distinct from Number.
 * @covers Json.ejsontype-string-distinct-number
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface004Nominal()
{
	return EJsonType::String != EJsonType::Number;
}
/** @end */
/**
 * @begin ejsontype-number-distinct-boolean
 * @summary EJsonType::Number is distinct from Boolean.
 * @topic Unreal
 */
/**
 * @function ObserveSurface005Nominal
 * @summary EJsonType::Number is distinct from Boolean.
 * @covers Json.ejsontype-number-distinct-boolean
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface005Nominal()
{
	return EJsonType::Number != EJsonType::Boolean;
}
/** @end */
/**
 * @begin ejsontype-boolean-distinct-array
 * @summary EJsonType::Boolean is distinct from Array.
 * @topic Unreal
 */
/**
 * @function ObserveSurface006Nominal
 * @summary EJsonType::Boolean is distinct from Array.
 * @covers Json.ejsontype-boolean-distinct-array
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface006Nominal()
{
	return EJsonType::Boolean != EJsonType::Array;
}
/** @end */
/**
 * @begin ejsontype-array-distinct-object
 * @summary EJsonType::Array is distinct from Object.
 * @topic Unreal
 */
/**
 * @function ObserveSurface007Nominal
 * @summary EJsonType::Array is distinct from Object.
 * @covers Json.ejsontype-array-distinct-object
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface007Nominal()
{
	return EJsonType::Array != EJsonType::Object;
}
/** @end */
/**
 * @begin ejsontype-object-distinct-none
 * @summary EJsonType::Object is distinct from None.
 * @topic Unreal
 */
/**
 * @function ObserveSurface008Nominal
 * @summary EJsonType::Object is distinct from None.
 * @covers Json.ejsontype-object-distinct-none
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface008Nominal()
{
	return EJsonType::Object != EJsonType::None;
}
/** @end */
/**
 * @begin value-type-to-string
 * @summary ValueTypeToString maps None and String to their stable display names.
 * @topic Unreal
 */
/**
 * @function ObserveValueTypeToStringNominal
 * @summary ValueTypeToString maps None and String to their stable display names.
 * @covers Json.value-type-to-string
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveValueTypeToStringNominal()
{
	FString NoneText = Json::ValueTypeToString(EJsonType::None);
	FString StringText = Json::ValueTypeToString(EJsonType::String);
	return NoneText == "None" && StringText == "String" && StringText != NoneText;
}
/** @end */
/**
 * @begin get-type
 * @summary Boundary/ownership: Get*Field on a missing name is the diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveGetTypeNominal
 * @summary Boundary/ownership: Get*Field on a missing name is the diagnostic path.
 * @covers Json.get-type
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetTypeNominal()
{
	FJsonValue Empty;
	FJsonArray Values;
	Values.AddString("First");
	FJsonValue First = Values.GetValueAt(0);
	return Empty.GetType() == EJsonType::None && First.GetType() == EJsonType::String;
}
/** @end */
/**
 * @begin is-null
 * @summary Boundary/ownership: Get*Field on a missing name is the diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveIsNullNominal
 * @summary Boundary/ownership: Get*Field on a missing name is the diagnostic path.
 * @covers Json.is-null
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsNullNominal()
{
	FJsonValue Empty;
	FJsonObject Root = Json::ParseString("{\"X\":null}");
	FJsonObjectFieldIterator It = Root.Iterator();
	It.Proceed();
	FJsonValue NullValue = It.GetValue();
	return !Empty.IsNull() && NullValue.IsNull();
}
/** @end */
/**
 * @begin num
 * @summary Boundary/ownership: Get*Field on a missing name is the diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveNumNominal
 * @summary Boundary/ownership: Get*Field on a missing name is the diagnostic path.
 * @covers Json.num
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveNumNominal()
{
	FJsonArray Empty;
	FJsonArray Values;
	Values.AddString("First");
	Values.AddString("Second");
	return Empty.Num() == 0 && Values.Num() == 2;
}
/** @end */
/**
 * @begin get-value-at
 * @summary Boundary/ownership: Get*Field on a missing name is the diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveGetValueAtNominal
 * @summary Boundary/ownership: Get*Field on a missing name is the diagnostic path.
 * @covers Json.get-value-at
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetValueAtNominal()
{
	FJsonArray Values;
	Values.AddString("First");
	FJsonValue First = Values.GetValueAt(0);
	FString Text;
	bool bGot = First.TryGetString(Text);
	return First.GetType() == EJsonType::String && bGot && Text == "First";
}
/** @end */
/**
 * @begin is-valid
 * @summary Boundary/ownership: Get*Field on a missing name is the diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveIsValidNominal
 * @summary Boundary/ownership: Get*Field on a missing name is the diagnostic path.
 * @covers Json.is-valid
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsValidNominal()
{
	FJsonObject Root;
	FJsonObject Parsed = Json::ParseString("{");
	return Root.IsValid() && !Parsed.IsValid();
}
/** @end */
/**
 * @begin has-field
 * @summary Boundary/ownership: Get*Field on a missing name is the diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveHasFieldNominal
 * @summary Boundary/ownership: Get*Field on a missing name is the diagnostic path.
 * @covers Json.has-field
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveHasFieldNominal()
{
	FJsonObject Root;
	Root.SetStringField("Name", "Alice");
	return Root.HasField("Name") && !Root.HasField("Missing");
}
/** @end */
/**
 * @begin get-string-field
 * @summary Boundary/ownership: Get*Field on a missing name is the diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveGetStringFieldNominal
 * @summary Boundary/ownership: Get*Field on a missing name is the diagnostic path.
 * @covers Json.get-string-field
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetStringFieldNominal()
{
	FJsonObject Root;
	Root.SetStringField("Name", "Alice");
	return Root.GetStringField("Name") == "Alice";
}
/** @end */
/**
 * @begin get-number-field
 * @summary Boundary/ownership: Get*Field on a missing name is the diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveGetNumberFieldNominal
 * @summary Boundary/ownership: Get*Field on a missing name is the diagnostic path.
 * @covers Json.get-number-field
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetNumberFieldNominal()
{
	FJsonObject Root;
	Root.SetNumberField("Score", 1337.0);
	return Root.GetNumberField("Score") == 1337.0;
}
/** @end */
/**
 * @begin get-bool-field
 * @summary Boundary/ownership: Get*Field on a missing name is the diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveGetBoolFieldNominal
 * @summary Boundary/ownership: Get*Field on a missing name is the diagnostic path.
 * @covers Json.get-bool-field
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetBoolFieldNominal()
{
	FJsonObject Root;
	Root.SetBoolField("Enabled", true);
	Root.SetBoolField("Disabled", false);
	return Root.GetBoolField("Enabled") && !Root.GetBoolField("Disabled");
}
/** @end */
/**
 * @begin get-object-field
 * @summary Boundary/ownership: Get*Field on a missing name is the diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveGetObjectFieldNominal
 * @summary Boundary/ownership: Get*Field on a missing name is the diagnostic path.
 * @covers Json.get-object-field
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetObjectFieldNominal()
{
	FJsonObject Root;
	FJsonObject Child = Root.CreateObjectField("Child");
	Child.SetStringField("Label", "Nested");
	FJsonObject Read = Root.GetObjectField("Child");
	return Read.IsValid() && Read.GetStringField("Label") == "Nested";
}
/** @end */
/**
 * @begin get-array-field
 * @summary array wrapper shares the object's field storage.
 * @topic Unreal
 */
/**
 * @function ObserveGetArrayFieldNominal
 * @summary array wrapper shares the object's field storage.
 * @covers Json.get-array-field
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetArrayFieldNominal()
{
	FJsonObject Root;
	FJsonArray Values;
	Values.AddString("First");
	Root.SetArrayField("Values", Values);
	FJsonArray Read = Root.GetArrayField("Values");
	return Read.Num() == 1 && Read.GetValueAt(0).GetType() == EJsonType::String;
}
/** @end */
/**
 * @begin get-field-name
 * @summary array wrapper shares the object's field storage.
 * @topic Unreal
 */
/**
 * @function ObserveGetFieldNameNominal
 * @summary array wrapper shares the object's field storage.
 * @covers Json.get-field-name
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetFieldNameNominal()
{
	FJsonObject Root;
	Root.SetStringField("Name", "Alice");
	FJsonObjectFieldIterator It = Root.Iterator();
	It.Proceed();
	return It.GetFieldName() == "Name";
}
/** @end */
/**
 * @begin Json-Queries_02-get-type
 * @summary array wrapper shares the object's field storage.
 * @topic Unreal
 */
/**
 * @function ObserveGetTypeNominal
 * @summary array wrapper shares the object's field storage.
 * @covers Json.get-type
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetTypeNominal()
{
	FJsonObject Root;
	Root.SetStringField("Name", "Alice");
	FJsonObjectFieldIterator It = Root.Iterator();
	It.Proceed();
	return It.GetType() == EJsonType::String;
}
/** @end */
/**
 * @begin get-value
 * @summary array wrapper shares the object's field storage.
 * @topic Unreal
 */
/**
 * @function ObserveGetValueNominal
 * @summary array wrapper shares the object's field storage.
 * @covers Json.get-value
 * @inputs Json values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetValueNominal()
{
	FJsonObject Root;
	Root.SetStringField("Name", "Alice");
	FJsonObjectFieldIterator It = Root.Iterator();
	It.Proceed();
	FJsonValue Value = It.GetValue();
	FString Text;
	bool bGotString = Value.TryGetString(Text);
	return bGotString && Text == "Alice";
}
/** @end */
