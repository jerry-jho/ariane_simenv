// Copyright (c) 2014-2018 ETH Zurich, University of Bologna
//
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Fabian Schuiki <fschuiki@iis.ee.ethz.ch>
//
// This file defines the interfaces we support.

import axi_pkg::*;


/// An AXI4 interface.
interface AXI_BUS #(
  parameter AXI_ADDR_WIDTH = -1,
  parameter AXI_DATA_WIDTH = -1,
  parameter AXI_ID_WIDTH   = -1,
  parameter AXI_USER_WIDTH = -1
);

  localparam AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8;

  typedef logic [AXI_ID_WIDTH-1:0]   id_t;
  typedef logic [AXI_ADDR_WIDTH-1:0] addr_t;
  typedef logic [AXI_DATA_WIDTH-1:0] data_t;
  typedef logic [AXI_STRB_WIDTH-1:0] strb_t;
  typedef logic [AXI_USER_WIDTH-1:0] user_t;

  id_t        aw_id;
  addr_t      aw_addr;
  logic [7:0] aw_len;
  logic [2:0] aw_size;
  burst_t     aw_burst;
  logic       aw_lock;
  cache_t     aw_cache;
  prot_t      aw_prot;
  qos_t       aw_qos;
  region_t    aw_region;
  logic [5:0] aw_atop;
  user_t      aw_user;
  logic       aw_valid;
  logic       aw_ready;

  data_t      w_data;
  strb_t      w_strb;
  logic       w_last;
  user_t      w_user;
  logic       w_valid;
  logic       w_ready;

  id_t        b_id;
  resp_t      b_resp;
  user_t      b_user;
  logic       b_valid;
  logic       b_ready;

  id_t        ar_id;
  addr_t      ar_addr;
  logic [7:0] ar_len;
  logic [2:0] ar_size;
  burst_t     ar_burst;
  logic       ar_lock;
  cache_t     ar_cache;
  prot_t      ar_prot;
  qos_t       ar_qos;
  region_t    ar_region;
  user_t      ar_user;
  logic       ar_valid;
  logic       ar_ready;

  id_t        r_id;
  data_t      r_data;
  resp_t      r_resp;
  logic       r_last;
  user_t      r_user;
  logic       r_valid;
  logic       r_ready;

  modport Master (
    output aw_id, aw_addr, aw_len, aw_size, aw_burst, aw_lock, aw_cache, aw_prot, aw_qos, aw_region, aw_atop, aw_user, aw_valid, input aw_ready,
    output w_data, w_strb, w_last, w_user, w_valid, input w_ready,
    input b_id, b_resp, b_user, b_valid, output b_ready,
    output ar_id, ar_addr, ar_len, ar_size, ar_burst, ar_lock, ar_cache, ar_prot, ar_qos, ar_region, ar_user, ar_valid, input ar_ready,
    input r_id, r_data, r_resp, r_last, r_user, r_valid, output r_ready
  );

  modport Slave (
    input aw_id, aw_addr, aw_len, aw_size, aw_burst, aw_lock, aw_cache, aw_prot, aw_qos, aw_region, aw_atop, aw_user, aw_valid, output aw_ready,
    input w_data, w_strb, w_last, w_user, w_valid, output w_ready,
    output b_id, b_resp, b_user, b_valid, input b_ready,
    input ar_id, ar_addr, ar_len, ar_size, ar_burst, ar_lock, ar_cache, ar_prot, ar_qos, ar_region, ar_user, ar_valid, output ar_ready,
    output r_id, r_data, r_resp, r_last, r_user, r_valid, input r_ready
  );

endinterface


