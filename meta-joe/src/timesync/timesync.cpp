#include <iostream>
#include <cstring>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <unistd.h>
#include "timesync.h"

TimeSync::TimeSync() {

}

TimeSync::~TimeSync() {

}

bool TimeSync::GetNtpTime(time_t& ntpTime, const char* ntpServer) {
    // NTP packet structure (48 bytes)
    struct NtpPacket {
        uint8_t li_vn_mode;      // Leap Indicator, Version, Mode
        uint8_t stratum;         // Stratum level
        uint8_t poll;            // Poll interval
        uint8_t precision;       // Precision
        uint32_t rootDelay;      // Root delay
        uint32_t rootDispersion; // Root dispersion
        uint32_t refId;          // Reference ID
        uint32_t refTm_s;        // Reference Timestamp (seconds)
        uint32_t refTm_f;        // Reference Timestamp (fraction)
        uint32_t origTm_s;       // Originate Timestamp (seconds)
        uint32_t origTm_f;       // Originate Timestamp (fraction)
        uint32_t rxTm_s;         // Receive Timestamp (seconds)
        uint32_t rxTm_f;         // Receive Timestamp (fraction)
        uint32_t txTm_s;         // Transmit Timestamp (seconds)
        uint32_t txTm_f;         // Transmit Timestamp (fraction)
    } __attribute__((packed));

    // Create socket
    int sockfd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (sockfd < 0) {
        std::cerr << "Failed to create socket" << std::endl;
        return false;
    }

    // Set timeout for socket
    struct timeval timeout;
    timeout.tv_sec = 5;
    timeout.tv_usec = 0;
    if (setsockopt(sockfd, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout)) < 0) {
        std::cerr << "Failed to set socket timeout" << std::endl;
        close(sockfd);
        return false;
    }

    // Resolve NTP server hostname
    struct hostent* server = gethostbyname(ntpServer);
    if (server == nullptr) {
        std::cerr << "Failed to resolve NTP server: " << ntpServer << std::endl;
        close(sockfd);
        return false;
    }

    // Setup server address
    struct sockaddr_in serverAddr;
    memset(&serverAddr, 0, sizeof(serverAddr));
    serverAddr.sin_family = AF_INET;
    serverAddr.sin_port = htons(123); // NTP port
    memcpy(&serverAddr.sin_addr.s_addr, server->h_addr, server->h_length);

    // Initialize NTP request packet
    NtpPacket packet;
    memset(&packet, 0, sizeof(packet));
    packet.li_vn_mode = 0x1B; // LI=0, VN=3 (IPv4), Mode=3 (client)

    // Send NTP request
    if (sendto(sockfd, &packet, sizeof(packet), 0,
               (struct sockaddr*)&serverAddr, sizeof(serverAddr)) < 0) {
        std::cerr << "Failed to send NTP request" << std::endl;
        close(sockfd);
        return false;
    }

    // Receive NTP response
    socklen_t addrLen = sizeof(serverAddr);
    ssize_t bytesReceived = recvfrom(sockfd, &packet, sizeof(packet), 0,
                                     (struct sockaddr*)&serverAddr, &addrLen);

    close(sockfd);

    if (bytesReceived < (ssize_t)sizeof(packet)) {
        std::cerr << "Failed to receive NTP response or incomplete packet" << std::endl;
        return false;
    }

    // Extract transmit timestamp (in NTP format)
    uint32_t txTm_s = ntohl(packet.txTm_s);

    // Convert NTP timestamp to Unix timestamp
    // NTP epoch is 1900-01-01, Unix epoch is 1970-01-01
    // Difference is 70 years = 2208988800 seconds
    const uint32_t NTP_TIMESTAMP_DELTA = 2208988800UL;
    ntpTime = txTm_s - NTP_TIMESTAMP_DELTA;

    #ifdef LOCAL_BUILD
    std::cout << "NTP Time retrieved: " << ctime(&ntpTime);
    #endif

    return true;
}