#ifndef ASM_DEF_H_
#define ASM_DEF_H_

////////////////////////////////////////////////////////////////////////////////
//						Соглашение о вызове функции
//	Вызываемая функция может оперировать следующими регистрами без необходимости
//  сохранения их содержимого:
//		R0, R1, R2, R3, P0, P1, P2
//  Вызывающая функция передает параметры следующим образом:
//  	R0, R1, R2, STACK
//  Вызывающая функция ждет возвращаемое значение:
//		R0, R1
//	Данное соглашение применимо также к макросам.
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//						Типовые конструкции
////////////////////////////////////////////////////////////////////////////////
/*
 *
 * 								TYPE 1:  IF, IF..
 *													...							//Вычисление условия
 * 		if(condition){								IF !CC JUMP L1;
 *			statement;								statement_true;
 * 		}
 * 		if(cond){								L1:	IF !CC JUMP L2;
 *			statement;								statement_true;
 * 		}
 * 		...										L2: ...							//Конец ветвления
 *
 *============================================================================
 *
 * 								TYPE 2:  SWITCH
 *
 *		switch(sel){								P0 = JumpTable;				//Начало  таблицы переходов
 *													P1 = sel;					//Селектор/Индекс в таблице переходов
 *													CC = P1 < maxIndx;			//Проверяем допустимость индекса
 *			case 0:									IF !CC JUMP default;		//Если индекс недопустим, по вызываем обработчик по умолчанию
 *			statement;								P0 = P0+(P1<<2)				//Адрес нужной ячейки в таблице переходов
 *			break;									P1 = [P0];					//Извлечение адреса обработчика
 *													JUMP (P1);
 *											case0:
 *			case 1:									statement;
 *			statement;							 	JUMP end;
 *			break;							case1:
 *													statement;
 *			case 2:									JUMP end;
 *			statement;						case2:
 *			break;									statement;
 *													JUMP end;
 *			default:						default:
 *			statement;								statement;
 *													JUMP end;
 *											end:
 *		}											...
 *
 *											.BYTE4 JumpTable =
 *																case0,
 *																case1,
 *																case2,
 *																...
 *																default;
 *
 *
 *===========================================================================
 *
 *								TYPE 3:  IF ELSE
 *													...							//Вычисление условия
 *		if(condition){								IF !CC JUMP L1
 *													statement_true;
 *			statement;								JUMP L2;
 *		} else{									L1:
 *			statement;								statement;
 *		}										L2:								//Конец ветвления
 *
 *==========================================================================
 *
 *								TYPE 4:  IF ELSE
 *													...							//Вычисление первого условия
 *		if( condition1||condition2 ){				IF CC JUMP L1
 *			statement;								...							//Вычисление второго условия
 *		}else{										IF CC JUMP L1
 *			statement;								statement_false;
 *		}											JUMP L2
 *												L1:
 *													statament_true;
 *												L2:								//Конец ветвления
 *
 *==========================================================================
 *
 * 								TYPE 5: IF ELSE
 *													...							//Вычисление первого условия
 *		if( condition1&&condition2 ){				IF !CC JUMP L1
 *			statement;								...							//Вычисление второго условия
 *		}else{										IF !CC JUMP L1
 *			statement;								statement_true;
 *		}											JUMP L2
 *												L1:
 *													statement_false;
 *												L2:								//Конец ветвления
 *
 *============================================================================
 *
 *								TYPE 6: LOOP
 *
 *		for( i=val1, i < val2; i+=val3 ){		L1:
 *													...							//Вычисление условия
 *													IF CC JUMP L2;
 *			statement;								JUMP L3;
 *		}										L2:								//Тело цикла
 *													statement;
 *													JUMP L1;
 *												L3:								//Конец цикла
 *
 *============================================================================
 *
 *								TYPE 7: LOOP
 *
 *		while(condition){						L1:
 *			statement;								...							//Вычисление условия
 *		}											IF CC JUMP L2;
 *													JUMP L3;
 *												L2:								//Тело цикла
 *													statement;
 *													JUMP L1;
 *												L3:								//Конец цикла
 *
 *============================================================================
 *
 *								TYPE 8: LOOP
 *
 *		do{										L1:								//Тело цикла
 *			statement;								statement;
 *		}while(condition);						L2:
 *													...							//Вычисление условия
 *													IF CC JUMP L1;
 *
 *==============================================================================
 *
 *								TYPE 9: LOOP UNROLL
 *													Ordinary LOOP				Unroll LOOP
 *
 *		for( i=0, i < 4; i++ ){					L1:								statement;     	//Iteration 1
 *													...							statement;		//Iteration 2
 *													IF CC JUMP L2;				statement;		//Iteration 3
 *			statement;								JUMP L3;					statement;		//Iteration 4
 *		}										L2:
 *													statement;
 *													JUMP L1;
 *												L3:
 *
 *==============================================================================
 *
 *								TYPE 10: INTEGER LOOKUP TABLES
 *
 *
 *		uint32_t LookUpTable[N] ={...};				P0 = LookUpTable;				//Начало  таблицы соотвествия
 *		value = LookUpTable[sel];					P1 = sel;						//Индекс/аргумент
 *													P0 = P0+(P1<<2);
 *													R1 = [P0];
 *
 * 											.BYTE4  LookUpTable =
 *																	data0,
 *																	data1,
 *																	data2,
 *																	...
 *																	dataN;
 *
 *=================================================================================
 *
 *								TYPE 11: BINARY SEARCH
 *
 *		uint32_t LookUpTable[2*N]={					                                        .BYTE4  LookUpTable =														
 *																	        						ValKey1,ValData1,
 *		//	Key			Data										        						ValKey2,ValData2,
 *			ValKey1		ValData1,									        						ValKey3,ValData3,
 *			ValKey2		ValData2,									        						...
 *			ValKey3		ValData3,                                           						ValKeyN,ValDataN;   //Значение по умолчанию
 *			...
 *			ValKeyN		ValDataN
 *		}
 *		                                                                                    //P0 = sizeof(LookUpTable)/2;             
 *		uint32_t targetKey = ValKeyX;                                                       //R1 = ValKeyX;
 *		uint32_t currentKey = 0;                                                            //P1 = LookUpTable;
 *		uint32_t targetData = 0;                                                            //P2 = sizeof(BYTE4)*2;
 *                                                                                          //LOOP SearchLoop LCO = P0;
 *		for(uint32_t index = 0; index < 2N; index += sizeof(uint32_t )*2 ){                 //LOOP_BEGIN SearchLoop;
 *			currentKey = LookUpTable[index];                                                //R0 = [P1++P2];
 *			if(currentKey == targetKey){                                                    //CC = R0 == R1;
 *              break;                                                                      //IF CC JUMP END;
 *          }                                                                               //LOOP_END SearchLoop;
 *		}                                                                               //END:             
 *		targetData = LookUpTable[ index + sizeof(uint32_t ) ];                              //P0 = LookUpTable;
 *                                                                                          //P1 = LCO;
 *                                                                                          //P0 = P0+P1+
 *
 *
 */
#define LOAD_IMM32_REG(R,VAL) 					R##.L = LO(VAL); R##.H = HI(VAL)
#define LOAD_MSB_IMM16_REG_HI(R,VAL) 			R##.L = 0; R##.H = HI(VAL)
#define LOAD_LSB_IMM16_REG_LO(R,VAL) 			R##.L = LO(VAL); R##.H = 0

#define ld32(r,val) 					        r##.l = lo((val)); r##.h = hi((val))
#define ldAddr(p, val)							p##.l = 0; p##.h = hi(val)


#endif /* ASM_DEF_H_ */
