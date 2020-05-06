int button1 = 2;
int button2 = 4;
int button3 = 8;
int button4 = 12;
int button = 0;

void setup() {
  pinMode(button1, INPUT);
  pinMode(button2, INPUT);
  pinMode(button3, INPUT);
  pinMode(button4, INPUT);
  Serial.begin(9600);
}

void loop() {
  button = 0;
  
  if(digitalRead(button1) == HIGH) {
    button = 1;
    while(digitalRead(button1) == HIGH) {
    }
  }
  if(digitalRead(button2) == HIGH) {
    button = 2;
    while(digitalRead(button2) == HIGH) {
    }
  }
  if(digitalRead(button3) == HIGH) {
    button = 3;
    while(digitalRead(button3) == HIGH) {
    }
  }
  if(digitalRead(button4) == HIGH) {
    button = 4;
    while(digitalRead(button4) == HIGH) {
    }
  }
  
  if(button != 0) {
    Serial.println(button);
    delay(500);
  }
}
