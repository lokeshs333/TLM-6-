`include "uvm_macros.svh"
import uvm_pkg::*;

//////////////////////////////////////////////////
// Producer component with a blocking put port.
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
    
endclass

//////////////////////////////////////////////////
// Consumer component with a blocking put export.
//////////////////////////////////////////////////
class consumer extends uvm_component;
  `uvm_component_utils(consumer)
  
  // Export used to receive data
  uvm_blocking_put_export #(int) recv;
  
  function new(input string path = "consumer", uvm_component parent = null);
    super.new(path, parent);

    recv = new("recv", this);
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

  // Connect producer port to consumer export
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    p.send.connect(c.recv);
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
uvm_blocking_put_port is a TLM port used by the producer to send data.
uvm_blocking_put_export is an export that forwards the put interface to an implementation.
The connection p.send.connect(c.recv) establishes a TLM communication path between the producer and consumer.
This example focuses only on creating and connecting the TLM port and export. No data transfer occurs because no put() method or implementation is provided.

TLM connection:

Producer
  send (blocking_put_port)
          │
          ▼
Consumer
  recv (blocking_put_export)
