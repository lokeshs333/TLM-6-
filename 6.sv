`include "uvm_macros.svh"
import uvm_pkg::*;

//////////////////////////////////////////////////
// Producer component that requests data using a
// blocking get port.
//////////////////////////////////////////////////
class producer extends uvm_component;
  `uvm_component_utils(producer)
  
  uvm_blocking_get_port #(int) port;

  int data = 0;
  
  function new(input string path = "producer", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  // Create the get port
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    port = new("port", this);
  endfunction
  
  // Receive data during main phase
  task main_phase(uvm_phase phase);
    phase.raise_objection(this);

    port.get(data);

    `uvm_info("PROD", $sformatf("Data Recv : %0d", data), UVM_NONE);

    phase.drop_objection(this);
  endtask
  
endclass

//////////////////////////////////////////////////
// Consumer component implementing the blocking
// get interface.
//////////////////////////////////////////////////
class consumer extends uvm_component;
  `uvm_component_utils(consumer)
  
  int data = 12;

  uvm_blocking_get_imp #(int, consumer) imp;
  
  function new(input string path = "consumer", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  // Create the get implementation
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction
  
  // Provide data to the producer
  virtual task get(output int datar);
    `uvm_info("CONS", $sformatf("Data Sent : %0d", data), UVM_NONE);

    datar = data;
  endtask
  
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

    c = consumer::type_id::create("c", this);
    p = producer::type_id::create("p", this);
  endfunction

  // Connect producer to consumer
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    p.port.connect(c.imp);
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
uvm_blocking_get_port is used by the producer to request data.
uvm_blocking_get_imp implements the get() method in the consumer.
Calling port.get(data) causes the producer to wait until the consumer provides the requested data.
The consumer assigns its local value (12) to the output argument, which the producer receives and prints.
This demonstrates blocking get communication, where the consumer acts as the data provider and the producer acts as the data requester.

TLM data flow:

Producer
 port.get(data)
      │
      ▼
blocking_get_port
      │
      ▼
blocking_get_imp
      │
      ▼
consumer.get(data)
      │
      ▼
Data returned to Producer
