############################################################
## This file is generated automatically by Vitis HLS.
## Please DO NOT edit it.
## Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
############################################################
open_project krnl_gaussian_blur
set_top krnl_gaussian_blur
add_files ../../../../src/krnl_gaussian_blur.cpp -cflags "-I/home/np/ghq/github.com/Xilinx/Vitis_Libraries/vision/L1/include -I/home/np/ghq/gitlab.banana-shake.com/npz35/vitis_tutorial/vitis/gaussian_blur/gaussian_blur_kernels/src"
add_files -tb ../../../../src/krnl_gaussian_blur_tb.cpp -cflags "-I/home/np/ghq/github.com/Xilinx/Vitis_Libraries/vision/L1/include -I/usr/include/opencv4 -L/lib/x86_64-linux-gnu -lopencv_core -lopencv_imgcodecs -lopencv_imgproc /usr/lib/x86_64-linux-gnu/libstdc++.so.6 -Wno-unknown-pragmas" -csimflags "-I/home/np/ghq/github.com/Xilinx/Vitis_Libraries/vision/L1/include -I/usr/include/opencv4 -L/lib/x86_64-linux-gnu -L/usr/lib/x86_64-linux-gnu -lopencv_core -lopencv_imgcodecs -lopencv_imgproc /usr/lib/x86_64-linux-gnu/libstdc++.so.6 -Wno-unknown-pragmas"
open_solution "solution" -flow_target vitis
set_part {xck26-sfvc784-2LV-c}
create_clock -period 199.998000MHz -name default
config_interface -m_axi_addr64 -m_axi_alignment_byte_size 64 -m_axi_auto_max_ports=0 -m_axi_conservative_mode -m_axi_latency 64 -m_axi_max_widen_bitwidth 512
config_rtl -deadlock_detection sim -register_reset_num 3
config_dataflow -strict_mode warning
config_export -format ip_catalog -ipname krnl_gaussian_blur -rtl verilog -vivado_clock 199.998000MHz
source "./krnl_gaussian_blur/solution/directives.tcl"
csim_design -ldflags {-lopencv_core -lopencv_imgcodecs -lopencv_imgproc /usr/lib/x86_64-linux-gnu/libstdc++.so.6}
csynth_design
cosim_design -ldflags {-lopencv_core -lopencv_imgcodecs -lopencv_imgproc /usr/lib/x86_64-linux-gnu/libstdc++.so.6}
export_design -flow syn -rtl verilog -format ip_catalog

