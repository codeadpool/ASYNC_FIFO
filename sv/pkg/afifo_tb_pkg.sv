package afifo_tb_pkg;
	parameter DATA_WIDTH = 32;
	parameter ADDR_WIDTH = 3;
	parameter MAX_FULL_RETRY = 10;
	parameter MAX_EMPTY_RETRY = 10;

    typedef enum {
      WR_OK,        
      WR_OVERFLOW,   
      WR_TIMEOUT     
    } wr_status_t;

    typedef enum {
      RD_OK,          
      RD_UNDERFLOW,   
      RD_TIMEOUT      
    } rd_status_t;

endpackage
