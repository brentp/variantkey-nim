import ospaths
template thisModuleFile: string = instantiationInfo(fullPaths = true).filename

# Package

version       = "0.0.2"
author        = "Brent Pedersen"
description   = "encode variants to uint64"
license       = "MIT"

# Dependencies

srcDir = "src"
installExt = @["nim", "c", "h"]

skipDirs = @["tests"]

import ospaths,strutils

task test, "run the tests":
  exec "nim c --lineDir:on --debuginfo -r src/variantkey"
