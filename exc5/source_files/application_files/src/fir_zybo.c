#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xil_types.h"
#include "xparameters.h"
#include "sleep.h"

// Offsets for control bits
#define VALID_IN 8
#define RESET 9
#define VALID_OUT 19

// Write to the first register
#define INPUT_REG XPAR_FIR_IP_0_S00_AXI_BASEADDR

// Read from the second register
#define OUTPUT_REG XPAR_FIR_IP_0_S00_AXI_BASEADDR + 4

//uint8_t values[] = {213,107,172,58,147,225,92,39,205,26,180,99,248,15,134,73};
uint8_t values[] = {208,231,32,233,161,24,71,140,245,247,40,248,245,124,204,36,107,234,202,245};

void reset(){
	uint32_t input_data = 0;
	// Set Reset Bit
	input_data = 1 << RESET ;
	Xil_Out32(INPUT_REG,input_data);
	// Wait 1usec
	usleep(1);
	// Unset Reset Bit
	input_data &= ~(1 << RESET);
	Xil_Out32(INPUT_REG,input_data);
	xil_printf("Reset Done\n\r");
}

void write_data(uint8_t num){
	uint32_t input_data = 0;
	input_data = (uint32_t) num;

	// Enable Valid bit
	input_data |= (1 << VALID_IN );
	// Disable Reset bit
	input_data &= ~(1 << RESET);

	Xil_Out32(INPUT_REG,input_data);
	// Mask
	input_data &= 0xFF;

	//xil_printf("Wrote: %d\n\r",input_data);
}


void read_data(){
	uint32_t output = 0;
	uint32_t valid_out = 0;

	while(!valid_out){
		output = Xil_In32(OUTPUT_REG);
		valid_out = (output >> VALID_OUT) & 0x01;
	}

	// Mask output
	output &= 0x7FFFF;
	xil_printf("Read : %d\n\r",output);
}

int main(){
	/* Initialize platform */
	init_platform();
	sleep(1);
	reset();

	xil_printf("Fir Test\n\r");

	for(int i=0; i < sizeof(values); ++i){
		write_data(values[i]);
		usleep(1);
		read_data();
	}

	xil_printf("End of test\n\r");

	return 0;
}
