{
  mkShellNoCC,
  tools,
}:
mkShellNoCC {
  packages = tools.toolchain;

  MESON_CROSS_FILE = tools.crossFile;

  shellHook = ''
    echo "Configure: meson setup build --cross-file \$MESON_CROSS_FILE" >&2
    echo "Build:     meson compile -C build" >&2
  '';
}
