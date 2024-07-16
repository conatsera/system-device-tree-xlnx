#
# (C) Copyright 2024 Advanced Micro Devices, Inc. All Rights Reserved.
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

proc gen_zocl_node {family} {
	global pl_ip_list
	if {![llength $pl_ip_list]} {
		dtg_warning "dt_zocl enabled and No PL ip's found in specified design, skip adding zocl node"
		return
	}
	set bus_node "amba_pl: amba_pl"
	set default_dts "pl.dtsi"
	set family [get_hw_family]
	set zocl_node [create_node -n "zyxclmm_drm" -d ${default_dts} -p $bus_node]
	if {$family in {"zynq" "zynqmp"}} {
	       add_prop $zocl_node "compatible" "xlnx,zocl" string $default_dts
	} else {
	       add_prop $zocl_node "compatible" "xlnx,zocl-versal" string $default_dts
	}
	set intr_ctrl [hsi::get_cells -hier -filter {IP_NAME == axi_intc}]
	set intr_extended ""
	foreach ctrl $intr_ctrl {
		set ctrl_node [get_node $ctrl]
		if {![string_is_empty $ctrl_node]} {
			set ctrl_node_label [lindex [split $ctrl_node ": "] 0]
			set ctrl_ref "&${ctrl_node_label}"
			set intr_num_range 32
			if {$ctrl != [lindex $intr_ctrl 0]} {
				set intr_num_range 31
			}
			for {set i 0} {$i < $intr_num_range} {incr i} {
				append intr_extended "<$ctrl_ref $i 4>"
				if {($i != ($intr_num_range - 1)) || ($ctrl != [lindex $intr_ctrl end])} {
					append intr_extended ", "
				}
			}
		}
	}
	if {[llength $intr_ctrl]} {
		if {![string_is_empty $intr_extended]} {
			add_prop $zocl_node "interrupts-extended" $intr_extended noformating $default_dts
		}
	} else {
		# if axi_intc not found then use gic controller
		set intr_num "<0x0 0x89 0x4>, <0x0 0x90 0x4>, <0x0 0x91 0x4>, <0x0 0x92 0x4>, <0x0 0x93 0x4>, <0x0 0x94 0x4>, <0x0 0x95 0x4>, <0x0 0x96 0x4>"
		add_prop $zocl_node "interrupt-parent" imux reference $default_dts
		add_prop $zocl_node "interrupts" $intr_num noformating $default_dts
	}

	set decouplers [hsi get_cells -hier -filter {IP_NAME == "dfx_decoupler"}]
	set count 1
	foreach decoupler $decouplers {
		if { $count == 1 } {
			add_prop "$zocl_node" "xlnx,pr-decoupler" "" boolean $default_dts
		} else {
			#zocl driver not supporting multiple decouplers so display warning.
			dtg_warning "Multiple dfx_decoupler IPs found in the design,\
				using pr-isolation-addr from [lindex [split $decouplers " "] 0] IP"
			break
		}
		set baseaddr [hsi get_property CONFIG.C_BASEADDR [hsi get_cells -hier $decoupler]]
		if {[llength $baseaddr]} {
			set baseaddr "0x0 $baseaddr"
			add_prop "$zocl_node" "xlnx,pr-isolation-addr" "$baseaddr" hexlist $default_dts
		}
		incr count
	}
}