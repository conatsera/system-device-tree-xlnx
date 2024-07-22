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

proc cpu_cortexr52_generate {drv_handle} {
	set ip_name [get_ip_property $drv_handle IP_NAME]
	set fields [split [get_ip_property $drv_handle NAME] "_"]
	set cpu_nr [lindex $fields end]
	global is_versal_net_platform
	global is_versal_gen2_platform
	if { $is_versal_net_platform } {
		if {$is_versal_gen2_platform} {
			set node [create_node -n "&cortexr52_${cpu_nr}" -d "pcw.dtsi" -p root -h $drv_handle]
		} else {
			set node [create_node -n "&psx_cortexr52_${cpu_nr}" -d "pcw.dtsi" -p root -h $drv_handle]
		}
	}
	gen_drv_prop_from_ip $drv_handle
	gen_pss_ref_clk_freq $drv_handle $node $ip_name

	add_prop $node "bus-handle" "amba" reference "pcw.dtsi"
	add_prop $node "cpu-frequency" [hsi get_property CONFIG.C_CPU_CLK_FREQ_HZ $drv_handle] int "pcw.dtsi"
	add_prop $node "xlnx,ip-name" $ip_name string "pcw.dtsi"
	set time_stamp_freq [get_ip_property $drv_handle CONFIG.C_TIMESTAMP_CLK_FREQ]
	if {[string_is_empty $time_stamp_freq]} {
		add_prop $node "xlnx,timestamp-clk-freq" 100000000 int "pcw.dtsi"
	}
}