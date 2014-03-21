//
//  TableViewController.m
//  FlickStream
//
//  Created by Ross Tang Him on 3/20/14.
//  Copyright (c) 2014 Ross Tang Him. All rights reserved.
//

#import "TableViewController.h"
#import "AROFlickrWebServiceManager.h"

@interface TableViewController ()
@property (nonatomic) NSArray *items;
@property (nonatomic) NSMutableArray *thumbnails;
@end

@implementation TableViewController
@synthesize items, thumbnails;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self navigationItem] setTitle:@"Flickr Photos"];
    
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                      action:@selector(loadData)
            forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    //show refresh initially
    self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
    [self.refreshControl beginRefreshing];
    
    [self loadData];
}

-(void) loadData {
    

    [[AROFlickrWebServiceManager sharedInstance] fetchPublicImagesWithCompletion:^(NSDictionary *data, NSURLResponse *response, NSError *error) {
        if (error) {
            /*
             * Somehow I would get this error sometimes:
             * ERROR Error Domain=NSCocoaErrorDomain Code=3840 "The operation couldn’t be completed. (Cocoa error 3840.)"
             * I believe that it is a problem with the JSON string so I retry until it works
             * It's brute force I know but I think it may be flickr's fault
             */
            //NSLog(@"JSON ERROR: %@", error);
            [self performSelector:@selector(loadData) withObject:nil afterDelay:0.5];
            return;
        }
        if (data) {
            items = [data objectForKey:@"items"];

            /*
             * load thumbnails into cache so scrolling is smoother
             * I tried to load them asynchronously one at a time but that was a bit slow
             *
             */
            thumbnails = [[NSMutableArray alloc] init];
            for (NSDictionary *item in items) {
                NSString *imageURLString = [[item objectForKey:@"media"] objectForKey:@"m"];
                [thumbnails addObject:[self imageFromURLString:imageURLString hiRes:NO]];
            }
            
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];

        }
        
    }];

}

-(UIImage *) imageFromURLString: (NSString *) urlString hiRes: (BOOL) isHiRes {
    //convert to high resolution url
    if (isHiRes) {
        urlString = [self convertURLStringToHiResURLString:urlString];
    }
    
    NSURL * imageURL = [NSURL URLWithString:urlString];
    NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImage * image = [UIImage imageWithData:imageData];
    return image;
}

-(UIImageView *) imageViewFromURLString: (NSString *) urlString hiRes: (BOOL) isHiRes {
    UIImage *image = [self imageFromURLString:urlString hiRes:isHiRes];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setBackgroundColor:[UIColor blackColor]];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    return imageView;
}

//Found that ending with _b.jpg is higher res than ending with _m.jpg
-(NSString *) convertURLStringToHiResURLString: (NSString *) urlString {
    NSString *retString = [NSString stringWithFormat:@"%@b.jpg", [urlString substringToIndex:urlString.length - 5]];
    return retString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [items count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    NSUInteger index = [indexPath row];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSDictionary *item = [items objectAtIndex:index];
    cell.textLabel.text = [item objectForKey:@"title"];
    cell.imageView.image = [thumbnails objectAtIndex:index];
    
    return cell;
}



-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *fullScreenViewController = [[UIViewController alloc] init];
    NSDictionary *item = [items objectAtIndex:indexPath.row];

    NSString *imageURLString = [[item objectForKey:@"media"] objectForKey:@"m"];
    [fullScreenViewController setTitle:[item objectForKey:@"title"]];
    
    [self.navigationController pushViewController:fullScreenViewController animated:YES];
    [fullScreenViewController setView:[self imageViewFromURLString:imageURLString hiRes:YES]];
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
