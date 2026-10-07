shared_library(
  'nvse_steam_loader',
  files(
    '../nvse/containers.cpp',
    '../nvse/Hooks_Memory.cpp',
    '../nvse/SafeWrite.cpp',
    '../nvse/Utilities.cpp',
    '../nvse/utility.cpp',
    'main.cpp',
  ),
  name_prefix: '',
  include_directories: inc,
  cpp_args: common_args + [
    '-D_USRDLL',
    '-DSTEAM_LOADER_EXPORTS',
    '/FIcommon/IPrefix.h',
  ],
  link_with: [common_lib, loader_common_lib],
  link_args: ['version.lib'],
  install: true,
  install_dir: install_root,
)
