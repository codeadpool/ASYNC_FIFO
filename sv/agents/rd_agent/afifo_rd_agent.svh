`ifndef AFIFO_RD_AGENT_SVH
`define AFIFO_RD_AGENT_SVH

class afifo_rd_agent extends uvm_agent;
  `uvm_component_utils(afifo_rd_agent)

  virtual afifo_rd_driver_bfm   m_drv_bfm;
  virtual afifo_rd_monitor_bfm  m_mon_bfm;
  afifo_rd_agent_cfg            m_agent_cfg;
  
  uvm_sequencer #(afifo_txn)    m_seqr;
  afifo_rd_driver               m_drv;
  afifo_rd_monitor              m_mon;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual afifo_rd_driver_bfm)::get(this, "", "rd_drv_bfm", m_drv_bfm)) begin
       `uvm_fatal(get_type_name(), "Couldn't retrieve READ DRIVER BFM")
    end

    if (!uvm_config_db#(virtual afifo_rd_monitor_bfm)::get(this, "", "rd_mon_bfm", m_mon_bfm)) begin
       `uvm_fatal(get_type_name(), "Couldn't retrieve READ MONITOR BFM")
    end

    if (!uvm_config_db#(afifo_rd_agent_cfg)::get(this, "", "rd_agent_cfg", m_agent_cfg)) begin
      	`uvm_fatal("RD_AGNT/CFG_ERR", "Couldn't retrieve READ AGENT CONFIG")
    end

    m_mon = afifo_rd_monitor::type_id::create("m_mon", this);
    uvm_config_db#(virtual afifo_rd_monitor_bfm)::set(this, "m_mon", "rd_mon_bfm", m_mon_bfm);

    if(m_agent_cfg.is_active == UVM_ACTIVE)begin
      m_seqr = uvm_sequencer#(afifo_txn)::type_id::create("m_seqr", this);
      m_drv  = afifo_rd_driver::type_id::create("m_drv", this);

      uvm_config_db#(virtual afifo_rd_driver_bfm)::set(this, "m_drv", "rd_drv_bfm", m_drv_bfm);
      uvm_config_db#(afifo_rd_agent_cfg)::set(this, "m_drv", "rd_agent_cfg", m_agent_cfg);
      uvm_config_db#(afifo_rd_agent_cfg)::set(this, "m_seqr", "rd_agent_cfg", m_agent_cfg);
    end
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    if(m_agent_cfg.is_active == UVM_ACTIVE)
      m_drv.seq_item_port.connect(m_seqr.seq_item_export);
  endfunction : connect_phase
endclass

`endif

