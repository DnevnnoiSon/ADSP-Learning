#include "asm_def.h"
#include "defBF607.h"
/*========== НАСТРОЙКА ПОД ИНТЕРФЕЙС ДЛЯ SPI ==================*/
/*=============================================================*/
/*                    МОДУЛЬ [SPORT]                           */
/*=============================================================*/
#include "sport.h"

.SECTION program
.ALIGN 4;
.GLOBAL _SPORT_Init;
_SPORT_Init:
 	[--SP] = RETS;
/*====== SPORT1B--->DAC1 ======*/
	CALL _SPORT1B_Init;
/*====== SPORT0B--->LMX2571 ======*/
	CALL _SPORT0B_Init;
	
_SPORT_Init.exit:
	RETS = [SP++];
	RTS;	
_SPORT_Init.end:


/* Инициализация SPORT1 */
.SECTION program
.ALIGN 4;
.GLOBAL _SPORT1B_Init;
_SPORT1B_Init:	
//настройка переферийнных пинов:     
//  CALL _SPORT_GPIO_Init; - на данный момент задаётся в UI
    
    ldAddr(P0, REG_SPORT1_CTL_B);
// Очистка управляющих регистров sport:
    R0 = 0(z);
    [P0+LO(REG_SPORT1_CTL_B)] = R0;	 //..OPMODE 
    [P0+LO(REG_SPORT1_MCTL_B)] = R0; //..MCE                                         
    
    //CLK = SCLK0 / ( 1 + DIV)
    //Частота следования сигнала FS в периодах CLK  
    ld32( R0, (3  << BITP_SPORT_DIV_CLKDIV) | ( 24 << BITP_SPORT_DIV_FSDIV) );              
    [P0+LO(REG_SPORT1_DIV_B)] = R0;  
       
   ld32(R0,     ENUM_SPORT_CTL_TX|
                ENUM_SPORT_CTL_SECONDARY_DIS|
                ENUM_SPORT_CTL_GCLK_EN|
                ENUM_SPORT_CTL_TXFIN_EN|
                ENUM_SPORT_CTL_LEVEL_FS|
                ENUM_SPORT_CTL_RJUST_DIS|
                ENUM_SPORT_CTL_LATE_FS|			
                ENUM_SPORT_CTL_FS_HI|
                ENUM_SPORT_CTL_DATA_INDP_FS|
                ENUM_SPORT_CTL_INTERNAL_FS|	
                ENUM_SPORT_CTL_FS_REQ|        
                ENUM_SPORT_CTL_CLK_RISE_EDGE|
                ENUM_SPORT_CTL_SERIAL_MC_MODE|
                ENUM_SPORT_CTL_INTERNAL_CLK|	
                ENUM_SPORT_CTL_PACK_DIS|
                ((24 - 1 ) << BITP_SPORT_CTL_SLEN)|
                ENUM_SPORT_CTL_MSB_FIRST|
                ENUM_SPORT_CTL_RJUSTIFY_ZFILL|
                ENUM_SPORT_CTL_EN    ); 
                    
	[P0+LO(REG_SPORT1_CTL_B)] = R0;	
	
_SPORT1B_Init.exit:
	RTS;
_SPORT1B_Init.end:

/* Инициализация SPORT0 */
.SECTION program
.ALIGN 4;
.GLOBAL _SPORT0B_Init;
_SPORT0B_Init:
//настройка переферийнных пинов: [задаётся в UI]
	ldAddr(P0, REG_SPORT0_CTL_B);
//Очистка управляющих регистров sport:
    R0 = 0(z);
    [P0+LO(REG_SPORT0_CTL_B)] = R0;	 //..OPMODE 
    [P0+LO(REG_SPORT0_MCTL_B)] = R0; //..MCE     
//Частота следования сигнала FS в периодах CLK  
	ld32( R0, (3  << BITP_SPORT_DIV_CLKDIV) | ( 24 << BITP_SPORT_DIV_FSDIV) );  
	
	[P0+LO(REG_SPORT0_DIV_B)] = R0;  
       
    ld32(R0,    ENUM_SPORT_CTL_TX|
                ENUM_SPORT_CTL_SECONDARY_DIS|
                ENUM_SPORT_CTL_GCLK_EN|
                ENUM_SPORT_CTL_TXFIN_EN|
                ENUM_SPORT_CTL_LEVEL_FS|
                ENUM_SPORT_CTL_RJUST_DIS|
                ENUM_SPORT_CTL_LATE_FS|			
                ENUM_SPORT_CTL_FS_HI|
                ENUM_SPORT_CTL_DATA_INDP_FS|
                ENUM_SPORT_CTL_INTERNAL_FS|	
                ENUM_SPORT_CTL_FS_REQ|        
                ENUM_SPORT_CTL_CLK_RISE_EDGE|
                ENUM_SPORT_CTL_SERIAL_MC_MODE|
                ENUM_SPORT_CTL_INTERNAL_CLK|	
                ENUM_SPORT_CTL_PACK_DIS|
                ((24 - 1 ) << BITP_SPORT_CTL_SLEN)|
                ENUM_SPORT_CTL_MSB_FIRST|
                ENUM_SPORT_CTL_RJUSTIFY_ZFILL|
                ENUM_SPORT_CTL_EN  ); 
                    
	[P0+LO(REG_SPORT0_CTL_B)] = R0;	
_SPORT0B_Init.exit:
	RTS;	
_SPORT0B_Init.end:


/* настройка SPORT1B ножек */
.SECTION program
.ALIGN 4;
.GLOBAL _SPORT_GPIO_Init;
_SPORT_GPIO_Init:
//PE4 ---> CLK:	
	// Периферийный
	P0.H = HI(REG_PORTE_FER);
	P0.L = LO(REG_PORTE_FER);
	R0 = [P0];
	R1 = BITM_PORT_FER_PX4;
	R0 = R0 | R1;          
	[P0] = R0;
	
	P0.H = HI(REG_PORTE_MUX);
	P0.L = LO(REG_PORTE_MUX);
	R0 = [P0];

	R1 = 2 << BITP_PORT_MUX_MUX4;  
	R0 = R0 | R1;
	
	[P0] = R0;
	
	RTS;
_SPORT_GPIO_Init.end: 

/*===========================================================*/
/*               Функция передачи данных [SPORT1]            */
/*===========================================================*/
//R0 - ccылка на данные
.SECTION program
.ALIGN 4;
.GLOBAL _SPORT1B_Transmit_Data;
_SPORT1B_Transmit_Data:
//half_B на передачу
//PE3 ---> BFS(CHIP SELECT)
  	ldAddr(P0, REG_SPORT1_CTL_B);
	
//проверка свободного места буффера:
_SPORT1B_Transmit_Data.check_buf_reserve:
	P1.L = LO(REG_SPORT1_CTL_B);	
	P1.H = HI(REG_SPORT1_CTL_B);  
	R1 = [P1];	
	ld32(R1, BITM_SPORT_CTL_B_DXSPRI); 
	R2 = R1 | R2; //проверка 32 бит значения
	CC = R1 == R2;
	IF CC JUMP _SPORT1B_Transmit_Data.check_buf_reserve;
	
//отгрузка данных - помещение их в буффер:    
    [P0 + LO(REG_SPORT1_TXPRI_B)] = R0; 
_SPORT1B_Transmit_Data.exit: 
	RTS;
_SPORT1B_Transmit_Data.end:

/*===========================================================*/
/*               Функция передачи данных [SPORT0]            */
/*===========================================================*/
//R0 - ccылка на данные
.SECTION program
.ALIGN 4;
.GLOBAL _SPORT0B_Transmit_Data;
_SPORT0B_Transmit_Data:
//half_B на передачу
	ldAddr(P0, REG_SPORT0_CTL_B);
	
/*=========== МУЛЬТИПЛЕКСИРОВАНИЕ ================*/	
	P1.L = LO(REG_PORTF_FER);      
	P1.H = HI(REG_PORTF_FER);
	R1 = [P1];
	R2 = ~(BITM_PORT_FER_PX4 | BITM_PORT_FER_PX5);
	R1 = R2 & R1; 
	[P1] = R1;
	
	P1.L = LO(REG_PORTF_DIR);     
	P1.H = HI(REG_PORTF_DIR);
	R1 = [P1];	
	R2 = BITM_PORT_POL_PX4 | BITM_PORT_POL_PX5;
	R1 = R1 | R2;
	[P1] = R1;
	
	P1.L = LO(REG_PORTF_DATA);       
	P1.H = HI(REG_PORTF_DATA);
	R1 = [P1];	
	R2 = ~(BITM_PORT_DATA_TGL_PX4 | BITM_PORT_POL_PX5);
	R1 = R1 & R2;
	[P1] = R1;

//проверка свободного места буффера:
_SPORT0B_Transmit_Data.check_buf_reserve:
    R1 = [P1];                      
    R2 = BITM_SPORT_STAT_TXHRE;     
    R3 = R1 & R2;
    CC = R3 == 0;
    IF CC JUMP _SPORT0B_Transmit_Data.check_buf_reserve;
	
//отгрузка данных - помещение их в буффер:    
    [P0 + LO(REG_SPORT0_TXPRI_B)] = R0; 
    
_SPORT0B_Transmit_Data.exit: 
	RTS;
_SPORT0B_Transmit_Data.end:






























