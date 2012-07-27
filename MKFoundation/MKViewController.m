//
//  MKViewController.m
//  MKFoundation
//
//  Created by Mugunth on 27/7/12.
//  Copyright (c) 2012 Steinlogic Consulting and Training Pte Ltd. All rights reserved.
//

#import "MKViewController.h"

#import "Parse/Parse.h"

#import "TestNode.h"

#import "TestLeaf.h"

@interface MKViewController ()

@end

@implementation MKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  TestNode *node = [[TestNode alloc] init];
  node.secondGreeting = @"HelloWorld";
  node.embeddedObject = [[TestLeaf alloc] init];
  
  node.embeddedObject.greeting = @"Welcome";
  
  PFObject *magicObject = [node pfObject];
  
  [magicObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    
    if(!succeeded)
      NSLog(@"%@", error);
    else
      NSLog(@"All done");
    
  }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
