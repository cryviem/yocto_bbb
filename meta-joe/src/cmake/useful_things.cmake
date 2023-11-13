# function: build_exe
#
# To build and install simple executable file
# Arguments:
#   [DBC] [optional] to build debug version
#   [TARGET] name of executable file
#   [INS] [optional] where to install executable file
#   [SRCS] list of source files
#   [INC_PATH] [optional] list of include paths
#   [LIBS] [optional] list of libraries to link
#   ToDo: Add more argument for link library private / public / interface
function(build_exe)
    cmake_parse_arguments(BC "DBG" "TARGET;INS" "SRCS;INC_PATH;LIBS" ${ARGN})
    message("----------------------------------------------------------")
    message("build_exe: target ${BC_TARGET} from ${BC_SRCS} ...")
    add_executable(${BC_TARGET} ${BC_SRCS})
    if (BC_INC_PATH)
        message("build_exe: include path ${BC_INC_PATH}")
        target_include_directories(${BC_TARGET} PRIVATE ${BC_INC_PATH})
    endif()

    if (BC_DBG)
        message("build_exe: debugging")
        target_compile_options(${BC_TARGET}    PUBLIC -g)
    endif()

    if (BC_LIBS)
        message("build_exe: use library ${BC_LIBS}")
        target_link_libraries(${BC_TARGET}    ${BC_LIBS})
    endif()

    if (BC_INS)
        message("build_exe: install to ${BC_INS}")
        install(TARGETS ${BC_TARGET}   DESTINATION ${BC_INS})
    endif()
    
    message("----------------------------------------------------------")
endfunction(build_exe)