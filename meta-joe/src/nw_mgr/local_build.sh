rm -rf build
mkdir -p build
cmake -DCMAKE_MODULE_PATH=../cmake -B build -S .
cmake --build build
