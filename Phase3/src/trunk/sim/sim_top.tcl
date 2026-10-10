	alias clc ".main clear"
	
	clc
	exec vlib work
	vmap work work
	
	set TB					"testbench_mode3"
	set hdl_path			"../src/hdl"
	set inc_path			"../src/inc"
	
	# set run_time			"1 us"
	set run_time			"-all"

#============================ Add verilog files  ===============================
# Pleas add other module here	
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/buffer.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/circular_buffer.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/controller_buffer.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/adder.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/datapath.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/filter_base_cnt.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/filter_offset_cnt.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/FilterScratchPad.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/final_register.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/IFMapScratchPad.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/PSumScratchPad.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/main_controller.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/multiplier.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/Mux2to1.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/read_data_cnt.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/read_data_controller.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/read_filter_cnt.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/read_filter_controller.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/Register.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/stride_counter.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/top.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/top_wrapper.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/write_counter.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/write_controller.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/psum_counter.v
	vlog 	+acc -incr -source  +define+SIM 	$hdl_path/final_top.v
		
	vlog 	+acc -incr -source  +incdir+$inc_path +define+SIM 	./tb/$TB.v
	onerror {break}

#================================ simulation ====================================

	vsim	-voptargs=+acc -debugDB $TB


#======================= adding signals to wave window ==========================


	add wave -bin -group 	 	{TB}				sim:/$TB/*
	add wave -bin -group 	 	{top}				sim:/$TB/uut/*	
	add wave -bin -group -r		{all}				sim:/$TB/*

#=========================== Configure wave signals =============================
	
	configure wave -signalnamewidth 2
    

#====================================== run =====================================

	run $run_time 
	