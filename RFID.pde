// RFID reading function
// we want to read an RFID tag, store the tag information, and set a flag to avoid
// another read until the data is sent and the flag is reset 
void readRfid () {
  int index = 0;
  boolean reading = false;

  while(mySerial.available()){
    //Serial.println("serial while loop");
    int readByte = mySerial.read(); //read next available byte

    if(readByte == 2) reading = true; //begining of tag
    if(readByte == 3) reading = false; //end of tag

    if(reading && readByte != 2 && readByte != 10 && readByte != 13){
      //store the tag
      tagString[index] = readByte;
      index ++;
    }
  }

  //Check if it is a match
  if (checkTag(tagString) && !allowSendTag) {
    if (copyTag (tagString, tagToSend)) {
      allowSendTag = true;
    }
  }
  clearTag(tagString); //Clear the char of all value
  if (!allowSendTag) resetReader();
}


// RFID function
boolean checkTag(char tag[]){
  ///////////////////////////////////
  //Check the read tag against known tags
  ///////////////////////////////////

  if(strlen(tag) != 12) {
    return false; //empty, no need to contunue
  }
  
  // light blue LED as an indicator
  lightLED(blueLED, 250);

  /*if(compareTag(tag, tag1)){ // if matched tag1, do this
    lightLED(4);

  }
  else if(compareTag(tag, tag2)){ //if matched tag2, do this
    lightLED(5);

  }
  else{
    Serial.println(tag); //read out any unknown tag
  }*/
  
  return true;
}

void lightLED(int pin, int delayTime){
  ///////////////////////////////////
  //Turn on LED on pin "pin" for 250ms
  ///////////////////////////////////
  //Serial.println(pin);

  digitalWrite(pin, HIGH);
  delay(delayTime);
  digitalWrite(pin, LOW);
}

void resetReader(){
  ///////////////////////////////////
  //Reset the RFID reader to read again.
  ///////////////////////////////////
  digitalWrite(RFIDResetPin, LOW);
  digitalWrite(RFIDResetPin, HIGH);
  delay(150);
}

void clearTag(char one[]){
  ///////////////////////////////////
  //clear the char array by filling with null - ASCII 0
  //Will think same tag has been read otherwise
  ///////////////////////////////////
  for(int i = 0; i < strlen(one); i++){
    one[i] = 0;
  }
}

/*boolean compareTag(char one[], char two[]){
  ///////////////////////////////////
  //compare two value to see if same,
  //strcmp not working 100% so we do this
  ///////////////////////////////////

  if(strlen(one) == 0) return false; //empty

  for(int i = 0; i < 12; i++){
    if(one[i] != two[i]) return false;
  }

  return true; //no mismatches
}*/

boolean copyTag(char one[], char two[]){
  ///////////////////////////////////
  //copy content of arry one into array two
  ///////////////////////////////////

  if(strlen(one) == 0) return false; //one is empty, nothing to copy

  for(int i = 0; i < 12; i++){
    two [i] = one[i];
  }

  return true;
}


