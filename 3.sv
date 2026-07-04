`include "uvm_macros.svh"
import uvm_pkg::*;

//////////////////////////////////////////////////
// Producer component that sends data using a
// blocking put port.
//////////////////////////////////////////////////
class producer extends uvm_component;
  `uvm_component_utils(producer)
  
  int data = 12;

  uvm_blocking_put_port #(int) send;
  
  function new(input string path = "producer", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  // Create the blocking put port
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    send = new("send", this);
  endfunction
  
  // Send data during main phase
  task main_phase(uvm_phase phase);
    phase.raise_objection(this);

    `uvm_info("PROD", $sformatf("Data Sent : %0d", data), UVM_NONE);

    send.put(data);

    phase.drop_objection(this);
  endtask
  
endclass

//////////////////////////////////////////////////
// Consumer component implementing the blocking
// put interface.
//////////////////////////////////////////////////
class consumer extends uvm_component;
  `uvm_component_utils(consumer)
  
  uvm_blocking_put_imp #(int, consumer) imp;
  
  function new(input string path = "consumer", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  // Create the put implementation
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction
  
  // Receive data from the producer
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
 
  function new(input string inst = "env", uvm_component c);
    super.new(inst, c);
  endfunction
 
  // Create components
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    p = producer::type_id::create("p", this);
    c = consumer::type_id::create("c", this);
  endfunction

  // Connect producer directly to the implementation
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    p.send.connect(c.imp);
  endfunction
 
endclass

//////////////////////////////////////////////////
// Test that creates the environment.
//////////////////////////////////////////////////
class test extends uvm_test;
  `uvm_component_utils(test)

  env e;
 
  function new(input string inst = "test", uvm_component c);
    super.new(inst, c);
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
uvm_blocking_put_port sends data from the producer.
uvm_blocking_put_imp directly implements the put() method in the consumer.
Unlike the previous example, no uvm_blocking_put_export is used. The port connects directly to the implementation.
Calling send.put(data) invokes the consumer's put() function through the TLM connection.
This is the simplest form of blocking put communication between two UVM components.

TLM data flow:

Producer
 send.put(data)
      │
      ▼
blocking_put_port
      │
      ▼
blocking_put_imp
      │
      ▼
consumer.put(data)
