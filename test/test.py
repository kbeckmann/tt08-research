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
    dut.ui_in.value = 0

    for i in range(0x100):
        await ClockCycles(dut.clk, 1)
        assert dut.top.data.value == i & 0xFFFFFFFF

    # Test wrapping at bit width
    dut.top.uut.acc.value = (1 << 32) - 0x100
    for i in range((1 << 32) - 0x100, (1 << 32) + 0x100):
        await ClockCycles(dut.clk, 1)
        # print(dut.top.data.value, i)
        assert dut.top.data.value == i & 0xFFFFFFFF
