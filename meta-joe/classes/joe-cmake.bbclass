# joe-cmake.bbclass
#
# This class provides common CMake helpers for joe layer recipes.
# It inherits the cmake class and sets up the path to useful_things.cmake
#
# Usage in a recipe:
#   inherit joe-cmake
#
# Then in your CMakeLists.txt:
#   include(useful_things)
#

inherit cmake

# Path to joe's cmake modules
JOE_CMAKE_DIR = "${JOE_SRC}/cmake"

# Add joe cmake directory to CMAKE_MODULE_PATH
EXTRA_OECMAKE:append = " -DCMAKE_MODULE_PATH=${JOE_CMAKE_DIR}"
