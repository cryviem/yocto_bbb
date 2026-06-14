#include <iostream>
#include <ctime>

class TimeSync {
    public:
    TimeSync();
    ~TimeSync();
    bool GetNtpTime(time_t& ntpTime, const char* ntpServer = "pool.ntp.org");

    private:

};