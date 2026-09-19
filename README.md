# Global Science Network 477 : 4-bit Computer Implementation

## Brief Intro

## Architecture

## Specs

## Prerequisites
1. ghdl
2. GTKWave
3. 

## How to test
1. ghdl -a --std=08 lfsr.vhd seven_seg_driver.vhd top_module.vhd testbench/tb_top_module.vhd
2. ghdl -e --std=08 tb_top_module
3. ghdl -r --std=08 tb_top_module --vcd=wave/waveform.vcd

## Testbenches
1. Capabilites : doing random generation for number and then display the values by using the framebuffer decoder. I do this for 16 times (based on the max 16 times of repeatability from lfsr) and thus, there should be a pattern generated in the form of image in the terminal.

## Authors
1. Brian A. Hadian (An final-year undergraduate computer science student at Bandung Institute of Technology)
