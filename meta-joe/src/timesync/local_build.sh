rm -rf build
mkdir -p build
cmake -DCMAKE_MODULE_PATH=../cmake -DCMAKE_CXX_FLAGS="-DLOCAL_BUILD" -B build -S .
cmake --build build
