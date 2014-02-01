#line 1 "T:/Documents/mikroC/Projects/analogClock/analogClock.c"
#line 9 "T:/Documents/mikroC/Projects/analogClock/analogClock.c"
unsigned short current_duty, old_duty, current_duty1, old_duty1;

int dutyArray[] = {12,21,32,43,53};
int dutyArrayInd = 0;

int sec;
int min1;
int hr;
int day;
int wDay;
int month;
int year;

unsigned short readRTC(unsigned short address){

 unsigned short r_data;

 I2C1_Start();
 I2C1_Wr(0xD0);
 I2C1_Wr(address);
 I2C1_Repeated_Start();
 I2C1_Wr(0xD1);
 r_data=I2C1_Rd(0);
 I2C1_Stop();
 return(r_data);
}


void writeRTC(unsigned short address,unsigned short w_data){

 I2C1_Start();
 I2C1_Wr(0xD0);
 I2C1_Wr(address);
 I2C1_Wr(w_data);
 I2C1_Stop();
}



void initMain() {

 ANSELA = 0;
 ANSELB = 0;
 ANSELC = 0;

 C1ON_bit = 0;
 ADCON1 = 0x06;

 PORTA = 255;
 TRISA = 255;
 LATC = 0;
 TRISC = 0;
 PWM1_Init(5000);
 PWM2_Init(5000);
 I2C1_Init(100000);


 writeRTC(7, 0x10);

}


void main() {

 initMain();

 current_duty = 0;
 current_duty1 = 0;

 PWM1_Start();
 PWM2_Start();
 PWM1_Set_Duty(current_duty);
 PWM2_Set_Duty(current_duty1);

 while (1) {

 sec = readRTC(0);
 min1 = readRTC(1);
 hr = readRTC(2);
 wDay = readRTC(3);
 day = readRTC(4);
 month = readRTC(5);
 year = readRTC(6);
#line 107 "T:/Documents/mikroC/Projects/analogClock/analogClock.c"
 if (RA0_bit) {
 Delay_ms(40);
 current_duty++;
 PWM1_Set_Duty(current_duty);
 }

 if (RA1_bit) {
 Delay_ms(40);
 current_duty--;
 PWM1_Set_Duty(current_duty);
 }

 if (RA2_bit) {
 Delay_ms(40);
 dutyArrayInd++;
 PWM2_Set_Duty(dutyArray[dutyArrayInd]);
 }

 if (RA3_bit) {
 Delay_ms(40);
 dutyArrayInd--;
 PWM2_Set_Duty(dutyArray[dutyArrayInd]);
 }

 Delay_ms(10);
 }
}
