//
//  ViewController.m
//  locationDemo
//
//  Created by nst on 2018/7/27.
//  Copyright © 2018年 nst. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
//地理编码头文件
#import <AddressBook/AddressBook.h>
@interface ViewController ()<CLLocationManagerDelegate>
@property (strong,nonatomic) CLLocationManager * locationManager;
// 用作地理编码、反地理编码的工具类
@property (nonatomic, strong) CLGeocoder *geoC;
@property (weak, nonatomic) IBOutlet UITextField *longitude;
@property (weak, nonatomic) IBOutlet UITextField *latitude;
@property (weak, nonatomic) IBOutlet UILabel *locationLable;
@property (weak, nonatomic) IBOutlet UITextField *cityField;
@end

@implementation ViewController
#pragma mark - 懒加载
-(CLGeocoder *)geoC
{
    if (!_geoC) {
        _geoC = [[CLGeocoder alloc] init];
    }
    return _geoC;
}
-(CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc]init];
        // 设置定位距离过滤参数 （当上次定位和本次定位之间的距离 > 此值时，才会调用代理通知开发者）
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        // 设置定位精度 （精确度越高，越耗电，所以需要我们根据实际情况，设定对应的精度）
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.allowsBackgroundLocationUpdates = YES;
        _locationManager.delegate = self;
    }
    return _locationManager;
}
- (IBAction)startLocation:(id)sender {
//    请求始终授权
    [_locationManager requestAlwaysAuthorization];
    
    
//    请求前台授权
//    [_locationManager requestWhenInUseAuthorization];
    
    // 2.判断定位服务是否可用
    if([CLLocationManager locationServicesEnabled])
    {
//        多次定位
        [self.locationManager startUpdatingLocation];
//        只定位一次
//        [self.locationManager requestLocation];
    }else
    {
        NSLog(@"不能定位呀");
    }
}
- (IBAction)stopLaocation:(id)sender {
    [self.locationManager stopUpdatingLocation];
    self.locationLable.text = @"结束定位";
}
- (IBAction)locatonAUthorization:(id)sender {
    // 在此处, 应该提醒用户给此应用授权, 并跳转到"设置"界面让用户进行授权
    // 在iOS8.0之后跳转到"设置"界面代码
    NSURL *settingURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([[UIApplication sharedApplication] canOpenURL:settingURL])
    {
        [[UIApplication sharedApplication] openURL:settingURL options:@{} completionHandler:nil];
    }
}

- (IBAction)geoCoder:(id)sender {
    
    if ([self.cityField.text length] == 0) {
        return;
    }
    
    // 地理编码方案一：直接根据地址进行地理编码（返回结果可能有多个，因为一个地点有重名）
    [self.geoC geocodeAddressString:self.cityField.text completionHandler:^(NSArray<CLPlacemark *> * __nullable placemarks, NSError * __nullable error) {
        // 包含区，街道等信息的地标对象
        CLPlacemark *placemark = [placemarks firstObject];
        // 城市名称
        //        NSString *city = placemark.locality;
        // 街道名称
        //        NSString *street = placemark.thoroughfare;
        // 全称
        NSString *name = placemark.name;
        self.cityField.text = [NSString stringWithFormat:@"%@", name];
        self.latitude.text = [NSString stringWithFormat:@"%f", placemark.location.coordinate.latitude];
        self.longitude.text = [NSString stringWithFormat:@"%f", placemark.location.coordinate.longitude];
    }];
    
    
    
    // 地理编码方案二：根据地址和区域两个条件进行地理编码（更加精确）
    //    [self.geoC geocodeAddressString:self.cityField.text inRegion:nil completionHandler:^(NSArray<CLPlacemark *> * __nullable placemarks, NSError * __nullable error) {
    //        // 包含区，街道等信息的地标对象
    //        CLPlacemark *placemark = [placemarks firstObject];
    //        self.cityField.text = placemark.description;
    //        self.latitude.text = [NSString stringWithFormat:@"%f", placemark.location.coordinate.latitude];
    //        self.longitude.text = [NSString stringWithFormat:@"%f", placemark.location.coordinate.longitude];
    //    }];
    
    
    
    // 地理编码方案三：
    //    NSDictionary *addressDic = @{
    //                                 (__bridge NSString *)kABPersonAddressCityKey : @"北京",
    //                                 (__bridge NSString *)kABPersonAddressStreetKey : @"棠下街"
    //                                 };
    //    [self.geoC geocodeAddressDictionary:addressDic completionHandler:^(NSArray<CLPlacemark *> * __nullable placemarks, NSError * __nullable error) {
    //        CLPlacemark *placemark = [placemarks firstObject];
    //        self.addressDetailTV.text = placemark.description;
    //        self.latitude.text = [NSString stringWithFormat:@"%f", placemark.location.coordinate.latitude];
    //        self.longitude.text = [NSString stringWithFormat:@"%f", placemark.location.coordinate.longitude];
    //    }];

    
}
- (IBAction)backGeoCooder:(id)sender {
    // 过滤空数据
    if ([self.latitude.text length] == 0 || [self.longitude.text length] == 0) {
        return;
    }
    // 创建CLLocation对象
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[self.latitude.text doubleValue] longitude:[self.longitude.text doubleValue]];
    // 根据CLLocation对象进行反地理编码
    [self.geoC reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * __nullable placemarks, NSError * __nullable error) {
        // 包含区，街道等信息的地标对象
        CLPlacemark *placemark = [placemarks firstObject];
        // 城市名称
        //        NSString *city = placemark.locality;
        // 街道名称
        //        NSString *street = placemark.thoroughfare;
        // 全称
        NSString *name = placemark.name;
        self.cityField.text = [NSString stringWithFormat:@"%@", name];
    }];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
//定位到的代理方法
-(void)locationManager:(nonnull CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations
{
      CLLocation *location = locations.lastObject;
    self.latitude.text = [NSString stringWithFormat:@"%f",location.coordinate.latitude];
    self.longitude.text = [NSString stringWithFormat:@"%f",location.coordinate.longitude];
    NSLog(@"位置信息维度%f,经度%f,海拔%f,方向%f,速度%fM/s,时间%@,水平精确度%f",location.coordinate.latitude,location.coordinate.longitude,location.altitude,location.course,location.speed,location.timestamp,location.horizontalAccuracy);
    self.locationLable.text = [NSString stringWithFormat:@"位置信息维度%f,经度%f,海拔%f,方向%f,速度%fM/s,时间%@,水平精确度%f",location.coordinate.latitude,location.coordinate.longitude,location.altitude,location.course,location.speed,location.timestamp,location.horizontalAccuracy];
//    [self reverseGeocodeLocation:location completionHandler:nil];
}
//- (void)reverseGeocodeLocation:(CLLocation *)location completionHandler:(CLGeocodeCompletionHandler)completionHandler{
//    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(50, 50, 200, CGFLOAT_MAX)];
//    lable.text = @"地名";
//        lable.text =[NSString stringWithFormat:@"%@"];
//}

/**
 *  当用户授权状态发生变化时调用
 */
-(void)locationManager:(nonnull CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
            // 用户还未决定
        case kCLAuthorizationStatusNotDetermined:
        {
            self.locationLable.text = @"用户还未决定";
            break;
        }
            // 问受限(苹果预留选项,暂时没用)
        case kCLAuthorizationStatusRestricted:
        {
            self.locationLable.text = @"访问受限";
            break;
        }
            // 定位关闭时和对此APP授权为never时调用
        case kCLAuthorizationStatusDenied:
        {
            // 定位是否可用（是否支持定位或者定位是否开启）
            if([CLLocationManager locationServicesEnabled])
            {
                self.locationLable.text = @"定位开启，但没有授权";
            }else
            {
                NSLog(@"定位关闭，不可用");
            }
            break;
        }
            // 获取前后台定位授权
        case kCLAuthorizationStatusAuthorizedAlways:
            //        case kCLAuthorizationStatusAuthorized: // 失效，不建议使用
        {
            NSLog(@"获取前后台定位授权");
            break;
        }
            // 获得前台定位授权
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            NSLog(@"获得前台定位授权");
            break;
        }
        default:
            break;
    }
    
}
/**
 * 当定位失败后调用此方法
 */
-(void)locationManager:(nonnull CLLocationManager *)manager didFailWithError:(nonnull NSError *)error
{
    
    NSLog(@"定位失败--%@", error.localizedDescription);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
