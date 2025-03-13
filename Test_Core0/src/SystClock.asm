#include "defBF607.h"
#include "SystClock.h"

// R0 - Опрашиваемый Регистр
// R1 - Значение маски
#define  REG_SET_MASKOR(Reg1, Reg2)			Reg1 = Reg1 & Reg2 //OR MASK										
#define  REG_SET_MASKANDK(Reg1, Reg2)		Reg1 = Reg1 | Reg2 //AND MASK
												
.GLOBAL _SystClock;	
.SECTION program
.ALIGN 4;
_SystClock:
_SystClock.init:
	//Проверка текущего состояния CGU_STAT:
	 R0 = 1;
	 CALL _Check_temp_SystClock;
	 	
	//Настройка коэффициента деления:
	 CALL _Set_Kofficient;
	 
    //Изменение частоты PLL:
    CALL _Change_PLL_Frequency;
    
    //Проверка завершения процесса:
     R0 = 0;
    CALL _Check_temp_SystClock;
	 RTS;
_SystClock.error:
//Опрос кодов ошибок
//...
//Обработка ошибок
	RTS; 
_SystClock.end:


//================= ПРОВЕРКА ТЕКУЩЕГО СОСТОЯНИЯ ===================
//СОГЛАШЕНИЕ: R0 - ЭЛЕМЕНТ ОТВЕЧАЮЩИЙ ЗА НАЛОЖЕНИЕ МАСКИ
.GLOBAL _Check_temp_SystClock;	
.SECTION program
.ALIGN 4;
_Check_temp_SystClock:
	R3 = R0;
    P0.L =  LO(REG_CGU0_STAT);	
    P0.H =  HI(REG_CGU0_STAT);

	R0 = [P0];

	R1.L = LO(BITM_CGU_STAT_PLLEN);	
	R1.h = HI(BITM_CGU_STAT_PLLEN);
	REG_SET_MASKANDK(R0, R1);

	R1.L = LO(BITM_CGU_STAT_PLOCK);
	R1.H = HI(BITM_CGU_STAT_PLOCK);
	REG_SET_MASKANDK(R0, R1);
	
	R1 = 0(Z);
	CC = R3 == R1;
	IF CC JUMP _Check_temp_SystClock.PLLBP;
_Check_temp_SystClock.PLOCKERR:
	R1.L = LO(BITM_CGU_STAT_PLOCKERR);	
	R1.H = HI(BITM_CGU_STAT_PLOCKERR);	
	REG_SET_MASKANDK(R0, R1);
	
	JUMP _Check_temp_SystClock.CLKSALGN;
_Check_temp_SystClock.PLLBP:
	R1.L = LO(BITM_CGU_STAT_PLLBP);	
	R1.H = HI(BITM_CGU_STAT_PLLBP);	
	REG_SET_MASKANDK(R0, R1);

_Check_temp_SystClock.CLKSALGN:
	R1.L = LO(BITM_CGU_STAT_CLKSALGN);	
	R1.H = HI(BITM_CGU_STAT_CLKSALGN);	
	REG_SET_MASKOR(R0, R1);
	
	[P0] = R0;
	RTS;
_Check_temp_SystClock.end:

//================ НАТСРОЙКА ЧАСТОТЫ ДЕЛЕНИЯ ===================
.GLOBAL _Set_Kofficient;	
.SECTION program
.ALIGN 4;
_Set_Kofficient:
	P0.L =  LO(REG_CGU0_CTL);	
    P0.H =  HI(REG_CGU0_CTL);
    
    R0 = [P0];
    BITCLR(R0, BITP_CGU_CTL_MSEL);	
    
    R1 = 0x14;
    R0 = R0 | R1;
    
    [P0] = R0; 
_Set_Kofficient.PLLwait:
	P0.L = LO(REG_CGU0_STAT);
	P0.H = LO(REG_CGU0_STAT);
	R0 = [P0];
	
	//Ожидание фиксации бита PLOCK = 1
	CC = BITTST(R0, BITP_CGU_STAT_PLOCK );
	IF CC JUMP _Set_Kofficient.PLLwait;
	
	//Установка делителей:
	 P0.L = LO(REG_CGU0_DIV);
     P0.H = HI(REG_CGU0_DIV);
     R0 = [P0];
	
	 BITCLR(R0, BITP_CGU_DIV_SYSSEL);
	 R1 = 0 (Z);
	 R1 = (4 << 4);
	 R0 = R0 | R1;
	 [P0] = R0; 
	
_Set_Kofficient.Align_Wait:
	P0.L = LO(REG_CGU0_STAT);
	P0.L = LO(REG_CGU0_STAT);
	R0 = [P0];
//ожидание сигнализации тактовых сигналов 
	R1 = (1 << 8);
   	R0 = R0 & R1;  // Проверяем бит CLKSALGN
    R1 = 0(Z);
  	CC = R0 == R1;
  	IF CC JUMP _Set_Kofficient.Align_Wait;
  	
	RTS;
_Set_Kofficient.end:

//================ ИЗМЕНЕНИЕ ЧАСТОТЫ PLL ===================
.GLOBAL _Change_PLL_Frequency
.SECTION program
.ALIGN 4;
_Change_PLL_Frequency:
	   
    P0.L = LO(REG_CGU0_STAT);
    P0.H = HI(REG_CGU0_STAT);
    R0 = [P0];

    R1.L = LO(BITM_CGU_STAT_PLOCKERR);
    R1.H = HI(BITM_CGU_STAT_PLOCKERR);
    BITCLR(R0, BITP_CGU_STAT_PLOCKERR); 

    [P0] = R0;  

    P0.L = LO(REG_CGU0_CTL);
    P0.H = HI(REG_CGU0_CTL);
    R0 = [P0];

    R1.L = LO(BITM_CGU_CTL_PLLBP);
    R1.H = HI(BITM_CGU_CTL_PLLBP);
    R0 = R0 | R1; 

    [P0] = R0;  

    P0.L = LO(REG_CGU0_CTL);
    P0.H = HI(REG_CGU0_CTL);
    R0 = [P0];

    R1 = 0x3F;  
    R1 = ~R1;
    R0 = R0 & R1; 

    R1 = 0x14; 
    R0 = R0 | R1;

    [P0] = R0;  
   
    P0.L = LO(REG_CGU0_CTL);
    P0.H = HI(REG_CGU0_CTL);
    R0 = [P0];

    BITCLR(R0, BITP_CGU_STAT_PLLBP); 

    [P0] = R0;  

_PLL_Wait_Lock:
    P0.L = LO(REG_CGU0_STAT);
    P0.H = HI(REG_CGU0_STAT);
    R0 = [P0];

    CC = BITTST(R0, BITP_CGU_STAT_PLOCK);
    IF !CC JUMP _PLL_Wait_Lock;  

_PLL_Wait_Align:
    P0.L = LO(REG_CGU0_STAT);
    P0.H = HI(REG_CGU0_STAT);
    R0 = [P0];

    R1 = (1 << 8);
    R0 = R0 & R1;  
    R1 = 0(Z);
    CC = R0 == R1;
    IF CC JUMP _PLL_Wait_Align;

    RTS; 
_Change_PLL_Frequency.end:



