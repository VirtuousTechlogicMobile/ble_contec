#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface AppDelegate : FlutterAppDelegate<CBCentralManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (nonatomic, strong) CBCentralManager *manager;
@property (strong) CBPeripheral  *connectingPeripheral;
@end
@interface StreamHandler : NSObject <FlutterStreamHandler>
@end
