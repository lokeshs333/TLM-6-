`include "uvm_macros.svh"
import uvm_pkg::*;

//////////////////////////////////////////////////
// Producer component that sends data using a
// blocking put port.
//////////////////////////////////////////////////
class producer extends uvm_component;
  `uvm_component_utils(producer)
  
  int data = 12;

  // Port used to send data
  uvm_blocking_put_port #(int) send;
  
  function new(input string path = "producer", uvm_component parent = null);
    super.new(path, parent);

    send = new("send", this);
  endfunction
  
  // Send data during main phase
  task main_phase(uvm_phase phase);
    phase.raise_objection(this);

    send.put(data);
    `uvm_info("PROD", $sformatf("Data Sent : %0d", data), UVM_NONE);

    phase.drop_objection(this);
  endtask
    
endclass

//////////////////////////////////////////////////
// Consumer component that receives data through
// a blocking put implementation.
//////////////////////////////////////////////////
class consumer extends uvm_component;
  `uvm_component_utils(consumer)
  
  uvm_blocking_put_export #(int) recv;
  uvm_blocking_put_imp #(int, consumer) imp;
  
  function new(input string path = "consumer", uvm_component parent = null);
    super.new(path, parent);

    recv = new("recv", this);
    imp  = new("imp", this);
  endfunction
  
  // Receive data from the producer
  task put(int datar);
    `uvm_info("CONS", $sformatf("Data Rcvd : %0d", datar), UVM_NONE);
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

    p = producer::type_id::create("p", this);
    c = consumer::type_id::create("c", this);
  endfunction
  
  // Connect TLM ports and implementation
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  
    p.send.connect(c.recv);
    c.recv.connect(c.imp);
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
uvm_blocking_put_port is used by the producer to send data.
uvm_blocking_put_export forwards the transaction to the implementation.
uvm_blocking_put_imp provides the actual implementation of the put() method in the consumer.
Calling send.put(data) in the producer invokes the consumer's put() task through the TLM connection.
The producer and consumer communicate using blocking TLM communication, where the sender waits until the put() operation completes.

TLM data flow:

Producer
 send.put(data)
      │
      ▼
blocking_put_port
      │
      ▼
blocking_put_export
      │
      ▼
blocking_put_imp
      │
      ▼
consumer.put(data)
