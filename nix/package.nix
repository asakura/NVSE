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
    rm "$out"/*.lib
    runHook postInstall
  '';

  dontFixup = true;
}
