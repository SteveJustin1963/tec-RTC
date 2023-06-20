# tec-RTC, RTC for the tec1

https://www.facebook.com/groups/623556744820045/search/?q=RTC
  

- DS1307
- 
## rtc.asm
 https://github.com/Kris-Sekula/CA80/blob/master/RTC/RTC_0x2000_0x2300_v1.4.asm

 code written for CA80 system. It appears to be related to interfacing with a real-time clock (RTC) through the I2C protocol.

Here's a breakdown of the main sections and their functionalities:

1. Initialization:
   - The program sets up some equates for memory addresses and I/O ports.
   - It defines the starting address for the program.

2. GET_RTC:
   - This section is a procedure to copy the time from the hardware RTC to the software RTC in the CA80 system.
   - It initializes the bus, sets the address counter, starts I2C communication, reads the time data from the RTC, and stores it in memory.
   - It increments the memory pointer to store subsequent time data.

3. SAVETIME:
   - This section is a procedure to save the current software RTC to the hardware RTC.
   - It sets up the I/O ports, reads the time data from memory, and writes it to the RTC.

4. Helper Subroutines:
   - There are several subroutines in the code that perform specific tasks such as delay, I2C communication, and setting/clearing I/O lines.
   - These subroutines handle tasks like generating clock pulses, sending/receiving data over I2C, and controlling the state of SDA and SCL lines.

The provided code focuses on the communication between the CA80 system and an external RTC using the I2C protocol. It reads the current time from the RTC and stores it in memory, and also allows for saving the software RTC to the hardware RTC. Other parts of the code might be related to display control and clearing the display.

## step-by-step breakdown of the code:

1. Initialization:
   a. Set the starting address for the program (ORG 2000H).
   b. Define memory equates for stack pointer (TOS), show clock system procedure (M0), and I/O ports for the 8255 chip (PIO_A, PIO_B, PIO_C, PIO_M).
   c. Define constants for SCL_bit and SDA_bit.

2. GET_RTC:
   a. Load the stack pointer (SP) with the TOS value.
   b. Load register A with the value 092h.
   c. Output the value of A to the PIO_M port to configure the I/O ports.
   d. Label: GETTIME
      - Load register HL with the memory address 0FFEDh.
      - Call the "stop" subroutine to initiate the I2C bus.
      - Call the "WAIT_4" subroutine to introduce a delay.
      - Call the "set_addr" subroutine to set the address counter of the I2C device to 00h.
      - Call the "start_i2c" subroutine to start the I2C communication.
      - Load register A with the value 0D1h (command to read the current address of the RTC).
      - Call the "putbyte" subroutine to send the byte over I2C.
      - Call the "get_ack" subroutine to receive the acknowledgment from the RTC.
      - Call the "getbyte" subroutine to read the seconds data from the RTC and store it in memory at the location pointed to by HL.
      - Increment register HL.
      - Call the "send_ack" subroutine to send an acknowledgment to the RTC.
      - Call the "getbyte" subroutine to read the minutes data from the RTC and store it in memory.
      - Increment register HL.

3. The same process is repeated to get the hours, date, month, and year from the RTC and store them in memory, with each value being stored at the location pointed to by HL and HL being incremented after each operation.

4. SAVETIME:
   a. Set up the I/O ports by loading register A with the value 092h and outputting it to the PIO_M port.
   b. Load register HL with the memory address 0FFEDh.
   c. Call the "stop" subroutine to initiate the I2C bus.
   d. Call the "set_addr" subroutine to set the address counter of the I2C device to 00h.
   e. Load register A with the seconds value from memory and call the "putbyte" subroutine to send it to the RTC.
   f. Call the "get_ack" subroutine to receive the acknowledgment from the RTC.
   g. Repeat the process for minutes, hours, day, month, and year values, sending them to the RTC and receiving acknowledgments.
   h. Call the "stop" subroutine to end the I2C communication.
   i. Call the "rst 30h" instruction to perform a software reset.

5. Helper Subroutines:
   - WAIT_4: This subroutine introduces a delay by decrementing the DE register and checking if it is zero.
   - set_addr: This subroutine sets the I2C address counter and sends a read command to the RTC.
   - get_ack: This subroutine waits for and receives the acknowledgment from the I2C slave.
   - send_ack: This subroutine sends an acknowledgment signal on the I2C bus.
   - send_noack: This subroutine sends a "no acknowledge" (NAK) signal on the I2C bus.
   - getbyte: This subroutine reads 8 bits from the

 I2C bus and returns the received byte.
   - putbyte: This subroutine sends a byte from register A to the I2C bus.
   - sclclk: This subroutine generates clock pulses on the SCL line.
   - stop: This subroutine generates the stop sequence on the I2C bus.
   - Other subroutines handle setting and clearing the SDA and SCL lines during I2C communication.

6. The code also includes other sections and comments that provide additional information about the code.
