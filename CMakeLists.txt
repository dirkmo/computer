cmake_minimum_required(VERSION 3.21)

include(FetchContent)

project(computer)

find_package(verilator HINTS $ENV{VERILATOR_ROOT} ${VERILATOR_ROOT})
if (NOT verilator_FOUND)
  message(FATAL_ERROR "Verilator was not found. Either install it, or set the VERILATOR_ROOT environment variable")
endif()

set(CMAKE_BUILD_TYPE DEBUG)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}-O0 -g")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O0 -g")


FetchContent_Declare(
    cpu
    GIT_REPOSITORY https://github.com/Arlet/verilog-65C02.git
    GIT_TAG main
)

FetchContent_Declare(
    vga
    GIT_REPOSITORY https://github.com/dirkmo/monovgatext.git
    GIT_TAG main
)

FetchContent_Declare(
    uart
    GIT_REPOSITORY https://github.com/dirkmo/uartmaster.git
    GIT_TAG main
)
            
# ${CMAKE_SOURCE_DIR}
# ${uart_SOURCE_DIR}
# ${vga_SOURCE_DIR}
# ${cpu_SOURCE_DIR}

FetchContent_Populate(cpu)
FetchContent_Populate(vga)
FetchContent_Populate(uart)

