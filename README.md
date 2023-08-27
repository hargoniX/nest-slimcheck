# `nest-slimcheck`
An `IsTest` implementation such that the `SlimCheck` framework can be
used with [`nest-core`](https://github.com/hargonix/nest-core).

The main contribution of this implementation is the `PropTest` type,
together with its `IsTest` implementation such that the `SlimCheck`
framework can be called from within `nest` test suites.

Here is a full example:
```lean
import NestCore
import NestSlimCheck

open Nest.Core
open Nest.SlimCheck

def tests : TestTree := [nest|
  group "examples"
    group "examples positive"
      test "rfl" : PropTest := .mk <| ∀ (x : Nat), x = x
      test "reverse_append" : PropTest := .mk <| ∀ (xs ys : List Nat), (xs ++ ys).reverse = ys.reverse ++ xs.reverse
    group "examples negative"
      test "lt" : PropTest := .mk <| ∀ (x y : Nat), x < y
      test "append_com" : PropTest := .mk <| ∀ (xs ys : List Nat), xs ++ ys = ys ++ xs
]

def main : IO UInt32 := Nest.Core.defaultMain tests
```

## Dependency footprint
Right now `SlimCheck` is within `mathlib4` which makes it necessary to
pull quite a large chunk of libraries in to compile this adapter, we
hope to extract `SlimCheck` either to `std4` or to its own library
in the future.
