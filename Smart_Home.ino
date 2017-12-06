/*
 * Smart Home system
 * control light and ac system throught wifi/internet
 * light could be control manually by IOS app 
 * or automatically by a light sensor
 * ac could be control by IOS app
*/
#include <Wire.h>
#include <Adafruit_Sensor.h>
#include "Adafruit_TSL2591.h"
#include "WString.h"
#include "WiFiEsp.h"
#include "DHT.h"
#include "string.h"
#define DHTPIN 2
#define DHTTYPE DHT11

// Emulate Serial1 on pins 6/7 if there's not hardware Serial
#ifndef HAVE_HWSERIAL1
#include "SoftwareSerial.h"
SoftwareSerial Serial1(6, 7); // RX, TX
#endif
//for light sensor
Adafruit_TSL2591 tsl = Adafruit_TSL2591(2591); // pass in a number for the sensor identifier (for your use later)

//online test
char ssid[] = "BLUFFING";            // your network SSID (name)
char pass[] = "apairofballsbeatseverything!";        // your network password

//local test
//char ssid[] = "Tianen";            // your network SSID (name)
//char pass[] = "jte19911106";        // your network password
int status = WL_IDLE_STATUS;     // the Wifi radio's status
int reqCount = 0;  
// number of requests received
//default light_level off
int light_level = 0;
int temp_set = 20;
//default ac off
int ac = 0;

//default mode is manual
//manual: mode=0
//auto: mode=1
int mode = 0;

int p=1;

//led light pins
int light_0 = 3;
int light_1 = 4;
int light_2 = 5;

// ac fan pins
int fan_A = 6;
int fan_B = 7;

// string buffer for http get
String readString;

//ac speed
byte speed = 150;

//esp web server port 80
WiFiEspServer server(80);

//DHT sensor for temperature and humidity
DHT dht(DHTPIN, DHTTYPE);

void setup()
{
  // initialize serial for debugging
  Serial.begin(9600);
  // initialize serial for ESP module
  Serial1.begin(115200);
  pinMode(light_0, OUTPUT);
  pinMode(light_1, OUTPUT);
  pinMode(light_2, OUTPUT);
  pinMode(fan_A,OUTPUT);
  pinMode(fan_B,OUTPUT);
  analogWrite(fan_A,LOW);
  analogWrite(fan_B,LOW);
  dht.begin();
  // initialize ESP module
  WiFi.init(&Serial1);
  configureSensor();
  // check for the presence of the shield
  if (WiFi.status() == WL_NO_SHIELD) {
    Serial.println("WiFi shield not present");
    // don't continue
    while (true);
  }

  // attempt to connect to WiFi network
  while ( status != WL_CONNECTED) {
    Serial.print("Attempting to connect to WPA SSID: ");
    Serial.println(ssid);
    // Connect to WPA/WPA2 network
    status = WiFi.begin(ssid, pass);
  }

  Serial.println("You're connected to the network");
  printWifiStatus();
  
  // start the web server on port 80
  server.begin();
}


void loop()
{

  // clear http get buffer
  readString = "";
  // humidity
    float h = dht.readHumidity();
  // Read temperature as Celsius (the default)
  float t = dht.readTemperature();
  // Read temperature as Fahrenheit (isFahrenheit = true)
  float f = dht.readTemperature(true);

  // Check if any reads failed and exit early (to try again).
  if (isnan(h) || isnan(t) || isnan(f)) {
    Serial.println("Failed to read from DHT sensor!");
    return;
  }
    // Compute heat index in Fahrenheit (the default)
  float hif = dht.computeHeatIndex(f, h);
  // Compute heat index in Celsius (isFahreheit = false)
  float hic = dht.computeHeatIndex(t, h, false);
  //Serial.print("Humidity: ");
  //Serial.print(h);
  //Serial.print(" %\t");
  //Serial.print("Temperature: ");
  //Serial.print(t);
  //Serial.print(" *C ");
  //Serial.print(f);
  //Serial.print(" *F\t");
  //Serial.print("Heat index: ");
  //Serial.print(hic);
  //Serial.print(" *C ");
  //Serial.print(hif);
 // Serial.println(" *F");

  //listen to incoming data from server
  WiFiEspClient client = server.available();
  if (client) {
    Serial.println("New client");
    // an http request ends with a blank line
    boolean currentLineIsBlank = true;
    while (client.connected()) {
      if (client.available()) {
        char c = client.read();
        if (readString.length() < 100) {

        //store characters to string 
            readString+=c; 
        } 
        //Serial.write(StrContains(c,"a0"));
        //Serial.print(c);
        // if you've gotten to the end of the line (received a newline
        // character) and the line is blank, the http request has ended,
        // so you can send a reply
        if (c == '\n' && currentLineIsBlank) {
            Serial.println(readString);
            if(strstr(readString.c_str(),"a0")!=NULL){
                ac=0;
                Serial.println("input_ac: 0");
            }else if(strstr(readString.c_str(),"a1")!=NULL){
                 ac=1;
                 Serial.println("input_ac: 1");
            }else {
                 Serial.println("input_ac: N/A");
             }
            if(strstr(readString.c_str(),"p0")!=NULL){
                p=0;
                Serial.println("No person in house");
            }else if(strstr(readString.c_str(),"p1")!=NULL){
                 p=1;
                 Serial.println("Some one in hose");
            }else {
                 Serial.println("No person input");
             }
            if(strstr(readString.c_str(),"m0")!=NULL){
                  mode=0;
                  Serial.println("input_mode: 0");
            }else if(strstr(readString.c_str(),"m1")!=NULL){
                  mode=1;
                 Serial.println("input_mode: 1");
            }else {
                 Serial.println("input_mode: N/A");
             }
            if(mode==1){
              Serial.println("ignore light setting since auto light is on.");
            }else if(strstr(readString.c_str(),"l0")!=NULL){
                light_level=0;
                Serial.println("input_light: 0");
            }else if(strstr(readString.c_str(),"l1")!=NULL){
                 light_level=1;
                 Serial.println("input_light: 1");
            }else if(strstr(readString.c_str(),"l2")!=NULL){
                 light_level=2;
                 Serial.println("input_light: 2");
            }else if(strstr(readString.c_str(),"l3")!=NULL){
                 light_level=3;
                 Serial.println("input_light: 3");
            }else {
                 Serial.println("input_light: N/A");
             }

          if(p==0&&mode==1){
            ac=0;
            light_level=0;   
          }
          Serial.println("Sending response");
          
          // send a standard json response header
          // use \r\n instead of many println statements to speedup data send
          client.println("HTTP/1.1 200 OK");
          client.println("Content-Type: application/json;charset=utf-8");
          client.println("Server: Arduino");
          client.println("Connnection: close");
          client.println();
            //"Refresh: 20\r\n"        // refresh the page automatically every 20 sec
            //"\r\n");


            //sending data
            client.print("{\"Temperature\":\"");
            client.print(t);
            client.print("\",");
            client.print("\"Humidity\":\"");
            client.print(h);
            client.print("\",");
            client.print("\"Light_Level\":\"");
            client.print(light_level);
            client.print("\",");
            client.print("\"AC\":\"");
            client.print(ac);
            client.print("\"}");
            client.print("\n");

            //check syntax in serial monitor
            Serial.print("{\"Temperature\":\"");
            Serial.print(t);
            Serial.print("\",");
            Serial.print("\"Humidity\":\"");
            Serial.print(h);
            Serial.print("\",");
            Serial.print("\"Light_Level\":\"");
            Serial.print(light_level);
            Serial.print("\",");
            Serial.print("\"AC\":\"");
            Serial.print(ac);
            Serial.print("\",");
            Serial.print("\"Light_Automation\":\"");
            Serial.print(mode);
            Serial.print("\"}");
            Serial.println();
            /*
          client.print("<!DOCTYPE HTML>\r\n"); 
          client.print("<html>\r\n");
          client.print("<h1>Hello World!</h1>\r\n");
          client.print("Requests received: ");
          client.print(++reqCount);
          client.print("<br>\r\n");
          client.print("Humidity: ");
          client.print(h);
          client.print(" %\t");
          client.print("Temperature: ");
          client.print(t);
          client.print(" *C ");
          client.print(f);
          client.print(" *F\t");
          client.print("<br>\r\n");
          client.print("</html>\r\n");
          */
          break;
        }
        if (c == '\n') {
          // you're starting a new line
          currentLineIsBlank = true;
        }
        else if (c != '\r') {
          // you've gotten a character on the current line
          currentLineIsBlank = false;
        }
      }
    }
    // give the web browser time to receive the data
    delay(10);
    // close the connection:
    client.stop();
    Serial.println("Client disconnected");
  }
    // light led
  if(mode==1&&p!=0){
      if(tsl.getLuminosity(TSL2591_VISIBLE)>=2000) {
          light_level=0; 
      }else if(tsl.getLuminosity(TSL2591_VISIBLE)>=1000){
          light_level=1;
      }else if(tsl.getLuminosity(TSL2591_VISIBLE)>=100){
          light_level=2;
      }else {
          light_level=3;
      }
      if(dht.readTemperature()>temp_set){
        ac=1;
      }else{
        ac=0;
      }
  }
  byte brightness;
  if(light_level==0){
    //brightness=0;
      digitalWrite(light_0, LOW);
      digitalWrite(light_1, LOW);
      digitalWrite(light_2, LOW);
      delay(100);  
  }else if(light_level==1){
    //brightness=90;
      digitalWrite(light_0, HIGH);
      digitalWrite(light_1, LOW);
      digitalWrite(light_2, LOW);
      delay(100);    
  }else if(light_level==2){
    //brightness=180;
      digitalWrite(light_0, HIGH);
      digitalWrite(light_1, HIGH);
      digitalWrite(light_2, LOW);
      delay(100);    
  }else if(light_level==3){
    //brightness=255;
      digitalWrite(light_0, HIGH);
      digitalWrite(light_1, HIGH);
      digitalWrite(light_2, HIGH);
      delay(100);   
  }
     //analogWrite(light_0, brightness);
  //AC fan
  if(ac==1){
    analogWrite(fan_A,speed);
    analogWrite(fan_B,0);
  }else{
    analogWrite(fan_A,LOW);
    analogWrite(fan_B, LOW);
  }
}


void printWifiStatus()
{
  // print the SSID of the network you're attached to
  Serial.print("SSID: ");
  Serial.println(WiFi.SSID());

  // print your WiFi shield's IP address
  IPAddress ip = WiFi.localIP();
  Serial.print("IP Address: ");
  Serial.println(ip);
  
  // print where to go in the browser
  Serial.println();
  Serial.print("To see this page in action, open a browser to http://");
  Serial.println(ip);
  Serial.println();
}

// searches for the string sfind in the string str
// returns 1 if string found
// returns 0 if string not found
char StrContains(char *str, char *sfind)
{
    char found = 0;
    char index = 0;
    char len;

    len = strlen(str);
    
    if (strlen(sfind) > len) {
        return 0;
    }
    while (index < len) {
        if (str[index] == sfind[found]) {
            found++;
            if (strlen(sfind) == found) {
                return 1;
            }
        }
        else {
            found = 0;
        }
        index++;
    }

    return 0;
}

void configureSensor(void)
{
  // You can change the gain on the fly, to adapt to brighter/dimmer light situations
  //tsl.setGain(TSL2591_GAIN_LOW);    // 1x gain (bright light)
  tsl.setGain(TSL2591_GAIN_MED);      // 25x gain
  // tsl.setGain(TSL2591_GAIN_HIGH);   // 428x gain
  
  // Changing the integration time gives you a longer time over which to sense light
  // longer timelines are slower, but are good in very low light situtations!
  //tsl.setTiming(TSL2591_INTEGRATIONTIME_100MS);  // shortest integration time (bright light)
   tsl.setTiming(TSL2591_INTEGRATIONTIME_200MS);
  // tsl.setTiming(TSL2591_INTEGRATIONTIME_300MS);
  // tsl.setTiming(TSL2591_INTEGRATIONTIME_400MS);
  // tsl.setTiming(TSL2591_INTEGRATIONTIME_500MS);
  // tsl.setTiming(TSL2591_INTEGRATIONTIME_600MS);  // longest integration time (dim light)

  /* Display the gain and integration time for reference sake */  
  Serial.println(F("------------------------------------"));
  Serial.print  (F("Gain:         "));
  tsl2591Gain_t gain = tsl.getGain();
  switch(gain)
  {
    case TSL2591_GAIN_LOW:
      Serial.println(F("1x (Low)"));
      break;
    case TSL2591_GAIN_MED:
      Serial.println(F("25x (Medium)"));
      break;
    case TSL2591_GAIN_HIGH:
      Serial.println(F("428x (High)"));
      break;
    case TSL2591_GAIN_MAX:
      Serial.println(F("9876x (Max)"));
      break;
  }
  Serial.print  (F("Timing:       "));
  Serial.print((tsl.getTiming() + 1) * 100, DEC); 
  Serial.println(F(" ms"));
  Serial.println(F("------------------------------------"));
  Serial.println(F(""));
}


