# Cross build of xNVSE with clang-cl + lld-link (see flake.nix and nix/toolchain.nix).
# Mirrors the Release|Win32 configuration of nvse/nvse.sln.
project(
  'xnvse',
  'cpp',
  meson_version: '>=1.3.0',
  default_options: [
    # Release|Win32 also writes PDBs (/O2 /Zi /DEBUG), which crash loggers use.
    'buildtype=debugoptimized',
    'b_ndebug=true',
    'cpp_std=none',
    'b_vscrt=md',
    'warning_level=1',
  ],
)

if host_machine.system() != 'windows' or host_machine.cpu_family() != 'x86'
  error('Fallout: New Vegas is a 32-bit Windows program: cross-compile for i686 Windows')
endif

if meson.get_compiler('cpp').get_argument_syntax() != 'msvc'
  error('xNVSE relies on the MSVC ABI: build with clang-cl or MSVC, not MinGW')
endif

# $(SolutionDir) and $(SolutionDir)..
inc = include_directories('nvse', '.')

# Shared by every project in the solution.
common_args = [
  '-DWIN32',
  '-D_WINDOWS',
  '/arch:SSE2',
  '/GS-',
  # MSVC's /std:c++latest is C++23 plus previews; clang-cl's is C++26, which rejects
  # arithmetic between different enum types.
  '/std:c++23preview',
]

# clang warnings about code that is intended and correct for MSVC.
common_args += [
  # Layout static_asserts on game classes, which are not standard-layout.
  '-Wno-invalid-offsetof',
  # MSVC idioms: overrides with a laxer exception specification than the base,
  # and static_cast between function and data pointers.
  '-Wno-microsoft-exception-spec',
  '-Wno-microsoft-cast',
  # MSVC-only #pragma optimize arguments.
  '-Wno-ignored-pragmas',
  # Two-character constants compared as UInt16, such as '%%' and '*/'.
  '-Wno-multichar',
  # Deliberate raw copies of objects with vtables, such as ArrayElement relocation,
  # which copies the object's own vtable pointer.
  '-Wno-dynamic-class-memaccess',
  '-Wno-nontrivial-memcall',
  # FakeDirectInput and FakeDirectInputDevice mirror COM interface vtables, so they
  # must not get a virtual destructor.
  '-Wno-delete-non-abstract-non-virtual-dtor',
]

# /DEBUG turns these off unless they are given explicitly (Release|Win32 enables both).
add_project_link_arguments('/OPT:REF', '/OPT:ICF', language: 'cpp')

# Game folder layout
install_root = get_option('prefix')

subdir('common')
subdir('nvse/loader_common')
subdir('nvse/nvse')
subdir('nvse/nvse_loader')
subdir('nvse/steam_loader')
