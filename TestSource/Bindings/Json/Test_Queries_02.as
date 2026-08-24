// Purpose: Observe array-field lookup and iterator field name/type/value
// after Proceed. Each function returns the exact comparison.
// AS-facing API: FJsonArray FJsonObject.GetArrayField(const FString& FieldName) const;
// FString FJsonObjectFieldIterator.GetFieldName() const;
// EJsonType FJsonObjectFieldIterator.GetType() const;
// FJsonValue FJsonObjectFieldIterator.GetValue() const;
// Inputs: Object with Values array of "First", iterator over Name=Alice.
// Expected observations: GetArrayField Num is 1. After Proceed, field name
// is Name, type is String, and TryGetString yields Alice.
// Boundary/ownership: Iterator getters are valid only after Proceed. The
// array wrapper shares the object's field storage.

namespace TS_Json_Queries_02
{
	bool Observe_GetArrayField_Nominal()
	{
		FJsonObject Root;
		FJsonArray Values;
		Values.AddString("First");
		Root.SetArrayField("Values", Values);
		FJsonArray Read = Root.GetArrayField("Values");
		return Read.Num() == 1 && Read.GetValueAt(0).GetType() == EJsonType::String;
	}

	bool Observe_GetFieldName_Nominal()
	{
		FJsonObject Root;
		Root.SetStringField("Name", "Alice");
		FJsonObjectFieldIterator It = Root.Iterator();
		It.Proceed();
		return It.GetFieldName() == "Name";
	}

	bool Observe_GetType_Nominal()
	{
		FJsonObject Root;
		Root.SetStringField("Name", "Alice");
		FJsonObjectFieldIterator It = Root.Iterator();
		It.Proceed();
		return It.GetType() == EJsonType::String;
	}

	bool Observe_GetValue_Nominal()
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
}
