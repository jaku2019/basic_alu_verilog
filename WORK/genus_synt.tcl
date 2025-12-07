# Ustawienie nazwy modulu nadrzednego calego projektu 
# podlegajacego syntezie logicznej
set TOP_DESIGN_NAME     TOP


###	KONFIGURACJA I WYKONIE SYNTEZY LOGICZNEJ I OPTYMALIZACJI CZASOWEJ
###
### !!!   NIE MODYFIKOWAC   !!!

set MODEL_TIMING  "./timing_model.sdc"

set GATES   "/dk/xfab/PDK/xh018/diglibs/D_CELLS_HD/v4_0"
set TECHS   "/dk/xfab/PDK/xh018/cadence/v8_0/techLEF/v8_0_1_1"
set QRCP    "/dk/xfab/PDK/xh018/cadence/v8_1/QRC_assura/v8_1_1/XH018_1143"

set LIB_LEF ""
set LIB_LEF "$LIB_LEF ${TECHS}/xh018_xx43_HD_MET4_METMID_METTHK.lef"                                   
set LIB_LEF "$LIB_LEF ${GATES}/LEF/v4_0_0/xh018_D_CELLS_HD.lef"   
set LIB_LEF "$LIB_LEF ${GATES}/LEF/v4_0_0/xh018_xx43_MET4_METMID_METTHK_D_CELLS_HD_mprobe.lef"           

## library_sets
create_library_set -name lib_ss \
        -timing "${GATES}/liberty_LPMOS/v4_0_0/PVT_1_80V_range/D_CELLS_HD_LPMOS_slow_1_62V_125C.lib"
			  
create_library_set -name lib_ff \
    -timing     "${GATES}/liberty_LPMOS/v4_0_0/PVT_1_80V_range/D_CELLS_HD_LPMOS_fast_1_98V_m40C.lib"

create_library_set -name lib_tt \
    -timing     "${GATES}/liberty_LPMOS/v4_0_0/PVT_1_80V_range/D_CELLS_HD_LPMOS_typ_1_80V_25C.lib"

## timing_condition
create_timing_condition -name tc_ss \
    -library_sets { lib_ss }
create_timing_condition -name tc_ff \
    -library_sets { lib_ff }
create_timing_condition -name tc_tt \
    -library_sets { lib_tt }

## rc_corner
create_rc_corner -name rc_ss \
    -temperature 125.0 \
    -pre_route_res 1.0 \
    -pre_route_cap 1.0 \
    -pre_route_clock_res 0.0 \
    -pre_route_clock_cap 0.0 \
    -post_route_res {1.0 1.0 1.0} \
    -post_route_cap {1.0 1.0 1.0} \
    -post_route_cross_cap {1.0 1.0 1.0} \
    -post_route_clock_res {1.0 1.0 1.0} \
    -post_route_clock_cap {1.0 1.0 1.0} \
    -qrc_tech "${QRCP}/QRC-Max/qrcTechFile"

create_rc_corner -name rc_ff \
    -temperature -40.0 \
    -pre_route_res 1.0 \
    -pre_route_cap 1.0 \
    -pre_route_clock_res 0.0 \
    -pre_route_clock_cap 0.0 \
    -post_route_res {1.0 1.0 1.0} \
    -post_route_cap {1.0 1.0 1.0} \
    -post_route_cross_cap {1.0 1.0 1.0} \
    -post_route_clock_res {1.0 1.0 1.0} \
    -post_route_clock_cap {1.0 1.0 1.0}\
    -qrc_tech "${QRCP}/QRC-Min/qrcTechFile"

create_rc_corner -name rc_tt \
    -temperature 25.0 \
    -pre_route_res 1.0 \
    -pre_route_cap 1.0 \
    -pre_route_clock_res 0.0 \
    -pre_route_clock_cap 0.0 \
    -post_route_res {1.0 1.0 1.0} \
    -post_route_cap {1.0 1.0 1.0} \
    -post_route_cross_cap {1.0 1.0 1.0} \
    -post_route_clock_res {1.0 1.0 1.0} \
    -post_route_clock_cap {1.0 1.0 1.0}\
    -qrc_tech "${QRCP}/QRC-Typ/qrcTechFile"

## delay_corner
create_delay_corner -name dc_ss \
    -early_timing_condition { tc_ss } \
    -late_timing_condition { tc_ss } \
    -early_rc_corner rc_ss \
    -late_rc_corner rc_ss

create_delay_corner -name dc_ff \
    -early_timing_condition { tc_ff } \
    -late_timing_condition { tc_ff } \
    -early_rc_corner rc_ff \
    -late_rc_corner rc_ff

create_delay_corner -name dc_tt \
    -early_timing_condition { tc_tt } \
    -late_timing_condition { tc_tt } \
    -early_rc_corner rc_tt \
    -late_rc_corner rc_tt

create_constraint_mode -name cm_normal \
   		-sdc_files "${MODEL_TIMING}"
		
create_analysis_view -name av_tt_normal \
    -constraint_mode cm_normal \
	-delay_corner    dc_tt

create_analysis_view -name av_ss_normal \
    -constraint_mode cm_normal \
	-delay_corner    dc_ss

create_analysis_view -name av_ff_normal \
    -constraint_mode cm_normal \
	-delay_corner    dc_ff
	

set TOP_DEFINES {ALL}

set_db lp_insert_clock_gating 				 	true
set_db lp_insert_discrete_clock_gating_logic  	false
set_db hdl_error_on_blackbox 				 	true
set_db hdl_reg_naming_style 		 	%s_%s
set_db hdl_record_naming_style	 		%s_%s
set_db hdl_parameter_naming_style 		_%s_%d
set_db hdl_instance_array_naming_style 	%s_%d
set_db hdl_generate_index_style		 	%s_%d
set_db hdl_bus_wire_naming_style 		%s_%d
set_db hdl_array_naming_style	 		%s_%d
set_db init_hdl_search_path             ../MODEL
set_db auto_ungroup                     none
set_db disable_ungroup_for_hierarchy    true


set_analysis_view 	-setup  {av_ss_normal av_tt_normal } \
		  			-hold   {av_tt_normal av_ff_normal}
		  			
set model_verilog [exec find ../MODEL -name *.v]
foreach c $model_verilog {

	puts "ODCZYTANIE pliku Verilog: $c"
	read_hdl -language v2001 $c

}
set model_verilog [exec find ../MODEL -name *.sv]
foreach c $model_verilog {

	puts "ODCZYTANIE pliku SystemVerilog: $c"
	read_hdl -language sv $c

}
set_db information_level 10
set_db lef_library $LIB_LEF
set_db delete_hier_insts_on_preserved_net false
set_db merge_combinational_hier_instances false 

set cell [vfind -lib_cell SDF*]
foreach c $cell {

	puts "SET $c dont_use=true"
	set_db $c .dont_use true

}

set cell [vfind -lib_cell *DLY*]
foreach c $cell {

	puts "SET $c dont_use=true"
	set_db $c .avoid false
	set_db $c .dont_use false

}

set cell 			   [vfind -lib_cell LGC*]
set cell [concat $cell [vfind -lib_cell LSG*]]
set cell [concat $cell [vfind -lib_cell LSO*]]
foreach c $cell {
	puts "SET $c dont_use=false"
	set_db $c .avoid false
	set_db $c .dont_use false
}

elaborate ${TOP_DESIGN_NAME}
init_design
syn_generic
write_hdl     						> ./gates_generic.v

syn_map
write_hdl     						> ./gates_map.v

syn_opt
write_hdl     						> ./gates_optimized.v

write_sdc  -view av_ss_normal		> ./gates_timing.sdc

write_reports -directory 			 ./gates_reports/ 	-tag gates
write_mmmc 	  -library -dir 		 ./gates_mmmc 

set_analysis_view -setup av_ss_normal
write_sdf     -view av_ss_normal  >  ./gates_slow.sdf

set_analysis_view -setup av_ff_normal
write_sdf     -view av_ff_normal  >  ./gates_fast.sdf

gui_show
