#
# (C) Copyright 2018-2022 Xilinx, Inc.
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

    proc audio_formatter_generate {drv_handle} {
        global env
        global dtsi_fname
        set path $env(REPO)

        set node [get_node $drv_handle]
        if {$node == 0} {
                return
        }
        set node [get_node $drv_handle]
        if {$node == 0} {
                return
        }
        set dts_file [set_drv_def_dts $drv_handle]
        if {$node == 0} {
                return
        }

        pldt append $node compatible "\ \, \"xlnx,audio-formatter-1.0\""

	set tx_connect_ip [get_connected_stream_ip [hsi get_cells -hier $drv_handle] "m_axis_mm2s"]
        if {[llength $tx_connect_ip] != 0} {
                add_prop "$node" "xlnx,tx" $tx_connect_ip reference $dts_file 1
        } else {
                dtg_warning "$drv_handle pin m_axis_mm2s is not connected... check your design"
        }
        set rx_connect_ip [get_connected_stream_ip [hsi get_cells -hier $drv_handle] "s_axis_s2mm"]
        if {[llength $rx_connect_ip] != 0} {
                add_prop "$node" "xlnx,rx" $rx_connect_ip reference $dts_file 1
        } else {
                dtg_warning "$drv_handle pin s_axis_s2mm is not connected... check your design"
        }


    }


