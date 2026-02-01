#include <iostream>
#include <thread>
#include <chrono>

int main() {
    std::cout << "FOTA SERVICE STARTED" << std::endl;

    while (true) {
        std::this_thread::sleep_for(std::chrono::seconds(10));
        std::cout << "FOTA SERVICE TEMPORARY LOOP" << std::endl;
    }
    return 0;
}