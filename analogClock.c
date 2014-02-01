/*
        Some header for super duper project
        
        Pin assignments go here
        C2 & C3 are PWM outputs 1 and 2, respectively
        
*/

unsigned short current_duty, old_duty, current_duty1, old_duty1;

int dutyArray[] = {12,21,32,43,53};
int dutyArrayInd = 0;

int sec;
int min1;
int hr;
int day;                              //day of the month
int wDay;                             //day of the week
int month;
int year;

unsigned short readRTC(unsigned short address){

  unsigned short r_data;
  
  I2C1_Start();
  I2C1_Wr(0xD0);                      //address 0x68 followed by direction bit (0 for write, 1 for read) 0x68 followed by 0 --> 0xD0
  I2C1_Wr(address);
  I2C1_Repeated_Start();
  I2C1_Wr(0xD1);                      //0x68 followed by 1 --> 0xD1
  r_data=I2C1_Rd(0);
  I2C1_Stop();
  return(r_data);
}


void writeRTC(unsigned short address,unsigned short w_data){

  I2C1_Start();                       // issue I2C start signal
  I2C1_Wr(0xD0);                      // send byte via I2C (device address + W)
  I2C1_Wr(address);                   // send byte (address of DS1307 location)
  I2C1_Wr(w_data);                    // send data (data to be written)
  I2C1_Stop();                        // issue I2C stop signal
}



void initMain() {

  ANSELA = 0;                         // Configure AN pins as digital
  ANSELB = 0;
  ANSELC = 0;

  C1ON_bit = 0;                       // To turn off comparators
  ADCON1 = 0x06;                      // To turn off ADCs

  PORTA = 255;
  TRISA = 255;                        // configure PORTA pins as input
  LATC  = 0;                          // set PORTC to 0
  TRISC = 0;                          // designate PORTC pins as output
  PWM1_Init(5000);                    // initialize PWM1 module at 5KHz
  PWM2_Init(5000);                    // initialize PWM2 module at 5KHz
  I2C1_Init(100000);                  // initialize I2C
  
  // bit7 is control register, 0x10 = 1Hz, 11 = 4.096kHz, 12 = 8.192kHz, 13 = 32.768kHz, 00 = disabled
  writeRTC(7, 0x10);                  //initialize 1PPS output
  
}


void main() {

  initMain();                         // start services
  
  current_duty  = 0;                  // initial value for current_duty
  current_duty1 = 0;                  // initial value for current_duty1

  PWM1_Start();                       // start PWM1
  PWM2_Start();                       // start PWM2
  PWM1_Set_Duty(current_duty);        // Set current duty for PWM1
  PWM2_Set_Duty(current_duty1);       // Set current duty for PWM2

  while (1) {                         // endless loop
  
  sec = readRTC(0);
  min1 = readRTC(1);
  hr = readRTC(2);
  wDay = readRTC(3);
  day = readRTC(4);
  month = readRTC(5);
  year = readRTC(6);
  
  /////////////////////////////////////////////////////////////////////////////
  // TO DO:
  // - write routine for checking buttons and setting time
  // - need to implement debounce routine, big time
  // - need to have accurate array of PWM output values for meter positions
  //
  // - writeRTC(0, sec);              //resets seconds
  // - writeRTC(1, min1);             //set minutes
  // - writeRTC(2, hr);               //set hour
  // - writeRTC(4, day);              //set day
  // - writeRTC(5, month);            //set month
  // - writeRTC(6, year);             //set year

  
  if (RA0_bit) {                      // button on RA0 pressed
     Delay_ms(40);
     current_duty++;                  // increment current_duty
     PWM1_Set_Duty(current_duty);
  }

  if (RA1_bit) {                      // button on RA1 pressed
     Delay_ms(40);
     current_duty--;                  // decrement current_duty
     PWM1_Set_Duty(current_duty);
  }

  if (RA2_bit) {                      // button on RA2 pressed
     Delay_ms(40);
     dutyArrayInd++;                  // increment current_duty1
     PWM2_Set_Duty(dutyArray[dutyArrayInd]);
  }

  if (RA3_bit) {                      // button on RA3 pressed
     Delay_ms(40);
     dutyArrayInd--;                  // decrement current_duty1
     PWM2_Set_Duty(dutyArray[dutyArrayInd]);
  }

    Delay_ms(10);                     // generic wait
  }
}