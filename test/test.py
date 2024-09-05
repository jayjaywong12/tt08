# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

OP_READ = 0
OP_WRITE = 1
OP_RUN = 2

OP_SHIFT = 6

UIO_DATA_MASK = 0xF

UIO_STATE_SHIFT = 4
UIO_STATE_MASK = 0x3

STATE_RESET = 0
STATE_RUNNING = 1

@cocotb.test()
async def test_mem(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # Set the input values you want to test
    for addr in range(0, 32):
        for test_value in range(0,16):
            # Write the value
            op = OP_WRITE
            dut.ui_in.value = addr | op << OP_SHIFT
            dut.uio_in.value = test_value

            await ClockCycles(dut.clk, 1)

            # Read the value back
            op = OP_READ
            dut.ui_in.value = addr | op << OP_SHIFT
            
            await ClockCycles(dut.clk, 1)

            assert (dut.uio_oe.value & UIO_DATA_MASK) == 0xF
            assert (dut.uio_out.value & UIO_DATA_MASK) == test_value

@cocotb.test()
async def test_sm(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    def get_state(dut):
       return (dut.uio_out.value & (UIO_STATE_MASK << UIO_STATE_SHIFT)) >> UIO_STATE_SHIFT 

    assert (dut.uio_oe.value & (UIO_STATE_MASK << UIO_STATE_SHIFT)) >> UIO_STATE_SHIFT == UIO_STATE_MASK
    assert get_state(dut) == STATE_RESET

    # Set op running
    dut.ui_in.value = OP_RUN << OP_SHIFT
    await ClockCycles(dut.clk, 2)

    assert get_state(dut) == STATE_RUNNING