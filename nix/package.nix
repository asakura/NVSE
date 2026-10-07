{
  lib,
  stdenvNoCC,
  self,
  tools,
}:
stdenvNoCC.mkDerivation {
  pname = "xnvse";
  version = self.shortRev or self.dirtyShortRev or "unknown";

  src = lib.cleanSource ../.;

  # out: the release archive's files. dev: headers for plugins, and import libraries.
  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;
  nativeBuildInputs = tools.toolchain;

  mesonFlags = [
    "--cross-file=${tools.crossFile}"
  ];

  # nixpkgs' Meson setup hook passes Unix install dirs; this layout is set by meson.build.
  configurePhase = ''
    runHook preConfigure
    meson setup build $mesonFlags --prefix=$out
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    meson compile -C build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    meson install -C build --no-rebuild

    # Like the release archive, out has no import libraries.
    mkdir -p "$dev/lib"
    mv "$out"/*.lib "$dev/lib"

    # Laid out for -I$dev/include, matching the include roots of the solution:
    # "nvse/PluginAPI.h", "common/ITypes.h", "Algohol/paramTypes.h".
    installHeaders() {
      (cd "$1" && find . -type f \( -name '*.h' -o -name '*.inc' \) -exec install -Dm444 {} "$2/{}" \;)
    }
    installHeaders nvse/nvse "$dev/include/nvse"
    installHeaders common "$dev/include/common"
    installHeaders nvse/Algohol "$dev/include/Algohol"

    runHook postInstall
  '';

  dontFixup = true;
}
