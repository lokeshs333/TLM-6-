`include "uvm_macros.svh"
import uvm_pkg::*;

//////////////////////////////////////////////////
// Sub-producer that generates and sends data.
//////////////////////////////////////////////////
class subproducer extends uvm_component;
  `uvm_component_utils(subproducer)
  
  int data = 12;

  uvm_blocking_put_port #(int) subport;
  
  function new(input string path = "subproducer", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  // Create the sub-producer port
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    subport = new("subport", this);
  endfunction
  
  // Send data during main phase
  task main_phase(uvm_phase phase);
    phase.raise_objection(this);

    `uvm_info("SUBPROD", $sformatf("Data Sent : %0d", data), UVM_NONE);

    subport.put(data);

    phase.drop_objection(this);
  endtask
  
endclass

//////////////////////////////////////////////////
// Producer containing the sub-producer.
//////////////////////////////////////////////////
class producer extends uvm_component;
  `uvm_component_utils(producer)
  
  subproducer s;

  uvm_blocking_put_port #(int) port;
  
  function new(input string path = "producer", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  // Create producer port and sub-producer
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    port = new("port", this);
    s = subproducer::type_id::create("s", this);
  endfunction
  
  // Forward sub-producer port to producer port
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    s.subport.connect(port);
  endfunction
  
endclass

//////////////////////////////////////////////////
// Consumer implementing the blocking put interface.
//////////////////////////////////////////////////
class consumer extends uvm_component;
  `uvm_component_utils(consumer)
  
  uvm_blocking_put_imp #(int, consumer) imp;
  
  function new(input string path = "consumer", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  // Create put implementation
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    imp = new("imp", this);
  endfunction
  
  // Receive data
  function void put(int datar);
    `uvm_info("CONS", $sformatf("Data Rcvd : %0d", datar), UVM_NONE);
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

    p.port.connect(c.imp);
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
subproducer generates the transaction and sends it through subport.
The producer acts as a forwarding component by connecting subport to its own port.
The environment connects the producer's port to the consumer's imp.
The data travels through multiple TLM connections before reaching the consumer.

TLM data flow:

SubProducer
 subport.put(data)
        │
        ▼
Producer.subport
        │
        ▼
Producer.port
        │
        ▼
Consumer.imp
        │
        ▼
consumer.put(data)

This example demonstrates hierarchical TLM communication, where a child component sends data through its parent before it reaches the final receiver.
