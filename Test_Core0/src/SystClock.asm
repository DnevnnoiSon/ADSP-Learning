#include "defBF607.h"
#include "SystClock.h"

.GLOBAL _Check_temp_SystClock;
.GLOBAL _Change_PLL_Frequency;

// R0 - Опрашиваемый Регистр
// R1 - Значение маски
#define  REG_SET_MASKAND(Reg1, Reg2) 	Reg2 = Reg2 & Reg1  //AND MASK								
#define  REG_SET_MASKOR(Reg1, Reg2)		Reg2 = Reg1 | Reg2  //OR MASK
						
												
.GLOBAL _SystClock;	
.SECTION program
.ALIGN 4;
_SystClock:
_SystClock.init:
	[--SP] = RETS;
	//Проверка текущего состояния CGU_STAT:
	 R0 = 1;
	 CALL _Check_temp_SystClock;
	 	
    //Изменение частоты PLL:
     CALL _Change_PLL_Frequency;
    
    //Проверка завершения процесса:
     R0 = 0;
     CALL _Check_temp_SystClock;
     
     RETS = [SP++];
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
	R3 = R0;	//Выгрузка выбора наложения макси
_Check_temp_SystClock.Start:
    P0.L =  LO(REG_CGU0_STAT);	
    P0.H =  HI(REG_CGU0_STAT);
	R0 = [P0];
//============ Наложение маски =================
	R1.L = LO(BITM_CGU_STAT_PLLEN);	
	R1.H = HI(BITM_CGU_STAT_PLLEN);
	REG_SET_MASKOR(R0, R1);
	CC = R0 == R1;
	IF !CC JUMP _Check_temp_SystClock.Start;
//============ Наложение маски =================
 _Check_temp_SystClock.PLOCK:
 	R1.L = LO(BITM_CGU_STAT_PLOCK);
	R1.H = HI(BITM_CGU_STAT_PLOCK);
	REG_SET_MASKOR(R0, R1);
	CC = R0 == R1;
	IF !CC JUMP _Check_temp_SystClock.Start;
//=========== Выбор наложения маски ============================
	R1 = 1(Z);
	CC = R3 == R1;
	IF CC JUMP _Check_temp_SystClock.CLKSALGN;
//============ Наложение маски =================	
_Check_temp_SystClock.PLLBP:
	R1.L = LO(BITM_CGU_STAT_PLLBP);	
	R1.H = HI(BITM_CGU_STAT_PLLBP);	
	REG_SET_MASKAND(R0, R1);
	CC = R1 == 0;
	IF !CC JUMP _Check_temp_SystClock.Start;
//===============================================================
//============ Наложение маски =================
_Check_temp_SystClock.CLKSALGN:
	R1.L = LO(BITM_CGU_STAT_CLKSALGN);	
	R1.H = HI(BITM_CGU_STAT_CLKSALGN);	
	REG_SET_MASKAND(R0, R1);
	CC = R1 == 0;
	IF !CC JUMP _Check_temp_SystClock.Start;
	
	[P0] = R0;
	RTS;
_Check_temp_SystClock.end:


//================ НАСТРОЙКА КОЭФФИЦИЕНТОВ ДЛЯ ЧАСТОТЫ PLL ===================
.GLOBAL _Change_PLL_Frequency;
.SECTION program
.ALIGN 4;
_Change_PLL_Frequency:
//============= Отключение PLL =======================
	P0.L =  LO(REG_CGU0_CTL);	
    P0.H =  HI(REG_CGU0_CTL);
//============= Включение режима bypass =======================
    R0 = [P0];  
    BITSET(R0, BITP_CGU_STAT_PLLBP);  //bypass ON 
    BITCLR(R0, BITP_CGU_STAT_PLLEN);  //обновление
    [P0] = R0; 
//=== Установка коэффициентов деления/множителей =====
	P0.L = LO(REG_CGU0_DIV);
    P0.H = HI(REG_CGU0_DIV);
	R0 = [P0];
	
	// Очистка полей MSEL, DF и CSEL
	R2 = ~((BITM_CGU_CTL_MSEL) | (BITM_CGU_CTL_DF) | (BITM_CGU_DIV_CSEL));
	R0 = R0 & R2;
	//Сгенерить:
	R1 = ((40 << BITP_CGU_CTL_MSEL)
	    | ( 1 << BITP_CGU_CTL_DF)
	    | ( 1 << BITP_CGU_DIV_CSEL));
	R0 = R0 | R1; 
	[P0] = R0; 
//============= Включение PLL =======================	
	P0.L =  LO(REG_CGU0_CTL);	
    P0.H =  HI(REG_CGU0_CTL);
    
    R0 = [P0];
    //============= Отключение режима bypass =======================   
    BITCLR(R0, BITP_CGU_STAT_PLLBP);  //bypass OFF (PLLBP = 0)
    BITSET(R0, BITP_CGU_STAT_PLLEN);  //обновление
    [P0] = R0;

	RTS;
_Change_PLL_Frequency.end:


.GLOBAL _Debbug_foo
.SECTION program
.ALIGN 4;
_Debbug_foo:
	P0.L = LO(REG_CGU0_CTL);
	P0.H = HI(REG_CGU0_CTL);
	R1 = [P0];
	
	P0.L = LO(REG_CGU0_STAT);
	P0.H = HI(REG_CGU0_STAT);
	R1 = [P0];
	
	RTS;
_Debbug_foo.end:







