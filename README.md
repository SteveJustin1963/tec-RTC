# DS1307 for the TEC-1
The DS1307 is a versatile and reliable chip for timekeeping applications, and its simplicity makes it popular in embedded systems and microcontroller applications to keep track of time and date information. It operates using an I2C interface and provides a way to maintain timekeeping even when the main system power is off, thanks to its battery backup feature. Here's an overview of its key features and functionalities:

### Key Features of the DS1307
1. **Timekeeping**:
   - The DS1307 can keep track of seconds, minutes, hours, day, date, month, and year, including leap year compensation (valid up to the year 2100).
   - It uses a 24-hour or 12-hour format with an AM/PM indicator.

2. **I2C Interface**:
   - The DS1307 communicates with microcontrollers using the I2C protocol, a two-wire interface (SDA for data and SCL for the clock).
   - The I2C address for the DS1307 is `0x68`, which is used to communicate with the RTC module.

3. **Battery Backup**:
   - The DS1307 has a pin for an external battery (typically a 3V coin cell) that allows it to keep time even when the main system power is off.
   - The clock continues to run as long as the battery is connected, making it suitable for timekeeping even during power loss.

4. **Square Wave Output**:
   - The DS1307 includes an output pin that can be configured to generate a square wave signal at frequencies of 1 Hz, 4.096 kHz, 8.192 kHz, or 32.768 kHz.

5. **RAM**:
   - It includes 56 bytes of non-volatile RAM that can be used for storing small amounts of data that need to persist through power cycles.

### DS1307 Registers
The DS1307 has a series of registers to store time, date, control settings, and RAM data:
- **Time Registers**: Store seconds, minutes, hours, day of the week, date, month, and year. These are in BCD (Binary Coded Decimal) format.
- **Control Register**: Used to configure the square wave output frequency or disable it.
- **RAM Registers**: Accessible via the I2C interface, allowing the user to store additional data.

### Common Uses
- **Clock and Calendar Functionality**: Often used in clocks, data loggers, and applications that require time stamps.
- **Alarms and Event Triggers**: Combined with a microcontroller, it can trigger events based on specific time and date settings.
- **Low-Power Applications**: Suitable for devices that need to maintain accurate timekeeping with minimal power consumption.

### Example I2C Communication with the DS1307
The microcontroller typically communicates with the DS1307 via I2C to:
- **Read**: The time and date information by accessing the appropriate registers.
- **Write**: The initial time and date setup or to modify timekeeping settings.

### Sample Pseudocode for Interfacing with DS1307
1. **Initialize the I2C bus**.
2. **Set the DS1307 time** (only if the RTC is not yet set):
   - Write to the time registers (hours, minutes, seconds, etc.) using I2C.
3. **Read the time**:
   - Access the time registers to retrieve and decode the current time and date.
4. **Configure the square wave output** (if needed):
   - Write the appropriate value to the control register.





### Ref
- https://www.facebook.com/groups/623556744820045/search/?q=RTC
- we need i2c to control it https://github.com/SteveJustin1963/tec-I2C-SPI
  


