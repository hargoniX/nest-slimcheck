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
