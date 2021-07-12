function rgbImage = balanceImg(path)
    rgbImage = imread(path);
    grayImage = rgb2gray(rgbImage); 
    redChannel = rgbImage(:, :, 1);
    greenChannel = rgbImage(:, :, 2);
    blueChannel = rgbImage(:, :, 3);
    meanR = mean2(redChannel);
    meanG = mean2(greenChannel);
    meanB = mean2(blueChannel);
    meanGray = mean2(grayImage);
    redChannel = uint8(double(redChannel) * 1.31 * meanGray / meanR);
    greenChannel = uint8(double(greenChannel) * meanGray / meanG);
    blueChannel = uint8(double(blueChannel) * 0.87 * meanGray / meanB);
    rgbImage = cat(3, redChannel, greenChannel, blueChannel);
end