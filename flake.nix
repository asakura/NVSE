{
  description = "xNVSE - Fallout: New Vegas script extender, cross-built with Meson + clang-cl for i686-pc-windows-msvc";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      inherit (pkgs)
        lib
        ;

      # Only x86_64-linux is built and verified; the outputs are cross-compiled Windows binaries either way.
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;

        # The MSVC CRT/STL and Windows SDK (nixpkgs windows.sdk) are unfree and need
        # https://visualstudio.microsoft.com/license-terms/mt644918/ accepted.
        config = {
          allowUnfreePredicate =
            pkg:
            builtins.elem (lib.getName pkg) [
              "win-sdk"
              "xwin-fetch-msvc"
            ];

          microsoftVisualStudioLicenseAccepted = true;
        };
      };

      tools = pkgs.callPackage ./nix/toolchain.nix { };

      xnvse = pkgs.callPackage ./nix/package.nix { inherit self tools; };
    in
    {
      packages.${system}.default = xnvse;

      checks.${system}.default = xnvse;

      devShells.${system}.default = pkgs.callPackage ./nix/shell.nix { inherit tools; };
    };
}
