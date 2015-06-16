//
//  ViewController.m
//  TestAVProject
//
//  Created by Alexey Yachmenev on 15.06.15.
//  Copyright (c) 2015 e-Legion. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@import MobileCoreServices;
@import AVFoundation;

@interface ViewController () <UITabBarDelegate, UITableViewDataSource, MPMediaPickerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) NSMutableArray *videos;
@property (nonatomic, copy) NSURL *audio;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.videos = [NSMutableArray array];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Audio" style:UIBarButtonItemStylePlain target:self action:@selector(selectAudio)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Video" style:UIBarButtonItemStylePlain target:self action:@selector(selectVideo)];
}

- (void)selectAudio
{
    MPMediaPickerController *mediaPickerController = [MPMediaPickerController new];
    mediaPickerController.delegate = self;
    [self presentViewController:mediaPickerController animated:YES completion:nil];
}

- (void)selectVideo
{
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePicker.mediaTypes = @[(__bridge NSString *)kUTTypeMovie];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma marl - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.videos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    NSURL *video = self.videos[indexPath.row];
    cell.imageView.image = [self getSnapshotForVideo:video];
    
    return cell;
}

#pragma mark - MediaPicker delegate

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems: (MPMediaItemCollection *) collection
{
    if (collection.items.count > 0) {
        MPMediaItem *item = [collection.items firstObject];
        NSURL *audioUrl = [item valueForProperty:MPMediaItemPropertyAssetURL];
        
        if (audioUrl) {
            self.audio = audioUrl;
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Запись отсутствует на вашем устройстве" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }
    
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.videos addObject:info[UIImagePickerControllerMediaURL]];
    [self.tableView reloadData];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Edit video

- (UIImage *)getSnapshotForVideo:(NSURL *)videoUrl
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    NSError *error;
    CMTime time = CMTimeMake(1, 60);
    CGImageRef imageRef = [generate copyCGImageAtTime:time actualTime:nil error:&error];
    NSLog(@"err==%@, imageRef==%@", error, imageRef);
    
    return [[UIImage alloc] initWithCGImage:imageRef];
}

@end
