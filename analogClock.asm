
_readRTC:

;analogClock.c,22 :: 		unsigned short readRTC(unsigned short address){
;analogClock.c,26 :: 		I2C1_Start();
	CALL        _I2C1_Start+0, 0
;analogClock.c,27 :: 		I2C1_Wr(0xD0);                      //address 0x68 followed by direction bit (0 for write, 1 for read) 0x68 followed by 0 --> 0xD0
	MOVLW       208
	MOVWF       FARG_I2C1_Wr_data_+0 
	CALL        _I2C1_Wr+0, 0
;analogClock.c,28 :: 		I2C1_Wr(address);
	MOVF        FARG_readRTC_address+0, 0 
	MOVWF       FARG_I2C1_Wr_data_+0 
	CALL        _I2C1_Wr+0, 0
;analogClock.c,29 :: 		I2C1_Repeated_Start();
	CALL        _I2C1_Repeated_Start+0, 0
;analogClock.c,30 :: 		I2C1_Wr(0xD1);                      //0x68 followed by 1 --> 0xD1
	MOVLW       209
	MOVWF       FARG_I2C1_Wr_data_+0 
	CALL        _I2C1_Wr+0, 0
;analogClock.c,31 :: 		r_data=I2C1_Rd(0);
	CLRF        FARG_I2C1_Rd_ack+0 
	CALL        _I2C1_Rd+0, 0
	MOVF        R0, 0 
	MOVWF       readRTC_r_data_L0+0 
;analogClock.c,32 :: 		I2C1_Stop();
	CALL        _I2C1_Stop+0, 0
;analogClock.c,33 :: 		return(r_data);
	MOVF        readRTC_r_data_L0+0, 0 
	MOVWF       R0 
;analogClock.c,34 :: 		}
L_end_readRTC:
	RETURN      0
; end of _readRTC

_writeRTC:

;analogClock.c,37 :: 		void writeRTC(unsigned short address,unsigned short w_data){
;analogClock.c,39 :: 		I2C1_Start();                       // issue I2C start signal
	CALL        _I2C1_Start+0, 0
;analogClock.c,40 :: 		I2C1_Wr(0xD0);                      // send byte via I2C (device address + W)
	MOVLW       208
	MOVWF       FARG_I2C1_Wr_data_+0 
	CALL        _I2C1_Wr+0, 0
;analogClock.c,41 :: 		I2C1_Wr(address);                   // send byte (address of DS1307 location)
	MOVF        FARG_writeRTC_address+0, 0 
	MOVWF       FARG_I2C1_Wr_data_+0 
	CALL        _I2C1_Wr+0, 0
;analogClock.c,42 :: 		I2C1_Wr(w_data);                    // send data (data to be written)
	MOVF        FARG_writeRTC_w_data+0, 0 
	MOVWF       FARG_I2C1_Wr_data_+0 
	CALL        _I2C1_Wr+0, 0
;analogClock.c,43 :: 		I2C1_Stop();                        // issue I2C stop signal
	CALL        _I2C1_Stop+0, 0
;analogClock.c,44 :: 		}
L_end_writeRTC:
	RETURN      0
; end of _writeRTC

_initMain:

;analogClock.c,48 :: 		void initMain() {
;analogClock.c,50 :: 		ANSELA = 0;                         // Configure AN pins as digital
	CLRF        ANSELA+0 
;analogClock.c,51 :: 		ANSELB = 0;
	CLRF        ANSELB+0 
;analogClock.c,52 :: 		ANSELC = 0;
	CLRF        ANSELC+0 
;analogClock.c,54 :: 		C1ON_bit = 0;                       // To turn off comparators
	BCF         C1ON_bit+0, BitPos(C1ON_bit+0) 
;analogClock.c,55 :: 		ADCON1 = 0x06;                      // To turn off ADCs
	MOVLW       6
	MOVWF       ADCON1+0 
;analogClock.c,57 :: 		PORTA = 255;
	MOVLW       255
	MOVWF       PORTA+0 
;analogClock.c,58 :: 		TRISA = 255;                        // configure PORTA pins as input
	MOVLW       255
	MOVWF       TRISA+0 
;analogClock.c,59 :: 		LATC  = 0;                          // set PORTC to 0
	CLRF        LATC+0 
;analogClock.c,60 :: 		TRISC = 0;                          // designate PORTC pins as output
	CLRF        TRISC+0 
;analogClock.c,61 :: 		PWM1_Init(5000);                    // initialize PWM1 module at 5KHz
	BSF         T2CON+0, 0, 0
	BSF         T2CON+0, 1, 0
	MOVLW       99
	MOVWF       PR2+0, 0
	CALL        _PWM1_Init+0, 0
;analogClock.c,62 :: 		PWM2_Init(5000);                    // initialize PWM2 module at 5KHz
	BSF         T2CON+0, 0, 0
	BSF         T2CON+0, 1, 0
	MOVLW       99
	MOVWF       PR2+0, 0
	CALL        _PWM2_Init+0, 0
;analogClock.c,63 :: 		I2C1_Init(100000);                  // initialize I2C
	MOVLW       80
	MOVWF       SSP1ADD+0 
	CALL        _I2C1_Init+0, 0
;analogClock.c,66 :: 		writeRTC(7, 0x10);                  //initialize 1PPS output
	MOVLW       7
	MOVWF       FARG_writeRTC_address+0 
	MOVLW       16
	MOVWF       FARG_writeRTC_w_data+0 
	CALL        _writeRTC+0, 0
;analogClock.c,68 :: 		}
L_end_initMain:
	RETURN      0
; end of _initMain

_main:

;analogClock.c,71 :: 		void main() {
;analogClock.c,73 :: 		initMain();                         // start services
	CALL        _initMain+0, 0
;analogClock.c,75 :: 		current_duty  = 0;                  // initial value for current_duty
	CLRF        _current_duty+0 
;analogClock.c,76 :: 		current_duty1 = 0;                  // initial value for current_duty1
	CLRF        _current_duty1+0 
;analogClock.c,78 :: 		PWM1_Start();                       // start PWM1
	CALL        _PWM1_Start+0, 0
;analogClock.c,79 :: 		PWM2_Start();                       // start PWM2
	CALL        _PWM2_Start+0, 0
;analogClock.c,80 :: 		PWM1_Set_Duty(current_duty);        // Set current duty for PWM1
	MOVF        _current_duty+0, 0 
	MOVWF       FARG_PWM1_Set_Duty_new_duty+0 
	CALL        _PWM1_Set_Duty+0, 0
;analogClock.c,81 :: 		PWM2_Set_Duty(current_duty1);       // Set current duty for PWM2
	MOVF        _current_duty1+0, 0 
	MOVWF       FARG_PWM2_Set_Duty_new_duty+0 
	CALL        _PWM2_Set_Duty+0, 0
;analogClock.c,83 :: 		while (1) {                         // endless loop
L_main0:
;analogClock.c,85 :: 		sec = readRTC(0);
	CLRF        FARG_readRTC_address+0 
	CALL        _readRTC+0, 0
	MOVF        R0, 0 
	MOVWF       _sec+0 
	MOVLW       0
	MOVWF       _sec+1 
;analogClock.c,86 :: 		min1 = readRTC(1);
	MOVLW       1
	MOVWF       FARG_readRTC_address+0 
	CALL        _readRTC+0, 0
	MOVF        R0, 0 
	MOVWF       _min1+0 
	MOVLW       0
	MOVWF       _min1+1 
;analogClock.c,87 :: 		hr = readRTC(2);
	MOVLW       2
	MOVWF       FARG_readRTC_address+0 
	CALL        _readRTC+0, 0
	MOVF        R0, 0 
	MOVWF       _hr+0 
	MOVLW       0
	MOVWF       _hr+1 
;analogClock.c,88 :: 		wDay = readRTC(3);
	MOVLW       3
	MOVWF       FARG_readRTC_address+0 
	CALL        _readRTC+0, 0
	MOVF        R0, 0 
	MOVWF       _wDay+0 
	MOVLW       0
	MOVWF       _wDay+1 
;analogClock.c,89 :: 		day = readRTC(4);
	MOVLW       4
	MOVWF       FARG_readRTC_address+0 
	CALL        _readRTC+0, 0
	MOVF        R0, 0 
	MOVWF       _day+0 
	MOVLW       0
	MOVWF       _day+1 
;analogClock.c,90 :: 		month = readRTC(5);
	MOVLW       5
	MOVWF       FARG_readRTC_address+0 
	CALL        _readRTC+0, 0
	MOVF        R0, 0 
	MOVWF       _month+0 
	MOVLW       0
	MOVWF       _month+1 
;analogClock.c,91 :: 		year = readRTC(6);
	MOVLW       6
	MOVWF       FARG_readRTC_address+0 
	CALL        _readRTC+0, 0
	MOVF        R0, 0 
	MOVWF       _year+0 
	MOVLW       0
	MOVWF       _year+1 
;analogClock.c,107 :: 		if (RA0_bit) {                      // button on RA0 pressed
	BTFSS       RA0_bit+0, BitPos(RA0_bit+0) 
	GOTO        L_main2
;analogClock.c,108 :: 		Delay_ms(40);
	MOVLW       2
	MOVWF       R11, 0
	MOVLW       160
	MOVWF       R12, 0
	MOVLW       146
	MOVWF       R13, 0
L_main3:
	DECFSZ      R13, 1, 1
	BRA         L_main3
	DECFSZ      R12, 1, 1
	BRA         L_main3
	DECFSZ      R11, 1, 1
	BRA         L_main3
	NOP
;analogClock.c,109 :: 		current_duty++;                  // increment current_duty
	INCF        _current_duty+0, 1 
;analogClock.c,110 :: 		PWM1_Set_Duty(current_duty);
	MOVF        _current_duty+0, 0 
	MOVWF       FARG_PWM1_Set_Duty_new_duty+0 
	CALL        _PWM1_Set_Duty+0, 0
;analogClock.c,111 :: 		}
L_main2:
;analogClock.c,113 :: 		if (RA1_bit) {                      // button on RA1 pressed
	BTFSS       RA1_bit+0, BitPos(RA1_bit+0) 
	GOTO        L_main4
;analogClock.c,114 :: 		Delay_ms(40);
	MOVLW       2
	MOVWF       R11, 0
	MOVLW       160
	MOVWF       R12, 0
	MOVLW       146
	MOVWF       R13, 0
L_main5:
	DECFSZ      R13, 1, 1
	BRA         L_main5
	DECFSZ      R12, 1, 1
	BRA         L_main5
	DECFSZ      R11, 1, 1
	BRA         L_main5
	NOP
;analogClock.c,115 :: 		current_duty--;                  // decrement current_duty
	DECF        _current_duty+0, 1 
;analogClock.c,116 :: 		PWM1_Set_Duty(current_duty);
	MOVF        _current_duty+0, 0 
	MOVWF       FARG_PWM1_Set_Duty_new_duty+0 
	CALL        _PWM1_Set_Duty+0, 0
;analogClock.c,117 :: 		}
L_main4:
;analogClock.c,119 :: 		if (RA2_bit) {                      // button on RA2 pressed
	BTFSS       RA2_bit+0, BitPos(RA2_bit+0) 
	GOTO        L_main6
;analogClock.c,120 :: 		Delay_ms(40);
	MOVLW       2
	MOVWF       R11, 0
	MOVLW       160
	MOVWF       R12, 0
	MOVLW       146
	MOVWF       R13, 0
L_main7:
	DECFSZ      R13, 1, 1
	BRA         L_main7
	DECFSZ      R12, 1, 1
	BRA         L_main7
	DECFSZ      R11, 1, 1
	BRA         L_main7
	NOP
;analogClock.c,121 :: 		dutyArrayInd++;                  // increment current_duty1
	INFSNZ      _dutyArrayInd+0, 1 
	INCF        _dutyArrayInd+1, 1 
;analogClock.c,122 :: 		PWM2_Set_Duty(dutyArray[dutyArrayInd]);
	MOVF        _dutyArrayInd+0, 0 
	MOVWF       R0 
	MOVF        _dutyArrayInd+1, 0 
	MOVWF       R1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	MOVLW       _dutyArray+0
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       hi_addr(_dutyArray+0)
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_PWM2_Set_Duty_new_duty+0 
	CALL        _PWM2_Set_Duty+0, 0
;analogClock.c,123 :: 		}
L_main6:
;analogClock.c,125 :: 		if (RA3_bit) {                      // button on RA3 pressed
	BTFSS       RA3_bit+0, BitPos(RA3_bit+0) 
	GOTO        L_main8
;analogClock.c,126 :: 		Delay_ms(40);
	MOVLW       2
	MOVWF       R11, 0
	MOVLW       160
	MOVWF       R12, 0
	MOVLW       146
	MOVWF       R13, 0
L_main9:
	DECFSZ      R13, 1, 1
	BRA         L_main9
	DECFSZ      R12, 1, 1
	BRA         L_main9
	DECFSZ      R11, 1, 1
	BRA         L_main9
	NOP
;analogClock.c,127 :: 		dutyArrayInd--;                  // decrement current_duty1
	MOVLW       1
	SUBWF       _dutyArrayInd+0, 1 
	MOVLW       0
	SUBWFB      _dutyArrayInd+1, 1 
;analogClock.c,128 :: 		PWM2_Set_Duty(dutyArray[dutyArrayInd]);
	MOVF        _dutyArrayInd+0, 0 
	MOVWF       R0 
	MOVF        _dutyArrayInd+1, 0 
	MOVWF       R1 
	RLCF        R0, 1 
	BCF         R0, 0 
	RLCF        R1, 1 
	MOVLW       _dutyArray+0
	ADDWF       R0, 0 
	MOVWF       FSR0 
	MOVLW       hi_addr(_dutyArray+0)
	ADDWFC      R1, 0 
	MOVWF       FSR0H 
	MOVF        POSTINC0+0, 0 
	MOVWF       FARG_PWM2_Set_Duty_new_duty+0 
	CALL        _PWM2_Set_Duty+0, 0
;analogClock.c,129 :: 		}
L_main8:
;analogClock.c,131 :: 		Delay_ms(10);                     // generic wait
	MOVLW       104
	MOVWF       R12, 0
	MOVLW       228
	MOVWF       R13, 0
L_main10:
	DECFSZ      R13, 1, 1
	BRA         L_main10
	DECFSZ      R12, 1, 1
	BRA         L_main10
	NOP
;analogClock.c,132 :: 		}
	GOTO        L_main0
;analogClock.c,133 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
