#!/usr/bin/env bash

echo
echo 'We are first going to update and upgrade the system'
echo
apt-get update
apt-get upgrade -y

echo
echo 'Now installing arduino-cli'
echo
sudo -u arduino curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh

echo
echo 'Now adding /home/arduino/bin to PATH'
echo
echo '' >> /home/arduino/.bashrc
echo 'export PATH=$PATH:/home/arduino/bin' >> /home/arduino/.bashrc

echo
echo 'Setting up config file for arduino-cli'
echo
sudo -u arduino /home/arduino/bin/arduino-cli config init

echo
echo 'Setting up arduino and related folders'
echo
sudo -u arduino mkdir /home/arduino/arduino/
sudo -u arduino mkdir /home/arduino/arduino/temp
sudo -u arduino mkdir /home/arduino/arduino/sketches
sudo -u arduino mkdir /home/arduino/arduino/sketches/blink

echo
echo 'Setting up basic serial monitor python script'
echo
sudo -u arduino cat << EOF > /home/arduino/arduino/python_serial_monitor.py
#!/usr/bin/env python3
import serial

if __name__ == '__main__':
    
    ser = serial.Serial('/dev/ttyACM0', 115200, timeout=1)
    
    ser.reset_input_buffer()
    
    while True:
        if ser.in_waiting > 0:
            line = ser.readline().decode('utf-8').rstrip()
            
            print(line)
EOF

echo
echo 'Setting up basic blink sketch'
echo
sudo -u arduino cat << EOF > /home/arduino/arduino/sketches/blink/blink.ino
void setup(){
    pinMode(LED_BUILTIN, OUTPUT);
    Serial.begin(115200);
}

void loop(){
    digitalWrite(LED_BUILTIN, HIGH);
    delay(1000);

    digitalWrite(LED_BUILTIN, LOW);
    delay(1000);

    Serial.print("Cycle complete: ");
    Serial.println(millis());
}
EOF

echo
echo 'Setting up avr boards'
echo
sudo -u arduino /home/arduino/bin/arduino-cli core update-index
sudo -u arduino /home/arduino/bin/arduino-cli core install arduino:avr

echo
echo 'First sketch compilation'
echo
sudo -u arduino /home/arduino/bin/arduino-cli compile -b arduino:avr:uno /home/arduino/arduino/sketches/blink/blink.ino

echo
echo 'Rebooting in 3 seconds...'
echo
sleep 3
reboot