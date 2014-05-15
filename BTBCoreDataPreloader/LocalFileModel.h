//
//  LocalFileModel.h
//  Square
//
//  Created by Barty Kim on 5/14/14.
//  Copyright (c) 2014 ZeroDesktop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LocalFileModel : NSManagedObject

@property (nonatomic, retain) NSString * fid;
@property (nonatomic, retain) NSNumber * is_dir;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * created_date;
@property (nonatomic, retain) NSDate * modified_date;
@property (nonatomic, retain) NSDate * downloaded_date;
@property (nonatomic, retain) NSString * parent_id;
@property (nonatomic, retain) NSString * saved_path;
@property (nonatomic, retain) NSString * preview_path;

@end
