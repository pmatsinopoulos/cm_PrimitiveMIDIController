//
//  main.m
//  PrimitiveMIDIController
//
//  Created by Panayotis Matsinopoulos on 16/8/21.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>
#import "CheckError.h"
#import "NSPrint.h"

UInt32 AskUserWhichNoteOn(void) {
  NSPrint(@"Which note do you want to key in? (give 0 to end program):");
  UInt32 note = 0;
  scanf("%u", &note);
  fflush(stdin);

  return note;
}

void SendNoteOnOff(MIDIEndpointRef source, Byte note, bool on) {
  MIDIEventList evtList;
  evtList.numPackets = 1;
  evtList.protocol = kMIDIProtocol_1_0;
  evtList.packet[0].timeStamp = 0;
  evtList.packet[0].wordCount = 1;
  memset(evtList.packet[0].words, 0 , sizeof(evtList.packet[0].words));
  evtList.packet[0].words[0] = on ? 0x20900000 : 0x20800000;
  evtList.packet[0].words[0] = evtList.packet[0].words[0] | ((note & 0x7F) << 8);
  evtList.packet[0].words[0] = evtList.packet[0].words[0] | 127;
  
  CheckError(MIDIReceivedEventList(source, &evtList),
             "MIDI Received Event List");
}

void SendNoteOn(MIDIEndpointRef source, Byte note) {
  SendNoteOnOff(source, note, true);
}

void SendNoteOff(MIDIEndpointRef source, Byte note) {
  SendNoteOnOff(source, note, false);
}

void ReleaseResources(MIDIEndpointRef source,
                      MIDIPortRef outPort,
                      MIDIClientRef client) {
  CheckError(MIDIEndpointDispose(source),
             "Disposing the MIDI source");
  CheckError(MIDIPortDispose(outPort),
             "Disposing the MIDI out port");
  CheckError(MIDIClientDispose(client),
             "Disposing the MIDI client");
}

int main(int argc, const char * argv[]) {
  @autoreleasepool {
    NSPrint(@"Starting...\n");
    
    MIDIClientRef client;
    CheckError(MIDIClientCreate(CFSTR("My Primitive MIDI Controller Client"),
                                NULL,
                                NULL,
                                &client),
               "Starting MIDI Client");
   
    MIDIPortRef outPort;
    CheckError(MIDIOutputPortCreate(client, CFSTR("outPort"), &outPort),
               "creating output port");

    MIDIEndpointRef source;
    CheckError(MIDISourceCreateWithProtocol(client,
                                            CFSTR("My Primitive MIDI Controller"),
                                            kMIDIProtocol_1_0,
                                            &source),
               "Creating MIDI Source");
    
    while(true) {
      Byte note = (Byte)AskUserWhichNoteOn();
      
      if (!note) {
        break;
      }
      
      SendNoteOn(source, note);
      
      sleep(0.5);
      
      SendNoteOff(source, note);
    }
    
    ReleaseResources(source, outPort, client);
  }
  return 0;
}
