.EXTERN _adi_initpinmux;
.EXTERN _adi_core_enable;

.EXTERN _GPIO_Control;
.EXTERN _GPIO_Triger_Overflow;
.EXTERN _Trigger_Init;
.EXTERN _Timer0_Init;
.EXTERN _Timer_Run;
.EXTERN _Timer0_Overflow;
.EXTERN _SystClock;
.EXTERN _SEC_Init;
.EXTERN _SPORT_Init;
.EXTERN _SPORT_Tranmit_Data;


.SECTION L1_code;
.ALIGN 4;
.GLOBAL _main;
_main:
_main.Init:	

    CALL _adi_initpinmux;
	
	CALL _SystClock;
	
	CALL _Timer0_Init;
	
	CALL _SEC_Init;
	
	CALL _GPIO_Control;
	
	CALL _Trigger_Init; 
	
	//CALL _Timer_Run;
	
	CALL _SPORT_Init;
	
_main.Loop:
//меандр по опросу флага триггера вх. сигнала: 
    //CALL _Timer0_Overflow;  
//меандр по опросу флага переполнения сигнала: 
	//CALL _GPIO_Triger_Overflow;
	
//цикл заполнения данными -	R0
	R0 = 10;	
	P2 = R0; 	//ЗАДЕРЖКА
	LSETUP(_GPIO_Meandr.LoopBegin, _GPIO_Meandr.LoopEnd) LC0 = P2;
_GPIO_Meandr.LoopBegin:
/*	R0 = R5;
	R1 = 1;
	R0 = R0 + R1; 
	R5 = R0; 
	
	CALL _SPORT_Tranmit_Data; */
_GPIO_Meandr.LoopEnd:

	R0.L = LO(0xF50);	// 0000 1111 0101 0000 1010
	R0.H = HI(0xF50); 
	CALL _SPORT_Tranmit_Data; 
	
	JUMP _main.Loop;
_main.end: 
/* В sec.asm - реализован меандр по прерыванию */
