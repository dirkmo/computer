cmake_minimum_required(VERSION 3.11)

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

# _deps/cpu-src/generic/abh.v
# _deps/cpu-src/generic/abl.v
# _deps/cpu-src/generic/alu.v
# _deps/cpu-src/generic/cpu.v
# _deps/cpu-src/generic/ctl.v
# _deps/cpu-src/generic/microcode.v
# _deps/cpu-src/generic/regfile.v
# _deps/uart-src/rtl/fifo.v
# _deps/uart-src/rtl/UartMasterSlave.v
# _deps/uart-src/rtl/UartProtocol.v
# _deps/uart-src/rtl/uart_rx.v
# _deps/uart-src/rtl/uart_tx.v
# _deps/vga-src/rtl/MonoVgaText.v
# cpu_async.v
# MasterShell.v