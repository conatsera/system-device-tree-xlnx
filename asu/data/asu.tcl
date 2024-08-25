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

proc asu_generate {drv_handle} {
	set cpu_node [create_node -n "&asu" -d "pcw.dtsi" -p root -h $drv_handle]
	set ip_name [get_ip_property $drv_handle IP_NAME]
	add_prop $cpu_node "xlnx,ip-name" $ip_name string "pcw.dtsi"
	gen_drv_prop_from_ip $drv_handle
}
