executable(
  'nvse_loader',
  files(
    'Inject.cpp',
    'main.cpp',
    'Options.cpp',
  ),
  import('windows').compile_resources('resources.rc'),
  include_directories: inc,
  cpp_args: common_args + ['/std:c++20', '-D_CONSOLE', '/FIcommon/IPrefix.h'],
  link_with: [common_lib, loader_common_lib],
  link_args: ['version.lib', '/DYNAMICBASE:NO'],
  win_subsystem: 'console',
  install: true,
  install_dir: install_root,
)
