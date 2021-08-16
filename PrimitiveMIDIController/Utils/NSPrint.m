//
//  NSPrint.m
//  Audio Conversion Command Line
//
//  Created by Panayotis Matsinopoulos on 29/5/21.
//

#import <Foundation/Foundation.h>

void NSPrint(NSString *format, ...) {
  va_list args;

  va_start(args, format);
  NSString *string  = [[NSString alloc] initWithFormat:format arguments:args];
  va_end(args);

  fprintf(stdout, "%s", [string UTF8String]);
    
#if !__has_feature(objc_arc)
  [string release];
#endif
}
