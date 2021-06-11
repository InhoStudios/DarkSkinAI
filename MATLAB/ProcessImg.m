for i = 0:17
   fname = strcat('img', string(i), '.jpg');
   im = imread(fname);
   im2 = balanceImg(fname);
   imwrite(im2, strcat('export-', fname));
   montage({im, im2})
end

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

function transImg = applyLut(imgPath, lutPath)
    img = imread(imgPath);
    lut = dlmread(lutPath, ' ', 8, 0);
    [img_lut] = imlut(img, lut, '3D', 'standard');
    imshow(img_lut);
end