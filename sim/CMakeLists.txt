cmake_minimum_required(VERSION 3.11)

project(MonoVgaTextSim)

include(FetchContent)

find_package(verilator HINTS $ENV{VERILATOR_ROOT} ${VERILATOR_ROOT})
if (NOT verilator_FOUND)
  message(FATAL_ERROR "Verilator was not found. Either install it, or set the VERILATOR_ROOT environment variable")
endif()

set(CMAKE_BUILD_TYPE DEBUG)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}-O0 -g")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O0 -g")

# Create a new executable target that will contain all your sources
add_executable(
  simulation
  sim.cpp
  IBM_VGA_8x16.c
)


verilate(simulation TRACE
  INCLUDE_DIRS
    ${CMAKE_SOURCE_DIR}/../rtl
    ${CMAKE_SOURCE_DIR}/../import/cpu
    ${CMAKE_SOURCE_DIR}/../import/vga
    ${CMAKE_SOURCE_DIR}/../import/uart
    VERILATOR_ARGS
    -CFLAGS "-g"
    -trace -O0 -x-assign 0
    +define+SIM=1 +librescan +libext+.v
    --top-module MasterShell
  SOURCES
    MasterShell.v
    UartMasterSlave.v
    uart_rx.v
    uart_tx.v
    UartProtocol.v
    fifo.v
    MonoVgaText.v
    abh.v
    abl.v
    alu.v
    cpu.v
    ctl.v
    microcode.v
    regfile.v
  )
