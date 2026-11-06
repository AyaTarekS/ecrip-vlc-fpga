
# ============================================================
# FFT/IFFT Standalone Simulation
# Vivado 2021.2
# ============================================================

# -------------------------
# 1. Configuration
# -------------------------

set ROOT_DIR "D:/CRIP-system/ifft"

set RTL_DIR    [file join $ROOT_DIR rtl]
set TB_DIR     [file join $ROOT_DIR tb]
set VEC_DIR    [file join $ROOT_DIR vectors]
set SIM_DIR    [file join $ROOT_DIR sim]

set WORK_DIR   [file join $SIM_DIR sim_work]
set IP_TCL_DIR [file join $ROOT_DIR ip_tcl]

set TOP "ifft_tb"

set TB_FILE    [file join $TB_DIR ifft_tb.sv]
set INPUT_FILE [file join $VEC_DIR ifft_input_vectors.mem]

# FFT twiddle-factor ROM initialization file
set ROM_FILE [file join $RTL_DIR \
    fft1d_fft1d_Pipeline_stage_loop_butterfly_loop_TWID_ROM_AUTO_1R.dat]

set PART "xc7z030sbv485-3"

# -------------------------
# 2. Check directories/files
# -------------------------

foreach dir [list $RTL_DIR $TB_DIR $VEC_DIR $SIM_DIR $IP_TCL_DIR] {
    if {![file isdirectory $dir]} {
        error "Directory not found: $dir"
    }
}

foreach f [list $TB_FILE $INPUT_FILE $ROM_FILE] {
    if {![file exists $f]} {
        error "File not found: $f"
    }
}

# Create simulation work directory
file mkdir $WORK_DIR

puts "\n=================================="
puts "Configuration verified."
puts "=================================="

# -------------------------
# 3. IP generation scripts
# -------------------------

set IP_TCL_FILES [list \
    [file join $IP_TCL_DIR fft1d_faddfsub_32ns_32ns_32_4_no_dsp_1_ip.tcl] \
    [file join $IP_TCL_DIR fft1d_faddfsub_32ns_32ns_32_4_full_dsp_1_ip.tcl] \
    [file join $IP_TCL_DIR fft1d_fmul_32ns_32ns_32_4_max_dsp_1_ip.tcl] \
]

foreach f $IP_TCL_FILES {
    if {![file exists $f]} {
        error "IP Tcl script not found: $f"
    }
}

# -------------------------
# 4. Check current Vivado project
# -------------------------

if {[current_project -quiet] eq ""} {
    error "No Vivado project is open. Open your project before running this script."
}

set PROJECT_NAME [get_property NAME [current_project]]
set PROJECT_DIR  [get_property DIRECTORY [current_project]]

puts "\nProject: $PROJECT_NAME"
puts "Project directory: $PROJECT_DIR"

# Actual XSim simulation working directory
set XSIM_DIR [file join $PROJECT_DIR \
    "${PROJECT_NAME}.sim" sim_1 behav xsim]

# -------------------------
# 5. Create all three IPs
# -------------------------

#puts "\n=================================="
#puts "Creating Floating Point IPs..."
#puts "=================================="

#foreach f $IP_TCL_FILES {
#    puts "\nSourcing IP script: [file tail $f]"

#    if {[catch {
#        source $f
#    } result]} {
#        puts $result
#        error "Failed to create IP from $f"
#    }
#}

# -------------------------
# 6. Generate IP simulation models
# -------------------------

puts "\n=================================="
puts "Generating IP simulation targets..."
puts "=================================="

set IPS [get_ips]

if {[llength $IPS] != 3} {
    error "Expected 3 IPs, found [llength $IPS]: $IPS"
}

foreach ip $IPS {
    puts "Generating simulation target: $ip"

    if {[catch {
        generate_target {synthesis simulation} $ip
    } result]} {
        puts $result
        error "IP target generation failed: $ip"
    }
}

# -------------------------
# 7. Add generated RTL
# -------------------------

puts "\n=================================="
puts "Adding RTL sources..."
puts "=================================="

proc collect_verilog {dir} {
    set result {}

    foreach f [glob -nocomplain -directory $dir *] {
        if {[file isdirectory $f]} {
            set result [concat $result [collect_verilog $f]]
        } elseif {[string match "*.v" [file tail $f]] ||
                  [string match "*.sv" [file tail $f]]} {
            lappend result $f
        }
    }

    return $result
}

set RTL_FILES [collect_verilog $RTL_DIR]

if {[llength $RTL_FILES] == 0} {
    error "No RTL files found in $RTL_DIR"
}

add_files -norecurse $RTL_FILES

# -------------------------
# 8. Add testbench and data files
# -------------------------

puts "\n=================================="
puts "Adding testbench and data files..."
puts "=================================="

add_files -fileset sim_1 -norecurse $TB_FILE
add_files -fileset sim_1 -norecurse $INPUT_FILE
add_files -fileset sim_1 -norecurse $ROM_FILE

set_property top $TOP [get_filesets sim_1]

puts "Testbench added: $TB_FILE"
puts "Input vectors added: $INPUT_FILE"
puts "FFT ROM added: $ROM_FILE"

# -------------------------
# 9. Copy data files to XSim
# -------------------------

puts "\n=================================="
puts "Preparing XSim working directory..."
puts "=================================="

file mkdir $XSIM_DIR

# Copy input vectors to XSim working directory.
# The testbench reads this file using a relative path.
file copy -force $INPUT_FILE \
    [file join $XSIM_DIR ifft_input_vectors.mem]

# Also keep a copy in sim_work.
file copy -force $INPUT_FILE \
    [file join $WORK_DIR ifft_input_vectors.mem]

# Copy FFT twiddle ROM to XSim working directory.
# The generated RTL reads the ROM using its filename.
file copy -force $ROM_FILE \
    [file join $XSIM_DIR [file tail $ROM_FILE]]

if {![file exists [file join $XSIM_DIR [file tail $ROM_FILE]]]} {
    error "FFT ROM copy failed."
}

if {![file exists [file join $XSIM_DIR ifft_input_vectors.mem]]} {
    error "Input vector copy failed."
}

puts "Input vectors copied successfully."
puts "FFT ROM copied successfully."
puts "XSim directory: $XSIM_DIR"

# -------------------------
# 10. Set compile order
# -------------------------

puts "\n=================================="
puts "Updating compile order..."
puts "=================================="

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# -------------------------
# 11. Export simulation scripts
# -------------------------

puts "\n=================================="
puts "Exporting simulation setup..."
puts "=================================="

set EXPORT_DIR [file join $SIM_DIR exported_sim]

file mkdir $EXPORT_DIR

export_simulation \
    -of_objects [get_filesets sim_1] \
    -directory $EXPORT_DIR \
    -simulator xsim \
    -force

# -------------------------
# 12. Launch simulation
# -------------------------

puts "\n=================================="
puts "Launching behavioral simulation..."
puts "=================================="

launch_simulation -simset sim_1 -mode behavioral

puts "\n=================================="
puts "Simulation launched."
puts "Run 'run all' in the simulation Tcl console."
puts "=================================="

run all
