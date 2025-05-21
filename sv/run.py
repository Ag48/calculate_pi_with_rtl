from vunit.verilog import VUnit

vu = VUnit.from_argv(compile_builtins=False)
vu.add_verilog_builtins()
lib = vu.add_library("lib")
lib.add_source_files("src/*.sv")
lib.add_source_files("tb/*.sv")

# vu.set_sim_option("modelsim.vsim_flags", ["-novopt"])

vu.main()
                
