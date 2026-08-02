module control(Opcode, Present_State, OF, BF, Funct, Rd, Next_State, PC_EN, PC_SEL, IorD, MEM_DATA_SEL, MEM_OE, MEM_WS, REG_DATA_SEL, IR_EN, Reg_Dest, MEMtoREG, REG_OE, REG_WS, SIGNEXT_SEL, ALU_SEL1, ALU_SEL2, ALU_OP, EPC_EN, CAUSE_SEL, CAUSE_EN, PCWrite_BEQ, PCWrite_BNE, PCWrite_BGTZ, PCWrite_BLTZ, PCWrite_BLEZ, STATE);

localparam OP_J     = 6'b000010,    //jump
           OP_JAL   = 6'b000011,    //jump and link
           OP_R_TYPE = 6'b000000,   //most r-type instructions have the same OPCODE
           OP_MFC0  = 6'b010000,    //move from C0
           OP_BLTZ  = 6'b000001,    //Branch on greater than zero
           OP_BEQ   = 6'b000100,    //Branch on equal
           OP_BNE   = 6'b000101,    //Branch on not equal
           OP_BLEZ  = 6'b000110,    //Branch on less than or equal zero
           OP_BGTZ  = 6'b000111,    //Branch on greater than zero
           OP_ADDi  = 6'b001000,    //Immediate addition
           OP_ADDiu = 6'b001001,    //Immediate addition unsigned
           OP_SLTiu = 6'b001011,    //Immediate set-if-less-than unsigned
           OP_SLTi  = 6'b001010,    //Immediate set-if-less-than
           OP_ANDi  = 6'b001100,    //Immediate logic AND
           OP_ORi   = 6'b001101,    //Immediate logic OR
           OP_XORi  = 6'b001110,    //Immediate logic XOR
           OP_LW    = 6'b100011,    //Load word
           OP_LBu   = 6'b100100,    //Load unsigned byte
           OP_LB    = 6'b100000,    //Load byte
           OP_LHu   = 6'b100101,    //Load unsigned half word
           OP_LH    = 6'b100001,    //Load half word
           OP_SB    = 6'b101000,    //Store byte
           OP_SH    = 6'b101001,    //Store half word
           OP_SW    = 6'b101011;    //Store word

output PC_EN, IorD, MEM_OE, MEM_WS, IR_EN, REG_OE, REG_WS, SIGNEXT_SEL, ALU_SEL1, EPC_EN, CAUSE_SEL, CAUSE_EN, PCWrite_BEQ, PCWrite_BNE, PCWrite_BGTZ, PCWrite_BLTZ, PCWrite_BLEZ;
output [2:0] ALU_OP;
output [2:0] ALU_SEL2;
output [2:0] MEMtoREG;
output [1:0] Reg_Dest;
output [2:0] REG_DATA_SEL;
output [1:0] MEM_DATA_SEL;
output [2:0] PC_SEL;
output [2:0] Next_State;
output [5:0] STATE;

input [2:0] Present_State;
input OF, BF;
input [5:0] Opcode;
input [5:0] Funct;
input [4:0] Rd;

reg PC_EN, IorD, MEM_OE, MEM_WS, IR_EN, REG_OE, REG_WS, SIGNEXT_SEL, ALU_SEL1, EPC_EN, CAUSE_SEL, CAUSE_EN, PCWrite_BEQ, PCWrite_BNE, PCWrite_BGTZ, PCWrite_BLTZ, PCWrite_BLEZ;

reg [2:0] ALU_OP;
reg [2:0] ALU_SEL2;
reg [2:0] MEMtoREG;
reg [1:0] Reg_Dest;
reg [2:0] REG_DATA_SEL;
reg [1:0] MEM_DATA_SEL;
reg [2:0] PC_SEL;
reg [2:0] Next_State;
reg [5:0] STATE;

wire [5:0] Opcode;
wire [5:0] Funct;
wire [4:0] Rd;
wire OF, BF;

always@ (Present_State, Opcode) begin
    case (Present_State)
        0: begin                            //state 0

            IorD = 1'b0;                    //Select the PC as the address to RAM
            MEM_OE = 1'b1;                  //enable reading the next instruction from RAM
            REG_DATA_SEL = 3'b000;          //select the instruction from RAM to be written into the IR
            IR_EN = 1'b1;                   //enable write to IR
            REG_OE = 1'b1;                  //enables reading instruction operands from Register File
            ALU_SEL1 = 1'b0;               //select PC as the first ALU operand
            ALU_SEL2 = 3'b001;             //select constant 1 as the second ALU operand
            ALU_OP = 3'b000;               //select the ADD operation in order to increment PC by 1
            PC_SEL = 3'b000;               //select the incremented PC to be the next PC value
            PC_EN = 1'b1;                  //write the incremented PC value into the PC register
            Next_State = 3'b001;           //next state is DECODE
            STATE = 6'b000000;             //output state number for debug only

            //initialize all other outputs to zero.
            MEM_WS = 1'b0;
            REG_WS = 1'b0;
            EPC_EN = 1'b0;
            CAUSE_EN = 1'b0;
            PCWrite_BEQ = 1'b0;
            PCWrite_BNE = 1'b0;
            PCWrite_BGTZ = 1'b0;
            PCWrite_BLTZ = 1'b0;
            PCWrite_BLEZ = 1'b0;
            SIGNEXT_SEL = 1'b0;
            CAUSE_SEL = 1'b0;
            MEMtoREG = 3'b000;
            Reg_Dest = 2'b00;
            MEM_DATA_SEL = 2'b00;
        end

        1: begin                            //state 1

            SIGNEXT_SEL = 1'b0;            //sign extend lower 16-bits of the instruction
            ALU_SEL1 = 1'b0;               //select PC as the first ALU operand
            ALU_SEL2 = 3'b011;             //select sign extend lower 16-bits (shifted left by 2)
            ALU_OP = 3'b000;               //select the ADD operation
            Next_State = 3'b010;           //next state is EXECUTE
            IR_EN = 1'b0;                  //disable write to IR
            MEM_OE = 1'b0;                 //disable reading from RAM
            PC_EN = 1'b0;                  //disable writes to PC register
            STATE = 6'b000001;             //output state number for debug only
        end

        2: begin
            if (Opcode == OP_MFC0) begin
                if (Rd == 5'b01101) begin       //state 33
                    Reg_Dest = 2'b01;           //select Rd to be the Register File address
                    MEMtoREG = 3'b011;          //select the content of the Cause register to be written to the Register File
                    Next_State = 3'b011;        //next state is MEMORY ACCESS
                    STATE = 6'b100001;          //output state number for debug only
                end
                else if (Rd == 5'b01110) begin  //state 32
                    Reg_Dest = 2'b01;           //select Rd to be the Register File address
                    MEMtoREG = 3'b010;          //select the content of the EPC register to be written to the Register File
                    Next_State = 3'b011;        //next state is MEMORY ACCESS
                    STATE = 6'b100000;          //output state number for debug only
                end
                else begin                      //go to invalid instruction state 31
                    CAUSE_SEL = 1'b1;           //select '1' to be written to the Cause register indicating an invalid operation
                    CAUSE_EN = 1'b1;            //enable writing to the Cause register
                    EPC_EN = 1'b1;              //enable writting the current PC to the EPC register
                    PC_SEL = 3'b100;            //select the incremented PC to be the next PC value
                    Next_State = 3'b000;        //next state is FETCH
                    STATE = 6'b011111;          //output state number for debug only
                end
            end
            else if (Opcode == OP_BLTZ) begin   //state 13
                ALU_SEL1 = 1'b1;               //select Reg1 as the first ALU operand
                ALU_SEL2 = 3'b100;             //select constant 0 as the second ALU operand as it is not needed for this operation
                ALU_OP = 3'b001;               //select the Subtract operation
                PC_SEL = 3'b001;               //select PC + 4 + ((sign extended I[15:0]) || 00) as the next PC
                PCWrite_BLTZ = 1'b1;           //enable PC load if condition met
                Next_State = 3'b000;           //next state is FETCH
                STATE = 6'b001101;             //output state number for debug only
            end
            else if (Opcode == OP_BGTZ) begin   //state 12
                ALU_SEL1 = 1'b1;               //select Reg1 as the first ALU operand
                ALU_SEL2 = 3'b100;             //select constant 0 as the second ALU operand as it is not needed for this operation
                ALU_OP = 3'b001;               //select the Subtract operation
                PC_SEL = 3'b001;               //select PC + 4 + ((sign extended I[15:0]) || 00) as the next PC
                PCWrite_BGTZ = 1'b1;           //enable PC load if condition met
                Next_State = 3'b000;           //next state is FETCH
                STATE = 6'b001100;             //output state number for debug only
            end
            else if (Opcode == OP_BLEZ) begin   //state 11
                ALU_SEL1 = 1'b1;               //select Reg1 as the first ALU operand
                ALU_SEL2 = 3'b100;             //select constant 0 as the second ALU operand as it is not needed for this operation
                ALU_OP = 3'b001;               //select the Subtract operation
                PC_SEL = 3'b001;               //select PC + 4 + ((sign extended I[15:0]) || 00) as the next PC
                PCWrite_BLEZ = 1'b1;           //enable PC load if condition met
                Next_State = 3'b000;           //next state is FETCH
                STATE = 6'b001011;             //output state number for debug only
            end
            else if (Opcode == OP_BNE) begin    //state 10
                ALU_SEL1 = 1'b1;               //select Reg1 as the first ALU operand
                ALU_SEL2 = 3'b000;             //select Reg2 as the second ALU operand
                ALU_OP = 3'b001;               //select the Subtract operation
                PC_SEL = 3'b001;               //select PC + 4 + ((sign extended I[15:0]) || 00) as the next PC
                PCWrite_BNE = 1'b1;            //enable PC load if condition met
                Next_State = 3'b000;           //next state is FETCH
                STATE = 6'b001010;             //output state number for debug only
            end
            else if (Opcode == OP_BEQ) begin    //state 9
                ALU_SEL1 = 1'b1;               //select Reg1 as the first ALU operand
                ALU_SEL2 = 3'b000;             //select Reg2 as the second ALU operand
                ALU_OP = 3'b001;               //select the Subtract operation
                PC_SEL = 3'b001;               //select (PC + 4 + ((sign extended I[15:0]) || 00)) as the next PC
                PCWrite_BEQ = 1'b1;            //enable PC load if condition met
                Next_State = 3'b000;           //next state is FETCH
                STATE = 6'b001001;             //output state number for debug only
            end
            else if (Opcode == OP_J) begin      //state 2
                PC_SEL = 3'b010;               //select (PC[31:28] || Inst[25:0] || 00) as the next PC
                PC_EN = 1'b1;                  //enable write to the PC register
                Next_State = 3'b000;           //next state is FETCH
                STATE = 6'b000010;             //output state number for debug only
            end
            else if (Opcode == OP_JAL) begin    //state 3
                Reg_Dest = 2'b10;              //select 31 ($ra) as the Register File address
                MEMtoREG = 3'b101;             //select (PC + 4) to be written to the Register File
                Next_State = 3'b011;           //next state is MEMORY ACCESS
                STATE = 6'b000011;             //output state number for debug only
            end
            else if (Opcode == OP_ORi) begin    //state 15
                ALU_SEL1 = 1'b1;               //select Reg1 as the first ALU operand
                ALU_SEL2 = 3'b010;             //select immediate value (sign extended I[15:0]) as the second ALU operand
                ALU_OP = 3'b101;               //select the OR operation
                SIGNEXT_SEL = 1'b0;            //sign extend lower 16-bits of the instruction
                Reg_Dest = 2'b00;              //select Rt to be the Register File address
                MEMtoREG = 3'b000;             //select the content of the ALU register to be written to the Register File
                Next_State = 3'b011;           //next state is MEMORY ACCESS
                STATE = 6'b001111;             //output state number for debug only
            end
            else if (Opcode == OP_XORi) begin   //state 16
                ALU_SEL1 = 1'b1;               //select Reg1 as the first ALU operand
                ALU_SEL2 = 3'b010;             //select immediate value (sign extended I[15:0]) as the second ALU operand
                ALU_OP = 3'b110;               //select the XOR operation
                SIGNEXT_SEL = 1'b0;            //sign extend lower 16-bits of the instruction
                Reg_Dest = 2'b00;              //select Rt to be the Register File address
                MEMtoREG = 3'b000;             //select the content of the ALU register to be written to the Register File
                Next_State = 3'b011;           //next state is MEMORY ACCESS
                STATE = 6'b010000;             //output state number for debug only
            end
            else if (Opcode == OP_ANDi) begin   //state 14
                ALU_SEL1 = 1'b1;               //select Reg1 as the first ALU operand
                ALU_SEL2 = 3'b010;             //select immediate value (sign extended I[15:0]) as the second ALU operand
                ALU_OP = 3'b100;               //select the AND operation
                SIGNEXT_SEL = 1'b0;            //sign extend lower 16-bits of the instruction
                Reg_Dest = 2'b00;              //select Rt to be the Register File address
                MEMtoREG = 3'b000;             //select the content of the ALU register to be written to the Register File
                Next_State = 3'b011;           //next state is MEMORY ACCESS
                STATE = 6'b001110;             //output state number for debug only
            end
            else if (Opcode == OP_SLTi) begin   //state 6
                ALU_SEL1 = 1'b1;               //select Reg1 as the first ALU operand
                ALU_SEL2 = 3'b010;             //select immediate value (sign extended I[15:0]) as the second ALU operand
                ALU_OP = 3'b011;               //select the SLT operation
                SIGNEXT_SEL = 1'b0;            //sign extend lower 16-bits of the instruction
                Reg_Dest = 2'b00;              //select Rt to be the Register File address
                MEMtoREG = 3'b000;             //select the content of the ALU register to be written to the Register File
                Next_State = 3'b011;           //next state is MEMORY ACCESS
                STATE = 6'b000110;             //output state number for debug only
            end
            else if (Opcode == OP_SLTiu) begin  //state 28
                ALU_SEL1 = 1'b1;               //select Reg1 as the first ALU operand
                ALU_SEL2 = 3'b010;             //select immediate value (sign extended I[15:0]) as the second ALU operand
                ALU_OP = 3'b011;               //select the SLT operation
                SIGNEXT_SEL = 1'b1;            //sign extend lower 16-bits of the instruction with zero's
                Reg_Dest = 2'b00;              //select Rt to be the Register File address
                MEMtoREG = 3'b000;             //select the content of the ALU register to be written to the Register File
                Next_State = 3'b011;           //next state is MEMORY ACCESS
                STATE = 6'b011100;             //output state number for debug only
            end
            else if (Opcode == OP_ADDiu) begin  //state 29
                ALU_SEL1 = 1'b1;               //select Reg1 as the first ALU operand
                ALU_SEL2 = 3'b010;             //select immediate value (sign extended I[15:0]) as the second ALU operand
                ALU_OP = 3'b000;               //select the ADD operation
                SIGNEXT_SEL = 1'b1;            //sign extend lower 16-bits of the instruction with zero's
                Reg_Dest = 2'b00;              //select Rt to be the Register File address
                MEMtoREG = 3'b000;             //select the content of the ALU register to be written to the Register File
                Next_State = 3'b011;           //next state is MEMORY ACCESS
                STATE = 6'b011101;             //output state number for debug only
            end
            else if (Opcode == OP_R_TYPE) begin
                if (Funct == 6'b001001) begin       //state 21, JALR function
                    Reg_Dest = 2'b01;               //select Rd as the Register File address
                    MEMtoREG = 3'b101;              //select (PC + 4) to be written to the Register File
                    Next_State = 3'b011;            //next state is MEMORY ACCESS
                    STATE = 6'b010101;              //output state number for debug only
                end
                else if (Funct == 6'b001000) begin  //state 20, JR function
                    PC_SEL = 3'b011;                //select content of Reg1 (Rs) as the next PC
                    PC_EN = 1'b1;                   //enable write to the PC register
                    Next_State = 3'b000;            //next state is FETCH
                    STATE = 6'b010100;              //output state number for debug only
                end
                else if ((Funct == 6'b100000) || (Funct == 6'b100001) || (Funct == 6'b100010) || (Funct == 6'b100011) || (Funct == 6'b100100) || (Funct == 6'b100101) || (Funct == 6'b100110) || (Funct == 6'b100111) || (Funct == 6'b000000) || (Funct == 6'b000100) || (Funct == 6'b000010) || (Funct == 6'b000110) || (Funct == 6'b000001) || (Funct == 6'b000111) || (Funct == 6'b101001) || (Funct == 6'b101010)) begin  //state 4
                    Reg_Dest = 2'b01;               //select Rd to be the Register File address
                    MEMtoREG = 3'b000;              //select the content of the ALU register to be written to the Register File
                    ALU_SEL1 = 1'b1;               //select Reg1 as the first ALU operand
                    ALU_SEL2 = 3'b000;             //select Reg2 as the second ALU operand
                    ALU_OP = 3'b010;               //select R-type operation
                    Next_State = 3'b011;            //next state is MEMORY ACCESS
                    STATE = 6'b000100;              //output state number for debug only
                end
                else begin                          //go to invalid instruction state 31
                    CAUSE_SEL = 1'b1;              //select '1' to be written to the Cause register indicating an invalid operation
                    CAUSE_EN = 1'b1;               //enable writing to the Cause register
                    EPC_EN = 1'b1;                 //enable writting the current PC to the EPC register
                    PC_SEL = 3'b100;               //select the incremented PC to be the next PC value
                    Next_State = 3'b000;            //next state is FETCH
                    STATE = 6'b100110;              //output state number for debug only. code 38
                end
            end
            else if ((Opcode == OP_ADDi) || (Opcode == OP_LW) || (Opcode == OP_LBu) || (Opcode == OP_LB) || (Opcode == OP_LHu) || (Opcode == OP_LH) || (Opcode == OP_SB) || (Opcode == OP_SH) || (Opcode == OP_SW)) begin
                                                //state 7 (various I-Type)
                ALU_SEL1 = 1'b1;               //select Reg1 as the first ALU operand
                ALU_SEL2 = 3'b010;             //select immediate value (sign extended I[15:0]) as the second ALU operand
                ALU_OP = 3'b000;               //select the ADD operation
                SIGNEXT_SEL = 1'b0;            //sign extend lower 16-bits of the instruction
                Reg_Dest = 2'b00;              //select Rt to be the Register File address
                MEMtoREG = 3'b000;             //select the content of the ALU register to be written to the Register File
                Next_State = 3'b011;           //next state is MEMORY ACCESS
                STATE = 6'b000111;             //output state number for debug only
            end
            else begin                          //go to invalid instruction state 31
                CAUSE_SEL = 1'b1;              //select '1' to be written to the Cause register indicating an invalid operation
                CAUSE_EN = 1'b1;               //enable writing to the Cause register
                EPC_EN = 1'b1;                 //enable writting the current PC to the EPC register
                PC_SEL = 3'b100;               //select the incremented PC to be the next PC value
                Next_State = 3'b000;           //next state is FETCH
                STATE = 6'b100011;             //output state number for debug only. code 35
            end
        end
        3: begin
            if ((Opcode == OP_ORi) || (Opcode == OP_XORi) || (Opcode == OP_ANDi) || (Opcode == OP_SLTi) || (Opcode == OP_ADDiu) || (Opcode == OP_SLTiu) || ((Opcode == OP_MFC0) && (Rd == 5'b01110)) || ((Opcode == OP_MFC0) && (Rd == 5'b01101))) begin //state 8
                REG_WS = 1'b1;                  //enable writing to the Register File
                Next_State = 3'b000;            //next state is FETCH
                STATE = 6'b001000;              //output state number for debug only
            end
            else if ((Opcode == OP_R_TYPE) && (Funct == 6'b001001)) begin  //State 35
                PC_SEL = 3'b011;                //select content of Reg1 (Rs) as the next PC
                PC_EN = 1'b1;                   //enable write to the PC register
                REG_WS = 1'b1;                  //enable writing to the Register File
                Next_State = 3'b000;            //next state is FETCH
                STATE = 6'b101101;              //output state number for debug only. code 45
            end
            else if (Opcode == OP_JAL) begin    //State 36
                PC_SEL = 3'b010;                //select (PC[31:28] || Inst[25:0] || 00) as the next PC
                PC_EN = 1'b1;                   //enable write to the PC register
                REG_WS = 1'b1;                  //enable writing to the Register File
                Next_State = 3'b000;            //next state is FETCH
                STATE = 6'b101110;              //output state number for debug only. code 46
            end
            else if (Opcode == OP_R_TYPE) begin
                if (BF == 1'b1) begin               //state 31
                    CAUSE_SEL = 1'b1;              //select '1' to be written to the Cause register indicating an invalid operation
                    CAUSE_EN = 1'b1;               //enable writing to the Cause register
                    EPC_EN = 1'b1;                 //enable writting the current PC to the EPC register
                    PC_SEL = 3'b100;               //select the incremented PC to be the next PC value
                    Next_State = 3'b000;            //next state is FETCH
                    STATE = 6'b100100;              //output state number for debug only. code 36
                end
                else if ((BF == 1'b0) && (OF == 1'b1) && (Funct[0] == 1'b1)) begin    //state 30
                    CAUSE_SEL = 1'b0;              //select '1' to be written to the Cause register indicating an arithmetic overflow
                    CAUSE_EN = 1'b1;               //enable writing to the Cause register
                    EPC_EN = 1'b1;                 //enable writting the current PC to the EPC register
                    PC_SEL = 3'b100;               //select the incremented PC to be the next PC value
                    Next_State = 3'b000;            //next state is FETCH
                    STATE = 6'b011110;              //output state number for debug only
                end
                else begin                          //state 5
                    REG_WS = 1'b1;                  //enable writing to the Register File
                    Next_State = 3'b000;            //next state is FETCH
                    STATE = 6'b000101;              //output state number for debug only
                end
            end
            else if ((Opcode == OP_ADDi) || (Opcode == OP_LW) || (Opcode == OP_LBu) || (Opcode == OP_LB) || (Opcode == OP_LHu) || (Opcode == OP_LH) || (Opcode == OP_SB) || (Opcode == OP_SH) || (Opcode == OP_SW)) begin   //various I-Type
                if ((Opcode == OP_ADDi) && (OF == 1'b0)) begin //state 8
                    REG_WS = 1'b1;                  //enable writing to the Register File
                    Next_State = 3'b000;            //next state is FETCH
                    STATE = 6'b001000;              //output state number for debug only
                end
                else if ((Opcode == OP_ADDi) && (OF == 1'b1)) begin //state 30
                    CAUSE_SEL = 1'b0;              //select '1' to be written to the Cause register indicating an arithmetic overflow
                    CAUSE_EN = 1'b1;               //enable writing to the Cause register
                    EPC_EN = 1'b1;                 //enable writting the current PC to the EPC register
                    PC_SEL = 3'b100;               //select the incremented PC to be the next PC value
                    Next_State = 3'b000;            //next state is FETCH
                    STATE = 6'b011110;              //output state number for debug only
                end
                else if (Opcode == OP_LH) begin     //state 25
                    IorD = 1'b1;                    //Select the content of the ALU register as the address to RAM
                    MEM_OE = 1'b1;                  //enable reading from RAM
                    REG_DATA_SEL = 3'b100;          //select the sign extended half word to be written into the IR
                    Reg_Dest = 2'b00;              //select Rt to be the Register File address
                    MEMtoREG = 3'b100;             //select the content of the IR register to be written to the Register File
                    Next_State = 3'b100;            //next state is WRITEBACK
                    STATE = 6'b011001;              //output state number for debug only
                end
                else if (Opcode == OP_SW) begin     //state 17
                    IorD = 1'b1;                    //Select the content of the ALU register as the address to RAM
                    MEM_DATA_SEL = 2'b00;          //select the content of Reg2 to be written to memory
                    Next_State = 3'b100;            //next state is WRITEBACK
                    STATE = 6'b010001;              //output state number for debug only
                end
                else if (Opcode == OP_LBu) begin    //state 22
                    IorD = 1'b1;                    //Select the content of the ALU register as the address to RAM
                    MEM_OE = 1'b1;                  //enable reading from RAM
                    REG_DATA_SEL = 3'b001;          //select the zero sign extended byte to be written into the IR
                    Reg_Dest = 2'b00;              //select Rt to be the Register File address
                    MEMtoREG = 3'b100;             //select the content of the IR register to be written to the Register File
                    Next_State = 3'b100;            //next state is WRITEBACK
                    STATE = 6'b010110;              //output state number for debug only
                end
                else if (Opcode == OP_LW) begin     //state 18
                    IorD = 1'b1;                    //Select the content of the ALU register as the address to RAM
                    MEM_OE = 1'b1;                  //enable reading from RAM
                    REG_DATA_SEL = 3'b000;          //select RAM data to be written into the IR
                    Reg_Dest = 2'b00;              //select Rt to be the Register File address
                    MEMtoREG = 3'b100;             //select the content of the IR register to be written to the Register File
                    Next_State = 3'b100;            //next state is WRITEBACK
                    STATE = 6'b010010;              //output state number for debug only
                end
                else if (Opcode == OP_LB) begin     //state 23
                    IorD = 1'b1;                    //Select the content of the ALU register as the address to RAM
                    MEM_OE = 1'b1;                  //enable reading from RAM
                    REG_DATA_SEL = 3'b010;          //select sign extended byte to be written into the IR
                    Reg_Dest = 2'b00;              //select Rt to be the Register File address
                    MEMtoREG = 3'b100;             //select the content of the IR register to be written to the Register File
                    Next_State = 3'b100;            //next state is WRITEBACK
                    STATE = 6'b010111;              //output state number for debug only
                end
                else if (Opcode == OP_LHu) begin    //state 24
                    IorD = 1'b1;                    //Select the content of the ALU register as the address to RAM
                    MEM_OE = 1'b1;                  //enable reading from RAM
                    REG_DATA_SEL = 3'b011;          //select the zero sign extended half word to be written into the IR
                    Reg_Dest = 2'b00;              //select Rt to be the Register File address
                    MEMtoREG = 3'b100;             //select the content of the IR register to be written to the Register File
                    Next_State = 3'b100;            //next state is WRITEBACK
                    STATE = 6'b011000;              //output state number for debug only
                end
                else if (Opcode == OP_SB) begin     //state 26
                    IorD = 1'b1;                    //Select the content of the ALU register as the address to RAM
                    MEM_DATA_SEL = 2'b01;          //select the sign extended byte to be written to memory
                    Next_State = 3'b100;            //next state is WRITEBACK
                    STATE = 6'b011010;              //output state number for debug only
                end
                else if (Opcode == OP_SH) begin     //state 27
                    IorD = 1'b1;                    //Select the content of the ALU register as the address to RAM
                    MEM_DATA_SEL = 2'b10;          //select the sign extended half word to be written to memory
                    Next_State = 3'b100;            //next state is WRITEBACK
                    STATE = 6'b011011;              //output state number for debug only
                end
                else begin                          //go to invalid instruction state 31
                    CAUSE_SEL = 1'b1;              //select '1' to be written to the Cause register indicating an invalid operation
                    CAUSE_EN = 1'b1;               //enable writing to the Cause register
                    EPC_EN = 1'b1;                 //enable writting the current PC to the EPC register
                    PC_SEL = 3'b100;               //select the incremented PC to be the next PC value
                    Next_State = 3'b000;            //next state is FETCH
                    STATE = 6'b011111;              //output state number for debug only
                end
            end
            else begin                              //go to invalid instruction state 31
                CAUSE_SEL = 1'b1;                  //select '1' to be written to the Cause register indicating an invalid operation
                CAUSE_EN = 1'b1;                   //enable writing to the Cause register
                EPC_EN = 1'b1;                     //enable writting the current PC to the EPC register
                PC_SEL = 3'b100;                   //select the incremented PC to be the next PC value
                Next_State = 3'b000;                //next state is FETCH
                STATE = 6'b100101;                  //output state number for debug only. code 37
            end
        end
        4: begin
            if ((Opcode == OP_SW) || (Opcode == OP_SH) || (Opcode == OP_SB)) begin //state 34
                MEM_WS = 1'b1;                  //enable write to memory
                Next_State = 3'b000;            //next state is FETCH
                STATE = 6'b100010;              //output state number for debug only. code 34
            end
            else begin                          //state 19
                REG_WS = 1'b1;                  //enable writing to the Register File
                Next_State = 3'b000;            //next state is FETCH
                STATE = 6'b010011;              //output state number for debug only
            end
        end

        default: begin                          //go to invalid instruction state 31
            CAUSE_SEL = 1'b1;                  //select '1' to be written to the Cause register indicating an invalid operation
            CAUSE_EN = 1'b1;                   //enable writing to the Cause register
            EPC_EN = 1'b1;                     //enable writting the current PC to the EPC register
            PC_SEL = 3'b100;                   //select the incremented PC to be the next PC value
            Next_State = 3'b000;               //next state is FETCH
            STATE = 6'b100110;                 //output state number for debug only. code 38
        end
    endcase
end

endmodule