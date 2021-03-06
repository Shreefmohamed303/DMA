module MIPS(Data_Bus,Address_Bus,Control,IReady , TReady ,clk , HOLD , HOLD_ACK, IOW, IOR ,cs);
// ******* DMA HOLD ************
input wire HOLD;
output reg HOLD_ACK;
reg DONT_NEED_BUS ;
// ******* Bus Registers *******
reg[7:0] data_bus ;
reg[15 :0] address_bus ;
reg control , iready  ;
initial begin control = 0; iready = 0 ; end
// ******* Bus ************
inout wire[7:0] Data_Bus;
inout wire[15:0] Address_Bus;
inout wire Control , IReady , TReady ;
input wire clk;
input cs;
output reg IOR,IOW;
reg CS;
// ******* Assign inout **********
assign Data_Bus 	= (!HOLD_ACK && Control)? data_bus : 'bz ; 
assign Address_Bus	= (!HOLD_ACK)? address_bus : 'bz ;
assign Control 		= (!HOLD_ACK)? control : 'bz ;
assign IReady 		= (!HOLD_ACK)? iready : 'bz ;
// ******* Modules ********
reg[31:0] PC ;
reg[31:0] RegFile[0:31];
reg[31:0] InsMemory[0:1024];
// ******* variables ******
integer i ,file ,size, _ ;
reg[31:0] ins;
reg[5:0] operand , fun;
reg[4:0] rs_1 , rs_2 , rt ,shift;
reg[15:0] value_16_bit  ;
// ********DMA Assembler Interaction Wires to Support DMA Modes*******
reg [15:0] source,destination,count;


// ********** Main Flow ************
// blocking assignment 
always@(posedge clk)
begin
$display("ins=%0h,PC=%0d",ins,PC); 
if (PC > size-1 )
	$finish;
// Fetch
ins = InsMemory[PC];
PC  = PC +1;
// Control Unit
operand =  ins[31:26];
rs_1    =  ins[25:21];
rs_2  	=  ins[20:16];
rt    	=  ins[15:11]; 
shift 	=  ins[10:6];
fun   	=  ins[5:0] ;
value_16_bit = ins[15:0];
// ALU
if (operand == 0) // R-Format
begin 
	case(fun)
	0  : RegFile[rt] = RegFile[rs_1] << shift; // sll
	2  : RegFile[rt] = RegFile[rs_1] >> shift; // srl
	32 : RegFile[rt] = RegFile[rs_1] + RegFile[rs_2]; // add
	34 : RegFile[rt] = RegFile[rs_1] - RegFile[rs_2]; // sub
	36 : RegFile[rt] = RegFile[rs_1] & RegFile[rs_2]; // and 
	37 : RegFile[rt] = RegFile[rs_1] | RegFile[rs_2]; // or
	38 : RegFile[rt] = RegFile[rs_1] ^ RegFile[rs_2]; // xor
	39 : RegFile[rt] = ~(RegFile[rs_1] | RegFile[rs_2]); // nor
	endcase
	DONT_NEED_BUS = 1 ;
end
// ***************Supporting DMA Modules***************

// ***************IO To Memory Mode********************
else if (operand == 6'b0100_00)
begin
// 1===== Reg-1
// Writing to base current address register 1st-cycle
address_bus = 16'h0004;		// master change the address bus to assign the a specific register
data_bus = 8'h00;	// master change the databus 200 decimal as a binary in 1 clock cycle
IOW = 0;
IOR = 1;
CS = 0;
// write
iready   = 1; 			// Initiator Ready with writing data
@(posedge TReady); 		// wait for Target Ack reciving 
iready = 0 ; 			// indication that the operation has finished(slave is waiting for this negedge to make TReady=0 too)
DONT_NEED_BUS =0 ;		// need it
@(posedge clk);
// 1===== Reg-1
// Writing to base current address register 2nd-cycle
address_bus = 16'h0004;		// master change the address bus to assign the a specific register
data_bus = 8'hc8;	// master change the databus 200 decimal as a binary in 1 clock cycle
IOW = 0;
IOR = 1;
CS = 0;
// write
iready   = 1; 			// Initiator Ready with writing data
@(posedge TReady); 		// wait for Target Ack reciving 
iready = 0 ; 			// indication that the operation has finished(slave is waiting for this negedge to make TReady=0 too)
DONT_NEED_BUS =0 ;		// need it
@(posedge clk);
@(posedge clk);
@(posedge clk);
// 1===== Reg-2
// Writing to base current word address register 1st-cycle
address_bus = 16'h0005;		// master change the address bus to assign the a specific register
data_bus = 8'b0000_0000;			// master change the databus
IOW = 0;
IOR = 1;
CS = 0;
// write
iready   = 1; 			// Initiator Ready with writing data
@(posedge TReady); 		// wait for Target Ack reciving 
iready = 0 ; 			// indication that the operation has finished(slave is waiting for this negedge to make TReady=0 too)
DONT_NEED_BUS =0 ;		// need it
@(posedge clk);
// Writing to base current word address register 2nd-cycle
address_bus = 16'h0005;		// master change the address bus to assign the a specific register
data_bus = 8'b0000_0010;			// master change the databus
IOW = 0;
IOR = 1;
CS = 0;
// write
iready   = 1; 			// Initiator Ready with writing data
@(posedge TReady); 		// wait for Target Ack reciving 
iready = 0 ; 			// indication that the operation has finished(slave is waiting for this negedge to make TReady=0 too)
DONT_NEED_BUS =0 ;		// need it
@(posedge clk);
@(posedge clk);
// 1===== Reg-3
// Writing to command address register
address_bus = 16'h0008;		// master change the address bus to assign the a specific register
data_bus = 8'b1100_0000;	// master change the databus
IOW = 0;
IOR = 1;
CS = 0;
// write
iready   = 1; 			// Initiator Ready with writing data
@(posedge TReady); 	// wait for Target Ack reciving 
iready = 0 ; 			// indication that the operation has finished(slave is waiting for this negedge to make TReady=0 too)
DONT_NEED_BUS =0 ;		// need it
@(posedge clk);
// 1===== Reg-4
// Writing to request address register
address_bus = 16'h0009;		// master change the address bus to assign the a specific register
data_bus = 8'b0000_0000;	// master change the databus
IOW = 0;
IOR = 1;
CS = 0;
// write
iready   = 1; 			// Initiator Ready with writing data
@(posedge TReady); 		// wait for Target Ack reciving 
iready = 0 ; 			// indication that the operation has finished(slave is waiting for this negedge to make TReady=0 too)
DONT_NEED_BUS = 0 ;		// need it
@(posedge clk);
// 1===== Reg-5
// Writing to Mode address register
address_bus = 16'h000b;		// master change the address bus to assign the a specific register
data_bus = 8'b0010_0100;	// master change the databus
IOW = 0;
IOR = 1;
CS = 0;
// write
iready   = 1; 			// Initiator Ready with writing data
@(posedge TReady); 		// wait for Target Ack reciving 
iready = 0 ; 			// indication that the operation has finished(slave is waiting for this negedge to make TReady=0 too)
DONT_NEED_BUS =0 ;		// need it
@(posedge clk);
// 1===== Reg-6
// Writing to Mask address register
address_bus = 16'h000f;		// master change the address bus to assign the a specific register
data_bus = 8'b0000_0000;	// master change the databus
IOW = 0;
IOR = 1;
CS = 0;
// write
iready   = 1; 			// Initiator Ready with writing data
@(posedge TReady); 		// wait for Target Ack reciving 
iready = 0 ; 			// indication that the operation has finished(slave is waiting for this negedge to make TReady=0 too)
DONT_NEED_BUS =0 ;		// need it
@(posedge clk);
IOW = 1;
IOR = 1;
CS = 1;
end
// **************Memory To IO Mode*********************
else if (operand == 6'b1000_00)
begin
// 2===== Reg-1
// Writing to base current address register
address_bus = 4'b0000;		// master change the address bus to assign the a specific register
data_bus = 8'b0000_1111;	// master change the databus 15 decimal as a binary in 1 clock cycle
IOW = 0;
IOR = 1;
CS = 0;
// write
iready   = 1; 			// Initiator Ready with writing data
@(posedge TReady); 		// wait for Target Ack reciving 
iready = 0 ; 			// indication that the operation has finished(slave is waiting for this negedge to make TReady=0 too)
DONT_NEED_BUS =0 ;		// need it
// 2===== Reg-2
// Writing to base current word address register
address_bus = 4'b0001;		// master change the address bus to assign the a specific register
data_bus = 4;			// master change the databus
IOW = 0;
IOR = 1;
CS = 0;
// write
iready   = 1; 			// Initiator Ready with writing data
@(posedge TReady); 		// wait for Target Ack reciving 
iready = 0 ; 			// indication that the operation has finished(slave is waiting for this negedge to make TReady=0 too)
DONT_NEED_BUS =0 ;		// need it
// 2===== Reg-3
// Writing to command address register
address_bus = 4'b1000;		// master change the address bus to assign the a specific register
data_bus = 8'b1100_0000;	// master change the databus
IOW = 0;
IOR = 1;
CS = 0;
// write
iready   = 1; 			// Initiator Ready with writing data
@(posedge TReady); 		// wait for Target Ack reciving 
iready = 0 ; 			// indication that the operation has finished(slave is waiting for this negedge to make TReady=0 too)
DONT_NEED_BUS =0 ;		// need it
// 2===== Reg-4
// Writing to request address register
address_bus = 4'b1001;		// master change the address bus to assign the a specific register
data_bus = 8'b0000_0000;	// master change the databus
IOW = 0;
IOR = 1;
CS = 0;
// write
iready   = 1; 			// Initiator Ready with writing data
@(posedge TReady); 		// wait for Target Ack reciving 
iready = 0 ; 			// indication that the operation has finished(slave is waiting for this negedge to make TReady=0 too)
DONT_NEED_BUS =0 ;		// need it
// 2===== Reg-5
// Writing to Mode address register
address_bus = 4'b1011;		// master change the address bus to assign the a specific register
data_bus = 8'b0010_1001;	// master change the databus
IOW = 0;
IOR = 1;
CS = 0;
// write
iready   = 1; 			// Initiator Ready with writing data
@(posedge TReady); 		// wait for Target Ack reciving 
iready = 0 ; 			// indication that the operation has finished(slave is waiting for this negedge to make TReady=0 too)
DONT_NEED_BUS =0 ;		// need it
// 2===== Reg-6
// Writing to Mask address register
address_bus = 4'b1111;		// master change the address bus to assign the a specific register
data_bus = 8'b0000_0000;	// master change the databus
IOW = 0;
IOR = 1;
CS = 0;
// write
iready   = 1; 			// Initiator Ready with writing data
@(posedge TReady); 		// wait for Target Ack reciving 
iready = 0 ; 			// indication that the operation has finished(slave is waiting for this negedge to make TReady=0 too)
DONT_NEED_BUS =0 ;		// need it
end
// **************Memory To Memory Mode******************
else if (operand == 6'b1100_00)
begin

	// Values are taken from GUI-Assembler
	source = ins[29:20];		// Loading source value from InsMemory[29:20] 
	destination = ins[19:10];	// Loading destination value from InsMemory[19:10]
	count = ins[9:0];   		// Loading count value from InsMemory[9:0]
// 3===== Reg-1
// =======1st 2 Cycles (Source)
// Writing to base current address register ===== 1st cycle (Source)
address_bus = 4'b0000;		// master change the address bus to assign the a specific register
data_bus = source[7:0] ;	// master change the databus by the 10-bit source decimal in 2 clock cycles
IOW = 0;
IOR = 1;
CS = 0;
// write
iready   = 1; 			// Initiator Ready with writing data
@(posedge TReady); 		// wait for Target Ack reciving 
iready = 0 ; 			// indication that the operation has finished(slave is waiting for this negedge to make TReady=0 too)
DONT_NEED_BUS =0 ;		// need it

// Delay by clock rate to send the rest data-bits on the data bus 
#100

// Writing to base current address register ===== 2nd cycle (Source)
address_bus = 4'b0000;		// master change the address bus to assign the a specific register
data_bus = source[15:8] ;	// master change the databus by the 10-bit source decimal in 2 clock cycles
IOW = 0;
IOR = 1;
CS = 0;
// write
iready   = 1; 			// Initiator Ready with writing data
@(posedge TReady); 		// wait for Target Ack reciving 
iready = 0 ; 			// indication that the operation has finished(slave is waiting for this negedge to make TReady=0 too)
DONT_NEED_BUS =0 ;		// need it

// ========2nd 2cycles (Destination) 
// Writing to base current address register ===== 1st cycle (Destination)
address_bus = 4'b0010;		// master change the address bus to assign the a specific register
data_bus = destination[7:0] ;	// master change the databus by the 10-bit source decimal in 2 clock cycles
IOW = 0;
IOR = 1;
CS = 0;
// write
iready   = 1; 			// Initiator Ready with writing data
@(posedge TReady); 		// wait for Target Ack reciving 
iready = 0 ; 			// indication that the operation has finished(slave is waiting for this negedge to make TReady=0 too)
DONT_NEED_BUS =0 ;		// need it

// Delay by clock rate to send the rest data-bits on the data bus 
#100

// Writing to base current address register ===== 2nd cycle (Destination)
address_bus = 4'b0010;			// master change the address bus to assign the a specific register
data_bus = destination[15:8] ;	// master change the databus by the 10-bit source decimal in 2 clock cycles
IOW = 0;
IOR = 1;
CS = 0;
// write
iready   = 1; 			// Initiator Ready with writing data
@(posedge TReady); 		// wait for Target Ack reciving 
iready = 0 ; 			// indication that the operation has finished(slave is waiting for this negedge to make TReady=0 too)
DONT_NEED_BUS =0 ;		// need it

// 3===== Reg-2
// Writing to base current word address register (1st Cycle) channel-0
address_bus = 4'b0001;		// master change the address bus to assign the a specific register
data_bus = count[7:0];		// master change the databus by how many bytes to transfer stored in count reg
IOW = 0;
IOR = 1;
CS = 0;
// write
iready   = 1; 			// Initiator Ready with writing data
@(posedge TReady); 		// wait for Target Ack reciving 
iready = 0 ; 			// indication that the operation has finished(slave is waiting for this negedge to make TReady=0 too)
DONT_NEED_BUS =0 ;		// need it

// Delay by clock rate to send the rest data-bits on the data bus 
#100
// Writing to base current word address register (2nd Cycle) channel-0
address_bus = 4'b0001;			// master change the address bus to assign the a specific register
data_bus = count[15:8];		// master change the databus by how many bytes to transfer stored in count reg
IOW = 0;
IOR = 1;
CS = 0;
// write
iready   = 1; 			// Initiator Ready with writing data
@(posedge TReady); 		// wait for Target Ack reciving 
iready = 0 ; 			// indication that the operation has finished(slave is waiting for this negedge to make TReady=0 too)
DONT_NEED_BUS =0 ;		// need it

// 3===== Reg-2
// Writing to base current word address register (1st Cycle) channel-1
address_bus = 4'b0011;		// master change the address bus to assign the a specific register
data_bus = count[7:0];		// master change the databus by how many bytes to transfer stored in count reg
IOW = 0;
IOR = 1;
CS = 0;
// write
iready   = 1; 			// Initiator Ready with writing data
@(posedge TReady); 		// wait for Target Ack reciving 
iready = 0 ; 			// indication that the operation has finished(slave is waiting for this negedge to make TReady=0 too)
DONT_NEED_BUS =0 ;		// need it

// Delay by clock rate to send the rest data-bits on the data bus 
#100
// Writing to base current word address register (2nd Cycle) channel-1
address_bus = 4'b0011;			// master change the address bus to assign the a specific register
data_bus = count[15:8];		// master change the databus by how many bytes to transfer stored in count reg
IOW = 0;
IOR = 1;
CS = 0;
// write
iready   = 1; 			// Initiator Ready with writing data
@(posedge TReady); 		// wait for Target Ack reciving 
iready = 0 ; 			// indication that the operation has finished(slave is waiting for this negedge to make TReady=0 too)
DONT_NEED_BUS =0 ;		// need it

// 3===== Reg-3
// Writing to command address register
address_bus = 4'b1000;		// master change the address bus to assign the a specific register
data_bus = 8'b1100_0001;	// master change the databus
IOW = 0;
IOR = 1;
CS = 0;
// write
iready   = 1; 			// Initiator Ready with writing data
@(posedge TReady); 		// wait for Target Ack reciving 
iready = 0 ; 			// indication that the operation has finished(slave is waiting for this negedge to make TReady=0 too)
DONT_NEED_BUS =0 ;		// need it
// 3===== Reg-4
// Writing to request address register
address_bus = 4'b1001;		// master change the address bus to assign the a specific register
data_bus = 8'b0000_0000;	// master change the databus
IOW = 0;
IOR = 1;
CS = 0;
// write
iready   = 1; 			// Initiator Ready with writing data
@(posedge TReady); 		// wait for Target Ack reciving 
iready = 0 ; 			// indication that the operation has finished(slave is waiting for this negedge to make TReady=0 too)
DONT_NEED_BUS =0 ;		// need it
// 3===== Reg-5
// Writing to Mode address register
address_bus = 4'b1011;		// master change the address bus to assign the a specific register
data_bus = 8'b0010_0100;	// master change the databus
IOW = 0;
IOR = 1;
CS = 0;
// write
iready   = 1; 			// Initiator Ready with writing data
@(posedge TReady); 		// wait for Target Ack reciving 
iready = 0 ; 			// indication that the operation has finished(slave is waiting for this negedge to make TReady=0 too)
DONT_NEED_BUS =0 ;		// need it
// 3===== Reg-6
// Writing to Mask address register
address_bus = 4'b1111;		// master change the address bus to assign the a specific register
data_bus = 8'b0000_0000;	// master change the databus
IOW = 0;
IOR = 1;
CS = 0;
// write
iready   = 1; 			// Initiator Ready with writing data
@(posedge TReady); 		// wait for Target Ack reciving 
iready = 0 ; 			// indication that the operation has finished(slave is waiting for this negedge to make TReady=0 too)
DONT_NEED_BUS =0 ;		// need it
end


else if (operand == 8) begin // addi
	RegFile[rs_2] = RegFile[rs_1] + value_16_bit ; 
	DONT_NEED_BUS = 1 ; end

// ************ READ FROM BUS ********************
else if (operand == 9) // LW
begin
if(HOLD_ACK) begin @(negedge HOLD_ACK); end
$display("LW");
// LW $s0,100 ===== load the address 100 and store it in $s0
address_bus = value_16_bit;	 // master puts the address in the register to assign the inout Address_Bus 
control = 0;			 // read
iready = 1; 		  	 // master is ready
@(posedge TReady);		 // wait for Target ack
RegFile[rs_2] = Data_Bus;	 // when Target is Ready >> Read the Data_Bus
iready = 0;			 // to indicate that the bus has no operation(slave is waiting for this negedge to make TReady=0 too)
DONT_NEED_BUS = 0; 		 // need it
end 
// ************* WRITE TO BUS *******************
else if (operand == 10)  // SW
begin
if(HOLD_ACK) begin @(negedge HOLD_ACK); end
$display("SW");
// SW $s0,100 ===== store the value of $s0 in address 100
address_bus = value_16_bit;	// master change the register to assign the inout address
data_bus = RegFile[rs_2];	// master change the register to assign the inout data
control  = 1; 			// write
iready   = 1; 			// Initiator Ready with writing data
@(posedge TReady); 		// wait for Target Ack reciving 
iready = 0 ; 			// indication that the operation has finished(slave is waiting for this negedge to make TReady=0 too)
DONT_NEED_BUS =0 ;		// need it
end 
// ***** Print Register File ******
for (i = 0 ; i < 31; i = i+1) begin $write ("RegFile[%0d]=%0d .",i,RegFile[i]); end $write ("\n%0d\n",PC);

end // always

// ********* DMA HOLD ************
always@(posedge HOLD)
begin
if(!DONT_NEED_BUS)		  // condition to handle the state that hold is 1 and processor needs the bus
	@(posedge DONT_NEED_BUS); // wait for processor to finish his work on the bus
HOLD_ACK = 1;			  // ACK to DMA To start using the bus
end
always@(negedge HOLD)
begin
HOLD_ACK = 0;
end


// ======================== FeedBack =======================
integer file2 ;
integer f; initial begin f = 1; end 
initial begin file2 = $fopen("feedback.txt","w"); end
always@(negedge clk)
begin
if(f) begin f = 0 ; end 
else $fwrite(file2,"%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d\n",PC-1,Data_Bus,Address_Bus,Control,HOLD,HOLD_ACK,DONT_NEED_BUS,0,0,0,0);
end
// =========================================================

integer file1;
// ******** initialization ***********
initial
begin
DONT_NEED_BUS = 1;
// pc
PC = 0;
// Instruction Memory
$readmemh("ins.txt",InsMemory);
// regFile
for(i =0 ; i < 32; i = i+1)
begin RegFile[i] = 0; end 
source = 0;
destination = 0;
count = 0;
control = 1;
// ******** Size Calculation ******
size = 0;
file1 = $fopen("ins.txt","r");
// calculate size of instruction file
while (! $feof (file1) ) begin _ = $fscanf (file1,"%h",_); size = size +1; end $display ("SIZE === %d ",size);
// ********************	*************
HOLD_ACK = 0;
end // initial


endmodule

/******* Bus ********
********* Data_Bus : 32 ********* 
for data , can be accssed by anyone on the bus (master in write operation and slave in read operation)
********* Address_Bus : 16 bit *********		
for address , can be accessed by master only
********* Control : 1 bit *********		
for(read/write) , can be accessed by master only	
********* IReady : 1 bit  *********	
indication that the master finished(put data&address in write mode "or" put address in read mode)
can be accessed by Master only
******* TReady : 1 bit *********
indication that the slave finished(successfuly write in write mode "or" put data in read mode)
can be accessed by slave only
********************/
module tb_MIPS();
reg clk ;
wire[7:0] Data_Bus;
wire[15:0] Address_Bus;
wire Control , IReady , TReady;
reg HOLD ; wire HOLD_ACK;

reg[7:0] data_bus  ;
reg[15:0] add =0;
reg iready  ,control  ;
//assign Data_Bus = (HOLD_ACK===1 && Control)? data_bus : 'bz;
//assign Address_Bus = (HOLD_ACK===1 )? add : 'bz;
//assign Control = (HOLD_ACK===1 )? control : 'bz;
//assign IReady = (HOLD_ACK===1 )? iready : 'bz;
wire IOR,IOW , CS;

RAM ram_ray2(Data_Bus,Address_Bus,Control,IReady,TReady,clk);
MIPS mips_ray2(Data_Bus,Address_Bus,Control,IReady,TReady,clk,HOLD,HOLD_ACK,IOW, IOR, CS);

always begin #10 clk = ~clk; end
initial begin clk = 0 ; end
initial begin
//#110
//HOLD = 1;
//@(posedge HOLD_ACK);
//data_bus = 16;
//add = 3;
//control = 1;
//iready = 1;
//@(posedge TReady);
//iready = 0;
//#40
//@(posedge clk);
//HOLD = 0;
end
endmodule