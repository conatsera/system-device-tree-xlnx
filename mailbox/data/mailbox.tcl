#
# (C) Copyright 2024 - 2025 Advanced Micro Devices, Inc. All Rights Reserved.
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

proc mailbox_generate {drv_handle} {
	set node [get_node $drv_handle]
	if {$node == 0} {
		return
	}

	#Obtain interrupt values
	set intr_val ""
	set intr_parent ""
	if {[catch {
		set intr_val [pldt get $node interrupts]
		set intr_parent [pldt get $node interrupt-parent]
	}]} {
		set intr_val ""
		set intr_parent ""
	}

	set intr_val [string trimright $intr_val ">"]
	set intr_val [string trimleft $intr_val "<"]
	set intr_parent [string trimright $intr_parent ">"]
	set intr_parent [string trimleft $intr_parent "<"]
	set intr_parent [string trimleft $intr_parent "&"]

	#Delete the Mailbox Core node
	pldt delete $node

	set proclist [hsi::get_cells -hier -filter IP_TYPE==PROCESSOR]

	#Create 2 Mailbox nodes for each Mailbox IP
	foreach processor $proclist {
		for {set port_id 0} {$port_id < 2} {incr port_id} {
			# port_interface: 2 = AXI4-Lite, 4 = AXI4-Stream
			set port_interface [common::get_property CONFIG.[format "C_INTERCONNECT_PORT_%d" $port_id] $drv_handle]
			create_mbox_nodes $drv_handle $port_interface $port_id $processor $intr_val $intr_parent
		}
	}
}

proc create_mbox_nodes {drv_handle port_interface port_id processor intr_val intr_parent} {

	#Identify if the processor is 32-bit or 64-bit
	set family [get_hw_family]
	global is_64_bit_mb
	if {$family in {"microblaze" "Zynq"} && !$is_64_bit_mb} {
		set bit_format 32
	} else {
		set bit_format 64
	}

	set ip_name [hsi::get_property IP_NAME $drv_handle]
	set name [hsi::get_property NAME $drv_handle]
	set bus_name [detect_bus_name $drv_handle]
	set compatible [get_comp_str $drv_handle]
	set label_name ${drv_handle}_S${port_id}
	set dts_file pl.dtsi
	set size 0x10000

	set is_axi4lite_connected	0
	set mbox_baseaddr	0
	set mbox_send_fsl	0
	set mbox_recv_fsl	0
	set mbox_use_fsl	0
	set use_fsl	0

	set mbox_delete_node	0

	set periph_name [string toupper [common::get_property NAME $drv_handle]]

	if {$port_interface == 2} {
		#AXI4LITE interface
		set mbox_baseaddr [common::get_property CONFIG.[format "C_S%d_AXI_BASEADDR" $port_id] $drv_handle]
		set mbox_highaddr [common::get_property CONFIG.[format "C_S%d_AXI_HIGHADDR" $port_id] $drv_handle]
		set is_axi4lite_connected [check_if_connected $drv_handle $port_id $port_interface $processor]
	} else {
		#AXI4STREAM interface
		set send_fsl 0
		set recv_fsl  0
		set delete_node	0

		handle_stream $drv_handle $port_interface $port_id $processor use_fsl send_fsl recv_fsl delete_node
		set is_axi4lite_connected	0

		set mbox_use_fsl        $use_fsl
		set mbox_send_fsl       $send_fsl
		set mbox_recv_fsl       $recv_fsl

		set mbox_delete_node	$delete_node
	}

	if {$mbox_baseaddr != 0} {
		set nodename_baseaddr [format %lx $mbox_baseaddr]
	} else {
		set mbox_baseaddr 0x0
		set mbox_highaddr 0xFFFF
		set nodename_baseaddr 0
	}

	set node [create_node -n $label_name -l $label_name -u $nodename_baseaddr -p $bus_name -d $dts_file]
	set reg [gen_reg_property_format $mbox_baseaddr $mbox_highaddr $bit_format]

	if { $is_axi4lite_connected == 1 || $use_fsl == 1 } {
		#Add properties to the node
		add_prop "${node}" "xlnx,send-fsl" $mbox_send_fsl int $dts_file
		add_prop "${node}" "xlnx,recv-fsl" $mbox_recv_fsl int $dts_file
		add_prop "${node}" "xlnx,use-fsl" $mbox_use_fsl int $dts_file
		add_prop "${node}" "compatible" $compatible string $dts_file
		add_prop "${node}" "xlnx,ip-name" $ip_name string $dts_file
		add_prop "${node}" "xlnx,name" $name string $dts_file
		add_prop "${node}" "status" "okay" string $dts_file
		add_prop "${node}" "reg" $reg hexlist $dts_file

		#Append generic compatible string
		pldt append $node compatible "\ \, \"xlnx,mailbox\""

		#Add interrupt properties
		if {![string_is_empty $intr_val]} {
			add_prop "${node}" "interrupts" $intr_val intlist $dts_file
		}
		if {![string_is_empty $intr_parent]} {
			add_prop "${node}" "interrupt-parent" $intr_parent reference  $dts_file
		}

		#Processor mapping
		map_node_to_processor "${label_name}" $processor $reg $bit_format $mbox_baseaddr $size
	}

	#Delete node if C_USE_EXTENDED_FSL_INSTR not enabled on Microblaze for AXI Stream interface connectivity with mailbox core
	if { $mbox_delete_node == 1 } {
		pldt delete $node
	}
}

proc check_if_connected {periph port_id port_interface processor} {
	set is_axi4lite_connected 0
	set if_axistream_connected 0

	if {$port_interface == 2} {
		#Check if AXI4LITE interface is connected.
		set baseaddr [common::get_property CONFIG.[format "C_S%d_AXI_BASEADDR" $port_id] $periph]
		set mem [hsi::get_mem_ranges -of_objects [hsi::get_cells -hier $processor] -filter INSTANCE==$periph]
		if {[llength [lindex $mem 0]] != 0} {
			set addrs [common::get_property BASE_VALUE $mem]
			if {$addrs == $baseaddr} {
				set is_axi4lite_connected 1
			}
		}
	} else {
		set delete_node	0
		set recv_fsl  0
		set send_fsl 0
		set use_fsl 0

		handle_stream $periph $bus_if $if_num $processor use_fsl send_fsl recv_fsl delete_node
		set if_axistream_connected $use_fsl
	}
	if {$is_axi4lite_connected || $if_axistream_connected} {
		return 1
	} else {
		return 0
	}
}

proc handle_stream {periph port_interface port_id processor usefsl sendfsl recvfsl deletenode} {
	upvar $recvfsl   recv_fsl
	upvar $sendfsl  send_fsl
	upvar $usefsl   use_fsl

	upvar $deletenode	delete_node

	set not_connected 0

	set periph_name [string toupper [common::get_property NAME $periph]]
	set initiator_handle [get_connected_intf $periph S${port_id}_AXIS]
	if { [llength $initiator_handle] == 0 } {
		incr not_connected
	} else {
		set maxis_initiator_handle [hsi::get_cells -of_objects $initiator_handle]
		if { $maxis_initiator_handle == $processor } {
			if {[common::get_property CONFIG.C_USE_EXTENDED_FSL_INSTR $processor] != 1 } {
				puts "WARNING: The mailbox node requires parameter C_USE_EXTENDED_FSL_INSTR on MicroBlaze to be enabled when an AXI Stream interface is used to connect the mailbox core."
				set delete_node	1
			}
			set initiator_name [common::get_property NAME $initiator_handle]
			scan $initiator_name "M%d_AXIS" send_fsl
			set use_fsl 1
		} else {
			set use_fsl 0
		}
	}

	set target_handle [get_connected_intf $periph M${port_id}_AXIS]
	if { [llength $target_handle] == 0 } {
		incr not_connected
	} else {
		set saxis_target_handle [hsi::get_cells -of_objects $target_handle]
		if { $saxis_target_handle == $processor } {
			if {[common::get_property CONFIG.C_USE_EXTENDED_FSL_INSTR $processor] != 1 } {
				puts "WARNING: The mailbox node requires parameter C_USE_EXTENDED_FSL_INSTR on MicroBlaze to be enabled when an AXI Stream interface is used to connect the mailbox core."
				set delete_node	1
			}
			set target_name [common::get_property NAME $target_handle]
			scan $target_name "S%d_AXIS" recv_fsl
			set use_fsl 1
		} else {
			set use_fsl 0
		}
	}

	if { $not_connected == 2 } {
		puts "WARNING: Unable to figure out AXI stream connectivity for Interface ${if_num} on mailbox $periph_name."
		set delete_node	1
	}
}
