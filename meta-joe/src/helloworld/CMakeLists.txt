cmake_minimum_required(VERSION 3.13.0)
project(helloworld)

add_executable(${PROJECT_NAME} 
    helloworld.c)

target_link_libraries(${PROJECT_NAME} jmath)