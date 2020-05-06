int button1 = 2;
int button2 = 4;
int button3 = 8;
int button4 = 12;
int button = 0;

void setup() {
  //Declaring button pins for input
  pinMode(button1, INPUT); //E
  pinMode(button2, INPUT); //B
  pinMode(button3, INPUT); //P
  pinMode(button4, INPUT); //Do not know
  Serial.begin(9600);
}

//Loops continuously, when a button is pressed an integer 
//corresponding to its identity is output via serial
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
