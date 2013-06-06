//
//  PDMapUtil.h
//  uDelivered
//
//  Created by Peter on 6/06/13.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PDMapUtil : NSObject

+ (void) zoomMapToUserLocation:(MKMapView*)mapView;
+ (void)zoomMapToFitAnnotations:(MKMapView*)mapView;
+ (void)zoomMapToFitAnnotations:(MKMapView*)mapView horizontalPadding:(float) horizontalPadding verticalPadding:(float) verticalPadding minimumLatitudeSpan:(float)minLatSpan animated:(BOOL)animated;

@end
