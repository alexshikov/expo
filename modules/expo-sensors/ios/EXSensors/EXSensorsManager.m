// Copyright 2015-present 650 Industries. All rights reserved.

#import <EXSensors/EXSensorsManager.h>
#import <CoreMotion/CoreMotion.h>

@interface EXSensorsManager ()

@property (nonatomic, strong) CMMotionManager *manager;
@property (nonatomic, strong) NSMutableDictionary *accelerometerHandlers;
@property (nonatomic, strong) NSMutableDictionary *deviceMotionHandlers;
@property (nonatomic, strong) NSMutableDictionary *gyroscopeHandlers;
@property (nonatomic, strong) NSMutableDictionary *magnetometerHandlers;
@property (nonatomic, strong) NSMutableDictionary *magnetometerUncalibratedHandlers;

@end

@implementation EXSensorsManager

EX_REGISTER_MODULE();

+ (const NSArray<Protocol *> *)exportedInterfaces
{
  return @[@protocol(EXAccelerometerInterface), @protocol(EXDeviceMotionInterface), @protocol(EXGyroscopeInterface), @protocol(EXMagnetometerInterface), @protocol(EXMagnetometerUncalibratedInterface)];
}

- (instancetype)init
{
  if (self = [super init]) {
    [self manager];
    _accelerometerHandlers = [[NSMutableDictionary alloc] init];
    _deviceMotionHandlers = [[NSMutableDictionary alloc] init];
    _gyroscopeHandlers = [[NSMutableDictionary alloc] init];
    _magnetometerHandlers = [[NSMutableDictionary alloc] init];
    _magnetometerUncalibratedHandlers = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (CMMotionManager *)manager
{
  if (!_manager) {
    _manager = [[CMMotionManager alloc] init];
  }
  return _manager;
}

- (void)dealloc
{
  [_manager stopAccelerometerUpdates];
  [_manager stopDeviceMotionUpdates];
  [_manager stopGyroUpdates];
  [_manager stopMagnetometerUpdates];
}

- (void)sensorModuleDidSubscribeForAccelerometerUpdates:(id)scopedSensorModule
                                            withHandler:(void (^)(NSDictionary *event))handlerBlock
{
  if ([_manager isAccelerometerAvailable]) {
    _accelerometerHandlers[scopedSensorModule] = handlerBlock;
  }
  if (![_manager isAccelerometerActive]) {
    [_manager setAccelerometerUpdateInterval:0.1f];
    __weak EXSensorsManager *weakSelf = self;
    [_manager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *data, NSError *error) {
      __strong EXSensorsManager *strongSelf = weakSelf;
      if (strongSelf) {
        for (void (^handler)(NSDictionary *) in strongSelf.accelerometerHandlers.allValues) {
          handler(@{
                    @"x": [NSNumber numberWithDouble:data.acceleration.x],
                    @"y": [NSNumber numberWithDouble:data.acceleration.y],
                    @"z": [NSNumber numberWithDouble:data.acceleration.z]
                    });
        }
      }
    }];
  }
}

- (void)sensorModuleDidUnsubscribeForAccelerometerUpdates:(id)scopedSensorModule
{
  [_accelerometerHandlers removeObjectForKey:scopedSensorModule];
  if (_accelerometerHandlers.count == 0) {
    [_manager stopAccelerometerUpdates];
  }
}

- (void)setAccelerometerUpdateInterval:(NSTimeInterval)intervalMs
{
  [_manager setAccelerometerUpdateInterval:intervalMs];
}

- (void)sensorModuleDidSubscribeForDeviceMotionUpdates:(id)scopedSensorModule
                                           withHandler:(void (^)(NSDictionary *event))handlerBlock
{
  if ([_manager isDeviceMotionAvailable]) {
    _deviceMotionHandlers[scopedSensorModule] = handlerBlock;
  }
  if (![_manager isDeviceMotionActive]) {
    [self activateDeviceMotionUpdates];
  }
}

- (void)sensorModuleDidUnsubscribeForDeviceMotionUpdates:(id)scopedSensorModule
{
  [_deviceMotionHandlers removeObjectForKey:scopedSensorModule];
  if (_deviceMotionHandlers.count == 0 && _magnetometerHandlers.count == 0) {
    [_manager stopDeviceMotionUpdates];
  }
}

- (void)setDeviceMotionUpdateInterval:(NSTimeInterval)intervalMs
{
  [_manager setDeviceMotionUpdateInterval:intervalMs];
}

- (void)sensorModuleDidSubscribeForGyroscopeUpdates:(id)scopedSensorModule
                                        withHandler:(void (^)(NSDictionary *event))handlerBlock
{
  if ([_manager isGyroAvailable]) {
    _gyroscopeHandlers[scopedSensorModule] = handlerBlock;
  }
  if (![_manager isGyroActive]) {
    [_manager setGyroUpdateInterval:0.1f];
    __weak EXSensorsManager *weakSelf = self;
    [_manager startGyroUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMGyroData *data, NSError *error) {
      __strong EXSensorsManager *strongSelf = weakSelf;
      if (strongSelf) {
        for (void (^handler)(NSDictionary *) in strongSelf.gyroscopeHandlers.allValues) {
          handler(@{
                    @"x": [NSNumber numberWithDouble:data.rotationRate.x],
                    @"y": [NSNumber numberWithDouble:data.rotationRate.y],
                    @"z": [NSNumber numberWithDouble:data.rotationRate.z]
                    });
        }
      }
    }];
  }
}

- (void)sensorModuleDidUnsubscribeForGyroscopeUpdates:(id)scopedSensorModule
{
  [_gyroscopeHandlers removeObjectForKey:scopedSensorModule];
  if (_gyroscopeHandlers.count == 0) {
    [_manager stopGyroUpdates];
  }
}

- (void)setGyroscopeUpdateInterval:(NSTimeInterval)intervalMs
{
  [_manager setGyroUpdateInterval:intervalMs];
}

- (void)sensorModuleDidSubscribeForMagnetometerUpdates:(id)scopedSensorModule
                                           withHandler:(void (^)(NSDictionary *event))handlerBlock
{
  if ([_manager isDeviceMotionAvailable]) {
    _magnetometerHandlers[scopedSensorModule] = handlerBlock;
  }
  if (![_manager isDeviceMotionActive]) {
    [self activateDeviceMotionUpdates];
  }
}

- (void)sensorModuleDidUnsubscribeForMagnetometerUpdates:(id)scopedSensorModule
{
  [_magnetometerHandlers removeObjectForKey:scopedSensorModule];
  if (_deviceMotionHandlers.count == 0 && _magnetometerHandlers.count == 0) {
    [_manager stopDeviceMotionUpdates];
  }
}

- (void)setMagnetometerUpdateInterval:(NSTimeInterval)intervalMs
{
  [_manager setDeviceMotionUpdateInterval:intervalMs];
}

- (void)sensorModuleDidSubscribeForMagnetometerUncalibratedUpdates:(id)scopedSensorModule
                                                       withHandler:(void (^)(NSDictionary *event))handlerBlock
{
  if ([_manager isMagnetometerAvailable]) {
    _magnetometerUncalibratedHandlers[scopedSensorModule] = handlerBlock;
  }
  if (![_manager isMagnetometerActive]) {
    [_manager setMagnetometerUpdateInterval:0.1f];
    __weak EXSensorsManager *weakSelf = self;
    [_manager startMagnetometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMMagnetometerData *data, NSError *error) {
      __strong EXSensorsManager *strongSelf = weakSelf;
      if (strongSelf) {
        for (void (^handler)(NSDictionary *) in strongSelf.magnetometerUncalibratedHandlers.allValues) {
          handler(@{
                    @"x": [NSNumber numberWithDouble:data.magneticField.x],
                    @"y": [NSNumber numberWithDouble:data.magneticField.y],
                    @"z": [NSNumber numberWithDouble:data.magneticField.z]
                    });
        }
      }
    }];
  }
}

- (void)sensorModuleDidUnsubscribeForMagnetometerUncalibratedUpdates:(id)scopedSensorModule
{
  [_magnetometerUncalibratedHandlers removeObjectForKey:scopedSensorModule];
  if (_magnetometerUncalibratedHandlers.count == 0) {
    [_manager stopMagnetometerUpdates];
  }
}

- (void)setMagnetometerUncalibratedUpdateInterval:(NSTimeInterval)intervalMs
{
  [_manager setMagnetometerUpdateInterval:intervalMs];
}

- (float)getGravity
{
  return EXGravity;
}

- (void)activateDeviceMotionUpdates
{
  [[self manager] setDeviceMotionUpdateInterval:0.1f];
  __weak EXSensorsManager *weakSelf = self;
  [_manager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical toQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *data, NSError *error) {
    __strong EXSensorsManager *strongSelf = weakSelf;
    if (!strongSelf) {
      return;
    }
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    int orientationDegrees;
    switch (orientation) {
      case UIDeviceOrientationPortrait:
        orientationDegrees = 0;
        break;
      case UIDeviceOrientationLandscapeLeft:
        orientationDegrees = -90;
        break;
      case UIDeviceOrientationLandscapeRight:
        orientationDegrees = 90;
        break;
      case UIDeviceOrientationPortraitUpsideDown:
        orientationDegrees = 180;
        break;
      default:
        orientationDegrees = 0;
        break;
    }
    
    NSDictionary *result = @{
                             @"acceleration": @{
                                 @"x": @(data.userAcceleration.x * EXGravity),
                                 @"y": @(data.userAcceleration.y * EXGravity),
                                 @"z": @(data.userAcceleration.z * EXGravity)
                                 },
                             @"accelerationIncludingGravity": @{
                                 @"x": @((data.userAcceleration.x + data.gravity.x) * EXGravity),
                                 @"y": @((data.userAcceleration.y + data.gravity.y) * EXGravity),
                                 @"z": @((data.userAcceleration.z + data.gravity.z) * EXGravity)
                                 },
                             @"rotation": @{
                                 @"alpha": @(data.attitude.yaw),
                                 @"beta": @(data.attitude.pitch),
                                 @"gamma": @(data.attitude.roll),
                                 },
                             @"rotationRate" :@{
                                 @"alpha": @(data.rotationRate.z),
                                 @"beta": @(data.rotationRate.y),
                                 @"gamma": @(data.rotationRate.x)
                                 },
                             @"orientation": @(orientationDegrees)
                             };
    
    // DeviceMotionUpdates handle DeviceMotion data as well as magnetic field
    for (void (^handler)(NSDictionary *) in strongSelf.deviceMotionHandlers.allValues) {
      handler(result);
    }
    
    for (void (^handler)(NSDictionary *) in strongSelf.magnetometerHandlers.allValues) {
      handler(@{
                @"x": [NSNumber numberWithDouble:data.magneticField.field.x],
                @"y": [NSNumber numberWithDouble:data.magneticField.field.y],
                @"z": [NSNumber numberWithDouble:data.magneticField.field.z]
                });
    }
  }];
}

@end

