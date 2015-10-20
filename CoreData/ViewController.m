//
//  ViewController.m
//  CoreData
//
//  Created by Budhathoki,Bipin on 10/9/15.
//  Copyright © 2015 Bipin Budhathoki. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()
@property (nonatomic, strong) NSManagedObject *selectedDataObject;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.tableDataArray = [NSMutableArray new];
    [self fetchDataFromDataBase];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tableDataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    NSManagedObject *managedObject = self.tableDataArray[indexPath.row];
    cell.textLabel.text = [managedObject valueForKey:@"name"];
    cell.detailTextLabel.text = [managedObject valueForKey:@"city"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *obj=[self.tableDataArray objectAtIndex:indexPath.row ];
    _selectedDataObject=obj;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Core Data" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.text = [obj valueForKey:@"name"];
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.text = [obj valueForKey:@"city"];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self updateDataInDataBase:alertController.textFields.firstObject.text city:alertController.textFields.lastObject.text];
        
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:saveAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if(editingStyle==UITableViewCellEditingStyleDelete)
    {
        AppDelegate *appDel=(AppDelegate *)[UIApplication sharedApplication].delegate;
        NSManagedObjectContext *context = [appDel managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Basket" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        NSError *error;
        [_managedObjectContext deleteObject:[_tableDataArray objectAtIndex:indexPath.row]];
        
        NSLog(@"object deleted");
        
        if (![_managedObjectContext save:&error])
        {
            NSLog(@"Error deleting  - error:%@",error);
        }
        
        [_tableDataArray removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView setEditing:NO animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)insertButtonTapped:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Core Data" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"Enter Name";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"Enter ddress";
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *name = alertController.textFields.firstObject.text;
        NSString *city = alertController.textFields.lastObject.text;
        [self insertData:name withCity:city];
        
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:saveAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
- (IBAction)deleteButtonTapped:(id)sender {
}

-(void)insertData:(NSString *)name withCity:(NSString *)city {
    AppDelegate *appDel = [UIApplication sharedApplication].delegate;
    _managedObjectContext = [appDel managedObjectContext];
    NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"DataBasket" inManagedObjectContext:_managedObjectContext];
    [newDevice setValue:name forKey:@"name"];
    [newDevice setValue:city forKey:@"city"];
    
    NSError *error;
    if([_managedObjectContext save:&error]) {
        NSLog(@"data saved");
        [self.tableDataArray addObject:newDevice];
        [self.tableView reloadData];
    }
    else {
         NSLog(@"Error occured while saving");
    }
}

-(void)fetchDataFromDataBase {
    [self.tableDataArray removeAllObjects];
    AppDelegate *appDel = [UIApplication sharedApplication].delegate;
    _managedObjectContext =[appDel managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DataBasket" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects == nil) {
        NSLog(@"no object");
    }
    else {
        for(NSManagedObject *currentObj in fetchedObjects) {
            [self.tableDataArray addObject:currentObj];
        }
        [self.tableView reloadData];
    }
}

//update
-(void)updateDataInDataBase:(NSString *)name city:(NSString *)city {
    AppDelegate *appDel = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _managedObjectContext = [appDel managedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest new];
     NSEntityDescription *entity = [NSEntityDescription entityForName:@"DataBasket" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    [_selectedDataObject setValue:name forKey:@"name"];
    [_selectedDataObject setValue:city forKey:@"city"];
    NSLog(@"Object edited");
    
    if(![_managedObjectContext save:&error]) {
        NSLog(@"Error editing  - error:%@",error);
    }
    [self.tableView reloadData];
}

@end
