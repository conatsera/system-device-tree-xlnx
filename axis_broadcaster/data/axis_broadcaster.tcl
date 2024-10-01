#
# (C) Copyright 2024 Advanced Micro Devices, Inc. All Rights Reserved.
#
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
proc axis_broadcaster_generate {drv_handle} {
}


proc axis_broadcaster_update_endpoints {drv_handle} {
	global end_mappings
	global remo_mappings

	set ips [hsi::get_cells -hier -filter {IP_NAME == "axis_broadcaster"}]
	foreach ip $ips {
		if {[llength $ip]} {
			set axis_broad_ip [hsi::get_property IP_NAME $ip]
			# broad_ip means broadcaster input ip is connected to another ip
			set broad_ip [get_broad_in_ip $ip]
			set validate_ip 1
			if {[llength $broad_ip]} {
				if { [hsi get_property IP_NAME $broad_ip] in { "v_proc_ss" "ISPPipeline_accel" } } {
				# set validate ip is 0 when axis_broadcaster input ip is
				# connect to v_proc_ss or ISPPipeline_accel to skip the below checks
					set validate_ip 0
				}
			}
			# add unit_addr and ip_type check when axis_broadcaster input ip is connected with other ips
			if {$validate_ip} {
				set unit_addr [get_baseaddr ${ip} no_prefix]
				if { ![string equal $unit_addr "-1"] } {
					break
				}
				set ip_type [get_property IP_TYPE $ip]
				if {[string match -nocase $ip_type "BUS"]} {
					break
				}
			}
			set label $ip
			set bus_node [detect_bus_name $ip]
			set dts_file [set_drv_def_dts $ip]
			set rt_node [create_node -n "axis_broadcaster$ip" -l ${label} -u 0 -d ${dts_file} -p $bus_node]
			if {[llength $axis_broad_ip]} {
				set intf [::hsi::get_intf_pins -of_objects [hsi::get_cells -hier $ip] -filter {TYPE==SLAVE || TYPE ==TARGET}]
				set inip [get_in_connect_ip $ip $intf]
				if {[llength $broad_ip]} {
					if {[llength $inip]} {
						set inipname [hsi get_property IP_NAME $inip]
						set valid_mmip_list "mipi_csi2_rx_subsystem v_tpg v_hdmi_rx_ss v_smpte_uhdsdi_rx_ss v_smpte_uhdsdi_tx_ss v_demosaic v_gamma_lut v_proc_ss v_frmbuf_rd v_frmbuf_wr v_hdmi_tx_ss v_hdmi_txss1 v_uhdsdi_audio audio_formatter i2s_receiver i2s_transmitter mipi_dsi_tx_subsystem v_mix v_multi_scaler v_scenechange ISPPipeline_accel"
						if {[lsearch  -nocase $valid_mmip_list $inipname] >= 0} {
							set ports_node [create_node -n "ports" -l axis_broadcaster_ports$ip -p $rt_node -d $dts_file]
							add_prop "$ports_node" "#address-cells" 1 int $dts_file
							add_prop "$ports_node" "#size-cells" 0 int $dts_file
							set port_node [create_node -n "port" -l axis_broad_port0$ip -u 0 -p $ports_node -d $dts_file]
							add_prop "$port_node" "reg" 0 int $dts_file
							if {[llength $inip]} {
								set axis_broad_in_end ""
								set axis_broad_remo_in_end ""
								if {[info exists end_mappings] && [dict exists $end_mappings $inip]} {
									set axis_broad_in_end [dict get $end_mappings $inip]
									dtg_verbose "drv:$ip inend:$axis_broad_in_end"
								}
								if {[info exists remo_mappings] && [dict exists $remo_mappings $inip]} {
									set axis_broad_remo_in_end [dict get $remo_mappings $inip]
									dtg_verbose "drv:$ip inremoend:$axis_broad_remo_in_end"
								}
								if {[llength $axis_broad_remo_in_end]} {
									set axisinnode [create_node -n "endpoint" -l $axis_broad_remo_in_end -p $port_node -d $dts_file]
								}
								if {[llength $axis_broad_in_end]} {
									add_prop "$axisinnode" "remote-endpoint" $axis_broad_in_end reference $dts_file 1
								}
							}
						}
					}
				}
			}
		}
	}
}