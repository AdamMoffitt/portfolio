//
//  ViewController.m
//  Tipper
//
//  Created by Adam Moffitt on 9/26/16.
//  Copyright © 2016 ITP342. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *billTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *taxSegmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *taxAmountLabel;
@property (weak, nonatomic) IBOutlet UISwitch *taxSwitch;
@property (weak, nonatomic) IBOutlet UISlider *tipSlider;
@property (weak, nonatomic) IBOutlet UILabel *tipPercentLabel;
@property (weak, nonatomic) IBOutlet UIStepper *evenSplitStepper;
@property (weak, nonatomic) IBOutlet UILabel *evenSplitNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalWithTipLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalPerPersonLabel;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UILabel *totalForTipLabel;

@property float billAmount;
@property float taxPercentage;
@property float taxAmount;
@property float tipAmount;
@property float tipPercentage;
@property int numberPeople;
@property float totalWithTip;
@property BOOL includeTax;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.billTextField becomeFirstResponder];
    
    [self setDefaultValues];
}
- (IBAction)billEntered:(UITextField *)sender {
    
    self.billAmount = [self.billTextField.text doubleValue];
    self.taxPercentage = [[self.taxSegmentedControl titleForSegmentAtIndex:[_taxSegmentedControl selectedSegmentIndex]] doubleValue];
    
    self.taxAmount = self.billAmount * (_taxPercentage / 100);
    
    self.taxAmountLabel.text = [ @"$" stringByAppendingString: [@(_taxAmount) stringValue]];

    [self calculateTips];
}


- (void) calculateTips {
    if([self.taxSwitch isOn]){
        _totalForTipLabel.text = [@"$" stringByAppendingString : [NSString stringWithFormat : @"%.2f",(_billAmount+_taxAmount)]];
        _tipAmount = (_billAmount + _taxAmount) * _tipPercentage;
    }
    else{
        _totalForTipLabel.text = [@"$" stringByAppendingString : [NSString stringWithFormat : @"%.2f",(_billAmount)]];
        _tipAmount = (_billAmount) * _tipPercentage;
    }
    
    _totalWithTip = _tipAmount+_billAmount+_taxAmount;
    
    self.totalWithTipLabel.text = [@"$" stringByAppendingString : [NSString stringWithFormat:@"%.2f", _totalWithTip]];
    
    self.totalPerPersonLabel.text = [NSString stringWithFormat:@"$%.2f", (_totalWithTip/_numberPeople)];
    
    self.tipAmountLabel.text = [@"$" stringByAppendingString : [NSString stringWithFormat:@"%.2f", _tipAmount]];
    
}

- (IBAction)taxPercentageChanged:(UISegmentedControl *)sender {
    self.taxPercentage = [[self.taxSegmentedControl titleForSegmentAtIndex:[_taxSegmentedControl selectedSegmentIndex]] doubleValue];
    self.taxAmount = self.billAmount * (_taxPercentage / 100);
    self.taxAmountLabel.text = [ @"$" stringByAppendingString: [@(_taxAmount) stringValue]];
    [self calculateTips];
}


- (IBAction)tipPercentageSlider:(UISlider *)sender {
    
    self.tipPercentLabel.text = [[NSString stringWithFormat:@"%i", (int)self.tipSlider.value] stringByAppendingString :  @"%"];
    
    
    _tipPercentage = self.tipSlider.value/100;
    
    [self calculateTips];
}


- (IBAction)tipIncludesTaxSwitch:(UISwitch *)sender {
    
    
    
    if([sender isOn]){
        
        //calculate tip without tax
        _tipAmount = (_billAmount + _taxAmount) * _tipPercentage;
        
        
        
    }
    else{
        
        //calculate tip with tax
        _tipAmount = (_billAmount) * _tipPercentage;
        
        
    }
    
    [self calculateTips];
}

- (IBAction)evenSplitStepperPressed:(UIStepper *)sender {
   
    _numberPeople = [sender value];
    _evenSplitNumberLabel.text = [NSString stringWithFormat:@"%i", _numberPeople];
    [self calculateTips];
}

- (IBAction)clearButton:(UIButton *)sender {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Clear all values"
                                          message:@"Are you sure you want to clear all values?"
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action) { /* code */ }];
    UIAlertAction *deleteAction = [UIAlertAction
                                   actionWithTitle:@"Clear"
                                   style:UIAlertActionStyleDestructive
                                   handler:^(UIAlertAction *action) { [self clearAll]; }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:deleteAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void) clearAll{
    _billTextField.text = @"$0.00";
    [_taxSegmentedControl setSelectedSegmentIndex:(0)];
    _taxAmountLabel.text = @"$0.00";
    [_taxSwitch setOn:(true)];
    [_tipSlider setValue:(20)];
    _evenSplitNumberLabel.text = @"1";
    [_evenSplitStepper setValue:(1)];
    _tipAmountLabel.text = @"$0.00";
    _totalWithTipLabel.text = @"$0.00";
    _totalPerPersonLabel.text = @"$0.00";
    self.tipPercentLabel.text = [[NSString stringWithFormat:@"%i", (int)self.tipSlider.value] stringByAppendingString :  @"%"];
    _totalForTipLabel.text = @"$0.00";
}

- (void) setDefaultValues{
    _billAmount = 0;
    _tipPercentage = .20;
    _numberPeople = 1;
}
- (IBAction)backGroundButtonDidPressed:(UIButton *)sender {
    [self.billTextField resignFirstResponder];
}





@end
