#
# (C) Copyright 2019-2021 Xilinx, Inc.
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

proc ipipsu_generate {drv_handle} {
	set ipi_list [hsi get_cells -hier -filter {IP_NAME == "psu_ipi" || IP_NAME == "psv_ipi" || IP_NAME == "psx_ipi" || IP_NAME == "ipi"}]
	set src_buffer_base [hsi get_property CONFIG.C_BUFFER_BASE $drv_handle]
	set base [get_baseaddr $drv_handle]
	set node [get_node $drv_handle]
	set proctype [get_hw_family]
	set dts_file "pcw.dtsi"

	add_prop $node "xlnx,ipi-target-count" [llength $ipi_list] int $dts_file

	# Map IPI nodes to corresponding CPU Master
	ipi_cpu_mapping $drv_handle $node $base

	# Generate all the available IPI child nodes
	generate_ipi_child_nodes $ipi_list $node $drv_handle $src_buffer_base $dts_file $proctype
}

# Generate IPI child nodes
proc generate_ipi_child_nodes {ipi_list node drv_handle buffer_base dts_file proctype} {
	# Constants for buffer calculations
	set default_buffer_index 0xffff
	set response_offset 0x20
	set buffer_size 64

	set src [hsi get_property CONFIG.C_BUFFER_INDEX [hsi get_cells -hier $drv_handle]]
	set child_node_label [hsi get_property NAME $drv_handle]
	set node_space "_"
	set idx 0

	foreach ipi_slave $ipi_list {
		# Create child node for this IPI slave
		set slv_node [create_node -n "child" -l "$child_node_label$node_space$idx" -u $idx -d $dts_file -p $node]

		# Get hardware properties for this slave
		set buffer_index [hsi get_property CONFIG.C_BUFFER_INDEX [hsi get_cells -hier $ipi_slave]]
		set bit_position [hsi get_property CONFIG.C_BIT_POSITION [hsi get_cells -hier $ipi_slave]]

		# Normalize buffer index - handle NIL and empty values
		if {[string match -nocase $buffer_index "NIL"] || [string_is_empty $buffer_index]} {
			set buffer_index $default_buffer_index
		} else {
			# Configure buffer addresses only if both buffer_index and src are valid
			if {![string match -nocase $src "NIL"]} {
				set req_base [expr $buffer_base + $buffer_size * $buffer_index]
				set res_base [expr $req_base + $response_offset]
				add_prop $slv_node "xlnx,ipi-req-msg-buf" $req_base hexint $dts_file
				add_prop $slv_node "xlnx,ipi-rsp-msg-buf" $res_base hexint $dts_file
			}
		}

		# Add xlnx,ipi-id
		add_ipi_id $slv_node $proctype $ipi_slave $dts_file $bit_position

		# Add buffer index property
		add_prop $slv_node "xlnx,ipi-buf-index" $buffer_index int $dts_file

		# Calculate and add bitmask property
		set bit_mask [expr 1 << $bit_position]
		add_prop $slv_node "xlnx,ipi-bitmask" $bit_mask int $dts_file
		incr idx
	}
}

# Configure and add IPI ID based on platform type
proc add_ipi_id {node proctype ipi_slave dts_file bit_position} {
	if {[is_zynqmp_platform $proctype]} {
		# Using a dictionary to create baseaddress-ID mapping
		set ipi_id [dict create 0xff300000 0 0xff310000 1 0xff320000 2 0xff330000 3 0xff331000 4 0xff332000 5 0xff333000 6 0xff340000 7 0xff350000 8 0xff360000 9 0xff370000 10]
		set slave_base [get_baseaddr $ipi_slave]
		add_prop $node "xlnx,ipi-id" [dict get $ipi_id $slave_base] int $dts_file
	} else {
		add_prop $node "xlnx,ipi-id" $bit_position int $dts_file
	}
}

# Configure memory mapping for IPI based on CPU type
proc ipi_cpu_mapping {drv_handle node base} {
	set cpu [hsi get_property CONFIG.C_CPU_NAME [hsi::get_cells -hier $drv_handle]]
	set node_label [string trimleft $node "&"]
	set memmap_key [get_cpu_memmap_key $cpu]

	if {[llength $node] > 1} {
		set node_label [lindex [split $node_label ":"] 0]
	}

	if {![string_is_empty $memmap_key]} {
		set high [get_highaddr $drv_handle]
		set size [format 0x%x [expr {${high} - ${base} + 1}]]
		set_memmap $node_label $memmap_key "0x0 $base 0x0 $size"
	}
}

# Map CPU name to memory map identifier
proc get_cpu_memmap_key {cpu} {
	set r5_procs [hsi::get_cells -hier -filter {IP_NAME==psv_cortexr5 || IP_NAME==psu_cortexr5 || IP_NAME==psx_cortexr52 || IP_NAME==cortexr52}]
	set memmap_key ""
	switch $cpu {
		"APU" - "A72" - "A78_0" {
			set memmap_key "a53"
		}
		"RPU0" - "R5_0" - "R52_0" {
			set memmap_key [lindex $r5_procs 0]
		}
		"RPU1" - "R5_1" - "R52_1" {
			set memmap_key [lindex $r5_procs 1]
		}
		"R52_2" {
			set memmap_key [lindex $r5_procs 2]
		}
		"R52_3" {
			set memmap_key [lindex $r5_procs 3]
		}
		"R52_4" {
			set memmap_key [lindex $r5_procs 4]
		}
		"R52_5" {
			set memmap_key [lindex $r5_procs 5]
		}
		"R52_6" {
			set memmap_key [lindex $r5_procs 6]
		}
		"R52_7" {
			set memmap_key [lindex $r5_procs 7]
		}
		"R52_8" {
			set memmap_key [lindex $r5_procs 8]
		}
		"R52_9" {
			set memmap_key [lindex $r5_procs 9]
		}
		"PSM" {
			set memmap_key "psm"
		}
		"PMC" {
			set memmap_key "pmc"
		}
		"PMU" {
			set memmap_key "pmu"
		}
		"ASU" {
			set memmap_key "asu"
		}
	}
	return $memmap_key
}
