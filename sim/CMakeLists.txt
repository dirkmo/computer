cmake_minimum_required(VERSION 3.11)

project(MonoVgaTextSim)

find_package(verilator HINTS $ENV{VERILATOR_ROOT} ${VERILATOR_ROOT})
if (NOT verilator_FOUND)
  message(FATAL_ERROR "Verilator was not found. Either install it, or set the VERILATOR_ROOT environment variable")
endif()

set(CMAKE_BUILD_TYPE DEBUG)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}-O0 -g")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O0 -g")

include_directories(${CMAKE_SOURCE_DIR}/../import/vga)

# Create a new executable target that will contain all your sources
add_executable(
  simulation
  sim.cpp
  ${CMAKE_SOURCE_DIR}/../import/vga/vga.cpp
  ${CMAKE_SOURCE_DIR}/../import/vga/IBM_VGA_8x16.c
)

include_directories(${CMAKE_SOURCE_DIR}/../import/vga/)

find_package(SDL2 REQUIRED)
include_directories(${SDL2_INCLUDE_DIRS})
target_link_libraries(simulation PRIVATE ${SDL2_LIBRARIES})

verilate(simulation TRACE
  INCLUDE_DIRS
  VERILATOR_ARGS
    -CFLAGS "-g"
    -trace -O0 -x-assign 0
    #+define+SIM=1
    +librescan +libext+.v
    --top-module System
    -y ${CMAKE_SOURCE_DIR}/../rtl
    -y ${CMAKE_SOURCE_DIR}/../import/cpu
    -y ${CMAKE_SOURCE_DIR}/../import/vga
    -y ${CMAKE_SOURCE_DIR}/../import/uart
  SOURCES
    ${CMAKE_SOURCE_DIR}/../rtl/System.v
    ${CMAKE_SOURCE_DIR}/../rtl/MasterShell.v
    ${CMAKE_SOURCE_DIR}/../rtl/cpu_async.v
    ${CMAKE_SOURCE_DIR}/../rtl/Memory.v
    ${CMAKE_SOURCE_DIR}/../import/uart/UartMasterSlave.v
    ${CMAKE_SOURCE_DIR}/../import/uart/uart_rx.v
    ${CMAKE_SOURCE_DIR}/../import/uart/uart_tx.v
    ${CMAKE_SOURCE_DIR}/../import/uart/UartProtocol.v
    ${CMAKE_SOURCE_DIR}/../import/uart/fifo.v
    ${CMAKE_SOURCE_DIR}/../import/vga/MonoVgaText.v
    ${CMAKE_SOURCE_DIR}/../import/cpu/abh.v
    ${CMAKE_SOURCE_DIR}/../import/cpu/abl.v
    ${CMAKE_SOURCE_DIR}/../import/cpu/alu.v
    ${CMAKE_SOURCE_DIR}/../import/cpu/cpu.v
    ${CMAKE_SOURCE_DIR}/../import/cpu/ctl.v
    ${CMAKE_SOURCE_DIR}/../import/cpu/microcode.v
    ${CMAKE_SOURCE_DIR}/../import/cpu/regfile.v
)
