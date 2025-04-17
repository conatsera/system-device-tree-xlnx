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

proc tmr_manager_generate {drv_handle} {
	set node [get_node $drv_handle]
	set tree_obj [return_tree_obj $drv_handle]
	if {$node == 0} {
		return
	}
	set version [string tolower [hsi get_property VLNV $drv_handle]]
	if {![string compare -nocase "xilinx.com:ip:tmr_manager:1.0" $version] == 0} {
		$tree_obj append $node compatible "\ \, \"xlnx,tmr-manager-1.0\""
	}
}
