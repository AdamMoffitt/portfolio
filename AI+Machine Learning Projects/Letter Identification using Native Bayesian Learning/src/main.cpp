#include <iostream>
#include <fstream>
#include <vector>
#include <map>
#include "mnist_reader.hpp"
#include "mnist_utils.hpp"
#include "bitmap.hpp"
#include <math.h>
#include <sstream>
#define MNIST_DATA_DIR "../../mnist_data"
using namespace std;



void getPriorProbabilities(vector<double> &priorProbabilities, vector<vector<double>> &classConditionalProbabilities, vector<unsigned char> trainLabels, vector<std::vector<unsigned char>> trainImages) {
    // 9 ints of how many times digit is seen in training set
    std::vector<int> priorProbabilitiesCount(10,0); 
    
    // for each digit, the probability that each pixel 0-783 is black for that digit (class conditional probabilities)
    std::vector<std::vector<int> > classConditionalProbabilitiesCount(10, std::vector<int>(784, 0));


    for (int i = 0; i < trainLabels.size(); i++) {
            // cout << "label: " << static_cast<int>(trainLabels[i]) << endl;
            int digit = static_cast<int>(trainLabels[i]);
            priorProbabilitiesCount[digit]++;
            for (int j = 0; j < 784; j++) {
                classConditionalProbabilitiesCount[digit][j] += (static_cast<int>(trainImages[i][j])); //0 if black, 1 if white
            }
    }
    for (int i = 0; i < 10; i++) {
        
        priorProbabilities[i] = (double)priorProbabilitiesCount[i]/trainLabels.size();
         for (int j = 0; j < 784; j++) {
                double prob = (double)(classConditionalProbabilitiesCount[i][j]+1)/(priorProbabilitiesCount[i]+2);
                // cout << (classConditionalProbabilitiesCount[i][j]+1) << " / " << (priorProbabilitiesCount[i]+2) << " = " << prob << endl;
                classConditionalProbabilities[i][j] = prob;
        }
    }
}

void visualizeModel(vector<vector<double>> &classConditionalProbabilities) {
    
    int numLabels = 10;
    int numFeatures = 784;
    for (int c=0; c<numLabels; c++) {
       std::vector<unsigned char> classFs(numFeatures);
       for (int f=0; f<numFeatures; f++) {
        //TODO: get probability of pixel f being white given class c
            double p = classConditionalProbabilities[c][f];
           uint8_t v = 255*p;
           classFs[f] = (unsigned char)v;
       }
       std::stringstream ss;
       ss << "../../output/digit" <<c<<".bmp";
       Bitmap::writeBitmap(classFs, 28, 28, ss.str(), false);
   }
}

int getMostLikelyDigit( vector<double> &priorProbabilities, vector<vector<double>> &classConditionalProbabilities, vector<unsigned char> image) {
    
    vector<double> results(10, 0.0);

    for ( int i = 0; i < 10; i++ ) {

        double sumProbabilitiesForDigit = 0;

        for ( int j = 0; j < 784; j++) {
            // pixel is white
            if (static_cast<int>(image[j])) {
                //cout << "white " << classConditionalProbabilities[i][j] << endl;
                sumProbabilitiesForDigit += log(classConditionalProbabilities[i][j]);
            } else { // pixel is black
                //cout << "black " << 1-classConditionalProbabilities[i][j] << endl;
                sumProbabilitiesForDigit += log(1-classConditionalProbabilities[i][j]);
            }
            
        }
        results[i] = sumProbabilitiesForDigit + log(priorProbabilities[i]);
    }

    int result = std::distance(results.begin(), std::max_element(results.begin(), results.end()));

     // cout << " most likely digit is: " << result << endl;

    return result;
}


int main(int argc, char* argv[]) {
    //Read in the data set from the files
    mnist::MNIST_dataset<std::vector, std::vector<uint8_t>, uint8_t> dataset =
    mnist::read_dataset<std::vector, std::vector, uint8_t, uint8_t>(MNIST_DATA_DIR);
    //Binarize the data set (so that pixels have values of either 0 or 1)
    mnist::binarize_dataset(dataset);
    //There are ten possible digits 0-9 (classes)
    int numLabels = 10;
    //There are 784 features (one per pixel in a 28x28 image)
    int numFeatures = 784;
    //Each pixel value can take on the value 0 or 1
    int numFeatureValues = 2;
    //image width
    int width = 28;
    //image height
    int height = 28;
    //image to print (these two images were randomly selected by me with no particular preference)
    int trainImageToPrint = 50;
    int testImageToPrint = 5434;
    // get training images
    std::vector<std::vector<unsigned char>> trainImages = dataset.training_images;
    // get training labels
    std::vector<unsigned char> trainLabels = dataset.training_labels;

    // for (int i = 0; i < trainLabels.size(); i++) {
    //     cout<<static_cast<int>(trainLabels[i])<<endl;
    // }


    // get test images
    std::vector<std::vector<unsigned char>> testImages = dataset.test_images;
    // get test labels
    std::vector<unsigned char> testLabels = dataset.test_labels;

    std::vector<double> priorProbabilities(10, 0);
    std::vector<vector<double>> classConditionalProbabilities(10, std::vector<double>(784, 0.0));

    //print out one of the training images
    for (int f=0; f<numFeatures; f++) {
        // get value of pixel f (0 or 1) from training image trainImageToPrint
        int pixelIntValue = static_cast<int>(trainImages[trainImageToPrint][f]);
        if (f % width == 0) {
            std::cout<<std::endl;
        }
        std::cout<<pixelIntValue<<" ";
    }
    std::cout<<std::endl;
    // print the associated label (correct digit) for training image trainImageToPrint
    std::cout<<"Label: "<<static_cast<int>(trainLabels[trainImageToPrint])<<std::endl;
    //print out one of the test images
    for (int f=0; f<numFeatures; f++) {
        // get value of pixel f (0 or 1) from training image trainImageToPrint
        int pixelIntValue = static_cast<int>(testImages[testImageToPrint][f]);
        if (f % width == 0) {
            std::cout<<std::endl;
        }
        std::cout<<pixelIntValue<<" ";
    }
    std::cout<<std::endl;
    // print the associated label (correct digit) for test image testImageToPrint
    std::cout<<"Label: "<<static_cast<int>(testLabels[testImageToPrint])<<std::endl;
    std::vector<unsigned char> trainI(numFeatures);
    std::vector<unsigned char> testI(numFeatures);
    for (int f=0; f<numFeatures; f++) {
        int trainV = 255*(static_cast<int>(trainImages[trainImageToPrint][f]));
        int testV = 255*(static_cast<int>(testImages[testImageToPrint][f]));
        trainI[f] = static_cast<unsigned char>(trainV);
        testI[f] = static_cast<unsigned char>(testV);
    }
    std::stringstream ssTrain;
    std::stringstream ssTest;
    ssTrain << "../../output/train" <<trainImageToPrint<<"Label"<<static_cast<int>(trainLabels[trainImageToPrint])<<".bmp";
    ssTest << "../../output/test" <<testImageToPrint<<"Label"<<static_cast<int>(testLabels[testImageToPrint])<<".bmp";
    Bitmap::writeBitmap(trainI, 28, 28, ssTrain.str(), false);
    Bitmap::writeBitmap(testI, 28, 28, ssTest.str(), false);


    getPriorProbabilities(priorProbabilities, classConditionalProbabilities, trainLabels, trainImages);
    visualizeModel(classConditionalProbabilities);
    
    int resultDigit = getMostLikelyDigit(priorProbabilities, classConditionalProbabilities, testImages[testImageToPrint]);

    // cout << static_cast<int>(testLabels[testImageToPrint]) << " - " << resultDigit << endl;

    std::vector<vector<int>> resultMatrix(10, std::vector<int>(10, 0));
    int right= 0;
    for (int i = 0; i < testImages.size(); i++) {
        int actual = static_cast<int>(testLabels[i]);
        int guessed = getMostLikelyDigit(priorProbabilities, classConditionalProbabilities, testImages[i]);
        resultMatrix[actual][guessed]++;
        if (actual == guessed) {
            right++;
        }
    }


    for (int i = 0; i < resultMatrix.size(); i++) {
        for (int j = 0; j< resultMatrix[i].size(); j++) {
            cout << resultMatrix[i][j] << " ";
        }
        cout << endl;
    }
    cout << (double)right / testLabels.size() << endl;

    // print network
    ofstream myfile1 ("../../output/network.txt");
      if (myfile1.is_open())
      {
        for (int i = 0; i < classConditionalProbabilities.size(); i++) {  
            for (int j = 0; j < classConditionalProbabilities[i].size(); j++) {  
                myfile1 << classConditionalProbabilities[i][j] << "\n";
            }
        } 

        for (int i = 0; i < priorProbabilities.size(); i++) {  
            myfile1 << priorProbabilities[i] << "\n";
        }
        myfile1.close();
      }

    // print classification
  ofstream myfile2 ("../../output/classification-summary.txt");
  if (myfile2.is_open())
  {
    for (int i = 0; i < resultMatrix.size(); i++) {
        for (int j = 0; j< resultMatrix[i].size(); j++) {
            myfile2 << resultMatrix[i][j] << " ";
        }
        myfile2 << endl;
    }
    myfile2 << (double)right / testLabels.size() << endl;
    myfile2.close();
  }
    return 0;
}



// PROJECT 2.1 STEPS

// get the probability of each digit occuring by counting how many of each digit there is in the training set (prior probability)

// for each digit 0-9, find the probability that each pixel 0-783 is black for that digit (class conditional probabilities)

// the for each test image, compute the posterior probability distribution, or the probability of the image being 
// each digit based on our previous model

// We will predict that test image Ti represents the digit with the highest posterior probability

