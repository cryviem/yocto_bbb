#include <iostream>
#include <thread>
#include <chrono>

int main() {
    std::cout << "NW MANAGER STARTED" << std::endl;

    while (true) {
        std::this_thread::sleep_for(std::chrono::seconds(10));
        std::cout << "NW MANAGER TEMPORARY LOOP" << std::endl;
    }
    return 0;
}