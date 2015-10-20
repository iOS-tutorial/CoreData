//
//  ViewController.h
//  CoreData
//
//  Created by Budhathoki,Bipin on 10/9/15.
//  Copyright © 2015 Bipin Budhathoki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *tableDataArray;

@property (strong) NSManagedObject *device;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

