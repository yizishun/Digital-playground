set device xc7z020clg400-2

set script_dir  [file dirname [info script]]

# Add files for system top
set src_files [list \
  "[file normalize "${script_dir}/rtl/system_top.sv"]" \
]

# Add files for constraint
set xdc_files [list \
  "[file normalize "${script_dir}/constr/constr.xdc"]" \
]

source ${script_dir}/../common.tcl
