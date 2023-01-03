with (import <nixpkgs> { });
mkShell.override { stdenv = llvmPackages_14.stdenv; } {
  buildInputs = [ nim lld_14 darwin.apple_sdk.frameworks.Security ];
}
