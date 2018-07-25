#####################################################################
#
# Genus(TM) Synthesis Solution setup file
# Created by Genus(TM) Synthesis Solution 17.21-s010_1
#   on 05/05/2018 12:45:10
#
#
#####################################################################


# This script is intended for use with Genus(TM) Synthesis Solution version 17.21-s010_1


# Remove Existing Design
###########################################################
if {[::legacy::find -design /designs/top] ne ""} {
  puts "** A design with the same name is already loaded. It will be removed. **"
  delete_obj /designs/top
}


# To allow user-readonly attributes
########################################################
::legacy::set_attribute -quiet force_tui_is_remote 1 /


# Libraries
###########################################################
::legacy::set_attribute library {/tsmc16/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn16ffcllbwp16p90_100a/tcbn16ffcllbwp16p90ssgnp0p72vm40c.lib /tsmc16/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tphn16ffcllgv18e_110c/tphn16ffcllgv18essgnp0p72v1p62vm40c.lib /sim/nikhil3/run4_16x162/synth3/top/../memory_tile_unq1/pnr.lib /sim/nikhil3/run4_16x162/synth3/top/../pe_tile_new_unq1/pnr.lib} /

::legacy::set_attribute lef_library {/tsmc16/download/TECH16FFC/N16FF_PRTF_Cad_1.2a/PR_tech/Cadence/LefHeader/Standard/VHV/N16_Encounter_9M_2Xa1Xd3Xe2Z_UTRDL_9T_PODE_1.2a.tlef /sim/nikhil3/run4_16x162/synth3/top/../pe_tile_new_unq1/pnr.lef /sim/nikhil3/run4_16x162/synth3/top/../memory_tile_unq1/pnr.lef /sim/bclim/TO_mdll/mdll_top_Model/library/mdll_top.lef /tsmc16/TSMCHOME/digital/Back_End/lef/tcbn16ffcllbwp16p90_100a/lef/tcbn16ffcllbwp16p90.lef /tsmc16/TSMCHOME/digital/Back_End/lef/tpbn16v_090a/fc/fc_lf_bu/APRDL/lef/tpbn16v.lef /tsmc16/TSMCHOME/digital/Back_End/lef/tphn16ffcllgv18e_110e/mt_1/9m/9M_2XA1XD_H_3XE_VHV_2Z/lef/tphn16ffcllgv18e_9lm.lef /tsmc16/pdk/2016.09.15_MOSIS/FFC/T-N16-CL-DR-032/N16_DTCD_library_kit_20160111/N16_DTCD_library_kit_20160111/lef/topMxyMxe_M9/N16_DTCD_v1d0a.lef /tsmc16/pdk/2016.09.15_MOSIS/FFC/T-N16-CL-DR-032/N16_ICOVL_library_kit_FF+_20150528/N16_ICOVL_library_kit_FF+_20150528/lef/topMxMxaMxc_M9/N16_ICOVL_v1d0a.lef} /
::legacy::set_attribute qrc_tech_file /tsmc16/download/TECH16FFC/cworst/Tech/cworst_CCworst_T/qrcTechFile /


# Design
###########################################################
read_netlist -top top results_syn/syn_out.v
read_metric -id current results_syn/syn_out.metrics.json

source results_syn/syn_out.g
puts "\n** Restoration Completed **\n"


# Data Integrity Check
###########################################################
# program version
if {"[string_representation [::legacy::get_attribute program_version /]]" != "17.21-s010_1"} {
   mesg_send [::legacy::find -message /messages/PHYS/PHYS-91] "golden program_version: 17.21-s010_1  current program_version: [string_representation [::legacy::get_attribute program_version /]]"
}
# license
if {"[string_representation [::legacy::get_attribute startup_license /]]" != "Genus_Synthesis"} {
   mesg_send [::legacy::find -message /messages/PHYS/PHYS-91] "golden license: Genus_Synthesis  current license: [string_representation [::legacy::get_attribute startup_license /]]"
}
# slack
set _slk_ [::legacy::get_attribute slack /designs/top]
if {[regexp {^-?[0-9.]+$} $_slk_]} {
  set _slk_ [format %.1f $_slk_]
}
if {$_slk_ != "-1582.1"} {
   mesg_send [::legacy::find -message /messages/PHYS/PHYS-92] "golden slack: -1582.1,  current slack: $_slk_"
}
unset _slk_
# multi-mode slack
# tns
set _tns_ [::legacy::get_attribute tns /designs/top]
if {[regexp {^-?[0-9.]+$} $_tns_]} {
  set _tns_ [format %.0f $_tns_]
}
if {$_tns_ != "9016936"} {
   mesg_send [::legacy::find -message /messages/PHYS/PHYS-92] "golden tns: 9016936,  current tns: $_tns_"
}
unset _tns_
# cell area
set _cell_area_ [::legacy::get_attribute cell_area /designs/top]
if {[regexp {^-?[0-9.]+$} $_cell_area_]} {
  set _cell_area_ [format %.0f $_cell_area_]
}
if {$_cell_area_ != "2179361"} {
   mesg_send [::legacy::find -message /messages/PHYS/PHYS-92] "golden cell area: 2179361,  current cell area: $_cell_area_"
}
unset _cell_area_
# net area
set _net_area_ [::legacy::get_attribute net_area /designs/top]
if {[regexp {^-?[0-9.]+$} $_net_area_]} {
  set _net_area_ [format %.0f $_net_area_]
}
if {$_net_area_ != "17305"} {
   mesg_send [::legacy::find -message /messages/PHYS/PHYS-92] "golden net area: 17305,  current net area: $_net_area_"
}
unset _net_area_
