//
//  CoverDownloader.m
//  LoadCocoaChinaTest
//
//  Created by mamong on 14-3-20.
//  Copyright (c) 2014年 mamong. All rights reserved.
//

#import "CoverDownloader.h"
#import "EBookDetailItem.h"

#define kCoverHight 150
#define kCoverWidth 110

@interface CoverDownloader (){
    
}
@property (nonatomic, assign) int index;
@property (nonatomic, strong) NSString *coverURL;
@property (nonatomic, strong) NSMutableData *activeDownload;
@property (nonatomic, strong) NSURLConnection *imageConnection;
@property (nonatomic, assign) long long picSize;
@end


@implementation CoverDownloader

#pragma mark

- (void)startDownloadWithIndex:(NSUInteger)index
{
    self.index = index;
    self.activeDownload = [NSMutableData data];
    self.coverURL = [NSString stringWithFormat:@"http://www.pin5i.com%@",[self.ebookDetail.coverURLArray objectAtIndex:index]];NSLog(@"cover url is %@",self.coverURL);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.coverURL]cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10.0];
    [request setHTTPMethod:@"Get"];
    [request setValue:@"image/*" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"http://www.pin5i.com/" forHTTPHeaderField:@"Referer"];
    // alloc+init and start an NSURLConnection; release on completion/failure
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    self.imageConnection = conn;
}



- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"response code is %d",[(NSHTTPURLResponse *)response statusCode]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
    
    NSLog(@"erro is %@",[error description]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
 //Set appIcon and clear temporary data/image
    
    UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];NSLog(@"image is %@,data is %@",[image description],[[NSString alloc]initWithData:self.activeDownload encoding:NSUTF8StringEncoding]);
    if (image&&[self.ebookDetail.coverArray count]) {
        if (image.size.width != kCoverWidth || image.size.height != kCoverHight)
        {
            CGSize itemSize = CGSizeMake(kCoverWidth, kCoverHight);
            UIGraphicsBeginImageContextWithOptions(itemSize, NO, 0.0f);
            CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
            [image drawInRect:imageRect];
            [self.ebookDetail.coverArray replaceObjectAtIndex:self.index withObject:UIGraphicsGetImageFromCurrentImageContext()];
            UIGraphicsEndImageContext();
        }else
        {
            [self.ebookDetail.coverArray replaceObjectAtIndex:self.index withObject:image];
        }
        NSNumber *size = [NSNumber numberWithUnsignedInt:[self.activeDownload length]];
        [self.ebookDetail.coverDownloadSizeArray replaceObjectAtIndex:self.index withObject:size];
        self.activeDownload = nil;

        // Release the connection now that it's finished
        self.imageConnection = nil;

    // call our delegate and tell it that our icon is ready for display
    
    }else if (!image){
        [self.ebookDetail.coverArray replaceObjectAtIndex:self.index withObject:@"BADRequest"];
    }
    if (self.completionHandler)
        self.completionHandler();
    
}



@end
