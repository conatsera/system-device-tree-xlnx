#
# (C) Copyright 2020-2022 Xilinx, Inc.
# (C) Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
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
proc sdi_rx_generate {drv_handle} {
	set node [get_node $drv_handle]
	set dts_file [set_drv_def_dts $drv_handle]
	if {$node == 0} {
		return
	}
        set dtsi_file [set_drv_def_dts $drv_handle]
        set compatible [get_comp_str $drv_handle]
        pldt append $node compatible "\ \, \"xlnx,v-smpte-uhdsdi-rx-ss\""
        set dbpc [hsi get_property CONFIG.C_DYNAMIC_BPP_CHANGE [hsi get_cells -hier $drv_handle]]
	set dbpc [expr {$dbpc == "true" ? 1 : 0}]
        if {$dbpc == 1} {
                add_prop "${node}" "xlnx,dbpc" $dbpc int $dts_file 1
        }
	set sdiline_rate [hsi get_property CONFIG.C_LINE_RATE [hsi get_cells -hier $drv_handle]]
	switch $sdiline_rate {
		"3G_SDI" {
			add_prop "${node}" "xlnx,sdiline-rate" 0 int $dts_file 1
		}
		"6G_SDI" {
			add_prop "${node}" "xlnx,sdiline-rate" 1 int $dts_file 1
		}
		"12G_SDI_8DS" {
			add_prop "${node}" "xlnx,sdiline-rate" 2 int $dts_file 1
		}
		"12G_SDI_16DS" {
			add_prop "${node}" "xlnx,sdiline-rate" 3 int $dts_file 1
		}
		default {
			add_prop "${node}" "xlnx,sdiline-rate" 4 int $dts_file 1
		}
	}

        set line_rate [hsi get_property CONFIG.C_LINE_RATE [hsi get_cells -hier $drv_handle]]
        add_prop "${node}" "xlnx,line-rate"  $line_rate string $dts_file 1
	set edh [hsi get_property CONFIG.C_INCLUDE_RX_EDH_PROCESSOR [hsi get_cells -hier $drv_handle]]
	if {$edh == "true"} {
		add_prop "${node}" "xlnx,include-edh" 1 int $dts_file 1
	} else {
		add_prop "${node}" "xlnx,include-edh" 0 int $dts_file 1
	}

}

