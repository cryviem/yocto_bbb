#include <iostream>
#include <thread>
#include <chrono>
#include <memory>
#include "timesync.h"

int main() {
    std::cout << "TIMESYNC SERVICE STARTED" << std::endl;

    #ifdef LOCAL_BUILD
    std::cout << "LOCAL BUILD WORK" << std::endl;
    #endif

    std::unique_ptr<TimeSync> timeSync(new TimeSync);

    while (true) {
        time_t ntpTime;
        if (timeSync->GetNtpTime(ntpTime)) {
            std::cout << "Successfully synced time: " << ctime(&ntpTime);
        } else {
            std::cerr << "Failed to get NTP time" << std::endl;
        }

        std::this_thread::sleep_for(std::chrono::seconds(60));
    }
    return 0;
}