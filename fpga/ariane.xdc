## Common Ariane XDCs

create_clock -period 100.000 -name jtag_TCK -waveform {0.000 50.000} [get_ports jtag_TCK]
set_input_jitter jtag_TCK 1.000

# minimize routing delay
set_input_delay  -clock jtag_TCK -clock_fall 5 [get_ports jtag_TDI        ]
set_input_delay  -clock jtag_TCK -clock_fall 5 [get_ports jtag_TMS        ]
set_output_delay -clock jtag_TCK             5 [get_ports jtag_TDO_data   ]
set_output_delay -clock jtag_TCK             5 [get_ports jtag_TDO_driven ]
set_false_path   -from                         [get_ports jtag_TRSTn      ] 


set_max_delay -datapath_only -from [get_pins i_dm_axi_top/i_dmi_jtag/i_dmi_cdc/i_cdc_resp/i_src/data_src_q_reg*/C] -to [get_pins i_dmi_jtag/i_dmi_cdc/i_cdc_resp/i_dst/data_dst_q_reg*/D] 20.000
set_max_delay -datapath_only -from [get_pins i_dm_axi_top/i_dmi_jtag/i_dmi_cdc/i_cdc_resp/i_src/req_src_q_reg/C] -to [get_pins i_dmi_jtag/i_dmi_cdc/i_cdc_resp/i_dst/req_dst_q_reg/D] 20.000
set_max_delay -datapath_only -from [get_pins i_dm_axi_top/i_dmi_jtag/i_dmi_cdc/i_cdc_req/i_dst/ack_dst_q_reg/C] -to [get_pins i_dmi_jtag/i_dmi_cdc/i_cdc_req/i_src/ack_src_q_reg/D] 20.000

# set multicycle path on reset, on the FPGA we do not care about the reset anyway
set_multicycle_path -from [get_pins i_rstgen_main/i_rstgen_bypass/synch_regs_q_reg[3]/C] 4
set_multicycle_path -from [get_pins i_rstgen_main/i_rstgen_bypass/synch_regs_q_reg[3]/C] 3  -hold
