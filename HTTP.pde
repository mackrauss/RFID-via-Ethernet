// function to send the Http request 
// http://www.glacialwanderer.com/hobbyrobotics/?p=15
boolean httpRequest()
{
  //  boolean requestSent = false;

  // we mix the tag (12 chars) with the board number (32 chars) to obscure the data a bit
  // TbTbTbTbTbTbTbTbTbTbTbTbbbbbbbbbbbbbbbbbbbbb
  // the array is on char longer and we add a terminating zero
  char reqData[45];
  sprintf(reqData, "%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c",
  tagToSend[0], serNo[0], tagToSend[1], serNo[1], tagToSend[2], serNo[2], tagToSend[3], serNo[3],
  tagToSend[4], serNo[4], tagToSend[5], serNo[5], tagToSend[6], serNo[6], tagToSend[7], serNo[7],
  tagToSend[8], serNo[8], tagToSend[9], serNo[9], tagToSend[10], serNo[10] , tagToSend[11], serNo[11],
  serNo[12], serNo[13], serNo[14], serNo[15], serNo[16], serNo[17], serNo[18], serNo[19], serNo[20],
  serNo[21], serNo[22], serNo[23], serNo[24], serNo[25], serNo[26], serNo[27], serNo[28], serNo[29],
  serNo[30], serNo[31], '\0');

  // create GET line of HTTP request
  String getRequestFull = "GET /arduino.php?data=";
  getRequestFull += reqData;
  getRequestFull += " HTTP/1.1";

  // create HOST part of HTTP request
  String hostPart = "HOST: ";
  hostPart += hostName;

  // if connected to server send request (HTTP GET)
  if (client.connected() || client.connect()) {
    //digitalWrite(blueLED, HIGH);
    // debugging
    Serial.println("Connected -- send GET request to server");
    Serial.println(getRequestFull);
    Serial.println(hostPart);
    // debugging end
    client.println(getRequestFull);
    client.println(hostPart);
    client.println();
    //digitalWrite(blueLED, LOW);
    return true;
  }
  // connection error 
  else {
    Serial.println("... no connection so can't send GET request");
    Serial.flush();
    lightLED(redLED, 1000);
    return false;
  }
}

void readHttpResponse () {
  //Serial.println("Read the server and go on with life");
  //Serial.println("");

  String readString = "";
  int cutOff = 0;

  while (client.available()) {
    char c = client.read();
    //Serial.print(c);
    if (cutOff > 230) {
      readString += c;
    }
    cutOff++;
  }
  Serial.println(readString);  
  /*int msgRegUser = readString.indexOf("message=RegisteredUser");
  int msgUnRegUser = readString.indexOf("message=UnregisteredUser");
  int msgNewTag = readString.indexOf("message=NewTag");*/
  
  // now we can match what is what
  // if index is not -1 we found the message and can light the corresponding LEDs
  if (-1 != readString.indexOf("message=RegisteredUser")) {
    Serial.println("Registered User");
    // registered: light GREEN for a while
    lightLED(greenLED, 1250);
    /*delay(250);
    lightLED(greenLED, 1250);
    delay(250);
    lightLED(greenLED, 1250);*/
  }
  else if (-1 != readString.indexOf("message=UnregisteredUser")) {
    Serial.println("Un-Registered User");
    // unregistered: blink 3 RED for a couple time
    lightLED(redLED, 1250);
    /*delay(250);
    lightLED(redLED, 1250);
    delay(250);
    lightLED(redLED, 1250);*/
  }
  else if (-1 != readString.indexOf("message=NewTag")) {
    Serial.println("New Tag");
    // new Tag: blink BLUE (??) for a while
    lightLED(blueLED, 1250);
    /*delay(250);
    lightLED(blueLED, 1250);
    delay(250);
    lightLED(blueLED, 1250);*/
  }
  

  // Disconnect from the server
  client.flush();
  client.stop();
  delay(150);

  allowSendTag = false;
  readServerResponse = false;

  Serial.println("");
  Serial.println("Reading is hard ....");
}


