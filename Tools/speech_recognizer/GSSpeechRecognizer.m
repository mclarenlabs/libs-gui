#import "GSSpeechRecognizer.h"

static GSSpeechRecognitionServer *server;
static int clients;

@interface GSSpeechRecognizer (Private)
+ (void)connectionDied: (NSNotification*)aNotification;
@end

@implementation GSSpeechRecognizer
+ (void)initialize
{
  server = [GSSpeechRecognitionServer sharedServer];
  RETAIN(server);
  [[NSNotificationCenter defaultCenter]
		addObserver: self
		   selector: @selector(connectionDied:)
                       name: NSConnectionDidDieNotification
                     object: nil];
}

/**
 * If the remote end exits before freeing the GSSpeechRecognizer then we need
 * to send it a -release message to make sure it dies.
 */
+ (void)connectionDied: (NSNotification*)aNotification
{
  NSEnumerator *e = [[[aNotification object] localObjects] objectEnumerator];
  NSObject *o = nil;
  
  for (o = [e nextObject] ; nil != o ; o = [e nextObject])
    {
      if ([o isKindOfClass: self])
        {
          [o release];
        }
    }
}

/**
 * If no clients have been active for some time, kill the speech server to
 * conserve resources.
 */
+ (void)exitIfUnneeded: (NSTimer*)sender
{
  if (clients == 0)
    {
      exit(0);
    }
}

- (id)init
{
  self = [super init];
  if (self != nil)
    {
      clients++;
      NSLog(@"self = %@",self);
    }
  return self;
}

- (void)dealloc
{
  NSLog(@"Deallocating recognizer....");
  clients--;
  if (clients == 0)
    {
      [NSTimer scheduledTimerWithTimeInterval: 600
                                       target: object_getClass(self)
                                     selector: @selector(exitIfUnneeded:)
                                     userInfo: nil
                                      repeats: NO];
    }
  [super dealloc];
}

- (void) startListening
{
  NSLog(@"Start Listening");
  if (server != nil)
    {
      [server startListening];
    }
}

- (void) stopListening
{
  NSLog(@"Stop Listening");
  if (server != nil)
    {
      [server stopListening];
    }
}

@end
