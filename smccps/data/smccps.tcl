#
# (C) Copyright 2014-2022 Xilinx, Inc.
# (C) Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#

    proc smccps_generate {drv_handle} {
        set handle [hsi::get_cells -hier -filter {IP_NAME==ps7_smcc}]
        set node [get_node $drv_handle]
        set dts_file [set_drv_def_dts $drv_handle]
        set reg [get_baseaddr [hsi::get_cells -hier $handle]]
        add_prop $node "flashbase" $reg int $dts_file
        set nand_handle [hsi::get_cells -hier -filter {IP_NAME==ps7_nand}]
        set bus_width [get_ip_property $nand_handle CONFIG.C_NAND_WIDTH]
        add_prop $node "nand-bus-width" $bus_width int $dts_file
    }


