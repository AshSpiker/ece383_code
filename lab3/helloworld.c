/******************************************************************************
* Copyright (C) 2023 Advanced Micro Devices, Inc. All Rights Reserved.
* SPDX-License-Identifier: MIT
******************************************************************************/
/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

/***************************** Include Files ********************************/

#include "xparameters.h"
#include "stdio.h"
#include "xstatus.h"

#include "platform.h"
#include "xil_printf.h"						// Contains xil_printf
#include <xuartlite_l.h>					// Contains XUartLite_RecvByte
#include <xil_io.h>							// Contains Xil_Out8 and its variations

/************************** Constant Definitions ****************************/
#define printf xil_printf			/* A smaller footprint printf */
#define	uartRegAddr			0x40600000		// read <= RX, write => TX

/*
 * The following constants define the slave registers used for our Counter PCORE
 */
#define countBase		0x44a00000
//#define countQReg		countBase			// 8 LSBs of slv_reg0 read=Q, write=D
//#define	countCtrlReg	countBase+4			// 2 LSBs of slv_reg1 are control
#define	exWrAddr	countBase+8			// 10 LSB of slvReg 2
#define	exWen		countBase+8		// ONLY using 10th bit of slv reg 2
#define lBusOut		countBase+0xc	// using bottom 16 bits of slv reg 3
#define rBusOut 	countBase+0xe   // using the top 16 bits of slv reg 3
#define exLBus		countBase+0x10	// using bottom 16 bits of slv reg 4
#define exRBus		countBase+0x12	// using the top 16 bits of slv reg 4
#define flagQReady	countBase+0x14	//using the LSB of slv reg 5
#define flagClear 	countBase+0x18	// using the LSB of slv reg 6
#define trigV		countBase+0x1c	// using the bottom 11 bits slv reg 7
#define trigT		countBase+0x20	// using the bottom 11 bits of slv reg 8

int ARRAYFULL = 0;
int INDEX	  = 0;
uint16_t array_L[1024];
uint16_t array_R[1024];

/************************** Function Prototypes ****************************/
void myISR(void);


int main(void) {
	/************************** Variable Declarations ****************************/

	int trigPos;	// variable to save trigger array position
	unsigned char c;

	/************************** END Variable Declarations ****************************/
	init_platform();

	print("Welcome to Lab 3\n\r");

    microblaze_register_handler((XInterruptHandler) myISR, (void *) 0);
    microblaze_enable_interrupts();

    Xil_Out8(flagClear, 0x01);					// Clear the flag and then you MUST
	Xil_Out8(flagClear, 0x00);					// allow the flag to be reset later



    while(1) {

    	c=XUartLite_RecvByte(uartRegAddr);




		switch(c) {

    		/*-------------------------------------------------
    		 * Reply with the help menu
    		 *-------------------------------------------------
			 */
    		case '?':

    			printf("--------------------------\r\n");
    			printf("?: help menu\r\n");
    			printf("d: demo signal\r\n");
    			printf("m: make audio arrays\r\n");
    			printf("w: write audio to BRAM\r\n");
    			printf("p: print audio arrays\r\n");
    			printf("t; print current trigger point\r\n");
    			printf("z: write triggered signal to BRAM\r\n");
    			printf("g: run oscilloscope continuously (no trigger)\r\n");
    			printf("i: use interrupts to fill arrays and write to BRAM\r\n");
    			printf("c: run oscilloscope continuously (triggered)\r\n");


    			break;

			/*-------------------------------------------------
			 * Basic I/O loopback
			 *-------------------------------------------------
			 */
    		case 'd':
    			printf("d: running demo signal\r\n");

    			for (uint32_t i=0;i<1024;i++) {
    				Xil_Out16(exWrAddr, i); // set BRAM address
    				Xil_Out16(exLBus, 185 << 7); // row for horz line
    				//exLBus = exLBus * 128;	                 // need to shift to upper 10bits?
    				Xil_Out16(exRBus, i << 7);   // diagnonal line [need to shift?]
    				Xil_Out16(exWen, (i | 1 << 10));    // write data to address in BRAM
    				Xil_Out16(exWen, (i & !(1 << 10)));    // turn off write
    		        }
					break;

    		case 'm':     // some of these will be XIL commands
    			printf("\r\n m: making audio arrays\r\n");

					for (uint32_t i=0;i<1024;i++) {
					  while( (Xil_In16(flagQReady)) == 0){}
					  array_L[i] = ((Xil_In16(lBusOut) >> 7) - 36); // read audio values
					  array_R[i] = ((Xil_In16(rBusOut) >> 7) - 36);
					  //printf("L: %d R: %d\r\n", Xil_In16(lBusOut), Xil_In16(rBusOut));
					  Xil_Out8(flagClear, 0x01);   //clear the flag
					  Xil_Out8(flagClear, 0x00);   //release the clear, so can be set again

					}
					break;
    		case 'w':     // some of these will be XIL commands
				printf("\r\n w: writing audio to BRAM\r\n");

					for (uint32_t i=0;i<1024;i++) {
						Xil_Out16(exWrAddr, i); // set BRAM address
						Xil_Out16(exLBus, array_L[i] << 7);
						Xil_Out16(exRBus, array_R[i] << 7);
						Xil_Out16(exWen, (i | 1 << 10));    // write data to address in BRAM
						Xil_Out16(exWen, (i & !(1 << 10)));    // turn off write
					}
					break;
    		case 'p':
    			printf("\r\n p: printing audio arrays\r\n");

    			for (int i=0; i<1024; i++){
    				printf("L: %d R: %d\r\n", array_L[i], array_R[i]);
    			}
    			break;
			case 't':
				printf("t: printing current trigger point\r\n");

				for (int i=1; i<1024; i++){
					if(array_L[i-1] <= Xil_In16(trigV) && array_L[i] > Xil_In16(trigV)){  //CHECK: bug may arise if negative values are in the array
						trigPos = i;
						printf("triggered index: %d\r\n", trigPos);
						printf("Volt trigger value: %d\r\n", Xil_In16(trigV));
						break;
					}
					else{
					trigPos = -1;
					}
				}
				if(trigPos == -1){
					printf("No valid trigger");
					trigPos = 0;
				}
				break;
            case 'z':
				printf("z: writing triggered signal to BRAM\r\n");

				int zTime = Xil_In16(trigT) - 20; //time trigger position
				printf("time trigger: %d\r\n", zTime);
				int zVolt = trigPos;		 //Volt trigger array index
				for(int k=0; k<1024; k++){
					Xil_Out16(exWrAddr, zTime); // set BRAM address
					Xil_Out16(exLBus, array_L[zVolt] << 7);
					Xil_Out16(exRBus, array_R[zVolt] << 7);
					Xil_Out16(exWen, (zTime | 1 << 10));    // write data to address in BRAM
					Xil_Out16(exWen, (zTime & !(1 << 10)));    // turn off write

					zTime++;
					zVolt++;

					if (zTime >= 1024){ //loop column back to front when we reach right edge of srceen
						zTime = 0;
					}
					if (zVolt >= 1024){ //loop array position back to front when we reach last index
						zVolt = 0;
					}
				}
               	break;
            case 'g':
				printf("g: continuous (no trigger)\r\n enter E to exit\r\n");

				while(c != 'E'){

					//find trigger index
					int trigFound = 0;

					for (int i=1; i<1024; i++){
						if(trigFound != 1){
							if(array_L[i-1] <= Xil_In16(trigV) && array_L[i] > Xil_In16(trigV)){  //CHECK: bug may arise if negative values are in the array
								trigPos = i;
								//printf("triggered index: %d", trigPos);
								trigFound = 1;
							}
							else{
								trigPos = -1;
							}
						}
					}
					if(trigPos == -1){
						//printf("No valid trigger");
						trigPos = 0;
					}

					//write shifted array to BRAM
					int g_Time = Xil_In16(trigT) - 20; //time trigger position
					int g_Volt = trigPos;		 //Volt trigger array index
					for(int k=0; k<1024; k++){
						Xil_Out16(exWrAddr, g_Time); // set BRAM address
						Xil_Out16(exLBus, array_L[g_Volt] << 7);
						Xil_Out16(exRBus, array_R[g_Volt] << 7);
						Xil_Out16(exWen, (g_Time | 1 << 10));    // write data to address in BRAM
						Xil_Out16(exWen, (g_Time & !(1 << 10)));    // turn off write

						g_Time++;
						g_Volt++;

						if (g_Time >= 1024){ //loop column back to front when we reach right edge of sceen
							g_Time = 0;
						}
						if (g_Volt >= 1024){ //loop array position back to front when we reach last index
							g_Volt = 0;
						}
					}

					c=XUartLite_RecvByte(uartRegAddr); //check for inputs to exit
				}

				printf("exiting G\r\n");
                break;
            case 'i':
                break;
            case 'c':
            	while(1){

            		ARRAYFULL = 0; //lets the interrupts fill the array

            		while(ARRAYFULL != 1); //wait for sample to be filled

            		//execute triggers
            		int c_trigFound = 0;

					for (int i= Xil_In16(trigT); i<1024; i++){
						if(c_trigFound != 1){
							if(array_L[i-1] <= Xil_In16(trigV) && array_L[i] > Xil_In16(trigV)){  //CHECK: bug may arise if negative values are in the array
								trigPos = i;
								//printf("triggered index: %d", trigPos);
								c_trigFound = 1;
							}
							else{
								trigPos = 0;
							}
						}
					}


					//write shifted array to BRAM
					int c_Time = Xil_In16(trigT); //time trigger position
					int c_Volt = trigPos;		 //Volt trigger array index

					if(c_trigFound && !((c_Volt - c_Time) + 600 >= 1024)){
						for(int k=20; k<620; k++){
							Xil_Out16(exWrAddr, k); // set BRAM address
							Xil_Out16(exLBus, (array_L[(c_Volt - c_Time) + k] +36) << 7);
							Xil_Out16(exRBus, (array_R[(c_Volt - c_Time) + k] +36) << 7);
							Xil_Out16(exWen, (k | 1 << 10));    // write data to address in BRAM
							Xil_Out16(exWen, (k & !(1 << 10)));    // turn off write

						}
					}
            	} //end case c while
                break;
    		default:
    			printf("unrecognized character: %c\r\n",c);
    			break;
    	} // end case

    } // end while 1

    cleanup_platform();

    return 0;
} // end main


void myISR(void) {
	//write single value into the arrays
	if(ARRAYFULL == 0){
		while( (Xil_In16(flagQReady)) == 0){}
		array_L[INDEX] = ((Xil_In16(lBusOut) >> 7) -36); // read audio values
		array_R[INDEX] = ((Xil_In16(rBusOut) >> 7) -36);
		Xil_Out8(flagClear, 0x01);   //clear the flag
		Xil_Out8(flagClear, 0x00);   //release the clear, so can be set again

		// handle indexing
		INDEX++;
		if(INDEX >= 1024){
			INDEX = 0;
			ARRAYFULL = 1;
		}
	}

}
