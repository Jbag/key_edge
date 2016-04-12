`timescale		1ns/1ns

module		key_edge_tb;

//--------系统输入-----------------
reg		clk;
reg		rst_n;
reg		key;
//--------系统输出-----------------
wire	key_come;

initial
	begin
		clk		=	0;
		rst_n	=	0;
		key		=	1;
		#1000
		rst_n	=	1;
		repeat(5)
			begin
				#200	key	=	0;
				#200	key	=	1;
				#200	key	=	0;
				#200	key	=	1;
				#200	key	=	0;
				#(22*1000)	key	=	1;
			end
	end
	
always	#10		clk	=	~clk;

key_edge	key_edge_inst(
	.clk				(clk),
	.rst_n				(rst_n),
	.key				(key),
	.key_come			(key_come)
);

endmodule