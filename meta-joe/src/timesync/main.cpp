#include <iostream>
#include <thread>
#include <chrono>

int main() {
    std::cout << "TIMESYNC SERVICE STARTED" << std::endl;

    while (true) {
        std::this_thread::sleep_for(std::chrono::seconds(10));
        std::cout << "TIMESYNC TEMPORARY LOOP" << std::endl;
    }
    return 0;
}