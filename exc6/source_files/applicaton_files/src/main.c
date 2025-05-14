#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xparameters_ps.h"
#include "xaxidma.h"
#include "xtime_l.h"
#include "data_array_1024.h"

#define TX_DMA_ID                 XPAR_PS2PL_DMA_DEVICE_ID
#define TX_DMA_MM2S_LENGTH_ADDR  (XPAR_PS2PL_DMA_BASEADDR + 0x28) // Reports actual number of bytes transferred from PS->PL (use Xil_In32 for report)

#define RX_DMA_ID                 XPAR_PL2PS_DMA_DEVICE_ID
#define RX_DMA_S2MM_LENGTH_ADDR  (XPAR_PL2PS_DMA_BASEADDR + 0x58) // Reports actual number of bytes transferred from PL->PS (use Xil_In32 for report)

#define TX_BUFFER (XPAR_DDR_MEM_BASEADDR + 0x08000000) // 0 + 128MByte
#define RX_BUFFER (XPAR_DDR_MEM_BASEADDR + 0x10000000) // 0 + 256MByte

/* User application global variables & defines */
#define N 1024
#define DATA_LENGTH N*N

XAxiDma TxAxiDma;
XAxiDma RxAxiDma;

uint8_t fpga_out[DATA_LENGTH][3];        // 2: Red | 1: Green | 0: Blue
uint8_t sw_out[3*DATA_LENGTH];

// Get pixel with edge handling
uint8_t get_pixel(const uint8_t *img, int x, int y, int width, int height) {
    if (x < 0 || x >= width) return 0;
    if (y < 0 || y >= width) return 0;
    return img[y * width + x];
}

// Debayer for GBRG pattern
void debayer_gbrg(uint8_t *bayer, uint8_t *rgb, int width, int height) {
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            uint16_t R = 0, G = 0, B = 0;

            if ((y % 2 == 0) && (x % 2 == 0)) {
                // Green (on Red row)
                G = get_pixel(bayer, x, y, width, height);
                B = (get_pixel(bayer, x - 1, y, width, height) + get_pixel(bayer, x + 1, y, width, height)) / 2;
                R = (get_pixel(bayer, x, y - 1, width, height) + get_pixel(bayer, x, y + 1, width, height)) / 2;
            } else if ((y % 2 == 0) && (x % 2 == 1)) {
                // Blue
                B = get_pixel(bayer, x, y, width, height);
                G = (get_pixel(bayer, x - 1, y, width, height) + get_pixel(bayer, x + 1, y, width, height) +
                     get_pixel(bayer, x, y - 1, width, height) + get_pixel(bayer, x, y + 1, width, height)) / 4;
                R = (get_pixel(bayer, x - 1, y - 1, width, height) + get_pixel(bayer, x + 1, y - 1, width, height) +
                     get_pixel(bayer, x - 1, y + 1, width, height) + get_pixel(bayer, x + 1, y + 1, width, height)) / 4;
            } else if ((y % 2 == 1) && (x % 2 == 0)) {
                // Red
                R = get_pixel(bayer, x, y, width, height);
                G = (get_pixel(bayer, x - 1, y, width, height) + get_pixel(bayer, x + 1, y, width, height) +
                     get_pixel(bayer, x, y - 1, width, height) + get_pixel(bayer, x, y + 1, width, height)) / 4;
                B = (get_pixel(bayer, x - 1, y - 1, width, height) + get_pixel(bayer, x + 1, y - 1, width, height) +
                     get_pixel(bayer, x - 1, y + 1, width, height) + get_pixel(bayer, x + 1, y + 1, width, height)) / 4;
            } else {
                // Green (on Blue row)
                G = get_pixel(bayer, x, y, width, height);
                B = (get_pixel(bayer, x, y - 1, width, height) + get_pixel(bayer, x, y + 1, width, height)) / 2;
                R = (get_pixel(bayer, x - 1, y, width, height) + get_pixel(bayer, x + 1, y, width, height)) / 2;
            }

            int idx = (y * width + x) * 3;
            rgb[idx + 2] = R;
            rgb[idx + 1] = G;
            rgb[idx + 0] = B;
        }
    }
}


int main()
{
	Xil_DCacheDisable();

	XTime preExecCyclesFPGA = 0;
	XTime postExecCyclesFPGA = 0;
	XTime preExecCyclesSW = 0;
	XTime postExecCyclesSW = 0;

	print("HELLO 1\r\n");

	// User application local variables
    uint32_t pixel;
    int error = 0;
    int speedup;
    int SW_execution_time, FPGA_execution_time;

	init_platform();
    Xil_DCacheDisable();  // DMA doesn't go through cache unless using coherent memory


    // Step 1: Initialize TX-DMA Device (PS->PL)
    XAxiDma_Config *txCfg = XAxiDma_LookupConfig(TX_DMA_ID);
    if (!txCfg || XAxiDma_CfgInitialize(&TxAxiDma, txCfg) != XST_SUCCESS) {
        xil_printf("TX DMA init failed.\r\n");
        return XST_FAILURE;
    }

    // Step 2: Initialize RX-DMA Device (PL->PS)
    XAxiDma_Config *rxCfg = XAxiDma_LookupConfig(RX_DMA_ID);
    if (!rxCfg || XAxiDma_CfgInitialize(&RxAxiDma, rxCfg) != XST_SUCCESS) {
        xil_printf("RX DMA init failed.\r\n");
        return XST_FAILURE;
    }

    // Disable interrupts (polling mode)
    XAxiDma_IntrDisable(&TxAxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);
    XAxiDma_IntrDisable(&RxAxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);

    // Set up buffers
    u8 *txBuffer = (u8 *)TX_BUFFER;
    u32 *rxBuffer = (u32 *)RX_BUFFER;

    // Read Input Data
    for (int i = 0; i < DATA_LENGTH; i++) {
        txBuffer[i] = data_array[i];
    }

    // Flush caches to ensure memory coherence
    Xil_DCacheFlushRange((UINTPTR)txBuffer, DATA_LENGTH);
    Xil_DCacheFlushRange((UINTPTR)rxBuffer, DATA_LENGTH);

    XTime_GetTime(&preExecCyclesFPGA);
    // Step 3 : Perform FPGA processing
    //      3a: Setup RX-DMA transaction
    if (XAxiDma_SimpleTransfer(&RxAxiDma, (UINTPTR)rxBuffer, DATA_LENGTH * 4, XAXIDMA_DEVICE_TO_DMA) != XST_SUCCESS) {
        xil_printf("RX DMA transfer failed.\r\n");
        return XST_FAILURE;
    }


    //      3b: Setup TX-DMA transaction
    if (XAxiDma_SimpleTransfer(&TxAxiDma, (UINTPTR)txBuffer, DATA_LENGTH, XAXIDMA_DMA_TO_DEVICE) != XST_SUCCESS) {
        xil_printf("TX DMA transfer failed.\r\n");
        return XST_FAILURE;
    }

    //      3c: Wait for TX-DMA & RX-DMA to finish
    while (XAxiDma_Busy(&TxAxiDma, XAXIDMA_DMA_TO_DEVICE));
    while (XAxiDma_Busy(&RxAxiDma, XAXIDMA_DEVICE_TO_DMA));

    XTime_GetTime(&postExecCyclesFPGA);

    xil_printf("DMA transfer finished.\r\n");

    // Step 4: Save data
    // Invalidate cache before reading
    Xil_DCacheInvalidateRange((UINTPTR)rxBuffer, DATA_LENGTH);



    for (int i = 0; i < DATA_LENGTH; i++) {
        pixel = rxBuffer[i];

        // Parse Output
        fpga_out[i][0] = (pixel & 0x000000FF);
        fpga_out[i][1] = (pixel & 0x0000FF00) >> 8;
        fpga_out[i][2] = (pixel & 0x00FF0000) >> 16;

        // xil_printf("Pixel %2d: (%3d,%3d,%3d)\n", i, fpga_out[i][2], fpga_out[i][1], fpga_out[i][0]);
    }

    xil_printf("FPGA data saved.\r\n");

    XTime_GetTime(&preExecCyclesSW);
    // Step 5: Perform SW processing
    debayer_gbrg(data_array,sw_out,N,N);

    XTime_GetTime(&postExecCyclesSW);

    xil_printf("SW calculation finished.\r\n");

//    for (int i = 0;i< 10; ++i){
//    	 xil_printf("Pixel_FPGA %2d: (%u,%u,%u)\r\n", i, fpga_out[i][2], fpga_out[i][1], fpga_out[i][0]);
//    	 xil_printf("Pixel_SW %2d: (%u,%u,%u)\r\n", i, sw_out[3*i+2], sw_out[3*i+1], sw_out[3*i]);
//    }


    // Step 6: Compare FPGA and SW results

    //     6a: Report total percentage error
    for(int i = 0; i < DATA_LENGTH; ++i){
        for(int j=0; j < 3; ++j)
            if(fpga_out[i][j] != sw_out[3*i+j])
                error++;
    }

    xil_printf("Total errors: %d.\r\n",error);

    //     6b: Report FPGA execution time in cycles (use preExecCyclesFPGA and postExecCyclesFPGA)
    FPGA_execution_time = postExecCyclesFPGA - preExecCyclesFPGA;
    xil_printf("FPGA time: %llu cycles.\r\n", FPGA_execution_time);


    //     6c: Report SW execution time in cycles (use preExecCyclesSW and postExecCyclesSW)
    SW_execution_time = postExecCyclesSW - preExecCyclesSW;
    xil_printf("SW time: %llu cycles.\r\n", SW_execution_time);

    //     6d: Report speedup (SW_execution_time / FPGA_exection_time)
    speedup = (unsigned int)SW_execution_time / (unsigned int)FPGA_execution_time;
    xil_printf("Speedup:  %u.\r\n", speedup);

    cleanup_platform();
    return 0;
}
