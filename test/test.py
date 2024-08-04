# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
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

    acc = 0
    for i in range(1, 0x100):
        dut.ui_in.value = i
        await ClockCycles(dut.clk, 1)
        assert dut.top.data.value == acc & ((1<<64)-1)
        acc += i + (i<<8) + (i<<16) + (i<<24) + (i<<32) + (i<<40) + (i<<48) + (i<<56)

    # Test wrapping at bit width
    acc = (1 << 24) - 0x100
    dut.top.uut.acc.value = acc
    for i in range(1, 0x100):
        dut.ui_in.value = i 
        await ClockCycles(dut.clk, 1)
        # print(dut.top.data.value, i)
        assert dut.top.data.value == acc & ((1<<64)-1)
        acc += i + (i<<8) + (i<<16) + (i<<24) + (i<<32) + (i<<40) + (i<<48) + (i<<56)
