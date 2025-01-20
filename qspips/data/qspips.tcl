#
# (C) Copyright 2014-2022 Xilinx, Inc.
# (C) Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
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

    proc qspips_generate {drv_handle} {
        set node [get_node $drv_handle]
        set dts_file [set_drv_def_dts $drv_handle]
        set slave [hsi::get_cells -hier $drv_handle]
        set qspi_mode [get_ip_param_value $slave "C_QSPI_MODE"]

        set ipname [hsi get_cells -hier -filter {IP_NAME == "pspmc" || IP_NAME == "pmcps" || IP_NAME == "ps_wizard"}]
        #for versal-net setting spi-max-frequency to 40MHZ if fbclk disabled in design
        set psxwizard [hsi get_cells -hier -filter {IP_NAME == "psx_wizard"}]
        if {[llength $ipname]} {
            set fbclk [hsi get_property CONFIG.PMC_QSPI_FBCLK [hsi get_cells -hier $ipname]]
                   if {[regexp "ENABLE 0" $fbclk matched]} {
                       set node [gen_peripheral_nodes $drv_handle]
                       if {$node == 0} {
                            return
                       }
                       qspips_set_spi_max_frequency $node $dts_file
                       add_prop $node xlnx,qspi-fbclk 0 int $dts_file
                   } elseif {[regexp "ENABLE 1" $fbclk matched]} {
                       set node [gen_peripheral_nodes $drv_handle]
                       if {$node == 0} {
                            return
                       }
                       add_prop $node xlnx,qspi-fbclk 1 int $dts_file
                   }
	} elseif {[llength $psxwizard]} {
                set psx_pmcx_config [hsi get_property CONFIG.PSX_PMCX_CONFIG [hsi get_cells -hier $psxwizard]]
                if {[llength $psx_pmcx_config]} {
                        set qspi_fbclk ""
                        if {[dict exists $psx_pmcx_config "PMCX_QSPI_FBCLK"]} {
                                set qspi_fbclk [dict get $psx_pmcx_config "PMCX_QSPI_FBCLK"]
                                set qspi_fbclk_enabled ""
                                if {[dict exists $qspi_fbclk "ENABLE"]} {
                                        set qspi_fbclk_enabled [dict get $qspi_fbclk "ENABLE"]
                                        if {$qspi_fbclk_enabled == 0} {
                                                qspips_set_spi_max_frequency $node $dts_file
                                        }
                                }
                        }
                }
        } else {
               add_prop $node xlnx,qspi-fbclk 0 int $dts_file
	}

        set is_stacked 0
        if { $qspi_mode == 2} {
                set is_dual 1
        } elseif { $qspi_mode == 1} {
                   set is_dual 0
                   set is_stacked 1
            } elseif { $qspi_mode == 0} {
                set is_dual 0
        }
        add_prop $node "is-dual" $is_dual int $dts_file

        # Set num-cs value to 2 if qspi is dual/stacked else 1
        set numcs 1
        if { $is_dual == 1 || $is_stacked == 1 } {
                set numcs 2
        }
        add_prop $node "num-cs" $numcs int $dts_file

        if {$is_stacked} {
                add_prop $node "is-stacked" $is_stacked int $dts_file
        }
        set bus_width [hsi get_property CONFIG.C_QSPI_BUS_WIDTH [hsi::get_cells -hier $drv_handle]]

        switch $bus_width {
                "3" {
                        add_prop $node "spi-tx-bus-width" 8 int $dts_file
                        add_prop $node "spi-rx-bus-width" 8 int $dts_file
                }
                "2" {
                        add_prop $node "spi-tx-bus-width" 4 int $dts_file
                        add_prop $node "spi-rx-bus-width" 4 int $dts_file
                }
                "1" {
                        add_prop $node "spi-tx-bus-width" 2 int $dts_file
                        add_prop $node "spi-rx-bus-width" 2 int $dts_file
                }
                "0" {
                        add_prop $node "spi-tx-bus-width" 1 int $dts_file
                        add_prop $node "spi-rx-bus-width" 1 int $dts_file
                }
                default {
                        dtg_warning "Unsupported bus_width:$bus_width"
                }
        }
        set_drv_conf_prop $drv_handle C_QSPI_BUS_WIDTH xlnx,bus-width $node int
        set_drv_conf_prop $drv_handle C_QSPI_MODE xlnx,connection-mode $node int
        set_drv_conf_prop $drv_handle C_QSPI_CLK_FREQ_HZ xlnx,clock-freq $node int
        set_drv_conf_prop $drv_handle C_QSPI_BAUD_RATE_DIV xlnx,baud-rate-div $node int
    }


#when fbclk disabled in the design
#this function will set the spi-max-freq to 40MHZ
proc qspips_set_spi_max_frequency {node dts_file} {
        add_prop "${node}" "//* hw design is missing feedback clock that's why spi-max-frequency is 40MHz */" "" comment $dts_file
        add_prop $node "spi-max-frequency" 40000000 int $dts_file
}
