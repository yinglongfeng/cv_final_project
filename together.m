dispR = 320;
halfBS = 3;
leftI = imread('reL1.png');
rightI = imread('reR1.png');
leftI = imresize(leftI,[300 400]);
rightI = imresize(rightI,[300 400]);
stereoDisparity_shenbei(leftI,rightI, dispR, halfBS);