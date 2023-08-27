import NestCore
import Mathlib.Testing.SlimCheck.Testable

namespace Nest
namespace SlimCheck

open SlimCheck.Decorations in
/--
A wrapper type around `Prop` that implements the `IsTest` type class
via calling `SlimCheck` onto the passed property.
-/
structure PropTest where
  /--
  The property we wish to test.
  -/
  p : Prop
  /--
  A tactic generated, annotated version of the property that helps us
  find instances of `SlimCheck.Testable`. You probably do not want to
  overwrite this argument
  -/
  p' : SlimCheck.Decorations.DecorationsOf p := by mk_decorations
  [testable : SlimCheck.Testable p']

attribute [instance] PropTest.testable

/--
Used to create a `SlimCheck.Configuration` from `Options` found in the
nest framework. All the fields of `SlimCheck.Configuration` can be
set via the name SlimCheck.field in the options map.
-/
def configOfOptions (opts : Core.Options) : SlimCheck.Configuration where
  traceDiscarded := opts.getBool `SlimCheck.traceDiscarded (defVal := false)
  traceSuccesses := opts.getBool `SlimCheck.traceSuccesses (defVal := false)
  traceShrink := opts.getBool `SlimCheck.traceShrink (defVal := false)
  traceShrinkCandidates := opts.getBool `SlimCheck.traceShrinkCandidate (defVal := false)
  quiet : Bool := opts.getBool `SlimCheck.quiet (defVal := true)
  numInst : Nat := opts.getNat `SlimCheck.numInst (defVal := 100)
  maxSize : Nat := opts.getNat `SlimCheck.maxSize (defVal := 100)
  numRetries : Nat := opts.getNat `SlimCheck.numRetries (defVal := 10)
  randomSeed : Option Nat := opts.get? `SlimCheck.randomSeed

instance : Core.IsTest PropTest where
  run opts prop := do
    let mut cfg := configOfOptions opts
    -- We always want a seed to make testing more easily reproducible
    let seed ←
      match cfg.randomSeed with
      | some seed => pure seed
      | none =>
        let ourSeed := UInt64.toNat (ByteArray.toUInt64LE! (← IO.getRandomBytes 8))
        cfg := { cfg with randomSeed := ourSeed }
        pure ourSeed
    let slimCheckRes ← SlimCheck.Testable.checkIO prop.p'
    let nestRes := match slimCheckRes with
    | .success .. =>
      {
        outcome := .success,
        description := s!"Unable to find counter examples (seed : {seed})",
        shortDescription := s!"Unable to find counter examples (seed : {seed})",
        details := ""
      }
    | .gaveUp n =>
      {
        outcome := .success,
        description := s!"Gave up generating input (seed: {seed})",
        shortDescription := s!"Gave up generating input (seed: {seed})",
        details := s!"Unable to generate problem instances after {n} tries."
      }
    | .failure _ vars _ =>
      {
        outcome := .failure .generic,
        description := s!"Found a counter example (seed : {seed})",
        shortDescription := s!"Found a counter example (seed : {seed})",
        details := String.intercalate ", " vars
      }
    return nestRes

end SlimCheck
end Nest
