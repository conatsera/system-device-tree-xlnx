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

proc pmcdma_generate {drv_handle} {
	set node [get_node $drv_handle]
	set dts_file [set_drv_def_dts $drv_handle]
	set pmcbridge [hsi::get_cells -hier -filter IP_NAME==pmcbridge]
	if {![string_is_empty $pmcbridge]} {
		[return_tree_obj $drv_handle] append $node compatible "\ \, \"xlnx,pmc-dma\""
		add_prop $node "xlnx,dma-type" 1 int $dts_file
	}
}
