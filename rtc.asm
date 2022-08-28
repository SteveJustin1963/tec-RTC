;   https://github.com/Kris-Sekula/CA80/blob/master/RTC/RTC_0x2000_0x2300_v1.4.asm


ORG 2000H	; first free address for the 27C128 EPROM (base 27C64 EPROM ends on 1FFFH)

TOS	equ 0FF8Dh	; user STACK
M0  equ 02c9h	; Show clock CA 80 system procedure

PIO_A	equ	0E0h		; CA80 user 8255 base address 	  (port A)
PIO_B	equ	0E1h		; CA80 user 8255 base address + 1 (port B)
PIO_C	equ	0E2h		; CA80 user 8255 base address + 2 (fport C)
PIO_M	equ	0E3h		; CA80 user 8255 control register

SCL_bit	equ	4h		; SCL port PC.4
SDA_bit	equ	0h		; SDA port PC.0


;
; Procedure to copy time from Hardware RTC to software RTC in CA80 (seconds are maintained in RAM starting from address 0xFFEDh - sec, 0xFFEEh - min, 0xFFEFh etc.)
;
; When finished, the procedure will jump straight to the CA80 Display Time program *E[0]

;The code is synchronizing the CA80 time with the RTC. It is first initiating the bus, 
;then setting the address counter to 00h, starting the i2c, putting the byte 0D1h, getting the ACK, 
;getting the byte, putting the byte in (hl), 
;sending the ACK, getting the byte, putting the byte in (hl), and then increments hl.


GET_RTC:

	LD	SP,TOS			; 

	ld A,092h 			; change port C(hi) and C(low) to output, port B to output
	out (PIO_M),A		; sorry it will reset the PIO_C to 00H

GETTIME: ; Synch CA80 time with RTC

	ld hl,0ffedh

	call stop		; initiate bus
	call WAIT_4
	
	call set_addr		; Set address counter to 00h
	call start_i2c
	ld a,0D1h			; Read current address A1 for EEPROM D0 for RTC
	call putbyte		
	call get_ack		; now get first data byte back from slave, SDA-in
	call getbyte		; get seconds data should be in A
	ld (hl),a
	inc hl
	call send_ack ;
	call getbyte		; get minutes
    ld (hl),a
    inc hl
    
    
    
    
    ; This code is responsible for getting the current date and time from a server and storing it in memory. 
   ; The "call send_ack" command sends a signal to the server indicating that the client is ready to receive data. 
   ; The "call getbyte" command gets a single byte of data from the server, which is then stored 
   ; in memory at the location pointed to by HL. The "ld (hl),
   ; a" command loads the byte into the location specified by HL. 
   ; The "inc hl" command increments the HL register, which points to the next byte in memory. 
   ; This process is repeated until all three bytes (hours, date, and month) have been received and stored in memory.
    
    call send_ack
	call getbyte		; get hours
	ld (hl),a
	inc hl
	call send_ack
	call getbyte		; get date
	ld (hl),a
	inc hl
	call send_ack
	call getbyte		; get month
	ld (hl),a
	inc hl
	call send_ack
	
	
	
	
; The code gets a byte (the year) and loads it into the memory location pointed to by HL. 
;;It then increments HL (so it points to the next byte) and calls send_noack. 
;This sends the byte without sending an acknowledgement. 
;;The code then calls stop, which halts the processor.
;RST 10h is a instruction to clear the display. 
;defb 80h is a directive to define a byte with the value 80h. 
;JP M0 is an instruction to jump to the label M0.	
	
	
    call getbyte            ; get year
    ld (hl),a
    inc hl

	call send_noack
	call stop
	
	RST 10h			; clear display procedure
	defb 80h		; all digits
	
	JP M0			; show time procedure  *E[0]

;
;
; 
; This code saves the software RTC to the HW RTC. It starts by setting port C(hi) and C(low) to output and port B to output. 
;It then saves the seconds to EEPROM under address 00. 
;It does the same for the minutes, hours, day, month, and year. 
;Finally, it stops and resets.


	ORG 2100H  ; So I can remember the address for SAVETIME procedure
	
SAVETIME:	; save current software RTC to HW RTC procedure, call by: *E[G][2100]=

	ld A,092h 			; change port C(hi) and C(low) to output, port B to output
	out (PIO_M),A		; sorry it will reset the PIO_C to 00H

	ld hl,0ffedh		; RTC SEC position in CA80
	
	call stop			; initiate bus

	call set_addr
	ld a,(hl)			; save seconds to EEPROM under address 00
	call putbyte
	call get_ack
	
	ld A,092h
	out (PIO_M),A
	
	inc hl
	ld a,(hl)		; save minutes to EEPROM under address 01
	call putbyte
	call get_ack
	
	ld A,092h
	out (PIO_M),A
	
	inc hl
	ld a,(hl)		; save hours to EEPROM under address 02
	call putbyte
	call get_ack
	ld A,092h
	out (PIO_M),A

	inc hl
	ld a,(hl)		; save day to EEPROM
	call putbyte
	call get_ack
	
	ld A,092h
	out (PIO_M),A

	inc hl
	ld a,(hl)		; save month to EEPROM
	call putbyte
	call get_ack
	
	ld A,092h
	out (PIO_M),A
	
	inc hl
	ld a,(hl)
	call putbyte
	call get_ack
	
	ld A,092h
	out (PIO_M),A
	
	call stop
	rst 30h
	
;
;
;
;
;



; 
;This code delays for a certain amount of time. 
;First, it pushes the AF, BC, and DE registers onto the stack. 
;Then, it loads the DE register with the value 0400h. 
;Next, it decrements the DE register and checks if it is equal to zero. 
;If it is not, the code jumps back to the W40 label and repeats the process. 
;Once the DE register is equal to zero, the code pops the AF, BC, and DE registers off the stack and returns.

WAIT_4:	; delay
		push	AF
		push	BC
		push	DE
		ld	de,0400h
W40:	djnz W40
		dec de
		ld a,d
		or a
		jp	nz,W40
		pop	DE
		pop	BC
		pop	AF
		ret







; The code is sending a write command to an i2c device on address D0, and then reading from address 00h. 
;The purpose of the code is to set the address of the i2c device to 00h so that it can be read from.

set_addr:
					; Reset device address counter to 00h, for i2c device on address D0
	call start_i2c
	ld a,0D0h		; Write Command A0 for EEPROM D0 for RTC
	call putbyte	;
	call get_ack	;
	
	ld a,092h     	; SDA + SCL output
	out (PIO_M),A	;
	
	ld a,00h	; read from address 00h
	call putbyte
	call get_ack	

	ld a,092h       ; SDA + SCL output
	out (PIO_M),A   ;
	
	ret










; This code is checking for an acknowledgement from an I2C slave. SDA is set to input and SCL is set to output. 
;A clock pulse is generated and then SDA is read. 
;If SDA is low, then an acknowledgement was received. 
;If SDA is high, then either no acknowledgement was received or there was a timeout.

get_ack:	; Get ACK from i2c slave
    ld A,093h			; SDA - in, SCL - out 
	out (PIO_M),A		; SDA goes HI as its set to input,
	call sclset			; raised CLK, now expect "low" on SDA as the sign on ACK	
	ld A,(PIO_M)	 	; here read SDA and look for "LOW" = ACK, "HI" - NOACK or Timeout`
	call sclclr
	ret
	; ToDo - implement the ACK timeout, right now we blindly assume the ACK came in.




;The code sets the SDA and SCL lines to output and then sets the SCL line high before waiting and then setting it low again.

send_ack: ld a,092h	; SDA + SCL output
	out (PIO_M),A	;
	call sclset		; Clock SCL
	call sclclr
	ret



; The code is sending a NAK signal to the I2C bus. 
;A NAK is a "no acknowledge" signal, which is used to indicate to the master that the slave is not ready or does not understand the command. 
; The code is sending a NAK signal to the I2C bus. 
;A NAK is a "no acknowledge" signal, which is used to indicate to the master that the slave is not ready or does not understand the command.

send_noack:		; Send NAK (no ACK) to i2c bus (master keeps SDA HI on the 9th bit of data)
	ld a,092h     		
	out (PIO_M), A		
	call sdaset			; 	
	call sclset			; Clock SCL 
	call sclclr
	ret
	

; This code reads 8 bits from an i2c bus. 
;It starts by pushing the BC register onto the stack. 
;It then sets the SDA line to be an input and the SCL line to be an output. 
;It then calls the sclset function to set the clock line high. 
;It reads the SDA line to get the data bit and then stores it in the C register. 
;It then calls the sclclr function to set the clock line low. 
;Finally, it pops the BC register off the stack and returns.


getbyte:	; Read 8 bits from i2c bus
        push bc
		ld A,093h       		; SDA - in, SCL - out
		out (PIO_M),A   		;
		ld b,8
gb1:    call    sclset          ; Clock UP
		in A,(PIO_C)			; SDA (RX data bit) is in A.0
		rrca					; move RX data bit to CY
		rl      c              	; Shift CY into C
        call    sclclr          ; Clock DOWN
        djnz    gb1
        ld a,c             		; Return RX Byte in A
		pop bc
        ret





; The code sends a byte from the A register to the i2C bus. 
;It uses the push and pop commands to save and restore the contents of the BC register. 
;it then loads the A register into C and B, and sets B to 8. 
;It loops 8 times, shifting the bits in C and sending them to the i2C bus. 
;After the 8th iteration, it sets the SDA line high and restores the contents of BC.

putbyte: 	; Send byte from A to i2C bus
        push    bc
        ld      c,a             ;Shift register
        ld      b,8
pbks1:  sla     c               ;B[7] => CY
        call    sdaput          ; & so to SDA
        call    sclclk          ;Clock it
        djnz    pbks1
        call    sdaset          ;Leave SDA high, for ACK
        pop     bc
        ret




; This code is for the clock signal (SCL) and data signal (SDA) of the I2C bus.
;The clock signal is generated by toggling the SCL line from high to low.
;The data signal is set by copying the state of the carry flag (CY) to the SDA line, without changing the state of the SCL line.
;The stop sequence is generated by setting the SDA line high while the SCL line is high.


sclclk:         ;	"Clock" the SCL line Hi -> Lo
			call    sclset
			call    sclclr
			ret
sdaput:        ; CY state copied to SDA line, without changing SCL state
        in      a,(PIO_C)
		res     SDA_bit,a
        jr      nc,sdz
        set     SDA_bit,a
sdz:    out     (PIO_C),a
        ret

stop:           ; i2c STOP sequence, SDA goes HI while SCL is HI
        push    af
        call    sdaclr
        call    sclset
        call    sdaset
        pop     af
        ret




;The code is written in assembly language for the 8051 microcontroller. It starts with the SDA (serial data) line going LOW while
the SCL (serial clock) line is HIGH. This is accomplished by calling the sdaset and sclset subroutines. The sdaset subroutine sets 
the SDA line HIGH, while the sclset subroutine sets the SCL line HIGH. Next, the code calls the sdaclr and sclclr subroutines. 
These two subroutines are used to set the SDA and SCL lines LOW, respectively. 
Finally, the code calls the sdaset subroutine one last time to set the SDA line HIGH, and then returns. 
The sclset, sclclr, sdaset, and sdaclr subroutines are used to manipulate the state of the SCL and SDA lines 
without affecting the state of the other line. 
For example, the sclset subroutine sets the SCL line HIGH without changing the state of the SDA line. 
Each of these subroutines starts by reading the value of the PIO_C register into the A register. 
The PIO_C register controls the state of the I/O pins on the 8051 microcontroller. 
Next, the code sets or clears the SCL or SDA bit in the A register, depending on which subroutine is being executed. 
Finally, the code writes the new value of the A register back to the PIO_C register, which updates the state of the I/O pins.

start_i2c:          ; i2c START sequence, SDA goes LO while SCL is HI
			call	sdaset
			call    sclset
			call    sdaclr
			call    sclclr
			call    sdaset
			ret

sclset: ; SCL HI without changing SDA     	
        in      a,(PIO_C)
        set     SCL_bit,a
        out     (PIO_C),a
        ret

sclclr:  ; SCL LO without changing SDA       	
        in      a,(PIO_C)
        res     SCL_bit,a
        out     (PIO_C),a
        ret

sdaset:	; SDA HI without changing SCL
        in      a,(PIO_C)
        set     SDA_bit,a
        out     (PIO_C),a
        ret

sdaclr: ; SDA LO without changing SCL   	
        in      a,(PIO_C)
        res     SDA_bit,a
        out     (PIO_C),a
        ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;convert all the above to pseudo code


I2C START SEQUENCE
SDA = 1
SCL = 1
SDA = 0
SCL = 0
SDA = 1

I2C STOP SEQUENCE
SDA = 0
SCL = 1
SDA = 1
SCL = 0
SDA = 1
