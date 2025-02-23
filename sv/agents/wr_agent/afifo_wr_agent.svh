`ifndef AFIFO_WR_AGENT_SVH
`define AFIFO_WR_AGENT_SVH

class afifo_wr_agent extends uvm_agent;
  `uvm_component_utils(afifo_wr_agent)
  
  virtual afifo_wr_driver_bfm 		m_drv_bfm;
  virtual afifo_wr_monitor_bfm 	 	m_mon_bfm;
  afifo_wr_agent_cfg 				m_agent_cfg;
  
  uvm_sequencer #(afifo_txn)	 	m_seqr;
  afifo_wr_driver   		 		m_drv;
  afifo_wr_monitor 			 		m_mon;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(virtual afifo_wr_driver_bfm)::get(this, "", "wr_drv_bfm", m_drv_bfm)) begin
       `uvm_fatal(get_type_name(), "Couldn't retrieve WRITE DRIVER BFM")
    end

    if (!uvm_config_db#(virtual afifo_wr_monitor_bfm)::get(this, "", "wr_mon_bfm", m_mon_bfm)) begin
       `uvm_fatal(get_type_name(), "Couldn't retrieve WRITE MONITOR BFM")
    end

    if (!uvm_config_db#(afifo_wr_agent_cfg)::get(this, "", "wr_agent_cfg", m_agent_cfg)) begin
       `uvm_fatal(get_type_name(), "Couldn't retrieve WRITE AGENT CONFIG")
    end
       
    m_mon = afifo_wr_monitor::type_id::create("m_mon", this);
    uvm_config_db#(virtual afifo_wr_monitor_bfm)::set(this, "m_mon", "wr_mon_bfm", m_mon_bfm);
       
    if(m_agent_cfg.is_active == UVM_ACTIVE) begin 
      m_seqr = uvm_sequencer#(afifo_txn)::type_id::create("m_seqr", this); 
      m_drv  = afifo_wr_driver ::type_id::create("m_drv",  this);
      
      uvm_config_db#(virtual afifo_wr_driver_bfm)::set(this, "m_drv", "wr_drv_bfm", m_drv_bfm);
      uvm_config_db#(afifo_wr_agent_cfg)::set(this, "m_drv", "wr_agent_cfg", m_agent_cfg);
      uvm_config_db#(afifo_wr_agent_cfg)::set(this, "m_seqr", "wr_agent_cfg", m_agent_cfg);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    if(m_agent_cfg.is_active == UVM_ACTIVE)
      m_drv.seq_item_port.connect(m_seqr.seq_item_export);
  endfunction
endclass
             
`endif      
