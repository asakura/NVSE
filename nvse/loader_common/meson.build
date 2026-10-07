loader_common_lib = static_library(
  'loader_common',
  files(
    'Error.cpp',
    'IdentifyEXE.cpp',
    'PluginChecker.cpp',
  ),
  include_directories: inc,
  cpp_args: common_args + ['-D_LIB', '/FIcommon/IPrefix.h'],
)
