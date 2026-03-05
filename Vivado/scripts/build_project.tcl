# --- Configuration ---
set project_name "systolic_array"
set output_dir   "../work"
set part_name    "xc7a35tcpg236-1";# <--- REPLACE THIS with your specific FPGA part

# --- 1. Create Project ---
# Create the project in the output directory and select the part
create_project $project_name $output_dir -part $part_name -force

# --- 2. Add Sources ---
# Recursively add all files from the hdl directory
add_files "../hdl"

# Recursively add all files from the sim directory (for simulation set only)
add_files -fileset sim_1 "../sim"

# --- 3. Add Constraints ---
# Add constraints and ensure they are used for synthesis/implementation
add_files -fileset constrs_1 "../xdc"

# --- 4. Configuration ---
# Set the top module name (Replace 'top_module' with your actual top module name)
set_property top top_module [current_fileset]

# Update compile order based on file dependencies
update_compile_order -fileset sources_1

puts "Project created successfully!"