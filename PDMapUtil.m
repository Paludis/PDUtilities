//
//  PDMapUtil.m
//  uDelivered
//
//  Created by Peter on 6/06/13.
//
//

#import "PDMapUtil.h"

@implementation PDMapUtil

// ref: http://codisllc.com/blog/zoom-mkmapview-to-fit-annotations/

+ (void)zoomMapToFitAnnotations:(MKMapView*)mapView horizontalPadding:(float) horizontalPadding verticalPadding:(float) verticalPadding minimumLatitudeSpan:(float)minLatSpan animated:(BOOL)animated
{
    if ([mapView.annotations count] == 0)
    {
        return;
    }
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(id<MKAnnotation> annotation in mapView.annotations)
    {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    
    // add padding at the sides
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) + verticalPadding;
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) + horizontalPadding;
    
    region.span.latitudeDelta = MAX(minLatSpan, region.span.latitudeDelta);
    
    region = [mapView regionThatFits:region];
    
    if (!CLLocationCoordinate2DIsValid(region.center))
    {
        region.center = CLLocationCoordinate2DMake(0, 0);
    }
    
    @try
    {
        [mapView setRegion:region animated:animated];
    }
    @catch (NSException * e)
    {
        //DBG_ASSERT1(false, @"%@", e.reason);
    }
}

+ (void)zoomMapToFitAnnotations:(MKMapView*)mapView
{
    [self zoomMapToFitAnnotations:mapView horizontalPadding:1.2 verticalPadding:1.2 animated:YES];
}

+ (void) zoomMapToUserLocation:(MKMapView*)mapView
{
    if (mapView.userLocation.location)
    {
        MKCoordinateRegion region;
        region.center = mapView.userLocation.coordinate;
        region = [mapView regionThatFits:region];
        [mapView setRegion:region animated:YES];
    }
}

@end
