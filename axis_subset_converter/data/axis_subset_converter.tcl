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

proc axis_subset_converter_generate {drv_handle} {
        set ip $drv_handle
	set bus_node [detect_bus_name $ip]
        set dts_file [set_drv_def_dts $drv_handle]
        set subset_node [create_node -n "axis_subset$ip" -l $ip -u 0 -p $bus_node -d $dts_file]
	set ip_name [hsi get_property IP_NAME [hsi get_cells -hier $drv_handle]]
	set ips [hsi get_cells -hier -filter {IP_NAME == "axis_subset_converter"}]
	pldt append $subset_node compatible "\"xlnx,axis-subsetconv-1.1\""
        set ports_node [create_node -n "ports" -l axis_subset_ports$ip -p $subset_node -d $dts_file]
        add_prop "$ports_node" "#address-cells" 1 int $dts_file
        add_prop "$ports_node" "#size-cells" 0 int $dts_file
        set port_node [create_node -n "port" -l axis_subset_port1$drv_handle -u 1 -p $ports_node -d $dts_file]
        add_prop "$port_node" "reg" 1 int $dts_file
        add_prop "$port_node" "xlnx,video-format" 12 int $dts_file
	set outip [get_connected_stream_ip [hsi::get_cells -hier $drv_handle] "m_axis_video"]
	set intf [hsi::get_intf_pins -of_objects [hsi::get_cells -hier $ip] -filter {TYPE==SLAVE || TYPE ==TARGET}]
	set inip [get_connected_stream_ip [hsi::get_cells -hier $ip] $intf]
		if {[llength $ip]} {
			set master_intf [::hsi::get_intf_pins -of_objects [hsi::get_cells -hier $ip] -filter {TYPE==MASTER || TYPE ==INITIATOR}]
			set ip_mem_handles [hsi::get_mem_ranges $ip]
			if {[llength $ip_mem_handles]} {
				set base [string tolower [hsi get_property BASE_VALUE $ip_mem_handles]]
				set subset_node [create_node -n "endpoint" -l subset_out$drv_handle -p $port_node -d $dts_file]
				gen_endpoint $drv_handle "subset_out$drv_handle"
				add_prop "$subset_node" "remote-endpoint" $drv_handle reference $dts_file
				gen_remoteendpoint $drv_handle "$ip$drv_handle"
				if {[string match -nocase [hsi get_property IP_NAME $ip] "v_frmbuf_wr"]} {
					axis_subset_gen_frmbuf_wr_node $ip $drv_handle $dts_file
				}
			} else {
				if {[string match -nocase [hsi get_property IP_NAME $ip] "system_ila"]} {
					continue
				}
			}
			set connectip [get_connect_ip $ip $master_intf $dts_file]
			puts "connect ip is = $connectip"
			if {[llength $connectip]} {
				#to handle scaler subsystem IP
				set sub_set_inip [get_connected_stream_ip [hsi::get_cells -hier $drv_handle] "S_AXIS"]
				set subset_node [create_node -n "endpoint" -l $drv_handle$connectip -p $port_node -d $dts_file]
				gen_endpoint $drv_handle "subset_out$drv_handle"
				if {[string match -nocase [hsi get_property IP_NAME $sub_set_inip] "v_proc_ss"]} {
					dtg_warning "$drv_handle scaler sub-core use case skipped.!"
				#	add_prop "$subset_node" "remote-endpoint" "" reference $dts_file
					return
				}
				add_prop "$subset_node" "remote-endpoint" $connectip$drv_handle reference $dts_file
				gen_remoteendpoint $drv_handle "$connectip$drv_handle"
				if {[string match -nocase [hsi get_property IP_NAME $connectip] "v_frmbuf_wr"]} {
					axis_subset_gen_frmbuf_wr_node $connectip $drv_handle $dts_file
				}
			}
		} else {
			dtg_warning "$drv_handle pin m_axis_video is not connected..check your design"
	}
}

proc axis_subset_converter_update_endpoints {drv_handle} {
        set ip $drv_handle
	set node [get_node $drv_handle]
        set dts_file [set_drv_def_dts $drv_handle]
        set axis_subset_inip [get_connected_stream_ip [hsi::get_cells -hier $drv_handle] "S_AXIS"]
        set subset_inip [get_connected_stream_ip [hsi::get_cells -hier $drv_handle] "S_AXIS_VIDEO"]
	set master_intf [hsi::get_intf_pins -of_objects [hsi get_cells -hier $subset_inip] -filter {TYPE==SLAVE || TYPE ==TARGET}]

        if {[string_is_empty $node]} {
                return
        }
	global end_mappings
	global remo_mappings
	set ports_node [create_node -n "ports" -l axis_subset_ports$drv_handle -p $node -d $dts_file]
	add_prop "$ports_node" "#address-cells" 1 int $dts_file 1
	add_prop "$ports_node" "#size-cells" 0 int $dts_file 1
        set port0_node [create_node -n "port" -l axis_subset_port0$axis_subset_inip -u 0 -p $ports_node -d $dts_file]
        add_prop "$port0_node" "reg" 0 int $dts_file
	add_prop "$port0_node" "xlnx,video-format" 12 int $dts_file
        set len [llength $axis_subset_inip]
	global port1_broad_end_mappings
	if {$len > 1} {
		for {set i 0 } {$i < $len} {incr i} {
			set temp_ip [lindex $axis_subset_inip $i]
			if {[regexp -nocase "ila" $temp_ip match]} {
				continue
			}
			set axis_subset_inip "$temp_ip"
		}
	}

	if {[string match -nocase [hsi get_property IP_NAME $axis_subset_inip] "mipi_csi2_rx_subsystem"]} {
		set subset_sink_node [create_node -n "endpoint" -l $drv_handle$axis_subset_inip -p $port0_node -d $dts_file]
		add_prop "$subset_sink_node" "remote-endpoint" $axis_subset_inip$drv_handle reference $dts_file
	}
        if {![llength $subset_inip]} {
		dtg_warning "$drv_handle pin S_AXIS_VIDEO is not connected..check your design"
        } else {
		set inip [get_in_connect_ip $subset_inip $master_intf]
		if {[llength $inip]} {
			set subset_in_end "":w
			set subset_remo_in_end ""
			if {[info exists end_mappings] && [dict exists $end_mappings $inip]} {
				set subset_in_end [dict get $end_mappings $inip]
			}
			if {[info exists remo_mappings] && [dict exists $remo_mappings $inip]} {
				set subset_remo_in_end [dict get $remo_mappings $inip]
			}
			if {[llength $subset_remo_in_end]} {
				set subset_node [create_node -n "endpoint" -l $subset_remo_in_end -p $port0_node -d $dts_file]
			}
			if {[llength $subset_in_end]} {
				add_prop "$subset_node" "remote-endpoint" $subset_in_end reference $dts_file
			}
		}
	}
}

proc axis_subset_gen_frmbuf_wr_node {outip drv_handle dts_file} {
	set bus_node [detect_bus_name $drv_handle]
	set vcap [create_node -n "vcap_$drv_handle" -p $bus_node -d $dts_file]
	add_prop $vcap "compatible" "xlnx,video" string $dts_file
	add_prop $vcap "dmas" "$outip 0" reference $dts_file
	add_prop $vcap "dma-names" "port0" string $dts_file
	set vcap_ports_node [create_node -n "ports" -l vcap_ports$drv_handle -p $vcap -d $dts_file]
	add_prop "$vcap_ports_node" "#address-cells" 1 int $dts_file
	add_prop "$vcap_ports_node" "#size-cells" 0 int $dts_file
	set vcap_port_node [create_node -n "port" -l vcap_port$drv_handle -u 0 -p $vcap_ports_node -d $dts_file]
	add_prop "$vcap_port_node" "reg" 0 int $dts_file
	add_prop "$vcap_port_node" "direction" input string $dts_file
	set vcap_in_node [create_node -n "endpoint" -l $outip$drv_handle -p $vcap_port_node -d $dts_file]
	gen_endpoint $drv_handle "demo_out$drv_handle"
	add_prop "$vcap_in_node" "remote-endpoint" demo_out$drv_handle reference $dts_file
	gen_remoteendpoint $drv_handle "$outip$drv_handle"
}
