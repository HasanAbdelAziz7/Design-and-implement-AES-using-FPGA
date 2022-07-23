interface AES_if;
//input signals
logic [7:0]data_byte;
logic [7:0]key_byte;
logic clk_sig;
logic reset_sig;
logic enable_sig;
//output signals
logic [7:0]data_byte_out;
logic ready_sig;
logic load_sig;
endinterface
