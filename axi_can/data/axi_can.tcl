#
# (C) Copyright 2014-2022 Xilinx, Inc.
# (C) Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
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

	proc axi_can_generate {drv_handle} {
		global env
		global dtsi_fname
		set path $env(CUSTOM_SDT_REPO)

		set node [get_node $drv_handle]
		if {$node == 0} {
			return
		}

		set dts_file [set_drv_def_dts $drv_handle]

		set keyval [pldt append $node compatible "\ \, \"xlnx,axi-can-1.00.a\""]

		set_drv_conf_prop $drv_handle c_can_num_acf can-num-acf $node hexint
		set_drv_conf_prop $drv_handle c_can_tx_dpth tx-fifo-depth $node hexint
		set_drv_conf_prop $drv_handle c_can_rx_dpth rx-fifo-depth $node hexint

		set ecc [hsi get_property CONFIG.ENABLE_ECC [hsi::get_cells -hier $drv_handle]]
		if { $ecc == 1} {
			add_prop $node "xlnx,has-ecc" "" boolean $dts_file
		}

		set proc_type [get_hw_family]
		if {[regexp "microblaze" $proc_type match]} {
			gen_dev_ccf_binding $drv_handle "s_axi_aclk"
		}
	}
