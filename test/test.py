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


    

    # Test for 1 ms @ 25 MHz
    # await ClockCycles(dut.clk, 25000)

    # assert dut.uo_out.value == 50

@cocotb.test()
async def test_mul_bit_serial(dut):
    dut._log.info("Testing mul_bit_serial module")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    # Test values close to the 16-bit boundaries with more variation
    boundary_cases = [
        (0x0000, 0x0000),      # Lower boundary
        (0x0001, 0x0001),      # Lower boundary
        (0x0002, 0x0003),
        (0x0022, 0x0033),
        (0x0001, 0x7FFF),      # Lower * Mid-1
        (0x1234, 0x7FFF),      # Lower * Mid-1
        (0x7FFF, 0x7FFF),      # Mid-1 * Mid-1
        (0xFFFF, 0x0001),      # Upper * 1
        (0x0001, 0x8000),      # Lower * Upper boundary
        (0x7FFF, 0x8000),      # Lower * Upper boundary
        (0x0001, 0xFFFF),      # Lower * Upper boundary
        (0x8000, 0x8000),      # Mid-range negative (two's complement)
        (0xFFFF, 0x0001),      # Upper * Lower boundary
        (0xFFFF, 0xFFFF),      # Upper boundary
        (0x7FFF, 0x7FFF),      # Mid-range positive
        (0x1234, 0x5678),      # Random mid-range values
        (0xAAAA, 0x5555),      # Patterned values
        (0xFFFF, 0x0000),      # Upper boundary with zero
    ]

    for a, b in boundary_cases:
        await ClockCycles(dut.clk, 1)
        print(a, b, a * b)
        dut.tt_um_top_instance.shift_register = ((a & 0xFFFF) << 16) | (b & 0xFFFF)
        await ClockCycles(dut.clk, 1)
        dut.tt_um_top_instance.start = 1
        await ClockCycles(dut.clk, 1)
        dut.tt_um_top_instance.start = 0
        
        # for i in range(50):
        #     print(dut.tt_um_top_instance.start, dut.uo_out[0].value, dut.uo_out[1].value, dut.tt_um_top_instance.mul_result, dut.tt_um_top_instance.mul_valid)
        #     await ClockCycles(dut.clk, 1)

        # print("----")

        # Wait until the result is ready
        while dut.tt_um_top_instance.mul_valid == 0:
            # print(dut.tt_um_top_instance.start, dut.uo_out[0].value, dut.uo_out[1].value, dut.tt_um_top_instance.mul_result, dut.tt_um_top_instance.mul_valid)
            await ClockCycles(dut.clk, 1)

        expected = a * b
        actual = dut.tt_um_top_instance.mul_result
        assert actual == expected, f"Test failed for {a:#06x} * {b:#06x}: expected {expected:#06x}, got {actual}"

    dut._log.info("All boundary tests passed for mul_bit_serial module")
