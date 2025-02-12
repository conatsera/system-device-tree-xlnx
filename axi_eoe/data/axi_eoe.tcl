#
# (C) Copyright 2025 Advanced Micro Devices, Inc. All Rights Reserved.
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

    proc axi_eoe_generate {eoe_ip node dts_file} {

         add_prop "$node" "xlnx,has-hw-offload" boolean $dts_file

         set gro_ports [hsi get_property CONFIG.C_RX_NUM_PORTS $eoe_ip]
         add_prop "$node" "xlnx,gro-ports" $gro_ports hexint $dts_file

         set tx_hw_offload [hsi get_property CONFIG.C_TX_HW_OFFLOAD $eoe_ip]
         if {$tx_hw_offload == 0} {
             add_prop "$node" "xlnx,tx-hw-offload" "1" int $dts_file
         } elseif {$tx_hw_offload == 1} {
                    add_prop "$node" "xlnx,tx-hw-offload" "2" int $dts_file
         }

         set rx_hw_offload [hsi get_property CONFIG.C_RX_HW_OFFLOAD $eoe_ip]
         if {$rx_hw_offload == 0} {
             add_prop "$node" "xlnx,rx-hw-offload" "1" int $dts_file
         } elseif {$rx_hw_offload == 1} {
             add_prop "$node" "xlnx,rx-hw-offload" "2" int $dts_file
         }

         set eoe_node [get_node $eoe_ip]
         set eoe_reg [pldt get $eoe_node reg]
         pldt append $node reg ", $eoe_reg"

         lappend reg_names "mac" "eoe"
         add_prop "${node}" "reg-names" ${reg_names} stringlist $dts_file
    }
