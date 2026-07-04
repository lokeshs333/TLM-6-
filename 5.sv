`include "uvm_macros.svh"
import uvm_pkg::*;

//////////////////////////////////////////////////
// Producer component that sends data using a
// blocking put port.
//////////////////////////////////////////////////
class producer extends uvm_component;
  `uvm_component_utils(producer)
  
  int data = 12;

  uvm_blocking_put_port #(int) port;
  
  function new(input string path = "producer", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  // Create the put port
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    port = new("port", this);
  endfunction
  
  // Send data during main phase
  task main_phase(uvm_phase phase);
    phase.raise_objection(this);

    `uvm_info("PROD", $sformatf("Data Sent : %0d", data), UVM_NONE);

    port.put(data);

    phase.drop_objection(this);
  endtask
  
endclass

//////////////////////////////////////////////////
// Sub-consumer implementing the blocking put
// interface.
//////////////////////////////////////////////////
class subconsumer extends uvm_component;
  `uvm_component_utils(subconsumer)
  
  uvm_blocking_put_imp #(int, subconsumer) imp;
  
  function new(input string path = "subconsumer", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  // Create the put implementation
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction
  
  // Receive data
  function void put(int datar);
    `uvm_info("SUBCONS", $sformatf("Data Rcvd : %0d", datar), UVM_NONE);
  endfunction
  
endclass

//////////////////////////////////////////////////
// Consumer containing a sub-consumer and a
// blocking put export.
//////////////////////////////////////////////////
class consumer extends uvm_component;
  `uvm_component_utils(consumer)
  
  uvm_blocking_put_export #(int) expo;
  subconsumer s;
  
  function new(input string path = "consumer", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  // Create export and sub-consumer
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    expo = new("expo", this);
    s = subconsumer::type_id::create("s", this);
  endfunction
  
  // Forward export to the sub-consumer
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    expo.connect(s.imp);
  endfunction
  
endclass

//////////////////////////////////////////////////
// Environment that creates and connects the
// producer and consumer.
//////////////////////////////////////////////////
class env extends uvm_env;
  `uvm_component_utils(env)

  producer p;
  consumer c;
 
  function new(input string path = "env", uvm_component parent = null);
    super.new(path, parent);
  endfunction
 
  // Create components
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    p = producer::type_id::create("p", this);
    c = consumer::type_id::create("c", this);
  endfunction

  // Connect producer to consumer
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    p.port.connect(c.expo);
  endfunction
 
endclass

//////////////////////////////////////////////////
// Test that creates the environment and prints
// the component hierarchy.
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

  // Display the UVM hierarchy
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
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
The producer sends data through a uvm_blocking_put_port.
The consumer contains a uvm_blocking_put_export, which forwards the transaction to its child component.
The subconsumer implements the put() method using uvm_blocking_put_imp.
The export acts as a pass-through, allowing the parent component to forward transactions to the child implementation.

TLM data flow:

Producer
 port.put(data)
      │
      ▼
blocking_put_port
      │
      ▼
Consumer.expo
      │
      ▼
SubConsumer.imp
      │
      ▼
subconsumer.put(data)

This example demonstrates hierarchical TLM communication using an export, where the parent component forwards transactions to a child component that implements the interface.
