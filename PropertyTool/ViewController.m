//
//  ViewController.m
//  PropertyTool
//
//  Created by delims on 2020/7/17.
//  Copyright © 2020 delims. All rights reserved.
//

#import "ViewController.h"

typedef NS_ENUM(NSUInteger, PropertyType) {
    PropertyTypeString,
    PropertyTypeInteger,
    PropertyTypeFloat,
};

@interface ViewController ()<NSTextViewDelegate>

@property (weak) IBOutlet NSTextView *textView1;
@property (weak) IBOutlet NSTextView *textView2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textView1.delegate = self;
    //Make ourselves delegate so we'll receive actions as firstResponder
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeWindow)name:NSWindowWillCloseNotification object:nil];
}
- (void)closeWindow
{
    [NSApp terminate:self];
}
- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRanges:(NSArray<NSValue *> *)affectedRanges replacementStrings:(NSArray<NSString *> *)replacementStrings
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self convert];
    });
    return YES;
}

- (void)convert
{
    NSLog(@"%@",self.textView1.textStorage.string);
    NSString *text = self.textView1.textStorage.string;
    
    if ([text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet].length == 0) {
        return;
    }
    text = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"　" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"/" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"\t" withString:@""];

    NSArray *items = [text componentsSeparatedByString:@","];
    
    NSMutableString *resultString = @"".mutableCopy;
    NSMutableString *propertyStringCode = @"".mutableCopy;
    NSMutableString *propertyIntegerCode = @"".mutableCopy;
    NSMutableString *propertyFloatCode = @"".mutableCopy;
    NSMutableString *propertyNullCode = @"".mutableCopy;
    NSMutableString *propertyArrayCode = @"".mutableCopy;
    NSMutableString *propertyDictionaryCode = @"".mutableCopy;

    NSInteger nullSpaceLength = 0;
    
    for (NSString *string in items) {
        NSString *key = [string componentsSeparatedByString:@":"].firstObject;
        NSString *value = [string componentsSeparatedByString:@":"].lastObject;
        key = [key stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        if ([value containsString:@"null"]) {
            if (key.length > nullSpaceLength) {
                nullSpaceLength = key.length;
            }
        }
    }
    nullSpaceLength += 2;
    for (NSString *string in items) {
        NSString *key = [string componentsSeparatedByString:@":"].firstObject;
        NSString *value = [string componentsSeparatedByString:@":"].lastObject;
        key = [key stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        if ([key isEqualToString:value]) {
            continue;
        }
        NSString *propertyString = nil;
        
        if ([value hasPrefix:@"\""] || [value hasSuffix:@"\""]) {
            propertyString = [NSString stringWithFormat:@"@property (nonatomic,%@) NSString    *%@;",@"copy",key];
            [propertyStringCode appendFormat:@"%@\n",propertyString];
        } else if ([value containsString:@"null"]) {
            propertyString = [NSString stringWithFormat:@"@property (nonatomic,%@) NSString    *%@;%@//null as NSString",@"copy",key,[self getWhiteSpaceString:nullSpaceLength - key.length]];
            [propertyNullCode appendFormat:@"%@\n",propertyString];
        } else if ([value containsString:@"["] || [value containsString:@"]"]) {
            propertyString = [NSString stringWithFormat:@"@property (nonatomic,%@) NSArray     *%@;",@"copy",key];
            [propertyArrayCode appendFormat:@"%@\n",propertyString];
        } else if ([value containsString:@"{"] || [value containsString:@"}"]) {
            propertyString = [NSString stringWithFormat:@"@property (nonatomic,%@) NSDictionary*%@;",@"copy",key];
            [propertyDictionaryCode appendFormat:@"%@\n",propertyString];
        } else  if ([value containsString:@"."]) {
            propertyString = [NSString stringWithFormat:@"@property (nonatomic,%@) float      %@;",@"assign",key];
            [propertyFloatCode appendFormat:@"%@\n",propertyString];
        } else {
            propertyString = [NSString stringWithFormat:@"@property (nonatomic,%@) NSInteger  %@;",@"assign",key];
            [propertyIntegerCode appendFormat:@"%@\n",propertyString];
        }
        if (propertyString == nil) continue;
    }
    
    [resultString appendFormat:@"%@",propertyStringCode];
    [resultString appendFormat:@"%@",propertyNullCode];
    [resultString appendFormat:@"%@",propertyArrayCode];
    [resultString appendFormat:@"%@",propertyDictionaryCode];
    [resultString appendFormat:@"%@",propertyFloatCode];
    [resultString appendFormat:@"%@",propertyIntegerCode];

    [self.textView2 setString:resultString];
}



- (NSString*)getWhiteSpaceString:(NSUInteger)length
{
    char str[length+1];
    for (int i = 0; i < length; i ++) {
        str[i] = 32;
    }
    str[length] = 0;
    return [NSString.alloc initWithCString:str encoding:NSUTF8StringEncoding];
}

@end
//"Id": null,
//"Name": "玉米种植计划",
//"TemplateId": "1",
//"LandId": null,
//"LandName": 702.002,
//"CropTypeId": "5",
//"CropType": "玉米",
//"CropVarietyId": "200",
//"CropVariety": "德单9",
//"SowDate": "2020-07-13 16:00:00",
//"PlantNumberPerMu": null,
//"CreatedTime": "2020-07-13 16:00:00",
//"Description": "玉米种植计划",
//"PlantPlanStages": [],
//"OrgId": "4308243c23da403a86ece12d9ae46482",
//"Growth": ""
            
//"Id": "6b1b1618a6274d8db35cd00e42d23cea",
//"Name": "玉米种植计划22",
//"TemplateId": "1",
//"LandId": "08b6a7cb18284d38a6ce3315dfb3d1f3",
//"LandName": "地块702002",
//"CropTypeId": "5",
//"CropType": "玉米",
//"CropVarietyId": "200",
//"CropVariety": "德单9",
//"SowDate": "2020-07-13 16:00:00",
//"PlantNumberPerMu": 10,
//"CreatedTime": "2020-07-13 16:00:00",
//"Description": {},
//"PlantPlanStages": [],
//"OrgId": "4308243c23da403a86ece12d9ae46482",
//"Growth": ""
