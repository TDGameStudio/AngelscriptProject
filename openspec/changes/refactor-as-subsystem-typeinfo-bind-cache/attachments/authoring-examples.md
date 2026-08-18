# Authoring examples

Illustrative contract for `refactor-as-subsystem-typeinfo-bind-cache`. Not compiled C++.

Source of truth for *what* to bind: current `Bind_*.cpp`. This file shows *how* that looks after TypeBindInfo.

**One type, one Register function.** Type declaration, adapter, ToString, constructors, methods, properties, constants — all in the same named function. `EJsonType` is not a second callback. `TArray.Add` is not a second callback.

**`EAngelscriptBindPhase` is deleted for migrated authoring.** Today's seven values exist only because each lambda immediately calls `asIScriptEngine::RegisterObjectType` / `RegisterObjectMethod`. After this change that order is **metadata on the recorded member** (`EApplySlot`), not a schedule that splits Register functions. Unmigrated `FAngelscriptBind` may still carry a Phase until that file migrates; then the enum goes away.

v1 may wrap an old lambda with a recorder. The **target** authoring form is section 1: one `FAngelscriptBind` per type family, one Register function that records everything. Do not introduce `FAngelscriptTypeBindInfoProvider`.

## What replaces the seven phases

| Today (`EAngelscriptBindPhase`) — execution schedule | After — metadata, not a second Register function |
|---|---|
| `TypeDeclarations` | `EApplySlot::Type` on that member |
| `TypeInfrastructure` | `EApplySlot::Infrastructure` (adapter, ToString, **template methods**) |
| `ExplicitBindings` | `EApplySlot::Members` |
| `GeneratedBindings` | provider `RegisterKind=Generated` (UHT walk — needs generated modules) |
| `ReflectionBindings` | provider `RegisterKind=Reflection` (needs live `UClass`) |
| `PostReflectionBindings` | provider `RegisterKind=PostReflection` (patches rows Reflection already created) |
| `Finalization` | validate after expand; not a bind-file Phase |

`RegisterKind` is **when this Register function is allowed to run** (compile-known vs needs `UClass` vs patch after rows exist). It is **not** type-vs-method. Apply still walks `EApplySlot`.

Storage is still **one row per type name**. Apply walks all `Type` slots, then `Infrastructure`, then `Members`.

```text
TypeBindInfos["FVector"]
  Kind = Value
  Flags = POD | BASICMATHTYPE
  AdapterRecipe = FVectorType
  Members:
    { TypeDecl,    ApplySlot=Type }
    { Adapter,     ApplySlot=Infrastructure }
    { ToString,    ApplySlot=Infrastructure }
    { TypeFinder,  ApplySlot=Infrastructure }
    { Constructor, ApplySlot=Members }
    { Property X,  ApplySlot=Members }
    { Method Size, ApplySlot=Members }
    { Constant ZeroVector, ApplySlot=Members }
```

`TArray.Add` is tagged `ApplySlot=Infrastructure` so Apply still registers it before other types' methods. That is a tag, not a second Register function.

---

## 1. `FVector` — one Register function, one row (from `Bind_FVector.cpp`)

Today's four `FAngelscriptBind` objects (`TypeDeclarations`, `TypeInfrastructure`, `ExplicitBindings`, `ToStringContribution`) become one `RegisterFVector`. Helper thunks (`FAngelscriptFVectorBinds`) and `FVectorType` stay. The file-level signature comment table is unchanged.

DSL infers `EApplySlot`: `Value` → Type; `Adapter` / `ToString` / `TypeFinder` → Infrastructure; constructors, methods, properties, constants → Members.

```cpp
static void RegisterFVector(FAngelscriptTypeBindInfoStore& Store)
{
	FAngelscriptTypeBindInfo& FVector_ = Store.Value<FVector>("FVector")
		.POD()
		.ExtraObjectFlags(asOBJ_BASICMATHTYPE);

	FVector_.Adapter<FVectorType>();
	FVector_.ToString(&FAngelscriptFVectorBinds::AppendToString);
	FVector_.TypeFinder([](FProperty* Property, FAngelscriptTypeUsage& Usage) -> bool
	{
		FStructProperty* StructProp = CastField<FStructProperty>(Property);
		if (StructProp == nullptr)
		{
			return false;
		}

		if (StructProp->Struct == FVector_NetQuantize::StaticStruct()
			|| StructProp->Struct == FVector_NetQuantize10::StaticStruct()
			|| StructProp->Struct == FVector_NetQuantize100::StaticStruct()
			|| StructProp->Struct == FVector_NetQuantizeNormal::StaticStruct())
		{
			Usage.TypeName = TEXT("FVector");
			return true;
		}

		return false;
	});

	FVector_.Constructor("void f(float64 X, float64 Y, float64 Z)",
			&FAngelscriptFVectorBinds::ConstructXYZ, "FVector", true)
		.NoDiscard();
	FVector_.Constructor("void f()", &FAngelscriptFVectorBinds::ConstructZero)
		.NoDiscard()
		.NativeConstructor("FVector", true, "0.f");
	FVector_.Constructor("void f(float64 F)",
			&FAngelscriptFVectorBinds::ConstructScalar, "FVector", true)
		.NoDiscard();
	FVector_.Constructor("void f(const FVector& Other)",
			&FAngelscriptFVectorBinds::ConstructCopy, "FVector", true)
		.NoDiscard();
	FVector_.Constructor("void f(const FVector3f& Other)",
			&FAngelscriptFVectorBinds::ConstructFromVector3f, "FVector", true)
		.NoDiscard();

	FVector_.Property("float64 X", &FVector::X);
	FVector_.Property("float64 Y", &FVector::Y);
	FVector_.Property("float64 Z", &FVector::Z);

	FVector_.Method("FVector& opAssign(const FVector& Other)",
		METHODPR_TRIVIAL(FVector&, FVector, operator=, (const FVector&)));
	FVector_.Method("FVector opAdd(const FVector& Other) const",
		METHODPR_TRIVIAL(FVector, FVector, operator+, (const FVector&) const));
	FVector_.Method("FVector opSub(const FVector& Other) const",
		METHODPR_TRIVIAL(FVector, FVector, operator-, (const FVector&) const));
	FVector_.Method("FVector opMul(const FVector& Other) const",
		METHODPR_TRIVIAL(FVector, FVector, operator*, (const FVector&) const));
	FVector_.Method("FVector opDiv(const FVector& Other) const",
		METHODPR_TRIVIAL(FVector, FVector, operator/, (const FVector&) const));
	FVector_.Method("FVector opMul(float64 Scale) const",
		METHODPR_TRIVIAL(FVector, FVector, operator*, (double) const));
	FVector_.Method("FVector opDiv(float64 Scale) const",
		METHODPR_TRIVIAL(FVector, FVector, operator/, (double) const));
	FVector_.Method("FVector opNeg() const",
		METHODPR_TRIVIAL(FVector, FVector, operator-, () const));
	FVector_.Method("FVector opMulAssign(float64 Scale)",
		METHODPR_TRIVIAL(FVector, FVector, operator*=, (double)));
	FVector_.Method("FVector opDivAssign(float64 Scale)",
		METHODPR_TRIVIAL(FVector, FVector, operator/=, (double)));
	FVector_.Method("FVector opMulAssign(const FVector& Other)",
		METHODPR_TRIVIAL(FVector, FVector, operator*=, (const FVector&)));
	FVector_.Method("FVector opDivAssign(const FVector& Other)",
		METHODPR_TRIVIAL(FVector, FVector, operator/=, (const FVector&)));
	FVector_.Method("FVector opAddAssign(const FVector& Other)",
		METHODPR_TRIVIAL(FVector, FVector, operator+=, (const FVector&)));
	FVector_.Method("FVector opSubAssign(const FVector& Other)",
		METHODPR_TRIVIAL(FVector, FVector, operator-=, (const FVector&)));
	FVector_.Method("float64& opIndex(int32 Index)",
		METHODPR_TRIVIAL(double&, FVector, operator[], (int32)));
	FVector_.Method("float64 opIndex(int32 Index) const",
		METHODPR_TRIVIAL(double, FVector, operator[], (int32) const));
	FVector_.Method("bool opEquals(const FVector& Other) const",
		METHODPR_TRIVIAL(bool, FVector, operator==, (const FVector&) const));

	FVector_.Method("bool Equals(const FVector& Other, float64 Tolerance = KINDA_SMALL_NUMBER) const",
		METHOD_TRIVIAL(FVector, Equals));
	FVector_.Method("FVector CrossProduct(const FVector& Other) const",
		FUNC_TRIVIAL(FVector::CrossProduct));
	FVector_.Method("float64 DotProduct(const FVector& Other) const",
		FUNC_TRIVIAL(FVector::DotProduct));
	FVector_.Method("bool AllComponentsEqual(float64 Tolerance = KINDA_SMALL_NUMBER) const",
		METHOD_TRIVIAL(FVector, AllComponentsEqual));

	FVector_.Method(
		"bool Parallel(const FVector& Normal2, float64 ParallelCosineThreshold = THRESH_NORMALS_ARE_PARALLEL) const",
		FUNC_TRIVIAL(FVector::Parallel))
		.Documentation(UTF8_TO_TCHAR(
	 "* See if two normal vectors are nearly parallel, meaning the angle between them is close to 0 degrees. \n"
	 "* @param  Normal1 First normalized vector.\n"
	 "* @param  Normal1 Second normalized vector.\n"
	 "* @param  ParallelCosineThreshold Normals are parallel if absolute value of dot product (cosine of angle between them) is greater than or equal to this. For example: cos(1.0 degrees). \n"
	 "* @return true if vectors are nearly parallel, false otherwise. \n"
	));
	FVector_.Method(
		"bool Coincident(const FVector& Normal2, float64 ParallelCosineThreshold = THRESH_NORMALS_ARE_PARALLEL) const",
		FUNC_TRIVIAL(FVector::Coincident))
		.Documentation(UTF8_TO_TCHAR(
	 "* See if two normal vectors are coincident (nearly parallel and point in the same direction).\n"
	 "* @param  Normal1 First normalized vector.\n"
	 "* @param  Normal2 Second normalized vector.\n"
	 "* @param  ParallelCosineThreshold Normals are coincident if dot product (cosine of angle between them) is greater than or equal to this. For example: cos(1.0 degrees).\n"
	 "* @return true if vectors are coincident (nearly parallel and point in the same direction), false otherwise.\n"
	));
	FVector_.Method(
		"bool Orthogonal(const FVector& Normal2, float64 OrthogonalCosineThreshold = THRESH_NORMALS_ARE_ORTHOGONAL) const",
		FUNC_TRIVIAL(FVector::Orthogonal))
		.Documentation(UTF8_TO_TCHAR(
	 "* See if two normal vectors are nearly orthogonal (perpendicular), meaning the angle between them is close to 90 degrees.\n"
	 "* @param  Normal1 First normalized vector.\n"
	 "* @param  Normal2 Second normalized vector.\n"
	 "* @param  OrthogonalCosineThreshold Normals are orthogonal if absolute value of dot product (cosine of angle between them) is less than or equal to this. For example: cos(89.0 degrees).\n"
	 "* @return true if vectors are orthogonal (perpendicular), false otherwise.\n"
	));

	FVector_.Method("float64 GetMax() const", METHOD_TRIVIAL(FVector, GetMax));
	FVector_.Method("float64 GetAbsMax() const", METHOD_TRIVIAL(FVector, GetAbsMax));
	FVector_.Method("float64 GetMin() const", METHOD_TRIVIAL(FVector, GetMin));
	FVector_.Method("float64 GetAbsMin() const", METHOD_TRIVIAL(FVector, GetAbsMin));
	FVector_.Method("FVector ComponentMin(const FVector& Other) const",
		METHOD_TRIVIAL(FVector, ComponentMin));
	FVector_.Method("FVector ComponentMax(const FVector& Other) const",
		METHOD_TRIVIAL(FVector, ComponentMax));
	FVector_.Method("FVector ComponentClamp(const FVector& Min, const FVector& Max) const",
		METHOD_TRIVIAL(FVector, BoundToBox));
	FVector_.Method("FVector GetAbs() const", METHOD_TRIVIAL(FVector, GetAbs));
	FVector_.Method("float64 Size() const", METHOD_TRIVIAL(FVector, Size));
	FVector_.Method("float64 SizeSquared() const", METHOD_TRIVIAL(FVector, SizeSquared));
	FVector_.Method("float64 Size2D() const", METHOD_TRIVIAL(FVector, Size2D));
	FVector_.Method("float64 SizeSquared2D() const", METHOD_TRIVIAL(FVector, SizeSquared2D));
	FVector_.Method("bool IsNearlyZero(float64 Tolerance = KINDA_SMALL_NUMBER) const",
		METHOD_TRIVIAL(FVector, IsNearlyZero));
	FVector_.Method("bool IsZero() const", METHOD_TRIVIAL(FVector, IsZero));
	FVector_.Method("bool Normalize(float64 Tolerance = SMALL_NUMBER)",
		METHOD_TRIVIAL(FVector, Normalize));
	FVector_.Method("bool IsNormalized() const", METHOD_TRIVIAL(FVector, IsNormalized));
	FVector_.Method("void ToDirectionAndLength(FVector& OutDir, float64& OutLength) const",
		METHODPR_TRIVIAL(void, FVector, ToDirectionAndLength, (FVector&, double&) const));
	FVector_.Method("void ToDirectionAndLength(FVector& OutDir, float32& OutLength) const",
		METHODPR_TRIVIAL(void, FVector, ToDirectionAndLength, (FVector&, float&) const));
	FVector_.Method("FVector GetSignVector() const", METHOD_TRIVIAL(FVector, GetSignVector));
	FVector_.Method("FVector Projection() const", METHOD_TRIVIAL(FVector, Projection));
	FVector_.Method("FVector GetUnsafeNormal() const", METHOD_TRIVIAL(FVector, GetUnsafeNormal));
	FVector_.Method("FVector GridSnap(const float64& GridSize) const",
		METHOD_TRIVIAL(FVector, GridSnap));
	FVector_.Method("FVector BoundToCube(float64 Radius) const",
		METHOD_TRIVIAL(FVector, BoundToCube));
	FVector_.Method("FVector BoundToBox(const FVector& Min, const FVector& Max) const",
		METHOD_TRIVIAL(FVector, BoundToBox));
	FVector_.Method("FVector GetClampedToSize(float64 Min, float64 Max) const",
		METHOD_TRIVIAL(FVector, GetClampedToSize));
	FVector_.Method("FVector GetClampedToSize2D(float64 Min, float64 Max) const",
		METHOD_TRIVIAL(FVector, GetClampedToSize2D));
	FVector_.Method("FVector GetClampedToMaxSize(float64 Max) const",
		METHOD_TRIVIAL(FVector, GetClampedToMaxSize));
	FVector_.Method("FVector GetClampedToMaxSize2D(float64 Max) const",
		METHOD_TRIVIAL(FVector, GetClampedToMaxSize2D));
	FVector_.Method("void AddBounded(const FVector& V, float64 Radius=MAX_int16)",
		METHOD_TRIVIAL(FVector, AddBounded));
	FVector_.Method("FVector Reciprocal() const", METHOD_TRIVIAL(FVector, Reciprocal));
	FVector_.Method("bool IsUniform(float64 Tolerance = KINDA_SMALL_NUMBER) const",
		METHOD_TRIVIAL(FVector, IsUniform));
	FVector_.Method("FVector MirrorByVector(const FVector& MirrorNormal) const",
		METHOD_TRIVIAL(FVector, MirrorByVector));
	FVector_.Method("FVector VectorPlaneProject(const FVector& PlaneNormal) const",
		FUNC_TRIVIAL(FVector::VectorPlaneProject));
	FVector_.Method("FVector RotateAngleAxis(float64 AngleDeg, const FVector& Axis) const",
		METHOD_TRIVIAL(FVector, RotateAngleAxis));
	FVector_.Method("FVector GetSafeNormal(float64 Tolerance = SMALL_NUMBER, const FVector& ResultIfZero = FVector::ZeroVector) const",
		METHOD_TRIVIAL(FVector, GetSafeNormal));
	FVector_.Method("FVector GetSafeNormal2D(float64 Tolerance = SMALL_NUMBER, const FVector& ResultIfZero = FVector::ZeroVector) const",
		METHOD_TRIVIAL(FVector, GetSafeNormal2D));
	FVector_.Method("float64 CosineAngle2D(FVector B) const",
		METHOD_TRIVIAL(FVector, CosineAngle2D));
	FVector_.Method("FVector ProjectOnTo(const FVector& A) const",
			METHOD_TRIVIAL(FVector, ProjectOnTo))
		.Documentation(UTF8_TO_TCHAR(
	 "Gets a copy of this vector projected onto the input vector.\n\n"
	 "@param A	Vector to project onto, does not assume it is normalized.\n"
	 "@return Projected vector."
	));
	FVector_.Method("FVector ProjectOnToNormal(const FVector& Normal) const",
			METHOD_TRIVIAL(FVector, ProjectOnToNormal))
		.Documentation(UTF8_TO_TCHAR(
	 "Gets a copy of this vector projected onto the input vector, which is assumed to be unit length.\n\n"
	 "@param A	Normal vector to project onto (assumed to be unit length).\n"
	 "@return Projected vector."
	));
	FVector_.Method("void FindBestAxisVectors(FVector& Axis1, FVector& Axis2) const",
		METHOD_TRIVIAL(FVector, FindBestAxisVectors));
	FVector_.Method("void UnwindEuler() const", METHOD_TRIVIAL(FVector, UnwindEuler));
	FVector_.Method("bool ContainsNaN() const", METHOD_TRIVIAL(FVector, ContainsNaN));
	FVector_.Method("bool IsUnit(float64 LengthSquaredTolerance = KINDA_SMALL_NUMBER) const",
		METHOD_TRIVIAL(FVector, IsUnit));
	FVector_.Method("float64 HeadingAngle() const", METHOD_TRIVIAL(FVector, HeadingAngle));
	FVector_.Method("bool PointsAreSame(const FVector& P2) const",
		FUNC_TRIVIAL(FVector::PointsAreSame));
	FVector_.Method("bool PointsAreNear(const FVector& P2, float64 Dist) const",
		FUNC_TRIVIAL(FVector::PointsAreNear));
	FVector_.Method("float64 Distance(const FVector& Other) const",
		FUNC_TRIVIAL(FVector::Distance));
	FVector_.Method("float64 DistSquared(const FVector& Other) const",
		FUNC_TRIVIAL(FVector::DistSquared));
	FVector_.Method("float64 Dist2D(const FVector& Other) const",
		FUNC_TRIVIAL(FVector::Dist2D));
	FVector_.Method("float64 DistXY(const FVector& Other) const",
		FUNC_TRIVIAL(FVector::DistXY));
	FVector_.Method("float64 DistSquaredXY(const FVector& Other) const",
		FUNC_TRIVIAL(FVector::DistSquaredXY));
	FVector_.Method("float64 DistSquared2D(const FVector& Other) const",
		FUNC_TRIVIAL(FVector::DistSquared2D));
	FVector_.Method("FRotator ToOrientationRotator() const",
		METHOD_TRIVIAL(FVector, ToOrientationRotator));
	FVector_.Method("FQuat ToOrientationQuat() const",
		METHOD_TRIVIAL(FVector, ToOrientationQuat));
	FVector_.Method("FRotator Rotation() const", METHOD_TRIVIAL(FVector, Rotation));
	FVector_.Method("bool InitFromString(const FString& SourceString)",
		METHOD_TRIVIAL(FVector, InitFromString));

	FVector_.Namespace()
		.Constant("const FVector ZeroVector", &FVector::ZeroVector)
		.Constant("const FVector OneVector", &FVector::OneVector)
		.Constant("const FVector UpVector", &FVector::UpVector)
		.Constant("const FVector DownVector", &FVector::DownVector)
		.Constant("const FVector ForwardVector", &FVector::ForwardVector)
		.Constant("const FVector BackwardVector", &FVector::BackwardVector)
		.Constant("const FVector RightVector", &FVector::RightVector)
		.Constant("const FVector LeftVector", &FVector::LeftVector);
}

AS_FORCE_LINK const FAngelscriptBind Bind_FVector(
	TEXT("FVector"),
	EAngelscriptBindRegisterKind::Explicit,
	&RegisterFVector);
```

Apply for `FVector`: walk `ApplySlot=Type`, then Infrastructure, then Members. Extra engines skip `RegisterFVector` and only Apply the row.

---

## 2. `FLinearColor` — one Register function (`Bind_FLinearColor.cpp`)

Today's three `FAngelscriptBind` objects (TypeDeclarations / TypeInfrastructure / ExplicitBindings) become one function. `EApplySlot` is inferred by the DSL (`Value` → Type, `Adapter`/`ToString` → Infrastructure, `Constructor`/`Method` → Members).

```cpp
static void RegisterFLinearColor(FAngelscriptTypeBindInfoStore& Store)
{
	FAngelscriptTypeBindInfo& C = Store.Value<FLinearColor>("FLinearColor").POD();
	C.Adapter<FLinearColorType>();
	C.ToString(&FAngelscriptFLinearColorBinds::AppendToString);

	C.Constructor("void f()", &FAngelscriptFLinearColorBinds::ConstructDefault)
		.NoDiscard()
		.NativeConstructor("FLinearColor", true, "0.f, 0.f, 0.f, 1.f");
	C.Constructor("void f(float32 R, float32 G, float32 B, float32 A = 1.f)",
			&FAngelscriptFLinearColorBinds::ConstructRGBA, "FLinearColor", true)
		.NoDiscard();
	C.Constructor("void f(const FLinearColor& Other)",
			&FAngelscriptFLinearColorBinds::ConstructCopy, "FLinearColor", true)
		.NoDiscard();
	C.Constructor("void f(const FColor& Other)",
			&FAngelscriptFLinearColorBinds::ConstructFromColor, "FLinearColor", true)
		.NoDiscard();

	C.Property("float32 R", &FLinearColor::R);
	C.Property("float32 G", &FLinearColor::G);
	C.Property("float32 B", &FLinearColor::B);
	C.Property("float32 A", &FLinearColor::A);

	C.Method("FLinearColor& opAssign(const FLinearColor& Other)",
		METHODPR_TRIVIAL(FLinearColor&, FLinearColor, operator=, (const FLinearColor&)));
	C.Method("FColor ToFColor(bool bSRGB) const", METHOD_TRIVIAL(FLinearColor, ToFColor));
	C.Method("bool InitFromString(const FString& SourceString)",
		METHOD_TRIVIAL(FLinearColor, InitFromString));

	C.Namespace()
		.Constant("FLinearColor White", &FLinearColor::White)
		.Constant("FLinearColor Black", &FLinearColor::Black)
		.Constant("FLinearColor Red", &FLinearColor::Red);
}

AS_FORCE_LINK const FAngelscriptBind Bind_FLinearColor(
	TEXT("FLinearColor"),
	EAngelscriptBindRegisterKind::Explicit,
	&RegisterFLinearColor);
```

`ToFColor` lives on the **`FLinearColor` row**. `RegisterFColor` may also `FindOrAdd` that row and append the same method — a cross-row patch, still not a Phase.

---

## 3. `FColor` — one Register function; `FindOrAdd` merges with UStruct (`Bind_FColor.cpp`)

Today `Bind_FColor` has no TypeDeclarations because `Bind_UStruct` already `RegisterObjectType`s it. After this change there is still **one** `FColor` row. `RegisterFColor` owns the extra constructors/methods/ToString; the UStruct generator `FindOrAdd`s the same row for reflected properties. No TypeDeclarations provider. No ToString-only provider.

```cpp
static void RegisterFColor(FAngelscriptTypeBindInfoStore& Store)
{
	FAngelscriptTypeBindInfo& FColor_ = Store.FindOrAddValue("FColor");
	FColor_.ToString(&FAngelscriptFColorBinds::AppendToString);

	FColor_.Constructor(
		"void f(uint8 R, uint8 G, uint8 B, uint8 A = 255)",
		&FAngelscriptFColorBinds::ConstructRGBA, "FColor", true)
		.NoDiscard();
	FColor_.Constructor(
		"void f(uint DWColor)",
		&FAngelscriptFColorBinds::ConstructPacked, "FColor", true)
		.NoDiscard();

	FColor_.Property("uint DWColor", 0);
	FColor_.Method("FString ToHex() const", METHOD_TRIVIAL(FColor, ToHex));
	FColor_.Method("FLinearColor FromRGBE() const", METHOD_TRIVIAL(FColor, FromRGBE));

	FColor_.Namespace()
		.StaticFunction("FColor FromHex(const FString& HexString) no_discard", &FColor::FromHex)
		.Constant("FColor White", &FColor::White)
		.Constant("FColor Black", &FColor::Black);

	Store.FindOrAddValue("FLinearColor")
		.Method("FColor ToFColor(bool bSRGB) const", METHOD_TRIVIAL(FLinearColor, ToFColor));
}

AS_FORCE_LINK const FAngelscriptBind Bind_FColor(
	TEXT("FColor"),
	EAngelscriptBindRegisterKind::Explicit,
	&RegisterFColor);
```

`FindOrAdd` (not `MustFind`) so this Register function does not depend on a prior type-only pass. If UStruct later merges reflected properties onto the same name, members append; conflicting `Kind` fails expand.

---

## 4. `FActorSpawnParameters` — one Register function writes the enum row and the struct row (`Bind_FActorSpawnParameters.cpp`)

Two TypeBindInfo rows, **one function**. The enum is not a TypeDeclarations provider.

```cpp
static void RegisterFActorSpawnParameters(FAngelscriptTypeBindInfoStore& Store)
{
	Store.Enum("ESpawnActorNameMode")
		.Value("Required_Fatal", FActorSpawnParameters::ESpawnActorNameMode::Required_Fatal)
		.Value("Required_ErrorAndReturnNull", FActorSpawnParameters::ESpawnActorNameMode::Required_ErrorAndReturnNull)
		.Value("Required_ReturnNull", FActorSpawnParameters::ESpawnActorNameMode::Required_ReturnNull)
		.Value("Requested", FActorSpawnParameters::ESpawnActorNameMode::Requested);

	FAngelscriptTypeBindInfo& P = Store.Value<FActorSpawnParameters>("FActorSpawnParameters");
	P.Adapter<FActorSpawnParametersType>();

	P.Constructor("void f()", &FAngelscriptActorSpawnParametersBinds::Construct)
		.NoDiscard()
		.NativeConstructor("FActorSpawnParameters", true);
	P.Constructor("void f(const FActorSpawnParameters& Other)",
			&FAngelscriptActorSpawnParametersBinds::CopyConstruct)
		.NoDiscard()
		.NativeConstructor("FActorSpawnParameters", true);
	P.Method("FActorSpawnParameters& opAssign(const FActorSpawnParameters& Other)",
		METHODPR_TRIVIAL(FActorSpawnParameters&, FActorSpawnParameters, operator=, (const FActorSpawnParameters&)));

	P.Property("FName Name", &FActorSpawnParameters::Name);
	P.Property("ESpawnActorNameMode NameMode", &FActorSpawnParameters::NameMode);
	P.Method("bool GetbNoFail() const", &FAngelscriptActorSpawnParametersBinds::GetNoFail);
	P.Method("void SetbNoFail(bool Value)", &FAngelscriptActorSpawnParametersBinds::SetNoFail);
}

AS_FORCE_LINK const FAngelscriptBind Bind_FActorSpawnParameters(
	TEXT("FActorSpawnParameters"),
	EAngelscriptBindRegisterKind::Explicit,
	&RegisterFActorSpawnParameters);
```

---

## 5. `TArray` — one template family, not one row per `T` (`Bind_TArray.cpp`)

**Do not store `TArray<int>`, `TArray<FVector>`, `TArray<AActor@>`.** Store the AngelScript **template pattern** once. Specializations are created later by each `asIScriptEngine` when a script writes `TArray<FVector>`. That is AngelScript's template system, not C++ template metaprogramming over every element type.

Today's three `FAngelscriptBind` objects (`TypeDeclarations`, `MethodSurface`, `TypeInfrastructure`) become one `RegisterTArray`. `FArrayOperations`, `FAngelscriptArrayType`, `ValidateArrayTemplate`, and the existing `FArrayOperations::Add_Template<T>` JIT helpers stay. No new type-list / Boost.MPL / "instantiate Register for every `T`" layer.

`RegisterTArray` writes **three** rows (same function, three type names):

```text
TypeBindInfos["TArray"]                 Kind=Template  Decl="TArray<class T>"
TypeBindInfos["TArrayIterator"]         Kind=Template  Decl="TArrayIterator<class T>"
TypeBindInfos["TArrayConstIterator"]    Kind=Template  Decl="TArrayConstIterator<class T>"
```

What the `TArray` row holds (signatures still contain the placeholder `T`):

```text
TypeBindInfos["TArray"]
  Kind = Template
  NativeLayout = FScriptArray
  TemplateArgs = "<T>"
  ExtraFlags = asOBJ_TEMPLATE_SUBTYPE_COVARIANT
  DefaultArrayType = true
  AdapterRecipe = FAngelscriptArrayType
  Members:
    { TypeDecl,          ApplySlot=Type }
    { Adapter,           ApplySlot=Infrastructure }
    { DefaultArrayType,  ApplySlot=Infrastructure }   // RegisterDefaultArrayType("TArray<T>")
    { TypeFinder,        ApplySlot=Infrastructure }   // FArrayProperty → TArray<Inner>
    { Constructor,       ApplySlot=Infrastructure, Decl="void f()", Callable=FArrayOperations::Construct }
    { Destructor,        ApplySlot=Infrastructure, Decl="void f()",
                         PassScriptObjectTypeAsFirstParam,
                         NativeTemplateInstantiatedCall="FArrayOperations::Destruct" }
    { TemplateCallback,  ApplySlot=Infrastructure, Callable=ValidateArrayTemplate }
    { Method Add,        ApplySlot=Infrastructure, Decl="void Add(const T&in if_handle_then_const Value)",
                         PassScriptObjectTypeAsFirstParam,
                         NativeTemplateInstantiatedCall="FArrayOperations::Add" }
    { Method opIndex,    ApplySlot=Infrastructure, NativeTArrayIndex }
    { Method Num,        ApplySlot=Infrastructure, Decl="int Num() const" }
    … remaining methods from Bind_TArray.cpp MethodSurface …
```

**Not stored:** `asITypeInfo*` for `TArray<FVector>`, `FArrayOperations*` userdata, element size/alignment. Those are created per engine when the template instantiates (`ValidateArrayOperations` today). TypeFinder also does not pre-build usages; Apply re-registers the same finder, and the finder still calls `FAngelscriptTypeUsage::FromProperty` on **that** engine's TypeDB.

**C++ templates that already exist stay where they are:** `FArrayOperations::Destruct_Template<T>` / `.NativeTemplateInstantiatedCall("FArrayOperations::Add", …)` are StaticJIT native-instantiation recipes (a **string name** + flags on the member). Expand records that recipe. It does not run the C++ template. JIT later instantiates `T` for a known specialization. That is not TypeBindInfo expansion.

`TMap` / `TSet` / `TOptional` / `TObjectPtr` / `TSubclassOf` / `TWeakObjectPtr` use the same shape: one template row (or a small family), methods tagged `Infrastructure`, no per-`T` rows.

DSL infers `EApplySlot` on a **template** row: `Value`/`Template` → Type; `Adapter` / `DefaultArrayType` / `TypeFinder` → Infrastructure; constructors, methods, properties, and `TemplateCallback` on that same template row also → Infrastructure (so `TArray.Add` still lands before other types' `Members`). No `.Infrastructure()` stamp on every method. Named TypeFinder is stored as a function pointer; Apply runs it against **that** engine's TypeDB. Do not freeze `TArray<FVector>` at Expand.

```cpp
static bool FindTArrayProperty(FProperty* Property, FAngelscriptTypeUsage& Usage)
{
	FArrayProperty* ArrayProperty = CastField<FArrayProperty>(Property);
	if (ArrayProperty == nullptr)
	{
		return false;
	}

	FAngelscriptTypeUsage InnerUsage = FAngelscriptTypeUsage::FromProperty(
		Usage.GetApplyTypeDatabase(), ArrayProperty->Inner);
	if (!InnerUsage.IsValid())
	{
		return false;
	}

	Usage.TypeName = TEXT("TArray");
	Usage.SubTypes.Add(InnerUsage);
	return true;
}

static void RegisterTArray(FAngelscriptTypeBindInfoStore& Store)
{
	FAngelscriptTypeBindInfo& TArray_ = Store.Value<FScriptArray>("TArray<class T>")
		.Template("<T>")
		.ExtraObjectFlags(asOBJ_TEMPLATE_SUBTYPE_COVARIANT);

	TArray_.DefaultArrayType();
	TArray_.Adapter<FAngelscriptArrayType>();
	TArray_.TypeFinder(&FindTArrayProperty);

	TArray_.Constructor("void f()", FUNC_TRIVIAL(FArrayOperations::Construct));
	TArray_.Destructor("void f()", &FArrayOperations::Destruct)
		.PassScriptObjectTypeAsFirstParam()
		.NativeTemplateInstantiatedCall("FArrayOperations::Destruct", false, false, false);
	TArray_.TemplateCallback("bool f(int&in Type, int&out ErrorMessage)", &ValidateArrayTemplate);

	TArray_.Method("T& opIndex(int __any_implicit_integer Index)", &FArrayOperations::OpIndex)
		.PassScriptObjectTypeAsFirstParam()
		.NativeTArrayIndex();
	TArray_.Method("const T& opIndex(int __any_implicit_integer Index) const", &FArrayOperations::OpIndex)
		.PassScriptObjectTypeAsFirstParam()
		.NativeTArrayIndex();
	TArray_.Method("TArray<T>& opAssign(const TArray<T>& Other)", &FArrayOperations::OpAssign)
		.PassScriptObjectTypeAsFirstParam()
		.NativeTemplateInstantiatedCall("FArrayOperations::OpAssign", false, false, true);
	TArray_.Method("bool opEquals(const TArray<T>& Other) const", &FArrayOperations::OpEquals)
		.PassScriptObjectTypeAsFirstParam()
		.NativeTemplateInstantiatedCall("FArrayOperations::OpEquals", false, true, false);
	TArray_.Method("void Add(const T&in if_handle_then_const Value)", &FArrayOperations::Add)
		.PassScriptObjectTypeAsFirstParam()
		.NativeTemplateInstantiatedCall("FArrayOperations::Add", false, false, true);
	TArray_.Method("void Append(const TArray<T>& Other)", &FArrayOperations::Append)
		.PassScriptObjectTypeAsFirstParam()
		.NativeTemplateInstantiatedCall("FArrayOperations::Append", false, false, true);
	TArray_.Method("void Shuffle()", FUNC(FArrayOperations::Shuffle))
		.PassScriptObjectTypeAsFirstParam();
	TArray_.Method(
		"void Swap(int32 __any_implicit_integer FirstIndexToSwap, int32 __any_implicit_integer SecondIndexToSwap)",
		&FArrayOperations::Swap)
		.PassScriptObjectTypeAsFirstParam()
		.NativeTemplateInstantiatedCall("FArrayOperations::Swap", true, false, true)
		.Documentation(TEXT("Swap the element at index FirstIndexToSwap with the element at index SecondIndexToSwap.\n"));
	TArray_.Method("void MoveAssignFrom(TArray<T>& OtherArray)", &FArrayOperations::MoveAssignFrom)
		.PassScriptObjectTypeAsFirstParam()
		.NativeTemplateInstantiatedCall("FArrayOperations::MoveAssignFrom", true, false, false)
		.Documentation(TEXT(
			"Perform a move-assign from the passed in array into this array.\n"
			"The passed in array will be emptied in the process as its memory is moved over."));
	TArray_.Method("bool IsValidIndex(int32 __any_implicit_integer Index) const",
		FUNC_TRIVIAL(FArrayOperations::IsValidIndex));
	TArray_.Method("const T& Last(int32 __any_implicit_integer IndexFromEnd = 0) const", &FArrayOperations::Last)
		.PassScriptObjectTypeAsFirstParam()
		.NativeTemplateInstantiatedCall("FArrayOperations::Last", false, false, false);
	TArray_.Method("T& Last(int32 __any_implicit_integer IndexFromEnd = 0)", &FArrayOperations::Last)
		.PassScriptObjectTypeAsFirstParam()
		.NativeTemplateInstantiatedCall("FArrayOperations::Last", false, false, false);
	TArray_.Method(
		"void Insert(const T&in if_handle_then_const Value, int32 __any_implicit_integer Index = 0)",
		&FArrayOperations::Insert)
		.PassScriptObjectTypeAsFirstParam()
		.NativeTemplateInstantiatedCall("FArrayOperations::Insert", false, false, true);
	TArray_.Method("bool AddUnique(const T&in if_handle_then_const Value)", &FArrayOperations::AddUnique)
		.PassScriptObjectTypeAsFirstParam()
		.NativeTemplateInstantiatedCall("FArrayOperations::AddUnique", false, true, true)
		.Documentation(TEXT(
			"Will first do a check if the object already is in the array.\n"
			"Returns 'True' if the object is added.\n"));
	TArray_.Method("void Empty(int32 __any_implicit_integer ReservedSize = 0)", &FArrayOperations::Empty)
		.PassScriptObjectTypeAsFirstParam()
		.NativeTemplateInstantiatedCall("FArrayOperations::Empty", false, false, false);
	TArray_.Method("void Reset(int32 __any_implicit_integer ReservedSize = 0)", &FArrayOperations::Reset)
		.PassScriptObjectTypeAsFirstParam()
		.NativeTemplateInstantiatedCall("FArrayOperations::Reset", false, false, false);
	TArray_.Method("void Reserve(int32 __any_implicit_integer ReservedSize = 0)", &FArrayOperations::Reserve)
		.PassScriptObjectTypeAsFirstParam()
		.NativeTemplateInstantiatedCall("FArrayOperations::Reserve", false, false, false);
	TArray_.Method("void SetNum(int32 __any_implicit_integer NewNum = 0)", FUNC(FArrayOperations::SetNum))
		.PassScriptObjectTypeAsFirstParam();
	TArray_.Method(
		"void Copy(const TArray<T>& SourceArray, int32 __any_implicit_integer SourceIndex, int32 __any_implicit_integer Count, int __any_implicit_integer TargetIndex = 0)",
		FUNC(FArrayOperations::Copy))
		.PassScriptObjectTypeAsFirstParam();
	TArray_.Method("void SetNumZeroed(int32 __any_implicit_integer NewNum = 0)", FUNC(FArrayOperations::SetNumZeroed))
		.PassScriptObjectTypeAsFirstParam();
	TArray_.Method("int32 FindIndex(const T&in if_handle_then_const Value) const", &FArrayOperations::FindIndex)
		.PassScriptObjectTypeAsFirstParam()
		.NativeTemplateInstantiatedCall("FArrayOperations::FindIndex", false, true, false)
		.Documentation(TEXT(
			"Find the first index that contains an element with the given value.\n"
			"If no element matches the value, it will return -1."));
	TArray_.Method("bool Contains(const T&in if_handle_then_const Value) const", &FArrayOperations::Contains)
		.PassScriptObjectTypeAsFirstParam()
		.NativeTemplateInstantiatedCall("FArrayOperations::Contains", false, true, false);
	TArray_.Method("int RemoveSingle(const T&in if_handle_then_const Value)", &FArrayOperations::RemoveSingle)
		.PassScriptObjectTypeAsFirstParam()
		.NativeTemplateInstantiatedCall("FArrayOperations::RemoveSingle", false, true, false);
	TArray_.Method("int Remove(const T&in if_handle_then_const Value)", &FArrayOperations::Remove)
		.PassScriptObjectTypeAsFirstParam()
		.NativeTemplateInstantiatedCall("FArrayOperations::Remove", false, true, false);
	TArray_.Method("int RemoveSingleSwap(const T&in if_handle_then_const Value)", &FArrayOperations::RemoveSingleSwap)
		.PassScriptObjectTypeAsFirstParam()
		.NativeTemplateInstantiatedCall("FArrayOperations::RemoveSingleSwap", false, true, false);
	TArray_.Method("int RemoveSwap(const T&in if_handle_then_const Value)", &FArrayOperations::RemoveSwap)
		.PassScriptObjectTypeAsFirstParam()
		.NativeTemplateInstantiatedCall("FArrayOperations::RemoveSwap", false, true, false);
	TArray_.Method("void RemoveAt(int32 __any_implicit_integer Index)", &FArrayOperations::RemoveAt)
		.PassScriptObjectTypeAsFirstParam()
		.NativeTemplateInstantiatedCall("FArrayOperations::RemoveAt", false, false, true);
	TArray_.Method("void RemoveAtSwap(int32 __any_implicit_integer Index)", &FArrayOperations::RemoveAtSwap)
		.PassScriptObjectTypeAsFirstParam()
		.NativeTemplateInstantiatedCall("FArrayOperations::RemoveAtSwap", false, false, true);
	TArray_.Method("void Sort(bool bDescendingOrder = false)", FUNC(FArrayOperations::Sort))
		.PassScriptObjectTypeAsFirstParam();
	TArray_.Method("int Num() const", FUNC_TRIVIAL(FArrayOperations::Num));
	TArray_.Method("int Max() const", FUNC_TRIVIAL(FArrayOperations::Max));
	TArray_.Method("int64 GetAllocatedSize() const", &FArrayOperations::GetAllocatedSize)
		.PassScriptObjectTypeAsFirstParam()
		.NativeTemplateInstantiatedCall("FArrayOperations::GetAllocatedSize", true, false, false);
	TArray_.Method("bool IsEmpty() const", FUNC_TRIVIAL(FArrayOperations::IsEmpty));
	TArray_.Method("int GetSlack() const", FUNC_TRIVIAL(FArrayOperations::GetSlack));
	TArray_.Method("int opForBegin()", &FAngelscriptArrayIterationBinds::ForBegin);
	TArray_.Method("int opForBegin() const", &FAngelscriptArrayIterationBinds::ForBegin);
	TArray_.Method("bool opForEnd(const int Iterator) const", &FAngelscriptArrayIterationBinds::ForEnd);
	TArray_.Method("void opForNext(int&inout Iterator)", &FAngelscriptArrayIterationBinds::ForNext);
	TArray_.Method("void opForNext(int&inout Iterator) const", &FAngelscriptArrayIterationBinds::ForNext);
	TArray_.Method("T& opForValue(const int Iterator)", &FAngelscriptArrayIterationBinds::ForValue)
		.PassScriptObjectTypeAsFirstParam();
	TArray_.Method("const T& opForValue(const int Iterator) const", &FAngelscriptArrayIterationBinds::ForValue)
		.PassScriptObjectTypeAsFirstParam();
	TArray_.Method("int opForKey(const int Iterator) const", &FAngelscriptArrayIterationBinds::ForKey);
	TArray_.Method("void Shrink()", &FArrayOperations::Shrink)
		.PassScriptObjectTypeAsFirstParam()
		.NativeTemplateInstantiatedCall("FArrayOperations::Shrink", true, false, false);

	FAngelscriptTypeBindInfo& It = Store.Value<FArrayIterator>("TArrayIterator<class T>")
		.Template("<T>");
	It.Adapter<FAngelscriptArrayIteratorType>();
#if AS_ITERATOR_DEBUGGING
	It.Destructor("void f()", &FArrayIterator::Destruct);
#endif
	It.Constructor("void f(const TArrayIterator<T>& Other)", &FArrayIterator::CopyConstruct);
	It.Method("TArrayIterator<T>& opAssign(const TArrayIterator<T>& Other)", &FArrayIterator::Assignment);
	It.Property("bool CanProceed", &FArrayIterator::bCanProceed);
	It.Method("T& Proceed()", &FArrayIterator::Proceed)
		.NativeTArrayIteratorProceed();

	FAngelscriptTypeBindInfo& ConstIt = Store.Value<FArrayIterator>("TArrayConstIterator<class T>")
		.Template("<T>");
	ConstIt.Adapter<FAngelscriptArrayConstIteratorType>();
#if AS_ITERATOR_DEBUGGING
	ConstIt.Destructor("void f()", &FArrayIterator::Destruct);
#endif
	ConstIt.Constructor("void f(const TArrayConstIterator<T>& Other)", &FArrayIterator::CopyConstruct);
	ConstIt.Method("TArrayConstIterator<T>& opAssign(const TArrayConstIterator<T>& Other)",
		&FArrayIterator::Assignment);
	ConstIt.Property("bool CanProceed", &FArrayIterator::bCanProceed);
	ConstIt.Method("const T& Proceed()", &FArrayIterator::Proceed)
		.NativeTArrayIteratorProceed();

	TArray_.Method("TArrayIterator<T> Iterator()", &FArrayIterator::Create)
		.PassScriptObjectTypeAsFirstParam()
		.NativeTArrayIteratorCreate();
	TArray_.Method("TArrayConstIterator<T> Iterator() const", &FArrayIterator::Create)
		.PassScriptObjectTypeAsFirstParam()
		.NativeTArrayIteratorCreate();
}

AS_FORCE_LINK const FAngelscriptBind Bind_TArray(
	TEXT("TArray"),
	EAngelscriptBindRegisterKind::Explicit,
	&RegisterTArray);
```

Apply still registers every `Infrastructure` member (including `TArray.Add`) before any other type's `Members`. That replaces the TypeInfrastructure **phase**, not a second Register function. Script use of `TArray<FVector>` still goes through AngelScript template instantiation + `ValidateArrayOperations` on that engine. `FArrayOperations`, `ValidateArrayTemplate`, and the existing `*_Template<T>` JIT helpers stay in `Bind_TArray.h`. The file-level signature comment table is unchanged.

---

## 6. Json family — one Register function (`Bind_Json.cpp`)

`EJsonType`, the four value types, their methods, and `Json::ParseString` are all `RegisterJson`. Not `Bind_Json_TypeDeclarations` plus `Bind_Json.Manual`.

```cpp
static void RegisterJson(FAngelscriptTypeBindInfoStore& Store)
{
	Store.Enum("EJsonType")
		.Value("None", EJson::None)
		.Value("Null", EJson::Null)
		.Value("String", EJson::String)
		.Value("Number", EJson::Number)
		.Value("Boolean", EJson::Boolean)
		.Value("Array", EJson::Array)
		.Value("Object", EJson::Object);

	FAngelscriptTypeBindInfo& JsonValue = Store.Value<FJsonValueContainer>("FJsonValue");
	JsonValue.Constructor("void f()", &FAngelscriptJsonBinds::ConstructValue);
	JsonValue.Destructor("void f()", &FAngelscriptJsonBinds::DestructValue);
	JsonValue.Method("EJsonType GetType() const", &FJsonValueContainer::GetType);
	JsonValue.Method("bool TryGetArray(FJsonArray& OutArray) const", &FJsonValueContainer::TryGetArray);

	FAngelscriptTypeBindInfo& JsonArray = Store.Value<FJsonValueArrayContainer>("FJsonArray");
	JsonArray.Constructor("void f()", &FAngelscriptJsonBinds::ConstructArray);
	JsonArray.Method("FJsonValue GetValueAt(int32 Index) const", &FJsonValueArrayContainer::GetValueAt);

	FAngelscriptTypeBindInfo& JsonObject = Store.Value<FJsonObjectContainer>("FJsonObject");
	JsonObject.Constructor("void f()", &FAngelscriptJsonBinds::ConstructObject);
	JsonObject.Method("FString SaveToString(bool bPrettyPrint = true) const",
		&FAngelscriptJsonBinds::SaveToString);
	JsonObject.Method("FJsonObjectFieldIterator Iterator()", &FAngelscriptJsonBinds::Iterator);

	FAngelscriptTypeBindInfo& It = Store.Value<FJsonObjectFieldIterator>("FJsonObjectFieldIterator");
	It.Method("EJsonType GetType() const", &FJsonObjectFieldIterator::GetType);
	It.Method("FJsonObjectFieldIterator& Proceed()", &FAngelscriptJsonBinds::Proceed);

	Store.Namespace("Json")
		.StaticFunction("FString ValueTypeToString(EJsonType T)", &FAngelscriptJsonBinds::ValueTypeToString)
		.StaticFunction("FJsonObject ParseString(const FString& JsonStr)", &FAngelscriptJsonBinds::ParseString);
}

AS_FORCE_LINK const FAngelscriptBind Bind_Json(
	TEXT("Json"),
	EAngelscriptBindRegisterKind::Explicit,
	&RegisterJson);
```

One Register function may create **several** rows (enum + values + namespace). Recording does not need `EJsonType` to already exist on a live engine; Apply registers the enum `Type` slot before any `GetType()` `Members` slot.

---

## 7. `UStruct` generator — one Register function per struct, many structs (`Bind_UStruct.cpp`)

Not one static row per struct, and **not** three phase providers. One Reflection Register walks BindDB / `TObjectRange` and for each struct writes declaration + adapter + reflected members onto that row.

```cpp
static void RegisterUStructs(FAngelscriptTypeBindInfoStore& Store)
{
	for (FAngelscriptStructBind& DBBind : Store.BindDatabase().Structs)
	{
		UScriptStruct* Struct = FindObject<UScriptStruct>(nullptr, *DBBind.UnrealPath);
		if (Struct == nullptr)
		{
			continue;
		}

		FAngelscriptTypeBindInfo& Row = Store.FindOrAddValue(DBBind.TypeName, Struct);
		if (Struct->StructFlags & STRUCT_IsPlainOldData)
		{
			Row.POD();
		}
		Row.AdapterFromStruct(Struct);
		BindStructBehaviors(Row, Struct);
		AppendReflectedProperties(Row, Struct);
	}
}

AS_FORCE_LINK const FAngelscriptBind Bind_UStruct(
	TEXT("UStruct"),
	EAngelscriptBindRegisterKind::Reflection,
	&RegisterUStructs);
```

`FColor` is one of these rows. `RegisterFColor` `FindOrAdd`s the same name and appends extra methods.

---

## 8. Blueprint `UClass` — one Register function declares, adapts, and fills members (`Bind_BlueprintType.cpp`)

```cpp
static void RegisterBlueprintTypes(FAngelscriptTypeBindInfoStore& Store)
{
	for (UClass* Class : GetOrCaptureBlueprintTypeClasses(Store))
	{
		const FString TypeName = FAngelscriptType::GetBoundClassName(Class);
		FAngelscriptTypeBindInfo& Row = Store.FindOrAddObject(TypeName, Class);
		Row.AdapterFromClass(Class);
		AppendReflectedProperties(Row, Class);
		AppendReflectedFunctions(Row, Class);
		Row.StaticClassGlobal(TypeName, Class);

		if (Class->IsChildOf(AActor::StaticClass()))
		{
			AppendActorSpawnMembers(Row, Class);
		}
	}
}

AS_FORCE_LINK const FAngelscriptBind Bind_BlueprintType(
	TEXT("BlueprintType"),
	EAngelscriptBindRegisterKind::Reflection,
	&RegisterBlueprintTypes);
```

`TObjectPtr` / `TSubclassOf` / `TWeakObjectPtr` are one Explicit Register each; their template methods are tagged `Infrastructure`, same as `TArray`.

`AMyEnemy.Spawn(...)` is a member on the **`AMyEnemy` row**, written while that row is filled. It is not a TypeDeclarations provider and not a leftover `EAngelscriptBindPhase`.

---

## 9. `AActor` — one Explicit Register for extras; Spawn already on the class row (`Bind_AActor.cpp`)

`AActor` as a `UClass` is filled by `RegisterBlueprintTypes` (declaration + reflected members + Spawn). `RegisterAActor` only appends Hazelight-style extras onto that same row. It is not a TypeDeclarations / ExplicitBindings pair.

```cpp
static void RegisterAActor(FAngelscriptTypeBindInfoStore& Store)
{
	FAngelscriptTypeBindInfo& A = Store.FindOrAddObject("AActor");

	A.Method("bool IsActorInitialized() const", METHOD_TRIVIAL(AActor, IsActorInitialized));
	A.Method("bool HasActorBegunPlay() const", METHOD_TRIVIAL(AActor, HasActorBegunPlay));
	A.Method("bool IsHidden() const", METHOD_TRIVIAL(AActor, IsHidden));
	A.Method("FVector GetActorLocation() const", METHOD_TRIVIAL(AActor, GetActorLocation));
	A.Method("FRotator GetActorRotation() const", METHOD_TRIVIAL(AActor, GetActorRotation));
	A.Method("void SetActorScale3D(FVector NewScale3D)", METHOD_TRIVIAL(AActor, SetActorScale3D));
	A.Method("FString GetActorNameOrLabel() const", METHOD_TRIVIAL(AActor, GetActorNameOrLabel));
	A.Method("UGameInstance GetGameInstance() const",
		METHODPR_TRIVIAL(UGameInstance*, AActor, GetGameInstance, () const));
	A.Method("void GetComponentsByClass(?& OutComponents) const",
		&FAngelscriptActorBinds::GetComponentsByClass);
	A.Method("APawn GetInstigator() const", &FAngelscriptActorBinds::GetInstigator);
	A.Method("void EnableInput(APlayerController PlayerController)",
		&FAngelscriptActorBinds::EnableInput);
	A.Method("void SetReplicates(bool bInReplicates)", &AActor::SetReplicates);

	Store.Namespace("Actor")  // today's BindGlobalFunctionForTarget without a type namespace
		.StaticFunction("void GetAllActorsOfClass(?& OutActors)",
			&FAngelscriptActorBinds::GetAllActorsOfClass)
		.StaticFunction(
			"AActor SpawnActor(const TSubclassOf<AActor>& Class, const FVector& Location = FVector::ZeroVector, const FRotator& Rotation = FRotator::ZeroRotator, const FName& Name = NAME_None, bool bDeferredSpawn = false, ULevel Level = nullptr)",
			FUNC(FAngelscriptActorBinds::SpawnActor))
			.DeterminesOutputType(0)
		.StaticFunction("void FinishSpawningActor(AActor Actor)",
			FUNC(FAngelscriptActorBinds::FinishSpawningActor));

	Store.FindOrAddObject("UWorld")
		.Method(
			"AActor SpawnActor(const TSubclassOf<AActor>& Class, const FTransform& SpawnTransform, const FActorSpawnParameters& SpawnParameters)",
			&FAngelscriptActorBinds::SpawnActorInWorld)
		.DeterminesOutputType(0);
}

AS_FORCE_LINK const FAngelscriptBind Bind_AActor(
	TEXT("AActor"),
	EAngelscriptBindRegisterKind::Explicit,
	&RegisterAActor);
```

Hazelight extras stay in `Bind_AActor.cpp`. Per-subclass `Spawn` stays in `RegisterBlueprintTypes` on that subclass row. `RegisterKind=PostReflection` remains in the enum for genuine "must run after every Reflection row exists" patches; Actor Spawn does not need a second provider.

---

## 10. Member conditions — still on the method, not a second type

```cpp
static void RegisterUFoo(FAngelscriptTypeBindInfoStore& Store)
{
	FAngelscriptTypeBindInfo& Foo = Store.FindOrAddObject("UFoo");

	Foo.Method("void DumpEditorStats() const", METHOD(UFoo, DumpEditorStats))
		.EditorOnly()
		.NativeFunction("UFoo::DumpEditorStats");

	Foo.Method("void EnsureReady()", METHOD(UFoo, EnsureReady))
		.CompileOutInTest();
}
```

Apply for a cooked engine drops `DumpEditorStats`. `EnsureReady` still registers; compile-out uses the **target** engine, not the expander.

---

## Apply walks metadata, not `EAngelscriptBindPhase`

```text
for each TypeBindInfo in DeclarationOrder:
    RegisterObjectType / ValueClass / Enum          // members with ApplySlot=Type

for each TypeBindInfo in DeclarationOrder:
    adapter / ToString / template methods           // ApplySlot=Infrastructure

for each TypeBindInfo in DeclarationOrder:
    constructors / methods / properties / Spawn     // ApplySlot=Members
    (filtered by this engine's surface)
```

This is three Apply slots, not seven bind phases. v1 implements it as walks keyed by `EApplySlot` + `MemberOrder`. Observable `Register*` order MUST match today's engine (types, then template method surfaces, then other methods).

Rollback: `as.BindFromTypeBindInfo=0` restores per-engine lambda replay for unmigrated files.
