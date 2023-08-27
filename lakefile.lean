import Lake
open Lake DSL

require «nest-core» from git "https://github.com/hargonix/nest-core" @ "main"
require mathlib from git "https://github.com/leanprover-community/mathlib4"
  @ "cf479f4ee9e6e5e54f8b3ddea0011c3f816350d4"

package «nest-slimcheck» {
  -- add package configuration options here
}

@[default_target]
lean_lib «NestSlimCheck» {
  -- add library configuration options here
}

lean_exe Main {

}
