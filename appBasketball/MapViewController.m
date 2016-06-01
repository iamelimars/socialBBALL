//
//  MapViewController.m
//  appBasketball
//
//  Created by iMac on 6/1/16.
//  Copyright © 2016 Marshall. All rights reserved.
//

#import "MapViewController.h"
@import Mapbox;
@interface MapViewController ()
@property (nonatomic) MGLMapView *mapView;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView = [[MGLMapView alloc]initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    // set maps center coordinates
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(59.31, 18.06) zoomLevel:9 animated:NO];
    self.mapView.styleURL = [MGLStyle outdoorsStyleURLWithVersion:9];

    [self.view addSubview:self.mapView];
    self.mapView.delegate = self;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:nil];
    doubleTap.numberOfTapsRequired = 2;
    [self.mapView addGestureRecognizer:doubleTap];
    
    // delay single tap recognition until it is clearly not a double
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self.mapView addGestureRecognizer:singleTap];
    
    // convert `mapView.centerCoordinate` (CLLocationCoordinate2D)
    // to screen location (CGPoint)
    CGPoint centerScreenPoint = [self.mapView convertCoordinate:self.mapView.centerCoordinate
                                                  toPointToView:self.mapView];
    
    NSLog(@"Screen center: %@ = %@",
          NSStringFromCGPoint(centerScreenPoint),
          NSStringFromCGPoint(self.mapView.center));
    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)mapViewDidFinishLoadingMap:(MGLMapView *)mapView {
    // Wait for the map to load before initiating the first camera movement.
    
    // Create a camera that rotates around the same center point, rotating 180°.
    // `fromDistance:` is meters above mean sea level that an eye would have to be in order to see what the map view is showing.
    MGLMapCamera *camera = [MGLMapCamera cameraLookingAtCenterCoordinate:self.mapView.centerCoordinate fromDistance:4500 pitch:15 heading:180];
    
    // Animate the camera movement over 5 seconds.
    [self.mapView setCamera:camera withDuration:5 animationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
}
// Use the default marker; see our custom marker example for more information
- (MGLAnnotationImage *)mapView:(MGLMapView *)mapView imageForAnnotation:(id <MGLAnnotation>)annotation {
    return nil;
}

// Allow markers callouts to show when tapped
- (BOOL)mapView:(MGLMapView *)mapView annotationCanShowCallout:(id <MGLAnnotation>)annotation {
    return YES;
}
- (void)handleSingleTap:(UITapGestureRecognizer *)tap
{
    // convert tap location (CGPoint)
    // to geographic coordinates (CLLocationCoordinate2D)
    CLLocationCoordinate2D location = [self.mapView convertPoint:[tap locationInView:self.mapView]
                                            toCoordinateFromView:self.mapView];
    
    NSLog(@"You tapped at: %.5f, %.5f", location.latitude, location.longitude);
    
    // create an array of coordinates for our polyline
    CLLocationCoordinate2D coordinates[] = {
        self.mapView.centerCoordinate,
        location
    };
    MGLPointAnnotation *hello = [[MGLPointAnnotation alloc] init];
    hello.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
    hello.title = @"Hello world!";
    hello.subtitle = @"Welcome to my marker";
    
    // Add marker `hello` to the map
    [self.mapView addAnnotation:hello];
    // remove existing polyline from the map, (re)add polyline with coordinates
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
