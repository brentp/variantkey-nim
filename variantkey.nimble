import ospaths
template thisModuleFile: string = instantiationInfo(fullPaths = true).filename

# Package

version       = "0.0.1"
author        = "Brent Pedersen"
description   = "encode variants to uint64"
license       = "MIT"

# Dependencies

requires "nimgen"
srcDir = "src"
installExt = @["nim"]

bin = @["variantkey"]

skipDirs = @["tests"]

import ospaths,strutils

before install:
  nimgen variantkey.cfg

task test, "run the tests":
  exec "nim c --lineDir:on --debuginfo -r src/variantkey"
  exec "bash tests/functional-tests.sh"
