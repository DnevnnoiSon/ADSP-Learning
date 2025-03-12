#include "defBF607.h"
#include "SystClock.h"

// R0 - Опрашиваемый Регистр
// R1 - Значение маски
#define  PLL_REGS_CHECK()			R1 = R0 & R1; \
									R1 = R0 | R1 
#define  PLL_REGS_CHECK_(Reg1, Reg2)			Reg1 = Reg1 & Reg2; \
												Reg1 = Reg1 | Reg2 

.GLOBAL _SystClock;	
.SECTION program
.ALIGN 4;
_SystClock:
_SystClock.init:
	//Проверка текущего состояния CGU_STAT:
	 CALL Check_temp_SystClock;
	 	
	//Настройка коэффициента деления:
	 CALL _Set_Kofficient;
	 
    //Изменение частоты PLL:
	 RTS;
_SystClock.error:
//Опрос кодов ошибок
//...
//Обработка ошибок
	RTS; 
_SystClock.end:

//============================================================================
//Функция проверки текущего состояния CGU_STAT
.GLOBAL Check_temp_SystClock;	
.SECTION program
.ALIGN 4;
Check_temp_SystClock:
     P0.L =  LO(REG_CGU0_STAT);	
     P0.H =  HI(REG_CGU0_STAT);
//Регистр будет хранится в R0    
	 R0 = [P0];
//Проверка текущего состояния CGU_STAT:	 
	 [--SP] = R0;
	 R1.L = LO(BITM_CGU_STAT_PLLEN);
	 R1.H = HI(BITM_CGU_STAT_PLLEN);
	 R2 = 1;
	 CALL _Mask_Add;
	 R0 = [SP++];
	 
	 PLL_REGS_CHECK();
	 
	 PLL_REGS_CHECK_(R0, R1);
	 
	 [--SP] = R0;
	 R1 = BITM_CGU_STAT_PLOCK;
	 R2 = 1;
	 CALL _Mask_Add;
	 R0 = [SP++];
	 
	 [--SP] = R0;
	 R1.L = LO(BITM_CGU_STAT_PLOCKERR);
	 R1.H = HI(BITM_CGU_STAT_PLOCKERR);
	 R2 = 1;
	 CALL _Mask_Add;
	 R0 = [SP++];
	 
	 [--SP] = R0;
	 R1.L = LO(BITM_CGU_STAT_CLKSALGN);
	 R1.H = HI(BITM_CGU_STAT_CLKSALGN);
	 R2 = 0;
	 CALL _Mask_Add;
	 R0 = [SP++];
	 
	 RTS;
Check_temp_SystClock.end:

//============================================================================
.GLOBAL Set_Kofficient;	
.SECTION program
.ALIGN 4;
Set_Kofficient:

Set_Kofficient.end:
//============================================================================
//Соглашение:
// R0 - Опрашиваемый Регистр
// R1 - Значение маски
// R2 - Вид Операции[1 -> OR MASK] [0 -> AND MASK] 
// Возвращает код ошибки
.GLOBAL _Mask_Add;	
.SECTION program
.ALIGN 4;
_Mask_Add:
	R3 = R1;
	CC = R2;
	IF CC JUMP _Mask_Add.OR;
Mask_Add.AND:	
	R1 = R0 & R1; 
	CC = R0 == R1; 
	IF !CC JUMP _Mask_Add.False;
	
	JUMP _Mask_Add.True;
_Mask_Add.OR:	
	R1 = R0 | R1; 
	CC = R0 == R1; 
	IF !CC JUMP _Mask_Add.False;
	
_Mask_Add.True:
	RTS;
_Mask_Add.False:
	
_Mask_Add.end:




