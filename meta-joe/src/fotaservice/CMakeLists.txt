cmake_minimum_required(VERSION 3.13.0)
project(fotaservice)

include(useful_things)

# Build the timesync service executable
build_exe(
    TARGET      ${PROJECT_NAME}
    SRCS        main.cpp
)