package types;

typedef enum logic [3:0] { 
    AND_OP = 4'b0000,
    OR_OP  = 4'b0001,
    XOR_OP = 4'b0010,
    ADD_OP = 4'b0011,
    SUB_OP = 4'b0100,
    SLL_OP = 4'b0101,
    SRL_OP = 4'b0110,
    SRA_OP = 4'b0111,
    SLT_OP = 4'b1000,
    SLTU_OP = 4'b1001
} alusel_t;

typedef enum logic [1:0] { 
    BIGGER =  2'b00,
    SMALLER = 2'b01,
    EQUAL =   2'b10
} compout_t;

typedef enum logic [1:0] { 
    ALU =    2'b00,
    MEM =    2'b01,
    PCNEXT = 2'b10,
    IMM =    2'b11
} regWriteSrc_t;

typedef enum logic [2:0] { 
    FETCH =     3'b000,
    DECODE =    3'b001,
    EXECUTE =   3'b010,
    MEMORY =    3'b011,
    WRITEBACK = 3'b100
} fsmState_t;

endpackage: types