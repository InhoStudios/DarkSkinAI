A = imread('skinimg.jpg');
B = balanceImg('skinimg.jpg');
C = imread('blue-skinimg.jpg');
D = balanceImg('blue-skinimg.jpg');

imwrite(D, 'export-skinimg.jpg')

montage({A, B, C, D})

A1 = imread('psoriasisdark.jpg');
B1 = balanceImg('psoriasisdark.jpg');
C1 = imread('blue-psoriasisdark.jpg');
D1 = balanceImg('blue-psoriasisdark.jpg');

imwrite(D1, 'export-psoriasisdark.jpg')

montage({A, B, C, D})

A = imread('isic38.jpg');
B = balanceImg('isic38.jpg');

montage({A, B})

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