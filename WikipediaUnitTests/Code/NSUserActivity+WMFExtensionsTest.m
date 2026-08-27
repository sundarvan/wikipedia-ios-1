#import <XCTest/XCTest.h>
#import "NSUserActivity+WMFExtensions.h"

@interface NSUserActivity_WMFExtensions_wmf_activityForWikipediaScheme_Test : XCTestCase
@end

@implementation NSUserActivity_WMFExtensions_wmf_activityForWikipediaScheme_Test

- (void)testURLWithoutWikipediaSchemeReturnsNil {
    NSURL *url = [NSURL URLWithString:@"http://www.foo.com"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertNil(activity);
}

- (void)testInvalidArticleURLReturnsNil {
    NSURL *url = [NSURL URLWithString:@"wikipedia://en.wikipedia.org/Foo"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertNil(activity);
}

- (void)testArticleURL {
    NSURL *url = [NSURL URLWithString:@"wikipedia://en.wikipedia.org/wiki/Foo"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypeLink);
    XCTAssertEqualObjects(activity.webpageURL.absoluteString, @"https://en.wikipedia.org/wiki/Foo");
}

- (void)testExploreURL {
    NSURL *url = [NSURL URLWithString:@"wikipedia://explore"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypeExplore);
}

- (void)testSavedURL {
    NSURL *url = [NSURL URLWithString:@"wikipedia://saved"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypeSavedPages);
}

- (void)testSearchURL {
    NSURL *url = [NSURL URLWithString:@"wikipedia://en.wikipedia.org/w/index.php?search=dog"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypeLink);
    XCTAssertEqualObjects(activity.webpageURL.absoluteString,
                          @"https://en.wikipedia.org/w/index.php?search=dog&title=Special:Search&fulltext=1");
}

#pragma mark - Places coordinate deep links

- (void)testPlacesURLWithValidCoordinatesStoresUserInfo {
    NSURL *url = [NSURL URLWithString:@"wikipedia://places?lat=52.3547498&long=4.8339215"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypePlaces);
    XCTAssertEqualObjects(activity.userInfo[WMFPlacesLatitudeKey], @(52.3547498));
    XCTAssertEqualObjects(activity.userInfo[WMFPlacesLongitudeKey], @(4.8339215));
}

- (void)testPlacesURLAcceptsLonAlias {
    NSURL *url = [NSURL URLWithString:@"wikipedia://places?lat=52.35&lon=4.83"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypePlaces);
    XCTAssertEqualObjects(activity.userInfo[WMFPlacesLatitudeKey], @(52.35));
    XCTAssertEqualObjects(activity.userInfo[WMFPlacesLongitudeKey], @(4.83));
}

- (void)testPlacesURLWithNegativeLongitude {
    NSURL *url = [NSURL URLWithString:@"wikipedia://places?lat=40.4380638&long=-3.7495758"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqualObjects(activity.userInfo[WMFPlacesLongitudeKey], @(-3.7495758));
}

- (void)testPlacesURLMissingLatitudeOmitsCoordinates {
    NSURL *url = [NSURL URLWithString:@"wikipedia://places?long=4.83"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypePlaces);
    XCTAssertNil(activity.userInfo[WMFPlacesLatitudeKey]);
    XCTAssertNil(activity.userInfo[WMFPlacesLongitudeKey]);
}

- (void)testPlacesURLMissingLongitudeOmitsCoordinates {
    NSURL *url = [NSURL URLWithString:@"wikipedia://places?lat=52.35"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypePlaces);
    XCTAssertNil(activity.userInfo[WMFPlacesLatitudeKey]);
    XCTAssertNil(activity.userInfo[WMFPlacesLongitudeKey]);
}

- (void)testPlacesURLNonNumericLatitudeOmitsCoordinates {
    NSURL *url = [NSURL URLWithString:@"wikipedia://places?lat=abc&long=4.83"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypePlaces);
    XCTAssertNil(activity.userInfo[WMFPlacesLatitudeKey]);
    XCTAssertNil(activity.userInfo[WMFPlacesLongitudeKey]);
}

- (void)testPlacesURLOutOfRangeLatitudeOmitsCoordinates {
    NSURL *url = [NSURL URLWithString:@"wikipedia://places?lat=91&long=0"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertNil(activity.userInfo[WMFPlacesLatitudeKey]);
    XCTAssertNil(activity.userInfo[WMFPlacesLongitudeKey]);
}

- (void)testPlacesURLOutOfRangeLongitudeOmitsCoordinates {
    NSURL *url = [NSURL URLWithString:@"wikipedia://places?lat=0&long=181"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertNil(activity.userInfo[WMFPlacesLatitudeKey]);
    XCTAssertNil(activity.userInfo[WMFPlacesLongitudeKey]);
}

- (void)testPlacesURLEmptyValuesOmitsCoordinates {
    NSURL *url = [NSURL URLWithString:@"wikipedia://places?lat=&long="];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypePlaces);
    XCTAssertNil(activity.userInfo[WMFPlacesLatitudeKey]);
    XCTAssertNil(activity.userInfo[WMFPlacesLongitudeKey]);
}

- (void)testPlacesURLIntegerCoordinates {
    NSURL *url = [NSURL URLWithString:@"wikipedia://places?lat=52&long=4"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqualObjects(activity.userInfo[WMFPlacesLatitudeKey], @(52.0));
    XCTAssertEqualObjects(activity.userInfo[WMFPlacesLongitudeKey], @(4.0));
}

- (void)testPlacesOfficialSchemeWithCoordinates {
    NSURL *url = [NSURL URLWithString:@"wikipedia-official://places?lat=52.35&long=4.83"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypePlaces);
    XCTAssertEqualObjects(activity.userInfo[WMFPlacesLatitudeKey], @(52.35));
    XCTAssertEqualObjects(activity.userInfo[WMFPlacesLongitudeKey], @(4.83));
}

- (void)testPlacesArticleURLStillParsed {
    NSURL *url = [NSURL URLWithString:@"wikipedia://places?WMFArticleURL=https://en.wikipedia.org/wiki/Amsterdam"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypePlaces);
    XCTAssertEqualObjects(activity.webpageURL.absoluteString, @"https://en.wikipedia.org/wiki/Amsterdam");
    XCTAssertNil(activity.userInfo[WMFPlacesLatitudeKey]);
}

- (void)testPlacesCoordinatesTakePrecedenceAlongsideArticleURL {
    NSURL *url = [NSURL URLWithString:@"wikipedia://places?lat=52.35&long=4.83&WMFArticleURL=https://en.wikipedia.org/wiki/Amsterdam"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqualObjects(activity.userInfo[WMFPlacesLatitudeKey], @(52.35));
    XCTAssertEqualObjects(activity.userInfo[WMFPlacesLongitudeKey], @(4.83));
    XCTAssertEqualObjects(activity.webpageURL.absoluteString, @"https://en.wikipedia.org/wiki/Amsterdam");
}

- (void)testPlacesURLWithoutQueryStillOpensPlaces {
    NSURL *url = [NSURL URLWithString:@"wikipedia://places"];
    NSUserActivity *activity = [NSUserActivity wmf_activityForWikipediaScheme:url];
    XCTAssertEqual(activity.wmf_type, WMFUserActivityTypePlaces);
    XCTAssertNil(activity.userInfo[WMFPlacesLatitudeKey]);
}

@end
