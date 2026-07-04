`include "uvm_macros.svh"
import uvm_pkg::*;

//////////////////////////////////////////////////
// Producer component broadcasting data using
// an analysis port.
//////////////////////////////////////////////////
class producer extends uvm_component;
  `uvm_component_utils(producer)
  
  uvm_analysis_port #(int) port;

  int data = 12;
  
  function new(input string path = "producer", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  // Create the analysis port
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    port = new("port", this);
  endfunction
  
  // Broadcast data
  task main_phase(uvm_phase phase);
    phase.raise_objection(this);

    `uvm_info("PROD", $sformatf("Data Broadcasted : %0d", data), UVM_NONE);

    port.write(data);

    phase.drop_objection(this);
  endtask
  
endclass

//////////////////////////////////////////////////
// First consumer receiving broadcast data.
//////////////////////////////////////////////////
class consumer1 extends uvm_component;
  `uvm_component_utils(consumer1)
  
  uvm_analysis_imp #(int, consumer1) imp;
  
  function new(input string path = "consumer1", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  // Create analysis implementation
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction
  
  // Receive broadcast data
  virtual function void write(int datar);
    `uvm_info("CONS1", $sformatf("Data Recv : %0d", datar), UVM_NONE);
  endfunction
  
endclass

//////////////////////////////////////////////////
// Second consumer receiving broadcast data.
//////////////////////////////////////////////////
class consumer2 extends uvm_component;
  `uvm_component_utils(consumer2)
  
  uvm_analysis_imp #(int, consumer2) imp;
  
  function new(input string path = "consumer2", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  // Create analysis implementation
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction
  
  // Receive broadcast data
  virtual function void write(int datar);
    `uvm_info("CONS2", $sformatf("Data Recv : %0d", datar), UVM_NONE);
  endfunction
  
endclass

//////////////////////////////////////////////////
// Environment that creates and connects the
// producer and consumers.
//////////////////////////////////////////////////
class env extends uvm_env;
  `uvm_component_utils(env)

  producer p;
  consumer1 c1;
  consumer2 c2;

  function new(input string path = "env", uvm_component parent = null);
    super.new(path, parent);
  endfunction
 
  // Create components
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    c1 = consumer1::type_id::create("c1", this);
    c2 = consumer2::type_id::create("c2", this);
    p  = producer::type_id::create("p", this);
  endfunction

  // Connect analysis port to multiple consumers
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    p.port.connect(c1.imp);
    p.port.connect(c2.imp);
  endfunction
 
endclass

//////////////////////////////////////////////////
// Test that creates the environment.
//////////////////////////////////////////////////
class test extends uvm_test;
  `uvm_component_utils(test)

  env e;
 
  function new(input string path = "test", uvm_component parent = null);
    super.new(path, parent);
  endfunction
 
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    e = env::type_id::create("e", this);
  endfunction
 
endclass

//////////////////////////////////////////////////
// Top-level testbench
// Starts the UVM test.
//////////////////////////////////////////////////
module tb;

initial begin
  run_test("test");
end

endmodule











What this example demonstrates
uvm_analysis_port is used to broadcast transactions to multiple subscribers.
uvm_analysis_imp implements the write() method in each consumer.
Calling port.write(data) sends the same data to all connected analysis implementations.
Unlike put(), get(), or transport(), analysis communication is non-blocking and supports one-to-many connections.
Both consumer1 and consumer2 receive the value 12 simultaneously.

TLM data flow:

             Producer
        analysis_port.write()
             │
      ┌──────┴──────┐
      ▼             ▼
Consumer1      Consumer2
 analysis_imp   analysis_imp
      │             │
   write()       write()
