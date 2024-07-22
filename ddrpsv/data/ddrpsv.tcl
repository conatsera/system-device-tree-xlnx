#
# (C) Copyright 2019-2022 Xilinx, Inc.
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

    proc ddrpsv_generate {drv_handle} {
        set ip_name [get_ip_property $drv_handle IP_NAME]
        set supported_ip_feature [list "ddr"]
        if {![string_is_empty [hsi get_mem_ranges -filter ADDRESS_BLOCK=~HBM*]]} {
                lappend supported_ip_feature "hbm"
        }

        foreach feature $supported_ip_feature {
                set supported_block_names [ddrpsv_get_memory_block_names $ip_name $feature]
                ddrpsv_node_info_map $drv_handle $supported_block_names "${drv_handle}_${feature}_memory"
        }
    }

    proc ddrpsv_get_memory_block_names {ip_name {feature ""}} {
        # HW designs can have multiple NOC IPs, and each of them can be connected to
        # same DDR segment with different address ranges, and through different
        # master interface channels.
        # For each DDR segment, NOC IP interface whose base address is lowest in the design
        # would be stored in base_addr_list and highest high address would be stored in
        # high_address_list. Index of base_address_list/high_address_list where base/high
        # address for specific DDR segment/DDR region is stored is as given below. These
        # lowest and highest addresses would be used to create canonical definitions, which
        # would be consumed by MMU/MPU tables in Cortex-A72/Cortex-R5 BSP.
        #
        # NOC1 DDR Address blocks
        # ------------------------------------------------------------------------
        #  DDR segment       |    Start address  |   Size   | Index in addr_list |
        # -------------------|-------------------|----------|--------------------|
        #  DDR_LOW_0         |      0x0000_0000  |    2 GB  |         0          |
        #  DDR_LOW_1         |    0x8_0000_0000  |   32 GB  |         1          |
        #  DDR_LOW_2         |   0xC0_0000_0000  |  256 GB  |         2          |
        #  DDR_LOW_3         |  0x100_0000_0000  |  734 GB  |         3          |
        #  DDR_CH_1          |  0x500_0000_0000  |  512 GB  |         4          |
        #  DDR_CH_2          |  0x600_0000_0000  |  512 GB  |         5          |
        #  DDR_CH_3          |  0x700_0000_0000  |  512 GB  |         6          |
        # ------------------------------------------------------------------------
        #
        # NOC1 HBM Address blocks
        # ------------------------------------------------------------------------
        #  HBM segment       |    Start address  |   Size   | Index in addr_list |
        # -------------------|-------------------|----------|--------------------|
        #  HBM0_PC0          |   0x40_0000_0000  |    1 GB  |         0          |
        #  HBM0_PC1          |   0x40_4000_0000  |    1 GB  |         1          |
        #  HBM1_PC0          |   0x40_8000_0000  |    1 GB  |         2          |
        #  HBM1_PC1          |   0x40_C000_0000  |    1 GB  |         3          |
        #  HBM2_PC0          |   0x41_0000_0000  |    1 GB  |         4          |
        #  HBM2_PC1          |   0x41_4000_0000  |    1 GB  |         5          |
        #  HBM3_PC0          |   0x41_8000_0000  |    1 GB  |         6          |
        #  HBM3_PC1          |   0x41_C000_0000  |    1 GB  |         7          |
        #  HBM4_PC0          |   0x42_0000_0000  |    1 GB  |         8          |
        #  HBM4_PC1          |   0x42_4000_0000  |    1 GB  |         9          |
        #  HBM5_PC0          |   0x42_8000_0000  |    1 GB  |        10          |
        #  HBM5_PC1          |   0x42_C000_0000  |    1 GB  |        11          |
        #  HBM6_PC0          |   0x43_0000_0000  |    1 GB  |        12          |
        #  HBM6_PC1          |   0x43_4000_0000  |    1 GB  |        13          |
        #  HBM7_PC0          |   0x43_8000_0000  |    1 GB  |        14          |
        #  HBM7_PC1          |   0x43_C000_0000  |    1 GB  |        15          |
        #  HBM8_PC0          |   0x44_0000_0000  |    1 GB  |        16          |
        #  HBM8_PC1          |   0x44_4000_0000  |    1 GB  |        17          |
        #  HBM9_PC0          |   0x44_8000_0000  |    1 GB  |        18          |
        #  HBM9_PC1          |   0x44_C000_0000  |    1 GB  |        19          |
        #  HBM10_PC0         |   0x45_0000_0000  |    1 GB  |        20          |
        #  HBM10_PC1         |   0x45_4000_0000  |    1 GB  |        21          |
        #  HBM11_PC0         |   0x45_8000_0000  |    1 GB  |        22          |
        #  HBM11_PC1         |   0x45_C000_0000  |    1 GB  |        23          |
        #  HBM12_PC0         |   0x46_0000_0000  |    1 GB  |        24          |
        #  HBM12_PC1         |   0x46_4000_0000  |    1 GB  |        25          |
        #  HBM13_PC0         |   0x46_8000_0000  |    1 GB  |        26          |
        #  HBM13_PC1         |   0x46_C000_0000  |    1 GB  |        27          |
        #  HBM14_PC0         |   0x47_0000_0000  |    1 GB  |        28          |
        #  HBM14_PC1         |   0x47_4000_0000  |    1 GB  |        29          |
        #  HBM15_PC0         |   0x47_8000_0000  |    1 GB  |        30          |
        #  HBM15_PC1         |   0x47_C000_0000  |    1 GB  |        31          |
        # ------------------------------------------------------------------------
        #
        # NOC2 DDR Address blocks
        # ------------------------------------------------------------------------
        #  DDR segment       |    Start address  |   Size   | Index in addr_list |
        # -------------------|-------------------|----------|--------------------|
        #  DDR_CH0_LEGACY    |      0x0000_0000  |    2 GB  |         0          |
        #  DDR_CH0_MED       |    0x8_0000_0000  |   32 GB  |         1          |
        #  DDR_CH0_HIGH0     |   0xC0_0000_0000  |  256 GB  |         2          |
        #  DDR_CH0_HIGH1     |  0x100_0000_0000  |  734 GB  |         3          |
        #  DDR_CH_1          |  0x500_0000_0000  |  512 GB  |         4          |
        #  DDR_CH_1A         |  0x600_0000_0000  |  512 GB  |         5          |
        #  DDR_CH_2          |  0x700_0000_0000  |  512 GB  |         6          |
        #  DDR_CH_2A         | 0x1800_0000_0000  |  512 GB  |         7          |
        #  DDR_CH_3          | 0x1880_0000_0000  |  512 GB  |         8          |
        #  DDR_CH_3A         | 0x1900_0000_0000  |  512 GB  |         9          |
        #  DDR_CH_4          | 0x1980_0000_0000  |  512 GB  |        10          |
        # ------------------------------------------------------------------------


        set supported_block_names [list create]

        if { $ip_name == "axi_noc2" } {
                set supported_block_names { \
                        "C*_DDR_CH0_LEGACY*" "C*_DDR_CH0_MED*" "C*_DDR_CH0_HIGH0*" "C*_DDR_CH0_HIGH1*" "C*_DDR_CH1*" "C*_DDR_CH1A*" "C*_DDR_CH2*" \
                        "C*_DDR_CH2A*" "C*_DDR_CH3*" "C*_DDR_CH3A*" "C*_DDR_CH4*" \
                }
        } else {
                set supported_block_names { \
                        "C*_DDR_LOW0*" "C*_DDR_LOW1*" "C*_DDR_LOW2*" "C*_DDR_LOW3*" "C*_DDR_CH1*" "C*_DDR_CH2*"  "C*_DDR_CH3*" \
                }
        }

        if {$feature == "hbm"} {
                set supported_block_names { \
                        "HBM0_*PC0*" "HBM0_*PC1*" "HBM1_*PC0*" "HBM1_*PC1*" "HBM2_*PC0*" "HBM2_*PC1*" "HBM3_*PC0*" "HBM3_*PC1*" "HBM4_*PC0*" \
                        "HBM4_*PC1*" "HBM5_*PC0*" "HBM5_*PC1*" "HBM6_*PC0*" "HBM6_*PC1*" "HBM7_*PC0*" "HBM7_*PC1*" "HBM8_*PC0*" "HBM8_*PC1*" \
                        "HBM9_*PC0*" "HBM9_*PC1*" "HBM10_*PC0*"  "HBM10_*PC1*" "HBM11_*PC0*" "HBM11_*PC1*" "HBM12_*PC0*" "HBM12_*PC1*" "HBM13_*PC0*" \
                        "HBM13_*PC1*" "HBM14_*PC0*" "HBM14_*PC1*" "HBM15_*PC0*" "HBM15_*PC1*"
                }
        }

        return $supported_block_names
    }

    proc ddrpsv_node_info_map {drv_handle supported_block_names label} {
        set a72 0
        set dts_file "system-top.dts"

        # Get the periph_name from drv_handle (output is usually same as drv_handle)
        set periph_name [hsi::get_cells -hier ${drv_handle}]
        set vlnv [split [hsi get_property VLNV $periph_name] ":"]
        set name [lindex $vlnv 2]
        set ver [lindex $vlnv 3]

        # Property for compatibility string
        set comp_prop "xlnx,${name}-${ver}"
        regsub -all {_} $comp_prop {-} comp_prop

        # Defined at the top to avoid scope issue if no DDR region is mapped
        set reg_val ""

        # Number of known DDR regions is set to 7 for versal, 11 for Versal Net
        # Check ddrpsv_number_of_memory_regions API for more details on the regions.
        set num_of_known_regions [llength $supported_block_names]

        # List that contains base_address of each DDR region (C0_DDR_LOW(0-3), C0_DDR_CH(1-3))
        global base_addr_list
        set base_addr_list [lrepeat $num_of_known_regions 0]

        # List that contains high_address of each DDR region (C0_DDR_LOW(0-3), C0_DDR_CH(1-3))
        global high_addr_list
        set high_addr_list [lrepeat $num_of_known_regions 0]

        global overall_base_addr_list
        set overall_base_addr_list [lrepeat $num_of_known_regions 0]

        global overall_high_addr_list
        set overall_high_addr_list [lrepeat $num_of_known_regions 0]

        # Need a dictionary to gather system level data using processor level data
        set global_map_dict [dict create]

        # list all the processors available in the design
        set proclist [hsi::get_cells -hier -filter {IP_TYPE==PROCESSOR}]
        foreach procc $proclist {
                # List to save the access status of each DDR region
                # If the region is present, final status is set to 1
                set region_accessed [lrepeat $num_of_known_regions 0]

                # Set default values in global_map_dict to 0 for each DDR region for each proc
                for {set index 0} {$index < $num_of_known_regions} {incr index} {
                        # region_accessed base_addr high_addr
                        dict set global_map_dict "$procc" $index "0 0 0"
                }

                # Get all the NOC memory instances mapped to the particular processor
                set mapped_periph_list [hsi::get_mem_ranges -of_objects $procc $periph_name]

                # If there is no instances mapped, then skip that processor
                if { $mapped_periph_list eq "" } {
                        continue
                }

                # Get the processor IP name (A72/R5/PMC/PSM)
                set proc_ip_name [hsi get_property IP_NAME $procc]

                # Get the interface block names
                # (e.g. C0_DDR_LOW0 C0_DDR_LOW0 C0_DDR_LOW0 C0_DDR_LOW1 C0_DDR_LOW1 C0_DDR_LOW1)
                # Blocks with same name say C0_DDR_LOW0 will be having a different master interface
                # FPD_CCI_NOC_0, FPD_CCI_NOC_1 are the examples of master interfaces
                set interface_block_names [hsi get_property ADDRESS_BLOCK ${mapped_periph_list}]

                # If the mappings have already been found for a72_0, then ignore the process for a72_1
                if {$a72 == 1 && ($proc_ip_name in {"psv_cortexa72" "psx_cortexa78" "cortexa78"} ) } {
                        continue
                }
                if {$proc_ip_name in {"psv_cortexa72" "psx_cortexa78" "cortexa78"}} {
                       set a72 1
                }


                set region_accessed [ddrpsv_addr_params $mapped_periph_list $interface_block_names $region_accessed $supported_block_names]


                # Generate reg_property available for the processor, combining all the regions
                set updat ""
                for {set index 0} {$index < $num_of_known_regions} {incr index} {
                        if {[lindex $region_accessed $index]} {
                                set base_value [lindex $base_addr_list $index]
                                set base_value [ddrpsv_check_tcm_overlapping $procc $base_value]
                                set high_value [lindex $high_addr_list $index]
                                dict set global_map_dict "$procc" "$index" "1 $base_value $high_value"
                                set reg_val [ddrpsv_generate_reg_property $base_value $high_value]
                                set updat [lappend updat $reg_val]
                        }
                }

                set len [llength $updat]
                set reg_val ""

                if {$len} {
                        set reg_val [join $updat ">, <"]
                        ddrpsv_update_mc_ranges $drv_handle $reg_val
                        switch $proc_ip_name {
                                "psv_cortexr5" - "psx_cortexr52" - "cortexr52" - "microblaze" - "microblaze_riscv" {
                                        set_memmap "${label}" $procc $reg_val
                                }
                                "psv_cortexa72" - "psx_cortexa78" - "cortexa78" {
                                        set_memmap "${label}" a53 $reg_val
                                }
                                "psv_pmc" - "psx_pmc" - "pmc" {
                                        set_memmap "${label}" pmc $reg_val
                                }
                                "psv_psm" - "psx_psm" - "psm" {
                                        set_memmap "${label}" psm $reg_val
                                }
                                default {
                                }
                        }
                }
        }

        # Get the system level memory reg
        set ov_update ""
        set global_node_base_addr ""

        # A flag to get base_address of the memory node
        set first_region_access 0


        for {set index 0} {$index < $num_of_known_regions} {incr index} {
                # Flag to check the first access of the current region among diff procs and set the first base_addr for that region
                # Also to differentiate the actually read 0 and default 0
                set curr_region_access 0
                set base_addr ""
                set high_addr ""
                foreach procc $proclist {
                        set curr_base_addr [lindex [dict get $global_map_dict $procc $index] 1]
                        set curr_high_addr [lindex [dict get $global_map_dict $procc $index] 2]
                        if {[lindex [dict get $global_map_dict $procc $index] 0]} {
                                if { !$curr_region_access } {
                                        set base_addr $curr_base_addr
                                        set high_addr $curr_high_addr
                                        set curr_region_access 1
                                } else {
                                        if { [string compare $curr_base_addr $base_addr] < 0 } {
                                                set base_addr $curr_base_addr
                                        }
                                        if { [string compare $curr_high_addr $base_addr] > 0 } {
                                                set high_addr $curr_high_addr
                                        }
                                }
                        }
                }
                if {$curr_region_access} {
                        set ov_update [lappend ov_update [ddrpsv_generate_reg_property $base_addr $high_addr]]
                        if { !$first_region_access } {
                                set global_node_base_addr $base_addr
                                set first_region_access 1
                        }
                }
        }

        if {[llength $ov_update]} {
                set memory_node [create_node -n memory -l "${label}" -u [regsub -all {^0x} ${global_node_base_addr} {}] -p root -d "system-top.dts"]
                add_prop "${memory_node}" "compatible" $comp_prop string $dts_file
                add_prop "${memory_node}" "device_type" "memory" string $dts_file
                add_prop "${memory_node}" "xlnx,ip-name" [get_ip_property $drv_handle IP_NAME] string $dts_file
                add_prop "${memory_node}" "memory_type" "memory" string $dts_file
                add_prop "${memory_node}" "reg" [join $ov_update ">, <"] hexlist $dts_file
        }

    }

    proc ddrpsv_generate_reg_property {base high} {
        set size [format 0x%x [expr {${high} - ${base} + 1}]]

        set proctype [get_hw_family]
        if {[string match -nocase $proctype "versal"] || [string match -nocase $proctype "psv_pmc"] || [string match -nocase $proctype "psv_cortexr5"]} {
                if {[regexp -nocase {0x([0-9a-f]{9})} "$base" match]} {
                        set temp $base
                        set temp [string trimleft [string trimleft $temp 0] x]
                        set len [string length $temp]
                        set rem [expr {${len} - 8}]
                        set high_base "0x[string range $temp $rem $len]"
                        set low_base "0x[string range $temp 0 [expr {${rem} - 1}]]"
                        set low_base [format 0x%08x $low_base]
                } else {
                        set high_base $base
                        set low_base 0x0
                }
                if {[regexp -nocase {0x([0-9a-f]{9})} "$size" match]} {
                        set temp $size
                        set temp [string trimleft [string trimleft $temp 0] x]
                        set len [string length $temp]
                        set rem [expr {${len} - 8}]
                        set high_size "0x[string range $temp $rem $len]"
                        set low_size  "0x[string range $temp 0 [expr {${rem} - 1}]]"
                        set low_size [format 0x%08x $low_size]
                } else {
                        set high_size $size
                        set low_size 0x0
                }
                set reg "$low_base $high_base $low_size $high_size"
        } else {
                set reg "0x0 $base 0x0 $size"
        }
        return $reg
    }

    proc ddrpsv_update_mc_ranges {drv_handle reg} {
        global is_versal_net_platform
        if { !$is_versal_net_platform } {
                set num_mc [hsi get_property CONFIG.NUM_MC [hsi::get_cells -hier $drv_handle]]
                set intrleave_size [hsi get_property CONFIG.MC_INTERLEAVE_SIZE [hsi::get_cells -hier $drv_handle]]
                if {$num_mc >= 1} {
                        if {[catch {set value [pcwdt get "&mc0" ranges]} msg]} {
                                set node [create_node -n "&mc0" -d "pcw.dtsi" -p root]
                                add_prop $node ranges $reg hexlist "pcw.dtsi" 1
                                add_prop $node "status" "okay" string "pcw.dtsi" 1
                                set mcnode [create_node -n "&ddrmc_xmpu_0" -d "pcw.dtsi" -p root]
                                add_prop $mcnode "status" "okay" string "pcw.dtsi" 1
                        } else {
                                set reg_val $value
                                set reg_val [string trimleft $reg_val "<"]
                                set reg_val [string trimright $reg_val ">"]
                                append reg_val ">, <$reg"
                                pcwdt unset "&mc0" ranges
                                set reg_val [ddrpsv_remove_dup $reg_val]
                                add_prop "&mc0" ranges $reg_val hexlist "pcw.dtsi" 1
                                add_prop "&mc0" "status" "okay" string "pcw.dtsi" 1
                        }
                }

                if {$num_mc >= 2} {
                        if {[catch {set value [pcwdt get "&mc1" ranges]} msg]} {
                                set node [create_node -n "&mc1" -d "pcw.dtsi" -p root]          
                                add_prop $node ranges $reg hexlist "pcw.dtsi" 1
                                add_prop $node "status" "okay" string "pcw.dtsi" 1
                                set mcnode [create_node -n "&ddrmc_xmpu_1" -d "pcw.dtsi" -p root]               
                                add_prop $mcnode "status" "okay" string "pcw.dtsi" 1
                        } else {
                                set reg_val $value
                                set reg_val [string trimleft $reg_val "<"]
                                set reg_val [string trimright $reg_val ">"]
                                append reg_val ">, <$reg"
                                pcwdt unset "&mc1" ranges
                                set reg_val [ddrpsv_remove_dup $reg_val]
                                add_prop "&mc1" ranges $reg_val hexlist "pcw.dtsi" 1                    
                                add_prop "&mc1" "status" "okay" string "pcw.dtsi" 1
                        }
                        add_prop "&mc0" interleave "$intrleave_size 0" hexlist "pcw.dtsi" 1
                        add_prop "&mc1" interleave "$intrleave_size 1" hexlist "pcw.dtsi" 1
                }
                
                if {$num_mc >= 4} {
                        if {[catch {set value [pcwdt get "&mc2" ranges]} msg]} {
                                set node [create_node -n "&mc2" -d "pcw.dtsi" -p root]
                                add_prop $node ranges $reg hexlist "pcw.dtsi" 1
                                add_prop $node "status" "okay" string "pcw.dtsi" 1
                                set mcnode [create_node -n "&ddrmc_xmpu_2" -d "pcw.dtsi" -p root]
                                add_prop $mcnode "status" "okay" string "pcw.dtsi" 1
                        } else {
                                set reg_val $value
                                set reg_val [string trimleft $reg_val "<"]
                                set reg_val [string trimright $reg_val ">"]
                                append reg_val ">, <$reg"
                                pcwdt unset "&mc2" ranges
                                set reg_val [ddrpsv_remove_dup $reg_val]
                                add_prop "&mc2" ranges $reg_val hexlist "pcw.dtsi" 1               
                                add_prop "&mc2" "status" "okay" string "pcw.dtsi" 1
                        }
                        add_prop "&mc2" interleave "$intrleave_size 2" hexlist "pcw.dtsi" 1
                        if {[catch {set value [pcwdt get "&mc3" ranges]} msg]} {
                                set node [create_node -n "&mc3" -d "pcw.dtsi" -p root]
                                add_prop $node ranges $reg hexlist "pcw.dtsi" 1
                                set mcnode [create_node -n "&ddrmc_xmpu_3" -d "pcw.dtsi" -p root]
                                add_prop $mcnode "status" "okay" string "pcw.dtsi" 1
                        } else {
                                set reg_val $value
                                set reg_val [string trimleft $reg_val "<"]
                                set reg_val [string trimright $reg_val ">"]
                                append reg_val ">, <$reg"
                                pcwdt unset "&mc3" ranges
                                set reg_val [ddrpsv_remove_dup $reg_val]
                                add_prop "&mc3" ranges $reg_val hexlist "pcw.dtsi" 1             
                                add_prop "&mc3" "status" "okay" string "pcw.dtsi" 1
                        }

                        add_prop "&mc3" interleave "$intrleave_size 3" hexlist "pcw.dtsi" 1
                }
        }

    }

    proc ddrpsv_remove_dup {reg} {
        set list [ddrpsv_multisplit $reg ">, <"]
        set list [lsort -unique $list]
        set len [llength $list]
        if {$len == 1} {
                return $list
        }
        set first [lindex $list 0]
        set list [lreplace $list 0 0]
        foreach val $list {
                append first ">, <$val"
        }
        return $first
        
    }

    proc ddrpsv_multisplit "str splitStr {mc {\x00}}" {
        return [split [string map [list $splitStr $mc] $str] $mc]
    }                                                                                                                                                                           

    proc ddrpsv_get_base_addr {mapped_periph_list index} {
        # Get the Base address of the mapped DDR region
        return [hsi get_property BASE_VALUE [lindex ${mapped_periph_list} $index]]
    }

    proc ddrpsv_get_high_addr {mapped_periph_list index} {
        # Get the High address of the mapped DDR region
        return [hsi get_property HIGH_VALUE [lindex ${mapped_periph_list} $index]]
    }

    proc ddrpsv_handle_address_details { index mapped_periph_list is_ddr_region_accessed ddr_region_id } {
        #Variables to hold base address and high address of each DDR region
        global base_addr_list
        global high_addr_list

        # Get the base address of the passed DDR region i.e. mapped_periph_list[index]
        set temp [ddrpsv_get_base_addr $mapped_periph_list $index]

        # If the DDR region is accessed for the first time OR
        # If the base address found is less than the address present in the list for this DDR region,
        # replace the address in the list with the new address found.
        if { $is_ddr_region_accessed == 0 || ([scan $temp %x] < [scan [lindex $base_addr_list $ddr_region_id] %x])} {
                lset base_addr_list $ddr_region_id $temp
        }

        # Get the High address of the passed DDR region i.e. mapped_periph_list[index]
        set temp [ddrpsv_get_high_addr $mapped_periph_list $index]

        # If the DDR region is accessed for the first time OR
        # If the high address found is greater than the address present in the list for this DDR region,
        # replace the address in the list with the new address found.
        if { $is_ddr_region_accessed == 0 || ([scan $temp %x] > [scan [lindex $high_addr_list $ddr_region_id] %x])} {
                lset high_addr_list $ddr_region_id $temp
        }
    }

    proc ddrpsv_addr_params {mapped_periph_list interface_block_names region_accessed supported_block_names} {
        # Loop variable to go over all the interface blocks
        set i 0

        # Loop through all the interface blocks mapped to the processor
        foreach block_name $interface_block_names {
                # ddr_region_id:
                #        specifies index of base_addr_list/high_addr_list
                #        for each DDR region.
                # lindex $region_accessed $ddr_region_id:
                #        status of each DDR region, if it is present or not.
                # ddrpsv_handle_address_details:
                #       to update the base_addr_list and high_ddr_list if needed.
                # i:
                #       loop variable to traverse across the mapped DDR region.
                #       This is needed as block_name dont have unique names.
                foreach entry $supported_block_names {
                        if {[string match $entry $block_name]} {
                                set ddr_region_id [lsearch -exact $supported_block_names $entry]
                                if {$ddr_region_id >= 0} {
                                        ddrpsv_handle_address_details $i $mapped_periph_list [lindex $region_accessed $ddr_region_id] $ddr_region_id
                                        lset region_accessed $ddr_region_id 1
                                        break
                                }
                        }
                }

                incr i
        }
        return $region_accessed
    }

    # Vivado is allowing the DDR addresses accessible from RPU to start from 0.
    # This leads to the DDR region's overlapping with the TCM region and results into linking error.
    proc ddrpsv_check_tcm_overlapping {proc ddr_base_addr} {
        set proc_ip [get_ip_property $proc IP_NAME]
        if {$proc_ip in {"psv_cortexr5" "psx_cortexr52" "cortexr52"}} {
                set tcm_ip [hsi::get_cells -hier -filter {NAME=~"*tcm_ram_global" || NAME=~"*tcm_alias"}]
                if {[llength $tcm_ip] == 1} {
                        set tcm_high_addr [get_highaddr $tcm_ip]
                        set tcm_base_addr [get_baseaddr $tcm_ip]
                        set tcm_size [format 0x%x [expr {${tcm_high_addr} - ${tcm_base_addr} + 1}]]
                        if {[scan $tcm_size %x] > [scan $ddr_base_addr %x]} {
                                set ddr_base_addr $tcm_size
                        }
                }
        }
        return $ddr_base_addr
    }