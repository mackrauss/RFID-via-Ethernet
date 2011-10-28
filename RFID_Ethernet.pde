// ==================================================================================
// License of this work 
// ==================================================================================
// This software is available under the MIT licence (http://www.opensource.org/licenses/mit-license.php)
// Copyright (c) 2011 -- Armin Krauss and Colin McCann
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software
// and associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
// OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// ==================================================================================
// Attribution
// ==================================================================================
// Copyright (C) 2011 Armin Krauss and Colin McCann
// with contributions, inspirations, and help of many people we know
// and people that made their great work available on the Internet.
// Just to name a few:
// Matt Ratto helped with the design, gave directions and instructions, and even
//      helped out with some code
// Georg Kaindl for this great EthernetDHCP library
// Mikal Hart for the amazing NewSoftSerial library
// Bildr.org for their inspiration (http://bildr.org/2011/02/rfid-arduino/)
// and again all the others we talked to and googled for their inspiration.
// And last but not least the whole Arduino team for their incredible platform xoxoxo

// PLEASE NOTE:
// If you feel like we missed to properly name you or attribute your work contact us
// and we will be happy to work with you in order to satisfy your needs!

// ==================================================================================
// ============= Libraries used =====================================================
// ==================================================================================
//  EthernetDHCP
//  Copyright (C) 2010 Georg Kaindl
//  http://gkaindl.com
//
//  This file is part of Arduino EthernetDHCP.
//
//  EthernetDHCP is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Lesser General Public License as
//  published by the Free Software Foundation, either version 3 of
//  the License, or (at your option) any later version.
//
//  EthernetDHCP is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public
//  License along with EthernetDHCP. If not, see
//  <http://www.gnu.org/licenses/>.
//

// Code example to use the RFID reader is from http://bildr.org/2011/02/rfid-arduino/
// under CC Attribution-Share Alike 3.0 Unported license (https://creativecommons.org/licenses/by-sa/3.0/)
// Modified by Matt R. 
// changed to NewSoftSerial library (license unknown)

// NewSoftSerial library by Mikal Hart (license unknown) http://arduiniana.org/libraries/newsoftserial/

// Sending data examples
// http://arduino.cc/en/Reference/ClientConstructor


// ==================================================================================
// ===================== Import needed libs  ========================================
// ==================================================================================
// Ethernet library header
#include <Ethernet.h>
// DHCP library header
#if defined(ARDUINO) && ARDUINO > 18
#include <SPI.h>
#endif
#include <EthernetDHCP.h>
// serial library that allows Serial on custom ports
#include <NewSoftSerial.h>
// ==================================================================================


// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// +++++++++++++++++++++ To be changed !!!  +++++++++++++++++++++++++++++++++++++++++
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// DHCP (true) or static IP (false) mode
// WARNING: If static IP mode set, please configure ip, gateway, and subnet below
boolean bDhcpMode = true;

// static IP address settings
byte ip[] = {
  192, 168, 0, 203};
byte gateway[] = {
  192, 168, 0, 1};
byte subnet[] = {
  255, 255, 255, 0};

// Serial number of board (32 characters long)
// If string is longer than 32 chars we ignore the excess chars
String serNo = "ca761232ed4211cebacd0123456784cc";

// http://eldaba.dyndns.info:8585/Tagon/Home/ProcessRFID?param=sdf

// IP address of server where we want to send data to
byte server[] = { 
  192, 168, 0, 101 }; // your server IP
int serverPort = 80; // the port your server is listening on
// hostname to be sent with server request
// Note: This should correspond with server ip above
String hostName = "host.name.org";

// mac address of the Ethernet shield - used in DHCP and static mode
// 6 Bytes in Hex notation
// change this if you want
byte mac[] = { 
  0xDE, 0xAD, 0xAE, 0xEF, 0xFE, 0xED };
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


// ==================================================================================
// ===================== nothing to change here =====================================
// ==================================================================================
// initialize Client class to send requests to server
Client client(server, serverPort);

// function to turn IP bytes into a string that can be printed for debugging
const char* ip_to_str(const uint8_t*);

// settings for RFID reader
int RFIDResetPin = 8;
char tagString[13];
char tagToSend[13];
boolean allowSendTag = false;
boolean readServerResponse = false;
NewSoftSerial mySerial(2, 3);
int blueLED = 4;
int greenLED = 5;
int redLED = 6;

// ==================================================================================


void setup()
{
  Serial.begin(9600);

  /*pinMode(ethernetResetPin, OUTPUT);        //ADDED BY COLIN to allow reset of Ethernet shield
  digitalWrite(ethernetResetPin, LOW);
  delay(500);
  digitalWrite(ethernetResetPin, HIGH);*/

  // Initiate a DHCP session. The argument is the MAC (hardware) address that
  // you want your Ethernet shield to use. The second argument enables polling
  // mode, which means that this call will not block like in the
  // SynchronousDHCP example, but will return immediately.
  // Within your loop(), you can then poll the DHCP library for its status,
  // finding out its state, so that you can tell when a lease has been
  // obtained. You can even find out when the library is in the process of
  // renewing your lease.
  if (bDhcpMode) {
    EthernetDHCP.begin(mac, 1);
  }
  else {
    // Initiate the static Ethernet connection
    Ethernet.begin(mac, ip, gateway, subnet);

    // some sanity printout at the beginning
    //Serial.println(ip_to_str(ip));
    //Serial.println(ip_to_str(gateway));
    //Serial.println(ip_to_str(subnet));
  }

  // Setup of RFID
  mySerial.begin(9600);

  pinMode(RFIDResetPin, OUTPUT);
  digitalWrite(RFIDResetPin, HIGH);

  //ONLY NEEDED IF CONTROLLING THESE PINS - EG. LEDs
  pinMode(blueLED, OUTPUT);
  pinMode(greenLED, OUTPUT);
  pinMode(redLED, OUTPUT);
  
  /*lightLED(blueLED, 500);
  delay(50);
  lightLED(greenLED, 500);
  delay(50);
  lightLED(redLED, 500);*/
}

void loop()
{
  // DHCP mode
  if (bDhcpMode) {
    // print out current programMode once
    /*if (printProgramMode) {
     Serial.println("Running with programMode " + (String)programMode);
     printProgramMode = false;
     }*/

    static DhcpState prevState = DhcpStateNone;
    static unsigned long prevTime = 0;

    // poll() queries the DHCP library for its current state (all possible values
    // are shown in the switch statement below). This way, you can find out if a
    // lease has been obtained or is in the process of being renewed, without
    // blocking your sketch. Therefore, you could display an error message or
    // something if a lease cannot be obtained within reasonable time.
    // Also, poll() will actually run the DHCP module, just like maintain(), so
    // you should call either of these two methods at least once within your
    // loop() section, or you risk losing your DHCP lease when it expires!
    DhcpState state = EthernetDHCP.poll();

    if (prevState != state) {
      Serial.println();

      switch (state) {
      case DhcpStateDiscovering:
        Serial.print("Discovering servers.");
        break;
      case DhcpStateRequesting:
        Serial.print("Requesting lease.");
        break;
      case DhcpStateRenewing:
        Serial.print("Renewing lease.");
        break;
      case DhcpStateLeased: 
        {
          Serial.println("Obtained lease!");

          // Since we're here, it means that we now have a DHCP lease, so we
          // print out some information.
          const byte* ipAddr = EthernetDHCP.ipAddress();
          const byte* gatewayAddr = EthernetDHCP.gatewayIpAddress();
          const byte* dnsAddr = EthernetDHCP.dnsIpAddress();

          Serial.print("My IP address is ");
          Serial.println(ip_to_str(ipAddr));

          Serial.print("Gateway IP address is ");
          Serial.println(ip_to_str(gatewayAddr));

          Serial.print("DNS IP address is ");
          Serial.println(ip_to_str(dnsAddr));

          Serial.println();
          break;
        }
      }
    } 
    else if (state != DhcpStateLeased && millis() - prevTime > 300) {
      prevTime = millis();
      Serial.print('.'); 
    }

    prevState = state;


    if (allowSendTag && DhcpStateLeased && !readServerResponse) {
      // make a GET request with the right key value pair to transfer the RFID ID read
      if (httpRequest()) {
        // reset the state and many other things (paranoia)
        clearTag(tagString);
        clearTag(tagToSend);
        resetReader();
        Serial.flush();
        mySerial.flush();
        readServerResponse = true;
      }
    }

    // try here to read from the server
    if (readServerResponse && client.available()) {
      readHttpResponse();
    }

    // if we are not sending a tag we try to read
    // from the RFID reader
    if (!allowSendTag) {
      readRfid();
    }
  }
  // Fixed IP mode
  else {
    if (allowSendTag && !readServerResponse) {
      // make a GET request with the right key value pair to transfer the RFID ID read
      if (httpRequest()) {
        // reset the state and many other things (paranoia)
        clearTag(tagString);
        clearTag(tagToSend);
        resetReader();
        Serial.flush();
        mySerial.flush();
        readServerResponse = true;
      }
    }
    
    // try here to read from the server
    if (readServerResponse && client.available()) {
      readHttpResponse();
    }

    // if we are not sending a tag we try to read
    // from the RFID reader
    if (!allowSendTag) {
      readRfid();
    }
  }
}


// Just a utility function to nicely format an IP address.
const char* ip_to_str(const uint8_t* ipAddr)
{
  static char buf[16];
  sprintf(buf, "%d.%d.%d.%d\0", ipAddr[0], ipAddr[1], ipAddr[2], ipAddr[3]);
  return buf;
}






