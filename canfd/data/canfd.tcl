#
# (C) Copyright 2025 Advanced Micro Devices, Inc. All Rights Reserved.
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

proc canfd_generate {drv_handle} {

	set node [get_node $drv_handle]
	if {$node == 0} {
		return
	}
	set dts_file [set_drv_def_dts $drv_handle]

	set ip_name [get_ip_property $drv_handle IP_NAME]
	set version [string tolower [hsi get_property VLNV $drv_handle]]

	set is_pl [get_ip_property $drv_handle IS_PL]
	if {$is_pl == 1} {
		if {[string compare -nocase "xilinx.com:ip:canfd:1.0" $version] == 0} {
			set keyval [pldt append $node compatible "\ \, \"xlnx,canfd-1.0\""]
		} else {
			set keyval [pldt append $node compatible " \, \"xlnx,canfd-2.0\""]
		}
	}

	if {$is_pl == 1} {

		set num_tx_buf [get_ip_property $drv_handle "CONFIG.NUM_OF_TX_BUF"]
		set rx_fifo_0_depth [get_ip_property $drv_handle "CONFIG.C_RX_FIFO_0_DEPTH"]
		set rx_fifo_1_depth [get_ip_property $drv_handle "CONFIG.C_RX_FIFO_1_DEPTH"]
		set en_rx_fifo_1 [get_ip_property $drv_handle "CONFIG.EN_RX_FIFO_1"]

		if {$en_rx_fifo_1 == 1} {
			set total_rx_fifo_depth [expr $rx_fifo_0_depth + $rx_fifo_1_depth]
		} else {
			set total_rx_fifo_depth $rx_fifo_0_depth
		}
		set keyval [pldt append $node "tx-mailbox-count" <$num_tx_buf>]
		set keyval [pldt append $node "rx-fifo-depth" <$total_rx_fifo_depth>]
	}

	set proc_type [get_hw_family]
	if {[regexp "microblaze" $proc_type match]} {
		gen_dev_ccf_binding $drv_handle "s_axi_aclk"
	}
}
