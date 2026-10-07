# Cross toolchain shared by the package and the dev shell: unwrapped clang-cl + lld-link
# against the 32-bit MSVC CRT/STL and Windows SDK, plus the Meson cross file that wires them up.
{
  lib,
  path,
  callPackage,
  windows,
  writeText,
  llvmPackages,
  meson,
  ninja,
}:
let
  sdkDir = "${path}/pkgs/os-specific/windows/msvcSdk";

  # nixpkgs picks the SDK architecture from the host platform; FNV is 32-bit, so
  # fetch the x86 libraries with the hash nixpkgs pins for them.
  fetchWinSdk = callPackage "${sdkDir}/fetchWinSdk.nix" { };
in
rec {
  sdk = windows.sdk.overrideAttrs {
    src = fetchWinSdk {
      arch = "x86";
      manifest = "${sdkDir}/manifest.json";
      hash = (lib.importJSON "${sdkDir}/hashes.json").x86;
    };
  };

  llvm = llvmPackages;

  toolchain = [
    llvm.clang-unwrapped # unwrapped: the nix cc-wrapper only targets the host; provides clang-cl
    llvm.lld # lld-link
    llvm.llvm # llvm-lib, llvm-rc
    meson
    ninja
  ];

  # Reproducible output: /Brepro puts a content hash instead of a timestamp in the PE header,
  # /PDBALTPATH keeps the absolute PDB path out of the binaries.
  compileArgs = [
    "/Brepro"
    "/vctoolsdir"
    "${sdk}/crt"
    "/winsdkdir"
    "${sdk}/sdk"
  ];

  crossFile = writeText "i686-windows-msvc.ini" ''
    [binaries]
    c = ['clang-cl', '--target=i686-pc-windows-msvc']
    cpp = ['clang-cl', '--target=i686-pc-windows-msvc']
    c_ld = 'lld-link'
    cpp_ld = 'lld-link'
    ar = 'llvm-lib'
    windres = 'llvm-rc'

    [built-in options]
    c_args = [${lib.concatMapStringsSep ", " (a: "'${a}'") compileArgs}]
    cpp_args = [${lib.concatMapStringsSep ", " (a: "'${a}'") compileArgs}]
    c_link_args = ['/Brepro', '/PDBALTPATH:%_PDB%', '/vctoolsdir:${sdk}/crt', '/winsdkdir:${sdk}/sdk']
    cpp_link_args = ['/Brepro', '/PDBALTPATH:%_PDB%', '/vctoolsdir:${sdk}/crt', '/winsdkdir:${sdk}/sdk']

    [host_machine]
    system = 'windows'
    cpu_family = 'x86'
    cpu = 'i686'
    endian = 'little'
  '';
}
