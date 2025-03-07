`ifndef AFIFO_ENV_SVH
`define AFIFO_ENV_SVH

class afifo_env extends uvm_env;
  `uvm_component_utils(afifo_env)
  
  afifo_wr_agent      m_wr_agent;
  afifo_wr_agent_cfg  m_wr_agent_cfg;
  afifo_rd_agent      m_rd_agent;
  afifo_rd_agent_cfg  m_rd_agent_cfg;
  
  afifo_scoreboard  m_scb;
  afifo_coverage    m_cov;

  function new(string name = "afifo_env", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

//     if(!uvm_config_db#(afifo_wr_agent_cfg)::get(this, "", "wr_agent_cfg", m_wr_agent_cfg))
//       m_wr_agent_cfg = afifo_wr_agent_cfg::type_id::create("m_wr_agent_cfg", this);
   
//     if(!uvm_config_db#(afifo_rd_agent_cfg)::get(this, "", "rd_agent_cfg", m_rd_agent_cfg))
//       m_rd_agent_cfg = afifo_rd_agent_cfg::type_id::create("rd_agent_cfg", this);
    
//     uvm_config_db#(afifo_wr_agent_cfg)::set(this, "m_wr_agent", "wr_agent_cfg", m_wr_agent_cfg);
//     uvm_config_db#(afifo_rd_agent_cfg)::set(this, "m_rd_agent", "rd_agent_cfg", m_rd_agent_cfg);

    m_wr_agent = afifo_wr_agent::type_id::create("m_wr_agent", this);
    m_rd_agent = afifo_rd_agent::type_id::create("m_rd_agent", this);

    m_cov = afifo_coverage# (afifo_txn)::type_id::create("m_cov", this);
    m_scb = afifo_scoreboard::type_id::create("m_scb", this);
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    m_wr_agent.m_mon.ap.connect(m_scb.wr_imp);
    m_rd_agent.m_mon.ap.connect(m_scb.rd_imp);
    
    uvm_config_db#(uvm_sequencer#(afifo_txn))::set(uvm_root::get(), "*.vseq*", "wr_seqr", this.m_wr_agent.m_seqr);
    uvm_config_db#(uvm_sequencer#(afifo_txn))::set(uvm_root::get(), "*.vseq*", "rd_seqr", this.m_rd_agent.m_seqr);
  endfunction : connect_phase
endclass

`endif
