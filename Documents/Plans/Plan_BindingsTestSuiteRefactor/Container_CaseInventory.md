# Container Bindings — Case Inventory Baseline

> 从 `AngelscriptContainerBindingsTests.cpp`（commit `2beac6f`）提取，共 14 个 Automation ID。
> 每条记录：旧 ID / 脚本行号 / 条件原文 / return 值 / 语义 / 新文件覆盖状态

## OptionalCompat（9 个 if/return + 1 个 return 1）

| # | 条件 | return | 语义 | ✅ |
|---|------|--------|------|----|
| 1 | `Empty.IsSet()` | 10 | 空 Optional 不应 IsSet | |
| 2 | `Empty.Get(7) != 7` | 20 | 空 Optional Get 应返回 fallback 7 | |
| 3 | `!Empty.IsSet()` (after Set(42)) | 30 | Set 后应 IsSet | |
| 4 | `Empty.GetValue() != 42` | 40 | GetValue 应返回 42 | |
| 5 | `!(Copy == Empty)` | 50 | 拷贝构造应相等 | |
| 6 | `Copy.GetValue() != 19` (after Copy = 19) | 60 | 赋值后 GetValue 应为 19 | |
| 7 | `Copy.IsSet()` (after Reset) | 70 | Reset 后不应 IsSet | |
| 8 | `!OptionalName.IsSet()` | 80 | FName Optional 应 IsSet | |
| 9 | `!(OptionalName.GetValue() == FName("Alpha"))` | 90 | FName GetValue 应匹配 | |
| 10 | `!(OptionalName.Get(FName("Fallback")) == FName("Alpha"))` | 100 | FName Get 有值时返回值而非 fallback | |

## OptionalGetValueUnsetError（4 个 TestEqual 断言）

| # | 断言 | 期望值 | 语义 | ✅ |
|---|------|--------|------|----|
| 1 | PrepareResult == asSUCCESS | 0 | Prepare 应成功 | |
| 2 | ExecuteResult == asEXECUTION_EXCEPTION | 3 | 应抛脚本异常 | |
| 3 | ExceptionString == "GetValue() called on Optional when not set!..." | 精确匹配 | 异常消息正确 | |
| 4 | ExceptionLine == 5 | 5 | 异常行号正确 | |

## SetCompat（9 个 if/return + 1 个 return 1）

| # | 条件 | return | 语义 | ✅ |
|---|------|--------|------|----|
| 1 | `!Empty.IsEmpty()` | 10 | 空集应 IsEmpty | |
| 2 | `Empty.Num() != 1` (after Add(4) x2) | 20 | 重复 Add 应去重 Num=1 | |
| 3 | `!Empty.Contains(4)` | 30 | 应包含已添加元素 | |
| 4 | `!Copy.Contains(4) \|\| Copy.Num() != Empty.Num()` | 40 | 拷贝应一致 | |
| 5 | `Copy.Num() != 2` (after Copy.Add(7)) | 50 | 拷贝 Add 新元素 Num=2 | |
| 6 | `!Copy.Remove(4)` | 60 | Remove 应返回 true | |
| 7 | `Copy.Contains(4)` (after Remove) | 70 | Remove 后不应包含 | |
| 8 | `!Copy.IsEmpty()` (after Reset) | 80 | Reset 后应 IsEmpty | |
| 9 | `!Names.Contains(FName("Alpha"))` | 90 | FName 集合 Contains | |

## MapCompat（17 个 if/return + 1 个 return 1）

| # | 条件 | return | 语义 | ✅ |
|---|------|--------|------|----|
| 1 | `!Empty.IsEmpty()` | 10 | 空 Map 应 IsEmpty | |
| 2 | `Empty.Num() != 1` (after Add x2 same key) | 20 | 相同 key Add 覆盖，Num=1 | |
| 3 | `!Empty.Contains(FName("Alpha"))` | 30 | 应包含 key | |
| 4 | `!Empty.Find(FName("Alpha"), Value)` | 40 | Find 应成功 | |
| 5 | `Value != 7` | 50 | Find 值应为覆盖后的 7 | |
| 6 | `FoundOrAdded != 7` | 55 | FindOrAdd 已存在返回 7 | |
| 7 | `AddedDefaulted != 11` | 56 | FindOrAdd 新 key+default 返回 11 | |
| 8 | `Empty.Num() != 2` | 57 | 加入 Beta 后 Num=2 | |
| 9 | `!Contains(Alpha) \|\| !Contains(Beta) \|\| Num!=2` | 58 | 两 key 都在 | |
| 10 | `Copy.Num() != 2` | 60 | 拷贝 Num=2 | |
| 11 | `!Copy.Contains(Alpha) \|\| !Copy.Contains(Beta)` | 61 | 拷贝包含两 key | |
| 12 | `!Copy.Remove(FName("Alpha"))` | 70 | Remove 应返回 true | |
| 13 | `Copy.Contains(FName("Alpha"))` | 80 | Remove 后不应包含 | |
| 14 | `!Copy.IsEmpty()` (after Reset) | 90 | Reset 后应 IsEmpty | |
| 15 | `!Names.Find(FName("A"), NameValue)` | 100 | FName Map Find | |
| 16 | `!(NameValue == FName("Alpha"))` | 110 | FName Map Value 正确 | |

## MapFindFailureAndFindOrAddRefCompat（5 个 if/return + 1 个三元 return）

| # | 条件 | return | 语义 | ✅ |
|---|------|--------|------|----|
| 1 | `Values.Find(FName("Missing"), MissingValue)` | 10 | Find 缺失 key 应返回 false | |
| 2 | `MissingValue != 99` | 20 | Find 失败不应修改 out 变量 | |
| 3 | `!Find("Gamma", Out) \|\| Out != 33` | 30 | FindOrAdd ref 赋值后 Find 应得 33 | |
| 4 | `!Find("Delta", Out) \|\| Out != 12` | 40 | FindOrAdd+default ref 赋值后得 12 | |
| 5 | `Values.Num() == 2 ? 1 : 50` | 50/1 | 最终 Num 应为 2 | |

## ArrayForeach（1 个三元 return）

| # | 条件 | return | 语义 | ✅ |
|---|------|--------|------|----|
| 1 | `Sum==8 && IndexSum==3` | 1/10 | foreach(Value,Index:Array) 累加正确 | |

## SetForeach（1 个三元 return）

| # | 条件 | return | 语义 | ✅ |
|---|------|--------|------|----|
| 1 | `Sum == 7` | 1/10 | foreach(Value:Set) 累加正确 | |

## SetForeachExactVisit（4 个 if/return + 1 个 return 1）

| # | 条件 | return | 语义 | ✅ |
|---|------|--------|------|----|
| 1 | `EmptyVisitCount != 0` | 10 | 空集 foreach 不执行体 | |
| 2 | `Visited.Num() != 3` | 20 | 3 元素应得 3 唯一访问 | |
| 3 | `!Contains(2\|5\|11)` | 30 | 每个元素都被访问 | |
| 4 | `VisitCount != 3` | 40 | 访问计数 = 3 | |

## MapForeach（1 个三元 return）

| # | 条件 | return | 语义 | ✅ |
|---|------|--------|------|----|
| 1 | `Sum==7 && KeyCount==2` | 1/10 | foreach(Value,Key:Map) 累加正确 | |

## MapForeachKeyValuePairing（11 个 if/return + 1 个 return 1）

| # | 条件 | return | 语义 | ✅ |
|---|------|--------|------|----|
| 1 | `EmptyVisits != 0` | 10 | 空 Map foreach 不执行体 | |
| 2 | `SeenCount != 1` (inside loop) | 20 | 每个 key 恰被访问一次 | |
| 3 | `Value != 2` (Alpha) | 30 | Alpha 的 value=2 | |
| 4 | `Value != 9` (Beta) | 40 | Beta 的 value=9 | |
| 5 | `Value != 17` (Gamma) | 50 | Gamma 的 value=17 | |
| 6 | else (unknown key) | 60 | 不应出现未知 key | |
| 7 | `VisitCount != 3` | 70 | 总访问 3 次 | |
| 8 | `SeenCounts.Num() != 3` | 80 | 3 个 key 有记录 | |
| 9 | `!Find(Alpha) \|\| SeenCount!=1` | 90 | Alpha 访问 1 次 | |
| 10 | `!Find(Beta) \|\| SeenCount!=1` | 100 | Beta 访问 1 次 | |
| 11 | `!Find(Gamma) \|\| SeenCount!=1` | 110 | Gamma 访问 1 次 | |

## ForeachNestedArrayMap（直接 return Total）

| # | 条件 | return | 语义 | ✅ |
|---|------|--------|------|----|
| 1 | `Total` | 30 | 嵌套 foreach 累加 A(10)+B(20)=30 | |

## ForeachEmptyContainerSkipsBody（直接 return Count）

| # | 条件 | return | 语义 | ✅ |
|---|------|--------|------|----|
| 1 | `Count` | 0 | 三种空容器 foreach 体不执行 | |

## ForeachUObjectArrayCompiles（直接 return Count）

| # | 条件 | return | 语义 | ✅ |
|---|------|--------|------|----|
| 1 | `Count` | 0 | UObject 空数组 foreach 编译通过且不执行 | |

## ForeachConstRefPreservesOriginal（2 个 if/return + 1 个 return 42）

| # | 条件 | return | 语义 | ✅ |
|---|------|--------|------|----|
| 1 | `Sum < 4.9 \|\| Sum > 5.1` | 1 | foreach 累加 X 正确 (1+4=5) | |
| 2 | `Vectors[0].X < 0.9 \|\| Vectors[0].X > 1.1` | 2 | foreach 不修改原数组 | |
| 3 | return 42 | 42 | 全部通过 | |

---

**总计**：14 个 ID，61 个可验证的条件/断言点。
