#include "asm_def.h"
#include "defBF607.h"

//========== ИНТЕРФЕЙС ДЛЯ SPI ====================
#include "spi.h"

#define SPI_CLK_20MHz	(5 << BITP_SPI_CLK_BAUD)
/*=================*/
/*   МОДУЛЬ [SPI]  */
/*=================*/
.SECTION program
.ALIGN 4;
.GLOBAL _SPI_Init;
_SPI_Init:
	[--SP] = RETS;

	CALL _spi0_init;
	
_SPI_Init.exit:
	RETS = [SP++];
	RTS;
_SPI_Init.end:

/* Инициализация SPI0 */
.SECTION program
.ALIGN 4;
.GLOBAL _spi0_init;
_spi0_init:
	 ldAddr(P0, REG_SPI0_CTL);	
//Очистка буферов смещением:
	R0 = 0(Z);
	[P0 + LO(REG_SPI0_CTL)] = R0;
	[P0 + LO(REG_SPI0_RXCTL)] = R0;
	[P0 + LO(REG_SPI0_TXCTL)] = R0;
	
//Частота на которой будет работать SPI:
	R0 = SPI_CLK_20MHz;
	[P0 + LO(REG_SPI0_CLK)] = R0;
	
	P0.L = LO(REG_SPI0_DLY);
	P0.H = HI(REG_SPI0_DLY);
	R0 = [P0];
	
	R1 = (BITM_SPI_DLY_LAGX | 
		  BITM_SPI_DLY_LEADX|
		  BITM_SPI_DLY_STOP);
	R0 = R0 | R1; 
		  
	[P0] = R0;	  

//настройка под chip select:
	
	
//Режим инициирования SPI:
	P0.L = LO(REG_SPI0_TXCTL);
	P0.H = HI(REG_SPI0_TXCTL);
	R0 = [P0]; 
	
	R1 = BITM_SPI_TXCTL_TTI; 
	R0 = R0 | R1; 
	[P0] = R0; 
	
_spi0_init.exit:
	RTS;	
_spi0_init.end: 


/*===========================================================*/
/*               Функция передачи данных [SPI]               */
/*===========================================================*/
.SECTION program
.ALIGN 4;
.GLOBAL _spi_transmit_data;
_spi_transmit_data:


_spi_transmit_data.end:

/*===========================================================*/
/*               Функция приема данных [SPI]                 */
/*===========================================================*/
.SECTION program
.ALIGN 4;
.GLOBAL _spi_receive_data;
_spi_receive_data:


_spi_receive_data.end:






