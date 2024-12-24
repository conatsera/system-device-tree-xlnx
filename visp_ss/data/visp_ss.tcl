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

#IBA
proc add_iba_properties {drv_handle port_node dts_file isp_index iba_index tile_index} {
	set prefix "CONFIG.C_TILE${tile_index}_ISP${isp_index}_IBA${iba_index}_"
	set data_format [get_ip_property $drv_handle "${prefix}DATA_FORMAT"]
	set fps [get_ip_property $drv_handle "${prefix}FPS"]
	set ppc [get_ip_property $drv_handle "${prefix}PPC"]
	set max_width [get_ip_property $drv_handle "${prefix}RES_HOR"]
	set max_height [get_ip_property $drv_handle "${prefix}RES_VER"]
	set vcid [get_ip_property $drv_handle "${prefix}VCID"]
	add_prop "$port_node" "xlnx,iba${iba_index}_vcid" $vcid int $dts_file
	add_prop "$port_node" "xlnx,iba${iba_index}_max-height" $max_height int $dts_file
	add_prop "$port_node" "xlnx,iba${iba_index}_data_format" $data_format int $dts_file
	add_prop "$port_node" "xlnx,iba${iba_index}_ppc" $ppc int $dts_file
	add_prop "$port_node" "xlnx,iba${iba_index}_max-width" $max_width int $dts_file
	add_prop "$port_node" "xlnx,iba${iba_index}_frame_rate" $fps int $dts_file
}


#OBA_MP
proc add_oba_properties_mp {drv_handle port_node dts_file isp_index oba_index tile_index} {
	set config_properties {
		"CONFIG.C_TILE0_ISP0_OBA0_MP_YUV420"
		"CONFIG.C_TILE0_ISP0_OBA0_MP_YUV422"
		"CONFIG.C_TILE0_ISP1_OBA0_MP_YUV420"
		"CONFIG.C_TILE0_ISP1_OBA0_MP_YUV422"
		"CONFIG.C_TILE1_ISP0_OBA0_MP_YUV420"
		"CONFIG.C_TILE1_ISP0_OBA0_MP_YUV422"
		"CONFIG.C_TILE1_ISP1_OBA0_MP_YUV420"
		"CONFIG.C_TILE1_ISP1_OBA0_MP_YUV422"
		"CONFIG.C_TILE2_ISP0_OBA0_MP_YUV420"
		"CONFIG.C_TILE2_ISP0_OBA0_MP_YUV422"
		"CONFIG.C_TILE2_ISP1_OBA0_MP_YUV420"
		"CONFIG.C_TILE2_ISP1_OBA0_MP_YUV422"
	}
	set mp_data_format ""
	set sp_data_format ""
	foreach config_name $config_properties {
		set is_enabled [get_ip_property $drv_handle $config_name]
		if {$is_enabled eq "true"} {
			if {[string match *MP* $config_name]} {
				set format_type "MP"
				set format_name [string range $config_name [expr [string last "_" $config_name] + 1] end]
				set mp_data_format $format_name
			} elseif {[string match *SP* $config_name]} {
				set format_type "SP"
				set format_name [string range $config_name [expr [string last "_" $config_name] + 1] end]
				set sp_data_format $format_name
			}
		}
	}
	set prefix "CONFIG.C_TILE${tile_index}_ISP${isp_index}_OBA${oba_index}_"
	set mp_bpp [get_ip_property $drv_handle "${prefix}MP_BPP"]
	set mp_ppc [get_ip_property $drv_handle "${prefix}PPC"]
	add_prop "$port_node" "xlnx,oba${oba_index}_mp_bpp" $mp_bpp int $dts_file
	add_prop "$port_node" "xlnx,oba${oba_index}_mp_data_format" $mp_data_format string $dts_file
	add_prop "$port_node" "xlnx,oba${oba_index}_mp_ppc" $mp_ppc int $dts_file
}


#OBA_SP
proc add_oba_properties_sp {drv_handle port_node dts_file isp_index oba_index tile_index} {
	set config_properties {
		"CONFIG.C_TILE0_ISP0_OBA0_SP_YUV420"
		"CONFIG.C_TILE0_ISP0_OBA0_SP_YUV422"
		"CONFIG.C_TILE0_ISP1_OBA0_SP_YUV420"
		"CONFIG.C_TILE0_ISP1_OBA0_SP_YUV422"
		"CONFIG.C_TILE1_ISP0_OBA0_SP_YUV420"
		"CONFIG.C_TILE1_ISP0_OBA0_SP_YUV422"
		"CONFIG.C_TILE1_ISP1_OBA0_SP_YUV420"
		"CONFIG.C_TILE1_ISP1_OBA0_SP_YUV422"
		"CONFIG.C_TILE2_ISP0_OBA0_SP_YUV420"
		"CONFIG.C_TILE2_ISP0_OBA0_SP_YUV422"
		"CONFIG.C_TILE2_ISP1_OBA0_SP_YUV420"
		"CONFIG.C_TILE2_ISP1_OBA0_SP_YUV422"
	}
	set sp_data_format ""
	foreach config_name $config_properties {
		set is_enabled [get_ip_property $drv_handle $config_name]
		if {$is_enabled eq "true"} {
			if {[string match *MP* $config_name]} {
				set format_type "MP"
				set format_name [string range $config_name [expr [string last "_" $config_name] + 1] end]
				set mp_data_format $format_name
			} elseif {[string match *SP* $config_name]} {
				set format_type "SP"
				set format_name [string range $config_name [expr [string last "_" $config_name] + 1] end]
				set sp_data_format $format_name
			}
		}
	}
	set prefix "CONFIG.C_TILE${tile_index}_ISP${isp_index}_OBA${oba_index}_"
	set sp_bpp [get_ip_property $drv_handle "${prefix}SP_BPP"]
	set sp_ppc [get_ip_property $drv_handle "${prefix}PPC"]
	add_prop "$port_node" "xlnx,oba${oba_index}_sp_bpp" $sp_bpp int $dts_file
	add_prop "$port_node" "xlnx,oba${oba_index}_sp_data_format" $sp_data_format string $dts_file
	add_prop "$port_node" "xlnx,oba${oba_index}_sp_ppc" $sp_ppc int $dts_file
}


#VISP_SS MAIN
proc visp_ss_generate {drv_handle} {
	set node [get_node $drv_handle]
	if {$node == 0} {
		return
	}
	set default_dts [set_drv_def_dts $drv_handle]
	set bus_name [detect_bus_name $drv_handle]
	set baseaddr [get_baseaddr [hsi get_cells -hier $drv_handle] no_prefix]
	set sub_region_size 0x10000  ;# 64 KB
	set intr_val [pldt get $node interrupts]
	set intr_val [string trimright $intr_val ">"]
	set intr_val [string trimleft $intr_val "<"]
	# Get interrupt names
	set intr_names [pldt get $node interrupt-names]
	set intr_names [string map {"," "" "\"" ""} $intr_names]

	set intr_mapping {}
	set reg_mapping {}
	for {set i 0} {$i < [llength $intr_names]} {incr i} {
		# Extract the next three values (base address, IRQ number, flags)
		set value [lrange $intr_val [expr $i * 3] [expr $i * 3 + 2]]
		# Map the name to its value
		dict set intr_mapping [lindex $intr_names $i] $value
	}
	pldt delete $node
	for {set tile 0} {$tile < 3} {incr tile} {
		set tile_enabled [get_ip_property $drv_handle "CONFIG.C_TILE${tile}_ENABLE"]
		if {!$tile_enabled} {
			continue
		}
		for {set isp 0} {$isp < 2} {incr isp} {
			set isp_id [expr {$tile * 2 + $isp}]
			set sub_node_label "visp_ss_${isp_id}"
			set sub_baseaddr [format %08x [expr 0x$baseaddr + $isp_id * $sub_region_size]]
			set sub_node [create_node -l ${sub_node_label} -n "visp_ss" -u $sub_baseaddr -p $bus_name -d $default_dts]
			set reg_value "0x0 0x$sub_baseaddr 0x0 $sub_region_size"
			add_prop "$sub_node" "reg" $reg_value hexlist $default_dts
			add_prop "$sub_node" "status" "okay" string $default_dts
			dict set reg_mapping $sub_node_label $reg_value
			set ports_node [create_node -l "portss${tile}${isp}" -n "ports" -p $sub_node -d $default_dts]
			add_prop "$ports_node" "#address-cells" 1 int $default_dts
			add_prop "$ports_node" "#size-cells" 0 int $default_dts
			set live_stream [get_ip_property $drv_handle CONFIG.C_TILE${tile}_ISP${isp}_LIVE_INPUTS]
			set io_mode [get_ip_property $drv_handle CONFIG.C_TILE${tile}_ISP${isp}_IO_TYPE]
			set io_type [get_ip_property $drv_handle CONFIG.C_TILE${tile}_ISP${isp}_IO_TYPE]
			if {$io_type == 1} {
				set io_mode_name "lilo"
			} elseif {$io_type == 2} {
				set io_mode_name "limo"
			} elseif {$io_type == 3} {
				set io_mode_name "mimo"
			} else {
				set io_mode_name "Unknown"
			}
			set live_inputs [get_ip_property $drv_handle CONFIG.C_TILE${tile}_ISP${isp}_LIVE_INPUTS]
			set mem_inputs [get_ip_property $drv_handle CONFIG.C_TILE${tile}_ISP${isp}_MEM_INPUTS]
			set net_fps [get_ip_property $drv_handle CONFIG.C_TILE${tile}_ISP${isp}_NETFPS]
			set rpu [get_ip_property $drv_handle CONFIG.C_TILE${tile}_ISP${isp}_RPU]
			add_prop "$sub_node" "xlnx,io_mode" "$io_mode_name" string $default_dts
			add_prop "$sub_node" "xlnx,num_streams" $live_inputs int $default_dts
			add_prop "$sub_node" "xlnx,mem_inputs" $mem_inputs int $default_dts
			add_prop "$sub_node" "xlnx,netfps" $net_fps int $default_dts
			add_prop "$sub_node" "xlnx,rpu" $rpu int $default_dts
			add_prop "$sub_node" "isp_id" $isp_id int $default_dts
			set tile_intrnames ""
			dict for {key value} $intr_mapping {
				if {[string match "*tile${tile}_isp${isp}*" $key]} {
					add_prop "$sub_node" "interrupts" "$value" hexlist $default_dts
					append tile_intrnames " \"$key\""
				}
				if {$isp == 0} {
					if {[string match "*tile${tile}_isp_isr_irq*" $key] || [string match "*tile${tile}_isp_xmpu_interrupt*" $key]} {
						add_prop "$sub_node" "interrupts" "$value" hexlist $default_dts
						append tile_intrnames " \"$key\""
					}
				}
			}
			add_prop "$sub_node" "interrupt-names" $tile_intrnames stringlist $default_dts

			if {$io_type == 1} {
				set compatible_name "xlnx,visp-ss-lilo-1.0"
			} elseif {$io_type == 2} {
				set compatible_name "xlnx,visp-ss-limo-1.0"
			} elseif {$io_type == 3} {
				set compatible_name "xlnx,visp-ss-mimo-1.0"
			} else {
				set compatible_name "xlnx,Unknown"
			}

			add_prop "$sub_node" "compatible" "$compatible_name" string $default_dts
			isp_handle_condition $drv_handle $tile $isp $io_mode $live_stream $isp_id $ports_node $default_dts $sub_node $sub_node_label $bus_name
		}
	}

	set proclist [hsi::get_cells -hier -filter {IP_TYPE==PROCESSOR}]
	foreach proc $proclist {
		if {![string_is_empty [hsi get_mem_ranges -of_objects [hsi get_cells -hier $proc] -filter INSTANCE==$drv_handle]]} {
			set proc_ip_name [get_ip_property $proc IP_NAME]
			dict for {label reg_val} $reg_mapping {
				switch $proc_ip_name {
					"cortexr52" - "microblaze" - "microblaze_riscv" {
						set_memmap "${label}" $proc $reg_val
					}
					"cortexa78" {
						set_memmap "${label}" a53 $reg_val
					}
					"pmc" {
						set_memmap "${label}" pmc $reg_val
					}
					"asu" {
						set_memmap "${label}" asu $reg_val
					}
					default {
					}
				}
			}
		}
	}
}

proc create_vcp_node {sub_node default_dts isp_id bus_name} {
	set vcp_node [create_node -l vvcam_video_${isp_id} -n "vvcam_video.${isp_id}" -p $bus_name -d $default_dts]
	add_prop "$vcp_node" "compatible" "xlnx,visp-video" string $default_dts
	add_prop "$vcp_node" "status" "okay" string $default_dts
	return $vcp_node
}

#IO_MODE==2 (LIMO)
proc handle_io_mode_2 {drv_handle tile isp ports_node isp_id default_dts sub_node sub_node_label live_stream bus_name io_mode} {
	set vcp_node [create_vcp_node $sub_node $default_dts $isp_id $bus_name]
	set vcap_ports_node [create_node -l "vcap_ports${tile}${isp}" -n "ports" -p $vcp_node -d $default_dts]
	add_prop "$vcap_ports_node" "#address-cells" 1 int $default_dts
	add_prop "$vcap_ports_node" "#size-cells" 0 int $default_dts
	set reg_counter 1
	for {set iba 0} {$iba < $live_stream} {incr iba} {
		for {set j 0} {$j < 5} {incr j} {
			set port_idx [expr $iba * 5 + $j]
			add_iba_properties $drv_handle $sub_node $default_dts $isp $iba $tile
			if {$isp == 1 && $io_mode == 2 && $live_stream <= 2 && $port_idx % 5 == 0} {
				set iba_values {}
				if {$live_stream == 1} {
					lappend iba_values 4
				} elseif {$live_stream == 2} {
					lappend iba_values 4 3
				}
				foreach iba $iba_values {
					set visp_ip_name "TILE${tile}_ISP_MIPI_VIDIN${iba}"
					set visp_inip [get_connected_stream_ip [hsi::get_cells -hier $drv_handle] $visp_ip_name]
					visp_ss_inip_endpoints $drv_handle $ports_node $default_dts "${sub_node_label}${port_idx}" $visp_inip
				}
			} elseif {$port_idx % 5 == 0} {
				set visp_ip_name "TILE${tile}_ISP_MIPI_VIDIN${iba}"
				set visp_inip [get_connected_stream_ip [hsi::get_cells -hier $drv_handle] $visp_ip_name]
				visp_ss_inip_endpoints $drv_handle $ports_node $default_dts "${sub_node_label}${port_idx}" $visp_inip
			} else {
				if {$port_idx % 5 == 1} {
					set port [create_node -n "port${tile}${isp}@${port_idx}" -p $ports_node -d $default_dts]
					add_prop "$port" "reg" $port_idx int $default_dts
					set endpoint_node_mp [create_node -n "vvcam_isp${isp_id}_port${tile}${isp}${iba}_mp: endpoint" -p $port -d $default_dts]
					add_prop "$endpoint_node_mp" "remote-endpoint" vvcam_video_${isp_id}_${iba}_0 reference $default_dts
					add_prop "$endpoint_node_mp" "type" "output" string $default_dts


					set vcp_ports [create_node -n "v_port${tile}${isp}@${port_idx}" -p $vcap_ports_node -d $default_dts]
					add_prop "$vcp_ports" "reg" $reg_counter int $default_dts
					incr reg_counter
					set vcp_endpoint_node_mp [create_node -n "vvcam_video_${isp_id}_${iba}_0: endpoint" -p $vcp_ports -d $default_dts]
					add_prop "$vcp_endpoint_node_mp" "remote-endpoint" vvcam_isp${isp_id}_port${tile}${isp}${iba}_mp reference $default_dts
				}
				if {$port_idx % 5 == 2} {
					set port [create_node -n "port${tile}${isp}@${port_idx}" -p $ports_node -d $default_dts]
					add_prop "$port" "reg" $port_idx int $default_dts
					set endpoint_node_sp [create_node -n "vvcam_isp${isp_id}_port${tile}${isp}${iba}_sp: endpoint" -p $port -d $default_dts]
					add_prop "$endpoint_node_sp" "remote-endpoint" vvcam_video_${isp_id}_${iba}_1 reference $default_dts
					add_prop "$endpoint_node_sp" "type" "output" string $default_dts

					set vcp_ports1 [create_node -n "v_port${tile}${isp}@${port_idx}" -p $vcap_ports_node -d $default_dts]
					add_prop "$vcp_ports1" "reg" $reg_counter int $default_dts
					incr reg_counter
					set vcp_endpoint_node_sp [create_node -n "vvcam_video_${isp_id}_${iba}_1: endpoint" -p $vcp_ports1 -d $default_dts]
					add_prop "$vcp_endpoint_node_sp" "remote-endpoint" vvcam_isp${isp_id}_port${tile}${isp}${iba}_sp reference $default_dts
				}
			}
		}
	}
}

# IO_MODE==1 (LILO)
proc handle_io_mode_1 {drv_handle tile isp ports_node isp_id default_dts sub_node sub_node_label bus_name} {
	set port0 [create_node -n "port${tile}${isp}" -p $ports_node -d $default_dts]
	add_prop "$port0" "reg" 1 int $default_dts
	set pin_name ""
	if {$isp == 0} {
		set pin_name "TILE${tile}_ISP_MIPI_VIDIN0"
		set isp_iba 0
	} elseif {$isp == 1} {
		set pin_name "TILE${tile}_ISP_MIPI_VIDIN4"
		set isp_iba 4
	} else {
		return
	}
	set visp_inip [get_connected_stream_ip [hsi::get_cells -hier $drv_handle] $pin_name]
	visp_ss_inip_endpoints $drv_handle $ports_node $default_dts $sub_node_label $visp_inip
	set outip [get_connected_stream_ip [hsi::get_cells -hier $drv_handle] "TILE${tile}_ISP${isp}_VIDOUT_PO"]
	visp_ss_outip_endpoints $drv_handle $port0 $default_dts $sub_node_label $outip

	add_iba_properties $drv_handle $sub_node $default_dts $isp $isp_iba $tile
	# Add OBA properties
	add_oba_properties_mp $drv_handle $sub_node $default_dts $isp $isp $tile
	add_oba_properties_sp $drv_handle $sub_node $default_dts $isp $isp $tile
}

#conditions
proc isp_handle_condition {drv_handle tile isp io_mode live_stream isp_id ports_node default_dts sub_node sub_node_label bus_name} {
	if {$isp == 0 || $isp == 1} {
		if {$io_mode == 1} {
			handle_io_mode_1 $drv_handle $tile $isp $ports_node $isp_id $default_dts $sub_node $sub_node_label $bus_name
		} elseif {$io_mode == 2} {
			handle_io_mode_2 $drv_handle $tile $isp $ports_node $isp_id $default_dts $sub_node $sub_node_label $live_stream $bus_name $io_mode
		} else {
		}
	}
}

proc visp_ss_inip_endpoints {drv_handle node default_dts sub visp_inip} {
	global end_mappings
	global remo_mappings
	global port1_end_mappings
	global port2_end_mappings
	global port3_end_mappings
	global port4_end_mappings
	global axis_port1_remo_mappings
	global axis_port2_remo_mappings
	global axis_port3_remo_mappings
	global axis_port4_remo_mappings
	global port1_broad_end_mappings
	global broad_port1_remo_mappings
	global port2_broad_end_mappings
	global broad_port2_remo_mappings

	set port_node [create_node -n "port$sub" -l visp_ss_ports$sub$drv_handle -p $node -d $default_dts]
	add_prop "$port_node" "reg" 0 int $default_dts 1
	set len [llength $visp_inip]

	if {$len > 1} {
		for {set i 0} {$i < $len} {incr i} {
			set temp_ip [lindex $visp_inip $i]
			if {[regexp -nocase "ila" $temp_ip match]} {
				continue
			}
			set visp_inip "$temp_ip"
		}
	}

	foreach inip $visp_inip {
		if {[llength $inip]} {
			set ip_mem_handles [hsi::get_mem_ranges $inip]
			if {![llength $ip_mem_handles]} {
				set broad_ip [get_broad_in_ip $inip]
				if {[llength $broad_ip]} {
					if {[string match -nocase [hsi::get_property IP_NAME $broad_ip] "axis_broadcaster"]} {
						set master_intf [hsi::get_intf_pins -of_objects [hsi get_cells -hier $broad_ip] -filter {TYPE==MASTER || TYPE ==INITIATOR}]
						set intlen [llength $master_intf]
						set mipi_in_end ""
						set mipi_remo_in_end ""
						switch $intlen {
							"1" {
								if {[info exists port1_broad_end_mappings] && [dict exists $port1_broad_end_mappings $broad_ip]} {
									set mipi_in_end [dict get $port1_broad_end_mappings $broad_ip]
								}
								if {[info exists broad_port1_remo_mappings] && [dict exists $broad_port1_remo_mappings $broad_ip]} {
									set mipi_remo_in_end [dict get $broad_port1_remo_mappings $broad_ip]
								}
								if {[info exists sca_remo_in_end] && [regexp -nocase $drv_handle "$sca_remo_in_end" match]} {
									if {[llength $mipi_remo_in_end]} {
										set mipi_node [create_node -n "endpoint" -l $mipi_remo_in_end -p $port_node -d $default_dts]
									}
									if {[llength $mipi_in_end]} {
										add_prop "$mipi_node" "remote-endpoint" $mipi_in_end reference $default_dts
						}
								}
							}
							"2" {
								if {[info exists port1_broad_end_mappings] && [dict exists $port1_broad_end_mappings $broad_ip]} {
									set mipi_in_end [dict get $port1_broad_end_mappings $broad_ip]
								}
								if {[info exists broad_port1_remo_mappings] && [dict exists $broad_port1_remo_mappings $broad_ip]} {
									set mipi_remo_in_end [dict get $broad_port1_remo_mappings $broad_ip]
								}
								if {[info exists port2_broad_end_mappings] && [dict exists $port2_broad_end_mappings $broad_ip]} {
									set mipi_in1_end [dict get $port2_broad_end_mappings $broad_ip]
								}
								if {[info exists broad_port2_remo_mappings] && [dict exists $broad_port2_remo_mappings $broad_ip]} {
									set mipi_remo_in1_end [dict get $broad_port2_remo_mappings $broad_ip]
								}
								if {[info exists mipi_remo_in_end] && [regexp -nocase $drv_handle "$mipi_remo_in_end" match]} {
									if {[llength $mipi_remo_in_end]} {
										set mipi_node [create_node -n "endpoint" -l $mipi_remo_in_end -p $port_node -d $default_dts]
									}
									if {[llength $mipi_in_end]} {
										add_prop "$mipi_node" "remote-endpoint" $mipi_in_end reference $default_dts
									}
								}
								if {[info exists mipi_remo_in1_end] && [regexp -nocase $drv_handle "$mipi_remo_in1_end" match]} {
									if {[llength $mipi_remo_in1_end]} {
										set mipi_node [create_node -n "endpoint" -l $mipi_remo_in1_end -p $port_node -d $default_dts]
									}
									if {[llength $mipi_in1_end]} {
										add_prop "$mipi_node" "remote-endpoint" $mipi_in1_end reference $default_dts
									}
								}
							}
						}
							return
					}
				}
			}
		}

		if {[llength $visp_inip]} {
			if {[string match -nocase [hsi::get_property IP_NAME $visp_inip] "axis_switch"]} {
				set ip_mem_handles [hsi::get_mem_ranges $visp_inip]
				if {![llength $ip_mem_handles]} {
					set visp_in_end ""
					set visp_remo_in_end ""
					if {[info exists port1_end_mappings] && [dict exists $port1_end_mappings $visp_inip]} {
						set visp_in_end [dict get $port1_end_mappings $visp_inip]
						dtg_verbose "visp_in_end:$visp_in_end"
					}
					if {[info exists axis_port1_remo_mappings] && [dict exists $axis_port1_remo_mappings $visp_inip]} {
						set visp_remo_in_end [dict get $axis_port1_remo_mappings $visp_inip]
						dtg_verbose "visp_remo_in_end:$visp_remo_in_end"
					}
					if {[info exists port2_end_mappings] && [dict exists $port2_end_mappings $visp_inip]} {
						set visp_in1_end [dict get $port2_end_mappings $visp_inip]
						dtg_verbose "visp_in1_end:$visp_in1_end"
					}
					if {[info exists axis_port2_remo_mappings] && [dict exists $axis_port2_remo_mappings $visp_inip]} {
						set visp_remo_in1_end [dict get $axis_port2_remo_mappings $visp_inip]
						dtg_verbose "visp_remo_in1_end:$visp_remo_in1_end"
					}
					if {[info exists port3_end_mappings] && [dict exists $port3_end_mappings $visp_inip]} {
						set visp_in2_end [dict get $port3_end_mappings $visp_inip]
						dtg_verbose "visp_in2_end:$visp_in2_end"
					}
					if {[info exists axis_port3_remo_mappings] && [dict exists $axis_port3_remo_mappings $visp_inip]} {
						set visp_remo_in2_end [dict get $axis_port3_remo_mappings $visp_inip]
						dtg_verbose "visp_remo_in2_end:$visp_remo_in2_end"
					}
					if {[info exists port4_end_mappings] && [dict exists $port4_end_mappings $visp_inip]} {
						set visp_in3_end [dict get $port4_end_mappings $visp_inip]
						dtg_verbose "visp_in3_end:$visp_in3_end"
					}
					if {[info exists axis_port4_remo_mappings] && [dict exists $axis_port4_remo_mappings $visp_inip]} {
						set visp_remo_in3_end [dict get $axis_port4_remo_mappings $visp_inip]
						dtg_verbose "visp_remo_in3_end:$visp_remo_in3_end"
					}
					set drv [split $visp_remo_in_end "-"]
					set handle [lindex $drv 0]
					if {[info exists visp_remo_in_end] && [regexp -nocase $drv_handle "$visp_remo_in_end" match]} {
						if {[llength $visp_remo_in_end]} {
							set visp_ss_node [create_node -n "endpoint" -l $visp_remo_in_end -p $port_node -d $default_dts]
						}
						if {[llength $visp_in_end]} {
							add_prop "$visp_ss_node" "remote-endpoint" $visp_in_end reference $default_dts
						}
					}

					if {[info exists visp_remo_in1_end] && [regexp -nocase $drv_handle "$visp_remo_in1_end" match]} {
						if {[llength $visp_remo_in1_end]} {
							set visp_ss_node1 [create_node -n "endpoint" -l $visp_remo_in1_end -p $port_node -d $default_dts]
						}
						if {[llength $visp_in1_end]} {
							add_prop "$visp_ss_node1" "remote-endpoint" $visp_in1_end reference $default_dts
						}
					}

					if {[info exists visp_remo_in2_end] && [regexp -nocase $drv_handle "$visp_remo_in2_end" match]} {
						if {[llength $visp_remo_in2_end]} {
							set visp_ss_node2 [create_node -n "endpoint" -l $visp_remo_in2_end -p $port_node -d $default_dts]
						}
						if {[llength $visp_in2_end]} {
							add_prop "$visp_ss_node2" "remote-endpoint" $visp_in2_end reference $default_dts
						}
					}

					if {[info exists visp_remo_in3_end] && [regexp -nocase $drv_handle "$visp_remo_in3_end" match]} {
						if {[llength $visp_remo_in3_end]} {
							set visp_ss_node3 [create_node -n "endpoint" -l $visp_remo_in3_end -p $port_node -d $default_dts]
						}
						if {[llength $visp_in3_end]} {
							add_prop "$visp_ss_node3" "remote-endpoint" $visp_in3_end reference $default_dts
						}
					}
					return
				} else {
					set visp_in_end ""
					set visp_remo_in_end ""
					if {[info exists axis_switch_port1_end_mappings] && [dict exists $axis_switch_port1_end_mappings $visp_inip]} {
						set visp_in_end [dict get $axis_switch_port1_end_mappings $visp_inip]
						dtg_verbose "visp_in_end:$visp_in_end"
					}
					if {[info exists axis_switch_port1_remo_mappings] && [dict exists $axis_switch_port1_remo_mappings $visp_inip]} {
						set visp_remo_in_end [dict get $axis_switch_port1_remo_mappings $visp_inip]
						dtg_verbose "visp_remo_in_end:$visp_remo_in_end"
					}
					if {[info exists axis_switch_port2_end_mappings] && [dict exists $axis_switch_port2_end_mappings $visp_inip]} {
						set visp_in1_end [dict get $axis_switch_port2_end_mappings $visp_inip]
						dtg_verbose "visp_in1_end:$visp_in1_end"
					}
					if {[info exists axis_switch_port2_remo_mappings] && [dict exists $axis_switch_port2_remo_mappings $visp_inip]} {
						set visp_remo_in1_end [dict get $axis_switch_port2_remo_mappings $visp_inip]
						dtg_verbose "visp_remo_in1_end:$visp_remo_in1_end"
					}
					if {[info exists axis_switch_port3_end_mappings] && [dict exists $axis_switch_port3_end_mappings $visp_inip]} {
						set visp_in2_end [dict get $axis_switch_port3_end_mappings $visp_inip]
						dtg_verbose "visp_in2_end:$visp_in2_end"
					}
					if {[info exists axis_switch_port3_remo_mappings] && [dict exists $axis_switch_port3_remo_mappings $visp_inip]} {
						set visp_remo_in2_end [dict get $axis_switch_port3_remo_mappings $visp_inip]
						dtg_verbose "visp_remo_in2_end:$visp_remo_in2_end"
					}
					if {[info exists axis_switch_port4_end_mappings] && [dict exists $axis_switch_port4_end_mappings $visp_inip]} {
						set visp_in3_end [dict get $axis_switch_port4_end_mappings $visp_inip]
						dtg_verbose "visp_in3_end:$visp_in3_end"
					}
					if {[info exists axis_switch_port4_remo_mappings] && [dict exists $axis_switch_port4_remo_mappings $visp_inip]} {
						set visp_remo_in3_end [dict get $axis_switch_port4_remo_mappings $visp_inip]
						dtg_verbose "visp_remo_in3_end:$visp_remo_in3_end"
					}
					set drv [split $visp_remo_in_end "-"]
					set handle [lindex $drv 0]
					if {[regexp -nocase $drv_handle "$visp_remo_in_end" match]} {
						if {[llength $visp_remo_in_end]} {
							set visp_ss_node [create_node -n "endpoint" -l $visp_remo_in_end -p $port_node -d $default_dts]
						}
						if {[llength $visp_in_end]} {
							add_prop "$visp_ss_node" "remote-endpoint" $visp_in_end reference $default_dts
						}
					}

					if {[regexp -nocase $drv_handle "$visp_remo_in1_end" match]} {
						if {[llength $visp_remo_in1_end]} {
							set visp_ss_node1 [create_node -n "endpoint" -l $visp_remo_in1_end -p $port_node -d $default_dts]
						}
						if {[llength $visp_in1_end]} {
							add_prop "$visp_ss_node1" "remote-endpoint" $visp_in1_end reference $default_dts
						}
					}
				}
			}
		}

		set inip ""
		if {[llength $visp_inip]} {
			foreach inip $visp_inip {
				set master_intf [hsi::get_intf_pins -of_objects [hsi::get_cells -hier $inip] -filter {TYPE==SLAVE || TYPE ==TARGET}]
				set ip_mem_handles [hsi::get_mem_ranges $inip]
				if {[llength $ip_mem_handles]} {
					set base [string tolower [hsi::get_property BASE_VALUE $ip_mem_handles]]
				} else {
					if {[string match -nocase [hsi::get_property IP_NAME $inip] "system_ila"]} {
						continue
					}
					set inip [get_in_connect_ip $inip $master_intf]
				}
				if {[llength $inip]} {
					set visp_in_end ""
					set visp_remo_in_end ""
					if {[info exists end_mappings] && [dict exists $end_mappings $inip]} {
						set visp_in_end [dict get $end_mappings $inip]
					}
					if {[info exists remo_mappings] && [dict exists $remo_mappings $inip]} {
						set visp_remo_in_end [dict get $remo_mappings $inip]
					}
					if {[llength $visp_remo_in_end]} {
						set visp_ss_node [create_node -n "endpoint" -l $visp_remo_in_end -p $port_node -d $default_dts]
					}
					if {[llength $visp_in_end]} {
						add_prop "$visp_ss_node" "remote-endpoint" $visp_in_end reference $default_dts
					}
				}
			}
		} else {
			dtg_warning "$drv_handle pin s_axis is not connected..check your design"
		}


	}
}

proc visp_ss_outip_endpoints {drv_handle port01 default_dts sub_node_label outip} {
	set outipname [hsi get_property IP_NAME $outip]
	set valid_mmip_list "v_frmbuf_wr mipi_dsi_tx_subsystem"
	if {[lsearch  -nocase $valid_mmip_list $outipname] >= 0} {
		foreach ip $outip {
			if {[llength $ip]} {
				set master_intf [::hsi::get_intf_pins -of_objects [hsi::get_cells -hier $ip] -filter {TYPE==MASTER || TYPE ==INITIATOR}]
				set ip_mem_handles [hsi::get_mem_ranges $ip]
				if {[llength $ip_mem_handles]} {
					set base [string tolower [hsi get_property BASE_VALUE $ip_mem_handles]]
					set vispnode [create_node -n "endpoint" -l visp_out$sub_node_label -p $port01 -d $default_dts]
					gen_endpoint $drv_handle "visp_out$sub_node_label"
					add_prop "$vispnode" "remote-endpoint" $ip$sub_node_label reference $default_dts
					gen_remoteendpoint $drv_handle "$ip$sub_node_label"
					if {[string match -nocase [hsi get_property IP_NAME $ip] "v_frmbuf_wr"]} {
						visp_ss_gen_frmbuf_wr_node $ip $drv_handle $default_dts $sub_node_label
					}
				} else {
					if {[string match -nocase [hsi get_property IP_NAME $ip] "system_ila"]} {
						continue
					}
					set connectip [get_connect_ip $ip $master_intf $default_dts]
					if {[llength $connectip]} {
						set vispnode [create_node -n "endpoint" -l visp_out$sub_node_label -p $port01 -d $default_dts]
						gen_endpoint $drv_handle "visp_out$sub_node_label"
						add_prop "$vispnode" "remote-endpoint" $connectip$drv_handle reference $default_dts
						gen_remoteendpoint $drv_handle "$connectip$drv_handle"
						if {[string match -nocase [hsi get_property IP_NAME $connectip] "v_frmbuf_wr"]} {
							visp_ss_gen_frmbuf_wr_node $connectip $drv_handle $default_dts $sub_node_label
						}
					}
				}
			} else {
				dtg_warning "$drv_handle pin TILE0_ISP0_VIDOUT_PO is not connected..check your design"
			}
		}
	}

}

proc visp_ss_gen_frmbuf_wr_node {outip drv_handle dts_file sub_node_label} {
	set bus_node [detect_bus_name $drv_handle]
	set vcap [create_node -n "vcap_$sub_node_label" -p $bus_node -d $dts_file]
	add_prop $vcap "compatible" "xlnx,video" string $dts_file
	add_prop $vcap "dmas" "$outip 0" reference $dts_file
	add_prop $vcap "dma-names" "port0" string $dts_file
	set vcap_ports_node [create_node -n "ports" -l vcap_ports$sub_node_label -p $vcap -d $dts_file]
	add_prop "$vcap_ports_node" "#address-cells" 1 int $dts_file
	add_prop "$vcap_ports_node" "#size-cells" 0 int $dts_file
	set vcap_port_node [create_node -n "port" -l vcap_port$sub_node_label -p $vcap_ports_node -d $dts_file]
	add_prop "$vcap_port_node" "reg" 0 int $dts_file
	add_prop "$vcap_port_node" "direction" input string $dts_file
	set vcap_in_node [create_node -n "endpoint" -l $outip$sub_node_label -p $vcap_port_node -d $dts_file]
	gen_endpoint $$sub_node_label "visp_out$sub_node_label"
	add_prop "$vcap_in_node" "remote-endpoint" visp_out$sub_node_label reference $dts_file
	gen_remoteendpoint $$sub_node_label "$outip$sub_node_label"
}
