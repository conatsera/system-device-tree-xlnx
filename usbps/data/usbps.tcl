#
# (C) Copyright 2014-2022 Xilinx, Inc.
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

    proc usbps_generate {drv_handle} {
        ps7_reset_handle $drv_handle CONFIG.C_USB_RESET CONFIG.usb-reset
        set proctype [get_hw_family]
	set super_speed 0
        set node [get_node $drv_handle]
	set peripheral [hsi get_cells -hier -filter {IP_NAME == zynq_ultra_ps_e}]
        set default_dts [set_drv_def_dts $drv_handle]
        if {[string match -nocase $proctype "zynq"] } {
        set_drv_prop $drv_handle phy_type ulpi $node string
        } else {
        global env
        set path $env(CUSTOM_SDT_REPO)

        set drvname [get_drivers $drv_handle]

        set common_file "$path/device_tree/data/config.yaml"
        set mainline_ker [get_user_config $common_file -mainline_kernel]

        if {[string match -nocase $proctype "versal"] || [string match -nocase $proctype "psv_cortexr5"] || [string match -nocase $proctype "psv_pmc"]} {
                #TODO:Remove this once the versal dts is fully updated.
		add_prop $node "xlnx,enable-superspeed" $super_speed int $default_dts
                return
        }
        if {[string match -nocase $mainline_ker "none"]} {
             set index [string index $drv_handle end]
             add_prop $node "status" "okay" string $default_dts
        }
	if {$peripheral > 0} {
		set usb3_0 0
		set usb3_1 0
		set parameters [hsi list_property [hsi get_cells -hier $peripheral]]
		if {[lsearch -nocase $parameters "CONFIG.PSU__USB3_0__PERIPHERAL__ENABLE"] >= 0} {
			set usb3_0 [hsi get_property CONFIG.PSU__USB3_0__PERIPHERAL__ENABLE [hsi get_cells -hier $peripheral]]
		}
		if {[lsearch -nocase $parameters "CONFIG.PSU__USB3_1__PERIPHERAL__ENABLE"] >= 0} {
			set usb3_1 [hsi get_property CONFIG.PSU__USB3_1__PERIPHERAL__ENABLE [hsi get_cells -hier $peripheral]]
		}
		if { $usb3_0 || $usb3_1 } {
			set super_speed 1
		}
        }
    }
    add_prop $node "xlnx,enable-superspeed" $super_speed int $default_dts
    }
