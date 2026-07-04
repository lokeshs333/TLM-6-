`include "uvm_macros.svh"
import uvm_pkg::*;

//////////////////////////////////////////////////
// Producer component demonstrating blocking
// transport communication.
//////////////////////////////////////////////////
class producer extends uvm_component;
  `uvm_component_utils(producer)
  
  uvm_blocking_transport_port #(int, int) port;
  
  int datas = 12;
  int datar = 0;
  
  function new(input string path = "producer", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  // Create the transport port
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    port = new("port", this);
  endfunction
  
  // Send request and receive response
  task main_phase(uvm_phase phase);
    phase.raise_objection(this);
  
    port.transport(datas, datar);
    
    `uvm_info("PROD",
      $sformatf("Data Sent : %0d , Data Recv : %0d", datas, datar),
      UVM_NONE);

    phase.drop_objection(this);
  endtask
  
endclass

//////////////////////////////////////////////////
// Consumer component implementing the blocking
// transport interface.
//////////////////////////////////////////////////
class consumer extends uvm_component;
  `uvm_component_utils(consumer)
  
  int datas = 13;
  int datar = 0;
  
  uvm_blocking_transport_imp #(int, int, consumer) imp;
  
  function new(input string path = "consumer", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  // Create the transport implementation
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp = new("imp", this);
  endfunction
  
  // Receive request and return response
  virtual task transport(input int datar, output int datas);
    datas = this.datas;

    `uvm_info("CONS",
      $sformatf("Data Sent : %0d , Data Recv : %0d", datas, datar),
      UVM_NONE);
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
uvm_blocking_transport_port supports request-response communication in a single transaction.
The producer calls transport(request, response) to send data and receive a reply.
uvm_blocking_transport_imp implements the transport() task in the consumer.
The consumer receives the producer's request (datar) and returns its own response (datas).
This demonstrates blocking transport TLM, where request and response are exchanged through a single interface.

TLM data flow:

Producer
 transport(request, response)
          │
          ▼
blocking_transport_port
          │
          ▼
blocking_transport_imp
          │
          ▼
consumer.transport(request, response)
          │
          ▼
Response returned to Producer
